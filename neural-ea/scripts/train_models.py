#!/usr/bin/env python3
"""
Neural EA - Model Training Script
Trains 3 ML models for trading signal generation:
  1. LSTM Trend Filter  (Keras) - predicts ADX trend strength
  2. CatBoost Signal Filter - predicts win probability
  3. Price Predictor (CNN+LSTM) - predicts price direction

Usage:
  python train_models.py --data data.csv --format native
  python train_models.py --data data.csv --format onnx
  python train_models.py --data data.csv --format both  (default)
"""

import argparse
import json
import os
import sys
import time
import logging
from pathlib import Path

import numpy as np
import pandas as pd

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
log = logging.getLogger("train_models")

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
BASE_DIR = Path(__file__).resolve().parent.parent
MODELS_DIR = BASE_DIR / "models"
MODELS_DIR.mkdir(exist_ok=True)


# ---------------------------------------------------------------------------
# Model 1: LSTM Trend Filter (Keras)
# ---------------------------------------------------------------------------
def build_lstm_trend_model(seq_len: int = 20, n_features: int = 5):
    """LSTM -> Dense(1) that predicts ADX / trend strength."""
    try:
        from tensorflow.keras.models import Sequential
        from tensorflow.keras.layers import LSTM, Dense, Dropout
    except ImportError:
        from keras.models import Sequential
        from keras.layers import LSTM, Dense, Dropout

    model = Sequential([
        LSTM(50, input_shape=(seq_len, n_features), return_sequences=False),
        Dropout(0.2),
        Dense(1, activation="linear"),
    ])
    model.compile(optimizer="adam", loss="mse", metrics=["mae"])
    return model


def train_lstm_trend(X_train, y_train, X_val, y_val, epochs=50, batch_size=32):
    log.info("Training LSTM Trend Filter ...")
    model = build_lstm_trend_model(seq_len=X_train.shape[1], n_features=X_train.shape[2])
    model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=epochs,
        batch_size=batch_size,
        verbose=1,
    )
    return model


# ---------------------------------------------------------------------------
# Model 2: CatBoost Signal Filter
# ---------------------------------------------------------------------------
def train_catboost_signal(X_train, y_train, X_val, y_val, iterations=500):
    log.info("Training CatBoost Signal Filter ...")
    from catboost import CatBoostClassifier

    model = CatBoostClassifier(
        iterations=iterations,
        depth=6,
        learning_rate=0.05,
        loss_function="Logloss",
        eval_metric="AUC",
        verbose=50,
    )
    model.fit(X_train, y_train, eval_set=(X_val, y_val), early_stopping_rounds=50)
    return model


# ---------------------------------------------------------------------------
# Model 3: Price Predictor (CNN + LSTM)
# ---------------------------------------------------------------------------
def build_price_predictor(seq_len: int = 60, n_features: int = 5):
    """Conv1D -> MaxPool -> LSTM -> LSTM -> Dense(1) price direction predictor."""
    try:
        from tensorflow.keras.models import Sequential
        from tensorflow.keras.layers import (
            Conv1D, MaxPooling1D, LSTM, Dense, Dropout, Flatten,
        )
    except ImportError:
        from keras.models import Sequential
        from keras.layers import (
            Conv1D, MaxPooling1D, LSTM, Dense, Dropout, Flatten,
        )

    model = Sequential([
        Conv1D(256, kernel_size=3, activation="relu", input_shape=(seq_len, n_features)),
        MaxPooling1D(pool_size=2),
        Dropout(0.2),
        LSTM(100, return_sequences=True),
        Dropout(0.2),
        LSTM(100, return_sequences=False),
        Dropout(0.2),
        Dense(1, activation="sigmoid"),
    ])
    model.compile(optimizer="adam", loss="binary_crossentropy", metrics=["accuracy"])
    return model


def train_price_predictor(X_train, y_train, X_val, y_val, epochs=50, batch_size=32):
    log.info("Training Price Predictor (CNN+LSTM) ...")
    model = build_price_predictor(seq_len=X_train.shape[1], n_features=X_train.shape[2])
    model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=epochs,
        batch_size=batch_size,
        verbose=1,
    )
    return model


# ---------------------------------------------------------------------------
# Incremental retrain helpers (used by server)
# ---------------------------------------------------------------------------
def incremental_retrain_lstm(model, X_new, y_new, epochs=5, batch_size=16):
    """Fine-tune an existing LSTM model on new data."""
    model.fit(X_new, y_new, epochs=epochs, batch_size=batch_size, verbose=0)
    return model


def incremental_retrain_catboost(model, X_new, y_new, iterations=50):
    """Fine-tune an existing CatBoost model on new data."""
    model.fit(X_new, y_new, init_model=model, verbose=0)
    return model


def incremental_retrain_price(model, X_new, y_new, epochs=5, batch_size=16):
    """Fine-tune an existing price predictor on new data."""
    model.fit(X_new, y_new, epochs=epochs, batch_size=batch_size, verbose=0)
    return model


# ---------------------------------------------------------------------------
# Save helpers
# ---------------------------------------------------------------------------
def _save_native_keras(model, name: str):
    """Save a Keras model in native .keras format."""
    path = MODELS_DIR / f"{name}.keras"
    model.save(str(path))
    log.info(f"  Saved native Keras model → {path}")
    return path


def _save_native_catboost(model, name: str):
    """Save a CatBoost model in native .cbm format."""
    path = MODELS_DIR / f"{name}.cbm"
    model.save_model(str(path), format="cbm")
    log.info(f"  Saved native CatBoost model → {path}")
    return path


def _save_onnx_keras(model, name: str, opset: int = 13):
    """Convert Keras model to ONNX and save."""
    try:
        import tf2onnx
        import tensorflow as tf

        spec = (tf.TensorSpec(model.input_shape, tf.float32, name="input"),)
        onnx_model, _ = tf2onnx.convert.from_keras(model, input_signature=spec, opset=opset)
        path = MODELS_DIR / f"{name}.onnx"
        with open(path, "wb") as f:
            f.write(onnx_model.SerializeToString())
        log.info(f"  Saved ONNX model → {path}")
        return path
    except ImportError:
        log.warning("  tf2onnx not installed – skipping ONNX export")
        return None


def _save_onnx_catboost(model, name: str):
    """Convert CatBoost model to ONNX and save."""
    try:
        from catboost import CatBoostClassifier, CatBoostRegressor
        # catboost has built-in onnx export
        path = MODELS_DIR / f"{name}.onnx"
        model.save_model(str(path), format="onnx")
        log.info(f"  Saved ONNX model → {path}")
        return path
    except Exception as e:
        log.warning(f"  CatBoost ONNX export failed: {e}")
        return None


def save_model(model, name: str, model_type: str, save_format: str = "both"):
    """Save a model in native, onnx, or both formats.

    model_type: 'keras' | 'catboost'
    save_format: 'native' | 'onnx' | 'both'
    """
    if save_format in ("native", "both"):
        if model_type == "keras":
            _save_native_keras(model, name)
        elif model_type == "catboost":
            _save_native_catboost(model, name)

    if save_format in ("onnx", "both"):
        if model_type == "keras":
            _save_onnx_keras(model, name)
        elif model_type == "catboost":
            _save_onnx_catboost(model, name)


# ---------------------------------------------------------------------------
# Synthetic data generator (for testing without real data)
# ---------------------------------------------------------------------------
def generate_synthetic_data(n_samples: int = 2000, seq_len_lstm: int = 20,
                            seq_len_price: int = 60, n_features: int = 5):
    """Generate synthetic OHLCV-derived features for testing."""
    log.info(f"Generating {n_samples} synthetic samples ...")
    np.random.seed(42)

    # Flat feature matrix for CatBoost
    X_flat = np.random.randn(n_samples, n_features + 4).astype(np.float32)
    y_catboost = (X_flat[:, 0] + X_flat[:, 1] * 0.5 + np.random.randn(n_samples) * 0.3 > 0).astype(int)

    # LSTM sequences
    X_lstm = np.random.randn(n_samples, seq_len_lstm, n_features).astype(np.float32)
    y_lstm = np.sin(np.linspace(0, 20, n_samples)) + np.random.randn(n_samples) * 0.1
    y_lstm = y_lstm.astype(np.float32)

    # Price sequences
    X_price = np.random.randn(n_samples, seq_len_price, n_features).astype(np.float32)
    y_price = (np.random.randn(n_samples) > 0).astype(int)

    # Train/val split
    split = int(0.8 * n_samples)
    return {
        "lstm": (X_lstm[:split], y_lstm[:split], X_lstm[split:], y_lstm[split:]),
        "catboost": (X_flat[:split], y_catboost[:split], X_flat[split:], y_catboost[split:]),
        "price": (X_price[:split], y_price[:split], X_price[split:], y_price[split:]),
    }


def load_csv_data(path: str, seq_len_lstm: int = 20, seq_len_price: int = 60,
                  n_features: int = 5):
    """Load data from CSV. Expects OHLCV + indicator columns."""
    df = pd.read_csv(path)
    log.info(f"Loaded {len(df)} rows from {path}")

    # Derive features (adjust column names to your dataset)
    feature_cols = [c for c in df.columns if c not in ("time", "target_adx", "target_win", "target_direction")]
    X = df[feature_cols].values.astype(np.float32)

    # Targets
    y_adx = df["target_adx"].values.astype(np.float32) if "target_adx" in df.columns else np.zeros(len(df))
    y_win = df["target_win"].values.astype(int) if "target_win" in df.columns else np.zeros(len(df), dtype=int)
    y_dir = df["target_direction"].values.astype(int) if "target_direction" in df.columns else np.zeros(len(df), dtype=int)

    # Build sequences
    n_samples = len(df) - seq_len_price
    X_lstm = np.array([X[i:i + seq_len_lstm] for i in range(n_samples)])
    X_price = np.array([X[i:i + seq_len_price] for i in range(n_samples)])
    X_flat = X[seq_len_price:]
    y_adx = y_adx[seq_len_price:]
    y_win = y_win[seq_len_price:]
    y_dir = y_dir[seq_len_price:]

    split = int(0.8 * n_samples)
    return {
        "lstm": (X_lstm[:split], y_adx[:split], X_lstm[split:], y_adx[split:]),
        "catboost": (X_flat[:split], y_win[:split], X_flat[split:], y_win[split:]),
        "price": (X_price[:split], y_dir[:split], X_price[split:], y_dir[split:]),
    }


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="Train Neural EA models")
    parser.add_argument("--data", type=str, default=None, help="Path to CSV data file (omit for synthetic)")
    parser.add_argument("--format", type=str, default="both", choices=["native", "onnx", "both"],
                        help="Save format: native (.keras/.cbm), onnx, or both (default)")
    parser.add_argument("--epochs", type=int, default=50, help="Training epochs for Keras models")
    parser.add_argument("--catboost-iters", type=int, default=500, help="CatBoost iterations")
    parser.add_argument("--seq-len-lstm", type=int, default=20, help="LSTM sequence length")
    parser.add_argument("--seq-len-price", type=int, default=60, help="Price predictor sequence length")
    parser.add_argument("--n-features", type=int, default=5, help="Number of input features")
    args = parser.parse_args()

    t0 = time.time()

    # Load data
    if args.data and os.path.exists(args.data):
        data = load_csv_data(args.data, args.seq_len_lstm, args.seq_len_price, args.n_features)
    else:
        if args.data:
            log.warning(f"Data file '{args.data}' not found – using synthetic data")
        data = generate_synthetic_data(seq_len_lstm=args.seq_len_lstm,
                                       seq_len_price=args.seq_len_price,
                                       n_features=args.n_features)

    # Train models
    lstm_model = train_lstm_trend(*data["lstm"], epochs=args.epochs)
    catboost_model = train_catboost_signal(*data["catboost"], iterations=args.catboost_iters)
    price_model = train_price_predictor(*data["price"], epochs=args.epochs)

    # Save models
    log.info(f"Saving models in '{args.format}' format ...")
    save_model(lstm_model, "lstm_trend", "keras", args.format)
    save_model(catboost_model, "catboost_signal", "catboost", args.format)
    save_model(price_model, "price_predictor", "keras", args.format)

    # Save config for the server
    config = {
        "seq_len_lstm": args.seq_len_lstm,
        "seq_len_price": args.seq_len_price,
        "n_features": args.n_features,
        "feature_names": [f"feat_{i}" for i in range(args.n_features + 4)],
        "model_files": {
            "lstm_trend": "lstm_trend.keras",
            "catboost_signal": "catboost_signal.cbm",
            "price_predictor": "price_predictor.keras",
        },
    }
    config_path = MODELS_DIR / "model_config.json"
    with open(config_path, "w") as f:
        json.dump(config, f, indent=2)
    log.info(f"Saved model config → {config_path}")

    elapsed = time.time() - t0
    log.info(f"Training complete in {elapsed:.1f}s")


if __name__ == "__main__":
    main()
