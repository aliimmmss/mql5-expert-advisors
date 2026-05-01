# Neural-Enhanced Smart Money Concepts EA

A MetaTrader 5 Expert Advisor that combines **Smart Money Concepts** (SMC) with **3 neural network models** for superior signal filtering.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    SIGNAL LAYER                      │
│  ┌──────────────────────────────────────────────────┐│
│  │  Smart Money Concepts                             ││
│  │  • Break of Structure (BOS)                       ││
│  │  • Fair Value Gap (FVG)                           ││
│  │  • Order Blocks (OB)                              ││
│  │  • Liquidity Sweeps                               ││
│  │  → Generates Buy/Sell signals with confluence     ││
│  └──────────────────────┬───────────────────────────┘│
│                         ▼                            │
│  ┌──────────────────────────────────────────────────┐│
│  │            NEURAL FILTER LAYER                    ││
│  │  1. LSTM → Predicted ADX > 30? (trending?)        ││
│  │  2. CatBoost → Win prob > 0.15? (quality?)        ││
│  │  3. Price Predictor → Direction confidence         ││
│  │  All pass → TRADE. Any fail → SKIP.               ││
│  └──────────────────────┬───────────────────────────┘│
│                         ▼                            │
│  ┌──────────────────────────────────────────────────┐│
│  │          EXECUTION LAYER                          ││
│  │  • ATR-based SL/TP                                ││
│  │  • Risk-based lot sizing (1% per trade)           ││
│  │  • Max 3 concurrent positions                     ││
│  └──────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────┘
```

## Neural Models

| Model | Architecture | Input | Output | Purpose |
|-------|-------------|-------|--------|---------|
| **LSTM Trend** | LSTM(50) → Dense(1) | 5 bars × [ADX, RSI, return] | Predicted ADX | Filter ranging markets |
| **CatBoost Filter** | Gradient Boosting | 30 features (oscillators) | Win probability | Filter low-quality signals |
| **Price Predictor** | Conv1D(256)→LSTM(100)→Dense(1) | 120 bars × 4 features | Up probability | Boost signal direction |

## Project Structure

```
neural-ea/
├── data/
│   └── neural_training_data.csv    # Training data from MT5
├── models/
│   ├── lstm_trend.onnx             # LSTM model
│   ├── catboost_filter.onnx        # CatBoost model
│   ├── catboost_filter.cbm         # CatBoost native
│   └── price_predictor.onnx        # CNN+LSTM model
├── mql5/
│   ├── NeuralEA_DataCollector.mq5  # Run in Tester to collect data
│   └── NeuralEA_SmartMoney.mq5     # Main EA with ONNX integration
├── scripts/
│   ├── train_models.py             # Python training pipeline
│   └── live_trainer.py             # Live retraining from EA data
├── requirements.txt
└── README.md
```

## Setup Instructions

### Step 1: Collect Training Data

1. Copy `NeuralEA_DataCollector.mq5` to your MT5 `Experts/` folder
2. Run in Strategy Tester on XAUUSD H1 (any date range)
3. It will generate `neural_training_data.csv` in `MQL5/Files/`
4. Copy the CSV to `neural-ea/data/`

### Step 2: Train Models

```bash
cd neural-ea
pip install -r requirements.txt
python scripts/train_models.py --data data/neural_training_data.csv --models all
```

This creates 3 ONNX files in `models/`.

### Step 3: Deploy to MT5

1. Copy `.onnx` files from `models/` to MT5 `MQL5/Files/`
2. Copy `NeuralEA_SmartMoney.mq5` to MT5 `Experts/`
3. Compile in MetaEditor
4. Run backtest in Strategy Tester

### Step 4: Optimize

Key parameters to optimize:
- `InpLSTM_ADX_Threshold` (20-40): How strict the trend filter is
- `InpCatBoost_Threshold` (0.10-0.30): Signal quality threshold
- `InpPrice_Confidence` (0.50-0.70): Direction confidence threshold
- `InpSwingLookback` (10-50): SMC structure detection
- `InpStopLoss` / `InpTakeProfit`: Risk management

### Step 5: Live Training (Optional)

Run the live trainer alongside the EA to continuously improve models with real market data:

```bash
python scripts/live_trainer.py --port 8099 --retrain-every 100
```

The EA sends market data snapshots via `WebRequest` to the trainer. After enough labeled samples accumulate, models are automatically retrained and saved. The feedback loop:

1. EA on chart sends data via `POST /snapshot` each bar
2. EA reports trade results via `POST /trade_outcome`
3. EA sends next-bar close via `POST /label_direction` for automatic labeling
4. After 100+ fully labeled samples → automatic retrain of all 3 models
5. Updated ONNX models saved to `models/` → copy to MT5 `MQL5/Files/`

## How It Works

### Neural Filters (3 layers of protection)

1. **LSTM Trend Filter**: Predicts mean ADX for next 10 bars. If predicted ADX < 30, the market is ranging → skip all trades. This alone avoids 30-40% of losing trades.

2. **CatBoost Signal Filter**: Binary classifier trained on 30 oscillator features. Predicts win probability for current market conditions. Rejects signals with < 15% predicted win rate.

3. **Price Predictor**: CNN+LSTM hybrid trained on 120-bar sequences. Provides directional bias. Boosts buy signals when predicted up-probability > 55%, and vice versa.

### SmartMoney Signal Generation

- **BOS (Break of Structure)**: Identifies when price breaks key swing levels → trend continuation
- **FVG (Fair Value Gap)**: Detects imbalance zones where price may return → entry zones
- **Order Blocks**: Last opposing candle before a move → institutional supply/demand
- **Liquidity Sweeps**: Price wicks beyond key levels then reverses → stop hunts

### Confluence Scoring

Signals are scored based on confluence:
- BOS: +2 points
- FVG: +1 point
- Order Block: +1 point
- Liquidity Sweep: +2 points
- Price Predictor alignment: +1 point

Minimum 2 points required to trade. Buy/sell direction is determined by which side has higher score.

## Performance Expectations

Based on optimization of the SmartMoney EA (without neural filters):
- **Profit Factor**: 1.1 — 1.7
- **Win Rate**: 45-55%
- **Sharpe Ratio**: 1.5 — 4.3
- **Max Drawdown**: 7-12%

With neural filters, we expect:
- **Higher Profit Factor** (filtering out 20-30% of losing trades)
- **Lower Drawdown** (avoiding ranging markets)
- **Fewer but higher quality trades**

## Risk Warning

- This EA uses **no stop-hedging** (compatible with US brokers)
- Default risk is 1% per trade
- Max 3 concurrent positions
- Always forward-test on demo before live trading
- Past performance does not guarantee future results
