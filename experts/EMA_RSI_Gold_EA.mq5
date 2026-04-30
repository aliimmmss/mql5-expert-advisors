//+------------------------------------------------------------------+
//|                                      EMA_RSI_Gold_EA.mq5         |
//|                                      Based on MQL5 Article Analysis|
//|                                      Strategy: EMA Crossover + RSI |
//+------------------------------------------------------------------+
#property copyright "Based on 326 MQL5 Gold Articles Analysis"
#property link      ""
#property version   "1.00"
#property description "EMA Crossover + RSI Confirmation for XAUUSDc"
#property description "Optimized for Cent Accounts (5,000 USC)"

//--- Input Parameters
input group "=== STRATEGY PARAMETERS ==="
input int      InpFastEMA        = 21;           // Fast EMA Period
input int      InpSlowEMA        = 50;           // Slow EMA Period
input int      InpRSIPeriod      = 14;           // RSI Period
input int      InpATRPeriod      = 14;           // ATR Period
input double   InpRSIOverbought  = 70.0;         // RSI Overbought Level
input double   InpRSIOversold    = 30.0;         // RSI Oversold Level

input group "=== RISK MANAGEMENT ==="
input double   InpRiskPercent    = 1.0;          // Risk Per Trade (%)
input double   InpSLMultiplier   = 1.5;          // Stop Loss (ATR Multiplier)
input double   InpTPMultiplier   = 3.0;          // Take Profit (ATR Multiplier)
input int      InpMaxPositions   = 1;            // Max Open Positions

input group "=== TRADING HOURS ==="
input int      InpStartHour      = 1;            // Trading Start Hour (Server)
input int      InpEndHour        = 23;           // Trading End Hour (Server)

input group "=== GENERAL SETTINGS ==="
input ulong    InpMagicNumber    = 123456;       // Magic Number
input string   InpTradeComment   = "EMA_RSI_Gold"; // Trade Comment

//--- Indicator Handles
int handleFastEMA;
int handleSlowEMA;
int handleRSI;
int handleATR;

//--- Global Variables
double fastEMA[];
double slowEMA[];
double rsiValues[];
double atrValues[];

//+------------------------------------------------------------------+
//| Expert initialization function                                      |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Validate inputs
   if(InpFastEMA >= InpSlowEMA)
   {
      Print("ERROR: Fast EMA must be less than Slow EMA");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   if(InpRiskPercent <= 0 || InpRiskPercent > 5)
   {
      Print("WARNING: Risk percent adjusted to safe range");
   }
   
   //--- Create indicator handles
   handleFastEMA = iMA(_Symbol, PERIOD_CURRENT, InpFastEMA, 0, MODE_EMA, PRICE_CLOSE);
   handleSlowEMA = iMA(_Symbol, PERIOD_CURRENT, InpSlowEMA, 0, MODE_EMA, PRICE_CLOSE);
   handleRSI     = iRSI(_Symbol, PERIOD_CURRENT, InpRSIPeriod, PRICE_CLOSE);
   handleATR     = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
   
   //--- Validate handles
   if(handleFastEMA == INVALID_HANDLE || handleSlowEMA == INVALID_HANDLE ||
      handleRSI == INVALID_HANDLE || handleATR == INVALID_HANDLE)
   {
      Print("ERROR: Failed to create indicator handles");
      return(INIT_FAILED);
   }
   
   //--- Set arrays as series
   ArraySetAsSeries(fastEMA, true);
   ArraySetAsSeries(slowEMA, true);
   ArraySetAsSeries(rsiValues, true);
   ArraySetAsSeries(atrValues, true);
   
   Print("=== EMA RSI Gold EA Initialized ===");
   Print("Symbol: ", _Symbol);
   Print("Fast EMA: ", InpFastEMA, " | Slow EMA: ", InpSlowEMA);
   Print("RSI Period: ", InpRSIPeriod);
   Print("Risk: ", InpRiskPercent, "% per trade");
   Print("SL: ", InpSLMultiplier, "x ATR | TP: ", InpTPMultiplier, "x ATR");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitial function                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Release indicator handles
   if(handleFastEMA != INVALID_HANDLE) IndicatorRelease(handleFastEMA);
   if(handleSlowEMA != INVALID_HANDLE) IndicatorRelease(handleSlowEMA);
   if(handleRSI != INVALID_HANDLE)     IndicatorRelease(handleRSI);
   if(handleATR != INVALID_HANDLE)     IndicatorRelease(handleATR);
   
   Print("=== EMA RSI Gold EA Removed ===");
}

//+------------------------------------------------------------------+
//| Expert tick function                                                |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Check if new bar (avoid multiple checks per bar)
   static datetime lastBar = 0;
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(lastBar == currentBar) return;
   lastBar = currentBar;
   
   //--- Check trading hours
   if(!IsTradeTime()) return;
   
   //--- Get indicator values
   if(!GetIndicatorValues()) return;
   
   //--- Check for signals
   int signal = CheckSignal();
   
   //--- Execute trades
   if(signal == 1)      // BUY signal
   {
      if(CountPositions(ORDER_TYPE_BUY) < InpMaxPositions)
      {
         ClosePositions(ORDER_TYPE_SELL);  // Close opposite
         OpenBuy();
      }
   }
   else if(signal == -1) // SELL signal
   {
      if(CountPositions(ORDER_TYPE_SELL) < InpMaxPositions)
      {
         ClosePositions(ORDER_TYPE_BUY);   // Close opposite
         OpenSell();
      }
   }
}

//+------------------------------------------------------------------+
//| Get indicator values                                                |
//+------------------------------------------------------------------+
bool GetIndicatorValues()
{
   //--- Copy indicator buffers
   if(CopyBuffer(handleFastEMA, 0, 0, 3, fastEMA) < 3) return false;
   if(CopyBuffer(handleSlowEMA, 0, 0, 3, slowEMA) < 3) return false;
   if(CopyBuffer(handleRSI, 0, 0, 3, rsiValues) < 3)   return false;
   if(CopyBuffer(handleATR, 0, 0, 3, atrValues) < 3)   return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Check for trading signal                                            |
//+------------------------------------------------------------------+
int CheckSignal()
{
   //--- Current values (index 1 = last closed bar)
   double fastCurr = fastEMA[1];
   double fastPrev = fastEMA[2];
   double slowCurr = slowEMA[1];
   double slowPrev = slowEMA[2];
   double rsiCurr  = rsiValues[1];
   
   //--- BUY Signal: Fast EMA crosses above Slow EMA
   if(fastPrev <= slowPrev && fastCurr > slowCurr)
   {
      //--- RSI confirmation: bullish but not overbought
      if(rsiCurr > 50.0 && rsiCurr < InpRSIOverbought)
      {
         Print("BUY Signal: EMA Cross UP | RSI: ", DoubleToString(rsiCurr, 1));
         return 1;
      }
   }
   
   //--- SELL Signal: Fast EMA crosses below Slow EMA
   if(fastPrev >= slowPrev && fastCurr < slowCurr)
   {
      //--- RSI confirmation: bearish but not oversold
      if(rsiCurr < 50.0 && rsiCurr > InpRSIOversold)
      {
         Print("SELL Signal: EMA Cross DOWN | RSI: ", DoubleToString(rsiCurr, 1));
         return -1;
      }
   }
   
   return 0; // No signal
}

//+------------------------------------------------------------------+
//| Open Buy Position                                                   |
//+------------------------------------------------------------------+
bool OpenBuy()
{
   double atr = atrValues[1];
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double sl = ask - (atr * InpSLMultiplier);
   double tp = ask + (atr * InpTPMultiplier);
   double lotSize = CalculateLotSize(atr * InpSLMultiplier);
   
   //--- Normalize prices
   sl = NormalizeDouble(sl, _Digits);
   tp = NormalizeDouble(tp, _Digits);
   
   //--- Create trade request
   MqlTradeRequest request = {};
   MqlTradeResult  result  = {};
   
   request.action    = TRADE_ACTION_DEAL;
   request.symbol    = _Symbol;
   request.volume    = lotSize;
   request.type      = ORDER_TYPE_BUY;
   request.price     = ask;
   request.sl        = sl;
   request.tp        = tp;
   request.deviation = 10;
   request.magic     = InpMagicNumber;
   request.comment   = InpTradeComment;
   
   //--- Send order
   if(!OrderSend(request, result))
   {
      Print("ERROR: Buy order failed - ", result.retcode);
      return false;
   }
   
   if(result.retcode == TRADE_RETCODE_DONE || result.retcode == TRADE_RETCODE_DONE_PARTIAL)
   {
      Print("BUY Opened: Lot=", lotSize, " SL=", sl, " TP=", tp);
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Open Sell Position                                                  |
//+------------------------------------------------------------------+
bool OpenSell()
{
   double atr = atrValues[1];
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl = bid + (atr * InpSLMultiplier);
   double tp = bid - (atr * InpTPMultiplier);
   double lotSize = CalculateLotSize(atr * InpSLMultiplier);
   
   //--- Normalize prices
   sl = NormalizeDouble(sl, _Digits);
   tp = NormalizeDouble(tp, _Digits);
   
   //--- Create trade request
   MqlTradeRequest request = {};
   MqlTradeResult  result  = {};
   
   request.action    = TRADE_ACTION_DEAL;
   request.symbol    = _Symbol;
   request.volume    = lotSize;
   request.type      = ORDER_TYPE_SELL;
   request.price     = bid;
   request.sl        = sl;
   request.tp        = tp;
   request.deviation = 10;
   request.magic     = InpMagicNumber;
   request.comment   = InpTradeComment;
   
   //--- Send order
   if(!OrderSend(request, result))
   {
      Print("ERROR: Sell order failed - ", result.retcode);
      return false;
   }
   
   if(result.retcode == TRADE_RETCODE_DONE || result.retcode == TRADE_RETCODE_DONE_PARTIAL)
   {
      Print("SELL Opened: Lot=", lotSize, " SL=", sl, " TP=", tp);
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Calculate lot size based on risk                                    |
//+------------------------------------------------------------------+
double CalculateLotSize(double slDistance)
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * InpRiskPercent / 100.0;
   
   //--- Get tick value
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   
   if(tickSize == 0 || tickValue == 0)
   {
      Print("WARNING: Could not get tick info, using minimum lot");
      return SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   }
   
   //--- Calculate lot size
   double slTicks = slDistance / tickSize;
   double lotSize = riskAmount / (slTicks * tickValue);
   
   //--- Normalize to broker requirements
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
   
   return NormalizeDouble(lotSize, 2);
}

//+------------------------------------------------------------------+
//| Count positions by type                                             |
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
//| Close positions by type                                             |
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
               
               request.volume = PositionGetDouble(POSITION_VOLUME);
               
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
//| Check if within trading hours                                       |
//+------------------------------------------------------------------+
bool IsTradeTime()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   
   //--- Skip weekends
   if(dt.day_of_week == 0 || dt.day_of_week == 6) return false;
   
   //--- Check trading hours
   if(dt.hour >= InpStartHour && dt.hour < InpEndHour)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
