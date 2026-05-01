//+------------------------------------------------------------------+
//| NeuralEA_DataCollector.mq5                                        |
//| Collects training data for LSTM, CatBoost, and Price models       |
//| Run in Strategy Tester to generate CSV training data              |
//+------------------------------------------------------------------+
#property copyright "Aliim"
#property version   "1.00"
#property strict

//--- Input parameters
input string   InpSymbol       = "XAUUSD";     // Symbol
input ENUM_TIMEFRAMES InpTF     = PERIOD_H1;    // Timeframe
input int      InpHistoryBars  = 10000;         // History bars to collect
input string   InpFileName     = "neural_training_data.csv"; // Output file

//--- Indicator handles
int handleADX, handleRSI, handleMACD, handlePSAR, handleATR;
int handleSMA50, handleSMA200, handleBB;
int handleMFI, handleCCI, handleStoch, handleWPR;
int handleOBV, handleAD;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   // Create indicator handles
   handleADX  = iADX(InpSymbol, InpTF, 14);
   handleRSI  = iRSI(InpSymbol, InpTF, 14, PRICE_CLOSE);
   handleMACD = iMACD(InpSymbol, InpTF, 12, 26, 9, PRICE_CLOSE);
   handlePSAR = iSAR(InpSymbol, InpTF, 0.02, 0.2);
   handleATR  = iATR(InpSymbol, InpTF, 14);
   handleSMA50  = iMA(InpSymbol, InpTF, 50, 0, MODE_SMA, PRICE_CLOSE);
   handleSMA200 = iMA(InpSymbol, InpTF, 200, 0, MODE_SMA, PRICE_CLOSE);
   handleBB   = iBands(InpSymbol, InpTF, 20, 0, 2.0, PRICE_CLOSE);
   handleMFI  = iMFI(InpSymbol, InpTF, 14, VOLUME_TICK);
   handleCCI  = iCCI(InpSymbol, InpTF, 14, PRICE_TYPICAL);
   handleStoch = iStochastic(InpSymbol, InpTF, 14, 3, 3, MODE_SMA, STO_LOWHIGH);
   handleWPR  = iWPR(InpSymbol, InpTF, 14);
   handleOBV  = iOBV(InpSymbol, InpTF, VOLUME_TICK);
   handleAD   = iAD(InpSymbol, InpTF, VOLUME_TICK);
   
   if(handleADX == INVALID_HANDLE || handleRSI == INVALID_HANDLE ||
      handleMACD == INVALID_HANDLE || handlePSAR == INVALID_HANDLE ||
      handleATR == INVALID_HANDLE)
   {
      Print("Error creating indicator handles!");
      return INIT_FAILED;
   }
   
   Print("Data collector initialized for ", InpSymbol, " ", EnumToString(InpTF));
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   IndicatorRelease(handleADX);
   IndicatorRelease(handleRSI);
   IndicatorRelease(handleMACD);
   IndicatorRelease(handlePSAR);
   IndicatorRelease(handleATR);
   IndicatorRelease(handleSMA50);
   IndicatorRelease(handleSMA200);
   IndicatorRelease(handleBB);
   IndicatorRelease(handleMFI);
   IndicatorRelease(handleCCI);
   IndicatorRelease(handleStoch);
   IndicatorRelease(handleWPR);
   IndicatorRelease(handleOBV);
   IndicatorRelease(handleAD);
}

//+------------------------------------------------------------------+
//| Copy indicator buffer values                                       |
//+------------------------------------------------------------------+
bool CopyIndicator(int handle, int buffer, int start, int count, double &arr[])
{
   if(CopyBuffer(handle, buffer, start, count, arr) != count)
      return false;
   return true;
}

//+------------------------------------------------------------------+
//| Calculate Heiken Ashi values                                       |
//+------------------------------------------------------------------+
void GetHeikenAshi(int shift, double &haOpen, double &haClose, double &haHigh, double &haLow)
{
   double o = iOpen(InpSymbol, InpTF, shift);
   double h = iHigh(InpSymbol, InpTF, shift);
   double l = iLow(InpSymbol, InpTF, shift);
   double c = iClose(InpSymbol, InpTF, shift);
   
   haClose = (o + h + l + c) / 4.0;
   
   // Get previous HA values
   double prevO = iOpen(InpSymbol, InpTF, shift + 1);
   double prevH = iHigh(InpSymbol, InpTF, shift + 1);
   double prevL = iLow(InpSymbol, InpTF, shift + 1);
   double prevC = iClose(InpSymbol, InpTF, shift + 1);
   double prevHaOpen = (prevO + prevH + prevL + prevC) / 4.0;
   double prevHaClose = prevHaOpen; // simplified
   
   haOpen = (prevHaOpen + prevHaClose) / 2.0;
   haHigh = MathMax(h, MathMax(haOpen, haClose));
   haLow  = MathMin(l, MathMin(haOpen, haClose));
}

//+------------------------------------------------------------------+
//| Expert tick function                                               |
//+------------------------------------------------------------------+
void OnTick()
{
   // Only run once on new bar
   static datetime lastBar = 0;
   datetime currentBar = iTime(InpSymbol, InpTF, 0);
   if(currentBar == lastBar) return;
   lastBar = currentBar;
   
   // We only collect data once (on first tick after init)
   static bool collected = false;
   if(collected) return;
   collected = true;
   
   CollectData();
}

//+------------------------------------------------------------------+
//| Main data collection function                                      |
//+------------------------------------------------------------------+
void CollectData()
{
   int handle = FileOpen(InpFileName, FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
   if(handle == INVALID_HANDLE)
   {
      Print("Error opening file: ", InpFileName);
      return;
   }
   
   // Write header
   FileWrite(handle,
      // Time
      "datetime",
      // OHLC
      "open", "high", "low", "close",
      // Stationary features
      "candle_return", "candle_body_pct", "upper_wick_pct", "lower_wick_pct",
      // Indicators (current bar)
      "adx", "adx_plus", "adx_minus",
      "rsi",
      "macd_main", "macd_signal", "macd_hist",
      "psar",
      "atr",
      "sma50", "sma200",
      "bb_upper", "bb_middle", "bb_lower",
      "mfi", "cci", "stoch_k", "stoch_d", "wpr",
      "obv", "ad",
      // Heiken Ashi
      "ha_open", "ha_close", "ha_high", "ha_low",
      // Price relative to indicators
      "close_vs_sma50", "close_vs_sma200", "close_vs_bb_mid",
      // Multi-bar features (5 bars)
      "adx_1", "adx_2", "adx_3", "adx_4",
      "rsi_1", "rsi_2", "rsi_3", "rsi_4",
      "close_return_1", "close_return_2", "close_return_3", "close_return_4",
      // Labels (for training)
      "label_adx_future_10",  // LSTM target: mean ADX of next 10 bars
      "label_price_direction", // Price predictor target: 1=up, 0=down
      "label_win"              // CatBoost target: 1=profitable trade, 0=loss
   );
   
   int totalBars = MathMin(InpHistoryBars, iBars(InpSymbol, InpTF) - 250);
   int collected_count = 0;
   
   for(int i = totalBars; i >= 20; i--)
   {
      // Get OHLC
      double open  = iOpen(InpSymbol, InpTF, i);
      double high  = iHigh(InpSymbol, InpTF, i);
      double low   = iLow(InpSymbol, InpTF, i);
      double close = iClose(InpSymbol, InpTF, i);
      datetime dt  = iTime(InpSymbol, InpTF, i);
      
      // Stationary features
      double candle_return = (close - open) / close;
      double candle_body   = MathAbs(close - open) / (high - low + 0.0001);
      double upper_wick    = (high - MathMax(open, close)) / (high - low + 0.0001);
      double lower_wick    = (MathMin(open, close) - low) / (high - low + 0.0001);
      
      // Get indicator values
      double adx[], adxP[], adxM[];
      double rsi[], macdM[], macdS[], macdH[];
      double psar[], atr[];
      double sma50[], sma200[];
      double bbU[], bbM[], bbL[];
      double mfi[], cci[], stochK[], stochD[], wpr[];
      double obv[], ad[];
      
      if(!CopyIndicator(handleADX, 0, i, 1, adx)) continue;
      if(!CopyIndicator(handleADX, 1, i, 1, adxP)) continue;
      if(!CopyIndicator(handleADX, 2, i, 1, adxM)) continue;
      if(!CopyIndicator(handleRSI, 0, i, 1, rsi)) continue;
      if(!CopyIndicator(handleMACD, 0, i, 1, macdM)) continue;
      if(!CopyIndicator(handleMACD, 1, i, 1, macdS)) continue;
      if(!CopyIndicator(handlePSAR, 0, i, 1, psar)) continue;
      if(!CopyIndicator(handleATR, 0, i, 1, atr)) continue;
      if(!CopyIndicator(handleSMA50, 0, i, 1, sma50)) continue;
      if(!CopyIndicator(handleSMA200, 0, i, 1, sma200)) continue;
      if(!CopyIndicator(handleBB, 0, i, 1, bbM)) continue;
      if(!CopyIndicator(handleBB, 1, i, 1, bbU)) continue;
      if(!CopyIndicator(handleBB, 2, i, 1, bbL)) continue;
      if(!CopyIndicator(handleMFI, 0, i, 1, mfi)) continue;
      if(!CopyIndicator(handleCCI, 0, i, 1, cci)) continue;
      if(!CopyIndicator(handleStoch, 0, i, 1, stochK)) continue;
      if(!CopyIndicator(handleStoch, 1, i, 1, stochD)) continue;
      if(!CopyIndicator(handleWPR, 0, i, 1, wpr)) continue;
      if(!CopyIndicator(handleOBV, 0, i, 1, obv)) continue;
      if(!CopyIndicator(handleAD, 0, i, 1, ad)) continue;
      
      // MACD histogram
      macdH[0] = macdM[0] - macdS[0];
      
      // Heiken Ashi
      double haO, haC, haH, haL;
      GetHeikenAshi(i, haO, haC, haH, haL);
      
      // Price relative features
      double close_vs_sma50  = (close - sma50[0]) / sma50[0];
      double close_vs_sma200 = (close - sma200[0]) / sma200[0];
      double close_vs_bb_mid = (close - bbM[0]) / (bbU[0] - bbL[0] + 0.0001);
      
      // Multi-bar features (bars 1-4)
      double adx_hist[4], rsi_hist[4], return_hist[4];
      for(int j = 0; j < 4; j++)
      {
         double adx_tmp[], rsi_tmp[];
         if(!CopyIndicator(handleADX, 0, i + j + 1, 1, adx_tmp)) { adx_hist[j] = 0; continue; }
         if(!CopyIndicator(handleRSI, 0, i + j + 1, 1, rsi_tmp)) { rsi_hist[j] = 0; continue; }
         adx_hist[j] = adx_tmp[0];
         rsi_hist[j] = rsi_tmp[0];
         double prev_close = iClose(InpSymbol, InpTF, i + j + 1);
         double prev_prev_close = iClose(InpSymbol, InpTF, i + j + 2);
         return_hist[j] = (prev_close - prev_prev_close) / prev_prev_close;
      }
      
      // === LABELS ===
      
      // Label 1: Mean ADX of next 10 bars (LSTM target)
      double future_adx_sum = 0;
      for(int j = 1; j <= 10; j++)
      {
         double tmp[];
         if(CopyIndicator(handleADX, 0, i - j, 1, tmp) == 1)
            future_adx_sum += tmp[0];
      }
      double label_adx_future = future_adx_sum / 10.0;
      
      // Label 2: Price direction (next bar close > current close)
      double next_close = iClose(InpSymbol, InpTF, i - 1);
      int label_direction = (next_close > close) ? 1 : 0;
      
      // Label 3: Win label (would a trade at this bar be profitable?)
      // Simple: buy if close > SMA50, sell if close < SMA50
      // Check if price moved favorably after 10 bars
      double future_close = iClose(InpSymbol, InpTF, i - 10);
      int label_win = 0;
      if(close > sma50[0]) // long bias
         label_win = (future_close > close + atr[0]) ? 1 : 0;
      else // short bias
         label_win = (future_close < close - atr[0]) ? 1 : 0;
      
      // Write row
      FileWrite(handle,
         dt,
         open, high, low, close,
         candle_return, candle_body, upper_wick, lower_wick,
         adx[0], adxP[0], adxM[0],
         rsi[0],
         macdM[0], macdS[0], macdH[0],
         psar[0],
         atr[0],
         sma50[0], sma200[0],
         bbU[0], bbM[0], bbL[0],
         mfi[0], cci[0], stochK[0], stochD[0], wpr[0],
         obv[0], ad[0],
         haO, haC, haH, haL,
         close_vs_sma50, close_vs_sma200, close_vs_bb_mid,
         adx_hist[0], adx_hist[1], adx_hist[2], adx_hist[3],
         rsi_hist[0], rsi_hist[1], rsi_hist[2], rsi_hist[3],
         return_hist[0], return_hist[1], return_hist[2], return_hist[3],
         label_adx_future,
         label_direction,
         label_win
      );
      
      collected_count++;
   }
   
   FileClose(handle);
   Print("Collected ", collected_count, " rows → ", InpFileName);
}
//+------------------------------------------------------------------+
