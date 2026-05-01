# MQL5 Expert Advisors — Knowledge Base & Trading Systems

A comprehensive MQL5 knowledge base for building Expert Advisors on MetaTrader 5, with **production-ready EAs** based on deep analysis of 1,000+ MQL5 articles.

## 📁 Repository Structure

```
mql5-expert-advisors/
├── experts/           # Production Expert Advisors
│   ├── Gold_MultiStrategy_EA.mq5      # 11-strategy gold EA (v2.0)
│   ├── SmartMoney_Concepts_EA.mq5     # SMC-based EA (v1.0)
│   └── README.md      # EA documentation
├── neural-ea/         # Neural-Enhanced Trading System
│   ├── mql5/          # MQL5 EAs (Live, SmartMoney, DataCollector)
│   ├── scripts/       # Python server, training, live trainer
│   ├── models/        # Trained ML models (LSTM, CatBoost, Price Predictor)
│   ├── data/          # Training data from MT5
│   └── README.md      # Neural EA documentation
├── book/              # MQL5 Book — 341 chapters
├── neurobook/         # Neural networks for trading (9 chapters)
├── docs/              # MQL5 Language Reference (8 sections)
├── articles/          # Articles index + 22 full EA-focused articles
├── code/              # Code library — EA examples, indicators
├── data/              # Scraped article data (190MB)
└── tools/             # Scraping utilities
```

## 🤖 Expert Advisors

### Neural-Enhanced Trading System (NEW!)

**2 EAs** — NeuralEA_Live (Python server) + NeuralEA_SmartMoney (ONNX inference)

| EA | Architecture | Inference | Best For |
|----|-------------|-----------|----------|
| **NeuralEA_Live** | SMC + 3 ML models via HTTP | Python server (port 5556) | Full ML pipeline, live retraining |
| **NeuralEA_SmartMoney** | SMC + 3 ONNX models | In-MT5 ONNX Runtime | Standalone, no external deps |

**Neural Models:**
- **LSTM Trend Filter** — Predicts ADX to filter ranging markets
- **CatBoost Signal Filter** — Win probability from 30 oscillator features
- **Price Predictor** — CNN+LSTM hybrid for directional bias

**Architecture:**
```
SMC Signal (BOS/FVG/OB/Liquidity) → Neural Filter (3 models) → Trade Execution
```

See `neural-ea/README.md` for full documentation.

### SmartMoney Concepts EA (v1.0)
**Strategies**: BOS + CHoCH + FVG + Order Blocks + Liquidity Sweeps + Session Breakouts

Non-lagging, price-action-based EA using institutional trading concepts:
- **Market Structure**: Break of Structure (BOS) and Change of Character (CHoCH)
- **Fair Value Gaps**: FVG detection with mitigation/inversion (IFVG)
- **Order Blocks**: Institutional supply/demand zones
- **Liquidity Sweeps**: Buy/Sell Side Liquidity detection
- **Session Breakouts**: Opening Range + Midnight Range
- **Sentiment Engine**: Multi-timeframe strategy switching (H4/H1/M15)

### Gold Multi-Strategy EA (v2.0)
**Strategies**: 11 strategies with ADX/Multi-TF filters

Signal-voting system where multiple strategies must agree:
- EMA RSI Crossover, Trend + S/R Bounce, Price Breakout
- RSI Extreme Reversal, MACD Trend, Bollinger Squeeze
- Heikin Ashi, Donchian, Golden Cross, Divergence, SMC

## 📚 Knowledge Base Sources

| Source | Content | Files |
|--------|---------|-------|
| [MQL5 Book](https://www.mql5.com/en/book) | Complete MQL5 programming tutorial | 341 chapters |
| [NeuroBook](https://www.mql5.com/en/neurobook) | Neural networks & deep learning for trading | 9 chapters, 1.6MB |
| [MQL5 Docs](https://www.mql5.com/en/docs) | Language reference & API docs | 8 sections |
| [MQL5 Articles](https://www.mql5.com/en/articles) | 531 articles indexed, 22 downloaded | 23 files |
| [MQL5 Code](https://www.mql5.com/en/code) | Code library index + EA implementations | 6 files |

## 🚀 Quick Start

### Neural EA Setup (Recommended)

**Option A: Python Server (NeuralEA_Live)**
```bash
# 1. Train models
cd neural-ea
pip install -r requirements.txt
python scripts/train_models.py --data data/neural_training_data.csv --models all

# 2. Start prediction server (HTTP on 5556, TCP on 5555)
python scripts/server.py

# 3. In MT5: Add http://127.0.0.1:5556 to WebRequest allowed URLs
# 4. Compile NeuralEA_Live.mq5 in MetaEditor
# 5. Attach to chart (XAUUSDc H1 recommended)
```

**Option B: ONNX Inference (NeuralEA_SmartMoney)**
```bash
# 1. Train models (same as above)
# 2. Copy .onnx files to MT5 MQL5/Files/
# 3. Compile NeuralEA_SmartMoney.mq5 in MetaEditor
# 4. Attach to chart — no external server needed
```

### Traditional EAs

1. Copy `.mq5` file to your MT5 `Experts` folder
2. Restart MetaTrader 5
3. Drag EA onto chart (XAUUSDc H1 for Gold EA, any symbol for SMC EA)
4. Enable Auto Trading
5. Start with demo account first!

## 📊 Forward Testing Status

Currently running forward tests:
- **NeuralEA_Live** — Connected to Python server via WebRequest
- **SmartMoney_Concepts_EA** — Running on separate broker

## Key MQL5 Concepts

```mql5
// Every EA needs these event handlers:
int OnInit()          { /* initialization */    return INIT_SUCCEEDED; }
void OnDeinit(const int reason) { /* cleanup */ }
void OnTick()         { /* main trading logic */ }
void OnTrade()        { /* trade event */ }
void OnTimer()        { /* timer event */ }
```

## Essential Trading Functions

- `OrderSend(request, result)` — Send orders
- `PositionSelect(symbol)` — Select position
- `SymbolInfoDouble(symbol, SYMBOL_ASK)` — Get price
- `AccountInfoDouble(ACCOUNT_BALANCE)` — Account info
- `iMA()`, `iRSI()`, `iMACD()` — Technical indicators
- `WebRequest()` — HTTP communication with external servers

## 🧠 NeuroBook Highlights

The `neurobook/` directory contains a complete guide to neural networks in MQL5:

- **Perceptrons & MLPs** — Building blocks
- **CNNs** — Convolutional networks for pattern recognition
- **RNNs** — Recurrent networks for time series
- **Transformers** — Self-attention and GPT architecture
- **OpenCL** — GPU acceleration in MT5
- **Python integration** — Using TensorFlow/PyTorch with MQL5

## 📖 Book Contents

The MQL5 Book (`book/`) covers:

1. **Part 1**: Introduction & development environment
2. **Part 2**: Programming fundamentals (types, arrays, functions, preprocessor)
3. **Part 3**: OOP (structures, classes, interfaces, templates)
4. **Part 4**: Common APIs (strings, math, files, matrices)
5. **Part 5**: Application programs (scripts, indicators, charts, objects)
6. **Part 6**: Trading automation (symbols, market book, Expert Advisors, tester)
7. **Part 7**: Advanced tools (resources, SQLite, Python, OpenCL)

## 📰 Articles Highlights

22 full articles downloaded covering:

- Self-optimizing EAs with MQL5 + Python
- Multi-currency Expert Advisor development
- LLM integration into EAs (fine-tuning, LoRA)
- Strategy implementations (breakout, RSI, Parabolic SAR, Bollinger)
- Telegram integration for trade signals
- Auto-optimization techniques

See `articles/index.md` for the complete 531-article index organized by category.

## ⚠️ Notes

- Content was scraped from mql5.com on 2026-04-29
- Some pages returned HTTP 403 (rate limiting) — content supplemented from official PDFs
- Code examples are original implementations based on library descriptions
- The MQL5 Book was extracted from the official 2047-page PDF

## 🔗 Official Resources

- [MQL5 Documentation](https://www.mql5.com/en/docs)
- [MQL5 Book](https://www.mql5.com/en/book)
- [MQL5 Code Library](https://www.mql5.com/en/code)
- [MQL5 Articles](https://www.mql5.com/en/articles)
- [MQL5 Forum](https://www.mql5.com/en/forum)

---

**License**: Content is from mql5.com — refer to their terms of use.
