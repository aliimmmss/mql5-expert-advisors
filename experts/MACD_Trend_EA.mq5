//+------------------------------------------------------------------+
//|                                      MACD_Trend_EA.mq5            |
//|                                      MACD Trend Following         |
//|                                      Based on MQL5 Article Analysis|
//+------------------------------------------------------------------+
#property copyright "Based on 326 MQL5 Gold Articles Analysis"
#property link      ""
#property version   "1.00"
#property description "MACD Trend Following for XAUUSDc"
#property description "Trades MACD histogram crossovers with trend confirmation"

//--- Input Parameters
input group "=== MACD SETTINGS ==="
input int      InpMACDFast       = 12;           // MACD Fast EMA
input int      InpMACDSlow       = 26;           // MACD Slow EMA
input int      InpMACDSignal     = 9;            // MACD Signal Line
input bool     InpUseHistogram   = false;         // Use Histogram Crossover

input group "=== TREND CONFIRMATION ==="
input int      InpTrendEMA       = 200;          // Trend EMA Period
input bool     InpUseTrendFilter = true;         // Use Trend Filter

input group "=== MOMENTUM FILTER ==="
input int      InpMomentumPeriod = 14;           // Momentum Period
input bool     InpUseMomentum    = true;         // Use Momentum Filter

input group "=== RISK MANAGEMENT ==="
input double   InpRiskPercent    = 1.0;          // Risk Per Trade (%)
input double   InpSLMultiplier   = 1.5;          // SL (ATR Multiplier)
input double   InpTPMultiplier   = 3.0;          // TP (ATR Multiplier)
input int      InpMaxPositions   = 1;            // Max Open Positions

input group "=== TRADING HOURS ==="
input int      InpStartHour      = 1;            // Trading Start Hour
input int      InpEndHour        = 23;           // Trading End Hour

input group "=== GENERAL SETTINGS ==="
input ulong    InpMagicNumber    = 123460;       // Magic Number
input string   InpTradeComment   = "MACD_Trend"; // Trade Comment

//--- Indicator Handles
int handleMACD;
int handleTrendEMA;
int handleATR;
int handleMomentum;

double macdMain[];
double macdSignal[];
double macdHistogram[];
double trendEMA[];
double atrValues[];
double momentum[];

//+------------------------------------------------------------------+
int OnInit()
{
   handleMACD      = iMACD(_Symbol, PERIOD_CURRENT, InpMACDFast, InpMACDSlow, InpMACDSignal, PRICE_CLOSE);
   handleTrendEMA  = iMA(_Symbol, PERIOD_CURRENT, InpTrendEMA, 0, MODE_EMA, PRICE_CLOSE);
   handleATR       = iATR(_Symbol, PERIOD_CURRENT, 14);
   handleMomentum  = iMomentum(_Symbol, PERIOD_CURRENT, InpMomentumPeriod, PRICE_CLOSE);
   
   if(handleMACD == INVALID_HANDLE || handleTrendEMA == INVALID_HANDLE ||
      handleATR == INVALID_HANDLE || handleMomentum == INVALID_HANDLE)
   {
      Print("ERROR: Failed to create indicator handles");
      return(INIT_FAILED);
   }
   
   ArraySetAsSeries(macdMain, true);
   ArraySetAsSeries(macdSignal, true);
   ArraySetAsSeries(macdHistogram, true);
   ArraySetAsSeries(trendEMA, true);
   ArraySetAsSeries(atrValues, true);
   ArraySetAsSeries(momentum, true);
   
   Print("=== MACD Trend EA Initialized ===");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(handleMACD != INVALID_HANDLE) IndicatorRelease(handleMACD);
   if(handleTrendEMA != INVALID_HANDLE) IndicatorRelease(handleTrendEMA);
   if(handleATR != INVALID_HANDLE) IndicatorRelease(handleATR);
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
   
   int signal = CheckMACDSignal();
   
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
   if(CopyBuffer(handleMACD, 0, 0, 6, macdMain) < 6) return false;
   if(CopyBuffer(handleMACD, 1, 0, 6, macdSignal) < 6) return false;
   if(CopyBuffer(handleMACD, 2, 0, 6, macdHistogram) < 6) return false;
   if(CopyBuffer(handleTrendEMA, 0, 0, 5, trendEMA) < 5) return false;
   if(CopyBuffer(handleATR, 0, 0, 3, atrValues) < 3) return false;
   if(CopyBuffer(handleMomentum, 0, 0, 5, momentum) < 5) return false;
   return true;
}

//+------------------------------------------------------------------+
int CheckMACDSignal()
{
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   
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
   
   if(InpUseHistogram)
   {
      // Histogram direction change (momentum shift)
      double hist1 = macdHistogram[1];
      double hist2 = macdHistogram[2];
      double hist3 = macdHistogram[3];
      
      // BUY: Histogram positive and turning up (direction change from decreasing to increasing)
      if(hist1 > 0 && hist1 > hist2 && hist2 < hist3)
      {
         if(isUptrend && momentumUp)
         {
            Print("BUY: MACD Histogram momentum shift up");
            return 1;
         }
      }
      
      // SELL: Histogram negative and turning down (direction change from increasing to decreasing)
      if(hist1 < 0 && hist1 < hist2 && hist2 > hist3)
      {
         if(isDowntrend && momentumDown)
         {
            Print("SELL: MACD Histogram momentum shift down");
            return -1;
         }
      }
   }
   else
   {
      // MACD line crossover
      double macd1 = macdMain[1];
      double macd2 = macdMain[2];
      double sig1  = macdSignal[1];
      double sig2  = macdSignal[2];
      
      // BUY: MACD crosses above signal
      if(macd2 <= sig2 && macd1 > sig1)
      {
         if(isUptrend && momentumUp)
         {
            Print("BUY: MACD crossed above signal");
            return 1;
         }
      }
      
      // SELL: MACD crosses below signal
      if(macd2 >= sig2 && macd1 < sig1)
      {
         if(isDowntrend && momentumDown)
         {
            Print("SELL: MACD crossed below signal");
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
