# Expert Advisors

Production-ready Expert Advisors for MetaTrader 5, built from analysis of 1,000+ MQL5 articles.

## Available EAs

### 0. NeuralEA_Live (v2.0) — Neural-Enhanced Trading

**File**: `../neural-ea/mql5/NeuralEA_Live.mq5`
**Best for**: XAUUSDc, H1 timeframe
**Approach**: Smart Money Concepts + 3 ML models via Python server

**Neural Models:**
- LSTM Trend Filter — Predicts ADX to filter ranging markets
- CatBoost Signal Filter — Win probability from 30 features
- Price Predictor — CNN+LSTM for directional bias

**Architecture:**
```
Layer 1: SMC Signal → BOS/FVG/OB/Liquidity detection
Layer 2: Neural Filter → LSTM + CatBoost + Price Predictor
Layer 3: Signal Combination → Weighted vote → BUY/SELL/HOLD
Layer 4: Trade Execution → ATR-based SL/TP
```

**Key Features:**
- HTTP WebRequest to Python server (port 5556)
- Automatic server reconnection
- Chart display with model outputs
- Trailing stop management
- Live model retraining support

**Setup:**
1. Start Python server: `python neural-ea/scripts/server.py`
2. Add `http://127.0.0.1:5556` to MT5 WebRequest allowed URLs
3. Compile and attach to chart

See `../neural-ea/README.md` for full documentation.

---

### 1. SmartMoney Concepts EA (v1.0)

**File**: `SmartMoney_Concepts_EA.mq5`
**Best for**: Any symbol, H1 timeframe
**Approach**: Non-lagging, price-action-based using institutional trading concepts

#### Strategies (8 total)

| Strategy | Type | Logic |
|----------|------|-------|
| BOS | Structure | Break of Structure — trend continuation |
| CHoCH | Structure | Change of Character — trend reversal |
| FVG | Zone | Fair Value Gap — price imbalance fills |
| IFVG | Zone | Inverse FVG — mitigated gap reversals |
| Order Blocks | Zone | Institutional supply/demand zones |
| Liquidity Sweep | Liquidity | BSL/SSL wick rejections |
| Opening Range | Session | Breakout after range formation |
| Midnight Range | Session | Breakout after midnight session |

#### Architecture

```
Layer 1: H4 MA200 → Trend Bias
Layer 2: H1 Swing Structure → HH/HL/LH/LL
Layer 3: M15 Momentum → Breakout Confirmation
Layer 4: Sentiment Engine → Strategy Selection
Layer 5: Trade Execution → Entry at Zones
```

#### Key Features

- Multi-timeframe sentiment analysis (H4/H1/M15)
- Automatic strategy switching based on market conditions
- Visual indicators on chart (swing labels, FVG/OB rectangles)
- Max 3 concurrent trades with sentiment alignment
- Configurable: toggle any strategy on/off

#### Recommended Settings

| Parameter | Value | Notes |
|-----------|-------|-------|
| Timeframe | H1 | Best for structure detection |
| Higher TF | H4 | Trend bias |
| Medium TF | H1 | Structure analysis |
| Lower TF | M15 | Entry timing |
| Lot Size | 0.01 | Start small |
| Stop Loss | 500 points | ~50 pips |
| Take Profit | 1500 points | ~150 pips (1:3 R:R) |

---

### 2. Gold Multi-Strategy EA (v2.0)

**File**: `Gold_MultiStrategy_EA.mq5`
**Best for**: XAUUSDc, H1 timeframe
**Approach**: Signal-voting system with 11 strategies + filters

#### Strategies (11 total)

**Original Strategies:**
1. EMA RSI Crossover
2. Trend + S/R Bounce
3. Price Breakout
4. RSI Extreme Reversal
5. MACD Trend Following
6. Bollinger Squeeze

**Advanced Strategies:**
7. Heikin Ashi Breakout
8. Donchian Channel Breakout
9. Golden/Death Cross
10. Advanced Divergence
11. Smart Money Concepts (Simplified)

#### Filters

- ADX Trend Filter (strength > 25)
- Multi-Timeframe Confirmation (H4 + M15)
- Volume Filter (above average)

#### Exit Management

- Partial Close (50% at 1:1 R:R)
- Trailing Stop (after 2:1 R:R)
- Breakeven Move (after 1:1 R:R)

#### Recommended Settings

| Parameter | Value | Notes |
|-----------|-------|-------|
| Timeframe | H1 | Best for gold |
| Symbol | XAUUSDc | HFM Cent Account |
| Deposit | 5,000+ USC | Minimum $50 |
| Min Buy Signals | 3 | Out of 11 strategies |
| Min Sell Signals | 3 | Out of 11 strategies |

---

## Installation

1. Copy `.mq5` file to: `MQL5/Experts/`
2. Restart MetaTrader 5
3. Open Navigator (Ctrl+N)
4. Expand Expert Advisors
5. Drag EA onto chart
6. Enable Auto Trading (toolbar button)
7. Allow live trading in EA properties

## Backtesting

1. Open Strategy Tester (Ctrl+R)
2. Select EA from dropdown
3. Choose symbol and timeframe
4. Set date range (at least 1 year)
5. Model: "Every tick based on real ticks"
6. Click Start

## Risk Warnings

- ⚠️ Past performance does not guarantee future results
- ⚠️ Always start with a demo account
- ⚠️ Never risk more than 2% per trade
- ⚠️ Monitor during high-impact news events
- ⚠️ These EAs are for educational purposes

## Development Notes

Built from deep analysis of:
- 326 gold trading articles
- 109 non-lagging strategy articles
- 531 total indexed articles
- MQL5 Book (341 chapters)
- NeuroBook (9 chapters)

Key insights incorporated:
- Smart Money Concepts (institutional trading logic)
- Market structure analysis (BOS/CHoCH)
- Fair Value Gaps and Order Blocks
- Multi-timeframe confirmation
- Sentiment-based strategy selection
- Neural network filtering (LSTM, CatBoost, CNN+LSTM)
