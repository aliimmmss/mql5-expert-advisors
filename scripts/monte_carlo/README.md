# Monte Carlo Risk Assessment for XAUUSDc EAs

## Overview

This toolkit uses **Monte Carlo simulation** to stress-test your EA's trade history. It answers one critical question:

> *"If the same trades happened in a different order, how often would my account blow up?"*

Based on [MQL5 Article #22291](https://www.mql5.com/en/articles/22291) by Duy Van Nguy.

## Files

| File | Description |
|------|-------------|
| `MonteCarlo_RiskAssessor.mq5` | The main MT5 script — place in `MQL5\Scripts\` |
| `trades.csv` | Sample trade data — place in `MQL5\Files\` |
| `prepare_trades.py` | Python helper to convert Strategy Tester reports to trades.csv |

## Quick Start

### Step 1: Export Your Backtest Results

In MetaTrader 5 Strategy Tester:
1. Run your EA backtest (e.g., Gold_MultiStrategy_EA on XAUUSDc)
2. Go to **Results** tab
3. Right-click on the trade list → **Save as Report**
4. Save the HTML file

### Step 2: Convert to trades.csv

**Option A: Use the Python script (recommended)**
```bash
python3 prepare_trades.py "path/to/your_report.html" trades.csv
```

**Option B: Manual conversion**
1. Open the HTML report in a browser
2. Copy the Profit column values
3. Paste into a text file, one value per line
4. Add header "Profit" on first line
5. Save as `trades.csv`

**Option C: From Strategy Tester directly**
1. In Results tab, right-click → **Export to XML/CSV**
2. Open the exported file
3. Keep only the Profit column
4. Save as `trades.csv`

### Step 3: Run the Monte Carlo Script

1. Copy `trades.csv` to: `MQL5\Files\` (File → Open Data Folder → MQL5 → Files)
2. Copy `MonteCarlo_RiskAssessor.mq5` to: `MQL5\Scripts\`
3. In MT5 Navigator panel, find **Scripts** → `MonteCarlo_RiskAssessor`
4. Drag it onto any chart (symbol/timeframe doesn't matter)
5. Configure settings (defaults are fine for first run)
6. Click **OK**

### Step 4: Interpret Results

The script produces:

#### Fan Chart
- **Median line (blue)** — typical outcome
- **Green band (25th-75th percentile)** — interquartile range
- **Wide band (5th-95th percentile)** — full outcome range
- **Red line** — initial balance reference

#### Key Metrics

| Metric | What It Means | Danger Zone |
|--------|---------------|-------------|
| Median Max Drawdown | Typical worst decline | > 15% |
| Stress Drawdown (95th%) | Worst 5% of scenarios | > 25% |
| Value at Risk (5%) | Dollar amount at risk | > 10% of balance |
| Probability of Ruin | % of simulations exceeding ruin threshold | > 20% |

## Recommended Settings for XAUUSDc

Since we trade on a **HFM cent account** ($50/month = 5,000 USC):

```
InpInitialBalance = 5000    // Your actual balance in USC
InpRuinThreshold  = 0.20    // 20% drawdown = 1,000 USC loss
InpSimulations    = 1000    // Default is fine
InpSlippageEnabled = true   // Enable for realistic testing
InpCommission      = 2      // HFM typical commission
InpSlippageMax     = 3      // Conservative slippage estimate
```

## Understanding the Output

### Good Results (Strategy is Robust)
- Narrow fan chart (outcomes converge)
- Median drawdown < 10%
- Stress drawdown < 20%
- Probability of ruin < 10%

### Warning Signs (Strategy is Fragile)
- Wide fan chart (outcomes diverge)
- Median drawdown > 15%
- Stress drawdown > 25%
- Probability of ruin > 20%

### Critical (Do Not Trade Live)
- Very wide fan (highly path-dependent)
- Stress drawdown > 35%
- Probability of ruin > 30%

## Running for Each EA

Test each of your EAs separately:

1. **EMA_RSI** — Run backtest → export → MC analysis
2. **Trend_SR** — Run backtest → export → MC analysis
3. **Breakout** — Run backtest → export → MC analysis
4. **RSI_Extreme** — Run backtest → export → MC analysis
5. **MACD_Trend** — Run backtest → export → MC analysis
6. **Bollinger_Squeeze** — Run backtest → export → MC analysis
7. **Gold_MultiStrategy** — Run backtest → export → MC analysis

Compare the results to identify which strategies are most robust.

## Tips

- **Minimum 200 trades** for reliable results
- **Test with slippage enabled** for realistic live conditions
- **Run multiple times** — results vary slightly due to randomness
- **Compare backtest drawdown to MC stress drawdown** — if MC is 2× higher, the strategy is sequence-sensitive

## CSV Export

The script exports `mc_results.csv` with:
- Percentile curves per trade step (P5, P25, P50, P75, P95)
- Summary metrics

You can load this in Python for further analysis:
```python
import pandas as pd
df = pd.read_csv('mc_results.csv', skiprows=3)  # Skip metadata header
```
