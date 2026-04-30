//+------------------------------------------------------------------+
//|                                      RSI_Extreme_EA.mq5           |
//|                                      RSI Overbought/Oversold      |
//|                                      Based on MQL5 Article Analysis|
//+------------------------------------------------------------------+
#property copyright "Based on 326 MQL5 Gold Articles Analysis"
#property link      ""
#property version   "1.00"
#property description "RSI Overbought/Oversold Reversal for XAUUSDc"
#property description "Trades reversals from extreme RSI levels"

//--- Input Parameters
input group "=== RSI SETTINGS ==="
input int      InpRSIPeriod      = 14;           // RSI Period
input double   InpOverbought     = 70.0;         // Overbought Level
input double   InpOversold       = 30.0;         // Oversold Level
input double   InpExitLevel      = 50.0;         // Exit at RSI Level

input group "=== TREND FILTER ==="
input int      InpTrendEMA       = 200;          // Trend EMA Period
input bool     InpUseTrendFilter = false;        // Use Trend Filter

input group "=== DIVERGENCE ==="
input bool     InpUseDivergence  = true;         // Use RSI Divergence
input int      InpDivLookback    = 10;           // Divergence Lookback

input group "=== RISK MANAGEMENT ==="
input double   InpRiskPercent    = 1.0;          // Risk Per Trade (%)
input double   InpSLPoints       = 500;          // Stop Loss (points)
input double   InpTPRatio        = 2.0;          // TP:SL Ratio
input int      InpMaxPositions   = 1;            // Max Open Positions

input group "=== TRADING HOURS ==="
input int      InpStartHour      = 1;            // Trading Start Hour
input int      InpEndHour        = 23;           // Trading End Hour

input group "=== GENERAL SETTINGS ==="
input ulong    InpMagicNumber    = 123459;       // Magic Number
input string   InpTradeComment   = "RSI_Extreme"; // Trade Comment

//--- Indicator Handles
int handleRSI;
int handleTrendEMA;

double rsiValues[];
double trendEMA[];

//+------------------------------------------------------------------+
int OnInit()
{
   handleRSI       = iRSI(_Symbol, PERIOD_CURRENT, InpRSIPeriod, PRICE_CLOSE);
   handleTrendEMA  = iMA(_Symbol, PERIOD_CURRENT, InpTrendEMA, 0, MODE_EMA, PRICE_CLOSE);
   
   if(handleRSI == INVALID_HANDLE || handleTrendEMA == INVALID_HANDLE)
   {
      Print("ERROR: Failed to create indicator handles");
      return(INIT_FAILED);
   }
   
   ArraySetAsSeries(rsiValues, true);
   ArraySetAsSeries(trendEMA, true);
   
   Print("=== RSI Extreme EA Initialized ===");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(handleRSI != INVALID_HANDLE) IndicatorRelease(handleRSI);
   if(handleTrendEMA != INVALID_HANDLE) IndicatorRelease(handleTrendEMA);
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
   
   int signal = CheckRSISignal();
   
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
   
   // Exit at RSI 50
   CheckRSIExit();
}

//+------------------------------------------------------------------+
bool GetIndicatorValues()
{
   // Copy enough data for both signal check and divergence lookback
   int rsiCopySize = 2 * InpDivLookback + 5;
   if(CopyBuffer(handleRSI, 0, 0, rsiCopySize, rsiValues) < rsiCopySize) return false;
   if(CopyBuffer(handleTrendEMA, 0, 0, 5, trendEMA) < 5) return false;
   return true;
}

//+------------------------------------------------------------------+
int CheckRSISignal()
{
   double rsi1 = rsiValues[1];  // Current RSI
   double rsi2 = rsiValues[2];  // Previous RSI
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   
   // Trend filter
   bool isUptrend = true;
   bool isDowntrend = true;
   
   if(InpUseTrendFilter)
   {
      isUptrend = close1 > trendEMA[1];
      isDowntrend = close1 < trendEMA[1];
   }
   
   // BUY: RSI crosses above oversold (reversal)
   if(rsi2 <= InpOversold && rsi1 > InpOversold)
   {
      bool validBuy = true;
      
      // Check for bullish divergence
      if(InpUseDivergence)
         validBuy = CheckBullishDivergence();
      
      if(validBuy && isUptrend)
      {
         Print("BUY: RSI crossed above oversold (", DoubleToString(rsi1, 1), ")");
         return 1;
      }
   }
   
   // SELL: RSI crosses below overbought (reversal)
   if(rsi2 >= InpOverbought && rsi1 < InpOverbought)
   {
      bool validSell = true;
      
      // Check for bearish divergence
      if(InpUseDivergence)
         validSell = CheckBearishDivergence();
      
      if(validSell && isDowntrend)
      {
         Print("SELL: RSI crossed below overbought (", DoubleToString(rsi1, 1), ")");
         return -1;
      }
   }
   
   return 0;
}

//+------------------------------------------------------------------+
bool CheckBullishDivergence()
{
   // Simplified divergence: compare RSI at current low vs previous low
   // Look for RSI making higher lows while price makes lower lows
   
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
   double close3 = iClose(_Symbol, PERIOD_CURRENT, 3);
   
   double rsi1 = rsiValues[1];
   double rsi2 = rsiValues[2];
   double rsi3 = rsiValues[3];
   
   // Bullish divergence: price going down, RSI going up
   if(close1 < close3 && rsi1 > rsi3 && rsi1 < InpOversold + 10)
   {
      Print("Bullish Divergence Detected");
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
bool CheckBearishDivergence()
{
   // Simplified divergence: compare RSI at current high vs previous high
   // Look for RSI making lower highs while price makes higher highs
   
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
   double close3 = iClose(_Symbol, PERIOD_CURRENT, 3);
   
   double rsi1 = rsiValues[1];
   double rsi2 = rsiValues[2];
   double rsi3 = rsiValues[3];
   
   // Bearish divergence: price going up, RSI going down
   if(close1 > close3 && rsi1 < rsi3 && rsi1 > InpOverbought - 10)
   {
      Print("Bearish Divergence Detected");
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
void CheckRSIExit()
{
   double rsi1 = rsiValues[1];
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
         {
            // Close BUY if RSI reaches exit level from below
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && rsi1 >= InpExitLevel)
            {
               ClosePosition(ticket);
            }
            // Close SELL if RSI reaches exit level from above
            else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && rsi1 <= InpExitLevel)
            {
               ClosePosition(ticket);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
bool OpenBuy()
{
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
               ClosePosition(ticket);
         }
      }
   }
}

//+------------------------------------------------------------------+
void ClosePosition(ulong ticket)
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
