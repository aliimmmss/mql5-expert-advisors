//+------------------------------------------------------------------+
//| ASQ_Order_Executor.mq5                                           |
//| Institutional order execution wrapper for MQL5                   |
//| Source: MQL5 Code Library #72025                                 |
//| Rating: 5.0/5.0                                                  |
//|                                                                  |
//| Description:                                                     |
//|   ASQ Order Executor provides institutional-grade order          |
//|   execution with automatic retry logic, slippage monitoring,     |
//|   partial fill handling, and execution quality reporting.        |
//|   Designed as a reusable library for other EAs.                  |
//+------------------------------------------------------------------+
#property copyright "MQL5 Code Library"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

//--- Execution settings
input group "=== Execution Settings ==="
input int      InpMaxRetries       = 3;        // Max retry attempts
input int      InpRetryDelayMs     = 500;      // Delay between retries (ms)
input double   InpMaxSlippagePts   = 30;       // Max slippage in points
input double   InpMaxSpreadPts     = 50;       // Max spread allowed (points)
input bool     InpUsePartialFills  = true;     // Allow partial fills

input group "=== Risk Settings ==="
input double   InpMaxVolumeLots    = 10.0;     // Max volume per order
input double   InpMinVolumeLots    = 0.01;     // Min volume per order
input bool     InpCheckFreeMargin  = true;     // Check free margin before order

input group "=== Monitoring ==="
input bool     InpLogExecution     = true;     // Log execution details
input bool     InpAlertOnSlippage  = true;     // Alert on high slippage
input double   InpSlippageAlertPts = 20;       // Slippage alert threshold

//--- Execution statistics
struct ExecutionStats
{
   int      totalOrders;
   int      successOrders;
   int      failedOrders;
   int      retriedOrders;
   int      partialFills;
   double   totalSlippage;
   double   maxSlippage;
   double   avgSlippage;
   double   avgExecutionMs;
   datetime lastOrderTime;
};

//--- Order request wrapper
struct OrderRequest
{
   ENUM_ORDER_TYPE   type;
   double            volume;
   double            price;
   double            sl;
   double            tp;
   string            symbol;
   string            comment;
   ulong             magic;
   datetime          expiration;
};

//+------------------------------------------------------------------+
//| Order Executor Class                                              |
//+------------------------------------------------------------------+
class COrderExecutor
{
private:
   CTrade         m_trade;
   ExecutionStats m_stats;
   int            m_maxRetries;
   int            m_retryDelay;
   double         m_maxSlippage;
   double         m_maxSpread;
   bool           m_allowPartial;
   bool           m_checkMargin;
   bool           m_logExecution;

public:
   //--- Constructor
   COrderExecutor()
   {
      m_maxRetries   = InpMaxRetries;
      m_retryDelay   = InpRetryDelayMs;
      m_maxSlippage  = InpMaxSlippagePts;
      m_maxSpread    = InpMaxSpreadPts;
      m_allowPartial = InpUsePartialFills;
      m_checkMargin  = InpCheckFreeMargin;
      m_logExecution = InpLogExecution;
      m_trade.SetExpertMagicNumber(0);
      ZeroMemory(m_stats);
   }

   //--- Initialize with magic number
   void Init(ulong magic, string comment = "")
   {
      m_trade.SetExpertMagicNumber(magic);
      if(comment != "")
         m_trade.SetComment(comment);
      m_trade.SetDeviationInPoints((ulong)m_maxSlippage);
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   }

   //--- Execute market buy order
   ulong Buy(string symbol, double volume, double sl = 0, double tp = 0, string comment = "")
   {
      double price = SymbolInfoDouble(symbol, SYMBOL_ASK);
      return ExecuteOrder(symbol, ORDER_TYPE_BUY, volume, price, sl, tp, comment);
   }

   //--- Execute market sell order
   ulong Sell(string symbol, double volume, double sl = 0, double tp = 0, string comment = "")
   {
      double price = SymbolInfoDouble(symbol, SYMBOL_BID);
      return ExecuteOrder(symbol, ORDER_TYPE_SELL, volume, price, sl, tp, comment);
   }

   //--- Execute pending order
   ulong PlacePending(string symbol, ENUM_ORDER_TYPE type, double volume,
                      double price, double sl = 0, double tp = 0,
                      datetime expiration = 0, string comment = "")
   {
      return ExecuteOrder(symbol, type, volume, price, sl, tp, comment, expiration);
   }

   //--- Close position by ticket
   bool ClosePosition(ulong ticket, double volume = 0)
   {
      if(!PositionSelectByTicket(ticket))
      {
         Log("Position not found: " + IntegerToString(ticket));
         return false;
      }

      double closeVolume = (volume > 0) ? volume : PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      string sym = PositionGetString(POSITION_SYMBOL);

      ulong startTime = GetMicrosecondCount();
      bool result = false;

      for(int attempt = 0; attempt < m_maxRetries; attempt++)
      {
         if(posType == POSITION_TYPE_BUY)
            result = m_trade.Sell(closeVolume, sym);
         else
            result = m_trade.Buy(closeVolume, sym);

         if(result)
         {
            RecordExecution(startTime, 0);
            return true;
         }

         if(attempt < m_maxRetries - 1)
         {
            Log("Close retry " + IntegerToString(attempt + 1) + " for ticket " + IntegerToString(ticket));
            Sleep(m_retryDelay);
         }
      }

      m_stats.failedOrders++;
      Log("FAILED to close position: " + IntegerToString(ticket) +
          " Error: " + IntegerToString(GetLastError()));
      return false;
   }

   //--- Modify position SL/TP
   bool ModifyPosition(ulong ticket, double sl, double tp)
   {
      for(int attempt = 0; attempt < m_maxRetries; attempt++)
      {
         if(m_trade.PositionModify(ticket, sl, tp))
            return true;

         if(attempt < m_maxRetries - 1)
            Sleep(m_retryDelay);
      }
      return false;
   }

   //--- Close all positions on symbol
   int CloseAllPositions(string symbol = "")
   {
      int closed = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(symbol != "" && PositionGetString(POSITION_SYMBOL) != symbol) continue;

         if(ClosePosition(ticket))
            closed++;
      }
      return closed;
   }

   //--- Get execution statistics
   ExecutionStats GetStats() { return m_stats; }

   //--- Print statistics report
   void PrintReport()
   {
      Print("=== ASQ Order Executor Report ===");
      Print("Total Orders:     ", m_stats.totalOrders);
      Print("Successful:       ", m_stats.successOrders);
      Print("Failed:           ", m_stats.failedOrders);
      Print("Retried:          ", m_stats.retriedOrders);
      Print("Partial Fills:    ", m_stats.partialFills);
      if(m_stats.successOrders > 0)
      {
         Print("Avg Slippage:     ", DoubleToString(m_stats.avgSlippage, 1), " pts");
         Print("Max Slippage:     ", DoubleToString(m_stats.maxSlippage, 1), " pts");
         Print("Avg Exec Time:    ", DoubleToString(m_stats.avgExecutionMs, 1), " ms");
      }
      Print("=================================");
   }

private:
   //--- Core execution engine with retry logic
   ulong ExecuteOrder(string symbol, ENUM_ORDER_TYPE type, double volume,
                      double price, double sl, double tp, string comment,
                      datetime expiration = 0)
   {
      //--- Validate inputs
      volume = MathMax(InpMinVolumeLots, MathMin(volume, InpMaxVolumeLots));
      volume = NormalizeDouble(volume, 2);

      //--- Check spread
      double spread = SymbolInfoInteger(symbol, SYMBOL_SPREAD);
      if(spread > m_maxSpread)
      {
         Log("Spread too high: " + DoubleToString(spread, 0) + " > " +
             DoubleToString(m_maxSpread, 0) + " pts. Order rejected.");
         return 0;
      }

      //--- Check free margin
      if(m_checkMargin)
      {
         double margin = 0;
         if(!OrderCalcMargin(type, symbol, volume, price, margin))
         {
            Log("Cannot calculate margin for order");
            return 0;
         }
         double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
         if(margin > freeMargin * 0.9)
         {
            Log("Insufficient free margin. Required: " + DoubleToString(margin, 2) +
                " Available: " + DoubleToString(freeMargin, 2));
            return 0;
         }
      }

      //--- Execute with retries
      ulong startTime = GetMicrosecondCount();
      m_stats.totalOrders++;

      for(int attempt = 0; attempt < m_maxRetries; attempt++)
      {
         if(attempt > 0)
            m_stats.retriedOrders++;

         //--- Refresh price
         if(type == ORDER_TYPE_BUY)
            price = SymbolInfoDouble(symbol, SYMBOL_ASK);
         else if(type == ORDER_TYPE_SELL)
            price = SymbolInfoDouble(symbol, SYMBOL_BID);

         m_trade.SetDeviationInPoints((ulong)m_maxSlippage);

         bool success = false;
         if(type == ORDER_TYPE_BUY || type == ORDER_TYPE_SELL)
            success = m_trade.PositionOpen(symbol, type, volume, price, sl, tp, comment);
         else
            success = m_trade.OrderOpen(symbol, type, volume, 0, price, sl, tp,
                                        ORDER_TIME_GTC, expiration, comment);

         if(success)
         {
            //--- Check actual fill price for slippage
            double fillPrice = m_trade.ResultPrice();
            double slippage = MathAbs(fillPrice - price) / SymbolInfoDouble(symbol, SYMBOL_POINT);
            if(type == ORDER_TYPE_SELL)
               slippage = -slippage;

            RecordExecution(startTime, slippage);

            //--- Check for partial fill
            double filledVolume = m_trade.ResultVolume();
            if(filledVolume < volume && m_allowPartial)
            {
               m_stats.partialFills++;
               Log("Partial fill: " + DoubleToString(filledVolume, 2) +
                   "/" + DoubleToString(volume, 2) + " lots");
            }

            //--- Slippage alert
            if(InpAlertOnSlippage && MathAbs(slippage) > InpSlippageAlertPts)
            {
               Alert("HIGH SLIPPAGE: ", DoubleToString(slippage, 1),
                     " pts on ", symbol, " ", EnumToString(type));
            }

            if(m_logExecution)
            {
               Log("Order executed: " + symbol + " " + EnumToString(type) +
                   " " + DoubleToString(volume, 2) + " lots @ " +
                   DoubleToString(fillPrice, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)) +
                   " Slippage: " + DoubleToString(slippage, 1) + " pts" +
                   " Fill: " + DoubleToString(filledVolume, 2) + " lots");
            }

            return m_trade.ResultOrder();
         }

         //--- Log retry
         int error = GetLastError();
         Log("Order attempt " + IntegerToString(attempt + 1) + " failed. Error: " +
             IntegerToString(error) + " - " + m_trade.ResultRetcodeDescription());

         if(attempt < m_maxRetries - 1)
            Sleep(m_retryDelay);
      }

      //--- All retries failed
      m_stats.failedOrders++;
      Log("ORDER FAILED after " + IntegerToString(m_maxRetries) + " attempts: " +
          symbol + " " + EnumToString(type) + " " + DoubleToString(volume, 2) + " lots");
      return 0;
   }

   //--- Record execution metrics
   void RecordExecution(ulong startTimeUs, double slippage)
   {
      m_stats.successOrders++;
      m_stats.lastOrderTime = TimeCurrent();
      m_stats.totalSlippage += slippage;
      m_stats.maxSlippage = MathMax(m_stats.maxSlippage, MathAbs(slippage));
      m_stats.avgSlippage = m_stats.totalSlippage / m_stats.successOrders;

      double execMs = (GetMicrosecondCount() - startTimeUs) / 1000.0;
      m_stats.avgExecutionMs = (m_stats.avgExecutionMs * (m_stats.successOrders - 1) + execMs) /
                               m_stats.successOrders;
   }

   //--- Logging helper
   void Log(string msg)
   {
      Print("[ASQ Executor] ", msg);
   }
};

//--- Global executor instance
COrderExecutor *g_executor = NULL;

//+------------------------------------------------------------------+
//| Expert initialization                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   g_executor = new COrderExecutor();
   if(g_executor == NULL)
   {
      Print("Failed to create Order Executor");
      return INIT_FAILED;
   }
   g_executor.Init(123456, "ASQ_Exec");

   Print("ASQ Order Executor initialized successfully");
   Print("Max retries: ", InpMaxRetries);
   Print("Max slippage: ", InpMaxSlippagePts, " pts");
   Print("Max spread: ", InpMaxSpreadPts, " pts");

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(g_executor != NULL)
   {
      g_executor.PrintReport();
      delete g_executor;
      g_executor = NULL;
   }
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- This is a library EA - the executor is used by other components
   //--- Example usage: g_executor.Buy(_Symbol, 0.10, sl, tp, "test");
}

//+------------------------------------------------------------------+
//| Example: Execute a simple buy with retry logic                   |
//+------------------------------------------------------------------+
void ExampleBuyOrder()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   double sl = NormalizeDouble(ask - 100 * point, digits);
   double tp = NormalizeDouble(ask + 200 * point, digits);

   ulong ticket = g_executor.Buy(_Symbol, 0.10, sl, tp, "ASQ_Buy");
   if(ticket > 0)
      Print("Buy order placed: ticket ", ticket);
   else
      Print("Buy order failed");
}

//+------------------------------------------------------------------+
//| Example: Trailing stop management using executor                  |
//+------------------------------------------------------------------+
void ManageTrailingStop(ulong ticket, int trailPoints, int trailStart = 0)
{
   if(!PositionSelectByTicket(ticket))
      return;

   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   double currentSL = PositionGetDouble(POSITION_SL);
   ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

   if(posType == POSITION_TYPE_BUY)
   {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double profit = (bid - openPrice) / point;

      if(trailStart > 0 && profit < trailStart)
         return;

      double newSL = NormalizeDouble(bid - trailPoints * point, digits);
      if(newSL > currentSL + point)
         g_executor.ModifyPosition(ticket, newSL, PositionGetDouble(POSITION_TP));
   }
   else
   {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double profit = (openPrice - ask) / point;

      if(trailStart > 0 && profit < trailStart)
         return;

      double newSL = NormalizeDouble(ask + trailPoints * point, digits);
      if(currentSL == 0 || newSL < currentSL - point)
         g_executor.ModifyPosition(ticket, newSL, PositionGetDouble(POSITION_TP));
   }
}
//+------------------------------------------------------------------+
