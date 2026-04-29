//+------------------------------------------------------------------+
//| Easy_Range_Breakout_EA.mq5                                       |
//| Range Breakout Trading Strategy for MT5                          |
//| Source: MQL5 Code Library #68764                                 |
//| Rating: 5.0/4.0                                                  |
//|                                                                  |
//| Description:                                                     |
//|   This EA implements a range breakout trading strategy. It       |
//|   calculates a price range between start and end times defined   |
//|   by the user, draws a visual rectangle on the chart to mark     |
//|   the high and low of the range, and enters trades when price    |
//|   breaks out of the range. Includes stop loss, take profit,      |
//|   and session filtering.                                         |
//+------------------------------------------------------------------+
#property copyright "MQL5 Code Library"
#property version   "2.00"
#property strict

#include <Trade\Trade.mqh>

input group "=== Range Settings ==="
input int      InpRangeStartHour   = 8;        // Range start hour (server time)
input int      InpRangeStartMin    = 0;        // Range start minute
input int      InpRangeEndHour     = 10;       // Range end hour (server time)
input int      InpRangeEndMin      = 0;        // Range end minute
input bool     InpShowRangeRect    = true;     // Draw range rectangle on chart
input color    InpRangeColor       = clrDodgerBlue; // Range rectangle color

input group "=== Trade Settings ==="
input double   InpLotSize          = 0.10;     // Lot size
input int      InpSLPoints         = 100;      // Stop loss in points (0=range size)
input int      InpTPPoints         = 200;      // Take profit in points (0=auto)
input int      InpBreakBufferPts   = 10;       // Breakout buffer in points
input int      InpMaxTradesPerDay  = 2;        // Max trades per day
input ulong    InpMagicNumber      = 687640;   // Magic number

input group "=== Filters ==="
input bool     InpUseVolumeFilter  = false;    // Require volume spike for breakout
input double   InpVolumeMultiplier = 1.5;      // Volume multiplier for filter
input int      InpMinRangePoints   = 20;       // Minimum range size (points)
input int      InpMaxRangePoints   = 500;      // Maximum range size (points)
input bool     InpCloseAtEndOfDay  = true;     // Close positions at end of day
input int      InpCloseHour        = 23;       // Hour to close all positions

input group "=== Trailing Stop ==="
input bool     InpUseTrailingStop  = false;    // Enable trailing stop
input int      InpTrailStartPts    = 100;      // Trailing start (points)
input int      InpTrailStepPts     = 50;       // Trailing step (points)

//--- Global variables
CTrade      m_trade;
double      g_rangeHigh = 0;
double      g_rangeLow = 0;
datetime    g_rangeStartTime = 0;
datetime    g_rangeEndTime = 0;
datetime    g_lastTradeDate = 0;
int         g_tradesToday = 0;
bool        g_rangeCalculated = false;
bool        g_breakoutTriggered = false;
string      g_rectName = "RangeRect";
string      g_labelPrefix = "RangeBreak_";

//+------------------------------------------------------------------+
//| Expert initialization                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   m_trade.SetExpertMagicNumber(InpMagicNumber);
   m_trade.SetDeviationInPoints(30);
   m_trade.SetTypeFilling(ORDER_FILLING_IOC);

   Print("Easy Range Breakout EA initialized");
   Print("Range: ", InpRangeStartHour, ":", StringFormat("%02d", InpRangeStartMin),
         " - ", InpRangeEndHour, ":", StringFormat("%02d", InpRangeEndMin));

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, g_labelPrefix);
   ObjectsDeleteAll(0, g_rectName);
   Comment("");
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   MqlDateTime dt;
   TimeCurrent(dt);

   //--- Reset daily counter
   datetime today = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
   if(today != g_lastTradeDate)
   {
      g_lastTradeDate = today;
      g_tradesToday = 0;
      g_rangeCalculated = false;
      g_breakoutTriggered = false;
   }

   //--- Calculate range
   if(!g_rangeCalculated)
      CalculateRange();

   //--- End of day close
   if(InpCloseAtEndOfDay && dt.hour >= InpCloseHour)
   {
      CloseAllPositions();
      return;
   }

   //--- Monitor for breakout
   if(g_rangeCalculated && !g_breakoutTriggered)
      MonitorBreakout();

   //--- Manage trailing stops
   if(InpUseTrailingStop)
      ManageTrailingStops();

   //--- Update display
   UpdateDisplay();
}

//+------------------------------------------------------------------+
//| Calculate the trading range from historical data                 |
//+------------------------------------------------------------------+
void CalculateRange()
{
   MqlDateTime dt;
   TimeCurrent(dt);

   //--- Check if we're past the range end time
   if(dt.hour < InpRangeEndHour || (dt.hour == InpRangeEndHour && dt.min < InpRangeEndMin))
      return;

   //--- Find range start and end bars
   datetime rangeStart = TimeCurrent();
   datetime rangeEnd = TimeCurrent();

   MqlDateTime startDt = dt;
   startDt.hour = InpRangeStartHour;
   startDt.min = InpRangeStartMin;
   startDt.sec = 0;
   rangeStart = StructToTime(startDt);

   MqlDateTime endDt = dt;
   endDt.hour = InpRangeEndHour;
   endDt.min = InpRangeEndMin;
   endDt.sec = 0;
   rangeEnd = StructToTime(endDt);

   //--- Get high and low of range
   int startBar = iBarShift(_Symbol, PERIOD_M1, rangeStart);
   int endBar = iBarShift(_Symbol, PERIOD_M1, rangeEnd);

   if(startBar < 0 || endBar < 0 || startBar <= endBar)
   {
      Print("Cannot find range bars. Start: ", startBar, " End: ", endBar);
      return;
   }

   g_rangeHigh = iHigh(_Symbol, PERIOD_M1, iHighest(_Symbol, PERIOD_M1, MODE_HIGH, startBar - endBar + 1, endBar));
   g_rangeLow = iLow(_Symbol, PERIOD_M1, iLowest(_Symbol, PERIOD_M1, MODE_LOW, startBar - endBar + 1, endBar));

   double rangeSize = g_rangeHigh - g_rangeLow;
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double rangePoints = rangeSize / point;

   //--- Validate range size
   if(rangePoints < InpMinRangePoints)
   {
      Print("Range too small: ", DoubleToString(rangePoints, 0), " points. Min: ", InpMinRangePoints);
      g_rangeCalculated = false;
      return;
   }

   if(InpMaxRangePoints > 0 && rangePoints > InpMaxRangePoints)
   {
      Print("Range too large: ", DoubleToString(rangePoints, 0), " points. Max: ", InpMaxRangePoints);
      g_rangeCalculated = false;
      return;
   }

   g_rangeStartTime = rangeStart;
   g_rangeEndTime = rangeEnd;
   g_rangeCalculated = true;

   //--- Draw range rectangle
   if(InpShowRangeRect)
      DrawRangeRectangle();

   Print("Range calculated: High=", DoubleToString(g_rangeHigh, _Digits),
         " Low=", DoubleToString(g_rangeLow, _Digits),
         " Size=", DoubleToString(rangePoints, 0), " points");
}

//+------------------------------------------------------------------+
//| Monitor for range breakout                                       |
//+------------------------------------------------------------------+
void MonitorBreakout()
{
   if(g_tradesToday >= InpMaxTradesPerDay)
      return;

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double buffer = InpBreakBufferPts * point;

   //--- Volume filter
   if(InpUseVolumeFilter)
   {
      long currentVol = iVolume(_Symbol, PERIOD_M1, 0);
      double avgVol = 0;
      for(int i = 1; i <= 20; i++)
         avgVol += (double)iVolume(_Symbol, PERIOD_M1, i);
      avgVol /= 20.0;

      if(currentVol < avgVol * InpVolumeMultiplier)
         return;
   }

   //--- Check for bullish breakout
   if(bid > g_rangeHigh + buffer)
   {
      double sl = 0, tp = 0;

      if(InpSLPoints > 0)
         sl = NormalizeDouble(ask - InpSLPoints * point, _Digits);
      else
         sl = NormalizeDouble(g_rangeLow, _Digits);

      if(InpTPPoints > 0)
         tp = NormalizeDouble(ask + InpTPPoints * point, _Digits);
      else
         tp = NormalizeDouble(ask + (g_rangeHigh - g_rangeLow), _Digits);

      if(m_trade.Buy(InpLotSize, _Symbol, ask, sl, tp, "RangeBreak_Buy"))
      {
         g_tradesToday++;
         g_breakoutTriggered = true;
         Print("BUY breakout at ", DoubleToString(ask, _Digits));
      }
   }
   //--- Check for bearish breakout
   else if(ask < g_rangeLow - buffer)
   {
      double sl = 0, tp = 0;

      if(InpSLPoints > 0)
         sl = NormalizeDouble(bid + InpSLPoints * point, _Digits);
      else
         sl = NormalizeDouble(g_rangeHigh, _Digits);

      if(InpTPPoints > 0)
         tp = NormalizeDouble(bid - InpTPPoints * point, _Digits);
      else
         tp = NormalizeDouble(bid - (g_rangeHigh - g_rangeLow), _Digits);

      if(m_trade.Sell(InpLotSize, _Symbol, bid, sl, tp, "RangeBreak_Sell"))
      {
         g_tradesToday++;
         g_breakoutTriggered = true;
         Print("SELL breakout at ", DoubleToString(bid, _Digits));
      }
   }
}

//+------------------------------------------------------------------+
//| Manage trailing stops on open positions                          |
//+------------------------------------------------------------------+
void ManageTrailingStops()
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;

      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);
      double currentTP = PositionGetDouble(POSITION_TP);

      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      if(posType == POSITION_TYPE_BUY)
      {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double profit = (bid - openPrice) / point;

         if(profit >= InpTrailStartPts)
         {
            double newSL = NormalizeDouble(bid - InpTrailStepPts * point, _Digits);
            if(newSL > currentSL + point)
               m_trade.PositionModify(ticket, newSL, currentTP);
         }
      }
      else
      {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double profit = (openPrice - ask) / point;

         if(profit >= InpTrailStartPts)
         {
            double newSL = NormalizeDouble(ask + InpTrailStepPts * point, _Digits);
            if(currentSL == 0 || newSL < currentSL - point)
               m_trade.PositionModify(ticket, newSL, currentTP);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      m_trade.PositionClose(ticket);
   }
}

//+------------------------------------------------------------------+
//| Draw range rectangle on chart                                    |
//+------------------------------------------------------------------+
void DrawRangeRectangle()
{
   ObjectDelete(0, g_rectName);
   ObjectCreate(0, g_rectName, OBJ_RECTANGLE, 0, g_rangeStartTime, g_rangeHigh, g_rangeEndTime, g_rangeLow);
   ObjectSetInteger(0, g_rectName, OBJPROP_COLOR, InpRangeColor);
   ObjectSetInteger(0, g_rectName, OBJPROP_FILL, true);
   ObjectSetInteger(0, g_rectName, OBJPROP_BACK, true);
   ObjectSetInteger(0, g_rectName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, g_rectName, OBJPROP_SELECTABLE, false);

   //--- Draw breakout levels
   string highLine = g_labelPrefix + "HighLine";
   string lowLine = g_labelPrefix + "LowLine";

   ObjectCreate(0, highLine, OBJ_TREND, 0, g_rangeEndTime, g_rangeHigh, TimeCurrent(), g_rangeHigh);
   ObjectSetInteger(0, highLine, OBJPROP_COLOR, clrLime);
   ObjectSetInteger(0, highLine, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, highLine, OBJPROP_RAY_RIGHT, true);

   ObjectCreate(0, lowLine, OBJ_TREND, 0, g_rangeEndTime, g_rangeLow, TimeCurrent(), g_rangeLow);
   ObjectSetInteger(0, lowLine, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, lowLine, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, lowLine, OBJPROP_RAY_RIGHT, true);
}

//+------------------------------------------------------------------+
//| Update chart display                                             |
//+------------------------------------------------------------------+
void UpdateDisplay()
{
   string display = "";
   display += "=== Easy Range Breakout EA ===\n";
   display += "Range: " + DoubleToString(g_rangeHigh, _Digits) +
              " - " + DoubleToString(g_rangeLow, _Digits) + "\n";
   display += "Size: " + DoubleToString((g_rangeHigh - g_rangeLow) / SymbolInfoDouble(_Symbol, SYMBOL_POINT), 0) + " pts\n";
   display += "Calculated: " + (g_rangeCalculated ? "YES" : "NO") + "\n";
   display += "Breakout: " + (g_breakoutTriggered ? "TRIGGERED" : "Waiting") + "\n";
   display += "Trades today: " + IntegerToString(g_tradesToday) + "/" + IntegerToString(InpMaxTradesPerDay) + "\n";
   Comment(display);
}
//+------------------------------------------------------------------+
