//+------------------------------------------------------------------+
//|                            Gold_MultiStrategy_EA.mq5              |
//|                            M5-Optimized Multi-Strategy Gold EA    |
//|                            v2.0 - 11 Strategies + Filters        |
//+------------------------------------------------------------------+
#property copyright "Based on 319 MQL5 Gold Articles Deep Analysis"
#property link      ""
#property version   "2.00"
#property description "M5-Optimized Multi-Strategy EA for XAUUSDc"
#property description "11 strategies + ADX/Multi-TF filters + Partial Close + Trailing Stop"
#property description "Signals vote: trade when enough strategies agree"

//+------------------------------------------------------------------+
//| STRATEGY TOGGLES                                                  |
//+------------------------------------------------------------------+
input group "=== ORIGINAL STRATEGIES ==="
input bool     InpUseEMA_RSI         = true;          // EMA RSI Crossover
input bool     InpUseTrendSR         = true;          // Trend + S/R Bounce
input bool     InpUseBreakout        = true;          // Price Breakout
input bool     InpUseRSI_Extreme     = true;          // RSI Extreme Reversal
input bool     InpUseMACD_Trend      = true;          // MACD Trend Following
input bool     InpUseBollinger_Sq    = true;          // Bollinger Squeeze

input group "=== NEW ADVANCED STRATEGIES ==="
input bool     InpUseHeikinAshi      = true;          // Heikin Ashi Breakout
input bool     InpUseDonchian        = true;          // Donchian Channel Breakout
input bool     InpUseGoldenCross     = true;          // Golden/Death Cross
input bool     InpUseDivergence      = true;          // Advanced Divergence
input bool     InpUseSMC             = true;          // Smart Money Concepts (Simplified)

input group "=== SIGNAL FILTERS ==="
input bool     InpUseADXFilter       = true;          // ADX Trend Filter
input bool     InpUseMultiTF         = true;          // Multi-Timeframe Confirmation
input bool     InpUseVolumeFilter    = true;          // Volume Filter

input group "=== EXIT MANAGEMENT ==="
input bool     InpUsePartialClose    = true;          // Partial Close (50% at 1:1)
input bool     InpUseTrailingStop    = true;          // Trailing Stop
input bool     InpUseBreakeven       = true;          // Move SL to Breakeven

input group "=== SIGNAL AGGREGATION ==="
input int      InpMinBuySignals      = 3;             // Min signals for BUY (1-11)
input int      InpMinSellSignals     = 3;             // Min signals for SELL (1-11)

//+------------------------------------------------------------------+
//| EMA RSI SETTINGS (M5-optimized: faster periods)                   |
//+------------------------------------------------------------------+
input group "=== EMA RSI ==="
input int      InpEMA_Fast           = 9;             // Fast EMA
input int      InpEMA_Slow           = 21;            // Slow EMA
input int      InpRSI_Period         = 9;             // RSI Period
input int      InpRSI_BuyLevel       = 40;            // RSI Buy Above
input int      InpRSI_SellLevel      = 60;            // RSI Sell Below

//+------------------------------------------------------------------+
//| TREND S/R SETTINGS                                                |
//+------------------------------------------------------------------+
input group "=== TREND S/R ==="
input int      InpTrendEMA           = 200;           // Trend EMA Period
input int      InpSRPeriod           = 20;            // S/R Lookback Period
input int      InpSRZone             = 300;           // S/R Zone Size (points)
input int      InpFastEMA_SR         = 9;             // Fast EMA (S/R)
input int      InpSlowEMA_SR         = 21;            // Slow EMA (S/R)

//+------------------------------------------------------------------+
//| BREAKOUT SETTINGS (M5-optimized)                                  |
//+------------------------------------------------------------------+
input group "=== BREAKOUT ==="
input int      InpBreakoutLookback   = 10;            // Lookback Period
input double   InpBreakoutSize       = 50;            // Min Breakout Size (points)
input double   InpATRMultiplier      = 1.2;           // ATR Multiplier for Breakout

//+------------------------------------------------------------------+
//| RSI EXTREME SETTINGS (M5-optimized)                               |
//+------------------------------------------------------------------+
input group "=== RSI EXTREME ==="
input int      InpRSI_Period_Ext     = 9;             // RSI Period
input int      InpRSI_Oversold       = 25;            // RSI Oversold Level
input int      InpRSI_Overbought     = 75;            // RSI Overbought Level

//+------------------------------------------------------------------+
//| MACD TREND SETTINGS (M5-optimized: 8/17/9)                        |
//+------------------------------------------------------------------+
input group "=== MACD TREND ==="
input int      InpMACDFast           = 8;             // MACD Fast EMA
input int      InpMACDSlow           = 17;            // MACD Slow EMA
input int      InpMACDSignal         = 9;             // MACD Signal Line
input int      InpMomentumPeriod     = 10;            // Momentum Period

//+------------------------------------------------------------------+
//| BOLLINGER SQUEEZE SETTINGS                                        |
//+------------------------------------------------------------------+
input group "=== BOLLINGER SQUEEZE ==="
input int      InpBB_Period          = 20;            // BB Period
input double   InpBB_Deviation       = 2.0;           // BB Deviation
input int      InpBB_SqueezeBars     = 6;             // Squeeze Detection Bars
input double   InpBB_ExpandATR       = 1.2;           // Expansion ATR Threshold

//+------------------------------------------------------------------+
//| HEIKIN ASHI SETTINGS                                              |
//+------------------------------------------------------------------+
input group "=== HEIKIN ASHI ==="
input int      InpHA_Period          = 10;            // HA Smoothing Period
input double   InpHA_SL_Multi        = 1.0;           // SL (ATR Multiplier)
input double   InpHA_TP_Multi        = 1.5;           // TP (ATR Multiplier)

//+------------------------------------------------------------------+
//| DONCHIAN CHANNEL SETTINGS                                         |
//+------------------------------------------------------------------+
input group "=== DONCHIAN CHANNEL ==="
input int      InpDonchian_Period    = 20;            // Donchian Period
input int      InpADX_Period_DC      = 14;            // ADX Period for Donchian
input int      InpADX_Threshold_DC   = 20;            // ADX Threshold

//+------------------------------------------------------------------+
//| GOLDEN/DEATH CROSS SETTINGS (M5: longer periods)                  |
//+------------------------------------------------------------------+
input group "=== GOLDEN CROSS ==="
input int      InpGC_FastEMA         = 50;            // Fast EMA
input int      InpGC_SlowEMA         = 200;           // Slow EMA
input int      InpGC_ConfirmBars     = 3;             // Confirmation Candles

//+------------------------------------------------------------------+
//| ADVANCED DIVERGENCE SETTINGS                                      |
//+------------------------------------------------------------------+
input group "=== DIVERGENCE ==="
input int      InpDiv_RSI_Period     = 14;            // RSI Period
input int      InpDiv_Lookback       = 10;            // Swing Lookback
input int      InpDiv_MinSwing       = 30;            // Min Swing Points

//+------------------------------------------------------------------+
//| SMART MONEY CONCEPTS SETTINGS                                     |
//+------------------------------------------------------------------+
input group "=== SMART MONEY ==="
input int      InpSMC_OB_Lookback    = 20;            // Order Block Lookback
input int      InpSMC_FVG_MinSize    = 5;             // Min FVG Size (points)
input int      InpSMC_KillZone_Start = 7;             // Kill Zone Start (hour, GMT)
input int      InpSMC_KillZone_End   = 10;            // Kill Zone End (hour, GMT)

//+------------------------------------------------------------------+
//| ADX FILTER SETTINGS                                               |
//+------------------------------------------------------------------+
input group "=== ADX FILTER ==="
input int      InpADX_Period         = 14;            // ADX Period
input int      InpADX_TrendLevel     = 20;            // ADX Trend Threshold
input int      InpADX_RangeLevel     = 15;            // ADX Range Threshold

//+------------------------------------------------------------------+
//| MULTI-TIMEFRAME SETTINGS                                          |
//+------------------------------------------------------------------+
input group "=== MULTI-TIMEFRAME ==="
input ENUM_TIMEFRAMES InpMTF_TF1     = PERIOD_M15;    // Confirmation TF 1
input ENUM_TIMEFRAMES InpMTF_TF2     = PERIOD_H1;     // Confirmation TF 2
input int      InpMTF_EMA_Period     = 50;            // MTF EMA Period

//+------------------------------------------------------------------+
//| RISK MANAGEMENT (M5-optimized: tighter)                           |
//+------------------------------------------------------------------+
input group "=== RISK MANAGEMENT ==="
input double   InpRiskPercent        = 0.5;           // Risk Per Trade (%)
input double   InpSLMultiplier       = 1.0;           // SL (ATR Multiplier)
input double   InpTPMultiplier       = 1.5;           // TP (ATR Multiplier)
input int      InpMaxPositions       = 2;             // Max Open Positions

//+------------------------------------------------------------------+
//| PARTIAL CLOSE + TRAILING STOP                                     |
//+------------------------------------------------------------------+
input group "=== EXIT MANAGEMENT ==="
input double   InpPartialClosePct    = 50.0;          // Partial Close (%)
input double   InpPartialCloseRR     = 1.0;           // Close at R:R ratio
input double   InpTrailATRMulti      = 1.5;           // Trail Stop (ATR Multiplier)
input double   InpBreakevenATR       = 0.8;           // Breakeven after (ATR Multiplier)

//+------------------------------------------------------------------+
//| SESSION & SPREAD FILTER                                           |
//+------------------------------------------------------------------+
input group "=== SESSION FILTER ==="
input int      InpLondonStart        = 7;             // London Session Start (GMT)
input int      InpLondonEnd          = 10;            // London Session End (GMT)
input int      InpNYStart            = 12;            // NY Session Start (GMT)
input int      InpNYEnd              = 15;            // NY Session End (GMT)
input int      InpMaxSpread          = 30;            // Max Spread (points)

//+------------------------------------------------------------------+
//| GENERAL SETTINGS                                                  |
//+------------------------------------------------------------------+
input group "=== GENERAL ==="
input ulong    InpMagicNumber        = 999999;        // Magic Number
input string   InpTradeComment       = "MultiStrat";  // Trade Comment

//+------------------------------------------------------------------+
//| INDICATOR HANDLES                                                 |
//+------------------------------------------------------------------+
// Original 6 strategies
int handleEMA_Fast, handleEMA_Slow, handleRSI;
int handleTrendEMA, handleFastEMA_SR, handleSlowEMA_SR, handleMomentum_SR;
int handleBreakoutEMA, handleATR;
int handleRSI_Extreme;
int handleMACD, handleMomentum;
int handleBB;

// New strategies
int handleADX;
int handleGC_FastEMA, handleGC_SlowEMA;
int handleDiv_RSI, handleDiv_MACD;
int handleMTF1_EMA, handleMTF2_EMA;

// Multi-timeframe
int handleMTF_EMA_TF1, handleMTF_EMA_TF2;

//+------------------------------------------------------------------+
//| INDICATOR BUFFERS                                                 |
//+------------------------------------------------------------------+
// Original
double emaFast[], emaSlow[], rsiValues[];
double trendEMA[], fastEMA_SR[], slowEMA_SR[], momentum_SR[];
double atrValues[], breakoutEMA[];
double rsiExtreme[];
double macdMain[], macdSignal[], macdHistogram[];
double momentum[];
double bbUpper[], bbMiddle[], bbLower[];

// New
double adxValues[], plusDI[], minusDI[];
double gcFastEMA[], gcSlowEMA[];
double divRSI[], divMACDMain[], divMACDSignal[];
double mtf1EMA[], mtf2EMA[];

//+------------------------------------------------------------------+
//| INITIALIZATION                                                    |
//+------------------------------------------------------------------+
int OnInit()
{
   // --- Original 6 strategies ---
   handleEMA_Fast    = iMA(_Symbol, PERIOD_CURRENT, InpEMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
   handleEMA_Slow    = iMA(_Symbol, PERIOD_CURRENT, InpEMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
   handleRSI         = iRSI(_Symbol, PERIOD_CURRENT, InpRSI_Period, PRICE_CLOSE);
   handleTrendEMA    = iMA(_Symbol, PERIOD_CURRENT, InpTrendEMA, 0, MODE_EMA, PRICE_CLOSE);
   handleFastEMA_SR  = iMA(_Symbol, PERIOD_CURRENT, InpFastEMA_SR, 0, MODE_EMA, PRICE_CLOSE);
   handleSlowEMA_SR  = iMA(_Symbol, PERIOD_CURRENT, InpSlowEMA_SR, 0, MODE_EMA, PRICE_CLOSE);
   handleMomentum_SR = iMomentum(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
   handleBreakoutEMA = iMA(_Symbol, PERIOD_CURRENT, 100, 0, MODE_EMA, PRICE_CLOSE);
   handleATR         = iATR(_Symbol, PERIOD_CURRENT, 14);
   handleRSI_Extreme = iRSI(_Symbol, PERIOD_CURRENT, InpRSI_Period_Ext, PRICE_CLOSE);
   handleMACD        = iMACD(_Symbol, PERIOD_CURRENT, InpMACDFast, InpMACDSlow, InpMACDSignal, PRICE_CLOSE);
   handleMomentum    = iMomentum(_Symbol, PERIOD_CURRENT, InpMomentumPeriod, PRICE_CLOSE);
   handleBB          = iBands(_Symbol, PERIOD_CURRENT, InpBB_Period, 0, InpBB_Deviation, PRICE_CLOSE);
   
   // --- New strategies ---
   handleADX         = iADX(_Symbol, PERIOD_CURRENT, InpADX_Period);
   handleGC_FastEMA  = iMA(_Symbol, PERIOD_CURRENT, InpGC_FastEMA, 0, MODE_EMA, PRICE_CLOSE);
   handleGC_SlowEMA  = iMA(_Symbol, PERIOD_CURRENT, InpGC_SlowEMA, 0, MODE_EMA, PRICE_CLOSE);
   handleDiv_RSI     = iRSI(_Symbol, PERIOD_CURRENT, InpDiv_RSI_Period, PRICE_CLOSE);
   handleDiv_MACD    = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
   
   // --- Multi-timeframe EMAs ---
   handleMTF_EMA_TF1 = iMA(_Symbol, InpMTF_TF1, InpMTF_EMA_Period, 0, MODE_EMA, PRICE_CLOSE);
   handleMTF_EMA_TF2 = iMA(_Symbol, InpMTF_TF2, InpMTF_EMA_Period, 0, MODE_EMA, PRICE_CLOSE);
   
   // Validate all handles
   if(handleEMA_Fast == INVALID_HANDLE || handleEMA_Slow == INVALID_HANDLE ||
      handleRSI == INVALID_HANDLE || handleTrendEMA == INVALID_HANDLE ||
      handleFastEMA_SR == INVALID_HANDLE || handleSlowEMA_SR == INVALID_HANDLE ||
      handleATR == INVALID_HANDLE || handleBreakoutEMA == INVALID_HANDLE ||
      handleRSI_Extreme == INVALID_HANDLE || handleMACD == INVALID_HANDLE ||
      handleMomentum == INVALID_HANDLE || handleBB == INVALID_HANDLE ||
      handleMomentum_SR == INVALID_HANDLE || handleADX == INVALID_HANDLE ||
      handleGC_FastEMA == INVALID_HANDLE || handleGC_SlowEMA == INVALID_HANDLE ||
      handleDiv_RSI == INVALID_HANDLE || handleDiv_MACD == INVALID_HANDLE ||
      handleMTF_EMA_TF1 == INVALID_HANDLE || handleMTF_EMA_TF2 == INVALID_HANDLE)
   {
      Print("ERROR: Failed to create indicator handles");
      return(INIT_FAILED);
   }
   
   // Set buffers as series
   ArraySetAsSeries(emaFast, true);
   ArraySetAsSeries(emaSlow, true);
   ArraySetAsSeries(rsiValues, true);
   ArraySetAsSeries(trendEMA, true);
   ArraySetAsSeries(fastEMA_SR, true);
   ArraySetAsSeries(slowEMA_SR, true);
   ArraySetAsSeries(atrValues, true);
   ArraySetAsSeries(breakoutEMA, true);
   ArraySetAsSeries(rsiExtreme, true);
   ArraySetAsSeries(macdMain, true);
   ArraySetAsSeries(macdSignal, true);
   ArraySetAsSeries(macdHistogram, true);
   ArraySetAsSeries(momentum, true);
   ArraySetAsSeries(bbUpper, true);
   ArraySetAsSeries(bbMiddle, true);
   ArraySetAsSeries(bbLower, true);
   ArraySetAsSeries(momentum_SR, true);
   ArraySetAsSeries(adxValues, true);
   ArraySetAsSeries(plusDI, true);
   ArraySetAsSeries(minusDI, true);
   ArraySetAsSeries(gcFastEMA, true);
   ArraySetAsSeries(gcSlowEMA, true);
   ArraySetAsSeries(divRSI, true);
   ArraySetAsSeries(divMACDMain, true);
   ArraySetAsSeries(divMACDSignal, true);
   ArraySetAsSeries(mtf1EMA, true);
   ArraySetAsSeries(mtf2EMA, true);
   
   Print("=== Gold Multi-Strategy EA v2.0 M5-Optimized ===");
   Print("Strategies: 11 | Filters: ADX + Multi-TF + Volume");
   Print("Exit Mgmt: Partial Close + Trailing + Breakeven");
   Print("Min Buy Signals: ", InpMinBuySignals, " | Min Sell Signals: ", InpMinSellSignals);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| DEINITIALIZATION                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Original handles
   if(handleEMA_Fast != INVALID_HANDLE) IndicatorRelease(handleEMA_Fast);
   if(handleEMA_Slow != INVALID_HANDLE) IndicatorRelease(handleEMA_Slow);
   if(handleRSI != INVALID_HANDLE) IndicatorRelease(handleRSI);
   if(handleTrendEMA != INVALID_HANDLE) IndicatorRelease(handleTrendEMA);
   if(handleFastEMA_SR != INVALID_HANDLE) IndicatorRelease(handleFastEMA_SR);
   if(handleSlowEMA_SR != INVALID_HANDLE) IndicatorRelease(handleSlowEMA_SR);
   if(handleATR != INVALID_HANDLE) IndicatorRelease(handleATR);
   if(handleBreakoutEMA != INVALID_HANDLE) IndicatorRelease(handleBreakoutEMA);
   if(handleRSI_Extreme != INVALID_HANDLE) IndicatorRelease(handleRSI_Extreme);
   if(handleMACD != INVALID_HANDLE) IndicatorRelease(handleMACD);
   if(handleMomentum != INVALID_HANDLE) IndicatorRelease(handleMomentum);
   if(handleBB != INVALID_HANDLE) IndicatorRelease(handleBB);
   if(handleMomentum_SR != INVALID_HANDLE) IndicatorRelease(handleMomentum_SR);
   
   // New handles
   if(handleADX != INVALID_HANDLE) IndicatorRelease(handleADX);
   if(handleGC_FastEMA != INVALID_HANDLE) IndicatorRelease(handleGC_FastEMA);
   if(handleGC_SlowEMA != INVALID_HANDLE) IndicatorRelease(handleGC_SlowEMA);
   if(handleDiv_RSI != INVALID_HANDLE) IndicatorRelease(handleDiv_RSI);
   if(handleDiv_MACD != INVALID_HANDLE) IndicatorRelease(handleDiv_MACD);
   if(handleMTF_EMA_TF1 != INVALID_HANDLE) IndicatorRelease(handleMTF_EMA_TF1);
   if(handleMTF_EMA_TF2 != INVALID_HANDLE) IndicatorRelease(handleMTF_EMA_TF2);
}

//+------------------------------------------------------------------+
//| MAIN TICK FUNCTION                                                |
//+------------------------------------------------------------------+
void OnTick()
{
   // --- Exit management runs every tick ---
   if(InpUseTrailingStop || InpUseBreakeven)
      ManageOpenPositions();
   
   // --- New bar filter ---
   static datetime lastBar = 0;
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(lastBar == currentBar) return;
   lastBar = currentBar;
   
   // --- Pre-filters ---
   if(!IsSessionTime()) return;
   if(!IsSpreadOK()) return;
   if(!GetIndicatorValues()) return;
   
   // --- Signal filters ---
   if(InpUseADXFilter && !PassesADXFilter()) return;
   if(InpUseMultiTF && !PassesMultiTFFilter()) return;
   if(InpUseVolumeFilter && !PassesVolumeFilter()) return;
   
   // --- Collect all strategy signals ---
   int buySignals = 0;
   int sellSignals = 0;
   string buyReasons = "";
   string sellReasons = "";
   
   // 1. EMA RSI Crossover
   if(InpUseEMA_RSI)
   {
      int sig = SignalEMA_RSI();
      if(sig == 1)       { buySignals++;  buyReasons  += "EMA_RSI,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "EMA_RSI,"; }
   }
   
   // 2. Trend S/R Bounce
   if(InpUseTrendSR)
   {
      int sig = SignalTrendSR();
      if(sig == 1)       { buySignals++;  buyReasons  += "Trend_SR,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "Trend_SR,"; }
   }
   
   // 3. Price Breakout
   if(InpUseBreakout)
   {
      int sig = SignalBreakout();
      if(sig == 1)       { buySignals++;  buyReasons  += "Breakout,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "Breakout,"; }
   }
   
   // 4. RSI Extreme Reversal
   if(InpUseRSI_Extreme)
   {
      int sig = SignalRSI_Extreme();
      if(sig == 1)       { buySignals++;  buyReasons  += "RSI_Ext,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "RSI_Ext,"; }
   }
   
   // 5. MACD Trend Following
   if(InpUseMACD_Trend)
   {
      int sig = SignalMACD_Trend();
      if(sig == 1)       { buySignals++;  buyReasons  += "MACD,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "MACD,"; }
   }
   
   // 6. Bollinger Squeeze
   if(InpUseBollinger_Sq)
   {
      int sig = SignalBollinger_Squeeze();
      if(sig == 1)       { buySignals++;  buyReasons  += "BB_Sq,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "BB_Sq,"; }
   }
   
   // 7. Heikin Ashi Breakout
   if(InpUseHeikinAshi)
   {
      int sig = SignalHeikinAshi();
      if(sig == 1)       { buySignals++;  buyReasons  += "HA,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "HA,"; }
   }
   
   // 8. Donchian Channel Breakout
   if(InpUseDonchian)
   {
      int sig = SignalDonchian();
      if(sig == 1)       { buySignals++;  buyReasons  += "Donchian,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "Donchian,"; }
   }
   
   // 9. Golden/Death Cross
   if(InpUseGoldenCross)
   {
      int sig = SignalGoldenCross();
      if(sig == 1)       { buySignals++;  buyReasons  += "GCross,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "GCross,"; }
   }
   
   // 10. Advanced Divergence
   if(InpUseDivergence)
   {
      int sig = SignalDivergence();
      if(sig == 1)       { buySignals++;  buyReasons  += "Div,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "Div,"; }
   }
   
   // 11. Smart Money Concepts
   if(InpUseSMC)
   {
      int sig = SignalSMC();
      if(sig == 1)       { buySignals++;  buyReasons  += "SMC,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "SMC,"; }
   }
   
   // --- Execute trades based on signal aggregation ---
   if(buySignals >= InpMinBuySignals && CountPositions(ORDER_TYPE_BUY) < InpMaxPositions)
   {
      ClosePositions(ORDER_TYPE_SELL);
      string comment = InpTradeComment + ":" + IntegerToString(buySignals) + "sig:" +
                       StringSubstr(buyReasons, 0, StringLen(buyReasons)-1);
      OpenBuy(comment);
      Print("BUY [", buySignals, "/", 11, " signals]: ", buyReasons);
   }
   else if(sellSignals >= InpMinSellSignals && CountPositions(ORDER_TYPE_SELL) < InpMaxPositions)
   {
      ClosePositions(ORDER_TYPE_BUY);
      string comment = InpTradeComment + ":" + IntegerToString(sellSignals) + "sig:" +
                       StringSubstr(sellReasons, 0, StringLen(sellReasons)-1);
      OpenSell(comment);
      Print("SELL [", sellSignals, "/", 11, " signals]: ", sellReasons);
   }
}

//+------------------------------------------------------------------+
//| GET ALL INDICATOR VALUES                                          |
//+------------------------------------------------------------------+
bool GetIndicatorValues()
{
   // Original indicators
   if(CopyBuffer(handleEMA_Fast, 0, 0, 5, emaFast) < 5) return false;
   if(CopyBuffer(handleEMA_Slow, 0, 0, 5, emaSlow) < 5) return false;
   if(CopyBuffer(handleRSI, 0, 0, 5, rsiValues) < 5) return false;
   if(CopyBuffer(handleTrendEMA, 0, 0, 5, trendEMA) < 5) return false;
   if(CopyBuffer(handleFastEMA_SR, 0, 0, 5, fastEMA_SR) < 5) return false;
   if(CopyBuffer(handleSlowEMA_SR, 0, 0, 5, slowEMA_SR) < 5) return false;
   if(CopyBuffer(handleMomentum_SR, 0, 0, 5, momentum_SR) < 5) return false;
   if(CopyBuffer(handleBreakoutEMA, 0, 0, 5, breakoutEMA) < 5) return false;
   if(CopyBuffer(handleATR, 0, 0, 12, atrValues) < 12) return false;
   if(CopyBuffer(handleRSI_Extreme, 0, 0, 5, rsiExtreme) < 5) return false;
   if(CopyBuffer(handleMACD, 0, 0, 6, macdMain) < 6) return false;
   if(CopyBuffer(handleMACD, 1, 0, 6, macdSignal) < 6) return false;
   if(CopyBuffer(handleMACD, 2, 0, 6, macdHistogram) < 6) return false;
   if(CopyBuffer(handleMomentum, 0, 0, 5, momentum) < 5) return false;
   if(CopyBuffer(handleBB, 0, 0, InpBB_SqueezeBars + 3, bbUpper) < InpBB_SqueezeBars + 3) return false;
   if(CopyBuffer(handleBB, 1, 0, InpBB_SqueezeBars + 3, bbMiddle) < InpBB_SqueezeBars + 3) return false;
   if(CopyBuffer(handleBB, 2, 0, InpBB_SqueezeBars + 3, bbLower) < InpBB_SqueezeBars + 3) return false;
   
   // New indicators
   if(CopyBuffer(handleADX, 0, 0, 5, adxValues) < 5) return false;
   if(CopyBuffer(handleADX, 1, 0, 5, plusDI) < 5) return false;
   if(CopyBuffer(handleADX, 2, 0, 5, minusDI) < 5) return false;
   if(CopyBuffer(handleGC_FastEMA, 0, 0, 5, gcFastEMA) < 5) return false;
   if(CopyBuffer(handleGC_SlowEMA, 0, 0, 5, gcSlowEMA) < 5) return false;
   if(CopyBuffer(handleDiv_RSI, 0, 0, InpDiv_Lookback + 3, divRSI) < InpDiv_Lookback + 3) return false;
   if(CopyBuffer(handleDiv_MACD, 0, 0, InpDiv_Lookback + 3, divMACDMain) < InpDiv_Lookback + 3) return false;
   if(CopyBuffer(handleDiv_MACD, 1, 0, InpDiv_Lookback + 3, divMACDSignal) < InpDiv_Lookback + 3) return false;
   
   // Multi-timeframe
   if(CopyBuffer(handleMTF_EMA_TF1, 0, 0, 3, mtf1EMA) < 3) return false;
   if(CopyBuffer(handleMTF_EMA_TF2, 0, 0, 3, mtf2EMA) < 3) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| ORIGINAL STRATEGY 1: EMA RSI CROSSOVER                            |
//+------------------------------------------------------------------+
int SignalEMA_RSI()
{
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   
   bool emaCrossUp   = (emaFast[2] <= emaSlow[2] && emaFast[1] > emaSlow[1]);
   bool emaCrossDown = (emaFast[2] >= emaSlow[2] && emaFast[1] < emaSlow[1]);
   
   if(emaCrossUp && rsiValues[1] > InpRSI_BuyLevel && close1 > emaFast[1])
      return 1;
   
   if(emaCrossDown && rsiValues[1] < InpRSI_SellLevel && close1 < emaFast[1])
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| ORIGINAL STRATEGY 2: TREND + S/R BOUNCE                           |
//+------------------------------------------------------------------+
int SignalTrendSR()
{
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
   double open1  = iOpen(_Symbol, PERIOD_CURRENT, 1);
   
   int trend = 0;
   if(close1 > trendEMA[1]) trend = 1;
   else if(close1 < trendEMA[1]) trend = -1;
   if(trend == 0) return 0;
   
   int highestBar = iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, InpSRPeriod, 2);
   int lowestBar  = iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, InpSRPeriod, 2);
   double high1   = iHigh(_Symbol, PERIOD_CURRENT, highestBar);
   double low1    = iLow(_Symbol, PERIOD_CURRENT, lowestBar);
   
   double zoneSize = InpSRZone * _Point;
   
   if(trend == 1)
   {
      if(close1 <= low1 + zoneSize && close1 > open1 && close1 > close2)
      {
         if(fastEMA_SR[1] > slowEMA_SR[1])
            return 1;
      }
   }
   
   if(trend == -1)
   {
      if(close1 >= high1 - zoneSize && close1 < open1 && close1 < close2)
      {
         if(fastEMA_SR[1] < slowEMA_SR[1])
            return -1;
      }
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| ORIGINAL STRATEGY 3: PRICE BREAKOUT                               |
//+------------------------------------------------------------------+
int SignalBreakout()
{
   int highestBar = iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, InpBreakoutLookback, 1);
   int lowestBar  = iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, InpBreakoutLookback, 1);
   
   double recentHigh = iHigh(_Symbol, PERIOD_CURRENT, highestBar);
   double recentLow  = iLow(_Symbol, PERIOD_CURRENT, lowestBar);
   
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
   double atr    = atrValues[1];
   
   double minBreakout = InpBreakoutSize * _Point;
   
   double avgATR = 0;
   for(int i = 1; i <= 10; i++)
      avgATR += atrValues[i];
   avgATR /= 10;
   
   if(close1 > recentHigh && close2 <= recentHigh)
   {
      double breakoutSize = close1 - recentHigh;
      bool isUptrend = close1 > breakoutEMA[1];
      if(breakoutSize >= minBreakout && isUptrend && atr > avgATR * InpATRMultiplier)
         return 1;
   }
   
   if(close1 < recentLow && close2 >= recentLow)
   {
      double breakoutSize = recentLow - close1;
      bool isDowntrend = close1 < breakoutEMA[1];
      if(breakoutSize >= minBreakout && isDowntrend && atr > avgATR * InpATRMultiplier)
         return -1;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| ORIGINAL STRATEGY 4: RSI EXTREME REVERSAL                         |
//+------------------------------------------------------------------+
int SignalRSI_Extreme()
{
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   bool isUptrend = close1 > trendEMA[1];
   bool isDowntrend = close1 < trendEMA[1];
   
   if(rsiExtreme[2] <= InpRSI_Oversold && rsiExtreme[1] > InpRSI_Oversold)
   {
      if(isUptrend) return 1;
   }
   
   if(rsiExtreme[2] >= InpRSI_Overbought && rsiExtreme[1] < InpRSI_Overbought)
   {
      if(isDowntrend) return -1;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| ORIGINAL STRATEGY 5: MACD TREND FOLLOWING                         |
//+------------------------------------------------------------------+
int SignalMACD_Trend()
{
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   
   bool isUptrend = close1 > trendEMA[1];
   bool isDowntrend = close1 < trendEMA[1];
   
   bool momentumUp = momentum[1] > 100.0;
   bool momentumDown = momentum[1] < 100.0;
   
   double macd1 = macdMain[1];
   double macd2 = macdMain[2];
   double sig1  = macdSignal[1];
   double sig2  = macdSignal[2];
   
   if(macd2 <= sig2 && macd1 > sig1)
   {
      if(isUptrend && momentumUp) return 1;
   }
   
   if(macd2 >= sig2 && macd1 < sig1)
   {
      if(isDowntrend && momentumDown) return -1;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| ORIGINAL STRATEGY 6: BOLLINGER SQUEEZE                            |
//+------------------------------------------------------------------+
int SignalBollinger_Squeeze()
{
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
   double atr    = atrValues[1];
   
   double avgATR = 0;
   for(int i = 1; i <= 10; i++)
      avgATR += atrValues[i];
   avgATR /= 10;
   
   double currentWidth = bbUpper[1] - bbLower[1];
   bool wasSqueeze = true;
   for(int i = 2; i <= InpBB_SqueezeBars + 1; i++)
   {
      double width = bbUpper[i] - bbLower[i];
      if(width >= currentWidth)
      {
         wasSqueeze = false;
         break;
      }
   }
   
   bool expanding = (atr > avgATR * InpBB_ExpandATR);
   
   if(wasSqueeze && expanding)
   {
      if(close1 > bbUpper[1] && close2 <= bbUpper[2])
         return 1;
      if(close1 < bbLower[1] && close2 >= bbLower[2])
         return -1;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| NEW STRATEGY 7: HEIKIN ASHI BREAKOUT                              |
//| Logic: Smooth candle direction + breakout of previous HA high/low |
//+------------------------------------------------------------------+
int SignalHeikinAshi()
{
   double open1  = iOpen(_Symbol, PERIOD_CURRENT, 1);
   double high1  = iHigh(_Symbol, PERIOD_CURRENT, 1);
   double low1   = iLow(_Symbol, PERIOD_CURRENT, 1);
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   
   double open2  = iOpen(_Symbol, PERIOD_CURRENT, 2);
   double high2  = iHigh(_Symbol, PERIOD_CURRENT, 2);
   double low2   = iLow(_Symbol, PERIOD_CURRENT, 2);
   double close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
   
   double open3  = iOpen(_Symbol, PERIOD_CURRENT, 3);
   double high3  = iHigh(_Symbol, PERIOD_CURRENT, 3);
   double low3   = iLow(_Symbol, PERIOD_CURRENT, 3);
   double close3 = iClose(_Symbol, PERIOD_CURRENT, 3);
   
   // Calculate Heikin Ashi candles
   double haClose2 = (open2 + high2 + low2 + close2) / 4.0;
   double haOpen2  = (open3 + (open3 + high3 + low3 + close3) / 4.0) / 2.0;
   
   double haClose1 = (open1 + high1 + low1 + close1) / 4.0;
   double haOpen1  = (open2 + haClose2) / 2.0;
   
   double haHigh1 = MathMax(high1, MathMax(haOpen1, haClose1));
   double haLow1  = MathMin(low1, MathMin(haOpen1, haClose1));
   
   double haHigh2 = MathMax(high2, MathMax(haOpen2, haClose2));
   double haLow2  = MathMin(low2, MathMin(haOpen2, haClose2));
   
   // HA is bullish when close > open (green candle)
   bool haBullish1 = haClose1 > haOpen1;
   bool haBearish1 = haClose1 < haOpen1;
   bool haBullish2 = haClose2 > haOpen2;
   bool haBearish2 = haClose2 < haOpen2;
   
   double atr = atrValues[1];
   
   // BUY: HA turns bullish + price breaks above previous HA high
   if(haBullish1 && haBearish2 && close1 > haHigh2)
   {
      // Confirm with EMA trend
      if(close1 > trendEMA[1])
         return 1;
   }
   
   // SELL: HA turns bearish + price breaks below previous HA low
   if(haBearish1 && haBullish2 && close1 < haLow2)
   {
      if(close1 < trendEMA[1])
         return -1;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| NEW STRATEGY 8: DONCHIAN CHANNEL BREAKOUT                         |
//| Logic: Price breaks Donchian high/low + ADX trend filter          |
//+------------------------------------------------------------------+
int SignalDonchian()
{
   // Find Donchian channel (highest high / lowest low over period)
   int highestBar = iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, InpDonchian_Period, 2);
   int lowestBar  = iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, InpDonchian_Period, 2);
   
   double dcHigh = iHigh(_Symbol, PERIOD_CURRENT, highestBar);
   double dcLow  = iLow(_Symbol, PERIOD_CURRENT, lowestBar);
   
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
   
   // ADX trend filter
   bool trending = adxValues[1] > InpADX_Threshold_DC;
   bool bullTrend = plusDI[1] > minusDI[1];
   bool bearTrend = minusDI[1] > plusDI[1];
   
   // BUY: Break above Donchian high + ADX trending + bullish DI
   if(close1 > dcHigh && close2 <= dcHigh)
   {
      if(trending && bullTrend)
         return 1;
   }
   
   // SELL: Break below Donchian low + ADX trending + bearish DI
   if(close1 < dcLow && close2 >= dcLow)
   {
      if(trending && bearTrend)
         return -1;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| NEW STRATEGY 9: GOLDEN/DEATH CROSS                                |
//| Logic: Fast EMA crosses Slow EMA with candle confirmation         |
//+------------------------------------------------------------------+
int SignalGoldenCross()
{
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double open1  = iOpen(_Symbol, PERIOD_CURRENT, 1);
   
   // Check for crossover
   bool goldenCross = (gcFastEMA[2] <= gcSlowEMA[2] && gcFastEMA[1] > gcSlowEMA[1]);
   bool deathCross  = (gcFastEMA[2] >= gcSlowEMA[2] && gcFastEMA[1] < gcSlowEMA[1]);
   
   // Candle confirmation (bullish/bearish candle)
   bool bullishCandle = close1 > open1;
   bool bearishCandle = close1 < open1;
   
   // Count confirmation candles
   int bullConfirm = 0;
   int bearConfirm = 0;
   for(int i = 1; i <= InpGC_ConfirmBars; i++)
   {
      double c = iClose(_Symbol, PERIOD_CURRENT, i);
      double o = iOpen(_Symbol, PERIOD_CURRENT, i);
      if(c > o) bullConfirm++;
      if(c < o) bearConfirm++;
   }
   
   // BUY: Golden Cross + bullish confirmation
   if(goldenCross && bullConfirm >= 2)
      return 1;
   
   // SELL: Death Cross + bearish confirmation
   if(deathCross && bearConfirm >= 2)
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| NEW STRATEGY 10: ADVANCED DIVERGENCE                              |
//| Logic: RSI/MACD divergence at swing points (Class A only)         |
//+------------------------------------------------------------------+
int SignalDivergence()
{
   // Find swing highs and lows
   int swingHighBar = -1, swingLowBar = -1;
   double swingHighPrice = 0, swingLowPrice = 999999;
   
   // Look for swing high (highest price in lookback)
   for(int i = 2; i <= InpDiv_Lookback; i++)
   {
      double h = iHigh(_Symbol, PERIOD_CURRENT, i);
      if(h > swingHighPrice)
      {
         swingHighPrice = h;
         swingHighBar = i;
      }
   }
   
   // Look for swing low (lowest price in lookback)
   for(int i = 2; i <= InpDiv_Lookback; i++)
   {
      double l = iLow(_Symbol, PERIOD_CURRENT, i);
      if(l < swingLowPrice)
      {
         swingLowPrice = l;
         swingLowBar = i;
      }
   }
   
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double high1  = iHigh(_Symbol, PERIOD_CURRENT, 1);
   double low1   = iLow(_Symbol, PERIOD_CURRENT, 1);
   
   // Bearish Divergence (Class A): Price makes higher high, RSI makes lower high
   if(high1 > swingHighPrice && swingHighBar > 0)
   {
      if(divRSI[1] < divRSI[swingHighBar])
      {
         double swingSize = (high1 - swingHighPrice) / _Point;
         if(swingSize >= InpDiv_MinSwing)
         {
            // Confirm with candlestick
            if(close1 < iOpen(_Symbol, PERIOD_CURRENT, 1))
               return -1;
         }
      }
   }
   
   // Bullish Divergence (Class A): Price makes lower low, RSI makes higher low
   if(low1 < swingLowPrice && swingLowBar > 0)
   {
      if(divRSI[1] > divRSI[swingLowBar])
      {
         double swingSize = (swingLowPrice - low1) / _Point;
         if(swingSize >= InpDiv_MinSwing)
         {
            if(close1 > iOpen(_Symbol, PERIOD_CURRENT, 1))
               return 1;
         }
      }
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| NEW STRATEGY 11: SMART MONEY CONCEPTS (Simplified)                |
//| Logic: Order blocks + Kill zones + Liquidity grabs                |
//+------------------------------------------------------------------+
int SignalSMC()
{
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
   double open1  = iOpen(_Symbol, PERIOD_CURRENT, 1);
   double open2  = iOpen(_Symbol, PERIOD_CURRENT, 2);
   double high1  = iHigh(_Symbol, PERIOD_CURRENT, 1);
   double low1   = iLow(_Symbol, PERIOD_CURRENT, 1);
   double high2  = iHigh(_Symbol, PERIOD_CURRENT, 2);
   double low2   = iLow(_Symbol, PERIOD_CURRENT, 2);
   
   // Kill Zone filter (London or NY session)
   MqlDateTime dt;
   TimeCurrent(dt);
   bool inKillZone = false;
   if((dt.hour >= InpSMC_KillZone_Start && dt.hour < InpSMC_KillZone_End) ||
      (dt.hour >= InpNYStart && dt.hour < InpNYEnd))
      inKillZone = true;
   
   if(!inKillZone) return 0;
   
   // Find Order Block (OB): last bearish candle before bullish move, or vice versa
   double obHigh = 0, obLow = 999999;
   int obType = 0; // 1 = bullish OB, -1 = bearish OB
   
   // Bullish OB: Find last bearish candle before current bullish move
   for(int i = 2; i <= InpSMC_OB_Lookback; i++)
   {
      double c = iClose(_Symbol, PERIOD_CURRENT, i);
      double o = iOpen(_Symbol, PERIOD_CURRENT, i);
      
      if(c < o) // Bearish candle (potential bullish OB)
      {
         // Check if price moved up after this candle
         double nextC = iClose(_Symbol, PERIOD_CURRENT, i - 1);
         if(nextC > o) // Bullish move after
         {
            obHigh = iHigh(_Symbol, PERIOD_CURRENT, i);
            obLow = iLow(_Symbol, PERIOD_CURRENT, i);
            obType = 1;
            break;
         }
      }
   }
   
   // Bearish OB: Find last bullish candle before current bearish move
   if(obType == 0)
   {
      for(int i = 2; i <= InpSMC_OB_Lookback; i++)
      {
         double c = iClose(_Symbol, PERIOD_CURRENT, i);
         double o = iOpen(_Symbol, PERIOD_CURRENT, i);
         
         if(c > o) // Bullish candle (potential bearish OB)
         {
            double nextC = iClose(_Symbol, PERIOD_CURRENT, i - 1);
            if(nextC < o) // Bearish move after
            {
               obHigh = iHigh(_Symbol, PERIOD_CURRENT, i);
               obLow = iLow(_Symbol, PERIOD_CURRENT, i);
               obType = -1;
               break;
            }
         }
      }
   }
   
   if(obType == 0) return 0;
   
   // BUY: Price returns to bullish OB + bullish candle
   if(obType == 1)
   {
      if(low1 <= obHigh && close1 > obHigh && close1 > open1)
      {
         // Liquidity grab: swept below previous low then reversed
         double prevLow = iLow(_Symbol, PERIOD_CURRENT, iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, 10, 2));
         if(low2 <= prevLow + 10 * _Point && close1 > close2)
            return 1;
      }
   }
   
   // SELL: Price returns to bearish OB + bearish candle
   if(obType == -1)
   {
      if(high1 >= obLow && close1 < obLow && close1 < open1)
      {
         double prevHigh = iHigh(_Symbol, PERIOD_CURRENT, iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, 10, 2));
         if(high2 >= prevHigh - 10 * _Point && close1 < close2)
            return -1;
      }
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| FILTER: ADX TREND FILTER                                          |
//| Logic: Only trade when ADX > threshold (trending market)          |
//+------------------------------------------------------------------+
bool PassesADXFilter()
{
   if(adxValues[1] < InpADX_TrendLevel)
      return false;
   if(plusDI[1] > minusDI[1]) return true;
   if(minusDI[1] > plusDI[1]) return true;
   return false;
}

//+------------------------------------------------------------------+
//| FILTER: MULTI-TIMEFRAME CONFIRMATION                              |
//| Logic: Current TF entry must align with M15 + H1 trend           |
//+------------------------------------------------------------------+
bool PassesMultiTFFilter()
{
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   bool mtf1Bull = close1 > mtf1EMA[0];
   bool mtf1Bear = close1 < mtf1EMA[0];
   bool mtf2Bull = close1 > mtf2EMA[0];
   bool mtf2Bear = close1 < mtf2EMA[0];
   
   if(mtf1Bull && mtf2Bull) return true;
   if(mtf1Bear && mtf2Bear) return true;
   return false;
}

//+------------------------------------------------------------------+
//| FILTER: VOLUME FILTER                                             |
//+------------------------------------------------------------------+
bool PassesVolumeFilter()
{
   long vol1 = iVolume(_Symbol, PERIOD_CURRENT, 0);
   double avgVol = 0;
   for(int i = 1; i <= 20; i++)
      avgVol += (double)iVolume(_Symbol, PERIOD_CURRENT, i);
   avgVol /= 20;
   if((double)vol1 > avgVol * 0.8) return true;
   return false;
}

//+------------------------------------------------------------------+
//| EXIT MANAGEMENT: Breakeven + Trailing Stop + Partial Close        |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket <= 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);
      double currentTP = PositionGetDouble(POSITION_TP);
      double volume    = PositionGetDouble(POSITION_VOLUME);
      long   posType   = PositionGetInteger(POSITION_TYPE);
      double atr       = atrValues[1];
      
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      
      double profitPoints = 0;
      if(posType == POSITION_TYPE_BUY)
         profitPoints = (bid - openPrice) / _Point;
      else
         profitPoints = (openPrice - ask) / _Point;
      
      double slDistance    = atr * InpSLMultiplier;
      double beThreshold   = slDistance * InpBreakevenATR / _Point;
      double partialTarget = slDistance * InpPartialCloseRR / _Point;
      double trailDistance = atr * InpTrailATRMulti;
      
      // --- PARTIAL CLOSE ---
      if(InpUsePartialClose && volume > SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
      {
         string comment = PositionGetString(POSITION_COMMENT);
         if(StringFind(comment, "PC") < 0 && profitPoints >= partialTarget)
         {
            double closeLots = NormalizeDouble(volume * InpPartialClosePct / 100.0, 2);
            double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
            double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
            closeLots = MathFloor(closeLots / lotStep) * lotStep;
            
            if(closeLots >= minLot)
            {
               MqlTradeRequest req = {};
               MqlTradeResult  res = {};
               req.action    = TRADE_ACTION_DEAL;
               req.symbol    = _Symbol;
               req.position  = ticket;
               req.volume    = closeLots;
               req.deviation = 10;
               
               if(posType == POSITION_TYPE_BUY)
               { req.type = ORDER_TYPE_SELL; req.price = bid; }
               else
               { req.type = ORDER_TYPE_BUY;  req.price = ask; }
               
               if(OrderSend(req, res) && res.retcode == TRADE_RETCODE_DONE)
                  Print("Partial Close: ", closeLots, " lots at ", profitPoints, " pts profit");
            }
         }
      }
      
      // --- BREAKEVEN ---
      if(InpUseBreakeven)
      {
         double newSL = 0;
         bool shouldMove = false;
         
         if(posType == POSITION_TYPE_BUY)
         {
            newSL = openPrice + 10 * _Point;
            if(bid >= openPrice + beThreshold * _Point && currentSL < newSL)
               shouldMove = true;
         }
         else
         {
            newSL = openPrice - 10 * _Point;
            if(ask <= openPrice - beThreshold * _Point && (currentSL > newSL || currentSL == 0))
               shouldMove = true;
         }
         
         if(shouldMove)
         {
            MqlTradeRequest req = {};
            MqlTradeResult  res = {};
            req.action   = TRADE_ACTION_SLTP;
            req.symbol   = _Symbol;
            req.position = ticket;
            req.sl       = NormalizeDouble(newSL, _Digits);
            req.tp       = currentTP;
            if(OrderSend(req, res) && res.retcode == TRADE_RETCODE_DONE)
               Print("Breakeven set for #", ticket, " SL=", newSL);
         }
      }
      
      // --- TRAILING STOP ---
      if(InpUseTrailingStop)
      {
         double newSL = 0;
         bool shouldTrail = false;
         
         if(posType == POSITION_TYPE_BUY)
         {
            newSL = bid - trailDistance;
            if(newSL > currentSL && newSL > openPrice && profitPoints > beThreshold)
               shouldTrail = true;
         }
         else
         {
            newSL = ask + trailDistance;
            if((newSL < currentSL || currentSL == 0) && newSL < openPrice && profitPoints > beThreshold)
               shouldTrail = true;
         }
         
         if(shouldTrail)
         {
            MqlTradeRequest req = {};
            MqlTradeResult  res = {};
            req.action   = TRADE_ACTION_SLTP;
            req.symbol   = _Symbol;
            req.position = ticket;
            req.sl       = NormalizeDouble(newSL, _Digits);
            req.tp       = currentTP;
            if(OrderSend(req, res) && res.retcode == TRADE_RETCODE_DONE)
               Print("Trailing Stop updated for #", ticket, " SL=", newSL);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| TRADE EXECUTION: Open BUY                                         |
//+------------------------------------------------------------------+
bool OpenBuy(string comment)
{
   double atr = atrValues[1];
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double sl  = ask - (atr * InpSLMultiplier);
   double tp  = ask + (atr * InpTPMultiplier);
   double lotSize = CalculateLotSize(atr * InpSLMultiplier);
   return ExecuteTrade(ORDER_TYPE_BUY, ask, sl, tp, lotSize, comment);
}

//+------------------------------------------------------------------+
//| TRADE EXECUTION: Open SELL                                        |
//+------------------------------------------------------------------+
bool OpenSell(string comment)
{
   double atr = atrValues[1];
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl  = bid + (atr * InpSLMultiplier);
   double tp  = bid - (atr * InpTPMultiplier);
   double lotSize = CalculateLotSize(atr * InpSLMultiplier);
   return ExecuteTrade(ORDER_TYPE_SELL, bid, sl, tp, lotSize, comment);
}

//+------------------------------------------------------------------+
//| TRADE EXECUTION: Execute trade                                    |
//+------------------------------------------------------------------+
bool ExecuteTrade(ENUM_ORDER_TYPE type, double price, double sl, double tp, double lotSize, string comment)
{
   MqlTradeRequest request = {};
   MqlTradeResult  result  = {};
   request.action    = TRADE_ACTION_DEAL;
   request.symbol    = _Symbol;
   request.volume    = lotSize;
   request.type      = type;
   request.price     = NormalizeDouble(price, _Digits);
   request.sl        = NormalizeDouble(sl, _Digits);
   request.tp        = NormalizeDouble(tp, _Digits);
   request.deviation = 10;
   request.magic     = InpMagicNumber;
   request.comment   = comment;
   
   if(!OrderSend(request, result))
   {
      Print("ERROR: Order failed - ", result.retcode);
      return false;
   }
   
   if(result.retcode == TRADE_RETCODE_DONE || result.retcode == TRADE_RETCODE_DONE_PARTIAL)
   {
      Print(type == ORDER_TYPE_BUY ? "BUY" : "SELL", " Opened: Lot=", lotSize,
            " SL=", sl, " TP=", tp, " Reason=", comment);
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| POSITION SIZING                                                   |
//+------------------------------------------------------------------+
double CalculateLotSize(double slDistance)
{
   double balance    = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * InpRiskPercent / 100.0;
   double tickSize   = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   
   if(tickSize == 0 || tickValue == 0)
      return SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   
   double slTicks = slDistance / tickSize;
   double lotSize = riskAmount / (slTicks * tickValue);
   
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
   return NormalizeDouble(lotSize, 2);
}

//+------------------------------------------------------------------+
//| POSITION COUNTER                                                  |
//+------------------------------------------------------------------+
int CountPositions(ENUM_ORDER_TYPE type)
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
         {
            if(type == ORDER_TYPE_BUY && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
               count++;
            else if(type == ORDER_TYPE_SELL && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
               count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| CLOSE POSITIONS                                                   |
//+------------------------------------------------------------------+
void ClosePositions(ENUM_ORDER_TYPE type)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket <= 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      
      bool shouldClose = false;
      if(type == ORDER_TYPE_BUY && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         shouldClose = true;
      else if(type == ORDER_TYPE_SELL && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
         shouldClose = true;
      
      if(shouldClose)
      {
         MqlTradeRequest request = {};
         MqlTradeResult  result  = {};
         request.action    = TRADE_ACTION_DEAL;
         request.symbol    = _Symbol;
         request.position  = ticket;
         request.deviation = 10;
         request.volume    = PositionGetDouble(POSITION_VOLUME);
         
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         { request.type = ORDER_TYPE_SELL; request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID); }
         else
         { request.type = ORDER_TYPE_BUY;  request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK); }
         
         if(OrderSend(request, result) && result.retcode == TRADE_RETCODE_DONE)
            Print("Closed position #", ticket);
      }
   }
}

//+------------------------------------------------------------------+
//| SESSION FILTER: London + NY sessions only                         |
//+------------------------------------------------------------------+
bool IsSessionTime()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   if(dt.day_of_week == 0 || dt.day_of_week == 6) return false;
   if(dt.hour >= InpLondonStart && dt.hour < InpLondonEnd) return true;
   if(dt.hour >= InpNYStart && dt.hour < InpNYEnd) return true;
   return false;
}

//+------------------------------------------------------------------+
//| SPREAD FILTER                                                     |
//+------------------------------------------------------------------+
bool IsSpreadOK()
{
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   return (spread <= InpMaxSpread);
}
//+------------------------------------------------------------------+
