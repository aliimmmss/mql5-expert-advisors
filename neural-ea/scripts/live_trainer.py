"""
Neural EA — Live Training Script
Receives live market data from the EA running on a chart via HTTP,
accumulates it with delayed labeling, and periodically retrains all 3 models.

Architecture:
  EA on chart (MQL5 WebRequest) → HTTP POST → live_trainer.py
  live_trainer accumulates + labels → retrains → saves ONNX → signals reload

Labeling strategy:
  - Price direction: labeled after 1 bar (next close vs current close)
  - ADX future mean: labeled after 10 bars
  - Win/Loss: labeled when EA reports a trade outcome (linked by timestamp)

Retraining:
  - Triggers every N new labeled samples (default 100)
  - Merges live data with historical CSV data
  - Retrains all 3 models, exports to ONNX
  - Signals companion prediction server (if running) to reload

Usage:
  python live_trainer.py --port 8099 --retrain-every 100 --data-dir ../data

EA integration (MQL5 WebRequest):
  In the EA, add WebRequest("POST", "http://localhost:8099/snapshot", ..., json_body, result);
"""

import json
import time
import threading
import logging
import signal
import sys
import argparse
import os
from pathlib import Path
from datetime import datetime, timezone
from collections import deque
from http.server import HTTPServer, BaseHTTPRequestHandler
from typing import Optional

import numpy as np
import pandas as pd

# ──────────────────────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────────────────────

BASE_DIR = Path(__file__).parent.parent
DATA_DIR = BASE_DIR / 'data'
MODELS_DIR = BASE_DIR / 'models'
MODELS_DIR.mkdir(parents=True, exist_ok=True)
DATA_DIR.mkdir(parents=True, exist_ok=True)

# Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
log = logging.getLogger('live_trainer')


# ──────────────────────────────────────────────────────────────
# Feature schema — must match train_models.py and DataCollector EA
# ──────────────────────────────────────────────────────────────

FEATURE_COLUMNS = [
    'open', 'high', 'low', 'close',
    'candle_return', 'candle_body_pct', 'upper_wick_pct', 'lower_wick_pct',
    'adx', 'adx_plus', 'adx_minus',
    'rsi',
    'macd_main', 'macd_signal', 'macd_hist',
    'psar', 'atr',
    'sma50', 'sma200',
    'bb_upper', 'bb_middle', 'bb_lower',
    'mfi', 'cci', 'stoch_k', 'stoch_d', 'wpr',
    'obv', 'ad',
    'ha_open', 'ha_close', 'ha_high', 'ha_low',
    'close_vs_sma50', 'close_vs_sma200', 'close_vs_bb_mid',
    'adx_1', 'adx_2', 'adx_3', 'adx_4',
    'rsi_1', 'rsi_2', 'rsi_3', 'rsi_4',
    'close_return_1', 'close_return_2', 'close_return_3', 'close_return_4',
]

LABEL_COLUMNS = ['label_adx_future_10', 'label_price_direction', 'label_win']

# SMA50-based direction for win labeling (same as DataCollector)
ADX_LABEL_BARS = 10   # How many bars ahead for ADX future label


# ──────────────────────────────────────────────────────────────
# Live Data Buffer
# ──────────────────────────────────────────────────────────────

class LiveDataBuffer:
    """
    Thread-safe rolling buffer of live market snapshots.
    Stores incoming data with timestamps and allows delayed labeling.
    """

    def __init__(self, max_size: int = 10000):
        self.max_size = max_size
        self._lock = threading.Lock()
        # snapshots: list of dicts with 'timestamp', 'features', 'labels' (None until labeled)
        self._snapshots: list[dict] = []
        self._labeled_since_retrain: int = 0
        self._total_received: int = 0
        self._total_labeled: int = 0

    def add_snapshot(self, timestamp: str, features: dict):
        """Add a new unlabeled snapshot."""
        with self._lock:
            self._snapshots.append({
                'timestamp': timestamp,
                'features': features,
                'labels': {
                    'label_adx_future_10': None,
                    'label_price_direction': None,
                    'label_win': None,
                }
            })
            self._total_received += 1

            # Trim oldest if over max
            if len(self._snapshots) > self.max_size:
                self._snapshots = self._snapshots[-self.max_size:]

    def label_price_direction(self, timestamp: str, next_close: float):
        """
        Label all snapshots whose timestamp is 1 bar before the given timestamp.
        next_close is the close price of the bar AFTER the snapshot.
        """
        labeled = 0
        with self._lock:
            for snap in self._snapshots:
                if snap['labels']['label_price_direction'] is None:
                    snap_close = snap['features'].get('close', 0)
                    if snap_close > 0:
                        snap['labels']['label_price_direction'] = 1 if next_close > snap_close else 0
                        labeled += 1
                        self._check_fully_labeled(snap)

        if labeled > 0:
            log.info(f"Labeled price_direction for {labeled} snapshot(s)")
        return labeled

    def label_adx_future(self, timestamps_to_label: list[str], adx_values: list[float]):
        """
        Label snapshots whose timestamp matches, with the mean ADX of the next 10 bars.
        Called when we have 10 bars of ADX after the snapshot.
        """
        labeled = 0
        with self._lock:
            for snap in self._snapshots:
                if snap['timestamp'] in timestamps_to_label and \
                   snap['labels']['label_adx_future_10'] is None:
                    idx = timestamps_to_label.index(snap['timestamp'])
                    # Mean of the 10 ADX values after this snapshot
                    mean_adx = np.mean(adx_values[idx:idx+ADX_LABEL_BARS]) \
                        if idx + ADX_LABEL_BARS <= len(adx_values) else np.mean(adx_values[idx:])
                    snap['labels']['label_adx_future_10'] = float(mean_adx)
                    labeled += 1
                    self._check_fully_labeled(snap)

        if labeled > 0:
            log.info(f"Labeled adx_future_10 for {labeled} snapshot(s)")
        return labeled

    def label_trade_outcome(self, timestamp: str, is_win: bool):
        """
        Label the snapshot at (or nearest before) the given timestamp with win/loss.
        Called when the EA reports a closed trade result.
        """
        with self._lock:
            # Find the closest snapshot at or before the trade timestamp
            target_ts = self._parse_ts(timestamp)
            best_snap = None
            best_diff = float('inf')

            for snap in self._snapshots:
                if snap['labels']['label_win'] is not None:
                    continue
                snap_ts = self._parse_ts(snap['timestamp'])
                diff = abs((target_ts - snap_ts).total_seconds())
                if diff < best_diff:
                    best_diff = diff
                    best_snap = snap

            if best_snap and best_diff < 7200:  # Within 2 hours
                best_snap['labels']['label_win'] = 1 if is_win else 0
                self._check_fully_labeled(best_snap)
                log.info(f"Labeled win={is_win} for snapshot {best_snap['timestamp']}")
                return True

        log.warning(f"No matching snapshot found for trade at {timestamp}")
        return False

    def _check_fully_labeled(self, snap: dict):
        """Check if a snapshot has all labels; if so, count it."""
        if all(v is not None for v in snap['labels'].values()):
            self._total_labeled += 1
            self._labeled_since_retrain += 1

    def get_labeled_dataframe(self) -> pd.DataFrame:
        """Return all fully-labeled snapshots as a DataFrame."""
        with self._lock:
            rows = []
            for snap in self._snapshots:
                if all(v is not None for v in snap['labels'].values()):
                    row = dict(snap['features'])
                    row.update(snap['labels'])
                    rows.append(row)

        if not rows:
            return pd.DataFrame()

        df = pd.DataFrame(rows)
        # Ensure column order matches training schema
        all_cols = FEATURE_COLUMNS + LABEL_COLUMNS
        for col in all_cols:
            if col not in df.columns:
                df[col] = 0
        return df[all_cols].dropna()

    def get_unlabeled_count(self) -> int:
        """Return count of snapshots still waiting for labels."""
        with self._lock:
            return sum(1 for s in self._snapshots
                       if any(v is None for v in s['labels'].values()))

    def get_labeled_since_retrain(self) -> int:
        with self._lock:
            return self._labeled_since_retrain

    def reset_retrain_counter(self):
        with self._lock:
            self._labeled_since_retrain = 0

    def stats(self) -> dict:
        with self._lock:
            return {
                'total_snapshots': len(self._snapshots),
                'total_received': self._total_received,
                'total_labeled': self._total_labeled,
                'labeled_since_retrain': self._labeled_since_retrain,
                'unlabeled': sum(1 for s in self._snapshots
                                 if any(v is None for v in s['labels'].values())),
            }

    @staticmethod
    def _parse_ts(ts: str) -> datetime:
        """Parse timestamp string to datetime."""
        for fmt in ('%Y-%m-%dT%H:%M:%S', '%Y.%m.%d %H:%M:%S', '%Y-%m-%d %H:%M:%S'):
            try:
                return datetime.strptime(ts, fmt).replace(tzinfo=timezone.utc)
            except ValueError:
                continue
        return datetime.now(timezone.utc)


# ──────────────────────────────────────────────────────────────
# Model Retrainer
# ──────────────────────────────────────────────────────────────

class ModelRetrainer:
    """
    Retrains all 3 neural models using accumulated live data
    merged with historical backtest data.
    """

    def __init__(self, data_dir: Path, models_dir: Path):
        self.data_dir = data_dir
        self.models_dir = models_dir
        self._lock = threading.Lock()
        self._is_training = False
        self._last_train_time: Optional[float] = None
        self._last_train_result: Optional[str] = None
        self._train_count: int = 0

    @property
    def is_training(self) -> bool:
        with self._lock:
            return self._is_training

    def retrain(self, live_df: pd.DataFrame, historical_csv: Optional[str] = None):
        """
        Merge live + historical data, retrain all models, export ONNX.
        This runs in a background thread.
        """
        with self._lock:
            if self._is_training:
                log.warning("Training already in progress, skipping")
                return
            self._is_training = True

        try:
            log.info("=" * 60)
            log.info("RETRAIN TRIGGERED")
            log.info("=" * 60)

            # ── Merge data ──
            df = self._merge_data(live_df, historical_csv)
            if len(df) < 50:
                log.warning(f"Only {len(df)} samples — need at least 50 to train. Skipping.")
                return

            log.info(f"Training dataset: {len(df)} samples")

            # ── Train all 3 models ──
            # Import train_models functions (reuse existing pipeline)
            self._train_all_models(df)

            # ── Save labeled live data as CSV for future runs ──
            live_csv_path = self.data_dir / 'live_labeled_data.csv'
            live_df.to_csv(live_csv_path, index=False)
            log.info(f"Saved {len(live_df)} live labeled samples to {live_csv_path}")

            # ── Signal companion server to reload ──
            self._signal_reload()

            with self._lock:
                self._train_count += 1
                self._last_train_time = time.time()
                self._last_train_result = f"OK — {len(df)} samples, train #{self._train_count}"

            log.info(f"Retraining complete (#{self._train_count})")

        except Exception as e:
            log.error(f"Retraining failed: {e}", exc_info=True)
            with self._lock:
                self._last_train_result = f"FAILED: {e}"

        finally:
            with self._lock:
                self._is_training = False

    def _merge_data(self, live_df: pd.DataFrame, historical_csv: Optional[str]) -> pd.DataFrame:
        """Merge live labeled data with historical CSV data."""
        frames = [live_df]

        # Load historical backtest data if available
        hist_path = historical_csv or str(self.data_dir / 'neural_training_data.csv')
        if os.path.exists(hist_path):
            try:
                hist_df = pd.read_csv(hist_path)
                if 'datetime' in hist_df.columns:
                    hist_df = hist_df.drop('datetime', axis=1)
                hist_df = hist_df.dropna()
                log.info(f"Loaded {len(hist_df)} historical samples from {hist_path}")
                frames.append(hist_df)
            except Exception as e:
                log.warning(f"Could not load historical data: {e}")

        # Load previously saved live data
        prev_live_path = self.data_dir / 'live_labeled_data.csv'
        if prev_live_path.exists() and str(prev_live_path) != str(historical_csv or ''):
            try:
                prev_df = pd.read_csv(prev_live_path)
                prev_df = prev_df.dropna()
                log.info(f"Loaded {len(prev_df)} previous live samples")
                frames.append(prev_df)
            except Exception as e:
                log.warning(f"Could not load previous live data: {e}")

        merged = pd.concat(frames, ignore_index=True)

        # Deduplicate by checking for exact row matches
        merged = merged.drop_duplicates()
        log.info(f"Merged dataset: {len(merged)} total samples")

        return merged

    def _train_all_models(self, df: pd.DataFrame):
        """Train all 3 models using the existing train_models pipeline."""
        # We import here to avoid heavy imports at startup
        sys.path.insert(0, str(Path(__file__).parent))
        import train_models

        # Update the module's MODELS_DIR to ensure correct output path
        train_models.MODELS_DIR = self.models_dir
        train_models.MODELS_DIR.mkdir(parents=True, exist_ok=True)

        # Train LSTM Trend Filter
        try:
            log.info("Training LSTM Trend Filter...")
            train_models.train_lstm_trend(df)
            log.info("LSTM Trend Filter: DONE")
        except Exception as e:
            log.error(f"LSTM training failed: {e}", exc_info=True)

        # Train CatBoost Signal Filter
        try:
            log.info("Training CatBoost Signal Filter...")
            train_models.train_catboost_filter(df)
            log.info("CatBoost Signal Filter: DONE")
        except Exception as e:
            log.error(f"CatBoost training failed: {e}", exc_info=True)

        # Train Price Predictor
        try:
            log.info("Training Price Predictor...")
            train_models.train_price_predictor(df)
            log.info("Price Predictor: DONE")
        except Exception as e:
            log.error(f"Price Predictor training failed: {e}", exc_info=True)

    def _signal_reload(self):
        """
        Signal a companion prediction server to reload updated models.
        Tries localhost:8098/reload (configurable).
        """
        try:
            import urllib.request
            req = urllib.request.Request(
                'http://localhost:8098/reload',
                method='POST',
                data=b'{}',
                headers={'Content-Type': 'application/json'}
            )
            with urllib.request.urlopen(req, timeout=5) as resp:
                if resp.status == 200:
                    log.info("Signaled prediction server to reload models")
                else:
                    log.warning(f"Reload signal returned status {resp.status}")
        except Exception as e:
            log.debug(f"No prediction server running (reload signal failed): {e}")

    def status(self) -> dict:
        with self._lock:
            return {
                'is_training': self._is_training,
                'train_count': self._train_count,
                'last_train_time': self._last_train_time,
                'last_train_result': self._last_train_result,
            }


# ──────────────────────────────────────────────────────────────
# HTTP Server Handler
# ──────────────────────────────────────────────────────────────

# Global state — accessed by handler
_buffer: Optional[LiveDataBuffer] = None
_retrainer: Optional[ModelRetrainer] = None
_retrain_every: int = 100
_background_adx_buffer: dict = {}  # timestamp → [adx values]


class LiveTrainerHandler(BaseHTTPRequestHandler):
    """HTTP request handler for EA communication."""

    def do_GET(self):
        if self.path == '/status':
            self._json_response(200, {
                'status': 'running',
                'buffer': _buffer.stats() if _buffer else {},
                'retrainer': _retrainer.status() if _retrainer else {},
                'retrain_threshold': _retrain_every,
            })
        elif self.path == '/health':
            self._json_response(200, {'ok': True})
        else:
            self._json_response(404, {'error': 'Not found'})

    def do_POST(self):
        content_len = int(self.headers.get('Content-Length', 0))
        if content_len == 0:
            self._json_response(400, {'error': 'Empty body'})
            return

        body = self.rfile.read(content_len)
        try:
            data = json.loads(body)
        except json.JSONDecodeError:
            self._json_response(400, {'error': 'Invalid JSON'})
            return

        if self.path == '/snapshot':
            self._handle_snapshot(data)
        elif self.path == '/trade_outcome':
            self._handle_trade_outcome(data)
        elif self.path == '/label_direction':
            self._handle_label_direction(data)
        elif self.path == '/label_adx':
            self._handle_label_adx(data)
        elif self.path == '/reload':
            self._json_response(200, {'ok': True, 'note': 'Models will be reloaded on next retrain'})
        else:
            self._json_response(404, {'error': 'Not found'})

    def _handle_snapshot(self, data: dict):
        """
        POST /snapshot
        Body: { "timestamp": "2025-05-01T12:00:00", "features": { ... } }
        """
        timestamp = data.get('timestamp', datetime.now(timezone.utc).isoformat())
        features = data.get('features', {})

        if not features:
            self._json_response(400, {'error': 'Missing features'})
            return

        _buffer.add_snapshot(timestamp, features)
        stats = _buffer.stats()

        # Check if retrain threshold reached
        if stats['labeled_since_retrain'] >= _retrain_every and not _retrainer.is_training:
            labeled_df = _buffer.get_labeled_dataframe()
            if len(labeled_df) >= _retrain_every:
                _buffer.reset_retrain_counter()
                thread = threading.Thread(
                    target=_retrainer.retrain,
                    args=(labeled_df,),
                    daemon=True
                )
                thread.start()

        self._json_response(200, {
            'ok': True,
            'buffer_size': stats['total_snapshots'],
            'labeled': stats['total_labeled'],
            'unlabeled': stats['unlabeled'],
        })

    def _handle_trade_outcome(self, data: dict):
        """
        POST /trade_outcome
        Body: { "timestamp": "2025-05-01T12:00:00", "is_win": true/false }
        """
        timestamp = data.get('timestamp', '')
        is_win = data.get('is_win')

        if is_win is None or not timestamp:
            self._json_response(400, {'error': 'Missing timestamp or is_win'})
            return

        success = _buffer.label_trade_outcome(timestamp, bool(is_win))
        self._json_response(200, {'ok': success, 'stats': _buffer.stats()})

    def _handle_label_direction(self, data: dict):
        """
        POST /label_direction
        Body: { "bar_timestamp": "2025-05-01T12:00:00", "next_close": 2345.67 }

        The EA calls this 1 bar after sending a snapshot, providing
        the close price of the new bar so we can label price direction.
        """
        bar_ts = data.get('bar_timestamp', '')
        next_close = data.get('next_close')

        if not bar_ts or next_close is None:
            self._json_response(400, {'error': 'Missing bar_timestamp or next_close'})
            return

        labeled = _buffer.label_price_direction(bar_ts, float(next_close))

        # Also accumulate ADX values for future labeling
        adx_val = data.get('current_adx')
        if adx_val is not None:
            _background_adx_buffer.setdefault('__adx_values__', []).append(float(adx_val))
            _background_adx_buffer.setdefault('__timestamps__', []).append(bar_ts)

            # Once we have ADX_LABEL_BARS+1 bars, label the oldest pending snapshot
            adx_vals = _background_adx_buffer.get('__adx_values__', [])
            ts_list = _background_adx_buffer.get('__timestamps__', [])
            if len(adx_vals) >= ADX_LABEL_BARS + 1:
                # Label the snapshot from ADX_LABEL_BARS ago
                ts_to_label = ts_list[:1]
                _buffer.label_adx_future(ts_to_label, adx_vals)
                # Shift window
                _background_adx_buffer['__adx_values__'] = adx_vals[1:]
                _background_adx_buffer['__timestamps__'] = ts_list[1:]

        self._json_response(200, {'ok': True, 'labeled_direction': labeled})

    def _handle_label_adx(self, data: dict):
        """
        POST /label_adx
        Body: { "timestamps": [...], "adx_values": [... (10 values)] }
        Direct labeling of ADX future values.
        """
        timestamps = data.get('timestamps', [])
        adx_values = data.get('adx_values', [])

        if not timestamps or not adx_values:
            self._json_response(400, {'error': 'Missing timestamps or adx_values'})
            return

        labeled = _buffer.label_adx_future(timestamps, adx_values)
        self._json_response(200, {'ok': True, 'labeled': labeled})

    def _json_response(self, status: int, data: dict):
        body = json.dumps(data).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        """Suppress default HTTP logging — use our structured logger."""
        pass


# ──────────────────────────────────────────────────────────────
# Background Retrain Monitor
# ──────────────────────────────────────────────────────────────

def retrain_monitor_loop(interval_sec: int = 60):
    """
    Periodic check: if enough labeled data has accumulated,
    trigger a retrain even if the threshold wasn't hit by incoming data.
    """
    while True:
        time.sleep(interval_sec)
        try:
            if _buffer and _retrainer:
                if _buffer.get_labeled_since_retrain() >= _retrain_every and \
                   not _retrainer.is_training:
                    labeled_df = _buffer.get_labeled_dataframe()
                    if len(labeled_df) >= _retrain_every:
                        _buffer.reset_retrain_counter()
                        log.info(f"Periodic monitor: triggering retrain with {len(labeled_df)} samples")
                        _retrainer.retrain(labeled_df)
        except Exception as e:
            log.error(f"Monitor loop error: {e}")


# ──────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────

def main():
    global _buffer, _retrainer, _retrain_every

    parser = argparse.ArgumentParser(description='Neural EA Live Trainer')
    parser.add_argument('--port', type=int, default=8099,
                        help='HTTP server port (default: 8099)')
    parser.add_argument('--host', type=str, default='0.0.0.0',
                        help='HTTP server bind address (default: 0.0.0.0)')
    parser.add_argument('--retrain-every', type=int, default=100,
                        help='Retrain after N new labeled samples (default: 100)')
    parser.add_argument('--max-buffer', type=int, default=10000,
                        help='Max snapshots in rolling buffer (default: 10000)')
    parser.add_argument('--data-dir', type=str, default=str(DATA_DIR),
                        help=f'Data directory (default: {DATA_DIR})')
    parser.add_argument('--models-dir', type=str, default=str(MODELS_DIR),
                        help=f'Models directory (default: {MODELS_DIR})')
    parser.add_argument('--monitor-interval', type=int, default=60,
                        help='Background monitor check interval in seconds (default: 60)')
    args = parser.parse_args()

    data_dir = Path(args.data_dir)
    models_dir = Path(args.models_dir)

    _retrain_every = args.retrain_every
    _buffer = LiveDataBuffer(max_size=args.max_buffer)
    _retrainer = ModelRetrainer(data_dir, models_dir)

    # Load any existing labeled live data into the buffer
    prev_live = data_dir / 'live_labeled_data.csv'
    if prev_live.exists():
        try:
            prev_df = pd.read_csv(prev_live)
            loaded = 0
            for _, row in prev_df.iterrows():
                ts = str(row.get('datetime', datetime.now(timezone.utc).isoformat()))
                features = {col: row[col] for col in FEATURE_COLUMNS if col in row.index}
                labels = {col: row[col] for col in LABEL_COLUMNS if col in row.index}
                _buffer.add_snapshot(ts, features)
                # Manually set labels if available
                snap = _buffer._snapshots[-1]
                for lbl_key, lbl_val in labels.items():
                    if pd.notna(lbl_val):
                        snap['labels'][lbl_key] = float(lbl_val)
                loaded += 1
            log.info(f"Loaded {loaded} previous live samples into buffer")
        except Exception as e:
            log.warning(f"Could not load previous live data: {e}")

    # Start background monitor thread
    monitor = threading.Thread(
        target=retrain_monitor_loop,
        args=(args.monitor_interval,),
        daemon=True
    )
    monitor.start()

    # Handle graceful shutdown
    def shutdown(signum, frame):
        log.info("Shutting down live trainer...")
        # Save current buffer state
        try:
            labeled_df = _buffer.get_labeled_dataframe()
            if len(labeled_df) > 0:
                save_path = data_dir / 'live_labeled_data.csv'
                labeled_df.to_csv(save_path, index=False)
                log.info(f"Saved {len(labeled_df)} labeled samples to {save_path}")
        except Exception as e:
            log.error(f"Error saving on shutdown: {e}")
        sys.exit(0)

    signal.signal(signal.SIGINT, shutdown)
    signal.signal(signal.SIGTERM, shutdown)

    # Start HTTP server
    server = HTTPServer((args.host, args.port), LiveTrainerHandler)
    log.info("=" * 60)
    log.info("NEURAL EA LIVE TRAINER")
    log.info("=" * 60)
    log.info(f"Listening on {args.host}:{args.port}")
    log.info(f"Retrain threshold: every {_retrain_every} labeled samples")
    log.info(f"Buffer max size: {args.max_buffer}")
    log.info(f"Data dir: {data_dir}")
    log.info(f"Models dir: {models_dir}")
    log.info("")
    log.info("Endpoints:")
    log.info(f"  POST http://{args.host}:{args.port}/snapshot       — EA sends market data")
    log.info(f"  POST http://{args.host}:{args.port}/trade_outcome   — EA reports trade result")
    log.info(f"  POST http://{args.host}:{args.port}/label_direction — EA sends next close for labeling")
    log.info(f"  GET  http://{args.host}:{args.port}/status          — Check status")
    log.info(f"  GET  http://{args.host}:{args.port}/health          — Health check")
    log.info("")
    log.info("EA MQL5 integration example:")
    log.info('  WebRequest("POST", "http://localhost:8099/snapshot", "", 5000, json_body, result);')
    log.info("")
    log.info("Waiting for data from EA...")
    log.info("=" * 60)

    server.serve_forever()


if __name__ == '__main__':
    main()
