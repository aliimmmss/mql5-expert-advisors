//+------------------------------------------------------------------+
//|                            SmartMoney_Concepts_EA.mq5             |
//|                            Combined Non-Lagging Strategies EA     |
//|                            v1.0 - SMC + Price Action + Sessions   |
//+------------------------------------------------------------------+
#property copyright "Based on 109 MQL5 Non-Lagging Strategy Articles"
#property link      ""
#property version   "1.00"
#property description "Smart Money Concepts EA - Combined Non-Lagging Strategies"
#property description "BOS + CHoCH + FVG + Order Blocks + Liquidity Sweeps + Session Breakouts"
#property description "Sentiment-based strategy switching across multiple timeframes"

#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>
#include <Arrays/ArrayObj.mqh>

//+------------------------------------------------------------------+
//| STRATEGY TOGGLES                                                  |
//+------------------------------------------------------------------+
input group "=== CORE SMC STRATEGIES ==="
input bool     InpUseBOS             = true;          // Break of Structure (BOS)
input bool     InpUseCHoCH           = true;          // Change of Character (CHoCH)
input bool     InpUseFVG             = true;          // Fair Value Gaps (FVG)
input bool     InpUseIFVG            = true;          // Inverse Fair Value Gaps (IFVG)
input bool     InpUseOrderBlocks     = true;          // Order Blocks
input bool     InpUseLiqSweep        = true;          // Liquidity Sweeps

input group "=== SESSION STRATEGIES ==="
input bool     InpUseOpeningRange    = true;          // Opening Range Breakout
input bool     InpUseMidnightRange   = true;          // Midnight Range Breakout

input group "=== SENTIMENT ENGINE ==="
input bool     InpUseSentiment       = true;          // Use Sentiment-Based Switching
input ENUM_TIMEFRAMES InpHigherTF    = PERIOD_H4;     // Higher Timeframe (Bias)
input ENUM_TIMEFRAMES InpMediumTF    = PERIOD_H1;     // Medium Timeframe (Structure)
input ENUM_TIMEFRAMES InpLowerTF     = PERIOD_M15;    // Lower Timeframe (Entry)

input group "=== TRADE MANAGEMENT ==="
input double   InpLotSize            = 0.01;          // Lot Size
input int      InpStopLoss           = 500;           // Stop Loss (points)
input int      InpTakeProfit         = 1500;          // Take Profit (points)
input double   InpRiskReward         = 2.0;           // Risk:Reward Ratio
input int      InpMaxTrades          = 3;             // Max Concurrent Trades
input long     InpMagicNumber        = 888888;        // Magic Number

input group "=== MARKET STRUCTURE ==="
input int      InpSwingLookback      = 5;             // Swing Detection Lookback
input int      InpSwingConfirmBars   = 2;             // Swing Confirmation Bars
input double   InpBOSMinSize         = 100;           // Min BOS Size (points)

input group "=== FAIR VALUE GAPS ==="
input int      InpFVGMinSize         = 50;            // Min FVG Size (points)
input int      InpFVGMaxAge          = 50;            // Max FVG Age (bars)
input double   InpFVGEntryPercent    = 50;            // FVG Entry Level (%)

input group "=== ORDER BLOCKS ==="
input int      InpOBMinCandles       = 3;             // Min Consecutive Candles for OB
input int      InpOBMaxAge           = 100;           // Max OB Age (bars)
input double   InpOBEntryPercent     = 50;            // OB Entry Level (%)

input group "=== LIQUIDITY SWEEPS ==="
input int      InpLiqSwingLookback   = 10;            // Liquidity Swing Lookback
input double   InpLiqWickPercent     = 60;            // Min Wick % of Candle

input group "=== SESSION RANGES ==="
input int      InpOpeningRangeStart  = 0;             // Opening Range Start Hour
input int      InpOpeningRangeEnd    = 6;             // Opening Range End Hour
input int      InpMidnightStart      = 0;             // Midnight Range Start Hour
input int      InpMidnightEnd        = 6;             // Midnight Range End Hour
input double   InpSessionBreakConf   = 1.5;           // Session Break Confidence

input group "=== VISUAL SETTINGS ==="
input bool     InpDrawStructure      = true;          // Draw Market Structure
input bool     InpDrawFVG            = true;          // Draw Fair Value Gaps
input bool     InpDrawOB             = true;          // Draw Order Blocks
input bool     InpDrawLiquidity      = true;          // Draw Liquidity Levels
input bool     InpDrawSessions       = true;          // Draw Session Ranges
input color    InpBullColor          = clrLime;       // Bullish Color
input color    InpBearColor          = clrRed;        // Bearish Color
input color    InpFVGColor           = clrPaleGreen;  // FVG Color
input color    InpOBColor            = clrGold;       // Order Block Color
input color    InpLiqColor           = clrDodgerBlue; // Liquidity Color
input color    InpSessionColor       = clrGray;       // Session Range Color

//+------------------------------------------------------------------+
//| STRUCTURES AND CLASSES                                            |
//+------------------------------------------------------------------+

// Swing Point Structure
struct SwingPoint {
   double   price;
   datetime time;
   int      barIndex;
   bool     isHigh;
   string   label;  // HH, HL, LH, LL
};

// Fair Value Gap Structure
struct FairValueGap {
   double   high;
   double   low;
   double   midpoint;
   datetime time;
   int      barIndex;
   bool     isBullish;
   bool     mitigated;
   bool     inverted;
   int      state;  // 0=normal, 1=mitigated, 2=retraced, 3=inverted
};

// Order Block Structure
struct OrderBlock {
   double   high;
   double   low;
   double   midpoint;
   datetime time;
   int      barIndex;
   bool     isBullish;
   bool     mitigated;
   int      consecutiveCandles;
};

// Liquidity Level Structure
struct LiquidityLevel {
   double   price;
   datetime time;
   int      barIndex;
   bool     isBuySide;  // true=BSL, false=SSL
   bool     swept;
};

// Session Range Structure
struct SessionRange {
   double   high;
   double   low;
   datetime startTime;
   datetime endTime;
   bool     broken;
   bool     isMidnight;
};

// Market Sentiment Enum
enum ENUM_SENTIMENT {
   SENTIMENT_STRONG_BULL = 2,    // Strong Bullish
   SENTIMENT_BULL        = 1,    // Bullish
   SENTIMENT_NEUTRAL     = 0,    // Neutral
   SENTIMENT_BEAR        = -1,   // Bearish
   SENTIMENT_STRONG_BEAR = -2    // Strong Bearish
};

// Strategy Type Enum
enum ENUM_STRATEGY_TYPE {
   STRATEGY_BOS,           // Break of Structure
   STRATEGY_CHOCH,         // Change of Character
   STRATEGY_FVG,           // Fair Value Gap
   STRATEGY_IFVG,          // Inverse Fair Value Gap
   STRATEGY_OB,            // Order Block
   STRATEGY_LIQ_SWEEP,    // Liquidity Sweep
   STRATEGY_OPENING_RANGE, // Opening Range Breakout
   STRATEGY_MIDNIGHT_RANGE // Midnight Range Breakout
};

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                  |
//+------------------------------------------------------------------+
CTrade         trade;
CPositionInfo  posInfo;

// Swing Points Arrays
SwingPoint     swingHighs[];
SwingPoint     swingLows[];
SwingPoint     lastSwingHigh;
SwingPoint     lastSwingLow;

// Market Structure
string         currentTrend;     // "BULLISH", "BEARISH", "NEUTRAL"
bool           bosDetected;
bool           chochDetected;
datetime       lastBOSTime;
datetime       lastCHoCHTime;

// Fair Value Gaps
FairValueGap   bullishFVGs[];
FairValueGap   bearishFVGs[];
int            maxFVGs = 50;

// Order Blocks
OrderBlock     bullishOBs[];
OrderBlock     bearishOBs[];
int            maxOBs = 50;

// Liquidity Levels
LiquidityLevel buySideLiq[];
LiquidityLevel sellSideLiq[];
int            maxLiqLevels = 50;

// Session Ranges
SessionRange   currentSession;
SessionRange   midnightSession;
datetime       lastSessionReset;
datetime       lastMidnightReset;

// Sentiment
ENUM_SENTIMENT currentSentiment;
string         currentSentimentText;
datetime       lastSentimentUpdate;

// Trade Tracking
int            activeTrades;
datetime       lastTradeTime;
string         lastStrategy;

// Bar Tracking
datetime       lastBarTime;
int            currentBarIndex;
datetime       lastStateSave;

// Indicator handles
int            g_ma200Handle = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit() {
   trade.SetExpertMagicNumber(InpMagicNumber);
   
   // Initialize arrays
   ArrayResize(swingHighs, 0);
   ArrayResize(swingLows, 0);
   ArrayResize(bullishFVGs, 0);
   ArrayResize(bearishFVGs, 0);
   ArrayResize(bullishOBs, 0);
   ArrayResize(bearishOBs, 0);
   ArrayResize(buySideLiq, 0);
   ArrayResize(sellSideLiq, 0);
   
   // Initialize state
   currentTrend = "NEUTRAL";
   bosDetected = false;
   chochDetected = false;
   currentSentiment = SENTIMENT_NEUTRAL;
   currentSentimentText = "Neutral";
   activeTrades = 0;
   lastBarTime = 0;
   currentBarIndex = 0;
   
   // Initialize session ranges
   currentSession.high = 0;
   currentSession.low = 999999;
   currentSession.broken = false;
   currentSession.isMidnight = false;
   
   midnightSession.high = 0;
   midnightSession.low = 999999;
   midnightSession.broken = false;
   midnightSession.isMidnight = true;
   
   lastSessionReset = 0;
   lastMidnightReset = 0;
   lastSentimentUpdate = 0;
   lastStateSave = 0;
   
   // Restore state from previous run (weekend/restart persistence)
   LoadState();
   
   // Create indicator handles
   g_ma200Handle = iMA(_Symbol, InpHigherTF, 200, 0, MODE_EMA, PRICE_CLOSE);
   if(g_ma200Handle == INVALID_HANDLE)
      Print("Failed to create MA200 handle for ", EnumToString(InpHigherTF));
   
   Print("SmartMoney Concepts EA Initialized");
   Print("Strategies: BOS=", InpUseBOS, " CHoCH=", InpUseCHoCH, 
         " FVG=", InpUseFVG, " IFVG=", InpUseIFVG,
         " OB=", InpUseOrderBlocks, " LiqSweep=", InpUseLiqSweep,
         " OpeningRange=", InpUseOpeningRange, " MidnightRange=", InpUseMidnightRange);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   // Save state before shutdown (weekend persistence)
   SaveState();
   
   // Release indicator handles
   if(g_ma200Handle != INVALID_HANDLE)
      IndicatorRelease(g_ma200Handle);
   
   // Clean up visual objects
   ObjectsDeleteAll(0, "SMC_");
   ObjectsDeleteAll(0, "FVG_");
   ObjectsDeleteAll(0, "OB_");
   ObjectsDeleteAll(0, "LIQ_");
   ObjectsDeleteAll(0, "SESSION_");
   ObjectsDeleteAll(0, "STRUCTURE_");
   
   Comment("");
   Print("SmartMoney Concepts EA Removed");
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick() {
   // Check for new bar
   if(!IsNewBar()) return;
   
   currentBarIndex = Bars(_Symbol, PERIOD_CURRENT) - 1;
   
   // Update active trades count
   UpdateActiveTrades();
   
   // === LAYER 1: MARKET STRUCTURE ===
   DetectSwingPoints();
   UpdateMarketStructure();
   
   // === LAYER 2: ZONE DETECTION ===
   if(InpUseFVG || InpUseIFVG) DetectFairValueGaps();
   if(InpUseOrderBlocks) DetectOrderBlocks();
   if(InpUseLiqSweep) DetectLiquidityLevels();
   
   // === LAYER 3: SESSION RANGES ===
   if(InpUseOpeningRange) UpdateOpeningRange();
   if(InpUseMidnightRange) UpdateMidnightRange();
   
   // Save state periodically (every 5 minutes)
   if(TimeCurrent() - lastStateSave >= 300) SaveState();
   
   // === LAYER 4: SENTIMENT ENGINE ===
   if(InpUseSentiment) CalculateSentiment();
   
   // === LAYER 5: STRATEGY EXECUTION ===
   ExecuteStrategies();
   
   // === LAYER 6: VISUALIZATION ===
   if(InpDrawStructure) DrawMarketStructure();
   if(InpDrawFVG) DrawFairValueGaps();
   if(InpDrawOB) DrawOrderBlocks();
   if(InpDrawLiquidity) DrawLiquidityLevels();
   if(InpDrawSessions) DrawSessionRanges();
   
   // Display status
   DisplayStatus();
}

//+------------------------------------------------------------------+
//| Check for new bar                                                 |
//+------------------------------------------------------------------+
bool IsNewBar() {
   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(currentBarTime != lastBarTime) {
      lastBarTime = currentBarTime;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Update active trades count                                        |
//+------------------------------------------------------------------+
void UpdateActiveTrades() {
   activeTrades = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      if(posInfo.SelectByIndex(i)) {
         if(posInfo.Symbol() == _Symbol && posInfo.Magic() == InpMagicNumber) {
            activeTrades++;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| DETECT SWING POINTS                                               |
//+------------------------------------------------------------------+
void DetectSwingPoints() {
   int lookback = InpSwingLookback;
   int confirm = InpSwingConfirmBars;
   
   // Check for swing high
   bool isSwingHigh = true;
   double highPrice = iHigh(_Symbol, PERIOD_CURRENT, lookback);
   
   for(int i = 1; i <= confirm; i++) {
      if(iHigh(_Symbol, PERIOD_CURRENT, lookback - i) >= highPrice ||
         iHigh(_Symbol, PERIOD_CURRENT, lookback + i) >= highPrice) {
         isSwingHigh = false;
         break;
      }
   }
   
   if(isSwingHigh) {
      SwingPoint newHigh;
      newHigh.price = highPrice;
      newHigh.time = iTime(_Symbol, PERIOD_CURRENT, lookback);
      newHigh.barIndex = currentBarIndex - lookback;
      newHigh.isHigh = true;
      newHigh.label = ClassifySwingHigh(highPrice);
      
      // Add to array if not duplicate
      if(ArraySize(swingHighs) == 0 || 
         swingHighs[ArraySize(swingHighs)-1].barIndex != newHigh.barIndex) {
         ArrayResize(swingHighs, ArraySize(swingHighs) + 1);
         swingHighs[ArraySize(swingHighs) - 1] = newHigh;
         lastSwingHigh = newHigh;
         
         // Limit array size
         if(ArraySize(swingHighs) > 100) {
            ArrayRemove(swingHighs, 0, 1);
         }
      }
   }
   
   // Check for swing low
   bool isSwingLow = true;
   double lowPrice = iLow(_Symbol, PERIOD_CURRENT, lookback);
   
   for(int i = 1; i <= confirm; i++) {
      if(iLow(_Symbol, PERIOD_CURRENT, lookback - i) <= lowPrice ||
         iLow(_Symbol, PERIOD_CURRENT, lookback + i) <= lowPrice) {
         isSwingLow = false;
         break;
      }
   }
   
   if(isSwingLow) {
      SwingPoint newLow;
      newLow.price = lowPrice;
      newLow.time = iTime(_Symbol, PERIOD_CURRENT, lookback);
      newLow.barIndex = currentBarIndex - lookback;
      newLow.isHigh = false;
      newLow.label = ClassifySwingLow(lowPrice);
      
      // Add to array if not duplicate
      if(ArraySize(swingLows) == 0 || 
         swingLows[ArraySize(swingLows)-1].barIndex != newLow.barIndex) {
         ArrayResize(swingLows, ArraySize(swingLows) + 1);
         swingLows[ArraySize(swingLows) - 1] = newLow;
         lastSwingLow = newLow;
         
         // Limit array size
         if(ArraySize(swingLows) > 100) {
            ArrayRemove(swingLows, 0, 1);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Classify swing high (HH or LH)                                   |
//+------------------------------------------------------------------+
string ClassifySwingHigh(double currentHigh) {
   if(ArraySize(swingHighs) == 0) return "HH";
   
   double previousHigh = swingHighs[ArraySize(swingHighs) - 1].price;
   
   if(currentHigh > previousHigh) return "HH";  // Higher High
   else return "LH";  // Lower High
}

//+------------------------------------------------------------------+
//| Classify swing low (HL or LL)                                     |
//+------------------------------------------------------------------+
string ClassifySwingLow(double currentLow) {
   if(ArraySize(swingLows) == 0) return "HL";
   
   double previousLow = swingLows[ArraySize(swingLows) - 1].price;
   
   if(currentLow > previousLow) return "HL";  // Higher Low
   else return "LL";  // Lower Low
}

//+------------------------------------------------------------------+
//| UPDATE MARKET STRUCTURE (BOS/CHoCH Detection)                     |
//+------------------------------------------------------------------+
void UpdateMarketStructure() {
   if(ArraySize(swingHighs) < 2 || ArraySize(swingLows) < 2) return;
   
   double currentClose = iClose(_Symbol, PERIOD_CURRENT, 0);
   double prevClose = iClose(_Symbol, PERIOD_CURRENT, 1);
   
   // Get recent swing points
   SwingPoint recentHigh = swingHighs[ArraySize(swingHighs) - 1];
   SwingPoint prevHigh = swingHighs[ArraySize(swingHighs) - 2];
   SwingPoint recentLow = swingLows[ArraySize(swingLows) - 1];
   SwingPoint prevLow = swingLows[ArraySize(swingLows) - 2];
   
   // Detect Break of Structure (BOS) - Trend Continuation
   // Bullish BOS: Price breaks above recent swing high in uptrend
   if(currentTrend == "BULLISH" || currentTrend == "NEUTRAL") {
      if(currentClose > recentHigh.price && prevClose <= recentHigh.price) {
         double bosSize = (currentClose - recentHigh.price) / _Point;
         if(bosSize >= InpBOSMinSize) {
            bosDetected = true;
            lastBOSTime = TimeCurrent();
            currentTrend = "BULLISH";
            
            if(InpUseBOS && IsStrategyAllowed(STRATEGY_BOS)) {
               Print("BOS Detected: Bullish continuation at ", recentHigh.price);
            }
         }
      }
   }
   
   // Bearish BOS: Price breaks below recent swing low in downtrend
   if(currentTrend == "BEARISH" || currentTrend == "NEUTRAL") {
      if(currentClose < recentLow.price && prevClose >= recentLow.price) {
         double bosSize = (recentLow.price - currentClose) / _Point;
         if(bosSize >= InpBOSMinSize) {
            bosDetected = true;
            lastBOSTime = TimeCurrent();
            currentTrend = "BEARISH";
            
            if(InpUseBOS && IsStrategyAllowed(STRATEGY_BOS)) {
               Print("BOS Detected: Bearish continuation at ", recentLow.price);
            }
         }
      }
   }
   
   // Detect Change of Character (CHoCH) - Trend Reversal
   // Bullish CHoCH: Price breaks above recent swing high in downtrend
   if(currentTrend == "BEARISH") {
      if(currentClose > recentHigh.price && prevClose <= recentHigh.price) {
         chochDetected = true;
         lastCHoCHTime = TimeCurrent();
         currentTrend = "BULLISH";
         
         if(InpUseCHoCH && IsStrategyAllowed(STRATEGY_CHOCH)) {
            Print("CHoCH Detected: Bullish reversal at ", recentHigh.price);
         }
      }
   }
   
   // Bearish CHoCH: Price breaks below recent swing low in uptrend
   if(currentTrend == "BULLISH") {
      if(currentClose < recentLow.price && prevClose >= recentLow.price) {
         chochDetected = true;
         lastCHoCHTime = TimeCurrent();
         currentTrend = "BEARISH";
         
         if(InpUseCHoCH && IsStrategyAllowed(STRATEGY_CHOCH)) {
            Print("CHoCH Detected: Bearish reversal at ", recentLow.price);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| DETECT FAIR VALUE GAPS                                            |
//+------------------------------------------------------------------+
void DetectFairValueGaps() {
   // Bullish FVG: Low of candle 3 > High of candle 1
   double high1 = iHigh(_Symbol, PERIOD_CURRENT, 3);
   double low3 = iLow(_Symbol, PERIOD_CURRENT, 1);
   
   if(low3 > high1) {
      FairValueGap newFVG;
      newFVG.high = low3;
      newFVG.low = high1;
      newFVG.midpoint = (high1 + low3) / 2;
      newFVG.time = iTime(_Symbol, PERIOD_CURRENT, 2);
      newFVG.barIndex = currentBarIndex - 2;
      newFVG.isBullish = true;
      newFVG.mitigated = false;
      newFVG.inverted = false;
      newFVG.state = 0;
      
      double fvgSize = (low3 - high1) / _Point;
      if(fvgSize >= InpFVGMinSize) {
         ArrayResize(bullishFVGs, ArraySize(bullishFVGs) + 1);
         bullishFVGs[ArraySize(bullishFVGs) - 1] = newFVG;
         
         if(ArraySize(bullishFVGs) > maxFVGs) {
            ArrayRemove(bullishFVGs, 0, 1);
         }
      }
   }
   
   // Bearish FVG: High of candle 1 < Low of candle 3
   double low1 = iLow(_Symbol, PERIOD_CURRENT, 3);
   double high3 = iHigh(_Symbol, PERIOD_CURRENT, 1);
   
   if(high3 < low1) {
      FairValueGap newFVG;
      newFVG.high = low1;
      newFVG.low = high3;
      newFVG.midpoint = (low1 + high3) / 2;
      newFVG.time = iTime(_Symbol, PERIOD_CURRENT, 2);
      newFVG.barIndex = currentBarIndex - 2;
      newFVG.isBullish = false;
      newFVG.mitigated = false;
      newFVG.inverted = false;
      newFVG.state = 0;
      
      double fvgSize = (low1 - high3) / _Point;
      if(fvgSize >= InpFVGMinSize) {
         ArrayResize(bearishFVGs, ArraySize(bearishFVGs) + 1);
         bearishFVGs[ArraySize(bearishFVGs) - 1] = newFVG;
         
         if(ArraySize(bearishFVGs) > maxFVGs) {
            ArrayRemove(bearishFVGs, 0, 1);
         }
      }
   }
   
   // Update FVG states (mitigation and inversion)
   UpdateFVGStates();
}

//+------------------------------------------------------------------+
//| Update FVG States (Mitigation/Inversion)                          |
//+------------------------------------------------------------------+
void UpdateFVGStates() {
   double currentClose = iClose(_Symbol, PERIOD_CURRENT, 0);
   double currentHigh = iHigh(_Symbol, PERIOD_CURRENT, 0);
   double currentLow = iLow(_Symbol, PERIOD_CURRENT, 0);
   
   // Update bullish FVGs
   for(int i = ArraySize(bullishFVGs) - 1; i >= 0; i--) {
      if(bullishFVGs[i].state == 0) {  // Normal state
         // Mitigation: Price breaks below FVG low
         if(currentLow < bullishFVGs[i].low) {
            bullishFVGs[i].state = 1;  // Mitigated
            bullishFVGs[i].mitigated = true;
         }
         // Check age
         else if(currentBarIndex - bullishFVGs[i].barIndex > InpFVGMaxAge) {
            ArrayRemove(bullishFVGs, i, 1);
         }
      }
      else if(bullishFVGs[i].state == 1) {  // Mitigated state
         // Retracement: Price re-enters FVG
         if(currentClose > bullishFVGs[i].low && currentClose < bullishFVGs[i].high) {
            bullishFVGs[i].state = 2;  // Retraced
         }
      }
      else if(bullishFVGs[i].state == 2) {  // Retraced state
         // Inversion: Price closes below FVG low (bearish IFVG)
         if(currentClose < bullishFVGs[i].low) {
            bullishFVGs[i].state = 3;  // Inverted
            bullishFVGs[i].inverted = true;
            
            if(InpUseIFVG && IsStrategyAllowed(STRATEGY_IFVG)) {
               Print("IFVG Detected: Bearish inversion at ", bullishFVGs[i].midpoint);
            }
         }
      }
   }
   
   // Update bearish FVGs
   for(int i = ArraySize(bearishFVGs) - 1; i >= 0; i--) {
      if(bearishFVGs[i].state == 0) {  // Normal state
         // Mitigation: Price breaks above FVG high
         if(currentHigh > bearishFVGs[i].high) {
            bearishFVGs[i].state = 1;  // Mitigated
            bearishFVGs[i].mitigated = true;
         }
         // Check age
         else if(currentBarIndex - bearishFVGs[i].barIndex > InpFVGMaxAge) {
            ArrayRemove(bearishFVGs, i, 1);
         }
      }
      else if(bearishFVGs[i].state == 1) {  // Mitigated state
         // Retracement: Price re-enters FVG
         if(currentClose > bearishFVGs[i].low && currentClose < bearishFVGs[i].high) {
            bearishFVGs[i].state = 2;  // Retraced
         }
      }
      else if(bearishFVGs[i].state == 2) {  // Retraced state
         // Inversion: Price closes above FVG high (bullish IFVG)
         if(currentClose > bearishFVGs[i].high) {
            bearishFVGs[i].state = 3;  // Inverted
            bearishFVGs[i].inverted = true;
            
            if(InpUseIFVG && IsStrategyAllowed(STRATEGY_IFVG)) {
               Print("IFVG Detected: Bullish inversion at ", bearishFVGs[i].midpoint);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| DETECT ORDER BLOCKS                                               |
//+------------------------------------------------------------------+
void DetectOrderBlocks() {
   int minCandles = InpOBMinCandles;
   
   // Bullish Order Block: Bearish candle(s) followed by strong bullish move
   bool hasBullishOB = true;
   int bullishCount = 0;
   
   for(int i = 1; i <= minCandles; i++) {
      if(iClose(_Symbol, PERIOD_CURRENT, i) < iOpen(_Symbol, PERIOD_CURRENT, i)) {
         bullishCount++;
      } else {
         hasBullishOB = false;
         break;
      }
   }
   
   if(hasBullishOB && bullishCount >= minCandles) {
      // Check for strong bullish candle after
      double lastBearClose = iClose(_Symbol, PERIOD_CURRENT, minCandles);
      double lastBearHigh = iHigh(_Symbol, PERIOD_CURRENT, minCandles);
      double currentBullClose = iClose(_Symbol, PERIOD_CURRENT, 0);
      
      if(currentBullClose > lastBearHigh) {
         OrderBlock newOB;
         newOB.high = lastBearHigh;
         newOB.low = iLow(_Symbol, PERIOD_CURRENT, minCandles);
         newOB.midpoint = (newOB.high + newOB.low) / 2;
         newOB.time = iTime(_Symbol, PERIOD_CURRENT, minCandles);
         newOB.barIndex = currentBarIndex - minCandles;
         newOB.isBullish = true;
         newOB.mitigated = false;
         newOB.consecutiveCandles = bullishCount;
         
         ArrayResize(bullishOBs, ArraySize(bullishOBs) + 1);
         bullishOBs[ArraySize(bullishOBs) - 1] = newOB;
         
         if(ArraySize(bullishOBs) > maxOBs) {
            ArrayRemove(bullishOBs, 0, 1);
         }
      }
   }
   
   // Bearish Order Block: Bullish candle(s) followed by strong bearish move
   bool hasBearishOB = true;
   int bearishCount = 0;
   
   for(int i = 1; i <= minCandles; i++) {
      if(iClose(_Symbol, PERIOD_CURRENT, i) > iOpen(_Symbol, PERIOD_CURRENT, i)) {
         bearishCount++;
      } else {
         hasBearishOB = false;
         break;
      }
   }
   
   if(hasBearishOB && bearishCount >= minCandles) {
      // Check for strong bearish candle after
      double lastBullClose = iClose(_Symbol, PERIOD_CURRENT, minCandles);
      double lastBullLow = iLow(_Symbol, PERIOD_CURRENT, minCandles);
      double currentBearClose = iClose(_Symbol, PERIOD_CURRENT, 0);
      
      if(currentBearClose < lastBullLow) {
         OrderBlock newOB;
         newOB.high = iHigh(_Symbol, PERIOD_CURRENT, minCandles);
         newOB.low = lastBullLow;
         newOB.midpoint = (newOB.high + newOB.low) / 2;
         newOB.time = iTime(_Symbol, PERIOD_CURRENT, minCandles);
         newOB.barIndex = currentBarIndex - minCandles;
         newOB.isBullish = false;
         newOB.mitigated = false;
         newOB.consecutiveCandles = bearishCount;
         
         ArrayResize(bearishOBs, ArraySize(bearishOBs) + 1);
         bearishOBs[ArraySize(bearishOBs) - 1] = newOB;
         
         if(ArraySize(bearishOBs) > maxOBs) {
            ArrayRemove(bearishOBs, 0, 1);
         }
      }
   }
   
   // Update OB mitigation
   UpdateOrderBlockStates();
}

//+------------------------------------------------------------------+
//| Update Order Block States                                         |
//+------------------------------------------------------------------+
void UpdateOrderBlockStates() {
   double currentClose = iClose(_Symbol, PERIOD_CURRENT, 0);
   double currentLow = iLow(_Symbol, PERIOD_CURRENT, 0);
   double currentHigh = iHigh(_Symbol, PERIOD_CURRENT, 0);
   
   // Update bullish OBs
   for(int i = ArraySize(bullishOBs) - 1; i >= 0; i--) {
      if(!bullishOBs[i].mitigated) {
         // Mitigation: Price breaks below OB low
         if(currentLow < bullishOBs[i].low) {
            bullishOBs[i].mitigated = true;
         }
         // Check age
         else if(currentBarIndex - bullishOBs[i].barIndex > InpOBMaxAge) {
            ArrayRemove(bullishOBs, i, 1);
         }
      }
   }
   
   // Update bearish OBs
   for(int i = ArraySize(bearishOBs) - 1; i >= 0; i--) {
      if(!bearishOBs[i].mitigated) {
         // Mitigation: Price breaks above OB high
         if(currentHigh > bearishOBs[i].high) {
            bearishOBs[i].mitigated = true;
         }
         // Check age
         else if(currentBarIndex - bearishOBs[i].barIndex > InpOBMaxAge) {
            ArrayRemove(bearishOBs, i, 1);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| DETECT LIQUIDITY LEVELS                                           |
//+------------------------------------------------------------------+
void DetectLiquidityLevels() {
   int lookback = InpLiqSwingLookback;
   
   // Find swing highs (Buy Side Liquidity - BSL)
   for(int i = lookback; i >= 2; i--) {
      bool isSwingHigh = true;
      double highPrice = iHigh(_Symbol, PERIOD_CURRENT, i);
      
      for(int j = 1; j <= 2; j++) {
         if(iHigh(_Symbol, PERIOD_CURRENT, i - j) >= highPrice ||
            iHigh(_Symbol, PERIOD_CURRENT, i + j) >= highPrice) {
            isSwingHigh = false;
            break;
         }
      }
      
      if(isSwingHigh) {
         // Check if already exists
         bool exists = false;
         for(int k = 0; k < ArraySize(buySideLiq); k++) {
            if(MathAbs(buySideLiq[k].price - highPrice) < 10 * _Point) {
               exists = true;
               break;
            }
         }
         
         if(!exists) {
            LiquidityLevel newLiq;
            newLiq.price = highPrice;
            newLiq.time = iTime(_Symbol, PERIOD_CURRENT, i);
            newLiq.barIndex = currentBarIndex - i;
            newLiq.isBuySide = true;
            newLiq.swept = false;
            
            ArrayResize(buySideLiq, ArraySize(buySideLiq) + 1);
            buySideLiq[ArraySize(buySideLiq) - 1] = newLiq;
            
            if(ArraySize(buySideLiq) > maxLiqLevels) {
               ArrayRemove(buySideLiq, 0, 1);
            }
         }
      }
   }
   
   // Find swing lows (Sell Side Liquidity - SSL)
   for(int i = lookback; i >= 2; i--) {
      bool isSwingLow = true;
      double lowPrice = iLow(_Symbol, PERIOD_CURRENT, i);
      
      for(int j = 1; j <= 2; j++) {
         if(iLow(_Symbol, PERIOD_CURRENT, i - j) <= lowPrice ||
            iLow(_Symbol, PERIOD_CURRENT, i + j) <= lowPrice) {
            isSwingLow = false;
            break;
         }
      }
      
      if(isSwingLow) {
         // Check if already exists
         bool exists = false;
         for(int k = 0; k < ArraySize(sellSideLiq); k++) {
            if(MathAbs(sellSideLiq[k].price - lowPrice) < 10 * _Point) {
               exists = true;
               break;
            }
         }
         
         if(!exists) {
            LiquidityLevel newLiq;
            newLiq.price = lowPrice;
            newLiq.time = iTime(_Symbol, PERIOD_CURRENT, i);
            newLiq.barIndex = currentBarIndex - i;
            newLiq.isBuySide = false;
            newLiq.swept = false;
            
            ArrayResize(sellSideLiq, ArraySize(sellSideLiq) + 1);
            sellSideLiq[ArraySize(sellSideLiq) - 1] = newLiq;
            
            if(ArraySize(sellSideLiq) > maxLiqLevels) {
               ArrayRemove(sellSideLiq, 0, 1);
            }
         }
      }
   }
   
   // Check for liquidity sweeps
   CheckLiquiditySweeps();
}

//+------------------------------------------------------------------+
//| Check for Liquidity Sweeps                                        |
//+------------------------------------------------------------------+
void CheckLiquiditySweeps() {
   double currentHigh = iHigh(_Symbol, PERIOD_CURRENT, 0);
   double currentLow = iLow(_Symbol, PERIOD_CURRENT, 0);
   double currentClose = iClose(_Symbol, PERIOD_CURRENT, 0);
   double currentOpen = iOpen(_Symbol, PERIOD_CURRENT, 0);
   
   // Check Buy Side Liquidity sweeps (price wicks above but closes below)
   for(int i = ArraySize(buySideLiq) - 1; i >= 0; i--) {
      if(!buySideLiq[i].swept) {
         if(currentHigh > buySideLiq[i].price && currentClose < buySideLiq[i].price) {
            // Calculate wick percentage
            double candleRange = currentHigh - currentLow;
            double upperWick = currentHigh - MathMax(currentOpen, currentClose);
            double wickPercent = (candleRange > 0) ? (upperWick / candleRange) * 100 : 0;
            
            if(wickPercent >= InpLiqWickPercent) {
               buySideLiq[i].swept = true;
               
               if(InpUseLiqSweep && IsStrategyAllowed(STRATEGY_LIQ_SWEEP)) {
                  Print("Liquidity Sweep: BSL swept at ", buySideLiq[i].price, 
                        " Wick: ", wickPercent, "%");
               }
            }
         }
      }
   }
   
   // Check Sell Side Liquidity sweeps (price wicks below but closes above)
   for(int i = ArraySize(sellSideLiq) - 1; i >= 0; i--) {
      if(!sellSideLiq[i].swept) {
         if(currentLow < sellSideLiq[i].price && currentClose > sellSideLiq[i].price) {
            // Calculate wick percentage
            double candleRange = currentHigh - currentLow;
            double lowerWick = MathMin(currentOpen, currentClose) - currentLow;
            double wickPercent = (candleRange > 0) ? (lowerWick / candleRange) * 100 : 0;
            
            if(wickPercent >= InpLiqWickPercent) {
               sellSideLiq[i].swept = true;
               
               if(InpUseLiqSweep && IsStrategyAllowed(STRATEGY_LIQ_SWEEP)) {
                  Print("Liquidity Sweep: SSL swept at ", sellSideLiq[i].price,
                        " Wick: ", wickPercent, "%");
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| SAVE STATE (GlobalVariables for weekend persistence)              |
//+------------------------------------------------------------------+
void SaveState() {
   string prefix = "SMC_" + _Symbol + "_" + IntegerToString(InpMagicNumber) + "_";
   
   GlobalVariableSet(prefix + "OH", currentSession.high);
   GlobalVariableSet(prefix + "OL", currentSession.low);
   GlobalVariableSet(prefix + "OB", currentSession.broken ? 1.0 : 0.0);
   GlobalVariableSet(prefix + "OST", (double)currentSession.startTime);
   GlobalVariableSet(prefix + "OET", (double)currentSession.endTime);
   
   GlobalVariableSet(prefix + "MH", midnightSession.high);
   GlobalVariableSet(prefix + "ML", midnightSession.low);
   GlobalVariableSet(prefix + "MB", midnightSession.broken ? 1.0 : 0.0);
   GlobalVariableSet(prefix + "MST", (double)midnightSession.startTime);
   GlobalVariableSet(prefix + "MET", (double)midnightSession.endTime);
   
   GlobalVariableSet(prefix + "LSR", (double)lastSessionReset);
   GlobalVariableSet(prefix + "LMR", (double)lastMidnightReset);
   
   double trendVal = 0;
   if(currentTrend == "BULLISH") trendVal = 1;
   else if(currentTrend == "BEARISH") trendVal = -1;
   GlobalVariableSet(prefix + "Trend", trendVal);
   
   GlobalVariableSet(prefix + "SaveTime", (double)TimeCurrent());
   lastStateSave = TimeCurrent();
}

//+------------------------------------------------------------------+
//| LOAD STATE (restore from previous run)                            |
//+------------------------------------------------------------------+
void LoadState() {
   string prefix = "SMC_" + _Symbol + "_" + IntegerToString(InpMagicNumber) + "_";
   
   if(!GlobalVariableCheck(prefix + "SaveTime")) {
      Print("SMC: No saved state found - starting fresh");
      return;
   }
   
   double saveTime = GlobalVariableGet(prefix + "SaveTime");
   datetime savedDt = (datetime)saveTime;
   
   // Only restore if saved within last 3 days (handles weekends)
   if(TimeCurrent() - savedDt > 3 * 86400) {
      Print("SMC: Saved state too old (", TimeToString(savedDt), ") - starting fresh");
      return;
   }
   
   currentSession.high = GlobalVariableGet(prefix + "OH");
   currentSession.low = GlobalVariableGet(prefix + "OL");
   currentSession.broken = (GlobalVariableGet(prefix + "OB") > 0.5);
   currentSession.startTime = (datetime)GlobalVariableGet(prefix + "OST");
   currentSession.endTime = (datetime)GlobalVariableGet(prefix + "OET");
   currentSession.isMidnight = false;
   
   midnightSession.high = GlobalVariableGet(prefix + "MH");
   midnightSession.low = GlobalVariableGet(prefix + "ML");
   midnightSession.broken = (GlobalVariableGet(prefix + "MB") > 0.5);
   midnightSession.startTime = (datetime)GlobalVariableGet(prefix + "MST");
   midnightSession.endTime = (datetime)GlobalVariableGet(prefix + "MET");
   midnightSession.isMidnight = true;
   
   lastSessionReset = (datetime)GlobalVariableGet(prefix + "LSR");
   lastMidnightReset = (datetime)GlobalVariableGet(prefix + "LMR");
   
   double trendVal = GlobalVariableGet(prefix + "Trend");
   if(trendVal > 0.5) currentTrend = "BULLISH";
   else if(trendVal < -0.5) currentTrend = "BEARISH";
   else currentTrend = "NEUTRAL";
   
   Print("SMC: State restored from ", TimeToString(savedDt));
   if(currentSession.high > 0 && currentSession.low < 999999)
      Print("SMC: Opening Range=", DoubleToString(currentSession.low, _Digits),
            " - ", DoubleToString(currentSession.high, _Digits));
   if(midnightSession.high > 0 && midnightSession.low < 999999)
      Print("SMC: Midnight Range=", DoubleToString(midnightSession.low, _Digits),
            " - ", DoubleToString(midnightSession.high, _Digits));
   
   // If it's a new day, backfill from history
   datetime todayDate = iTime(_Symbol, PERIOD_D1, 0);
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   if(lastSessionReset != todayDate && dt.hour >= InpOpeningRangeEnd) {
      BackfillOpeningRange();
   }
   if(lastMidnightReset != todayDate && dt.hour >= InpMidnightEnd) {
      BackfillMidnightRange();
   }
}

//+------------------------------------------------------------------+
//| BACKFILL OPENING RANGE FROM HISTORICAL BARS                      |
//+------------------------------------------------------------------+
void BackfillOpeningRange() {
   datetime todayDate = iTime(_Symbol, PERIOD_D1, 0);
   datetime rangeStart = todayDate + InpOpeningRangeStart * 3600;
   datetime rangeEnd = todayDate + InpOpeningRangeEnd * 3600;
   
   int startBar = iBarShift(_Symbol, PERIOD_CURRENT, rangeStart, false);
   int endBar = iBarShift(_Symbol, PERIOD_CURRENT, rangeEnd, false);
   
   if(startBar < 0 || endBar < 0) {
      Print("SMC: Cannot backfill opening range - bars not found");
      return;
   }
   
   int fromBar = MathMax(startBar, endBar);
   int toBar = MathMin(startBar, endBar);
   
   double maxHigh = 0;
   double minLow = 999999;
   
   for(int i = toBar; i <= fromBar; i++) {
      double h = iHigh(_Symbol, PERIOD_CURRENT, i);
      double l = iLow(_Symbol, PERIOD_CURRENT, i);
      if(h > maxHigh) maxHigh = h;
      if(l < minLow) minLow = l;
   }
   
   if(maxHigh > 0 && minLow < 999999) {
      currentSession.high = maxHigh;
      currentSession.low = minLow;
      currentSession.startTime = rangeStart;
      currentSession.endTime = rangeEnd;
      currentSession.broken = false;
      currentSession.isMidnight = false;
      lastSessionReset = todayDate;
      Print("SMC: Backfilled Opening Range=", DoubleToString(minLow, _Digits),
            " - ", DoubleToString(maxHigh, _Digits));
      SaveState();
   }
}

//+------------------------------------------------------------------+
//| BACKFILL MIDNIGHT RANGE FROM HISTORICAL BARS                     |
//+------------------------------------------------------------------+
void BackfillMidnightRange() {
   datetime todayDate = iTime(_Symbol, PERIOD_D1, 0);
   datetime rangeStart = todayDate + InpMidnightStart * 3600;
   datetime rangeEnd = todayDate + InpMidnightEnd * 3600;
   
   int startBar = iBarShift(_Symbol, PERIOD_CURRENT, rangeStart, false);
   int endBar = iBarShift(_Symbol, PERIOD_CURRENT, rangeEnd, false);
   
   if(startBar < 0 || endBar < 0) {
      Print("SMC: Cannot backfill midnight range - bars not found");
      return;
   }
   
   int fromBar = MathMax(startBar, endBar);
   int toBar = MathMin(startBar, endBar);
   
   double maxHigh = 0;
   double minLow = 999999;
   
   for(int i = toBar; i <= fromBar; i++) {
      double h = iHigh(_Symbol, PERIOD_CURRENT, i);
      double l = iLow(_Symbol, PERIOD_CURRENT, i);
      if(h > maxHigh) maxHigh = h;
      if(l < minLow) minLow = l;
   }
   
   if(maxHigh > 0 && minLow < 999999) {
      midnightSession.high = maxHigh;
      midnightSession.low = minLow;
      midnightSession.startTime = rangeStart;
      midnightSession.endTime = rangeEnd;
      midnightSession.broken = false;
      midnightSession.isMidnight = true;
      lastMidnightReset = todayDate;
      Print("SMC: Backfilled Midnight Range=", DoubleToString(minLow, _Digits),
            " - ", DoubleToString(maxHigh, _Digits));
      SaveState();
   }
}

//+------------------------------------------------------------------+
//| RANGE VALIDITY CHECK                                              |
//+------------------------------------------------------------------+
bool IsRangeValid(SessionRange &session) {
   return (session.high > 0 && session.low < 999999 && session.high > session.low);
}

//+------------------------------------------------------------------+
//| UPDATE OPENING RANGE                                              |
//+------------------------------------------------------------------+
void UpdateOpeningRange() {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   datetime todayDate = iTime(_Symbol, PERIOD_D1, 0);
   
   // Reset on new day - use date comparison, not exact minute
   if(lastSessionReset != todayDate) {
      // If we're past the session window, backfill from history
      if(dt.hour >= InpOpeningRangeEnd) {
         BackfillOpeningRange();
      }
      // If we're at or after session start, reset for live building
      else if(dt.hour >= InpOpeningRangeStart) {
         currentSession.high = 0;
         currentSession.low = 999999;
         currentSession.startTime = TimeCurrent();
         currentSession.broken = false;
         currentSession.isMidnight = false;
         lastSessionReset = todayDate;
         SaveState();
      }
   }
   
   // Update range during opening hours
   if(dt.hour >= InpOpeningRangeStart && dt.hour < InpOpeningRangeEnd) {
      double high = iHigh(_Symbol, PERIOD_CURRENT, 0);
      double low = iLow(_Symbol, PERIOD_CURRENT, 0);
      
      if(high > currentSession.high) currentSession.high = high;
      if(low < currentSession.low) currentSession.low = low;
      
      currentSession.endTime = TimeCurrent();
   }
}

//+------------------------------------------------------------------+
//| UPDATE MIDNIGHT RANGE                                             |
//+------------------------------------------------------------------+
void UpdateMidnightRange() {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   datetime todayDate = iTime(_Symbol, PERIOD_D1, 0);
   
   // Reset on new day - use date comparison, not exact minute
   if(lastMidnightReset != todayDate) {
      // If we're past the session window, backfill from history
      if(dt.hour >= InpMidnightEnd) {
         BackfillMidnightRange();
      }
      // If we're at or after session start, reset for live building
      else if(dt.hour >= InpMidnightStart) {
         midnightSession.high = 0;
         midnightSession.low = 999999;
         midnightSession.startTime = TimeCurrent();
         midnightSession.broken = false;
         midnightSession.isMidnight = true;
         lastMidnightReset = todayDate;
         SaveState();
      }
   }
   
   // Update range during midnight hours
   if(dt.hour >= InpMidnightStart && dt.hour < InpMidnightEnd) {
      double high = iHigh(_Symbol, PERIOD_CURRENT, 0);
      double low = iLow(_Symbol, PERIOD_CURRENT, 0);
      
      if(high > midnightSession.high) midnightSession.high = high;
      if(low < midnightSession.low) midnightSession.low = low;
      
      midnightSession.endTime = TimeCurrent();
   }
}

//+------------------------------------------------------------------+
//| CALCULATE MARKET SENTIMENT                                        |
//+------------------------------------------------------------------+
void CalculateSentiment() {
   // Limit updates to every 5 seconds
   if(TimeCurrent() - lastSentimentUpdate < 5) return;
   lastSentimentUpdate = TimeCurrent();
   
   // Get higher timeframe bias
   int higherTFBias = GetHigherTFBias();
   
   // Get medium timeframe structure
   bool mediumTFBullish = IsStructureBullish(InpMediumTF);
   bool mediumTFBearish = IsStructureBearish(InpMediumTF);
   
   // Get lower timeframe momentum
   bool lowerTFBreakout = HasBreakout(InpLowerTF, higherTFBias);
   
   // Determine sentiment
   if(higherTFBias == 1 && mediumTFBullish) {
      currentSentiment = SENTIMENT_STRONG_BULL;
      currentSentimentText = "Strong Bullish";
   }
   else if(higherTFBias == -1 && mediumTFBearish) {
      currentSentiment = SENTIMENT_STRONG_BEAR;
      currentSentimentText = "Strong Bearish";
   }
   else if(higherTFBias == 1 && lowerTFBreakout) {
      currentSentiment = SENTIMENT_BULL;
      currentSentimentText = "Bullish (Risk-On)";
   }
   else if(higherTFBias == -1 && lowerTFBreakout) {
      currentSentiment = SENTIMENT_BEAR;
      currentSentimentText = "Bearish (Risk-Off)";
   }
   else {
      currentSentiment = SENTIMENT_NEUTRAL;
      currentSentimentText = "Neutral";
   }
}

//+------------------------------------------------------------------+
//| Get Higher Timeframe Bias                                         |
//+------------------------------------------------------------------+
int GetHigherTFBias() {
   double ma200Buf[1];
   if(CopyBuffer(g_ma200Handle, 0, 0, 1, ma200Buf) <= 0) {
      Print("Failed to copy MA200 buffer");
      return 0;
   }
   double ma200 = ma200Buf[0];
   
   double currentPrice = iClose(_Symbol, InpHigherTF, 0);
   
   double deviation = MathAbs(currentPrice - ma200) / ma200;
   double threshold = 0.002;  // 0.2% threshold
   
   if(currentPrice > ma200 && deviation > threshold) return 1;   // Bullish
   if(currentPrice < ma200 && deviation > threshold) return -1;  // Bearish
   return 0;  // Neutral
}

//+------------------------------------------------------------------+
//| Check if structure is bullish                                     |
//+------------------------------------------------------------------+
bool IsStructureBullish(ENUM_TIMEFRAMES tf) {
   int lookback = InpSwingLookback;
   
   // Find recent swing high and low
   int swingHighIdx = iHighest(_Symbol, tf, MODE_HIGH, lookback * 2, 1);
   int swingLowIdx = iLowest(_Symbol, tf, MODE_LOW, lookback * 2, 1);
   
   if(swingHighIdx == -1 || swingLowIdx == -1) return false;
   
   double recentHigh = iHigh(_Symbol, tf, swingHighIdx);
   double recentLow = iLow(_Symbol, tf, swingLowIdx);
   
   // Check for higher highs and higher lows
   double prevHigh = iHigh(_Symbol, tf, swingHighIdx + lookback);
   double prevLow = iLow(_Symbol, tf, swingLowIdx + lookback);
   
   return (recentHigh > prevHigh && recentLow > prevLow);
}

//+------------------------------------------------------------------+
//| Check if structure is bearish                                     |
//+------------------------------------------------------------------+
bool IsStructureBearish(ENUM_TIMEFRAMES tf) {
   int lookback = InpSwingLookback;
   
   // Find recent swing high and low
   int swingHighIdx = iHighest(_Symbol, tf, MODE_HIGH, lookback * 2, 1);
   int swingLowIdx = iLowest(_Symbol, tf, MODE_LOW, lookback * 2, 1);
   
   if(swingHighIdx == -1 || swingLowIdx == -1) return false;
   
   double recentHigh = iHigh(_Symbol, tf, swingHighIdx);
   double recentLow = iLow(_Symbol, tf, swingLowIdx);
   
   // Check for lower highs and lower lows
   double prevHigh = iHigh(_Symbol, tf, swingHighIdx + lookback);
   double prevLow = iLow(_Symbol, tf, swingLowIdx + lookback);
   
   return (recentHigh < prevHigh && recentLow < prevLow);
}

//+------------------------------------------------------------------+
//| Check for breakout                                                |
//+------------------------------------------------------------------+
bool HasBreakout(ENUM_TIMEFRAMES tf, int higherTFBias) {
   int lookback = InpSwingLookback;
   
   int swingHighIdx = iHighest(_Symbol, tf, MODE_HIGH, lookback, 1);
   int swingLowIdx = iLowest(_Symbol, tf, MODE_LOW, lookback, 1);
   
   if(swingHighIdx == -1 || swingLowIdx == -1) return false;
   
   double swingHigh = iHigh(_Symbol, tf, swingHighIdx);
   double swingLow = iLow(_Symbol, tf, swingLowIdx);
   double currentPrice = iClose(_Symbol, tf, 0);
   
   // Breakout in direction of higher timeframe bias
   if(higherTFBias == 1) return (currentPrice > swingHigh);   // Bullish breakout
   if(higherTFBias == -1) return (currentPrice < swingLow);   // Bearish breakout
   
   return false;
}

//+------------------------------------------------------------------+
//| CHECK IF STRATEGY IS ALLOWED                                      |
//+------------------------------------------------------------------+
bool IsStrategyAllowed(ENUM_STRATEGY_TYPE strategy) {
   switch(strategy) {
      case STRATEGY_BOS:           return InpUseBOS;
      case STRATEGY_CHOCH:         return InpUseCHoCH;
      case STRATEGY_FVG:           return InpUseFVG;
      case STRATEGY_IFVG:          return InpUseIFVG;
      case STRATEGY_OB:            return InpUseOrderBlocks;
      case STRATEGY_LIQ_SWEEP:     return InpUseLiqSweep;
      case STRATEGY_OPENING_RANGE: return InpUseOpeningRange;
      case STRATEGY_MIDNIGHT_RANGE: return InpUseMidnightRange;
      default: return false;
   }
}

//+------------------------------------------------------------------+
//| EXECUTE STRATEGIES                                                |
//+------------------------------------------------------------------+
void ExecuteStrategies() {
   if(activeTrades >= InpMaxTrades) return;
   
   double currentClose = iClose(_Symbol, PERIOD_CURRENT, 0);
   double currentOpen = iOpen(_Symbol, PERIOD_CURRENT, 0);
   
   // === BOS STRATEGY ===
   if(InpUseBOS && bosDetected) {
      bosDetected = false;  // Reset flag
      
      if(currentTrend == "BULLISH" && IsSentimentAligned(true)) {
         ExecuteTrade(ORDER_TYPE_BUY, "BOS_Bullish", currentClose);
      }
      else if(currentTrend == "BEARISH" && IsSentimentAligned(false)) {
         ExecuteTrade(ORDER_TYPE_SELL, "BOS_Bearish", currentClose);
      }
   }
   
   // === CHoCH STRATEGY ===
   if(InpUseCHoCH && chochDetected) {
      chochDetected = false;  // Reset flag
      
      if(currentTrend == "BULLISH" && IsSentimentAligned(true)) {
         ExecuteTrade(ORDER_TYPE_BUY, "CHoCH_Bullish", currentClose);
      }
      else if(currentTrend == "BEARISH" && IsSentimentAligned(false)) {
         ExecuteTrade(ORDER_TYPE_SELL, "CHoCH_Bearish", currentClose);
      }
   }
   
   // === FVG STRATEGY ===
   if(InpUseFVG) {
      // Check bullish FVGs for entry
      for(int i = ArraySize(bullishFVGs) - 1; i >= 0; i--) {
         if(bullishFVGs[i].state == 0) {  // Normal state
            double entryLevel = bullishFVGs[i].low + 
                               (bullishFVGs[i].high - bullishFVGs[i].low) * InpFVGEntryPercent / 100;
            
            if(currentClose <= entryLevel && IsSentimentAligned(true)) {
               ExecuteTrade(ORDER_TYPE_BUY, "FVG_Bullish", currentClose);
               break;
            }
         }
      }
      
      // Check bearish FVGs for entry
      for(int i = ArraySize(bearishFVGs) - 1; i >= 0; i--) {
         if(bearishFVGs[i].state == 0) {  // Normal state
            double entryLevel = bearishFVGs[i].high - 
                               (bearishFVGs[i].high - bearishFVGs[i].low) * InpFVGEntryPercent / 100;
            
            if(currentClose >= entryLevel && IsSentimentAligned(false)) {
               ExecuteTrade(ORDER_TYPE_SELL, "FVG_Bearish", currentClose);
               break;
            }
         }
      }
   }
   
   // === IFVG STRATEGY ===
   if(InpUseIFVG) {
      // Check for inverted bullish FVGs (bearish IFVG)
      for(int i = ArraySize(bullishFVGs) - 1; i >= 0; i--) {
         if(bullishFVGs[i].state == 3 && bullishFVGs[i].inverted) {
            if(IsSentimentAligned(false)) {
               ExecuteTrade(ORDER_TYPE_SELL, "IFVG_Bearish", currentClose);
               bullishFVGs[i].inverted = false;  // Reset to avoid duplicate trades
               break;
            }
         }
      }
      
      // Check for inverted bearish FVGs (bullish IFVG)
      for(int i = ArraySize(bearishFVGs) - 1; i >= 0; i--) {
         if(bearishFVGs[i].state == 3 && bearishFVGs[i].inverted) {
            if(IsSentimentAligned(true)) {
               ExecuteTrade(ORDER_TYPE_BUY, "IFVG_Bullish", currentClose);
               bearishFVGs[i].inverted = false;  // Reset to avoid duplicate trades
               break;
            }
         }
      }
   }
   
   // === ORDER BLOCK STRATEGY ===
   if(InpUseOrderBlocks) {
      // Check bullish OBs for entry
      for(int i = ArraySize(bullishOBs) - 1; i >= 0; i--) {
         if(!bullishOBs[i].mitigated) {
            double entryLevel = bullishOBs[i].low + 
                               (bullishOBs[i].high - bullishOBs[i].low) * InpOBEntryPercent / 100;
            
            if(currentClose <= entryLevel && IsSentimentAligned(true)) {
               ExecuteTrade(ORDER_TYPE_BUY, "OB_Bullish", currentClose);
               break;
            }
         }
      }
      
      // Check bearish OBs for entry
      for(int i = ArraySize(bearishOBs) - 1; i >= 0; i--) {
         if(!bearishOBs[i].mitigated) {
            double entryLevel = bearishOBs[i].high - 
                               (bearishOBs[i].high - bearishOBs[i].low) * InpOBEntryPercent / 100;
            
            if(currentClose >= entryLevel && IsSentimentAligned(false)) {
               ExecuteTrade(ORDER_TYPE_SELL, "OB_Bearish", currentClose);
               break;
            }
         }
      }
   }
   
   // === LIQUIDITY SWEEP STRATEGY ===
   if(InpUseLiqSweep) {
      // Check for recent SSL sweeps (bullish entry)
      for(int i = ArraySize(sellSideLiq) - 1; i >= 0; i--) {
         if(sellSideLiq[i].swept && 
            currentBarIndex - sellSideLiq[i].barIndex <= 3) {
            if(currentClose > sellSideLiq[i].price && IsSentimentAligned(true)) {
               ExecuteTrade(ORDER_TYPE_BUY, "LiqSweep_SSL", currentClose);
               sellSideLiq[i].swept = false;  // Reset
               break;
            }
         }
      }
      
      // Check for recent BSL sweeps (bearish entry)
      for(int i = ArraySize(buySideLiq) - 1; i >= 0; i--) {
         if(buySideLiq[i].swept && 
            currentBarIndex - buySideLiq[i].barIndex <= 3) {
            if(currentClose < buySideLiq[i].price && IsSentimentAligned(false)) {
               ExecuteTrade(ORDER_TYPE_SELL, "LiqSweep_BSL", currentClose);
               buySideLiq[i].swept = false;  // Reset
               break;
            }
         }
      }
   }
   
   // === OPENING RANGE BREAKOUT STRATEGY ===
   if(InpUseOpeningRange && !currentSession.broken && IsRangeValid(currentSession)) {
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      
      // Only trade after opening range ends
      if(dt.hour >= InpOpeningRangeEnd) {
         double rangeSize = currentSession.high - currentSession.low;
         double minBreakSize = rangeSize * InpSessionBreakConf;
         
         // Bullish breakout
         if(currentClose > currentSession.high + minBreakSize && IsSentimentAligned(true)) {
            ExecuteTrade(ORDER_TYPE_BUY, "OpeningRange_Bull", currentClose);
            currentSession.broken = true;
            SaveState();
         }
         // Bearish breakout
         else if(currentClose < currentSession.low - minBreakSize && IsSentimentAligned(false)) {
            ExecuteTrade(ORDER_TYPE_SELL, "OpeningRange_Bear", currentClose);
            currentSession.broken = true;
            SaveState();
         }
      }
   }
   
   // === MIDNIGHT RANGE BREAKOUT STRATEGY ===
   if(InpUseMidnightRange && !midnightSession.broken && IsRangeValid(midnightSession)) {
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      
      // Only trade after midnight range ends
      if(dt.hour >= InpMidnightEnd) {
         double rangeSize = midnightSession.high - midnightSession.low;
         double minBreakSize = rangeSize * InpSessionBreakConf;
         
         // Bullish breakout
         if(currentClose > midnightSession.high + minBreakSize && IsSentimentAligned(true)) {
            ExecuteTrade(ORDER_TYPE_BUY, "MidnightRange_Bull", currentClose);
            midnightSession.broken = true;
            SaveState();
         }
         // Bearish breakout
         else if(currentClose < midnightSession.low - minBreakSize && IsSentimentAligned(false)) {
            ExecuteTrade(ORDER_TYPE_SELL, "MidnightRange_Bear", currentClose);
            midnightSession.broken = true;
            SaveState();
         }
      }
   }
}

//+------------------------------------------------------------------+
//| CHECK IF SENTIMENT IS ALIGNED                                     |
//+------------------------------------------------------------------+
bool IsSentimentAligned(bool isBullish) {
   if(!InpUseSentiment) return true;  // No sentiment filter
   
   if(isBullish) {
      return (currentSentiment == SENTIMENT_STRONG_BULL || 
              currentSentiment == SENTIMENT_BULL ||
              currentSentiment == SENTIMENT_NEUTRAL);
   } else {
      return (currentSentiment == SENTIMENT_STRONG_BEAR || 
              currentSentiment == SENTIMENT_BEAR ||
              currentSentiment == SENTIMENT_NEUTRAL);
   }
}

//+------------------------------------------------------------------+
//| EXECUTE TRADE                                                     |
//+------------------------------------------------------------------+
void ExecuteTrade(ENUM_ORDER_TYPE type, string strategy, double price) {
   if(activeTrades >= InpMaxTrades) return;
   
   // Calculate SL and TP
   double sl, tp;
   double point = _Point;
   
   if(type == ORDER_TYPE_BUY) {
      sl = price - InpStopLoss * point;
      tp = price + InpTakeProfit * point;
   } else {
      sl = price + InpStopLoss * point;
      tp = price - InpTakeProfit * point;
   }
   
   // Normalize prices
   sl = NormalizeDouble(sl, _Digits);
   tp = NormalizeDouble(tp, _Digits);
   price = NormalizeDouble(price, _Digits);
   
   // Build comment
   string comment = StringFormat("SMC_%s_Sent:%s", strategy, currentSentimentText);
   
   // Execute trade
   bool result = trade.PositionOpen(_Symbol, type, InpLotSize, price, sl, tp, comment);
   
   if(result) {
      ulong ticket = trade.ResultOrder();
      Print("Trade executed: ", EnumToString(type), 
            " | Strategy: ", strategy,
            " | Sentiment: ", currentSentimentText,
            " | Price: ", DoubleToString(price, _Digits),
            " | SL: ", DoubleToString(sl, _Digits),
            " | TP: ", DoubleToString(tp, _Digits),
            " | Ticket: ", ticket);
      
      lastTradeTime = TimeCurrent();
      lastStrategy = strategy;
      activeTrades++;
   } else {
      Print("Trade failed: ", trade.ResultRetcode(), " - ", trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
//| DRAW MARKET STRUCTURE                                             |
//+------------------------------------------------------------------+
void DrawMarketStructure() {
   // Draw swing highs
   for(int i = 0; i < ArraySize(swingHighs); i++) {
      string name = "STRUCTURE_SH_" + IntegerToString(i);
      ObjectCreate(0, name, OBJ_TEXT, 0, swingHighs[i].time, swingHighs[i].price);
      ObjectSetString(0, name, OBJPROP_TEXT, swingHighs[i].label);
      ObjectSetInteger(0, name, OBJPROP_COLOR, swingHighs[i].label == "HH" ? InpBullColor : InpBearColor);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   }
   
   // Draw swing lows
   for(int i = 0; i < ArraySize(swingLows); i++) {
      string name = "STRUCTURE_SL_" + IntegerToString(i);
      ObjectCreate(0, name, OBJ_TEXT, 0, swingLows[i].time, swingLows[i].price);
      ObjectSetString(0, name, OBJPROP_TEXT, swingLows[i].label);
      ObjectSetInteger(0, name, OBJPROP_COLOR, swingLows[i].label == "HL" ? InpBullColor : InpBearColor);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   }
}

//+------------------------------------------------------------------+
//| DRAW FAIR VALUE GAPS                                              |
//+------------------------------------------------------------------+
void DrawFairValueGaps() {
   // Draw bullish FVGs
   for(int i = 0; i < ArraySize(bullishFVGs); i++) {
      string name = "FVG_Bull_" + IntegerToString(i);
      datetime endTime = bullishFVGs[i].time + PeriodSeconds(PERIOD_CURRENT) * 10;
      
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, 
                   bullishFVGs[i].time, bullishFVGs[i].high,
                   endTime, bullishFVGs[i].low);
      ObjectSetInteger(0, name, OBJPROP_COLOR, InpFVGColor);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
   }
   
   // Draw bearish FVGs
   for(int i = 0; i < ArraySize(bearishFVGs); i++) {
      string name = "FVG_Bear_" + IntegerToString(i);
      datetime endTime = bearishFVGs[i].time + PeriodSeconds(PERIOD_CURRENT) * 10;
      
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, 
                   bearishFVGs[i].time, bearishFVGs[i].high,
                   endTime, bearishFVGs[i].low);
      ObjectSetInteger(0, name, OBJPROP_COLOR, InpBearColor);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
   }
}

//+------------------------------------------------------------------+
//| DRAW ORDER BLOCKS                                                 |
//+------------------------------------------------------------------+
void DrawOrderBlocks() {
   // Draw bullish OBs
   for(int i = 0; i < ArraySize(bullishOBs); i++) {
      string name = "OB_Bull_" + IntegerToString(i);
      datetime endTime = bullishOBs[i].time + PeriodSeconds(PERIOD_CURRENT) * 20;
      
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, 
                   bullishOBs[i].time, bullishOBs[i].high,
                   endTime, bullishOBs[i].low);
      ObjectSetInteger(0, name, OBJPROP_COLOR, InpOBColor);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
   }
   
   // Draw bearish OBs
   for(int i = 0; i < ArraySize(bearishOBs); i++) {
      string name = "OB_Bear_" + IntegerToString(i);
      datetime endTime = bearishOBs[i].time + PeriodSeconds(PERIOD_CURRENT) * 20;
      
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, 
                   bearishOBs[i].time, bearishOBs[i].high,
                   endTime, bearishOBs[i].low);
      ObjectSetInteger(0, name, OBJPROP_COLOR, InpBearColor);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
   }
}

//+------------------------------------------------------------------+
//| DRAW LIQUIDITY LEVELS                                             |
//+------------------------------------------------------------------+
void DrawLiquidityLevels() {
   // Draw Buy Side Liquidity
   for(int i = 0; i < ArraySize(buySideLiq); i++) {
      string name = "LIQ_BSL_" + IntegerToString(i);
      
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, buySideLiq[i].price);
      ObjectSetInteger(0, name, OBJPROP_COLOR, InpLiqColor);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      
      if(buySideLiq[i].swept) {
         ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrGray);
      }
   }
   
   // Draw Sell Side Liquidity
   for(int i = 0; i < ArraySize(sellSideLiq); i++) {
      string name = "LIQ_SSL_" + IntegerToString(i);
      
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, sellSideLiq[i].price);
      ObjectSetInteger(0, name, OBJPROP_COLOR, InpLiqColor);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      
      if(sellSideLiq[i].swept) {
         ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrGray);
      }
   }
}

//+------------------------------------------------------------------+
//| DRAW SESSION RANGES                                               |
//+------------------------------------------------------------------+
void DrawSessionRanges() {
   // Draw Opening Range
   if(currentSession.high > 0 && currentSession.low < 999999) {
      string name = "SESSION_Opening";
      datetime endTime = currentSession.endTime + PeriodSeconds(PERIOD_CURRENT) * 5;
      
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, 
                   currentSession.startTime, currentSession.high,
                   endTime, currentSession.low);
      ObjectSetInteger(0, name, OBJPROP_COLOR, InpSessionColor);
      ObjectSetInteger(0, name, OBJPROP_FILL, false);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
   }
   
   // Draw Midnight Range
   if(midnightSession.high > 0 && midnightSession.low < 999999) {
      string name = "SESSION_Midnight";
      datetime endTime = midnightSession.endTime + PeriodSeconds(PERIOD_CURRENT) * 5;
      
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, 
                   midnightSession.startTime, midnightSession.high,
                   endTime, midnightSession.low);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrMidnightBlue);
      ObjectSetInteger(0, name, OBJPROP_FILL, false);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
   }
}

//+------------------------------------------------------------------+
//| DISPLAY STATUS                                                    |
//+------------------------------------------------------------------+
void DisplayStatus() {
   string status = "";
   status += "=== SMART MONEY CONCEPTS EA ===\n";
   status += "═══════════════════════════════\n";
   status += "Market Trend: " + currentTrend + "\n";
   status += "Sentiment: " + currentSentimentText + "\n";
   status += "Active Trades: " + IntegerToString(activeTrades) + "/" + IntegerToString(InpMaxTrades) + "\n";
   status += "═══════════════════════════════\n";
   status += "STRUCTURE:\n";
   status += "  Swing Highs: " + IntegerToString(ArraySize(swingHighs)) + "\n";
   status += "  Swing Lows: " + IntegerToString(ArraySize(swingLows)) + "\n";
   status += "═══════════════════════════════\n";
   status += "ZONES:\n";
   status += "  Bullish FVGs: " + IntegerToString(ArraySize(bullishFVGs)) + "\n";
   status += "  Bearish FVGs: " + IntegerToString(ArraySize(bearishFVGs)) + "\n";
   status += "  Bullish OBs: " + IntegerToString(ArraySize(bullishOBs)) + "\n";
   status += "  Bearish OBs: " + IntegerToString(ArraySize(bearishOBs)) + "\n";
   status += "═══════════════════════════════\n";
   status += "LIQUIDITY:\n";
   status += "  BSL Levels: " + IntegerToString(ArraySize(buySideLiq)) + "\n";
   status += "  SSL Levels: " + IntegerToString(ArraySize(sellSideLiq)) + "\n";
   status += "═══════════════════════════════\n";
   status += "SESSIONS:\n";
   if(IsRangeValid(currentSession))
      status += "  Opening Range: " + DoubleToString(currentSession.low, _Digits) +
                " - " + DoubleToString(currentSession.high, _Digits) + "\n";
   else
      status += "  Opening Range: N/A (waiting for session)\n";
   if(IsRangeValid(midnightSession))
      status += "  Midnight Range: " + DoubleToString(midnightSession.low, _Digits) +
                " - " + DoubleToString(midnightSession.high, _Digits) + "\n";
   else
      status += "  Midnight Range: N/A (waiting for session)\n";
   status += "═══════════════════════════════\n";
   status += "Last Strategy: " + lastStrategy + "\n";
   
   Comment(status);
}
//+------------------------------------------------------------------+
