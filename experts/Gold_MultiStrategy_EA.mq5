//+------------------------------------------------------------------+
//|                                      Gold_MultiStrategy_EA.mq5    |
//|                                      Multi-Strategy Gold Trading  |
//|                                      Combines 6 proven strategies |
//+------------------------------------------------------------------+
#property copyright "Based on 326 MQL5 Gold Articles Analysis"
#property link      ""
#property version   "1.00"
#property description "Multi-Strategy EA for XAUUSDc"
#property description "Combines trend-following, breakout, and reversal strategies"
#property description "Signals vote: trade when enough strategies agree"

//+------------------------------------------------------------------+
//| STRATEGY TOGGLES                                                  |
//+------------------------------------------------------------------+
input group "=== STRATEGY TOGGLES ==="
input bool     InpUseEMA_RSI         = true;          // EMA RSI Crossover
input bool     InpUseTrendSR         = true;          // Trend + S/R Bounce
input bool     InpUseBreakout        = true;          // Price Breakout
input bool     InpUseRSI_Extreme     = true;          // RSI Extreme Reversal
input bool     InpUseMACD_Trend      = true;          // MACD Trend Following
input bool     InpUseBollinger_Sq    = true;          // Bollinger Squeeze

//+------------------------------------------------------------------+
//| SIGNAL AGGREGATION                                                |
//+------------------------------------------------------------------+
input group "=== SIGNAL AGGREGATION ==="
input int      InpMinBuySignals      = 2;             // Min signals for BUY (1-6)
input int      InpMinSellSignals     = 2;             // Min signals for SELL (1-6)

//+------------------------------------------------------------------+
//| EMA RSI SETTINGS                                                  |
//+------------------------------------------------------------------+
input group "=== EMA RSI ==="
input int      InpEMA_Fast           = 21;            // Fast EMA
input int      InpEMA_Slow           = 50;            // Slow EMA
input int      InpRSI_Period         = 14;            // RSI Period
input int      InpRSI_BuyLevel       = 40;            // RSI Buy Above
input int      InpRSI_SellLevel      = 60;            // RSI Sell Below

//+------------------------------------------------------------------+
//| TREND S/R SETTINGS                                                |
//+------------------------------------------------------------------+
input group "=== TREND S/R ==="
input int      InpTrendEMA           = 200;           // Trend EMA Period
input int      InpSRPeriod           = 20;            // S/R Lookback Period
input int      InpSRZone             = 500;           // S/R Zone Size (points)
input int      InpFastEMA_SR         = 21;            // Fast EMA (S/R)
input int      InpSlowEMA_SR         = 50;            // Slow EMA (S/R)

//+------------------------------------------------------------------+
//| BREAKOUT SETTINGS                                                 |
//+------------------------------------------------------------------+
input group "=== BREAKOUT ==="
input int      InpBreakoutLookback   = 20;            // Lookback Period
input double   InpBreakoutSize       = 100;           // Min Breakout Size (points)
input double   InpATRMultiplier      = 1.5;           // ATR Multiplier for Breakout

//+------------------------------------------------------------------+
//| RSI EXTREME SETTINGS                                              |
//+------------------------------------------------------------------+
input group "=== RSI EXTREME ==="
input int      InpRSI_Period_Ext     = 14;            // RSI Period
input int      InpRSI_Oversold       = 30;            // RSI Oversold Level
input int      InpRSI_Overbought     = 70;            // RSI Overbought Level

//+------------------------------------------------------------------+
//| MACD TREND SETTINGS                                               |
//+------------------------------------------------------------------+
input group "=== MACD TREND ==="
input int      InpMACDFast           = 12;            // MACD Fast EMA
input int      InpMACDSlow           = 26;            // MACD Slow EMA
input int      InpMACDSignal         = 9;             // MACD Signal Line
input int      InpMomentumPeriod     = 14;            // Momentum Period

//+------------------------------------------------------------------+
//| BOLLINGER SQUEEZE SETTINGS                                        |
//+------------------------------------------------------------------+
input group "=== BOLLINGER SQUEEZE ==="
input int      InpBB_Period          = 20;            // BB Period
input double   InpBB_Deviation       = 2.0;           // BB Deviation
input int      InpBB_SqueezeBars     = 6;             // Squeeze Detection Bars
input double   InpBB_ExpandATR       = 1.2;           // Expansion ATR Threshold

//+------------------------------------------------------------------+
//| RISK MANAGEMENT                                                   |
//+------------------------------------------------------------------+
input group "=== RISK MANAGEMENT ==="
input double   InpRiskPercent        = 1.0;           // Risk Per Trade (%)
input double   InpSLMultiplier       = 2.0;           // SL (ATR Multiplier)
input double   InpTPMultiplier       = 3.0;           // TP (ATR Multiplier)
input int      InpMaxPositions       = 2;             // Max Open Positions

//+------------------------------------------------------------------+
//| TRADING HOURS                                                     |
//+------------------------------------------------------------------+
input group "=== TRADING HOURS ==="
input int      InpStartHour          = 1;             // Trading Start Hour
input int      InpEndHour            = 23;            // Trading End Hour

//+------------------------------------------------------------------+
//| GENERAL SETTINGS                                                  |
//+------------------------------------------------------------------+
input group "=== GENERAL ==="
input ulong    InpMagicNumber        = 999999;        // Magic Number
input string   InpTradeComment       = "MultiStrat";  // Trade Comment

//+------------------------------------------------------------------+
//| INDICATOR HANDLES                                                 |
//+------------------------------------------------------------------+
int handleEMA_Fast;
int handleEMA_Slow;
int handleRSI;
int handleTrendEMA;
int handleFastEMA_SR;
int handleSlowEMA_SR;
int handleATR;
int handleBreakoutEMA;
int handleRSI_Extreme;
int handleMACD;
int handleMomentum;
int handleBB;
int handleMomentum_SR;

//+------------------------------------------------------------------+
//| INDICATOR BUFFERS                                                 |
//+------------------------------------------------------------------+
double emaFast[];
double emaSlow[];
double rsiValues[];
double trendEMA[];
double fastEMA_SR[];
double slowEMA_SR[];
double atrValues[];
double breakoutEMA[];
double rsiExtreme[];
double macdMain[];
double macdSignal[];
double macdHistogram[];
double momentum[];
double bbUpper[];
double bbMiddle[];
double bbLower[];
double momentum_SR[];

//+------------------------------------------------------------------+
//| INITIALIZATION                                                    |
//+------------------------------------------------------------------+
int OnInit()
{
   // EMA RSI
   handleEMA_Fast    = iMA(_Symbol, PERIOD_CURRENT, InpEMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
   handleEMA_Slow    = iMA(_Symbol, PERIOD_CURRENT, InpEMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
   handleRSI         = iRSI(_Symbol, PERIOD_CURRENT, InpRSI_Period, PRICE_CLOSE);
   
   // Trend S/R
   handleTrendEMA    = iMA(_Symbol, PERIOD_CURRENT, InpTrendEMA, 0, MODE_EMA, PRICE_CLOSE);
   handleFastEMA_SR  = iMA(_Symbol, PERIOD_CURRENT, InpFastEMA_SR, 0, MODE_EMA, PRICE_CLOSE);
   handleSlowEMA_SR  = iMA(_Symbol, PERIOD_CURRENT, InpSlowEMA_SR, 0, MODE_EMA, PRICE_CLOSE);
   handleMomentum_SR = iMomentum(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
   
   // Breakout
   handleBreakoutEMA = iMA(_Symbol, PERIOD_CURRENT, 100, 0, MODE_EMA, PRICE_CLOSE);
   handleATR         = iATR(_Symbol, PERIOD_CURRENT, 14);
   
   // RSI Extreme
   handleRSI_Extreme = iRSI(_Symbol, PERIOD_CURRENT, InpRSI_Period_Ext, PRICE_CLOSE);
   
   // MACD Trend
   handleMACD        = iMACD(_Symbol, PERIOD_CURRENT, InpMACDFast, InpMACDSlow, InpMACDSignal, PRICE_CLOSE);
   handleMomentum    = iMomentum(_Symbol, PERIOD_CURRENT, InpMomentumPeriod, PRICE_CLOSE);
   
   // Bollinger Squeeze
   handleBB          = iBands(_Symbol, PERIOD_CURRENT, InpBB_Period, 0, InpBB_Deviation, PRICE_CLOSE);
   
   // Validate all handles
   if(handleEMA_Fast == INVALID_HANDLE || handleEMA_Slow == INVALID_HANDLE ||
      handleRSI == INVALID_HANDLE || handleTrendEMA == INVALID_HANDLE ||
      handleFastEMA_SR == INVALID_HANDLE || handleSlowEMA_SR == INVALID_HANDLE ||
      handleATR == INVALID_HANDLE || handleBreakoutEMA == INVALID_HANDLE ||
      handleRSI_Extreme == INVALID_HANDLE || handleMACD == INVALID_HANDLE ||
      handleMomentum == INVALID_HANDLE || handleBB == INVALID_HANDLE ||
      handleMomentum_SR == INVALID_HANDLE)
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
   
   Print("=== Gold Multi-Strategy EA Initialized ===");
   Print("Min Buy Signals: ", InpMinBuySignals, " | Min Sell Signals: ", InpMinSellSignals);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| DEINITIALIZATION                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
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
}

//+------------------------------------------------------------------+
//| MAIN TICK FUNCTION                                                |
//+------------------------------------------------------------------+
void OnTick()
{
   static datetime lastBar = 0;
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(lastBar == currentBar) return;
   lastBar = currentBar;
   
   if(!IsTradeTime()) return;
   if(!GetIndicatorValues()) return;
   
   // Collect all signals
   int buySignals = 0;
   int sellSignals = 0;
   string buyReasons = "";
   string sellReasons = "";
   
   // 1. EMA RSI Crossover
   if(InpUseEMA_RSI)
   {
      int sig = SignalEMA_RSI();
      if(sig == 1)      { buySignals++;  buyReasons  += "EMA_RSI,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "EMA_RSI,"; }
   }
   
   // 2. Trend S/R Bounce
   if(InpUseTrendSR)
   {
      int sig = SignalTrendSR();
      if(sig == 1)      { buySignals++;  buyReasons  += "Trend_SR,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "Trend_SR,"; }
   }
   
   // 3. Price Breakout
   if(InpUseBreakout)
   {
      int sig = SignalBreakout();
      if(sig == 1)      { buySignals++;  buyReasons  += "Breakout,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "Breakout,"; }
   }
   
   // 4. RSI Extreme Reversal
   if(InpUseRSI_Extreme)
   {
      int sig = SignalRSI_Extreme();
      if(sig == 1)      { buySignals++;  buyReasons  += "RSI_Ext,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "RSI_Ext,"; }
   }
   
   // 5. MACD Trend Following
   if(InpUseMACD_Trend)
   {
      int sig = SignalMACD_Trend();
      if(sig == 1)      { buySignals++;  buyReasons  += "MACD,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "MACD,"; }
   }
   
   // 6. Bollinger Squeeze
   if(InpUseBollinger_Sq)
   {
      int sig = SignalBollinger_Squeeze();
      if(sig == 1)      { buySignals++;  buyReasons  += "BB_Sq,"; }
      else if(sig == -1) { sellSignals++; sellReasons += "BB_Sq,"; }
   }
   
   // Execute trades based on signal count
   if(buySignals >= InpMinBuySignals && CountPositions(ORDER_TYPE_BUY) < InpMaxPositions)
   {
      ClosePositions(ORDER_TYPE_SELL);
      string comment = InpTradeComment + ":" + StringSubstr(buyReasons, 0, StringLen(buyReasons)-1);
      OpenBuy(comment);
      Print("BUY [", buySignals, " signals]: ", buyReasons);
   }
   else if(sellSignals >= InpMinSellSignals && CountPositions(ORDER_TYPE_SELL) < InpMaxPositions)
   {
      ClosePositions(ORDER_TYPE_BUY);
      string comment = InpTradeComment + ":" + StringSubstr(sellReasons, 0, StringLen(sellReasons)-1);
      OpenSell(comment);
      Print("SELL [", sellSignals, " signals]: ", sellReasons);
   }
}

//+------------------------------------------------------------------+
//| GET ALL INDICATOR VALUES                                          |
//+------------------------------------------------------------------+
bool GetIndicatorValues()
{
   // EMA RSI
   if(CopyBuffer(handleEMA_Fast, 0, 0, 5, emaFast) < 5) return false;
   if(CopyBuffer(handleEMA_Slow, 0, 0, 5, emaSlow) < 5) return false;
   if(CopyBuffer(handleRSI, 0, 0, 5, rsiValues) < 5) return false;
   
   // Trend S/R
   if(CopyBuffer(handleTrendEMA, 0, 0, 5, trendEMA) < 5) return false;
   if(CopyBuffer(handleFastEMA_SR, 0, 0, 5, fastEMA_SR) < 5) return false;
   if(CopyBuffer(handleSlowEMA_SR, 0, 0, 5, slowEMA_SR) < 5) return false;
   if(CopyBuffer(handleMomentum_SR, 0, 0, 5, momentum_SR) < 5) return false;
   
   // Breakout + ATR
   if(CopyBuffer(handleBreakoutEMA, 0, 0, 5, breakoutEMA) < 5) return false;
   if(CopyBuffer(handleATR, 0, 0, 12, atrValues) < 12) return false;
   
   // RSI Extreme
   if(CopyBuffer(handleRSI_Extreme, 0, 0, 5, rsiExtreme) < 5) return false;
   
   // MACD
   if(CopyBuffer(handleMACD, 0, 0, 6, macdMain) < 6) return false;
   if(CopyBuffer(handleMACD, 1, 0, 6, macdSignal) < 6) return false;
   if(CopyBuffer(handleMACD, 2, 0, 6, macdHistogram) < 6) return false;
   if(CopyBuffer(handleMomentum, 0, 0, 5, momentum) < 5) return false;
   
   // Bollinger
   if(CopyBuffer(handleBB, 0, 0, InpBB_SqueezeBars + 3, bbUpper) < InpBB_SqueezeBars + 3) return false;
   if(CopyBuffer(handleBB, 1, 0, InpBB_SqueezeBars + 3, bbMiddle) < InpBB_SqueezeBars + 3) return false;
   if(CopyBuffer(handleBB, 2, 0, InpBB_SqueezeBars + 3, bbLower) < InpBB_SqueezeBars + 3) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| STRATEGY 1: EMA RSI CROSSOVER                                     |
//| Logic: Fast EMA crosses Slow EMA + RSI confirmation               |
//+------------------------------------------------------------------+
int SignalEMA_RSI()
{
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   
   // EMA crossover
   bool emaCrossUp   = (emaFast[2] <= emaSlow[2] && emaFast[1] > emaSlow[1]);
   bool emaCrossDown = (emaFast[2] >= emaSlow[2] && emaFast[1] < emaSlow[1]);
   
   // RSI confirmation
   if(emaCrossUp && rsiValues[1] > InpRSI_BuyLevel && close1 > emaFast[1])
      return 1;
   
   if(emaCrossDown && rsiValues[1] < InpRSI_SellLevel && close1 < emaFast[1])
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| STRATEGY 2: TREND + S/R BOUNCE                                    |
//| Logic: Price bounces off S/R in trend direction                   |
//+------------------------------------------------------------------+
int SignalTrendSR()
{
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
   double open1  = iOpen(_Symbol, PERIOD_CURRENT, 1);
   
   // Trend direction
   int trend = 0;
   if(close1 > trendEMA[1]) trend = 1;
   else if(close1 < trendEMA[1]) trend = -1;
   if(trend == 0) return 0;
   
   // Find S/R levels
   int highestBar = iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, InpSRPeriod, 2);
   int lowestBar  = iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, InpSRPeriod, 2);
   double high1   = iHigh(_Symbol, PERIOD_CURRENT, highestBar);
   double low1    = iLow(_Symbol, PERIOD_CURRENT, lowestBar);
   
   double zoneSize = InpSRZone * _Point;
   
   // BUY: Uptrend + bounce off support
   if(trend == 1)
   {
      if(close1 <= low1 + zoneSize && close1 > open1 && close1 > close2)
      {
         if(fastEMA_SR[1] > slowEMA_SR[1])
            return 1;
      }
   }
   
   // SELL: Downtrend + rejection at resistance
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
//| STRATEGY 3: PRICE BREAKOUT                                        |
//| Logic: Breakout of N-bar high/low with ATR confirmation           |
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
   
   // Calculate average ATR
   double avgATR = 0;
   for(int i = 1; i <= 10; i++)
      avgATR += atrValues[i];
   avgATR /= 10;
   
   // BUY: Breakout above resistance
   if(close1 > recentHigh && close2 <= recentHigh)
   {
      double breakoutSize = close1 - recentHigh;
      bool isUptrend = close1 > breakoutEMA[1];
      
      if(breakoutSize >= minBreakout && isUptrend && atr > avgATR * InpATRMultiplier)
         return 1;
   }
   
   // SELL: Breakdown below support
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
//| STRATEGY 4: RSI EXTREME REVERSAL                                  |
//| Logic: RSI crosses back from overbought/oversold zones            |
//+------------------------------------------------------------------+
int SignalRSI_Extreme()
{
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   
   bool isUptrend = close1 > trendEMA[1];
   bool isDowntrend = close1 < trendEMA[1];
   
   // BUY: RSI was oversold, now crossing back up
   if(rsiExtreme[2] <= InpRSI_Oversold && rsiExtreme[1] > InpRSI_Oversold)
   {
      if(isUptrend)
         return 1;
   }
   
   // SELL: RSI was overbought, now crossing back down
   if(rsiExtreme[2] >= InpRSI_Overbought && rsiExtreme[1] < InpRSI_Overbought)
   {
      if(isDowntrend)
         return -1;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| STRATEGY 5: MACD TREND FOLLOWING                                  |
//| Logic: MACD line crossover with momentum confirmation             |
//+------------------------------------------------------------------+
int SignalMACD_Trend()
{
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   
   bool isUptrend = close1 > trendEMA[1];
   bool isDowntrend = close1 < trendEMA[1];
   
   bool momentumUp = momentum[1] > 100.0;
   bool momentumDown = momentum[1] < 100.0;
   
   // MACD line crossover
   double macd1 = macdMain[1];
   double macd2 = macdMain[2];
   double sig1  = macdSignal[1];
   double sig2  = macdSignal[2];
   
   // BUY: MACD crosses above signal
   if(macd2 <= sig2 && macd1 > sig1)
   {
      if(isUptrend && momentumUp)
         return 1;
   }
   
   // SELL: MACD crosses below signal
   if(macd2 >= sig2 && macd1 < sig1)
   {
      if(isDowntrend && momentumDown)
         return -1;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| STRATEGY 6: BOLLINGER SQUEEZE                                     |
//| Logic: Low volatility squeeze followed by breakout expansion      |
//+------------------------------------------------------------------+
int SignalBollinger_Squeeze()
{
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
   double atr    = atrValues[1];
   
   // Calculate average ATR for expansion detection
   double avgATR = 0;
   for(int i = 1; i <= 10; i++)
      avgATR += atrValues[i];
   avgATR /= 10;
   
   // Detect squeeze: narrow Bollinger Bands
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
   
   // Check for expansion after squeeze
   bool expanding = (atr > avgATR * InpBB_ExpandATR);
   
   if(wasSqueeze && expanding)
   {
      // BUY: Close above upper band after squeeze
      if(close1 > bbUpper[1] && close2 <= bbUpper[2])
         return 1;
      
      // SELL: Close below lower band after squeeze
      if(close1 < bbLower[1] && close2 >= bbLower[2])
         return -1;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| TRADE EXECUTION                                                   |
//+------------------------------------------------------------------+
bool OpenBuy(string comment)
{
   double atr = atrValues[1];
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double sl = ask - (atr * InpSLMultiplier);
   double tp = ask + (atr * InpTPMultiplier);
   double lotSize = CalculateLotSize(atr * InpSLMultiplier);
   
   return ExecuteTrade(ORDER_TYPE_BUY, ask, sl, tp, lotSize, comment);
}

//+------------------------------------------------------------------+
bool OpenSell(string comment)
{
   double atr = atrValues[1];
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl = bid + (atr * InpSLMultiplier);
   double tp = bid - (atr * InpTPMultiplier);
   double lotSize = CalculateLotSize(atr * InpSLMultiplier);
   
   return ExecuteTrade(ORDER_TYPE_SELL, bid, sl, tp, lotSize, comment);
}

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
      Print(type == ORDER_TYPE_BUY ? "BUY" : "SELL", " Opened: Lot=", lotSize, " Reason=", comment);
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| POSITION SIZING                                                   |
//+------------------------------------------------------------------+
double CalculateLotSize(double slDistance)
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * InpRiskPercent / 100.0;
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   
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
      if(ticket > 0)
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
         {
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
               {
                  request.type  = ORDER_TYPE_SELL;
                  request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               }
               else
               {
                  request.type  = ORDER_TYPE_BUY;
                  request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
               }
               
               if(OrderSend(request, result))
               {
                  if(result.retcode == TRADE_RETCODE_DONE)
                     Print("Closed position #", ticket);
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| TRADING HOURS FILTER                                              |
//+------------------------------------------------------------------+
bool IsTradeTime()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   if(dt.day_of_week == 0 || dt.day_of_week == 6) return false;
   if(dt.hour >= InpStartHour && dt.hour < InpEndHour) return true;
   return false;
}
//+------------------------------------------------------------------+
