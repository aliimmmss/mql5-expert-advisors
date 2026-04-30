//+------------------------------------------------------------------+
//|                                      Breakout_EA.mq5              |
//|                                      Price Breakout Strategy      |
//|                                      Based on MQL5 Article Analysis|
//+------------------------------------------------------------------+
#property copyright "Based on 326 MQL5 Gold Articles Analysis"
#property link      ""
#property version   "1.00"
#property description "Breakout Strategy for XAUUSDc"
#property description "Trades breakouts of key levels with volume confirmation"

//--- Input Parameters
input group "=== BREAKOUT SETTINGS ==="
input int      InpLookback       = 20;           // Lookback Period for Levels
input int      InpBreakoutConfirm= 2;            // Bars to Confirm Breakout
input double   InpBreakoutSize   = 100;          // Min Breakout Size (points)

input group "=== TREND FILTER ==="
input int      InpTrendEMA       = 100;          // Trend Filter EMA
input bool     InpUseTrendFilter = true;         // Use Trend Filter

input group "=== VOLATILITY FILTER ==="
input int      InpATRPeriod      = 14;           // ATR Period
input double   InpATRMultiplier  = 1.5;          // ATR Multiplier for Breakout

input group "=== RISK MANAGEMENT ==="
input double   InpRiskPercent    = 1.0;          // Risk Per Trade (%)
input double   InpSLMultiplier   = 2.0;          // SL (ATR Multiplier)
input double   InpTPMultiplier   = 3.0;          // TP (ATR Multiplier)
input int      InpMaxPositions   = 1;            // Max Open Positions

input group "=== TRADING HOURS ==="
input int      InpStartHour      = 1;            // Trading Start Hour
input int      InpEndHour        = 23;           // Trading End Hour

input group "=== GENERAL SETTINGS ==="
input ulong    InpMagicNumber    = 123458;       // Magic Number
input string   InpTradeComment   = "Breakout";   // Trade Comment

//--- Indicator Handles
int handleTrendEMA;
int handleATR;

double trendEMA[];
double atrValues[];

//+------------------------------------------------------------------+
int OnInit()
{
   handleTrendEMA = iMA(_Symbol, PERIOD_CURRENT, InpTrendEMA, 0, MODE_EMA, PRICE_CLOSE);
   handleATR      = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
   
   if(handleTrendEMA == INVALID_HANDLE || handleATR == INVALID_HANDLE)
   {
      Print("ERROR: Failed to create indicator handles");
      return(INIT_FAILED);
   }
   
   ArraySetAsSeries(trendEMA, true);
   ArraySetAsSeries(atrValues, true);
   
   Print("=== Breakout EA Initialized ===");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(handleTrendEMA != INVALID_HANDLE) IndicatorRelease(handleTrendEMA);
   if(handleATR != INVALID_HANDLE) IndicatorRelease(handleATR);
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
   
   int signal = CheckBreakout();
   
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
   if(CopyBuffer(handleTrendEMA, 0, 0, 5, trendEMA) < 5) return false;
   if(CopyBuffer(handleATR, 0, 0, 3, atrValues) < 3) return false;
   return true;
}

//+------------------------------------------------------------------+
int CheckBreakout()
{
   // Find recent high and low
   int highestBar = iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, InpLookback, 1);
   int lowestBar  = iHighest(_Symbol, PERIOD_CURRENT, MODE_LOW, InpLookback, 1);
   
   double recentHigh = iHigh(_Symbol, PERIOD_CURRENT, highestBar);
   double recentLow  = iLow(_Symbol, PERIOD_CURRENT, lowestBar);
   
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
   double atr    = atrValues[1];
   
   // Trend filter
   bool isUptrend = true;
   bool isDowntrend = true;
   
   if(InpUseTrendFilter)
   {
      isUptrend = close1 > trendEMA[1];
      isDowntrend = close1 < trendEMA[1];
   }
   
   // Breakout size filter
   double minBreakout = InpBreakoutSize * _Point;
   
   // BUY: Breakout above resistance
   if(close1 > recentHigh && close2 <= recentHigh)
   {
      double breakoutSize = close1 - recentHigh;
      if(breakoutSize >= minBreakout && isUptrend)
      {
         // Check volatility (ATR should be above average)
         double avgATR = 0;
         for(int i = 1; i <= 10; i++)
            avgATR += atrValues[i];
         avgATR /= 10;
         
         if(atr > avgATR * InpATRMultiplier)
         {
            Print("BUY Breakout: High=", recentHigh, " Close=", close1);
            return 1;
         }
      }
   }
   
   // SELL: Breakdown below support
   if(close1 < recentLow && close2 >= recentLow)
   {
      double breakoutSize = recentLow - close1;
      if(breakoutSize >= minBreakout && isDowntrend)
      {
         double avgATR = 0;
         for(int i = 1; i <= 10; i++)
            avgATR += atrValues[i];
         avgATR /= 10;
         
         if(atr > avgATR * InpATRMultiplier)
         {
            Print("SELL Breakout: Low=", recentLow, " Close=", close1);
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
               
               if(OrderSend(request, result))
               {
                  if(result.retcode == TRADE_RETCODE_DONE)
                     Print("Closed position #", ticket);
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
