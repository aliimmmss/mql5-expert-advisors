"""
Neural EA — Model Training Pipeline
Trains 3 models for XAUUSDc neural-enhanced EA:
1. LSTM Trend Filter (predicts ADX → trending/ranging)
2. CatBoost Signal Filter (win probability)
3. Price Predictor (CNN+LSTM → next price direction)

All models exported to ONNX for MQL5 integration.
"""

import numpy as np
import pandas as pd
from pathlib import Path
import warnings
warnings.filterwarnings('ignore')

# Paths
BASE_DIR = Path(__file__).parent.parent
DATA_DIR = BASE_DIR / 'data'
MODELS_DIR = BASE_DIR / 'models'
MODELS_DIR.mkdir(exist_ok=True)


def load_and_prepare_data(csv_path: str) -> pd.DataFrame:
    """Load CSV from MQL5 data collector and prepare features."""
    df = pd.read_csv(csv_path)
    
    # Drop datetime for training (keep for reference)
    if 'datetime' in df.columns:
        df = df.drop('datetime', axis=1)
    
    # Drop rows with NaN
    df = df.dropna()
    
    print(f"Loaded {len(df)} samples, {len(df.columns)} columns")
    print(f"Label distribution:")
    print(f"  ADX future mean: {df['label_adx_future_10'].describe()}")
    print(f"  Price direction: {df['label_price_direction'].value_counts().to_dict()}")
    print(f"  Win label: {df['label_win'].value_counts().to_dict()}")
    
    return df


# ============================================================
# MODEL 1: LSTM Trend Filter (Predicts ADX)
# ============================================================

def train_lstm_trend(df: pd.DataFrame, timesteps: int = 5):
    """
    LSTM model that predicts mean ADX of next 10 bars.
    Used as trend filter: if predicted ADX > 30 → market is trending.
    
    Architecture: LSTM(50) → Dense(1)
    Input: 5 time steps × 3 features (ADX, RSI, candle_return)
    Output: predicted ADX value
    """
    import tensorflow as tf
    from tensorflow import keras
    from sklearn.preprocessing import StandardScaler
    
    print("\n" + "="*60)
    print("TRAINING MODEL 1: LSTM Trend Filter")
    print("="*60)
    
    # Features for LSTM
    feature_cols = ['adx', 'rsi', 'candle_return']
    target_col = 'label_adx_future_10'
    
    # Scale features
    scaler = StandardScaler()
    features_scaled = scaler.fit_transform(df[feature_cols].values)
    targets = df[target_col].values
    
    # Create sequences
    X, y = [], []
    for i in range(timesteps, len(features_scaled)):
        X.append(features_scaled[i-timesteps:i])
        y.append(targets[i])
    
    X = np.array(X)
    y = np.array(y)
    
    # Train/test split (80/20, no shuffle for time series)
    split = int(len(X) * 0.8)
    X_train, X_test = X[:split], X[split:]
    y_train, y_test = y[:split], y[split:]
    
    print(f"Training: {len(X_train)} samples, Test: {len(X_test)} samples")
    print(f"Input shape: {X_train.shape} (samples, timesteps, features)")
    
    # Build model
    model = keras.Sequential([
        keras.layers.LSTM(50, input_shape=(timesteps, len(feature_cols))),
        keras.layers.Dense(1)
    ])
    
    model.compile(optimizer='adam', loss='mse', metrics=['mae'])
    model.summary()
    
    # Train
    history = model.fit(
        X_train, y_train,
        validation_data=(X_test, y_test),
        epochs=50,
        batch_size=100,
        verbose=1
    )
    
    # Evaluate
    test_loss, test_mae = model.evaluate(X_test, y_test, verbose=0)
    print(f"\nTest MAE: {test_mae:.4f}")
    
    # Predictions analysis
    predictions = model.predict(X_test, verbose=0).flatten()
    print(f"Predicted ADX range: {predictions.min():.1f} — {predictions.max():.1f}")
    print(f"Actual ADX range: {y_test.min():.1f} — {y_test.max():.1f}")
    
    # How many would pass the ADX > 30 filter?
    trending_pct = (predictions > 30).mean() * 100
    print(f"Predicted trending (ADX > 30): {trending_pct:.1f}% of bars")
    
    # Convert to ONNX via tf.function tracing (works with all tf2onnx + Keras 3.x)
    import tf2onnx
    import onnx
    import tensorflow as tf
    import tempfile, shutil
    
    # Rebuild model and copy weights
    func_model = keras.Sequential([
        keras.layers.LSTM(50, input_shape=(timesteps, len(feature_cols))),
        keras.layers.Dense(1)
    ])
    func_model.compile(optimizer='adam', loss='mse')
    func_model.set_weights(model.get_weights())
    
    onnx_path = str(MODELS_DIR / 'lstm_trend.onnx')
    
    @tf.function(input_signature=[tf.TensorSpec((None, timesteps, len(feature_cols)), tf.float32)])
    def predict(x):
        return func_model(x)
    
    # Get concrete function and convert
    concrete_func = predict.get_concrete_function()
    onnx_model, _ = tf2onnx.convert.from_function(concrete_func, input_signature=concrete_func.inputs, opset=15)
    onnx.save_model(onnx_model, onnx_path)
    print(f"\n✅ LSTM Trend model saved to {onnx_path}")
    
    # Save scaler params for MQL5
    scaler_params = {
        'mean': scaler.mean_.tolist(),
        'scale': scaler.scale_.tolist()
    }
    
    return model, scaler, history


# ============================================================
# MODEL 2: CatBoost Signal Filter (Win Probability)
# ============================================================

def train_catboost_filter(df: pd.DataFrame):
    """
    CatBoost classifier that predicts win probability for a trade signal.
    Input: 26 features (oscillator values at signal time)
    Output: probability of winning trade
    
    Used to filter signals: only trade if win_prob > threshold
    """
    from catboost import CatBoostClassifier
    from sklearn.model_selection import train_test_split
    from sklearn.metrics import classification_report, roc_auc_score
    
    print("\n" + "="*60)
    print("TRAINING MODEL 2: CatBoost Signal Filter")
    print("="*60)
    
    # Features: all indicators + time
    feature_cols = [
        'adx', 'adx_plus', 'adx_minus',
        'rsi',
        'macd_main', 'macd_signal', 'macd_hist',
        'psar', 'atr',
        'sma50', 'sma200',
        'bb_upper', 'bb_middle', 'bb_lower',
        'mfi', 'cci', 'stoch_k', 'stoch_d', 'wpr',
        'obv', 'ad',
        'ha_open', 'ha_close', 'ha_high', 'ha_low',
        'candle_return', 'candle_body_pct',
        'close_vs_sma50', 'close_vs_sma200', 'close_vs_bb_mid'
    ]
    
    # Only use columns that exist
    feature_cols = [c for c in feature_cols if c in df.columns]
    target_col = 'label_win'
    
    X = df[feature_cols].values
    y = df[target_col].values
    
    # Train/test split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    print(f"Training: {len(X_train)} samples, Test: {len(X_test)} samples")
    print(f"Features: {len(feature_cols)}")
    print(f"Win rate: {y.mean()*100:.1f}%")
    
    # Calculate class weights (imbalanced data)
    win_rate = y_train.mean()
    class_weights = [1.0 / (1 - win_rate), 1.0 / win_rate]
    # Normalize to [10, 1] style
    class_weights = [w / min(class_weights) for w in class_weights]
    
    print(f"Class weights: {class_weights}")
    
    # Train CatBoost
    model = CatBoostClassifier(
        class_weights=class_weights,
        iterations=5000,
        learning_rate=0.02,
        depth=5,
        l2_leaf_reg=5,
        bagging_temperature=1,
        early_stopping_rounds=100,
        loss_function='Logloss',
        random_seed=42,
        verbose=500
    )
    
    model.fit(
        X_train, y_train,
        eval_set=(X_test, y_test),
        verbose=500
    )
    
    # Evaluate
    predictions = model.predict(X_test)
    proba = model.predict_proba(X_test)[:, 1]
    
    print(f"\nTest AUC: {roc_auc_score(y_test, proba):.4f}")
    print(f"\nClassification Report:")
    print(classification_report(y_test, predictions, target_names=['Loss', 'Win']))
    
    # Feature importance
    importance = model.get_feature_importance()
    feat_imp = sorted(zip(feature_cols, importance), key=lambda x: -x[1])
    print(f"\nTop 10 Features:")
    for name, imp in feat_imp[:10]:
        print(f"  {name}: {imp:.2f}")
    
    # Threshold analysis
    print(f"\nThreshold Analysis:")
    for threshold in [0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40]:
        mask = proba >= threshold
        if mask.sum() > 0:
            filtered_winrate = y_test[mask].mean()
            print(f"  Threshold {threshold:.2f}: {mask.sum()} trades, "
                  f"win rate {filtered_winrate*100:.1f}%")
    
    # Export to ONNX
    onnx_path = str(MODELS_DIR / 'catboost_filter.onnx')
    model.save_model(onnx_path, format="onnx",
                     export_parameters={
                         'onnx_domain': 'ai.onnx.ml',
                         'ai_onnx_ml': 2,
                         'onnx_opset_version': 12
                     })
    print(f"\n✅ CatBoost model saved to {onnx_path}")
    
    # Also save native model
    cbm_path = str(MODELS_DIR / 'catboost_filter.cbm')
    model.save_model(cbm_path)
    print(f"✅ CatBoost native model saved to {cbm_path}")
    
    return model


# ============================================================
# MODEL 3: Price Predictor (CNN + LSTM)
# ============================================================

def train_price_predictor(df: pd.DataFrame, timesteps: int = 120):
    """
    CNN+LSTM model that predicts next price direction.
    
    Architecture: Conv1D(256) → MaxPool → LSTM(100) → LSTM(100) → Dense(1)
    Input: 120 bars of normalized close prices
    Output: probability of price going up
    """
    import tensorflow as tf
    from tensorflow import keras
    from sklearn.preprocessing import MinMaxScaler
    
    print("\n" + "="*60)
    print("TRAINING MODEL 3: Price Predictor (CNN+LSTM)")
    print("="*60)
    
    # Use close price and key features
    feature_cols = ['close', 'volume_proxy'] if 'volume_proxy' in df.columns else ['close']
    
    # Create volume proxy from candle body if no volume
    if 'volume_proxy' not in df.columns:
        df['volume_proxy'] = df['candle_body_pct']
        feature_cols = ['close', 'candle_return', 'rsi', 'adx']
    
    # Scale features
    scaler = MinMaxScaler(feature_range=(0, 1))
    features_scaled = scaler.fit_transform(df[feature_cols].values)
    
    # Target: price direction (1 if next close > current close)
    targets = df['label_price_direction'].values
    
    # Create sequences
    X, y = [], []
    for i in range(timesteps, len(features_scaled) - 1):
        X.append(features_scaled[i-timesteps:i])
        y.append(targets[i])
    
    X = np.array(X)
    y = np.array(y)
    
    # Train/test split
    split = int(len(X) * 0.8)
    X_train, X_test = X[:split], X[split:]
    y_train, y_test = y[:split], y[split:]
    
    print(f"Training: {len(X_train)} samples, Test: {len(X_test)} samples")
    print(f"Input shape: {X_train.shape} (samples, timesteps, features)")
    print(f"Up/Down ratio: {y.mean()*100:.1f}% / {(1-y.mean())*100:.1f}%")
    
    # Build CNN+LSTM model
    model = keras.Sequential([
        keras.layers.Conv1D(256, kernel_size=2, strides=1, padding='same',
                           activation='relu', input_shape=(timesteps, len(feature_cols))),
        keras.layers.MaxPooling1D(pool_size=2),
        keras.layers.LSTM(100, return_sequences=True),
        keras.layers.Dropout(0.3),
        keras.layers.LSTM(100, return_sequences=False),
        keras.layers.Dropout(0.3),
        keras.layers.Dense(1, activation='sigmoid')
    ])
    
    model.compile(
        optimizer='adam',
        loss='binary_crossentropy',
        metrics=['accuracy']
    )
    model.summary()
    
    # Train with early stopping
    callbacks = [
        keras.callbacks.EarlyStopping(
            patience=20, restore_best_weights=True, monitor='val_loss'
        ),
        keras.callbacks.ReduceLROnPlateau(
            factor=0.5, patience=10, min_lr=1e-6
        )
    ]
    
    history = model.fit(
        X_train, y_train,
        validation_data=(X_test, y_test),
        epochs=300,
        batch_size=32,
        callbacks=callbacks,
        verbose=1
    )
    
    # Evaluate
    test_loss, test_acc = model.evaluate(X_test, y_test, verbose=0)
    print(f"\nTest Accuracy: {test_acc*100:.2f}%")
    
    # Prediction analysis
    predictions = model.predict(X_test, verbose=0).flatten()
    print(f"Prediction range: {predictions.min():.4f} — {predictions.max():.4f}")
    
    # Direction accuracy by confidence
    for threshold in [0.5, 0.55, 0.60, 0.65, 0.70]:
        mask = (predictions > threshold) | (predictions < (1-threshold))
        if mask.sum() > 0:
            correct = ((predictions[mask] > 0.5) == y_test[mask]).mean()
            print(f"  Confidence > {threshold}: {mask.sum()} samples, "
                  f"accuracy {correct*100:.1f}%")
    
    # Export to ONNX via tf.function tracing (works with all tf2onnx + Keras 3.x)
    import tf2onnx
    import onnx
    import tensorflow as tf
    
    onnx_path = str(MODELS_DIR / 'price_predictor.onnx')
    
    @tf.function(input_signature=[tf.TensorSpec((None, timesteps, len(feature_cols)), tf.float32)])
    def predict_price(x):
        return model(x)
    
    concrete_func = predict_price.get_concrete_function()
    onnx_model, _ = tf2onnx.convert.from_function(concrete_func, input_signature=concrete_func.inputs, opset=15)
    onnx.save_model(onnx_model, onnx_path)
    print(f"\n✅ Price Predictor model saved to {onnx_path}")
    
    return model, scaler, history


# ============================================================
# MAIN
# ============================================================

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='Train Neural EA models')
    parser.add_argument('--data', type=str, default=str(DATA_DIR / 'neural_training_data.csv'),
                       help='Path to training data CSV')
    parser.add_argument('--models', nargs='+', default=['all'],
                       choices=['all', 'lstm', 'catboost', 'price'],
                       help='Which models to train')
    args = parser.parse_args()
    
    # Load data
    df = load_and_prepare_data(args.data)
    
    models_to_train = args.models
    if 'all' in models_to_train:
        models_to_train = ['lstm', 'catboost', 'price']
    
    # Train models
    if 'lstm' in models_to_train:
        train_lstm_trend(df)
    
    if 'catboost' in models_to_train:
        train_catboost_filter(df)
    
    if 'price' in models_to_train:
        train_price_predictor(df)
    
    print("\n" + "="*60)
    print("ALL MODELS TRAINED SUCCESSFULLY!")
    print("="*60)
    print(f"\nONNX models saved to: {MODELS_DIR}")
    print("\nNext steps:")
    print("1. Copy .onnx files to MQL5/Files/ folder")
    print("2. Compile NeuralEA_SmartMoney.mq5 in MetaEditor")
    print("3. Run backtest in Strategy Tester")
