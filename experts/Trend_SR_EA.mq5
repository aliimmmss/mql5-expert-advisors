//+------------------------------------------------------------------+
//|                                      Trend_SR_EA.mq5              |
//|                                      Trend + Support/Resistance   |
//|                                      Based on MQL5 Article Analysis|
//+------------------------------------------------------------------+
#property copyright "Based on 326 MQL5 Gold Articles Analysis"
#property link      ""
#property version   "1.00"
#property description "Trend Following + Support/Resistance Bounce for XAUUSDc"
#property description "Identifies trend on D1, trades bounces on H1"

//--- Input Parameters
input group "=== TREND IDENTIFICATION ==="
input int      InpTrendEMA       = 200;          // Trend EMA Period (D1)
input int      InpFastEMA        = 21;           // Fast EMA (H1)
input int      InpSlowEMA        = 50;           // Slow EMA (H1)

input group "=== SUPPORT/RESISTANCE ==="
input int      InpSRPeriod       = 20;           // S/R Lookback Period
input int      InpSRZone         = 50;           // S/R Zone Size (points)
input int      InpBounceConfirm  = 2;            // Bounce Confirmation Bars

input group "=== RISK MANAGEMENT ==="
input double   InpRiskPercent    = 1.0;          // Risk Per Trade (%)
input double   InpSLPoints       = 500;          // Stop Loss (points)
input double   InpTPRatio        = 2.0;          // TP:SL Ratio
input int      InpMaxPositions   = 1;            // Max Open Positions

input group "=== TRADING HOURS ==="
input int      InpStartHour      = 1;            // Trading Start Hour
input int      InpEndHour        = 23;           // Trading End Hour

input group "=== GENERAL SETTINGS ==="
input ulong    InpMagicNumber    = 123457;       // Magic Number
input string   InpTradeComment   = "Trend_SR";   // Trade Comment

//--- Global Variables
int handleTrendEMA_H1;
int handleFastEMA_H1;
int handleSlowEMA_H1;
int handleATR;

double trendEMA_H1[];
double fastEMA_H1[];
double slowEMA_H1[];
double atrValues[];

//+------------------------------------------------------------------+
int OnInit()
{
   handleTrendEMA_H1 = iMA(_Symbol, PERIOD_H1, InpTrendEMA, 0, MODE_EMA, PRICE_CLOSE);
   handleFastEMA_H1  = iMA(_Symbol, PERIOD_H1, InpFastEMA, 0, MODE_EMA, PRICE_CLOSE);
   handleSlowEMA_H1  = iMA(_Symbol, PERIOD_H1, InpSlowEMA, 0, MODE_EMA, PRICE_CLOSE);
   handleATR         = iATR(_Symbol, PERIOD_H1, 14);
   
   if(handleTrendEMA_H1 == INVALID_HANDLE || handleFastEMA_H1 == INVALID_HANDLE ||
      handleSlowEMA_H1 == INVALID_HANDLE || handleATR == INVALID_HANDLE)
   {
      Print("ERROR: Failed to create indicator handles");
      return(INIT_FAILED);
   }
   
   ArraySetAsSeries(trendEMA_H1, true);
   ArraySetAsSeries(fastEMA_H1, true);
   ArraySetAsSeries(slowEMA_H1, true);
   ArraySetAsSeries(atrValues, true);
   
   Print("=== Trend SR EA Initialized ===");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(handleTrendEMA_H1 != INVALID_HANDLE) IndicatorRelease(handleTrendEMA_H1);
   if(handleFastEMA_H1 != INVALID_HANDLE) IndicatorRelease(handleFastEMA_H1);
   if(handleSlowEMA_H1 != INVALID_HANDLE) IndicatorRelease(handleSlowEMA_H1);
   if(handleATR != INVALID_HANDLE) IndicatorRelease(handleATR);
}

//+------------------------------------------------------------------+
void OnTick()
{
   static datetime lastBar = 0;
   datetime currentBar = iTime(_Symbol, PERIOD_H1, 0);
   if(lastBar == currentBar) return;
   lastBar = currentBar;
   
   if(!IsTradeTime()) return;
   if(!GetIndicatorValues()) return;
   
   int trend = GetTrend();
   int signal = CheckSRBounce(trend);
   
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
   if(CopyBuffer(handleTrendEMA_H1, 0, 0, 5, trendEMA_H1) < 5) return false;
   if(CopyBuffer(handleFastEMA_H1, 0, 0, 5, fastEMA_H1) < 5) return false;
   if(CopyBuffer(handleSlowEMA_H1, 0, 0, 5, slowEMA_H1) < 5) return false;
   if(CopyBuffer(handleATR, 0, 0, 3, atrValues) < 3) return false;
   return true;
}

//+------------------------------------------------------------------+
int GetTrend()
{
   double price = iClose(_Symbol, PERIOD_H1, 1);
   
   // Price above 200 EMA = Uptrend
   if(price > trendEMA_H1[1]) return 1;
   // Price below 200 EMA = Downtrend
   if(price < trendEMA_H1[1]) return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
int CheckSRBounce(int trend)
{
   double high1 = iHigh(_Symbol, PERIOD_H1, iHighest(_Symbol, PERIOD_H1, MODE_HIGH, InpSRPeriod, 2));
   double low1  = iLow(_Symbol, PERIOD_H1, iLowest(_Symbol, PERIOD_H1, MODE_LOW, InpSRPeriod, 2));
   
   double close1 = iClose(_Symbol, PERIOD_H1, 1);
   double close2 = iClose(_Symbol, PERIOD_H1, 2);
   double open1  = iOpen(_Symbol, PERIOD_H1, 1);
   
   double zoneSize = InpSRZone * _Point;
   
   // BUY: Uptrend + Price bounces off support
   if(trend == 1)
   {
      // Price near support zone and bouncing
      if(close1 <= low1 + zoneSize && close1 > open1 && close1 > close2)
      {
         // Bullish candle confirmation
         if(fastEMA_H1[1] > slowEMA_H1[1])
         {
            Print("BUY: Support bounce in uptrend");
            return 1;
         }
      }
   }
   
   // SELL: Downtrend + Price rejected at resistance
   if(trend == -1)
   {
      // Price near resistance zone and rejecting
      if(close1 >= high1 - zoneSize && close1 < open1 && close1 < close2)
      {
         // Bearish candle confirmation
         if(fastEMA_H1[1] < slowEMA_H1[1])
         {
            Print("SELL: Resistance rejection in downtrend");
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
   double sl = ask - InpSLPoints * _Point;
   double tp = ask + (InpSLPoints * InpTPRatio) * _Point;
   double lotSize = CalculateLotSize(InpSLPoints * _Point);
   
   return ExecuteTrade(ORDER_TYPE_BUY, ask, sl, tp, lotSize);
}

//+------------------------------------------------------------------+
bool OpenSell()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl = bid + InpSLPoints * _Point;
   double tp = bid - (InpSLPoints * InpTPRatio) * _Point;
   double lotSize = CalculateLotSize(InpSLPoints * _Point);
   
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
