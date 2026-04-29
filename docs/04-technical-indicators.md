# MQL5 Technical Indicators

> Source: https://www.mql5.com/en/docs/indicators and https://www.mql5.com/en/docs/customind

All functions like iMA, iAC, iMACD, iIchimoku etc. create a copy of the corresponding technical indicator in the global cache of the client terminal. If a copy of the indicator with such parameters already exists, the new copy is not created, and the counter of references to the existing copy increases.

These functions return the handle of the appropriate copy of the indicator. Further, using this handle, you can receive data calculated by the corresponding indicator. The corresponding buffer data (technical indicators contain calculated data in their internal buffers, which can vary from 1 to 5, depending on the indicator) can be copied to a mql5-program using the CopyBuffer() function.

You can't refer to the indicator data right after it has been created, because calculation of indicator values requires some time, so it's better to create indicator handles in OnInit(). Function iCustom() creates the corresponding custom indicator, and returns its handle in case it is successfully create. Custom indicators can contain up to 512 indicator buffers, the contents of which can also be obtained by the CopyBuffer() function, using the obtained handle.

## Built-in Indicator Functions

### Trend Indicators

**Moving Average (MA):**
```mql5
int iMA(string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift,
        ENUM_MA_METHOD ma_method, ENUM_APPLIED_PRICE applied_price);
```
- `ma_method`: MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
- `applied_price`: PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED

**Bollinger Bands (BB):**
```mql5
int iBands(string symbol, ENUM_TIMEFRAMES period, int bands_period,
           int bands_shift, double deviation, ENUM_APPLIED_PRICE applied_price);
```

**Envelopes:**
```mql5
int iEnvelopes(string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift,
               ENUM_MA_METHOD ma_method, ENUM_APPLIED_PRICE applied_price, double deviation);
```

**Parabolic SAR:**
```mql5
int iSAR(string symbol, ENUM_TIMEFRAMES period, double step, double maximum);
```

**Average Directional Index (ADX):**
```mql5
int iADX(string symbol, ENUM_TIMEFRAMES period, int adx_period);
```

**Ichimoku Kinko Hyo:**
```mql5
int iIchimoku(string symbol, ENUM_TIMEFRAMES period, int tenkan_sen, int kijun_sen, int senkou_span_b);
```

**Standard Deviation:**
```mql5
int iStdDev(string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift,
            ENUM_MA_METHOD ma_method, ENUM_APPLIED_PRICE applied_price);
```

### Oscillators

**Relative Strength Index (RSI):**
```mql5
int iRSI(string symbol, ENUM_TIMEFRAMES period, int rsi_period, ENUM_APPLIED_PRICE applied_price);
```

**Moving Average Convergence/Divergence (MACD):**
```mql5
int iMACD(string symbol, ENUM_TIMEFRAMES period, int fast_ema_period, int slow_ema_period,
          int signal_period, ENUM_APPLIED_PRICE applied_price);
```

**Stochastic Oscillator:**
```mql5
int iStochastic(string symbol, ENUM_TIMEFRAMES period, int K_period, int D_period,
                int slowing, ENUM_MA_METHOD ma_method, ENUM_STO_PRICE price_field);
```

**Commodity Channel Index (CCI):**
```mql5
int iCCI(string symbol, ENUM_TIMEFRAMES period, int cci_period, ENUM_APPLIED_PRICE applied_price);
```

**Williams Percent Range (WPR):**
```mql5
int iWPR(string symbol, ENUM_TIMEFRAMES period, int wpr_period);
```

**Momentum:**
```mql5
int iMomentum(string symbol, ENUM_TIMEFRAMES period, int mom_period, ENUM_APPLIED_PRICE applied_price);
```

**DeMarker:**
```mql5
int iDeMarker(string symbol, ENUM_TIMEFRAMES period, int dem_period);
```

**Relative Vigor Index (RVI):**
```mql5
int iRVI(string symbol, ENUM_TIMEFRAMES period, int rvi_period);
```

### Volume Indicators

**Volumes:**
```mql5
int iVolumes(string symbol, ENUM_TIMEFRAMES period, ENUM_APPLIED_VOLUME applied_volume);
```

**On Balance Volume (OBV):**
```mql5
int iOBV(string symbol, ENUM_TIMEFRAMES period, ENUM_APPLIED_VOLUME applied_volume);
```

**Money Flow Index (MFI):**
```mql5
int iMFI(string symbol, ENUM_TIMEFRAMES period, int mfi_period, ENUM_APPLIED_VOLUME applied_volume);
```

**Accumulation/Distribution:**
```mql5
int iAD(string symbol, ENUM_TIMEFRAMES period, ENUM_APPLIED_VOLUME applied_volume);
```

### Volatility Indicators

**Average True Range (ATR):**
```mql5
int iATR(string symbol, ENUM_TIMEFRAMES period, int atr_period);
```

**Bollinger Bands Width:**
Calculated from Bollinger Bands: `(Upper - Lower) / Middle`

**Standard Deviation:**
```mql5
int iStdDev(string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift,
            ENUM_MA_METHOD ma_method, ENUM_APPLIED_PRICE applied_price);
```

### Bill Williams Indicators

**Alligator:**
```mql5
int iAlligator(string symbol, ENUM_TIMEFRAMES period,
               int jaw_period, int jaw_shift, int teeth_period, int teeth_shift,
               int lips_period, int lips_shift, ENUM_MA_METHOD ma_method,
               ENUM_APPLIED_PRICE applied_price);
```

**Fractals:**
```mql5
int iFractals(string symbol, ENUM_TIMEFRAMES period);
```

**Awesome Oscillator (AO):**
```mql5
int iAO(string symbol, ENUM_TIMEFRAMES period);
```

**Accelerator Oscillator (AC):**
```mql5
int iAC(string symbol, ENUM_TIMEFRAMES period);
```

**Gator:**
```mql5
int iGator(string symbol, ENUM_TIMEFRAMES period,
           int jaw_period, int jaw_shift, int teeth_period, int teeth_shift,
           int lips_period, int lips_shift, ENUM_MA_METHOD ma_method,
           ENUM_APPLIED_PRICE applied_price);
```

**Market Facilitation Index (MFI):**
```mql5
int iBWMFI(string symbol, ENUM_TIMEFRAMES period);
```

---

## Using Indicators in Expert Advisors

### Getting Indicator Handle and Values

```mql5
int OnInit()
{
    // Create indicator handle
    ma_handle = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
    if(ma_handle == INVALID_HANDLE)
    {
        Print("Failed to create MA indicator");
        return(INIT_FAILED);
    }
    
    rsi_handle = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
    macd_handle = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
    bb_handle = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
    
    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    IndicatorRelease(ma_handle);
    IndicatorRelease(rsi_handle);
    IndicatorRelease(macd_handle);
    IndicatorRelease(bb_handle);
}

void OnTick()
{
    double ma_value[];
    ArraySetAsSeries(ma_value, true);
    CopyBuffer(ma_handle, 0, 0, 3, ma_value);
    
    double rsi_value[];
    ArraySetAsSeries(rsi_value, true);
    CopyBuffer(rsi_handle, 0, 0, 3, rsi_value);
    
    // Check if data copied successfully
    if(ArraySize(ma_value) < 3 || ArraySize(rsi_value) < 3)
        return;
    
    Print("MA: ", ma_value[0], " RSI: ", rsi_value[0]);
}
```

### Multi-Buffer Indicators (Bollinger Bands)

```mql5
void OnTick()
{
    double upper[], middle[], lower[];
    ArraySetAsSeries(upper, true);
    ArraySetAsSeries(middle, true);
    ArraySetAsSeries(lower, true);
    
    CopyBuffer(bb_handle, 0, 0, 3, middle);  // Buffer 0: Middle (SMA)
    CopyBuffer(bb_handle, 1, 0, 3, upper);   // Buffer 1: Upper band
    CopyBuffer(bb_handle, 2, 0, 3, lower);   // Buffer 2: Lower band
    
    double close = iClose(_Symbol, PERIOD_CURRENT, 1);
    
    if(close > upper[1])
        Print("Price above upper band - overbought");
    else if(close < lower[1])
        Print("Price below lower band - oversold");
}
```

### MACD Usage

```mql5
void OnTick()
{
    double main[], signal[];
    ArraySetAsSeries(main, true);
    ArraySetAsSeries(signal, true);
    
    CopyBuffer(macd_handle, 0, 0, 3, main);    // Main line
    CopyBuffer(macd_handle, 1, 0, 3, signal);   // Signal line
    
    // MACD crossover strategy
    if(main[2] < signal[2] && main[1] > signal[1])
        Print("MACD bullish crossover");
    else if(main[2] > signal[2] && main[1] < signal[1])
        Print("MACD bearish crossover");
}
```

### Stochastic Oscillator

```mql5
void OnTick()
{
    double k[], d[];
    ArraySetAsSeries(k, true);
    ArraySetAsSeries(d, true);
    
    CopyBuffer(stoch_handle, 0, 0, 3, k);  // %K line
    CopyBuffer(stoch_handle, 1, 0, 3, d);  // %D line
    
    if(k[1] < 20 && d[1] < 20)
        Print("Oversold zone");
    else if(k[1] > 80 && d[1] > 80)
        Print("Overbought zone");
}
```

---

## Creating Custom Indicators

```mql5
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2

#property indicator_label1 "Upper"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2

#property indicator_label2 "Lower"
#property indicator_type2 DRAW_LINE
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2

input int Period = 20;
input double Multiplier = 2.0;

double UpperBuffer[];
double LowerBuffer[];

int OnInit()
{
    SetIndexBuffer(0, UpperBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, LowerBuffer, INDICATOR_DATA);
    
    PlotIndexSetString(0, PLOT_LABEL, "Upper Band");
    PlotIndexSetString(1, PLOT_LABEL, "Lower Band");
    
    return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
{
    if(rates_total < Period) return(0);
    
    int start = prev_calculated > 0 ? prev_calculated - 1 : Period;
    
    for(int i = start; i < rates_total; i++)
    {
        double sum = 0;
        for(int j = 0; j < Period; j++)
            sum += close[i - j];
        double sma = sum / Period;
        
        double std_dev = 0;
        for(int j = 0; j < Period; j++)
            std_dev += MathPow(close[i - j] - sma, 2);
        std_dev = MathSqrt(std_dev / Period);
        
        UpperBuffer[i] = sma + Multiplier * std_dev;
        LowerBuffer[i] = sma - Multiplier * std_dev;
    }
    
    return(rates_total);
}
```

---

## Indicator Buffer Properties

| Property | Description |
|---|---|
| `INDICATOR_DATA` | Data buffer (visible on chart) |
| `INDICATOR_COLOR_INDEX` | Color index buffer |
| `INDICATOR_CALCULATIONS` | Auxiliary calculation buffer |

## Chart Window Types

- `indicator_chart_window` - drawn on the price chart
- `indicator_separate_window` - drawn in a separate window

## Drawing Styles

- `DRAW_LINE` - continuous line
- `DRAW_SECTION` - section line (gaps on NaN)
- `DRAW_HISTOGRAM` - histogram from zero
- `DRAW_ARROW` - arrows (icons)
- `DRAW_FILLING` - area fill between two buffers
- `DRAW_ZIGZAG` - zigzag line
- `DRAW_NONE` - invisible buffer
