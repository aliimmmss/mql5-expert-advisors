# MQL5 Language Documentation

> Compiled from https://www.mql5.com/en/docs

This directory contains organized MQL5 documentation focused on building Expert Advisors.

## Documentation Files

### 1. [Language Basics](01-language-basics.md)
Core MQL5 language features:
- Syntax and program structure
- Data types (integer, float, string, struct, class, enum)
- Operators (arithmetic, logical, bitwise)
- Control flow (if/else, for, while, switch)
- Functions and parameters
- Variables (local, global, input, static)
- Preprocessor directives
- Object-oriented programming (classes, inheritance, polymorphism)
- Namespaces
- Program types (EA, indicator, script, service)

### 2. [Event Handlers](02-event-handlers.md)
MQL5 program entry points and event processing:
- `OnInit()` - initialization
- `OnDeinit()` - cleanup
- `OnTick()` - new price quote (EAs)
- `OnTrade()` - trade events
- `OnTradeTransaction()` - detailed trade transactions
- `OnChartEvent()` - chart interactions
- `OnTimer()` - timer events
- `OnCalculate()` - indicator calculation
- `OnStart()` - script execution
- `OnTester()` - strategy tester

### 3. [Trading Functions](03-trading-functions.md)
Trade execution and order management:
- `OrderSend()` / `OrderSendAsync()` - execute trades
- `OrderCheck()` - validate orders
- Position management (PositionsTotal, PositionSelect, etc.)
- Order management (OrdersTotal, OrderGetTicket, etc.)
- History (HistorySelect, HistoryOrderGet, HistoryDealGet)
- CTrade class usage
- MqlTradeRequest / MqlTradeResult structures
- Order types, filling types, return codes

### 4. [Technical Indicators](04-technical-indicators.md)
Built-in and custom indicators:
- Trend: MA, Bollinger Bands, Parabolic SAR, ADX, Ichimoku
- Oscillators: RSI, MACD, Stochastic, CCI, WPR, Momentum, DeMarker
- Volume: OBV, MFI, Accumulation/Distribution
- Volatility: ATR, Standard Deviation
- Bill Williams: Alligator, Fractals, AO, AC, Gator
- Getting handles and reading values
- Creating custom indicators

### 5. [Standard Library](05-standard-library.md)
MQL5 Standard Library classes:
- Trade classes: CTrade, CPositionInfo, COrderInfo, CAccountInfo, CSymbolInfo
- Expert framework: CExpert, CExpertSignal, CExpertMoney, CExpertTrailing
- Signal modules: SignalMA, SignalRSI, SignalMACD, etc.
- Money management: MoneyFixedLot, MoneyFixedRisk, etc.
- File operations: CFileTxt, CFileBin, CFileCsv
- Collections: CArrayObj, CHashMap
- Indicator classes: CiMA, CiRSI, CiMACD, etc.
- Chart objects, Calendar, Database access

### 6. [Predefined Variables](06-predefined-variables.md)
Built-in variables and environment access:
- `_Symbol`, `_Period`, `_Digits`, `_Point`
- Series data (CopyClose, CopyOpen, iClose, iHigh, etc.)
- Time functions (TimeCurrent, TimeLocal, TimeGMT)
- Account info (balance, equity, margin, leverage)
- Market info (bid, ask, spread, tick value)
- Terminal and MQL5 program properties

### 7. [Chart Operations](07-chart-operations.md)
Chart manipulation and object drawing:
- Chart navigation and properties
- Creating/managing chart objects
- Line types, shapes, Fibonacci tools
- Drawing arrows, text labels
- Screen coordinates vs chart coordinates

---

## Quick Reference: EA Template

```mql5
#property copyright "Your Name"
#property link      "https://your-link.com"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

input double Lots = 0.1;
input int    StopLoss = 100;
input int    TakeProfit = 200;
input int    MagicNumber = 12345;

CTrade trade;
int ma_handle;

int OnInit()
{
    trade.SetExpertMagicNumber(MagicNumber);
    ma_handle = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
    if(ma_handle == INVALID_HANDLE)
        return(INIT_FAILED);
    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    IndicatorRelease(ma_handle);
}

void OnTick()
{
    if(!PositionSelect(_Symbol))
    {
        double ma[];
        ArraySetAsSeries(ma, true);
        CopyBuffer(ma_handle, 0, 0, 2, ma);
        
        double close = iClose(_Symbol, PERIOD_CURRENT, 1);
        double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        double sl = ask - StopLoss * _Point;
        double tp = ask + TakeProfit * _Point;
        
        if(close > ma[1])
            trade.Buy(Lots, _Symbol, ask, sl, tp, "EA Buy");
    }
}
```

## Quick Reference: Key Function Groups

| Category | Key Functions |
|---|---|
| **Trading** | `OrderSend()`, `OrderCheck()`, `PositionSelect()` |
| **Positions** | `PositionsTotal()`, `PositionGetTicket()`, `PositionGetDouble()` |
| **Orders** | `OrdersTotal()`, `OrderGetTicket()`, `OrderSelect()` |
| **History** | `HistorySelect()`, `HistoryOrderGet*()`, `HistoryDealGet*()` |
| **Indicators** | `iMA()`, `iRSI()`, `iMACD()`, `iBands()`, `CopyBuffer()` |
| **Market Info** | `SymbolInfoDouble()`, `SymbolInfoInteger()`, `SymbolInfoString()` |
| **Account** | `AccountInfoDouble()`, `AccountInfoInteger()`, `AccountInfoString()` |
| **Chart** | `ChartGetInteger()`, `ChartSetInteger()`, `ObjectCreate()` |
| **Time** | `TimeCurrent()`, `TimeLocal()`, `TimeToString()`, `TimeToStruct()` |
| **Series** | `CopyClose()`, `CopyOpen()`, `iClose()`, `iHigh()`, `Bars()` |

## Documentation Sources

All content sourced from the official MQL5 Reference:
- Main: https://www.mql5.com/en/docs
- Language Basis: https://www.mql5.com/en/docs/basis
- Trade Functions: https://www.mql5.com/en/docs/trading
- Event Handlers: https://www.mql5.com/en/docs/event_handlers
- Indicators: https://www.mql5.com/en/docs/indicators
- Standard Library: https://www.mql5.com/en/docs/standardlibrary
- Predefined Variables: https://www.mql5.com/en/docs/predefined
