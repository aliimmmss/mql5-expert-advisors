#!/usr/bin/env python3
"""
Neural EA - Prediction Server (TCP + HTTP)
Loads trained ML models and serves predictions via:
  - TCP socket on port 5555 (legacy)
  - HTTP on port 5556 (for MT5 WebRequest)

HTTP endpoint: POST http://127.0.0.1:5556/predict
  Body: JSON with lstm_input, features, price_input
  Response: JSON with signal, confidence, model outputs
"""

import json
import logging
import os
import socket
import sys
import threading
import time
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path
from typing import Optional

import numpy as np

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
HOST = "0.0.0.0"
TCP_PORT = 5555
HTTP_PORT = 5556
BASE_DIR = Path(__file__).resolve().parent.parent
MODELS_DIR = BASE_DIR / "models"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
log = logging.getLogger("neural-ea-server")


# ---------------------------------------------------------------------------
# Model Manager — load, predict, retrain, hot-reload
# ---------------------------------------------------------------------------
class ModelManager:
    """Thread-safe container for all 3 trading models."""

    def __init__(self, models_dir: Path):
        self.models_dir = models_dir
        self._lock = threading.RLock()

        # Models
        self.lstm_model = None
        self.catboost_model = None
        self.price_model = None

        # Config
        self.config: dict = {}
        self.seq_len_lstm = 20
        self.seq_len_price = 60
        self.n_features = 5
        self.feature_names = []

        # File modification tracking (for hot-reload)
        self._file_mtimes: dict[str, float] = {}

        # Load on init
        self.load_all()

    # ---- Loading ----------------------------------------------------------

    def load_all(self):
        """Load config + all models from disk."""
        with self._lock:
            self._load_config()
            self._load_lstm()
            self._load_catboost()
            self._load_price()
            self._update_mtimes()
            log.info("All models loaded successfully")

    def _load_config(self):
        cfg_path = self.models_dir / "model_config.json"
        if cfg_path.exists():
            with open(cfg_path) as f:
                self.config = json.load(f)
            self.seq_len_lstm = self.config.get("seq_len_lstm", 20)
            self.seq_len_price = self.config.get("seq_len_price", 60)
            self.n_features = self.config.get("n_features", 5)
            self.feature_names = self.config.get("feature_names", [])
            log.info(f"  Config: seq_len_lstm={self.seq_len_lstm}, "
                     f"seq_len_price={self.seq_len_price}, n_features={self.n_features}")
        else:
            log.warning("  No model_config.json found – using defaults")

    def _load_lstm(self):
        path = self.models_dir / "lstm_trend.keras"
        if not path.exists():
            log.warning(f"  LSTM model not found at {path}")
            self.lstm_model = None
            return
        try:
            from tensorflow.keras.models import load_model
            self.lstm_model = load_model(str(path))
            log.info(f"  Loaded LSTM Trend Filter from {path}")
        except ImportError:
            from keras.models import load_model
            self.lstm_model = load_model(str(path))
            log.info(f"  Loaded LSTM Trend Filter from {path}")

    def _load_catboost(self):
        path = self.models_dir / "catboost_signal.cbm"
        if not path.exists():
            log.warning(f"  CatBoost model not found at {path}")
            self.catboost_model = None
            return
        try:
            from catboost import CatBoostClassifier
            self.catboost_model = CatBoostClassifier()
            self.catboost_model.load_model(str(path))
            log.info(f"  Loaded CatBoost Signal Filter from {path}")
        except ImportError:
            log.error("  catboost package not installed!")

    def _load_price(self):
        path = self.models_dir / "price_predictor.keras"
        if not path.exists():
            log.warning(f"  Price model not found at {path}")
            self.price_model = None
            return
        try:
            from tensorflow.keras.models import load_model
            self.price_model = load_model(str(path))
            log.info(f"  Loaded Price Predictor from {path}")
        except ImportError:
            from keras.models import load_model
            self.price_model = load_model(str(path))
            log.info(f"  Loaded Price Predictor from {path}")

    def _update_mtimes(self):
        """Record current mtimes of model files for change detection."""
        for name in ("lstm_trend.keras", "catboost_signal.cbm",
                      "price_predictor.keras", "model_config.json"):
            p = self.models_dir / name
            if p.exists():
                self._file_mtimes[name] = p.stat().st_mtime

    # ---- Hot-reload -------------------------------------------------------

    def check_and_reload(self):
        """Check if any model file changed on disk; reload if so."""
        with self._lock:
            changed = False
            for name, old_mtime in self._file_mtimes.items():
                p = self.models_dir / name
                if p.exists():
                    new_mtime = p.stat().st_mtime
                    if new_mtime > old_mtime:
                        log.info(f"  Detected change in {name}, reloading ...")
                        changed = True
            if changed:
                self.load_all()

    # ---- Predict ----------------------------------------------------------

    def predict(self, request: dict) -> dict:
        """Run all models on the input and return combined result."""
        with self._lock:
            result = {
                "lstm_trend": None,
                "catboost_prob": None,
                "price_direction": None,
                "signal": "HOLD",
                "confidence": 0.0,
                "errors": [],
            }

            # --- LSTM Trend Filter ---
            lstm_input = request.get("lstm_input")
            if lstm_input is not None and self.lstm_model is not None:
                try:
                    arr = np.array(lstm_input, dtype=np.float32)
                    if arr.ndim == 2:
                        arr = arr.reshape(1, *arr.shape)  # add batch dim
                    pred = self.lstm_model.predict(arr, verbose=0)
                    result["lstm_trend"] = float(pred.flatten()[0])
                except Exception as e:
                    result["errors"].append(f"lstm: {e}")
            elif self.lstm_model is None:
                result["errors"].append("lstm: model not loaded")

            # --- CatBoost Signal Filter ---
            features = request.get("features")
            if features is not None and self.catboost_model is not None:
                try:
                    arr = np.array(features, dtype=np.float32)
                    if arr.ndim == 1:
                        arr = arr.reshape(1, -1)
                    proba = self.catboost_model.predict_proba(arr)
                    # Class 1 = win probability
                    result["catboost_prob"] = float(proba[0][1]) if proba.ndim == 2 else float(proba[0])
                except Exception as e:
                    result["errors"].append(f"catboost: {e}")
            elif self.catboost_model is None:
                result["errors"].append("catboost: model not loaded")

            # --- Price Predictor ---
            price_input = request.get("price_input")
            if price_input is not None and self.price_model is not None:
                try:
                    arr = np.array(price_input, dtype=np.float32)
                    if arr.ndim == 2:
                        arr = arr.reshape(1, *arr.shape)
                    pred = self.price_model.predict(arr, verbose=0)
                    result["price_direction"] = float(pred.flatten()[0])
                except Exception as e:
                    result["errors"].append(f"price: {e}")
            elif self.price_model is None:
                result["errors"].append("price: model not loaded")

            # --- Combine into trading signal ---
            result["signal"], result["confidence"] = self._combine_signals(result)

            if not result["errors"]:
                del result["errors"]

            return result

    def _combine_signals(self, result: dict) -> tuple[str, float]:
        """Combine model outputs into BUY / SELL / HOLD with confidence score."""
        signals = []
        weights = []

        # LSTM trend: ADX > 25 means strong trend; positive slope = uptrend
        if result["lstm_trend"] is not None:
            adx = result["lstm_trend"]
            if adx > 25:
                signals.append(1.0 if adx > 30 else 0.5)
            elif adx < 15:
                signals.append(-0.5)
            else:
                signals.append(0.0)
            weights.append(0.3)

        # CatBoost: win probability > 0.6 = BUY zone, < 0.4 = SELL zone
        if result["catboost_prob"] is not None:
            prob = result["catboost_prob"]
            if prob > 0.6:
                signals.append(1.0)
            elif prob < 0.4:
                signals.append(-1.0)
            else:
                signals.append(0.0)
            weights.append(0.35)

        # Price direction: > 0.5 = bullish, < 0.5 = bearish
        if result["price_direction"] is not None:
            direction = result["price_direction"]
            if direction > 0.6:
                signals.append(1.0)
            elif direction < 0.4:
                signals.append(-1.0)
            else:
                signals.append(0.0)
            weights.append(0.35)

        if not signals:
            return "HOLD", 0.0

        # Weighted average
        weights_arr = np.array(weights)
        weights_arr /= weights_arr.sum()
        score = float(np.dot(signals, weights_arr))

        # Map score to signal + confidence
        confidence = min(abs(score), 1.0)
        if score > 0.2:
            return "BUY", confidence
        elif score < -0.2:
            return "SELL", confidence
        else:
            return "HOLD", confidence

    # ---- Retrain ----------------------------------------------------------

    def retrain(self, request: dict) -> dict:
        """Incrementally retrain models with new data."""
        from train_models import (
            incremental_retrain_lstm,
            incremental_retrain_catboost,
            incremental_retrain_price,
            save_model,
        )

        with self._lock:
            data = request.get("data", {})
            results = {}

            # Retrain LSTM
            if "lstm_X" in data and "lstm_y" in data and self.lstm_model is not None:
                X = np.array(data["lstm_X"], dtype=np.float32)
                y = np.array(data["lstm_y"], dtype=np.float32)
                self.lstm_model = incremental_retrain_lstm(self.lstm_model, X, y,
                                                           epochs=data.get("epochs", 5))
                save_model(self.lstm_model, "lstm_trend", "keras", "native")
                results["lstm_trend"] = "retrained"

            # Retrain CatBoost
            if "catboost_X" in data and "catboost_y" in data and self.catboost_model is not None:
                X = np.array(data["catboost_X"], dtype=np.float32)
                y = np.array(data["catboost_y"], dtype=int)
                self.catboost_model = incremental_retrain_catboost(
                    self.catboost_model, X, y, iterations=data.get("iterations", 50))
                save_model(self.catboost_model, "catboost_signal", "catboost", "native")
                results["catboost_signal"] = "retrained"

            # Retrain Price Predictor
            if "price_X" in data and "price_y" in data and self.price_model is not None:
                X = np.array(data["price_X"], dtype=np.float32)
                y = np.array(data["price_y"], dtype=int)
                self.price_model = incremental_retrain_price(self.price_model, X, y,
                                                             epochs=data.get("epochs", 5))
                save_model(self.price_model, "price_predictor", "keras", "native")
                results["price_predictor"] = "retrained"

            self._update_mtimes()
            return {"status": "ok", "retrained": results}

    def status(self) -> dict:
        return {
            "lstm_loaded": self.lstm_model is not None,
            "catboost_loaded": self.catboost_model is not None,
            "price_loaded": self.price_model is not None,
            "seq_len_lstm": self.seq_len_lstm,
            "seq_len_price": self.seq_len_price,
            "n_features": self.n_features,
            "model_dir": str(self.models_dir),
        }


# ---------------------------------------------------------------------------
# HTTP Server (for MT5 WebRequest)
# ---------------------------------------------------------------------------
# Global model manager shared between TCP and HTTP
model_manager: Optional[ModelManager] = None


class PredictionHTTPHandler(BaseHTTPRequestHandler):
    """HTTP handler for MT5 WebRequest."""

    def log_message(self, format, *args):
        """Redirect HTTP logs to our logger."""
        log.info(f"HTTP {args[0]}")

    def do_POST(self):
        content_length = int(self.headers.get("Content-Length", 0))
        if content_length == 0:
            self._send_json(400, {"error": "Empty request body"})
            return

        try:
            body = self.rfile.read(content_length)
            request = json.loads(body.decode("utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError) as e:
            self._send_json(400, {"error": f"Invalid JSON: {e}"})
            return

        command = request.get("command", "predict")

        try:
            if command == "predict":
                result = model_manager.predict(request)
                self._send_json(200, result)
            elif command == "status":
                self._send_json(200, model_manager.status())
            elif command == "retrain":
                result = model_manager.retrain(request)
                self._send_json(200, result)
            elif command == "reload":
                model_manager.load_all()
                self._send_json(200, {"status": "reloaded"})
            else:
                self._send_json(400, {"error": f"Unknown command: {command}"})
        except Exception as e:
            log.exception(f"Error processing {command}")
            self._send_json(500, {"error": str(e)})

    def do_GET(self):
        if self.path == "/status":
            self._send_json(200, model_manager.status())
        else:
            self._send_json(200, {"status": "Neural EA Server", "endpoints": ["/predict", "/status"]})

    def _send_json(self, code: int, data: dict):
        response = json.dumps(data).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(response)))
        self.end_headers()
        self.wfile.write(response)


# ---------------------------------------------------------------------------
# TCP Server (legacy)
# ---------------------------------------------------------------------------
class NeuralEASServer:
    """Multi-threaded TCP server for Neural EA predictions."""

    def __init__(self, host: str, port: int):
        self.host = host
        self.port = port
        self._running = False
        self._server_socket: Optional[socket.socket] = None

    def start(self):
        """Start the TCP server."""
        self._running = True
        self._server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self._server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self._server_socket.settimeout(1.0)
        self._server_socket.bind((self.host, self.port))
        self._server_socket.listen(16)
        log.info(f"TCP server listening on {self.host}:{self.port}")

        try:
            while self._running:
                try:
                    client_sock, addr = self._server_socket.accept()
                    t = threading.Thread(target=self._handle_client,
                                         args=(client_sock, addr), daemon=True)
                    t.start()
                except socket.timeout:
                    continue
        except KeyboardInterrupt:
            pass
        finally:
            self._running = False
            if self._server_socket:
                self._server_socket.close()

    def _handle_client(self, sock: socket.socket, addr):
        buffer = b""
        try:
            sock.settimeout(60.0)
            while self._running:
                chunk = sock.recv(65536)
                if not chunk:
                    break
                buffer += chunk
                while b"\n" in buffer:
                    line, buffer = buffer.split(b"\n", 1)
                    line = line.strip()
                    if not line:
                        continue
                    request = json.loads(line)
                    command = request.get("command", "predict")
                    if command == "predict":
                        result = model_manager.predict(request)
                    elif command == "status":
                        result = model_manager.status()
                    elif command == "retrain":
                        result = model_manager.retrain(request)
                    elif command == "reload":
                        model_manager.load_all()
                        result = {"status": "reloaded"}
                    else:
                        result = {"error": f"Unknown command: {command}"}
                    sock.sendall((json.dumps(result) + "\n").encode("utf-8"))
        except (socket.timeout, ConnectionResetError, BrokenPipeError):
            pass
        except Exception as e:
            log.error(f"TCP client error ({addr}): {e}")
        finally:
            sock.close()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    import argparse
    parser = argparse.ArgumentParser(description="Neural EA Prediction Server")
    parser.add_argument("--host", type=str, default=HOST, help=f"Bind address (default: {HOST})")
    parser.add_argument("--tcp-port", type=int, default=TCP_PORT, help=f"TCP port (default: {TCP_PORT})")
    parser.add_argument("--http-port", type=int, default=HTTP_PORT, help=f"HTTP port (default: {HTTP_PORT})")
    args = parser.parse_args()

    global model_manager
    model_manager = ModelManager(MODELS_DIR)

    # Start hot-reload watcher
    def reload_watcher():
        while True:
            time.sleep(5)
            try:
                model_manager.check_and_reload()
            except Exception as e:
                log.error(f"Reload check failed: {e}")

    watcher = threading.Thread(target=reload_watcher, daemon=True)
    watcher.start()

    # Start HTTP server in background thread
    http_server = HTTPServer((args.host, args.http_port), PredictionHTTPHandler)
    http_thread = threading.Thread(target=http_server.serve_forever, daemon=True)
    http_thread.start()
    log.info(f"HTTP server listening on {args.host}:{args.http_port}")
    log.info(f"  POST http://127.0.0.1:{args.http_port}/predict")
    log.info(f"  GET  http://127.0.0.1:{args.http_port}/status")

    # Start TCP server in main thread
    log.info(f"Models dir: {MODELS_DIR}")
    tcp_server = NeuralEASServer(args.host, args.tcp_port)
    tcp_server.start()


if __name__ == "__main__":
    main()
