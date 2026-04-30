//+------------------------------------------------------------------+
//|                                      Bollinger_Squeeze_EA.mq5     |
//|                                      Bollinger Bands Squeeze      |
//|                                      Based on MQL5 Article Analysis|
//+------------------------------------------------------------------+
#property copyright "Based on 326 MQL5 Gold Articles Analysis"
#property link      ""
#property version   "1.00"
#property description "Bollinger Bands Squeeze Strategy for XAUUSDc"
#property description "Trades volatility breakouts from squeeze periods"

//--- Input Parameters
input group "=== BOLLINGER SETTINGS ==="
input int      InpBBPeriod       = 20;           // BB Period
input double   InpBBDeviation    = 2.0;          // BB Deviation
input int      InpSqueezePeriod  = 10;           // Squeeze Lookback Period
input double   InpSqueezeThreshold= 0.5;         // Squeeze Threshold (% of avg width)

input group "=== KELTNER CHANNEL ==="
input bool     InpUseKeltner     = true;         // Use Keltner for Squeeze
input int      InpKeltnerPeriod  = 20;           // Keltner Period
input double   InpKeltnerATR     = 1.5;          // Keltner ATR Multiplier

input group "=== MOMENTUM ==="
input int      InpMomentumPeriod = 12;           // Momentum Period
input bool     InpUseMomentum    = true;         // Use Momentum Confirmation

input group "=== TREND FILTER ==="
input int      InpTrendEMA       = 50;           // Trend EMA Period
input bool     InpUseTrendFilter = true;         // Use Trend Filter

input group "=== RISK MANAGEMENT ==="
input double   InpRiskPercent    = 1.0;          // Risk Per Trade (%)
input double   InpSLMultiplier   = 1.5;          // SL (ATR Multiplier)
input double   InpTPMultiplier   = 2.5;          // TP (ATR Multiplier)
input int      InpMaxPositions   = 1;            // Max Open Positions

input group "=== TRADING HOURS ==="
input int      InpStartHour      = 1;            // Trading Start Hour
input int      InpEndHour        = 23;           // Trading End Hour

input group "=== GENERAL SETTINGS ==="
input ulong    InpMagicNumber    = 123461;       // Magic Number
input string   InpTradeComment   = "BB_Squeeze"; // Trade Comment

//--- Indicator Handles
int handleBB;
int handleATR;
int handleTrendEMA;
int handleMomentum;

double bbUpper[];
double bbMiddle[];
double bbLower[];
double atrValues[];
double trendEMA[];
double momentum[];

//+------------------------------------------------------------------+
int OnInit()
{
   handleBB        = iBands(_Symbol, PERIOD_CURRENT, InpBBPeriod, 0, InpBBDeviation, PRICE_CLOSE);
   handleATR       = iATR(_Symbol, PERIOD_CURRENT, InpBBPeriod);
   handleTrendEMA  = iMA(_Symbol, PERIOD_CURRENT, InpTrendEMA, 0, MODE_EMA, PRICE_CLOSE);
   handleMomentum  = iMomentum(_Symbol, PERIOD_CURRENT, InpMomentumPeriod, PRICE_CLOSE);
   
   if(handleBB == INVALID_HANDLE || handleATR == INVALID_HANDLE ||
      handleTrendEMA == INVALID_HANDLE || handleMomentum == INVALID_HANDLE)
   {
      Print("ERROR: Failed to create indicator handles");
      return(INIT_FAILED);
   }
   
   ArraySetAsSeries(bbUpper, true);
   ArraySetAsSeries(bbMiddle, true);
   ArraySetAsSeries(bbLower, true);
   ArraySetAsSeries(atrValues, true);
   ArraySetAsSeries(trendEMA, true);
   ArraySetAsSeries(momentum, true);
   
   Print("=== Bollinger Squeeze EA Initialized ===");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(handleBB != INVALID_HANDLE) IndicatorRelease(handleBB);
   if(handleATR != INVALID_HANDLE) IndicatorRelease(handleATR);
   if(handleTrendEMA != INVALID_HANDLE) IndicatorRelease(handleTrendEMA);
   if(handleMomentum != INVALID_HANDLE) IndicatorRelease(handleMomentum);
}

//+------------------------------------------------------------------+
void OnTick()
{
   static datetime lastBar = 0;
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(lastBar == currentBar) return;
   lastBar = currentBar;
   
   if(!IsTradeTime()) return;
   if(!GetIndicatorValues()) return;
   
   int signal = CheckSqueezeBreakout();
   
   if(signal == 1 && CountPositions(ORDER_TYPE_BUY) < InpMaxPositions)
   {
      ClosePositions(ORDER_TYPE_SELL);
      OpenBuy();
   }
   else if(signal == -1 && CountPositions(ORDER_TYPE_SELL) < InpMaxPositions)
   {
      ClosePositions(ORDER_TYPE_BUY);
      OpenSell();
   }
}

//+------------------------------------------------------------------+
bool GetIndicatorValues()
{
   if(CopyBuffer(handleBB, 1, 0, InpSqueezePeriod + 5, bbUpper) < InpSqueezePeriod + 5) return false;
   if(CopyBuffer(handleBB, 0, 0, InpSqueezePeriod + 5, bbMiddle) < InpSqueezePeriod + 5) return false;
   if(CopyBuffer(handleBB, 2, 0, InpSqueezePeriod + 5, bbLower) < InpSqueezePeriod + 5) return false;
   if(CopyBuffer(handleATR, 0, 0, InpSqueezePeriod + 5, atrValues) < InpSqueezePeriod + 5) return false;
   if(CopyBuffer(handleTrendEMA, 0, 0, 5, trendEMA) < 5) return false;
   if(CopyBuffer(handleMomentum, 0, 0, 5, momentum) < 5) return false;
   return true;
}

//+------------------------------------------------------------------+
int CheckSqueezeBreakout()
{
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
   
   // Calculate BB width
   double bbWidth1 = (bbUpper[1] - bbLower[1]) / bbMiddle[1] * 100;
   double bbWidth2 = (bbUpper[2] - bbLower[2]) / bbMiddle[2] * 100;
   
   // Calculate average width
   double avgWidth = 0;
   for(int i = 1; i <= InpSqueezePeriod; i++)
   {
      avgWidth += (bbUpper[i] - bbLower[i]) / bbMiddle[i] * 100;
   }
   avgWidth /= InpSqueezePeriod;
   
   // Detect squeeze (narrow bands)
   bool wasSqueezed = bbWidth2 < avgWidth * InpSqueezeThreshold;
   
   // Detect breakout (bands expanding)
   bool isExpanding = bbWidth1 > bbWidth2;
   
   // Trend filter
   bool isUptrend = true;
   bool isDowntrend = true;
   
   if(InpUseTrendFilter)
   {
      isUptrend = close1 > trendEMA[1];
      isDowntrend = close1 < trendEMA[1];
   }
   
   // Momentum filter
   bool momentumUp = true;
   bool momentumDown = true;
   
   if(InpUseMomentum)
   {
      momentumUp = momentum[1] > 100.0;
      momentumDown = momentum[1] < 100.0;
   }
   
   // Squeeze and breakout detected
   if(wasSqueezed && isExpanding)
   {
      // BUY: Price breaks above upper band
      if(close1 > bbUpper[1] && close2 <= bbUpper[2])
      {
         if(isUptrend && momentumUp)
         {
            Print("BUY: Squeeze breakout above upper band");
            Print("  BB Width: ", DoubleToString(bbWidth2, 2), " -> ", DoubleToString(bbWidth1, 2));
            return 1;
         }
      }
      
      // SELL: Price breaks below lower band
      if(close1 < bbLower[1] && close2 >= bbLower[2])
      {
         if(isDowntrend && momentumDown)
         {
            Print("SELL: Squeeze breakout below lower band");
            Print("  BB Width: ", DoubleToString(bbWidth2, 2), " -> ", DoubleToString(bbWidth1, 2));
            return -1;
         }
      }
   }
   
   return 0;
}

//+------------------------------------------------------------------+
bool OpenBuy()
{
   double atr = atrValues[1];
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double sl = ask - (atr * InpSLMultiplier);
   double tp = ask + (atr * InpTPMultiplier);
   double lotSize = CalculateLotSize(atr * InpSLMultiplier);
   
   return ExecuteTrade(ORDER_TYPE_BUY, ask, sl, tp, lotSize);
}

//+------------------------------------------------------------------+
bool OpenSell()
{
   double atr = atrValues[1];
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl = bid + (atr * InpSLMultiplier);
   double tp = bid - (atr * InpTPMultiplier);
   double lotSize = CalculateLotSize(atr * InpSLMultiplier);
   
   return ExecuteTrade(ORDER_TYPE_SELL, bid, sl, tp, lotSize);
}

//+------------------------------------------------------------------+
bool ExecuteTrade(ENUM_ORDER_TYPE type, double price, double sl, double tp, double lotSize)
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
   request.comment   = InpTradeComment;
   
   if(!OrderSend(request, result))
   {
      Print("ERROR: Order failed - ", result.retcode);
      return false;
   }
   
   if(result.retcode == TRADE_RETCODE_DONE || result.retcode == TRADE_RETCODE_DONE_PARTIAL)
   {
      Print(type == ORDER_TYPE_BUY ? "BUY" : "SELL", " Opened: Lot=", lotSize);
      return true;
   }
   
   return false;
}

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
               
               OrderSend(request, result);
            }
         }
      }
   }
}

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
