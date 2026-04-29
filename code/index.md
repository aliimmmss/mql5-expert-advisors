# MQL5 Code Library - Organized Index

> Scraped from [MQL5 Code Base](https://www.mql5.com/en/code) on 2026-04-29
> Code implementations are original MQL5 examples based on the library descriptions.

---

## Expert Advisors (MT5)

| # | ID | Name | Rating | Description |
|---|------|------|--------|-------------|
| 1 | 72316 | Frontend EA | 5.0/5.0 | UI cleanup + quick-trading layer for MT5 |
| 2 | 68764 | Easy Range Breakout EA | 5.0/4.3 | Range breakout strategy with time-based range calculation and visual chart rectangle |
| 3 | 71460 | Easy Range Breakout EA v2 | 5.0/4.3 | Updated range breakout EA with enhanced features |
| 4 | 71776 | XANDER Grid XAUUSD | 4.8/4.8 | Bidirectional grid EA for Gold. Includes Daily Profit Target and Max Drawdown protection |
| 5 | 71761 | BEC Lockin Dashboard Manager | 5.0/5.0 | One-click controls for breakeven, trailing logic, partial close, stop-loss management |
| 6 | 71728 | XPro Trade Panel | 5.0/5.0 | Full trade management panel for MT5/MT4 - entries, exits, SL, TP, pending orders |
| 7 | 71700 | RSI Grid EA Pro | 5.0/5.0 | RSI-based entries with adaptive grid recovery system and overlap order management |
| 8 | 71657 | BEC Trade Breakeven Trail Manager | 5.0/5.0 | Automated breakeven, trailing stop, and position control with on-chart dashboard |
| 9 | 71645 | Hon Matrix | 4.8/4.6 | Price Action + Volatility Analysis + Real-Time News Filtering algorithmic system |
| 10 | 71521 | Hon APS Advanced Pattern Scanner | 5.0/5.0 | Open-source EA with DOM and News Integration for pattern-based trading |
| 11 | 71591 | KSQ CommandCenter | 5.0/5.0 | Two-way bridge between MT5 and Google Sheets for remote trade management |
| 12 | 71583 | ASQ Command Desk | 5.0/4.0 | Professional order management panel for manual traders |

## Indicators (MT5)

| # | ID | Name | Rating | Description |
|---|------|------|--------|-------------|
| 1 | 72401 | Institutional Fourier Transform (DFT) | 5.0/5.0 | DSP engine applying DFT to market data for dominant cycle detection |
| 2 | 72345 | Super Trend | 4.8/4.8 | ATR-based dynamic trend line with buy/sell arrow signals |
| 3 | 72247 | Self-Aware Trend System | 5.0/5.0 | Adaptive SuperTrend + Trend Quality Index (TQI) dashboard |
| 4 | 72204 | Daily Risk Monitor Lite | 5.0/5.0 | Daily P/L, floating P/L, drawdown, and risk status display |
| 5 | 72110 | Machine Learning Supertrend | 4.8/4.6 | ML-inspired trending regime detector with backtest confidence |
| 6 | 72094 | XANDER Adaptive Cross | 3.7/3.3 | Two adaptive moving averages with crossover signals |
| 7 | 72068 | Market Clock Pro | 4.7/4.3 | Candle countdown HUD, trading sessions, live spread, anomaly detection |
| 8 | 72043 | Institutional GARCH(1,1) | 5.0/5.0 | Predictive volatility forecaster using Nobel-prize GARCH model |
| 9 | 71860 | Precision Sniper | 4.5/5.0 | Multi-confluence signal grader (A+, A, B, C) using EMA, RSI, MACD, ADX, VWAP |
| 10 | 71862 | Institutional StatArb Z-Score | 5.0/5.0 | Statistical Arbitrage pairs trading with log-spread Z-Score |
| 11 | 71816 | XANDER Pulse Candles | 4.8/4.3 | Momentum-state colored candles with four bias levels |
| 12 | 71806 | Half Line For Exit 123 | 3.7/3.3 | Arrow entry with middle-line exit strategy |
| 13 | 71793 | QuantumAlgo Trade Panel | 5.0/5.0 | Professional trading utility for scalping, swing, and position trading |
| 14 | 71723 | Mini Prop-Firm Dashboard | 5.0/5.0 | Risk management and performance monitoring for prop firm traders |
| 15 | 71701 | Fibonacci Structure Engine | 5.0/4.0 | Market Structure + Fibonacci Intelligence for Buy/Sell signals |
| 16 | 71641 | K-Means ML Liquidity Clusters | 5.0/5.0 | Unsupervised ML detecting institutional liquidity zones |
| 17 | 71611 | HTF Reversal Divergences | 5.0/5.0 | Multi-timeframe RSI divergence with Buy/Sell signals |
| 18 | 71584 | ASQ PropGuard | 5.0/5.0 | Real-time prop firm rule monitor with dark-themed overlay |
| 19 | 71504 | ASQ Candle Scanner | 5.0/5.0 | On-chart candle analysis with structure tags, sentiment, trend arrows |
| 20 | 71577 | Institutional Fractal Dimension | 5.0/5.0 | Fractal geometry regime detector classifying market states |

## Libraries (MT5)

| # | ID | Name | Rating | Description |
|---|------|------|--------|-------------|
| 1 | 72025 | ASQ Order Executor | 5.0/5.0 | Institutional order execution wrapper with retry logic, slippage monitoring |
| 2 | 71010 | Calculate Lot Percent | 4.3/5.0 | Function for lot calculation from deposit percentage |
| 3 | 71476 | ASQ Session Manager | 5.0/5.0 | Institutional-grade forex session detection and analysis |
| 4 | 71479 | ASQ News Filter | 5.0/5.0 | Economic calendar trading guard with MQL5 Calendar API |
| 5 | 69093 | ATR Based Stop Loss Manager | 5.0/5.0 | Multi-method stop-loss: Fixed, ATR, Swing, Percentage + trailing |

## Scripts (MT5)

| # | ID | Name | Rating | Description |
|---|------|------|--------|-------------|
| 1 | 72326 | Trade History Exporter | 5.0/4.5 | CSV export with MAE, MFE and Time-Based Excursions |
| 2 | 71197 | L1 Trend Filter Demo | 5.0/5.0 | L1 Trend Filter for float/double vectors on random walk data |

## Services (MT5)

| # | ID | Name | Rating | Description |
|---|------|------|--------|-------------|
| 1 | 71688 | Symbol Summary | 5.0/5.0 | Separate viewer with detailed trading symbol report |

---

## Files in this repository

### EA Implementations (`eas/`)
- `ASQ_Order_Executor.mq5` - Institutional order execution wrapper
- `Easy_Range_Breakout_EA.mq5` - Range breakout strategy
- `XANDER_Grid_XAUUSD.mq5` - Gold grid trading EA
- `RSI_Grid_EA_Pro.mq5` - RSI + grid recovery EA
- `BEC_Breakeven_Trail_Manager.mq5` - Position management EA
- `Hon_Matrix_EA.mq5` - Multi-factor algo system
- `QuantumAlgo_Trade_Panel.mq5` - Professional trade panel
- `Fibonacci_Structure_EA.mq5` - Fibonacci-based EA
- `ASQ_Command_Desk.mq5` - Manual trading panel
- `Prop_Firm_Dashboard.mq5` - Risk management dashboard
- ... and more

### Utilities (`utilities/`)
- `Calculate_Lot_Percent.mq5` - Lot size calculator
- `ASQ_Session_Manager.mq5` - Session detection library
- `ASQ_News_Filter.mq5` - Economic calendar filter
- `ATR_Stop_Loss_Manager.mq5` - Multi-method SL manager

### Indicators (`indicators/`)
- `Super_Trend.mq5` - ATR-based trend indicator
- `Market_Clock_Pro.mq5` - Session/clock HUD
- `Precision_Sniper.mq5` - Multi-confluence signal grader
