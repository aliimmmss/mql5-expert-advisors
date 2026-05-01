#!/usr/bin/env python3
"""
Neural EA - TCP Prediction Server
Loads trained ML models and serves real-time predictions over TCP (port 5555).

Protocol:
  - JSON request  → JSON response
  - Request types: "predict" (default), "retrain", "status", "reload"

Example predict request:
  {"features": [...], "lstm_input": [...], "price_input": [...], "feature_names": [...]}

Example response:
  {"lstm_trend": 25.3, "catboost_prob": 0.78, "price_direction": 0.65,
   "signal": "BUY", "confidence": 0.72}

Example retrain request:
  {"command": "retrain", "data": {"lstm_X": [...], "lstm_y": [...],
   "catboost_X": [...], "catboost_y": [...], "price_X": [...], "price_y": [...]}}
"""

import json
import logging
import os
import socket
import sys
import threading
import time
from pathlib import Path
from typing import Optional

import numpy as np

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
HOST = "0.0.0.0"
PORT = 5555
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
# TCP Server
# ---------------------------------------------------------------------------
class NeuralEAServer:
    """Multi-threaded TCP server for Neural EA predictions."""

    def __init__(self, host: str, port: int):
        self.host = host
        self.port = port
        self.model_manager = ModelManager(MODELS_DIR)
        self._running = False
        self._server_socket: Optional[socket.socket] = None
        self._reload_thread: Optional[threading.Thread] = None

    def start(self):
        """Start the TCP server."""
        self._running = True
        self._server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self._server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self._server_socket.settimeout(1.0)  # allow periodic shutdown check
        self._server_socket.bind((self.host, self.port))
        self._server_socket.listen(16)
        log.info(f"Neural EA Server listening on {self.host}:{self.port}")
        log.info(f"Models dir: {MODELS_DIR}")

        # Background thread to watch for model file changes
        self._reload_thread = threading.Thread(target=self._reload_watcher, daemon=True)
        self._reload_thread.start()

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
            log.info("Shutting down ...")
        finally:
            self._running = False
            if self._server_socket:
                self._server_socket.close()

    def _reload_watcher(self):
        """Background thread: check for model file changes every 5s."""
        while self._running:
            time.sleep(5)
            try:
                self.model_manager.check_and_reload()
            except Exception as e:
                log.error(f"Reload check failed: {e}")

    def _handle_client(self, sock: socket.socket, addr):
        """Handle a single client connection (may send multiple requests)."""
        log.debug(f"Client connected: {addr}")
        buffer = b""
        try:
            sock.settimeout(60.0)
            while self._running:
                chunk = sock.recv(65536)
                if not chunk:
                    break
                buffer += chunk

                # Process all complete JSON messages (newline-delimited)
                while b"\n" in buffer:
                    line, buffer = buffer.split(b"\n", 1)
                    line = line.strip()
                    if not line:
                        continue
                    response = self._process_message(line)
                    sock.sendall((json.dumps(response) + "\n").encode("utf-8"))
        except (socket.timeout, ConnectionResetError, BrokenPipeError):
            pass
        except Exception as e:
            log.error(f"Client handler error ({addr}): {e}")
        finally:
            sock.close()
            log.debug(f"Client disconnected: {addr}")

    def _process_message(self, raw: bytes) -> dict:
        """Parse a JSON message and dispatch to the right handler."""
        try:
            request = json.loads(raw)
        except json.JSONDecodeError as e:
            return {"error": f"Invalid JSON: {e}"}

        command = request.get("command", "predict")

        try:
            if command == "predict":
                return self.model_manager.predict(request)
            elif command == "retrain":
                return self.model_manager.retrain(request)
            elif command == "status":
                return self.model_manager.status()
            elif command == "reload":
                self.model_manager.load_all()
                return {"status": "reloaded"}
            else:
                return {"error": f"Unknown command: {command}"}
        except Exception as e:
            log.exception(f"Error processing command '{command}'")
            return {"error": str(e)}


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    import argparse
    parser = argparse.ArgumentParser(description="Neural EA TCP Prediction Server")
    parser.add_argument("--host", type=str, default=HOST, help=f"Bind address (default: {HOST})")
    parser.add_argument("--port", type=int, default=PORT, help=f"Bind port (default: {PORT})")
    args = parser.parse_args()

    server = NeuralEAServer(args.host, args.port)
    server.start()


if __name__ == "__main__":
    main()
