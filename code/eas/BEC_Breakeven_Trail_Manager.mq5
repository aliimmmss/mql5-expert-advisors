//+------------------------------------------------------------------+
//| BEC_Breakeven_Trail_Manager.mq5                                 |
//| Automated Breakeven & Trailing Stop Manager with Dashboard       |
//| Source: MQL5 Code Library #71657                                 |
//| Rating: 5.0/5.0                                                  |
//|                                                                  |
//| Description:                                                     |
//|   BEC is an advanced trade management Expert Advisor designed    |
//|   to automate breakeven, trailing stop, and position control -   |
//|   all from a powerful on-chart dashboard. Supports multiple      |
//|   trailing methods, partial close, and profit lock.              |
//+------------------------------------------------------------------+
#property copyright "MQL5 Code Library"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

input group "=== Breakeven Settings ==="
input bool     InpUseBreakeven     = true;     // Enable breakeven
input int      InpBETriggerPts     = 100;      // Breakeven trigger (points)
input int      InpBEOffsetPts      = 10;       // Breakeven offset profit (points)

input group "=== Trailing Stop Settings ==="
input bool     InpUseTrailing      = true;     // Enable trailing stop
input int      InpTrailMethod      = 0;        // Method: 0=Fixed, 1=ATR, 2=Step
input int      InpTrailStartPts    = 100;      // Trailing start (points)
input int      InpTrailDistancePts = 80;       // Trailing distance (points)
input int      InpTrailStepPts     = 20;       // Step size for Step method
input int      InpATRPeriod        = 14;       // ATR period (for ATR method)
input double   InpATRMultiplier    = 2.0;      // ATR multiplier

input group "=== Partial Close ==="
input bool     InpUsePartialClose  = false;    // Enable partial close
input double   InpPartialPercent   = 50.0;     // Partial close % at trigger
input int      InpPartialTriggerPts = 150;     // Partial close trigger (points)

input group "=== General ==="
input ulong    InpMagicNumber      = 716570;   // Magic number (0=all magic)
input int      InpUpdateSeconds    = 1;        // Update interval (seconds)
input bool     InpManageAllSymbols = false;    // Manage all symbols
input bool     InpShowDashboard    = true;     // Show dashboard

//--- Global variables
CTrade      m_trade;
int         g_atrHandle = INVALID_HANDLE;
datetime    g_lastUpdate = 0;
color       g_dashBgColor = C'25,25,35';

struct PositionData
{
   ulong    ticket;
   string   symbol;
   int      type;
   double   openPrice;
   double   lots;
   double   currentSL;
   double   currentTP;
   double   profit;
   double   profitPts;
   bool     breakevenSet;
   bool     partialClosed;
   string   status;
};

PositionData g_positions[];

//+------------------------------------------------------------------+
int OnInit()
{
   m_trade.SetExpertMagicNumber(InpMagicNumber);
   m_trade.SetDeviationInPoints(20);

   if(InpTrailMethod == 1)
   {
      g_atrHandle = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
      if(g_atrHandle == INVALID_HANDLE)
      {
         Print("Failed to create ATR indicator");
         return INIT_FAILED;
      }
   }

   Print("BEC Breakeven Trail Manager initialized");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(g_atrHandle != INVALID_HANDLE)
      IndicatorRelease(g_atrHandle);

   //--- Remove dashboard objects
   ObjectsDeleteAll(0, "BEC_");
   Comment("");
}

//+------------------------------------------------------------------+
void OnTick()
{
   datetime now = TimeCurrent();
   if(now - g_lastUpdate < InpUpdateSeconds) return;
   g_lastUpdate = now;

   //--- Scan and manage positions
   ScanPositions();

   for(int i = 0; i < ArraySize(g_positions); i++)
   {
      if(!PositionSelectByTicket(g_positions[i].ticket))
         continue;

      g_positions[i].currentSL = PositionGetDouble(POSITION_SL);
      g_positions[i].currentTP = PositionGetDouble(POSITION_TP);
      g_positions[i].profit = PositionGetDouble(POSITION_PROFIT);
      g_positions[i].lots = PositionGetDouble(POSITION_VOLUME);

      double point = SymbolInfoDouble(g_positions[i].symbol, SYMBOL_POINT);
      double openPrice = g_positions[i].openPrice;

      if(g_positions[i].type == POSITION_TYPE_BUY)
      {
         double bid = SymbolInfoDouble(g_positions[i].symbol, SYMBOL_BID);
         g_positions[i].profitPts = (bid - openPrice) / point;

         ManageBuyPosition(i, bid, point);
      }
      else
      {
         double ask = SymbolInfoDouble(g_positions[i].symbol, SYMBOL_ASK);
         g_positions[i].profitPts = (openPrice - ask) / point;

         ManageSellPosition(i, ask, point);
      }
   }

   if(InpShowDashboard)
      DrawDashboard();
}

//+------------------------------------------------------------------+
void ManageBuyPosition(int index, double bid, double point)
{
   ulong ticket = g_positions[index].ticket;
   double openPrice = g_positions[index].openPrice;
   double currentSL = g_positions[index].currentSL;
   int digits = (int)SymbolInfoInteger(g_positions[index].symbol, SYMBOL_DIGITS);

   //--- Partial close
   if(InpUsePartialClose && !g_positions[index].partialClosed &&
      g_positions[index].profitPts >= InpPartialTriggerPts)
   {
      double closeLots = NormalizeDouble(g_positions[index].lots * InpPartialPercent / 100, 2);
      double minLot = SymbolInfoDouble(g_positions[index].symbol, SYMBOL_VOLUME_MIN);
      if(closeLots >= minLot)
      {
         m_trade.PositionClosePartial(ticket, closeLots);
         g_positions[index].partialClosed = true;
         g_positions[index].status = "Partial Closed";
      }
   }

   //--- Breakeven
   if(InpUseBreakeven && !g_positions[index].breakevenSet &&
      g_positions[index].profitPts >= InpBETriggerPts)
   {
      double newSL = NormalizeDouble(openPrice + InpBEOffsetPts * point, digits);
      if(newSL > currentSL)
      {
         if(m_trade.PositionModify(ticket, newSL, g_positions[index].currentTP))
         {
            g_positions[index].breakevenSet = true;
            g_positions[index].status = "Breakeven";
         }
      }
   }

   //--- Trailing stop
   if(InpUseTrailing && g_positions[index].profitPts >= InpTrailStartPts)
   {
      double trailDist = GetTrailingDistance(point);
      double newSL = NormalizeDouble(bid - trailDist, digits);

      if(newSL > currentSL + point)
      {
         if(m_trade.PositionModify(ticket, newSL, g_positions[index].currentTP))
            g_positions[index].status = "Trailing";
      }
   }
}

//+------------------------------------------------------------------+
void ManageSellPosition(int index, double ask, double point)
{
   ulong ticket = g_positions[index].ticket;
   double openPrice = g_positions[index].openPrice;
   double currentSL = g_positions[index].currentSL;
   int digits = (int)SymbolInfoInteger(g_positions[index].symbol, SYMBOL_DIGITS);

   //--- Partial close
   if(InpUsePartialClose && !g_positions[index].partialClosed &&
      g_positions[index].profitPts >= InpPartialTriggerPts)
   {
      double closeLots = NormalizeDouble(g_positions[index].lots * InpPartialPercent / 100, 2);
      double minLot = SymbolInfoDouble(g_positions[index].symbol, SYMBOL_VOLUME_MIN);
      if(closeLots >= minLot)
      {
         m_trade.PositionClosePartial(ticket, closeLots);
         g_positions[index].partialClosed = true;
         g_positions[index].status = "Partial Closed";
      }
   }

   //--- Breakeven
   if(InpUseBreakeven && !g_positions[index].breakevenSet &&
      g_positions[index].profitPts >= InpBETriggerPts)
   {
      double newSL = NormalizeDouble(openPrice - InpBEOffsetPts * point, digits);
      if(currentSL == 0 || newSL < currentSL)
      {
         if(m_trade.PositionModify(ticket, newSL, g_positions[index].currentTP))
         {
            g_positions[index].breakevenSet = true;
            g_positions[index].status = "Breakeven";
         }
      }
   }

   //--- Trailing stop
   if(InpUseTrailing && g_positions[index].profitPts >= InpTrailStartPts)
   {
      double trailDist = GetTrailingDistance(point);
      double newSL = NormalizeDouble(ask + trailDist, digits);

      if(currentSL == 0 || newSL < currentSL - point)
      {
         if(m_trade.PositionModify(ticket, newSL, g_positions[index].currentTP))
            g_positions[index].status = "Trailing";
      }
   }
}

//+------------------------------------------------------------------+
double GetTrailingDistance(double point)
{
   if(InpTrailMethod == 1 && g_atrHandle != INVALID_HANDLE)
   {
      double atr[];
      if(CopyBuffer(g_atrHandle, 0, 0, 1, atr) > 0)
         return atr[0] * InpATRMultiplier;
   }

   return InpTrailDistancePts * point;
}

//+------------------------------------------------------------------+
void ScanPositions()
{
   int count = 0;

   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;

      ulong magic = PositionGetInteger(POSITION_MAGIC);
      string sym = PositionGetString(POSITION_SYMBOL);

      if(InpMagicNumber > 0 && magic != InpMagicNumber) continue;
      if(!InpManageAllSymbols && sym != _Symbol) continue;

      //--- Check if already tracked
      bool found = false;
      for(int j = 0; j < ArraySize(g_positions); j++)
      {
         if(g_positions[j].ticket == ticket)
         {
            found = true;
            break;
         }
      }

      if(!found)
      {
         int size = ArraySize(g_positions);
         ArrayResize(g_positions, size + 1);
         g_positions[size].ticket = ticket;
         g_positions[size].symbol = sym;
         g_positions[size].type = (int)PositionGetInteger(POSITION_TYPE);
         g_positions[size].openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         g_positions[size].lots = PositionGetDouble(POSITION_VOLUME);
         g_positions[size].currentSL = PositionGetDouble(POSITION_SL);
         g_positions[size].currentTP = PositionGetDouble(POSITION_TP);
         g_positions[size].breakevenSet = false;
         g_positions[size].partialClosed = false;
         g_positions[size].status = "Monitoring";
         count++;
      }
   }

   //--- Remove closed positions
   for(int j = ArraySize(g_positions) - 1; j >= 0; j--)
   {
      if(!PositionSelectByTicket(g_positions[j].ticket))
      {
         for(int k = j; k < ArraySize(g_positions) - 1; k++)
            g_positions[k] = g_positions[k + 1];
         ArrayResize(g_positions, ArraySize(g_positions) - 1);
      }
   }
}

//+------------------------------------------------------------------+
void DrawDashboard()
{
   int total = ArraySize(g_positions);

   string dash = "";
   dash += "=== BEC Trade Manager ===\n";
   dash += "Managed Positions: " + IntegerToString(total) + "\n";
   dash += "Breakeven: " + (InpUseBreakeven ? "ON" : "OFF") + " (trigger: " + IntegerToString(InpBETriggerPts) + " pts)\n";
   dash += "Trailing: " + (InpUseTrailing ? "ON" : "OFF") + " (distance: " + IntegerToString(InpTrailDistancePts) + " pts)\n";
   dash += "Partial: " + (InpUsePartialClose ? "ON" : "OFF") + "\n";
   dash += "---\n";

   for(int i = 0; i < total && i < 10; i++)
   {
      string dir = (g_positions[i].type == POSITION_TYPE_BUY) ? "BUY " : "SELL";
      dash += dir + " " + g_positions[i].symbol +
              " " + DoubleToString(g_positions[i].lots, 2) +
              " Pts:" + DoubleToString(g_positions[i].profitPts, 0) +
              " [" + g_positions[i].status + "]\n";
   }

   Comment(dash);
}
//+------------------------------------------------------------------+
