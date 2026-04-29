//+------------------------------------------------------------------+
//| RSI_Grid_EA_Pro.mq5                                              |
//| RSI-based entries with adaptive grid recovery system              |
//| Source: MQL5 Code Library #71700                                 |
//| Rating: 5.0/5.0                                                  |
//|                                                                  |
//| Description:                                                     |
//|   RSI Grid Overlap Pro is a professional MT5 Expert Advisor      |
//|   combining RSI-based market entries with an adaptive grid        |
//|   recovery system. Features intelligent overlap order management  |
//|   to reduce drawdown, plus visual dashboard with trade stats.     |
//+------------------------------------------------------------------+
#property copyright "MQL5 Code Library"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

input group "=== RSI Settings ==="
input int      InpRSIPeriod        = 14;       // RSI period
input double   InpRSIOverbought    = 70.0;     // RSI overbought level
input double   InpRSIOversold      = 30.0;     // RSI oversold level
input ENUM_TIMEFRAMES InpRSITimeframe = PERIOD_H1; // RSI timeframe

input group "=== Entry Settings ==="
input double   InpEntryLots        = 0.10;     // Entry lot size
input int      InpStopLossPts      = 200;      // Stop loss (points)
input int      InpTakeProfitPts    = 300;      // Take profit (points)
input ulong    InpMagicNumber      = 717000;   // Magic number

input group "=== Grid Recovery ==="
input bool     InpUseGridRecovery  = true;     // Enable grid recovery
input int      InpGridSpacingPts   = 150;      // Grid spacing (points)
input int      InpMaxGridLevels    = 5;        // Max grid levels
input double   InpGridLotMultiplier = 1.5;     // Lot multiplier per level
input double   InpGridTakeProfitPts = 200;     // Grid TP (points)

input group "=== Overlap Management ==="
input bool     InpUseOverlap       = true;     // Enable overlap management
input double   InpOverlapProfitThreshold = 5.0; // Min profit for overlap close ($)

input group "=== Filters ==="
input int      InpMinBarsBetweenEntries = 3;   // Min bars between entries
input bool     InpTradeOnNewBarOnly = true;    // Trade only on new bar
input int      InpMaxSpreadPts     = 50;       // Max spread (points)
input double   InpMaxDailyLossPct  = 5.0;      // Max daily loss %

//--- Global variables
CTrade      m_trade;
int         g_rsiHandle = INVALID_HANDLE;
datetime    g_lastBarTime = 0;
datetime    g_lastTradeTime = 0;
int         g_barsSinceTrade = 999;
datetime    g_dayStart = 0;
double      g_dayStartBalance = 0;

struct GridState
{
   int      direction;      // 1=buy, -1=sell, 0=none
   int      levels;
   double   avgEntryPrice;
   double   totalLots;
   double   totalProfit;
   ulong    tickets[];
};

GridState g_grid;

//+------------------------------------------------------------------+
int OnInit()
{
   m_trade.SetExpertMagicNumber(InpMagicNumber);
   m_trade.SetDeviationInPoints(30);

   g_rsiHandle = iRSI(_Symbol, InpRSITimeframe, InpRSIPeriod, PRICE_CLOSE);
   if(g_rsiHandle == INVALID_HANDLE)
   {
      Print("Failed to create RSI indicator");
      return INIT_FAILED;
   }

   ZeroMemory(g_grid);
   g_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(g_rsiHandle != INVALID_HANDLE)
      IndicatorRelease(g_rsiHandle);
   Comment("");
}

//+------------------------------------------------------------------+
void OnTick()
{
   //--- Daily reset
   datetime today = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
   if(today != g_dayStart)
   {
      g_dayStart = today;
      g_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   }

   //--- Check daily loss limit
   if(InpMaxDailyLossPct > 0)
   {
      double dayPnl = AccountInfoDouble(ACCOUNT_EQUITY) - g_dayStartBalance;
      if(dayPnl < 0 && MathAbs(dayPnl) / g_dayStartBalance * 100 >= InpMaxDailyLossPct)
      {
         CloseAllPositions("Daily loss limit");
         return;
      }
   }

   //--- Get RSI value
   double rsi[];
   if(CopyBuffer(g_rsiHandle, 0, 0, 2, rsi) < 2)
      return;
   ArraySetAsSeries(rsi, true);

   //--- New bar check
   datetime currentBar = iTime(_Symbol, InpRSITimeframe, 0);
   bool newBar = (currentBar != g_lastBarTime);
   if(newBar)
   {
      g_lastBarTime = currentBar;
      g_barsSinceTrade++;
   }

   //--- Manage existing grid
   if(g_grid.levels > 0)
      ManageGrid();

   //--- Overlap management
   if(InpUseOverlap && g_grid.levels > 2)
      ManageOverlaps();

   //--- New entry signals
   if(!InpTradeOnNewBarOnly || newBar)
   {
      if(g_grid.levels == 0 && g_barsSinceTrade >= InpMinBarsBetweenEntries)
         CheckEntrySignal(rsi[1]);
      else if(InpUseGridRecovery && g_grid.levels > 0 && g_grid.levels < InpMaxGridLevels)
         CheckGridRecovery();
   }

   UpdateDashboard(rsi[0]);
}

//+------------------------------------------------------------------+
void CheckEntrySignal(double rsiValue)
{
   double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   if(spread > InpMaxSpreadPts) return;

   if(rsiValue <= InpRSIOversold)
   {
      //--- Buy signal
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double sl = (InpStopLossPts > 0) ? NormalizeDouble(ask - InpStopLossPts * point, _Digits) : 0;
      double tp = (InpTakeProfitPts > 0) ? NormalizeDouble(ask + InpTakeProfitPts * point, _Digits) : 0;

      if(m_trade.Buy(InpEntryLots, _Symbol, ask, sl, tp, "RSI_Grid_Buy"))
      {
         InitGrid(1, m_trade.ResultOrder(), ask, InpEntryLots);
         g_barsSinceTrade = 0;
         Print("BUY entry at RSI=", DoubleToString(rsiValue, 1));
      }
   }
   else if(rsiValue >= InpRSIOverbought)
   {
      //--- Sell signal
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double sl = (InpStopLossPts > 0) ? NormalizeDouble(bid + InpStopLossPts * point, _Digits) : 0;
      double tp = (InpTakeProfitPts > 0) ? NormalizeDouble(bid - InpTakeProfitPts * point, _Digits) : 0;

      if(m_trade.Sell(InpEntryLots, _Symbol, bid, sl, tp, "RSI_Grid_Sell"))
      {
         InitGrid(-1, m_trade.ResultOrder(), bid, InpEntryLots);
         g_barsSinceTrade = 0;
         Print("SELL entry at RSI=", DoubleToString(rsiValue, 1));
      }
   }
}

//+------------------------------------------------------------------+
void InitGrid(int direction, ulong ticket, double price, double lots)
{
   g_grid.direction = direction;
   g_grid.levels = 1;
   g_grid.avgEntryPrice = price;
   g_grid.totalLots = lots;
   ArrayResize(g_grid.tickets, 1);
   g_grid.tickets[0] = ticket;
}

//+------------------------------------------------------------------+
void CheckGridRecovery()
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double spacing = InpGridSpacingPts * point;

   //--- Calculate next grid level price
   double nextLevelPrice;
   if(g_grid.direction == 1)
      nextLevelPrice = g_grid.avgEntryPrice - g_grid.levels * spacing;
   else
      nextLevelPrice = g_grid.avgEntryPrice + g_grid.levels * spacing;

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   //--- Check if price reached next grid level
   bool trigger = false;
   if(g_grid.direction == 1 && ask <= nextLevelPrice)
      trigger = true;
   else if(g_grid.direction == -1 && bid >= nextLevelPrice)
      trigger = true;

   if(!trigger) return;

   //--- Calculate lot size for this level
   double lots = InpEntryLots;
   for(int i = 0; i < g_grid.levels; i++)
      lots *= InpGridLotMultiplier;
   lots = NormalizeDouble(lots, 2);

   //--- Place grid order
   bool success = false;
   if(g_grid.direction == 1)
      success = m_trade.Buy(lots, _Symbol, ask, 0, 0, "RSI_Grid_R" + IntegerToString(g_grid.levels));
   else
      success = m_trade.Sell(lots, _Symbol, bid, 0, 0, "RSI_Grid_R" + IntegerToString(g_grid.levels));

   if(success)
   {
      g_grid.levels++;
      g_grid.totalLots += lots;

      //--- Update average entry price
      g_grid.avgEntryPrice = (g_grid.avgEntryPrice * (g_grid.totalLots - lots) +
                              (g_grid.direction == 1 ? ask : bid) * lots) / g_grid.totalLots;

      int size = ArraySize(g_grid.tickets);
      ArrayResize(g_grid.tickets, size + 1);
      g_grid.tickets[size] = m_trade.ResultOrder();

      //--- Set take profit for all grid positions
      double tp;
      if(g_grid.direction == 1)
         tp = NormalizeDouble(g_grid.avgEntryPrice + InpGridTakeProfitPts * point, _Digits);
      else
         tp = NormalizeDouble(g_grid.avgEntryPrice - InpGridTakeProfitPts * point, _Digits);

      for(int i = 0; i < ArraySize(g_grid.tickets); i++)
      {
         if(PositionSelectByTicket(g_grid.tickets[i]))
            m_trade.PositionModify(g_grid.tickets[i], 0, tp);
      }

      Print("Grid level ", g_grid.levels - 1, " at ", DoubleToString(g_grid.direction == 1 ? ask : bid, _Digits),
            " Lots: ", DoubleToString(lots, 2), " Avg: ", DoubleToString(g_grid.avgEntryPrice, _Digits));
   }
}

//+------------------------------------------------------------------+
void ManageGrid()
{
   //--- Check if any grid position was closed (TP hit)
   bool anyClosed = false;
   for(int i = 0; i < ArraySize(g_grid.tickets); i++)
   {
      if(!PositionSelectByTicket(g_grid.tickets[i]))
      {
         anyClosed = true;
         break;
      }
   }

   if(anyClosed)
   {
      //--- Check if all are closed
      bool allClosed = true;
      for(int i = 0; i < ArraySize(g_grid.tickets); i++)
      {
         if(PositionSelectByTicket(g_grid.tickets[i]))
         {
            allClosed = false;
            break;
         }
      }

      if(allClosed)
      {
         Print("Grid fully closed. Levels: ", g_grid.levels);
         ZeroMemory(g_grid);
      }
   }
}

//+------------------------------------------------------------------+
void ManageOverlaps()
{
   double totalProfit = 0;
   for(int i = 0; i < ArraySize(g_grid.tickets); i++)
   {
      if(PositionSelectByTicket(g_grid.tickets[i]))
         totalProfit += PositionGetDouble(POSITION_PROFIT);
   }

   //--- If overall profit exceeds threshold, close the worst losing position
   if(totalProfit > InpOverlapProfitThreshold)
   {
      ulong worstTicket = 0;
      double worstPnl = 0;

      for(int i = 0; i < ArraySize(g_grid.tickets); i++)
      {
         if(PositionSelectByTicket(g_grid.tickets[i]))
         {
            double pnl = PositionGetDouble(POSITION_PROFIT);
            if(pnl < worstPnl)
            {
               worstPnl = pnl;
               worstTicket = g_grid.tickets[i];
            }
         }
      }

      if(worstTicket > 0 && worstPnl < 0)
      {
         m_trade.PositionClose(worstTicket);
         Print("Overlap close: ticket ", worstTicket, " P/L: $", DoubleToString(worstPnl, 2));
      }
   }
}

//+------------------------------------------------------------------+
void CloseAllPositions(string reason)
{
   Print("Closing all positions: ", reason);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      m_trade.PositionClose(ticket);
   }
   ZeroMemory(g_grid);
}

//+------------------------------------------------------------------+
void UpdateDashboard(double currentRSI)
{
   string dash = "=== RSI Grid EA Pro ===\n";
   dash += "RSI(" + IntegerToString(InpRSIPeriod) + "): " + DoubleToString(currentRSI, 1) + "\n";

   if(g_grid.levels > 0)
   {
      dash += "Grid Direction: " + (g_grid.direction == 1 ? "BUY" : "SELL") + "\n";
      dash += "Grid Levels: " + IntegerToString(g_grid.levels) + "/" + IntegerToString(InpMaxGridLevels) + "\n";
      dash += "Avg Entry: " + DoubleToString(g_grid.avgEntryPrice, _Digits) + "\n";
      dash += "Total Lots: " + DoubleToString(g_grid.totalLots, 2) + "\n";
      dash += "Grid P/L: $" + DoubleToString(CalculateGridProfit(), 2) + "\n";
   }
   else
      dash += "Status: Waiting for signal\n";

   Comment(dash);
}

//+------------------------------------------------------------------+
double CalculateGridProfit()
{
   double profit = 0;
   for(int i = 0; i < ArraySize(g_grid.tickets); i++)
   {
      if(PositionSelectByTicket(g_grid.tickets[i]))
         profit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   }
   return profit;
}
//+------------------------------------------------------------------+
