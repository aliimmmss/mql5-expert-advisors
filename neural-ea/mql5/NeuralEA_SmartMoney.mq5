//+------------------------------------------------------------------+
//| NeuralEA_SmartMoney.mq5                                           |
//| Neural-enhanced Smart Money Concepts EA                           |
//| Combines LSTM trend filter + CatBoost signal filter + Price predictor|
//+------------------------------------------------------------------+
#property copyright "Aliim"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>

//+------------------------------------------------------------------+
//| ONNX Model Resource Files                                         |
//+------------------------------------------------------------------+
#resource "lstm_trend.onnx"        as uchar LSTMModel[]      // LSTM trend filter
#resource "catboost_filter.onnx"   as uchar CatBoostModel[]  // CatBoost win probability
#resource "price_predictor.onnx"   as uchar PriceModel[]     // CNN+LSTM price direction

//+------------------------------------------------------------------+
//| INPUT PARAMETERS                                                  |
//+------------------------------------------------------------------+
input group "=== Risk Management ==="
input double InpLotSize        = 0.01;       // Lot Size
input int    InpStopLoss       = 4200;       // Stop Loss (points)
input int    InpTakeProfit     = 2400;       // Take Profit (points)
input double InpRiskPercent    = 1.0;        // Risk per trade (%)
input int    InpMaxTrades      = 3;          // Max concurrent trades

input group "=== Neural Filter Thresholds ==="
input double InpLSTM_ADX_Threshold  = 30.0;  // LSTM: min predicted ADX to trade
input double InpCatBoost_Threshold  = 0.15;  // CatBoost: min win probability
input double InpPrice_Confidence    = 0.55;  // Price predictor: min confidence

input group "=== SmartMoney Parameters ==="
input int    InpSwingLookback       = 25;    // Swing detection lookback
input int    InpSwingConfirmBars    = 13;    // Bars to confirm swing
input int    InpBOSMinSize          = 360;   // Min BOS size (points)
input int    InpFVGMinSize          = 50;    // Min FVG size (points)
input int    InpFVGMaxAge           = 50;    // Max FVG age (bars)
input double InpFVGEntryPercent     = 50;    // FVG entry % from edge
input int    InpOBMinCandles        = 15;    // Min OB candles
input int    InpOBMaxAge            = 253;   // Max OB age (bars)
input double InpOBEntryPercent      = 460;   // OB entry % from edge
input int    InpLiqSwingLookback    = 43;    // Liquidity swing lookback
input double InpLiqWickPercent      = 438;   // Liquidity wick %

input group "=== Session Times (Server Hours) ==="
input int    InpOpeningRangeStart   = 20;    // Opening range start
input int    InpOpeningRangeEnd     = 9;     // Opening range end
input int    InpMidnightStart       = 2;     // Midnight session start
input int    InpMidnightEnd         = 2;     // Midnight session end
input double InpSessionBreakConf    = 14.85; // Session break confidence

input group "=== Model Settings ==="
input bool   InpUseLSTMFilter       = true;  // Use LSTM trend filter
input bool   InpUseCatBoostFilter   = true;  // Use CatBoost signal filter
input bool   InpUsePricePredictor   = true;  // Use price predictor
input int    InpLSTM_Timesteps      = 5;     // LSTM input timesteps
input int    InpPrice_Timesteps     = 120;   // Price predictor timesteps

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                  |
//+------------------------------------------------------------------+
CTrade trade;
CPositionInfo posInfo;
CSymbolInfo symInfo;

// ONNX model handles
int lstmHandle = INVALID_HANDLE;
int catboostHandle = INVALID_HANDLE;
int priceHandle = INVALID_HANDLE;

// Indicator handles
int handleADX, handleRSI, handleMACD, handlePSAR, handleATR;
int handleSMA50, handleSMA200, handleBB;
int handleMFI, handleCCI, handleStoch, handleWPR;
int handleOBV, handleAD;

// Model input buffers
double lstmInput[];
double catboostInput[];
double priceInput[];

// Feature history for LSTM sequences
double adxHistory[];
double rsiHistory[];
double returnHistory[];

// Price history for CNN+LSTM
double priceHistory[];

//+------------------------------------------------------------------+
//| Expert initialization                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   // Validate inputs
   if(InpLotSize <= 0 || InpStopLoss <= 0 || InpTakeProfit <= 0)
   {
      Print("ERROR: Invalid risk parameters");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   // Initialize symbol info
   symInfo.Name(_Symbol);
   symInfo.Refresh();
   
   // Create ONNX model handles
   lstmHandle = OnnxCreateFromBuffer(LSTMModel, ONNX_DEFAULT);
   if(lstmHandle == INVALID_HANDLE)
      Print("WARNING: LSTM model not loaded - trend filter disabled");
   
   catboostHandle = OnnxCreateFromBuffer(CatBoostModel, ONNX_DEFAULT);
   if(catboostHandle == INVALID_HANDLE)
      Print("WARNING: CatBoost model not loaded - signal filter disabled");
   
   priceHandle = OnnxCreateFromBuffer(PriceModel, ONNX_DEFAULT);
   if(priceHandle == INVALID_HANDLE)
      Print("WARNING: Price predictor model not loaded - direction filter disabled");
   
   // Create indicator handles
   handleADX  = iADX(_Symbol, PERIOD_CURRENT, 14);
   handleRSI  = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
   handleMACD = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
   handlePSAR = iSAR(_Symbol, PERIOD_CURRENT, 0.02, 0.2);
   handleATR  = iATR(_Symbol, PERIOD_CURRENT, 14);
   handleSMA50  = iMA(_Symbol, PERIOD_CURRENT, 50, 0, MODE_SMA, PRICE_CLOSE);
   handleSMA200 = iMA(_Symbol, PERIOD_CURRENT, 200, 0, MODE_SMA, PRICE_CLOSE);
   handleBB   = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
   handleMFI  = iMFI(_Symbol, PERIOD_CURRENT, 14, VOLUME_TICK);
   handleCCI  = iCCI(_Symbol, PERIOD_CURRENT, 14, PRICE_TYPICAL);
   handleStoch = iStochastic(_Symbol, PERIOD_CURRENT, 14, 3, 3, MODE_SMA, STO_LOWHIGH);
   handleWPR  = iWPR(_Symbol, PERIOD_CURRENT, 14);
   handleOBV  = iOBV(_Symbol, PERIOD_CURRENT, VOLUME_TICK);
   handleAD   = iAD(_Symbol, PERIOD_CURRENT, VOLUME_TICK);
   
   if(handleADX == INVALID_HANDLE || handleRSI == INVALID_HANDLE ||
      handleMACD == INVALID_HANDLE || handleATR == INVALID_HANDLE)
   {
      Print("ERROR: Failed to create indicator handles");
      return INIT_FAILED;
   }
   
   // Initialize history arrays
   ArrayResize(adxHistory, InpLSTM_Timesteps + 10);
   ArrayResize(rsiHistory, InpLSTM_Timesteps + 10);
   ArrayResize(returnHistory, InpLSTM_Timesteps + 10);
   ArrayResize(priceHistory, InpPrice_Timesteps + 10);
   
   // Initialize arrays to zero
   ArrayInitialize(adxHistory, 0);
   ArrayInitialize(rsiHistory, 0);
   ArrayInitialize(returnHistory, 0);
   ArrayInitialize(priceHistory, 0);
   
   // Configure trade
   trade.SetExpertMagicNumber(20250501);
   trade.SetDeviationInPoints(50);
   trade.SetTypeFilling(ORDER_FILLING_IOC);
   
   Print("=== Neural SmartMoney EA Initialized ===");
   Print("LSTM Filter: ", (lstmHandle != INVALID_HANDLE && InpUseLSTMFilter) ? "ACTIVE" : "DISABLED");
   Print("CatBoost Filter: ", (catboostHandle != INVALID_HANDLE && InpUseCatBoostFilter) ? "ACTIVE" : "DISABLED");
   Print("Price Predictor: ", (priceHandle != INVALID_HANDLE && InpUsePricePredictor) ? "ACTIVE" : "DISABLED");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Release ONNX handles
   if(lstmHandle != INVALID_HANDLE) OnnxRelease(lstmHandle);
   if(catboostHandle != INVALID_HANDLE) OnnxRelease(catboostHandle);
   if(priceHandle != INVALID_HANDLE) OnnxRelease(priceHandle);
   
   // Release indicator handles
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
//| Get single indicator value                                        |
//+------------------------------------------------------------------+
double GetIndicator(int handle, int buffer, int shift)
{
   double arr[];
   if(CopyBuffer(handle, buffer, shift, 1, arr) != 1)
      return 0;
   return arr[0];
}

//+------------------------------------------------------------------+
//| Update feature history                                            |
//+------------------------------------------------------------------+
void UpdateHistory()
{
   // Shift history arrays
   for(int i = ArraySize(adxHistory) - 1; i > 0; i--)
   {
      adxHistory[i] = adxHistory[i-1];
      rsiHistory[i] = rsiHistory[i-1];
      returnHistory[i] = returnHistory[i-1];
      priceHistory[i] = priceHistory[i-1];
   }
   
   // Add current values
   adxHistory[0] = GetIndicator(handleADX, 0, 1);
   rsiHistory[0] = GetIndicator(handleRSI, 0, 1);
   
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
   returnHistory[0] = (close1 - close2) / close2;
   
   priceHistory[0] = close1;
}

//+------------------------------------------------------------------+
//| Run LSTM Trend Filter                                             |
//+------------------------------------------------------------------+
//| Returns: predicted ADX value (> threshold = trending)             |
//+------------------------------------------------------------------+
double RunLSTMFilter()
{
   if(lstmHandle == INVALID_HANDLE || !InpUseLSTMFilter)
      return 35.0; // Default: assume trending
   
   // Prepare input: 5 timesteps × 3 features (adx, rsi, candle_return)
   // Shape: [1, 5, 3]
   float input_data[];
   ArrayResize(input_data, InpLSTM_Timesteps * 3);
   
   for(int t = 0; t < InpLSTM_Timesteps; t++)
   {
      // Normalize features (same as training)
      input_data[t * 3 + 0] = (float)(adxHistory[t] / 100.0);  // ADX: 0-100
      input_data[t * 3 + 1] = (float)(rsiHistory[t] / 100.0);   // RSI: 0-100
      input_data[t * 3 + 2] = (float)(returnHistory[t] * 1000); // Return: scaled
   }
   
   // Set input shape
   OnnxTypeInfo inputType;
   inputType.type = ONNX_DATATYPE_FLOAT;
   OnnxTypeInfo outputType;
   
   if(!OnnxGetInputTypeInfo(lstmHandle, 0, inputType))
   {
      Print("LSTM: Failed to get input info");
      return 35.0;
   }
   
   // Run inference
   float output_data[];
   ArrayResize(output_data, 1);
   
   if(!OnnxRun(lstmHandle, ONNX_DEFAULT, {input_data}, output_data))
   {
      Print("LSTM: Inference failed");
      return 35.0;
   }
   
   double predictedADX = output_data[0];
   
   // Debug logging
   static int lstmLogCounter = 0;
   if(lstmLogCounter++ % 100 == 0)
      Print("LSTM: Predicted ADX = ", DoubleToString(predictedADX, 1));
   
   return predictedADX;
}

//+------------------------------------------------------------------+
//| Run CatBoost Signal Filter                                        |
//+------------------------------------------------------------------+
//| Returns: win probability (0-1)                                    |
//+------------------------------------------------------------------+
double RunCatBoostFilter()
{
   if(catboostHandle == INVALID_HANDLE || !InpUseCatBoostFilter)
      return 0.5; // Default: neutral probability
   
   // Prepare input: 30 features (matching training)
   float input_data[];
   ArrayResize(input_data, 30);
   
   input_data[0]  = (float)GetIndicator(handleADX, 0, 1);      // adx
   input_data[1]  = (float)GetIndicator(handleADX, 1, 1);      // adx_plus
   input_data[2]  = (float)GetIndicator(handleADX, 2, 1);      // adx_minus
   input_data[3]  = (float)GetIndicator(handleRSI, 0, 1);      // rsi
   input_data[4]  = (float)GetIndicator(handleMACD, 0, 1);     // macd_main
   input_data[5]  = (float)GetIndicator(handleMACD, 1, 1);     // macd_signal
   input_data[6]  = (float)(GetIndicator(handleMACD, 0, 1) -   // macd_hist
                            GetIndicator(handleMACD, 1, 1));
   input_data[7]  = (float)GetIndicator(handlePSAR, 0, 1);     // psar
   input_data[8]  = (float)GetIndicator(handleATR, 0, 1);      // atr
   input_data[9]  = (float)GetIndicator(handleSMA50, 0, 1);    // sma50
   input_data[10] = (float)GetIndicator(handleSMA200, 0, 1);   // sma200
   input_data[11] = (float)GetIndicator(handleBB, 1, 1);       // bb_upper
   input_data[12] = (float)GetIndicator(handleBB, 0, 1);       // bb_middle
   input_data[13] = (float)GetIndicator(handleBB, 2, 1);       // bb_lower
   input_data[14] = (float)GetIndicator(handleMFI, 0, 1);      // mfi
   input_data[15] = (float)GetIndicator(handleCCI, 0, 1);      // cci
   input_data[16] = (float)GetIndicator(handleStoch, 0, 1);    // stoch_k
   input_data[17] = (float)GetIndicator(handleStoch, 1, 1);    // stoch_d
   input_data[18] = (float)GetIndicator(handleWPR, 0, 1);      // wpr
   input_data[19] = (float)GetIndicator(handleOBV, 0, 1);      // obv
   input_data[20] = (float)GetIndicator(handleAD, 0, 1);       // ad
   
   // Heiken Ashi
   double open1  = iOpen(_Symbol, PERIOD_CURRENT, 1);
   double high1  = iHigh(_Symbol, PERIOD_CURRENT, 1);
   double low1   = iLow(_Symbol, PERIOD_CURRENT, 1);
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   
   input_data[21] = (float)((open1 + high1 + low1 + close1) / 4.0);  // ha_close approx
   input_data[22] = (float)open1;                                      // ha_open approx
   input_data[23] = (float)high1;                                      // ha_high
   input_data[24] = (float)low1;                                       // ha_low
   
   // Candle features
   input_data[25] = (float)((close1 - open1) / close1);               // candle_return
   input_data[26] = (float)(MathAbs(close1 - open1) / (high1 - low1 + 0.0001)); // candle_body_pct
   
   // Price relative
   double sma50  = GetIndicator(handleSMA50, 0, 1);
   double sma200 = GetIndicator(handleSMA200, 0, 1);
   double bbU    = GetIndicator(handleBB, 1, 1);
   double bbL    = GetIndicator(handleBB, 2, 1);
   double bbM    = GetIndicator(handleBB, 0, 1);
   
   input_data[27] = (float)((close1 - sma50) / sma50);                 // close_vs_sma50
   input_data[28] = (float)((close1 - sma200) / sma200);               // close_vs_sma200
   input_data[29] = (float)((close1 - bbM) / (bbU - bbL + 0.0001));   // close_vs_bb_mid
   
   // Run inference
   float output_data[];
   ArrayResize(output_data, 2); // Binary classifier: [loss_prob, win_prob]
   
   if(!OnnxRun(catboostHandle, ONNX_DEFAULT, {input_data}, output_data))
   {
      Print("CatBoost: Inference failed");
      return 0.5;
   }
   
   double winProb = output_data[1]; // Probability of class 1 (win)
   
   static int cbLogCounter = 0;
   if(cbLogCounter++ % 100 == 0)
      Print("CatBoost: Win probability = ", DoubleToString(winProb, 3));
   
   return winProb;
}

//+------------------------------------------------------------------+
//| Run Price Predictor                                               |
//+------------------------------------------------------------------+
//| Returns: probability of price going up (0-1)                     |
//+------------------------------------------------------------------+
double RunPricePredictor()
{
   if(priceHandle == INVALID_HANDLE || !InpUsePricePredictor)
      return 0.5; // Default: neutral
   
   // Need enough history
   if(ArraySize(priceHistory) < InpPrice_Timesteps)
      return 0.5;
   
   // Prepare input: 120 timesteps × 4 features (close, candle_return, rsi, adx)
   // Shape: [1, 120, 4]
   int features = 4;
   float input_data[];
   ArrayResize(input_data, InpPrice_Timesteps * features);
   
   // Normalize using simple scaling
   double lastPrice = priceHistory[0];
   
   for(int t = 0; t < InpPrice_Timesteps; t++)
   {
      int idx = InpPrice_Timesteps - 1 - t; // Reverse order (oldest first)
      
      // Normalize close: percentage from last price
      input_data[t * features + 0] = (float)((priceHistory[idx] - lastPrice) / lastPrice * 100);
      
      // Candle return (already normalized)
      if(idx < ArraySize(returnHistory))
         input_data[t * features + 1] = (float)(returnHistory[idx] * 100);
      else
         input_data[t * features + 1] = 0;
      
      // RSI (normalized 0-1)
      if(idx < ArraySize(rsiHistory))
         input_data[t * features + 2] = (float)(rsiHistory[idx] / 100.0);
      else
         input_data[t * features + 2] = 0.5;
      
      // ADX (normalized 0-1)
      if(idx < ArraySize(adxHistory))
         input_data[t * features + 3] = (float)(adxHistory[idx] / 100.0);
      else
         input_data[t * features + 3] = 0.2;
   }
   
   // Run inference
   float output_data[];
   ArrayResize(output_data, 1);
   
   if(!OnnxRun(priceHandle, ONNX_DEFAULT, {input_data}, output_data))
   {
      Print("Price Predictor: Inference failed");
      return 0.5;
   }
   
   double upProb = output_data[0];
   
   static int ppLogCounter = 0;
   if(ppLogCounter++ % 100 == 0)
      Print("Price Predictor: Up probability = ", DoubleToString(upProb, 3));
   
   return upProb;
}

//+------------------------------------------------------------------+
//| SmartMoney: Detect Swing High/Low                                 |
//+------------------------------------------------------------------+
struct SwingPoint {
   double price;
   int    bar;
   bool   isHigh;
};

SwingPoint FindSwingHigh(int lookback, int confirmBars)
{
   SwingPoint sp;
   sp.price = 0;
   sp.bar = -1;
   sp.isHigh = true;
   
   for(int i = confirmBars + 1; i < lookback; i++)
   {
      double high_i = iHigh(_Symbol, PERIOD_CURRENT, i);
      bool isSwing = true;
      
      for(int j = 1; j <= confirmBars; j++)
      {
         if(iHigh(_Symbol, PERIOD_CURRENT, i-j) >= high_i ||
            iHigh(_Symbol, PERIOD_CURRENT, i+j) >= high_i)
         {
            isSwing = false;
            break;
         }
      }
      
      if(isSwing)
      {
         sp.price = high_i;
         sp.bar = i;
         return sp;
      }
   }
   return sp;
}

SwingPoint FindSwingLow(int lookback, int confirmBars)
{
   SwingPoint sp;
   sp.price = 999999;
   sp.bar = -1;
   sp.isHigh = false;
   
   for(int i = confirmBars + 1; i < lookback; i++)
   {
      double low_i = iLow(_Symbol, PERIOD_CURRENT, i);
      bool isSwing = true;
      
      for(int j = 1; j <= confirmBars; j++)
      {
         if(iLow(_Symbol, PERIOD_CURRENT, i-j) <= low_i ||
            iLow(_Symbol, PERIOD_CURRENT, i+j) <= low_i)
         {
            isSwing = false;
            break;
         }
      }
      
      if(isSwing)
      {
         sp.price = low_i;
         sp.bar = i;
         return sp;
      }
   }
   return sp;
}

//+------------------------------------------------------------------+
//| SmartMoney: Detect Break of Structure (BOS)                       |
//+------------------------------------------------------------------+
int DetectBOS()
{
   // Returns: +1 = bullish BOS, -1 = bearish BOS, 0 = none
   
   SwingPoint lastHigh = FindSwingHigh(InpSwingLookback, InpSwingConfirmBars);
   SwingPoint lastLow  = FindSwingLow(InpSwingLookback, InpSwingConfirmBars);
   
   if(lastHigh.bar < 0 || lastLow.bar < 0)
      return 0;
   
   double currentClose = iClose(_Symbol, PERIOD_CURRENT, 1);
   double bosSize = MathAbs(lastHigh.price - lastLow.price);
   
   // Minimum BOS size filter
   if(bosSize < InpBOSMinSize * _Point)
      return 0;
   
   // Bullish BOS: price breaks above swing high
   if(currentClose > lastHigh.price)
      return 1;
   
   // Bearish BOS: price breaks below swing low
   if(currentClose < lastLow.price)
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| SmartMoney: Detect Fair Value Gap (FVG)                           |
//+------------------------------------------------------------------+
struct FVGZone {
   double high;
   double low;
   int    bar;
   int    direction; // +1 = bullish, -1 = bearish
};

FVGZone DetectFVG()
{
   FVGZone fvg;
   fvg.high = 0;
   fvg.low = 0;
   fvg.bar = -1;
   fvg.direction = 0;
   
   // Scan for FVG in recent bars
   for(int i = 1; i < InpFVGMaxAge; i++)
   {
      double h1 = iHigh(_Symbol, PERIOD_CURRENT, i + 1);  // Bar before
      double l3 = iLow(_Symbol, PERIOD_CURRENT, i - 1);   // Bar after
      double l1 = iLow(_Symbol, PERIOD_CURRENT, i + 1);
      double h3 = iHigh(_Symbol, PERIOD_CURRENT, i - 1);
      
      // Bullish FVG: gap between bar[i+1] high and bar[i-1] low
      if(l3 > h1 && (l3 - h1) >= InpFVGMinSize * _Point)
      {
         fvg.high = l3;
         fvg.low = h1;
         fvg.bar = i;
         fvg.direction = 1;
         return fvg;
      }
      
      // Bearish FVG: gap between bar[i-1] high and bar[i+1] low
      if(l1 > h3 && (l1 - h3) >= InpFVGMinSize * _Point)
      {
         fvg.high = l1;
         fvg.low = h3;
         fvg.bar = i;
         fvg.direction = -1;
         return fvg;
      }
   }
   
   return fvg;
}

//+------------------------------------------------------------------+
//| SmartMoney: Detect Order Block (OB)                               |
//+------------------------------------------------------------------+
struct OBZone {
   double high;
   double low;
   int    bar;
   int    direction; // +1 = bullish, -1 = bearish
};

OBZone DetectOrderBlock()
{
   OBZone ob;
   ob.high = 0;
   ob.low = 0;
   ob.bar = -1;
   ob.direction = 0;
   
   for(int i = InpOBMinCandles; i < InpOBMaxAge; i++)
   {
      // Look for opposing candle before a move
      double o_i = iOpen(_Symbol, PERIOD_CURRENT, i);
      double c_i = iClose(_Symbol, PERIOD_CURRENT, i);
      double h_i = iHigh(_Symbol, PERIOD_CURRENT, i);
      double l_i = iLow(_Symbol, PERIOD_CURRENT, i);
      
      // Check if this is a bearish candle followed by bullish move
      if(c_i < o_i) // Bearish candle
      {
         // Check if price moved up after
         double moveUp = iClose(_Symbol, PERIOD_CURRENT, i-1) - c_i;
         if(moveUp > (h_i - l_i) * 0.5)
         {
            ob.high = h_i;
            ob.low = l_i;
            ob.bar = i;
            ob.direction = 1; // Bullish OB (last bearish before rally)
            return ob;
         }
      }
      
      // Bullish candle followed by bearish move
      if(c_i > o_i) // Bullish candle
      {
         double moveDown = c_i - iClose(_Symbol, PERIOD_CURRENT, i-1);
         if(moveDown > (h_i - l_i) * 0.5)
         {
            ob.high = h_i;
            ob.low = l_i;
            ob.bar = i;
            ob.direction = -1; // Bearish OB (last bullish before drop)
            return ob;
         }
      }
   }
   
   return ob;
}

//+------------------------------------------------------------------+
//| SmartMoney: Detect Liquidity Sweep                                |
//+------------------------------------------------------------------+
int DetectLiquiditySweep()
{
   // Returns: +1 = bullish sweep (buy), -1 = bearish sweep (sell), 0 = none
   
   SwingPoint high = FindSwingHigh(InpLiqSwingLookback, 3);
   SwingPoint low  = FindSwingLow(InpLiqSwingLookback, 3);
   
   if(high.bar < 0 || low.bar < 0)
      return 0;
   
   double currentClose = iClose(_Symbol, PERIOD_CURRENT, 1);
   double currentHigh  = iHigh(_Symbol, PERIOD_CURRENT, 1);
   double currentLow   = iLow(_Symbol, PERIOD_CURRENT, 1);
   double currentOpen  = iOpen(_Symbol, PERIOD_CURRENT, 1);
   
   double range = currentHigh - currentLow;
   if(range == 0) return 0;
   
   // Bullish sweep: price sweeps below swing low then closes above
   if(currentLow < low.price && currentClose > low.price)
   {
      double lowerWick = MathMin(currentOpen, currentClose) - currentLow;
      if(lowerWick / range >= InpLiqWickPercent / 1000.0)
         return 1;
   }
   
   // Bearish sweep: price sweeps above swing high then closes below
   if(currentHigh > high.price && currentClose < high.price)
   {
      double upperWick = currentHigh - MathMax(currentOpen, currentClose);
      if(upperWick / range >= InpLiqWickPercent / 1000.0)
         return -1;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| Calculate position size based on risk                             |
//+------------------------------------------------------------------+
double CalculateLotSize(double slPoints)
{
   if(InpRiskPercent <= 0)
      return InpLotSize;
   
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * InpRiskPercent / 100.0;
   
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   
   if(tickValue == 0 || tickSize == 0 || slPoints == 0)
      return InpLotSize;
   
   double slTicks = slPoints / tickSize;
   double lotSize = riskAmount / (slTicks * tickValue);
   
   // Normalize to broker limits
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
   
   return lotSize;
}

//+------------------------------------------------------------------+
//| Count open positions for this EA                                  |
//+------------------------------------------------------------------+
int CountPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(posInfo.SelectByIndex(i))
      {
         if(posInfo.Magic() == 20250501 && posInfo.Symbol() == _Symbol)
            count++;
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Execute trade                                                     |
//+------------------------------------------------------------------+
bool ExecuteTrade(int direction, string reason)
{
   if(CountPositions() >= InpMaxTrades)
      return false;
   
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   double sl, tp, entry;
   double slPoints = InpStopLoss * _Point;
   double tpPoints = InpTakeProfit * _Point;
   
   double lotSize = CalculateLotSize(slPoints);
   
   string comment = StringFormat("NeuralSMC|%s", reason);
   
   if(direction > 0) // BUY
   {
      entry = ask;
      sl = entry - slPoints;
      tp = entry + tpPoints;
      
      if(trade.Buy(lotSize, _Symbol, entry, sl, tp, comment))
      {
         Print("BUY: ", reason, " Lot=", DoubleToString(lotSize, 2),
               " SL=", DoubleToString(sl, _Digits), " TP=", DoubleToString(tp, _Digits));
         return true;
      }
   }
   else // SELL
   {
      entry = bid;
      sl = entry + slPoints;
      tp = entry - tpPoints;
      
      if(trade.Sell(lotSize, _Symbol, entry, sl, tp, comment))
      {
         Print("SELL: ", reason, " Lot=", DoubleToString(lotSize, 2),
               " SL=", DoubleToString(sl, _Digits), " TP=", DoubleToString(tp, _Digits));
         return true;
      }
   }
   
   Print("Trade failed: ", trade.ResultRetcodeDescription());
   return false;
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   // Only trade on new bar
   static datetime lastBar = 0;
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(currentBar == lastBar) return;
   lastBar = currentBar;
   
   // Update feature history
   UpdateHistory();
   
   // ==========================================
   // STEP 1: Run Neural Filters
   // ==========================================
   
   double predictedADX = RunLSTMFilter();
   double winProb      = RunCatBoostFilter();
   double upProb       = RunPricePredictor();
   
   // ==========================================
   // STEP 2: SmartMoney Signal Detection
   // ==========================================
   
   int bosSignal = DetectBOS();
   FVGZone fvg = DetectFVG();
   OBZone ob = DetectOrderBlock();
   int liqSignal = DetectLiquiditySweep();
   
   // ==========================================
   // STEP 3: Confluence Scoring
   // ==========================================
   
   int buyScore = 0;
   int sellScore = 0;
   string reasons = "";
   
   // BOS signal
   if(bosSignal > 0) { buyScore += 2; reasons += "BOS+"; }
   if(bosSignal < 0) { sellScore += 2; reasons += "BOS-"; }
   
   // FVG signal
   if(fvg.direction > 0) { buyScore += 1; reasons += "FVG+"; }
   if(fvg.direction < 0) { sellScore += 1; reasons += "FVG-"; }
   
   // Order Block signal
   if(ob.direction > 0) { buyScore += 1; reasons += "OB+"; }
   if(ob.direction < 0) { sellScore += 1; reasons += "OB-"; }
   
   // Liquidity sweep
   if(liqSignal > 0) { buyScore += 2; reasons += "LIQ+"; }
   if(liqSignal < 0) { sellScore += 2; reasons += "LIQ-"; }
   
   // ==========================================
   // STEP 4: Apply Neural Filters
   // ==========================================
   
   // LSTM Filter: reject if not trending
   if(predictedADX < InpLSTM_ADX_Threshold)
   {
      if(buyScore > 0 || sellScore > 0)
      {
         static int filterLog = 0;
         if(filterLog++ % 50 == 0)
            Print("LSTM FILTER: ADX=", DoubleToString(predictedADX, 1), " < ", 
                  DoubleToString(InpLSTM_ADX_Threshold, 1), " — Skipping");
      }
      return; // Not trending, skip all signals
   }
   
   // CatBoost Filter: reject low quality signals
   if(winProb < InpCatBoost_Threshold)
   {
      if(buyScore > 0 || sellScore > 0)
      {
         static int cbFilterLog = 0;
         if(cbFilterLog++ % 50 == 0)
            Print("CATBOOST FILTER: WinProb=", DoubleToString(winProb, 3), " < ",
                  DoubleToString(InpCatBoost_Threshold, 3), " — Skipping");
      }
      return;
   }
   
   // Price Predictor: boost/reduce signal scores
   if(InpUsePricePredictor)
   {
      if(upProb > InpPrice_Confidence)
      {
         buyScore += 1;
         reasons += StringFormat("NN_UP(%.2f)", upProb);
      }
      else if(upProb < (1.0 - InpPrice_Confidence))
      {
         sellScore += 1;
         reasons += StringFormat("NN_DN(%.2f)", upProb);
      }
   }
   
   // ==========================================
   // STEP 5: Trade Decision
   // ==========================================
   
   int minScore = 2; // Minimum confluence to trade
   
   if(buyScore >= minScore && buyScore > sellScore)
   {
      ExecuteTrade(1, reasons);
   }
   else if(sellScore >= minScore && sellScore > buyScore)
   {
      ExecuteTrade(-1, reasons);
   }
}

//+------------------------------------------------------------------+
