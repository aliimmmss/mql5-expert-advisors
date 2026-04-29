# MQL5 Expert Advisors — Knowledge Base

A comprehensive MQL5 knowledge base for building Expert Advisors on MetaTrader 5. Scraped and organized from [mql5.com](https://www.mql5.com) official resources.

## 📁 Repository Structure

```
mql5-expert-advisors/
├── book/              # MQL5 Book — 341 chapters (from official PDF)
├── neurobook/         # NeuroBook — Neural networks for trading (9 chapters)
├── docs/              # MQL5 Language Reference (8 organized sections)
├── articles/          # Articles index + 22 full EA-focused articles
├── code/              # Code library — EA examples, indicators, utilities
│   ├── eas/           # Expert Advisor implementations (.mq5)
│   ├── index.md       # Full code library index (43 entries)
│   └── ...
└── references/        # Quick reference guides (coming soon)
```

## 📚 Sources

| Source | Content | Files |
|--------|---------|-------|
| [MQL5 Book](https://www.mql5.com/en/book) | Complete MQL5 programming tutorial | 341 chapters |
| [NeuroBook](https://www.mql5.com/en/neurobook) | Neural networks & deep learning for trading | 9 chapters, 1.6MB |
| [MQL5 Docs](https://www.mql5.com/en/docs) | Language reference & API docs | 8 sections |
| [MQL5 Articles](https://www.mql5.com/en/articles) | 531 articles indexed, 22 downloaded | 23 files |
| [MQL5 Code](https://www.mql5.com/en/code) | Code library index + EA implementations | 6 files |

## 🚀 Quick Start

### Building Your First EA

1. **Learn the basics**: Start with `book/001-introduction-to-mql5-and-development-environment.md`
2. **Understand trading functions**: Read `docs/03-trading-functions.md`
3. **Study event handlers**: See `docs/02-event-handlers.md`
4. **Look at examples**: Browse `code/eas/` for working EA implementations
5. **Read articles**: Check `articles/index.md` for deep dives on specific strategies

### Key MQL5 Concepts

```mql5
// Every EA needs these event handlers:
int OnInit()          { /* initialization */    return INIT_SUCCEEDED; }
void OnDeinit(const int reason) { /* cleanup */ }
void OnTick()         { /* main trading logic */ }
void OnTrade()        { /* trade event */ }
void OnTimer()        { /* timer event */ }
```

### Essential Trading Functions

- `OrderSend(request, result)` — Send orders
- `PositionSelect(symbol)` — Select position
- `SymbolInfoDouble(symbol, SYMBOL_ASK)` — Get price
- `AccountInfoDouble(ACCOUNT_BALANCE)` — Account info
- `iMA()`, `iRSI()`, `iMACD()` — Technical indicators

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
