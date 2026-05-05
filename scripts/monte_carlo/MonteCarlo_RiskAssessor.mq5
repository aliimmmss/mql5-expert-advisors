//+------------------------------------------------------------------+
//|                    MonteCarlo_RiskAssessor.mq5                   |
//|              Monte Carlo Trade Risk Analyzer — v1.00             |
//|         https://www.mql5.com/en/articles       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Duy Van Nguy."
#property link        "https://www.mql5.com/en/users/wazatrader"
#property version     "1.00"
#property description "Monte Carlo simulation for trading strategy risk assessment"
#property script_show_inputs


#include <Canvas\Canvas.mqh>

//--- ── Input parameters ─────────────────────────────────────────────
input string   InpCSVFile        = "trades.csv";      // CSV filename (place in MQL5\Files\)
input int      InpSimulations    = 1000;              // Number of Monte Carlo simulations
input double   InpInitialBalance = 10000.0;           // Starting account balance ($)
input double   InpRuinThreshold  = 0.2;              // Ruin threshold (0.50 = 50% drawdown)
input color    InpMedianColor    = clrDodgerBlue;     // Median curve color
input color    InpBandColor      = C'90,150,210';     // Percentile band base color

//--- ── Feature #3 : Commission & Slippage simulation ────────────────
input bool     InpSlippageEnabled = false;            // [Slippage] Enable commission/slippage sim
input double   InpCommission      = 2;              // [Slippage] Fixed commission per trade ($)
input double   InpSlippageMax     = 3;              // [Slippage] Max random slippage per trade ($)

//--- ── Feature #2 : Export results ──────────────────────────────────
input bool     InpExportCSV       = true;            // [Export] Write results to CSV file
input string   InpExportFile      = "mc_results.csv"; // [Export] Output CSV filename

//--- Canvas layout constants
#define CANVAS_W   900
#define CANVAS_H   580          // +20px to fit slippage row in stats panel
#define MARGIN_L    80
#define MARGIN_R    72          // Extended right margin for percentile labels
#define MARGIN_T    45
#define MARGIN_B   190          // +20px for slippage info row

//--- Percentile line colours (5th → 95th)
#define CLR_P05   clrTomato        // Red   – worst case
#define CLR_P25   clrOrange        // Orange
#define CLR_P75   clrYellowGreen   // Yellow-green
#define CLR_P95   clrLimeGreen     // Bright green – best case

//--- Global data storage
double g_Profits[];         // Trade P&L values loaded from CSV
double g_FinalEquities[];   // Final equity value for each simulation
double g_MaxDrawdowns[];    // Max drawdown (%) for each simulation
double g_AllCurves[];       // Flattened 2D: [simulation × (tradeCount+1)]
int    g_TradeCount = 0;    // Number of trades loaded from CSV
CCanvas g_Canvas;           // Canvas drawing object

//--- Shared summary metrics (filled by ComputeMetrics, used by Draw + Export)
double g_p05Eq, g_p50Eq, g_p95Eq;
double g_p50DD, g_p95DD;
double g_varAmt, g_probRuin;

//+------------------------------------------------------------------+
//| Load trade P&L from CSV into g_Profits[]                         |
//+------------------------------------------------------------------+
bool LoadTradesFromCSV(const string fileName)
  {
   int handle = FileOpen(fileName, FILE_READ | FILE_CSV | FILE_ANSI, ',');
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("ERROR: Cannot open '%s'. Verify file is in MQL5\\Files\\. Code: %d",
                  fileName, GetLastError());
      return false;
     }

   if(!FileIsEnding(handle))
      FileReadString(handle); // skip header row

   double buffer[];
   int    count = 0;

   while(!FileIsEnding(handle))
     {
      string row = FileReadString(handle);
      StringTrimRight(row);
      StringTrimLeft(row);
      if(StringLen(row) == 0)
         continue;

      string cols[];
      int nCols = StringSplit(row, ',', cols);

      double profit = 0.0;
      if(nCols >= 2)
         profit = StringToDouble(cols[1]);
      else if(nCols == 1)
         profit = StringToDouble(cols[0]);

      ArrayResize(buffer, count + 1, 1000);
      buffer[count++] = profit;
     }

   FileClose(handle);

   if(count == 0)
     {
      Print("ERROR: No valid trade data found. Check CSV format.");
      return false;
     }

   ArrayResize(g_Profits, count);
   ArrayCopy(g_Profits, buffer, 0, 0, count);
   g_TradeCount = count;

   PrintFormat("Loaded %d trades from '%s'.", count, fileName);
   return true;
  }

//+------------------------------------------------------------------+
//| Calculate peak-to-trough max drawdown (returns %)               |
//+------------------------------------------------------------------+
double CalcMaxDrawdown(const double &eq[], int len)
  {
   double peak  = eq[0];
   double maxDD = 0.0;

   for(int i = 1; i < len; i++)
     {
      if(eq[i] > peak)
         peak = eq[i];
      if(peak > 0.0)
        {
         double dd = (peak - eq[i]) / peak;
         if(dd > maxDD) maxDD = dd;
        }
     }
   return maxDD * 100.0;
  }

//+------------------------------------------------------------------+
//| Bootstrap Monte Carlo engine                                      |
//| Feature #3: optionally subtract commission + random slippage     |
//|   per sampled trade to stress-test realistic net P&L             |
//+------------------------------------------------------------------+
void RunMonteCarloSimulation()
  {
   int curveLen = g_TradeCount + 1;

   ArrayResize(g_FinalEquities, InpSimulations);
   ArrayResize(g_MaxDrawdowns,  InpSimulations);
   ArrayResize(g_AllCurves,     InpSimulations * curveLen);

   double equity[];
   ArrayResize(equity, curveLen);

   MathSrand((int)TimeLocal());

   for(int sim = 0; sim < InpSimulations; sim++)
     {
      equity[0] = InpInitialBalance;

      for(int t = 0; t < g_TradeCount; t++)
        {
         int    rIdx = MathRand() % g_TradeCount;
         double pnl  = g_Profits[rIdx];

         //--- Feature #3 ─────────────────────────────────────────────
         //  Apply fixed commission + uniform-random slippage [0, max]
         //  Both costs are deducted regardless of trade direction,
         //  which conservatively assumes worst-side fill.
         if(InpSlippageEnabled)
           {
            double slip = ((double)MathRand() / 32767.0) * InpSlippageMax;
            pnl -= (InpCommission + slip);
           }
         //-------------------------------------------------------------

         equity[t+1] = equity[t] + pnl;
        }

      g_FinalEquities[sim] = equity[g_TradeCount];
      g_MaxDrawdowns[sim]  = CalcMaxDrawdown(equity, curveLen);

      int offset = sim * curveLen;
      ArrayCopy(g_AllCurves, equity, offset, 0, curveLen);
     }
  }

//+------------------------------------------------------------------+
//| Percentile helper (linear interpolation on sorted copy)          |
//+------------------------------------------------------------------+
double Percentile(double &arr[], double pct)
  {
   int n = ArraySize(arr);
   if(n == 0) return 0.0;

   double tmp[];
   ArrayCopy(tmp, arr);
   ArraySort(tmp);

   double pos = pct * (n - 1);
   int    lo  = (int)MathFloor(pos);
   int    hi  = (int)MathCeil(pos);

   if(lo == hi) return tmp[lo];
   return tmp[lo] + (tmp[hi] - tmp[lo]) * (pos - lo);
  }

//+------------------------------------------------------------------+
//| Get equity percentile at a specific trade step                   |
//+------------------------------------------------------------------+
double PctAtStep(int step, double pct)
  {
   double vals[];
   ArrayResize(vals, InpSimulations);
   int curveLen = g_TradeCount + 1;
   for(int sim = 0; sim < InpSimulations; sim++)
      vals[sim] = g_AllCurves[sim * curveLen + step];
   return Percentile(vals, pct);
  }

//+------------------------------------------------------------------+
//| Compute and cache all summary metrics into globals               |
//+------------------------------------------------------------------+
void ComputeMetrics()
  {
   g_p05Eq   = Percentile(g_FinalEquities, 0.05);
   g_p50Eq   = Percentile(g_FinalEquities, 0.50);
   g_p95Eq   = Percentile(g_FinalEquities, 0.95);
   g_p50DD   = Percentile(g_MaxDrawdowns,  0.50);
   g_p95DD   = Percentile(g_MaxDrawdowns,  0.95);
   g_varAmt  = InpInitialBalance - g_p05Eq;

   int ruinCount = 0;
   for(int i = 0; i < InpSimulations; i++)
      if(g_MaxDrawdowns[i] >= InpRuinThreshold * 100.0)
         ruinCount++;
   g_probRuin = (double)ruinCount / InpSimulations * 100.0;
  }

//+------------------------------------------------------------------+
//| Feature #2 – Export percentile curves + summary to CSV           |
//|                                                                  |
//| Output file structure:                                           |
//|   Section 1 – Run metadata (comment lines starting with #)       |
//|   Section 2 – Percentile equity at every trade step              |
//|               Columns: Step, P5, P25, P50, P75, P95             |
//|   Section 3 – Summary metrics table                              |
//+------------------------------------------------------------------+
void ExportResultsToCSV()
  {
   int h = FileOpen(InpExportFile, FILE_WRITE | FILE_ANSI);
   if(h == INVALID_HANDLE)
     {
      PrintFormat("EXPORT ERROR: Cannot create '%s'. Code: %d", InpExportFile, GetLastError());
      return;
     }

   //--- Section 1: metadata header
   FileWriteString(h, "# Monte Carlo Risk Analyzer – Results Export\n");
   FileWriteString(h, StringFormat("# Generated  : %s\n", TimeToString(TimeLocal(), TIME_DATE | TIME_SECONDS)));
   FileWriteString(h, StringFormat("# Input file : %s\n", InpCSVFile));
   FileWriteString(h, StringFormat("# Simulations: %d\n", InpSimulations));
   FileWriteString(h, StringFormat("# Trades     : %d\n", g_TradeCount));
   FileWriteString(h, StringFormat("# Init Equity: $%.2f\n", InpInitialBalance));
   if(InpSlippageEnabled)
      FileWriteString(h, StringFormat("# Commission : $%.2f / trade\n# Max Slip   : $%.2f / trade\n",
                      InpCommission, InpSlippageMax));
   else
      FileWriteString(h, "# Commission : disabled\n");
   FileWriteString(h, "#\n");

   //--- Section 2: percentile curves (one row per trade step)
   FileWriteString(h, "Step,P5_Equity,P25_Equity,P50_Equity,P75_Equity,P95_Equity\n");
   for(int s = 0; s <= g_TradeCount; s++)
     {
      FileWriteString(h, StringFormat("%d,%.2f,%.2f,%.2f,%.2f,%.2f\n",
                      s,
                      PctAtStep(s, 0.05),
                      PctAtStep(s, 0.25),
                      PctAtStep(s, 0.50),
                      PctAtStep(s, 0.75),
                      PctAtStep(s, 0.95)));
     }

   //--- Section 3: summary metrics
   FileWriteString(h, "#\n# --- Summary Metrics ---\n");
   FileWriteString(h, "Metric,Value\n");
   FileWriteString(h, StringFormat("Median Final Equity,$%.2f\n",   g_p50Eq));
   FileWriteString(h, StringFormat("5th Pct Final Equity,$%.2f\n",  g_p05Eq));
   FileWriteString(h, StringFormat("95th Pct Final Equity,$%.2f\n", g_p95Eq));
   FileWriteString(h, StringFormat("Median Max Drawdown,%.2f%%\n",  g_p50DD));
   FileWriteString(h, StringFormat("Worst-Case DD 95th,%.2f%%\n",   g_p95DD));
   FileWriteString(h, StringFormat("Value at Risk 5pct,$%.2f\n",    g_varAmt));
   FileWriteString(h, StringFormat("Probability of Ruin,%.2f%%\n",  g_probRuin));
   FileWriteString(h, StringFormat("Ruin Threshold,%.0f%%\n",       InpRuinThreshold * 100.0));

   FileClose(h);
   PrintFormat("✔ Results exported → MQL5\\Files\\%s", InpExportFile);
  }

//+------------------------------------------------------------------+
//| Draw a 2-pixel-weight line                                        |
//+------------------------------------------------------------------+
void ThickLine(int x1, int y1, int x2, int y2, uint clr)
  {
   g_Canvas.Line(x1, y1,   x2, y2,   clr);
   g_Canvas.Line(x1, y1+1, x2, y2+1, clr);
  }

//+------------------------------------------------------------------+
//| Draw a dashed line                                                |
//+------------------------------------------------------------------+
void DashedLine(int x1, int y1, int x2, int y2, uint clr, int dashLen=6, int gapLen=4)
  {
   double dx   = x2 - x1, dy = y2 - y1;
   double dist = MathSqrt(dx*dx + dy*dy);
   if(dist < 1.0) return;
   double nx = dx/dist, ny = dy/dist;
   double d  = 0.0;
   bool   on = true;
   while(d < dist)
     {
      double segEnd = MathMin(d + (on ? dashLen : gapLen), dist);
      if(on)
        {
         int ax = x1 + (int)(nx*d),      ay = y1 + (int)(ny*d);
         int bx = x1 + (int)(nx*segEnd), by = y1 + (int)(ny*segEnd);
         g_Canvas.Line(ax, ay,   bx, by,   clr);
         g_Canvas.Line(ax, ay+1, bx, by+1, clr);
        }
      d  += on ? dashLen : gapLen;
      on  = !on;
     }
  }

//+------------------------------------------------------------------+
//| Render Monte Carlo results on chart                               |
//+------------------------------------------------------------------+
void DrawResultsOnChart()
  {
   if(!g_Canvas.CreateBitmapLabel(0, 0, "MC_Panel", 30, 30,
                                   CANVAS_W, CANVAS_H,
                                   COLOR_FORMAT_ARGB_NORMALIZE))
     {
      PrintFormat("Canvas creation failed. Error: %d", GetLastError());
      return;
     }

   g_Canvas.Erase(ColorToARGB(C'15,20,30', 255));

   int cL = MARGIN_L, cR = CANVAS_W - MARGIN_R;
   int cT = MARGIN_T, cB = CANVAS_H - MARGIN_B;
   int cW = cR - cL,  cH = cB - cT;

   //--- Y-scale: 5th–95th envelope
   double yMin = DBL_MAX, yMax = -DBL_MAX;
   for(int s = 0; s <= g_TradeCount; s++)
     {
      double lo = PctAtStep(s, 0.05);
      double hi = PctAtStep(s, 0.95);
      if(lo < yMin) yMin = lo;
      if(hi > yMax) yMax = hi;
     }
   double yRange = (yMax > yMin) ? yMax - yMin : 1.0;

   #define XP(step) (cL + (int)((double)(step) / g_TradeCount * cW))
   #define YP(val)  (cB - (int)(((val) - yMin) / yRange * cH))

   // ── LAYER 1: Filled bands ─────────────────────────────────────────

   for(int s = 0; s < g_TradeCount; s++)
     {
      int x1 = XP(s), x2 = XP(s + 1);
      int yLo1 = YP(PctAtStep(s,   0.05)), yHi1 = YP(PctAtStep(s,   0.95));
      int yLo2 = YP(PctAtStep(s+1, 0.05)), yHi2 = YP(PctAtStep(s+1, 0.95));
      uint c = ColorToARGB(InpBandColor, 45);
      g_Canvas.FillTriangle(x1, yHi1, x2, yHi2, x1, yLo1, c);
      g_Canvas.FillTriangle(x2, yHi2, x2, yLo2, x1, yLo1, c);
     }

   for(int s = 0; s < g_TradeCount; s++)
     {
      int x1 = XP(s), x2 = XP(s + 1);
      int yLo1 = YP(PctAtStep(s,   0.25)), yHi1 = YP(PctAtStep(s,   0.75));
      int yLo2 = YP(PctAtStep(s+1, 0.25)), yHi2 = YP(PctAtStep(s+1, 0.75));
      uint c = ColorToARGB(InpBandColor, 110);
      g_Canvas.FillTriangle(x1, yHi1, x2, yHi2, x1, yLo1, c);
      g_Canvas.FillTriangle(x2, yHi2, x2, yLo2, x1, yLo1, c);
     }

   // ── LAYER 2: Percentile boundary lines ───────────────────────────

   uint clr95 = ColorToARGB(CLR_P95,        230);
   uint clr75 = ColorToARGB(CLR_P75,        230);
   uint clr50 = ColorToARGB(InpMedianColor, 255);
   uint clr25 = ColorToARGB(CLR_P25,        230);
   uint clr05 = ColorToARGB(CLR_P05,        230);

   for(int s = 0; s < g_TradeCount; s++)
     {
      int x1 = XP(s), x2 = XP(s + 1);
      ThickLine(x1, YP(PctAtStep(s, 0.95)), x2, YP(PctAtStep(s+1, 0.95)), clr95);
      ThickLine(x1, YP(PctAtStep(s, 0.75)), x2, YP(PctAtStep(s+1, 0.75)), clr75);
      // Median: 3-px weight
      ThickLine(x1, YP(PctAtStep(s, 0.50)), x2, YP(PctAtStep(s+1, 0.50)), clr50);
      g_Canvas.Line(x1, YP(PctAtStep(s, 0.50))-1, x2, YP(PctAtStep(s+1, 0.50))-1, clr50);
      DashedLine(x1, YP(PctAtStep(s, 0.25)), x2, YP(PctAtStep(s+1, 0.25)), clr25);
      DashedLine(x1, YP(PctAtStep(s, 0.05)), x2, YP(PctAtStep(s+1, 0.05)), clr05);
     }

   // ── LAYER 3: Right-side inline labels with collision avoidance ────

   int yRaw[5];
   yRaw[0] = YP(PctAtStep(g_TradeCount, 0.95));
   yRaw[1] = YP(PctAtStep(g_TradeCount, 0.75));
   yRaw[2] = YP(PctAtStep(g_TradeCount, 0.50));
   yRaw[3] = YP(PctAtStep(g_TradeCount, 0.25));
   yRaw[4] = YP(PctAtStep(g_TradeCount, 0.05));

   int yLbl[5];
   int minGap = 19;
   ArrayCopy(yLbl, yRaw);
   for(int i = 1; i < 5; i++)
      if(yLbl[i] < yLbl[i-1] + minGap) yLbl[i] = yLbl[i-1] + minGap;
   for(int i = 3; i >= 0; i--)
      if(yLbl[i] > yLbl[i+1] - minGap) yLbl[i] = yLbl[i+1] - minGap;

   uint lblClr[5];
   lblClr[0] = ColorToARGB(CLR_P95,        240);
   lblClr[1] = ColorToARGB(CLR_P75,        240);
   lblClr[2] = ColorToARGB(InpMedianColor, 255);
   lblClr[3] = ColorToARGB(CLR_P25,        240);
   lblClr[4] = ColorToARGB(CLR_P05,        240);
   string lblTxt[5] = {"95th", "75th", "50th", "25th", "5th"};

   g_Canvas.FontSet("Arial Bold", 17);
   int xLbl = cR + 5;
   for(int i = 0; i < 5; i++)
     {
      g_Canvas.Line(cR, yRaw[i], xLbl - 1, yLbl[i], lblClr[i]);
      g_Canvas.TextOut(xLbl, yLbl[i], lblTxt[i], lblClr[i], TA_LEFT | TA_VCENTER);
     }

   // ── LAYER 4: Reference line + grid ───────────────────────────────

   int yRef = YP(InpInitialBalance);
   for(int x = cL; x < cR; x += 7)
      g_Canvas.Line(x, yRef, MathMin(x + 3, cR), yRef, ColorToARGB(clrGray, 130));

   g_Canvas.Rectangle(cL, cT, cR, cB, ColorToARGB(clrDimGray, 160));
   g_Canvas.FontSet("Arial", 18);
   for(int i = 0; i <= 5; i++)
     {
      double val = yMin + yRange * i / 5.0;
      int    yG  = YP(val);
      for(int x = cL + 2; x < cR; x += 8)
         g_Canvas.PixelSet(x, yG, ColorToARGB(clrDimGray, 55));
      g_Canvas.TextOut(cL - 5, yG, StringFormat("%.0f", val),
                       ColorToARGB(clrSilver, 200), TA_RIGHT | TA_VCENTER);
     }

   // ── LAYER 5: Title ────────────────────────────────────────────────

   g_Canvas.FontSet("Arial Bold", 26);
   string slipTag = InpSlippageEnabled ? "  ·  Slippage ON" : "";
   g_Canvas.TextOut(CANVAS_W / 2, 14,
      StringFormat("Monte Carlo Risk Assessment  ·  %d Simulations  ·  %d Trades%s",
                   InpSimulations, g_TradeCount, slipTag),
      ColorToARGB(clrWhite, 220), TA_CENTER | TA_TOP);

   // ── LAYER 6: Legend ───────────────────────────────────────────────

   g_Canvas.FontSet("Arial", 17);
   int bx1 = cR - 200, bx2 = cR - 2;
   int by1 = cT + 3,   by2 = cT + 108;
   g_Canvas.FillRectangle(bx1, by1, bx2, by2, ColorToARGB(C'10,14,22', 180));
   g_Canvas.Rectangle(bx1, by1, bx2, by2, ColorToARGB(clrDimGray, 80));

   struct LegendEntry { uint lineClr; bool dashed; string txt; };
   LegendEntry leg[5];
   leg[0].lineClr = clr95; leg[0].dashed = false; leg[0].txt = "95th percentile";
   leg[1].lineClr = clr75; leg[1].dashed = false; leg[1].txt = "75th percentile";
   leg[2].lineClr = clr50; leg[2].dashed = false; leg[2].txt = "50th  (Median)";
   leg[3].lineClr = clr25; leg[3].dashed = true;  leg[3].txt = "25th percentile";
   leg[4].lineClr = clr05; leg[4].dashed = true;  leg[4].txt = "5th  percentile";

   int ly0 = by1 + 12;
   for(int i = 0; i < 5; i++)
     {
      int ly = ly0 + i * 19;
      int lx1 = bx1 + 8, lx2 = bx1 + 32;
      if(leg[i].dashed)
         DashedLine(lx1, ly, lx2, ly, leg[i].lineClr, 5, 3);
      else
         ThickLine(lx1, ly, lx2, ly, leg[i].lineClr);
      g_Canvas.TextOut(lx2 + 6, ly, leg[i].txt, leg[i].lineClr, TA_LEFT | TA_VCENTER);
     }

   // ── LAYER 7: Statistics panel ─────────────────────────────────────

   int pT = cB + 14;
   g_Canvas.FontSet("Arial Bold", 20);
   g_Canvas.TextOut(CANVAS_W / 2, pT, "─── Risk Assessment Summary ───",
                    ColorToARGB(clrGold, 220), TA_CENTER);

   g_Canvas.FontSet("Arial", 20);
   int c1 = cL, c2 = cL + 250, c3 = cL + 490;
   int r1 = pT + 30, r2 = pT + 60, r3 = pT + 90, r4 = pT + 122;

   //--- Col 1: Equity outcomes
   g_Canvas.TextOut(c1, r1, StringFormat("Median Final Equity :   $%.2f", g_p50Eq), ColorToARGB(clrWhite));
   g_Canvas.TextOut(c1, r2, StringFormat("5th Pct Final Equity:   $%.2f", g_p05Eq), ColorToARGB(clrTomato));
   g_Canvas.TextOut(c1, r3, StringFormat("95th Pct Final Equity:  $%.2f", g_p95Eq), ColorToARGB(clrLimeGreen));

   //--- Col 2: Drawdown & VaR
   g_Canvas.TextOut(c2, r1, StringFormat("Median Max Drawdown :   %.1f%%", g_p50DD),  ColorToARGB(clrWhite));
   g_Canvas.TextOut(c2, r2, StringFormat("Worst-Case DD (95th):   %.1f%%", g_p95DD),  ColorToARGB(clrTomato));
   g_Canvas.TextOut(c2, r3, StringFormat("Value at Risk (5%%) :   $%.2f",  g_varAmt), ColorToARGB(clrGold));

   //--- Col 3: Ruin + simulation info
   color ruinClr = (g_probRuin > 10.0) ? clrTomato : clrLimeGreen;
   g_Canvas.TextOut(c3, r1, StringFormat("Probability of Ruin :   %.1f%%", g_probRuin), ColorToARGB(ruinClr));
   g_Canvas.TextOut(c3, r2, StringFormat("Ruin Threshold      :   %.0f%% drawdown",
                    InpRuinThreshold * 100.0), ColorToARGB(clrSilver));
   g_Canvas.TextOut(c3, r3, StringFormat("Simulations         :   %d  |  Trades: %d",
                    InpSimulations, g_TradeCount), ColorToARGB(clrDimGray));

   //--- Row 4: Feature #3 slippage status + Feature #2 export status
   g_Canvas.FontSet("Arial", 18);

   string slipInfo;
   uint   slipClr;
   if(InpSlippageEnabled)
     {
      slipInfo = StringFormat("Slippage sim : ON  |  Commission $%.2f + Rand slip [$0 – $%.2f] / trade",
                              InpCommission, InpSlippageMax);
      slipClr  = ColorToARGB(clrOrange, 210);
     }
   else
     {
      slipInfo = "Slippage sim : OFF  (enable InpSlippageEnabled to stress-test with commission & slippage)";
      slipClr  = ColorToARGB(clrDimGray, 180);
     }
   g_Canvas.TextOut(c1, r4, slipInfo, slipClr);

   string expInfo;
   uint   expClr;
   if(InpExportCSV)
     {
      expInfo = StringFormat("Export       : → MQL5\\Files\\%s", InpExportFile);
      expClr  = ColorToARGB(clrSkyBlue, 210);
     }
   else
     {
      expInfo = "Export       : OFF  (enable InpExportCSV to save curves to CSV)";
      expClr  = ColorToARGB(clrDimGray, 180);
     }
   g_Canvas.TextOut(c1, r4 + 22, expInfo, expClr);

   g_Canvas.Update();

   //--- Log to Experts tab
   Print("══════════ Monte Carlo Results ══════════");
   if(InpSlippageEnabled)
      PrintFormat("Slippage sim  : commission $%.2f + rand[0,$%.2f] / trade", InpCommission, InpSlippageMax);
   PrintFormat("Median Final Equity  : $%.2f", g_p50Eq);
   PrintFormat("5th–95th Pct Range   : $%.2f  →  $%.2f", g_p05Eq, g_p95Eq);
   PrintFormat("Median Max Drawdown  : %.1f%%", g_p50DD);
   PrintFormat("Worst-Case DD (95th) : %.1f%%", g_p95DD);
   PrintFormat("Value at Risk (5%%)  : $%.2f",  g_varAmt);
   PrintFormat("Probability of Ruin  : %.1f%%", g_probRuin);
   Print("═════════════════════════════════════════");
  }

//+------------------------------------------------------------------+
//| Script entry point                                               |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(!LoadTradesFromCSV(InpCSVFile))
      return;

   PrintFormat("Loaded. Running %d Monte Carlo simulations%s...",
               InpSimulations,
               InpSlippageEnabled ? " with commission/slippage" : "");

   RunMonteCarloSimulation();
   ComputeMetrics();          // fill globals used by both Draw + Export
   DrawResultsOnChart();

   //--- Feature #2: export if requested
   if(InpExportCSV)
      ExportResultsToCSV();

   Print("Complete. Panel rendered on chart.");
  }
//+------------------------------------------------------------------+