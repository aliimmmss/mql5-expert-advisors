# EMA RSI Gold EA

Expert Advisor for XAUUSDc based on EMA Crossover + RSI Confirmation strategy.

## Strategy Overview

**Based on analysis of 326 gold trading articles from MQL5.com**

### Entry Signals

**BUY:**
1. Fast EMA (21) crosses above Slow EMA (50)
2. RSI > 50 (bullish momentum)
3. RSI < 70 (not overbought)

**SELL:**
1. Fast EMA (21) crosses below Slow EMA (50)
2. RSI < 50 (bearish momentum)
3. RSI > 30 (not oversold)

### Exit Rules

- **Stop Loss**: 1.5 × ATR(14)
- **Take Profit**: 3.0 × ATR(14)
- **Risk-Reward**: 1:2
- **Opposite Signal**: Closes current position

## Recommended Settings

| Parameter | Value | Notes |
|-----------|-------|-------|
| Timeframe | H1 | Best for gold |
| Fast EMA | 21 | Standard |
| Slow EMA | 50 | Standard |
| RSI Period | 14 | Standard |
| Risk % | 1% | Conservative |

## Account Requirements

- **Minimum**: 5,000 USC ($50)
- **Recommended**: 10,000+ USC
- **Broker**: HFM Cent Account
- **Symbol**: XAUUSDc

## Installation

1. Copy `EMA_RSI_Gold_EA.mq5` to your MT5 `Experts` folder
2. Restart MetaTrader 5
3. Drag EA onto XAUUSDc H1 chart
4. Enable Auto Trading

## Backtesting

1. Open Strategy Tester (Ctrl+R)
2. Select `EMA_RSI_Gold_EA`
3. Symbol: XAUUSDc
4. Period: H1
5. Date range: 2022-01-01 to 2024-12-31
6. Model: Every tick based on real ticks
7. Deposit: 5000 (USC)

## Optimization

Test these parameter ranges:

- Fast EMA: 10, 15, 20, 21, 25
- Slow EMA: 40, 45, 50, 55, 60
- RSI Thresholds: 45/55, 50/50, 55/45
- ATR Multipliers: 1.0/2.0, 1.5/3.0, 2.0/4.0

## Risk Warnings

- ⚠️ Past performance does not guarantee future results
- ⚠️ Start with demo account first
- ⚠️ Never risk more than 2% per trade
- ⚠️ Monitor during high-impact news events
