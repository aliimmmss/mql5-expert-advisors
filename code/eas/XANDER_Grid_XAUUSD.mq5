//+------------------------------------------------------------------+
//| XANDER_Grid_XAUUSD.mq5                                          |
//| Bidirectional Grid EA for Gold (XAUUSD)                         |
//| Source: MQL5 Code Library #71776                                 |
//| Rating: 4.8/4.8                                                  |
//|                                                                  |
//| Description:                                                     |
//|   Bidirectional grid EA for Gold (XAUUSD). Ideal for ProCent    |
//|   accounts. Includes Daily Profit Target and Max Drawdown        |
//|   protection. Places grid orders above and below current price,  |
//|   profiting from price oscillation within the grid.              |
//+------------------------------------------------------------------+
#property copyright "MQL5 Code Library"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

input group "=== Grid Settings ==="
input double   InpGridSizeDollars  = 10.0;     // Grid size in price ($)
input int      InpMaxGridOrders    = 10;       // Max grid orders per side
input double   InpLotSize          = 0.01;     // Lot size per grid level
input double   InpLotMultiplier    = 1.2;      // Lot multiplier for recovery
input ulong    InpMagicNumber      = 717760;   // Magic number

input group "=== Profit Protection ==="
input double   InpDailyProfitTarget = 50.0;    // Daily profit target ($)
input double   InpMaxDailyLoss     = -100.0;   // Max daily loss ($)
input double   InpMaxDrawdownPct   = 20.0;     // Max drawdown % (0=disabled)
input double   InpTakeProfitGrid   = 15.0;     // Take profit per grid trade ($)

input group "=== Risk Management ==="
input bool     InpUseDailyReset    = true;      // Reset grid daily
input int      InpResetHour        = 0;        // Reset hour (server time)
input int      InpMaxSpreadPts     = 80;       // Max spread allowed
input bool     InpCloseOnFriday    = true;     // Close all on Friday
input int      InpFridayHour       = 20;       // Friday close hour

input group "=== Visual ==="
input bool     InpShowDashboard     = true;     // Show dashboard
input color    InpBuyGridColor      = clrDodgerBlue; // Buy grid lines
input color    InpSellGridColor     = clrOrangeRed;  // Sell grid lines

//--- Global variables
CTrade      m_trade;
double      g_centerPrice = 0;
double      g_dailyProfit = 0;
datetime    g_lastDay = 0;
bool        g_gridActive = false;
double      g_initialBalance = 0;
string      g_prefix = "XGrid_";

struct GridLevel
{
   double   price;
   double   lotSize;
   bool     hasOrder;
   ulong    ticket;
   int      side; // 1=buy, -1=sell
};

GridLevel g_buyGrid[];
GridLevel g_sellGrid[];

//+------------------------------------------------------------------+
int OnInit()
{
   m_trade.SetExpertMagicNumber(InpMagicNumber);
   m_trade.SetDeviationInPoints(30);

   g_initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);

   Print("XANDER Grid XAUUSD initialized");
   Print("Grid size: $", DoubleToString(InpGridSizeDollars, 2));
   Print("Max levels: ", InpMaxGridOrders, " per side");

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, g_prefix);
   Comment("");
}

//+------------------------------------------------------------------+
void OnTick()
{
   //--- Daily reset
   datetime today = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
   if(today != g_lastDay)
   {
      if(InpUseDailyReset && g_lastDay > 0)
         ResetGrid();
      g_lastDay = today;
      g_dailyProfit = 0;
   }

   //--- Friday close
   if(InpCloseOnFriday)
   {
      MqlDateTime dt;
      TimeCurrent(dt);
      if(dt.day_of_week == 5 && dt.hour >= InpFridayHour)
      {
         CloseAllAndReset();
         return;
      }
   }

   //--- Check daily limits
   double currentProfit = CalculateOpenProfit() + g_dailyProfit;
   if(InpDailyProfitTarget > 0 && currentProfit >= InpDailyProfitTarget)
   {
      CloseAllAndReset();
      Print("Daily profit target reached: $", DoubleToString(currentProfit, 2));
      return;
   }

   if(InpMaxDailyLoss < 0 && currentProfit <= InpMaxDailyLoss)
   {
      CloseAllAndReset();
      Print("Daily loss limit hit: $", DoubleToString(currentProfit, 2));
      return;
   }

   //--- Drawdown protection
   if(InpMaxDrawdownPct > 0)
   {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double drawdownPct = (g_initialBalance - equity) / g_initialBalance * 100;
      if(drawdownPct >= InpMaxDrawdownPct)
      {
         CloseAllAndReset();
         Print("Max drawdown reached: ", DoubleToString(drawdownPct, 1), "%");
         return;
      }
   }

   //--- Initialize or update grid
   if(!g_gridActive)
      InitializeGrid();
   else
      MonitorGrid();

   //--- Update display
   if(InpShowDashboard)
      UpdateDashboard();
}

//+------------------------------------------------------------------+
void InitializeGrid()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);

   if(spread > InpMaxSpreadPts)
   {
      Print("Spread too high for grid init: ", spread);
      return;
   }

   g_centerPrice = bid;
   ArrayResize(g_buyGrid, InpMaxGridOrders);
   ArrayResize(g_sellGrid, InpMaxGridOrders);

   //--- Create buy grid levels (below current price)
   for(int i = 0; i < InpMaxGridOrders; i++)
   {
      g_buyGrid[i].price = g_centerPrice - (i + 1) * InpGridSizeDollars;
      g_buyGrid[i].lotSize = CalculateGridLot(i);
      g_buyGrid[i].hasOrder = false;
      g_buyGrid[i].ticket = 0;
      g_buyGrid[i].side = 1;

      //--- Draw grid line
      if(InpShowDashboard)
      {
         string name = g_prefix + "Buy_" + IntegerToString(i);
         ObjectCreate(0, name, OBJ_HLINE, 0, 0, g_buyGrid[i].price);
         ObjectSetInteger(0, name, OBJPROP_COLOR, InpBuyGridColor);
         ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      }
   }

   //--- Create sell grid levels (above current price)
   for(int i = 0; i < InpMaxGridOrders; i++)
   {
      g_sellGrid[i].price = g_centerPrice + (i + 1) * InpGridSizeDollars;
      g_sellGrid[i].lotSize = CalculateGridLot(i);
      g_sellGrid[i].hasOrder = false;
      g_sellGrid[i].ticket = 0;
      g_sellGrid[i].side = -1;

      if(InpShowDashboard)
      {
         string name = g_prefix + "Sell_" + IntegerToString(i);
         ObjectCreate(0, name, OBJ_HLINE, 0, 0, g_sellGrid[i].price);
         ObjectSetInteger(0, name, OBJPROP_COLOR, InpSellGridColor);
         ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      }
   }

   g_gridActive = true;
   Print("Grid initialized at ", DoubleToString(g_centerPrice, _Digits));
}

//+------------------------------------------------------------------+
void MonitorGrid()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   //--- Check buy grid levels
   for(int i = 0; i < InpMaxGridOrders; i++)
   {
      if(!g_buyGrid[i].hasOrder && ask <= g_buyGrid[i].price)
      {
         double tp = g_buyGrid[i].price + InpTakeProfitGrid;
         if(m_trade.Buy(g_buyGrid[i].lotSize, _Symbol, ask, 0, tp, "XGrid_B"))
         {
            g_buyGrid[i].hasOrder = true;
            g_buyGrid[i].ticket = m_trade.ResultOrder();
            Print("Buy grid level ", i, " triggered at ", DoubleToString(ask, _Digits));
         }
      }

      //--- Reset grid level if TP hit
      if(g_buyGrid[i].hasOrder)
      {
         if(!PositionSelectByTicket(g_buyGrid[i].ticket))
         {
            g_buyGrid[i].hasOrder = false;
            g_buyGrid[i].ticket = 0;
            g_dailyProfit += InpTakeProfitGrid / point * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE) * g_buyGrid[i].lotSize;
         }
      }
   }

   //--- Check sell grid levels
   for(int i = 0; i < InpMaxGridOrders; i++)
   {
      if(!g_sellGrid[i].hasOrder && bid >= g_sellGrid[i].price)
      {
         double tp = g_sellGrid[i].price - InpTakeProfitGrid;
         if(m_trade.Sell(g_sellGrid[i].lotSize, _Symbol, bid, 0, tp, "XGrid_S"))
         {
            g_sellGrid[i].hasOrder = true;
            g_sellGrid[i].ticket = m_trade.ResultOrder();
            Print("Sell grid level ", i, " triggered at ", DoubleToString(bid, _Digits));
         }
      }

      if(g_sellGrid[i].hasOrder)
      {
         if(!PositionSelectByTicket(g_sellGrid[i].ticket))
         {
            g_sellGrid[i].hasOrder = false;
            g_sellGrid[i].ticket = 0;
         }
      }
   }
}

//+------------------------------------------------------------------+
double CalculateGridLot(int level)
{
   double lot = InpLotSize;
   for(int i = 0; i < level; i++)
      lot *= InpLotMultiplier;
   return NormalizeDouble(lot, 2);
}

//+------------------------------------------------------------------+
double CalculateOpenProfit()
{
   double profit = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      profit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   }
   return profit;
}

//+------------------------------------------------------------------+
void CloseAllAndReset()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      m_trade.PositionClose(ticket);
   }
   ResetGrid();
}

//+------------------------------------------------------------------+
void ResetGrid()
{
   ObjectsDeleteAll(0, g_prefix);
   ArrayFree(g_buyGrid);
   ArrayFree(g_sellGrid);
   g_gridActive = false;
   g_centerPrice = 0;
   Print("Grid reset");
}

//+------------------------------------------------------------------+
void UpdateDashboard()
{
   string dash = "";
   dash += "=== XANDER Grid XAUUSD ===\n";
   dash += "Center: $" + DoubleToString(g_centerPrice, 2) + "\n";
   dash += "Grid: $" + DoubleToString(InpGridSizeDollars, 2) + " x " + IntegerToString(InpMaxGridOrders) + "\n";
   dash += "Active Buy Orders: " + IntegerToString(CountActiveGridOrders(1)) + "\n";
   dash += "Active Sell Orders: " + IntegerToString(CountActiveGridOrders(-1)) + "\n";
   dash += "Open P/L: $" + DoubleToString(CalculateOpenProfit(), 2) + "\n";
   dash += "Daily P/L: $" + DoubleToString(g_dailyProfit + CalculateOpenProfit(), 2) + "\n";
   dash += "Target: $" + DoubleToString(InpDailyProfitTarget, 2) + "\n";
   Comment(dash);
}

//+------------------------------------------------------------------+
int CountActiveGridOrders(int side)
{
   int count = 0;
   if(side == 1)
   {
      for(int i = 0; i < InpMaxGridOrders; i++)
         if(g_buyGrid[i].hasOrder) count++;
   }
   else
   {
      for(int i = 0; i < InpMaxGridOrders; i++)
         if(g_sellGrid[i].hasOrder) count++;
   }
   return count;
}
//+------------------------------------------------------------------+
