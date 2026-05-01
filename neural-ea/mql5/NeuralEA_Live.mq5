//+------------------------------------------------------------------+
//| NeuralEA_Live.mq5                                                 |
//| Expert Advisor communicating with Python server via TCP sockets   |
//| Connects to localhost:5555, sends OHLC+indicators, receives       |
//| predictions (lstm_trend, catboost_prob, price_direction, signal)  |
//+------------------------------------------------------------------+
#property copyright "Neural Trading System"
#property version   "1.00"
#property strict

//--- Input parameters
input string   InpServerHost     = "127.0.0.1";    // Server host
input int      InpServerPort     = 5555;            // Server port
input int      InpTimeout        = 5000;            // Socket timeout (ms)
input int      InpBarsCount      = 120;             // Number of bars to send
input double   InpLotSize        = 0.01;            // Lot size
input int      InpMaxPositions   = 3;               // Max open positions
input double   InpStopLoss       = 500;             // Stop Loss (points)
input double   InpTakeProfit     = 1000;            // Take Profit (points)
input double   InpTrendThreshold = 0.6;             // Min trend strength to trade
input double   InpProbThreshold  = 0.55;            // Min win probability to trade
input double   InpDirThreshold   = 0.55;            // Min price direction to trade
input int      InpMagicNumber    = 202501;          // Magic number
input int      InpTimerInterval  = 1000;            // Timer interval (ms)
input bool     InpEnableTrailing = true;            // Enable trailing stop
input int      InpTrailStart     = 300;             // Trailing start (points)
input int      InpTrailStep      = 100;             // Trailing step (points)

//--- Indicator handles
int handleADX, handleRSI, handleMACD, handlePSAR, handleATR;
int handleSMA50, handleSMA200, handleBB, handleMFI, handleCCI;
int handleStoch, handleWPR, handleOBV, handleAD;

//--- Socket
int socketHandle = INVALID_HANDLE;
bool isConnected = false;
datetime lastConnectAttempt = 0;

//--- State
datetime lastBarTime = 0;
string lastSignal = "HOLD";

//+------------------------------------------------------------------+
//| Expert initialization                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED))
   {
      Print("ERROR: DLL imports not allowed. Enable in Tools -> Options -> Expert Advisors");
      return INIT_FAILED;
   }

   //--- Create indicator handles
   handleADX   = iADX(_Symbol, PERIOD_CURRENT, 14);
   handleRSI   = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
   handleMACD  = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
   handlePSAR  = iSAR(_Symbol, PERIOD_CURRENT, 0.02, 0.2);
   handleATR   = iATR(_Symbol, PERIOD_CURRENT, 14);
   handleSMA50 = iMA(_Symbol, PERIOD_CURRENT, 50, 0, MODE_SMA, PRICE_CLOSE);
   handleSMA200= iMA(_Symbol, PERIOD_CURRENT, 200, 0, MODE_SMA, PRICE_CLOSE);
   handleBB    = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
   handleMFI   = iMFI(_Symbol, PERIOD_CURRENT, 14, VOLUME_TICK);
   handleCCI   = iCCI(_Symbol, PERIOD_CURRENT, 14, PRICE_TYPICAL);
   handleStoch = iStochastic(_Symbol, PERIOD_CURRENT, 14, 3, 3, MODE_SMA, STO_LOWHIGH);
   handleWPR   = iWPR(_Symbol, PERIOD_CURRENT, 14);
   handleOBV   = iOBV(_Symbol, PERIOD_CURRENT, VOLUME_TICK);
   handleAD    = iAD(_Symbol, PERIOD_CURRENT, VOLUME_TICK);

   //--- Validate handles
   if(handleADX==INVALID_HANDLE || handleRSI==INVALID_HANDLE || handleMACD==INVALID_HANDLE ||
      handlePSAR==INVALID_HANDLE || handleATR==INVALID_HANDLE || handleSMA50==INVALID_HANDLE ||
      handleSMA200==INVALID_HANDLE || handleBB==INVALID_HANDLE || handleMFI==INVALID_HANDLE ||
      handleCCI==INVALID_HANDLE || handleStoch==INVALID_HANDLE || handleWPR==INVALID_HANDLE ||
      handleOBV==INVALID_HANDLE || handleAD==INVALID_HANDLE)
   {
      Print("ERROR: Failed to create indicator handles");
      return INIT_FAILED;
   }

   //--- Start timer
   EventSetMillisecondTimer(InpTimerInterval);

   //--- Initial connection
   ConnectToServer();

   Print("NeuralEA_Live initialized. Symbol=", _Symbol, " Period=", EnumToString(Period()));
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   DisconnectFromServer();

   //--- Release indicator handles
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
//| Timer function - main loop                                        |
//+------------------------------------------------------------------+
void OnTimer()
{
   //--- Manage connection
   if(!SocketIsConnected(socketHandle))
   {
      isConnected = false;
      if(TimeCurrent() - lastConnectAttempt > 5) // Retry every 5 seconds
         ConnectToServer();
      if(!isConnected) return;
   }

   //--- Manage trailing stop
   if(InpEnableTrailing)
      ManageTrailingStop();

   //--- Only process on new bar
   datetime barTime = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(barTime == lastBarTime) return;
   lastBarTime = barTime;

   //--- Collect market data and send to server
   string jsonData = CollectMarketData();
   if(jsonData == "") return;

   string response = SendAndReceive(jsonData);
   if(response == "") return;

   //--- Parse response and trade
   ProcessResponse(response);
}

//+------------------------------------------------------------------+
//| Connect to Python server                                          |
//+------------------------------------------------------------------+
void ConnectToServer()
{
   lastConnectAttempt = TimeCurrent();

   if(socketHandle != INVALID_HANDLE)
      SocketClose(socketHandle);

   socketHandle = SocketCreate();
   if(socketHandle == INVALID_HANDLE)
   {
      Print("ERROR: SocketCreate failed, error=", GetLastError());
      return;
   }

   if(!SocketConnect(socketHandle, InpServerHost, InpServerPort, InpTimeout))
   {
      Print("WARN: Connection to ", InpServerHost, ":", InpServerPort, " failed, error=", GetLastError());
      SocketClose(socketHandle);
      socketHandle = INVALID_HANDLE;
      isConnected = false;
      return;
   }

   isConnected = true;
   Print("Connected to Python server at ", InpServerHost, ":", InpServerPort);
}

//+------------------------------------------------------------------+
//| Disconnect from server                                            |
//+------------------------------------------------------------------+
void DisconnectFromServer()
{
   if(socketHandle != INVALID_HANDLE)
   {
      SocketClose(socketHandle);
      socketHandle = INVALID_HANDLE;
   }
   isConnected = false;
}

//+------------------------------------------------------------------+
//| Collect all market data into JSON string                          |
//+------------------------------------------------------------------+
string CollectMarketData()
{
   int bars = InpBarsCount;

   //--- OHLC data
   double open[], high[], low[], close[];
   long volume[];
   datetime time[];

   if(CopyOpen(_Symbol, PERIOD_CURRENT, 0, bars, open) < bars) return "";
   if(CopyHigh(_Symbol, PERIOD_CURRENT, 0, bars, high) < bars) return "";
   if(CopyLow(_Symbol, PERIOD_CURRENT, 0, bars, low) < bars) return "";
   if(CopyClose(_Symbol, PERIOD_CURRENT, 0, bars, close) < bars) return "";
   if(CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, bars, volume) < bars) return "";
   if(CopyTime(_Symbol, PERIOD_CURRENT, 0, bars, time) < bars) return "";

   //--- Indicator data
   double adx[], rsi[], macdMain[], macdSignal[], psar[], atr[];
   double sma50[], sma200[], bbUpper[], bbMiddle[], bbLower[];
   double mfi[], cci[], stochK[], stochD[], wpr[], obv[], adLine[];

   if(CopyBuffer(handleADX, 0, 0, bars, adx) < bars) return "";
   if(CopyBuffer(handleRSI, 0, 0, bars, rsi) < bars) return "";
   if(CopyBuffer(handleMACD, 0, 0, bars, macdMain) < bars) return "";
   if(CopyBuffer(handleMACD, 1, 0, bars, macdSignal) < bars) return "";
   if(CopyBuffer(handlePSAR, 0, 0, bars, psar) < bars) return "";
   if(CopyBuffer(handleATR, 0, 0, bars, atr) < bars) return "";
   if(CopyBuffer(handleSMA50, 0, 0, bars, sma50) < bars) return "";
   if(CopyBuffer(handleSMA200, 0, 0, bars, sma200) < bars) return "";
   if(CopyBuffer(handleBB, 0, 0, bars, bbMiddle) < bars) return "";
   if(CopyBuffer(handleBB, 1, 0, bars, bbUpper) < bars) return "";
   if(CopyBuffer(handleBB, 2, 0, bars, bbLower) < bars) return "";
   if(CopyBuffer(handleMFI, 0, 0, bars, mfi) < bars) return "";
   if(CopyBuffer(handleCCI, 0, 0, bars, cci) < bars) return "";
   if(CopyBuffer(handleStoch, 0, 0, bars, stochK) < bars) return "";
   if(CopyBuffer(handleStoch, 1, 0, bars, stochD) < bars) return "";
   if(CopyBuffer(handleWPR, 0, 0, bars, wpr) < bars) return "";
   if(CopyBuffer(handleOBV, 0, 0, bars, obv) < bars) return "";
   if(CopyBuffer(handleAD, 0, 0, bars, adLine) < bars) return "";

   //--- Build JSON manually (MQL5 has no native JSON)
   string json = "{";
   json += "\"symbol\":\"" + _Symbol + "\",";
   json += "\"period\":\"" + EnumToString(Period()) + "\",";
   json += "\"time\":" + IntegerToString((long)time[bars-1]) + ",";
   json += "\"bars\":" + IntegerToString(bars) + ",";

   //--- OHLC arrays
   json += "\"open\":[" + DoubleArrayToStr(open, bars) + "],";
   json += "\"high\":[" + DoubleArrayToStr(high, bars) + "],";
   json += "\"low\":[" + DoubleArrayToStr(low, bars) + "],";
   json += "\"close\":[" + DoubleArrayToStr(close, bars) + "],";
   json += "\"volume\":[" + LongArrayToStr(volume, bars) + "],";

   //--- Indicator arrays
   json += "\"adx\":[" + DoubleArrayToStr(adx, bars) + "],";
   json += "\"rsi\":[" + DoubleArrayToStr(rsi, bars) + "],";
   json += "\"macd_main\":[" + DoubleArrayToStr(macdMain, bars) + "],";
   json += "\"macd_signal\":[" + DoubleArrayToStr(macdSignal, bars) + "],";
   json += "\"psar\":[" + DoubleArrayToStr(psar, bars) + "],";
   json += "\"atr\":[" + DoubleArrayToStr(atr, bars) + "],";
   json += "\"sma50\":[" + DoubleArrayToStr(sma50, bars) + "],";
   json += "\"sma200\":[" + DoubleArrayToStr(sma200, bars) + "],";
   json += "\"bb_upper\":[" + DoubleArrayToStr(bbUpper, bars) + "],";
   json += "\"bb_middle\":[" + DoubleArrayToStr(bbMiddle, bars) + "],";
   json += "\"bb_lower\":[" + DoubleArrayToStr(bbLower, bars) + "],";
   json += "\"mfi\":[" + DoubleArrayToStr(mfi, bars) + "],";
   json += "\"cci\":[" + DoubleArrayToStr(cci, bars) + "],";
   json += "\"stoch_k\":[" + DoubleArrayToStr(stochK, bars) + "],";
   json += "\"stoch_d\":[" + DoubleArrayToStr(stochD, bars) + "],";
   json += "\"wpr\":[" + DoubleArrayToStr(wpr, bars) + "],";
   json += "\"obv\":[" + DoubleArrayToStr(obv, bars) + "],";
   json += "\"ad\":[" + DoubleArrayToStr(adLine, bars) + "]";

   //--- Current tick info
   MqlTick tick;
   if(SymbolInfoTick(_Symbol, tick))
   {
      json += ",\"bid\":" + DoubleToString(tick.bid, _Digits);
      json += ",\"ask\":" + DoubleToString(tick.ask, _Digits);
      json += ",\"spread\":" + IntegerToString(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD));
   }

   //--- Account info
   json += ",\"balance\":" + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2);
   json += ",\"equity\":" + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2);
   json += ",\"positions\":" + IntegerToString(CountPositions());

   json += "}";
   return json;
}

//+------------------------------------------------------------------+
//| Convert double array to comma-separated string                    |
//+------------------------------------------------------------------+
string DoubleArrayToStr(const double &arr[], int count)
{
   string result = "";
   for(int i = 0; i < count; i++)
   {
      if(i > 0) result += ",";
      result += DoubleToString(arr[i], 8);
   }
   return result;
}

//+------------------------------------------------------------------+
//| Convert long array to comma-separated string                      |
//+------------------------------------------------------------------+
string LongArrayToStr(const long &arr[], int count)
{
   string result = "";
   for(int i = 0; i < count; i++)
   {
      if(i > 0) result += ",";
      result += IntegerToString(arr[i]);
   }
   return result;
}

//+------------------------------------------------------------------+
//| Send JSON to server and read response                             |
//+------------------------------------------------------------------+
string SendAndReceive(const string &json)
{
   //--- Send: length-prefixed protocol (4 bytes big-endian length + JSON payload)
   uchar data[];
   StringToCharArray(json, data, 0, WHOLE_ARRAY, CP_UTF8);
   int len = ArraySize(data) - 1; // StringToCharArray adds null terminator

   //--- Build length header (big-endian 4 bytes)
   uchar header[4];
   header[0] = (uchar)((len >> 24) & 0xFF);
   header[1] = (uchar)((len >> 16) & 0xFF);
   header[2] = (uchar)((len >> 8) & 0xFF);
   header[3] = (uchar)(len & 0xFF);

   //--- Combine header + payload
   uchar sendBuf[];
   ArrayResize(sendBuf, 4 + len);
   ArrayCopy(sendBuf, header, 0, 0, 4);
   ArrayCopy(sendBuf, data, 4, 0, len);

   if(SocketSend(socketHandle, sendBuf) != 4 + len)
   {
      Print("ERROR: SocketSend failed");
      DisconnectFromServer();
      return "";
   }

   //--- Read response length (4 bytes)
   uchar lenBuf[];
   int bytesRead = SocketReadExact(socketHandle, lenBuf, 4, InpTimeout);
   if(bytesRead < 4)
   {
      Print("ERROR: Failed to read response length, bytesRead=", bytesRead);
      DisconnectFromServer();
      return "";
   }

   int respLen = ((int)lenBuf[0] << 24) | ((int)lenBuf[1] << 16) |
                 ((int)lenBuf[2] << 8) | (int)lenBuf[3];
   if(respLen <= 0 || respLen > 1048576) // Max 1MB
   {
      Print("ERROR: Invalid response length: ", respLen);
      return "";
   }

   //--- Read response payload
   uchar respBuf[];
   bytesRead = SocketReadExact(socketHandle, respBuf, respLen, InpTimeout);
   if(bytesRead < respLen)
   {
      Print("ERROR: Incomplete response, expected=", respLen, " got=", bytesRead);
      return "";
   }

   string response = CharArrayToString(respBuf, 0, bytesRead, CP_UTF8);
   return response;
}

//+------------------------------------------------------------------+
//| Read exact byte count from socket with timeout                    |
//+------------------------------------------------------------------+
int SocketReadExact(int handle, uchar &result[], int exactBytes, int timeout)
{
   ArrayResize(result, 0);
   int totalRead = 0;
   uint startTime = GetTickCount();

   while(totalRead < exactBytes)
   {
      if(GetTickCount() - startTime > (uint)timeout)
         break;

      uchar buf[];
      //--- Use MQL5 built-in SocketRead(handle, buf[], timeout_ms)
      int n = SocketRead(handle, buf, (uint)timeout);
      if(n <= 0) { Sleep(1); continue; }

      int oldSize = ArraySize(result);
      ArrayResize(result, oldSize + n);
      ArrayCopy(result, buf, oldSize, 0, n);
      totalRead += n;
   }
   return totalRead;
}

//+------------------------------------------------------------------+
//| Process server response and execute trades                        |
//+------------------------------------------------------------------+
void ProcessResponse(const string &json)
{
   //--- Parse JSON response manually
   //--- Expected format: {"lstm_trend": float, "catboost_prob": float,
   //---                    "price_direction": float, "signal": "BUY/SELL/HOLD",
   //---                    "sl": float, "tp": float}
   double lstmTrend = JsonGetDouble(json, "lstm_trend");
   double catboostProb = JsonGetDouble(json, "catboost_prob");
   double priceDir = JsonGetDouble(json, "price_direction");
   string signal = JsonGetString(json, "signal");
   double serverSL = JsonGetDouble(json, "sl");
   double serverTP = JsonGetDouble(json, "tp");

   //--- Log prediction
   Print("Prediction: signal=", signal,
         " trend=", DoubleToString(lstmTrend, 4),
         " prob=", DoubleToString(catboostProb, 4),
         " dir=", DoubleToString(priceDir, 4));

   //--- Update chart comment
   Comment("Signal: ", signal, "\n",
           "LSTM Trend: ", DoubleToString(lstmTrend, 4), "\n",
           "CatBoost Prob: ", DoubleToString(catboostProb, 4), "\n",
           "Price Direction: ", DoubleToString(priceDir, 4), "\n",
           "Positions: ", CountPositions(), "/", InpMaxPositions);

   lastSignal = signal;

   //--- Check thresholds and trade
   int positions = CountPositions();

   if(signal == "BUY" && lstmTrend > InpTrendThreshold &&
      catboostProb > InpProbThreshold && priceDir > InpDirThreshold)
   {
      ClosePositionsByType(ORDER_TYPE_SELL);

      if(positions < InpMaxPositions)
      {
         double sl = (serverSL > 0) ? serverSL : 0;
         double tp = (serverTP > 0) ? serverTP : 0;
         if(sl == 0 && InpStopLoss > 0) sl = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - InpStopLoss * _Point;
         if(tp == 0 && InpTakeProfit > 0) tp = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + InpTakeProfit * _Point;
         ExecuteOrder(ORDER_TYPE_BUY, sl, tp);
      }
   }
   else if(signal == "SELL" && lstmTrend < -InpTrendThreshold &&
           catboostProb > InpProbThreshold && priceDir < (1.0 - InpDirThreshold))
   {
      ClosePositionsByType(ORDER_TYPE_BUY);

      if(positions < InpMaxPositions)
      {
         double sl = (serverSL > 0) ? serverSL : 0;
         double tp = (serverTP > 0) ? serverTP : 0;
         if(sl == 0 && InpStopLoss > 0) sl = SymbolInfoDouble(_Symbol, SYMBOL_BID) + InpStopLoss * _Point;
         if(tp == 0 && InpTakeProfit > 0) tp = SymbolInfoDouble(_Symbol, SYMBOL_BID) - InpTakeProfit * _Point;
         ExecuteOrder(ORDER_TYPE_SELL, sl, tp);
      }
   }
   //--- HOLD: do nothing, let positions run
}

//+------------------------------------------------------------------+
//| Execute a market order                                            |
//+------------------------------------------------------------------+
bool ExecuteOrder(ENUM_ORDER_TYPE type, double sl, double tp)
{
   MqlTradeRequest request = {};
   MqlTradeResult  result  = {};

   request.action    = TRADE_ACTION_DEAL;
   request.symbol    = _Symbol;
   request.volume    = InpLotSize;
   request.type      = type;
   request.magic     = InpMagicNumber;
   request.deviation = 30;
   request.comment   = "NeuralEA_" + (type == ORDER_TYPE_BUY ? "BUY" : "SELL");

   if(type == ORDER_TYPE_BUY)
   {
      request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   }
   else
   {
      request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   }

   //--- Normalize SL/TP
   if(sl > 0) request.sl = NormalizeDouble(sl, _Digits);
   if(tp > 0) request.tp = NormalizeDouble(tp, _Digits);

   if(!OrderSend(request, result))
   {
      Print("ERROR: OrderSend failed, retcode=", result.retcode, " error=", GetLastError());
      return false;
   }

   if(result.retcode == TRADE_RETCODE_DONE || result.retcode == TRADE_RETCODE_PLACED)
   {
      Print("Order executed: ", request.comment, " price=", result.price, " ticket=", result.order);
      return true;
   }

   Print("ERROR: Order not executed, retcode=", result.retcode);
   return false;
}

//+------------------------------------------------------------------+
//| Close all positions of a given type                               |
//+------------------------------------------------------------------+
void ClosePositionsByType(ENUM_ORDER_TYPE closeType)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;

      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      bool shouldClose = false;
      if(closeType == ORDER_TYPE_BUY && posType == POSITION_TYPE_SELL) shouldClose = true;
      if(closeType == ORDER_TYPE_SELL && posType == POSITION_TYPE_BUY) shouldClose = true;

      if(shouldClose)
      {
         MqlTradeRequest request = {};
         MqlTradeResult  result  = {};
         request.action    = TRADE_ACTION_DEAL;
         request.symbol    = _Symbol;
         request.position  = ticket;
         request.volume    = PositionGetDouble(POSITION_VOLUME);
         request.deviation = 30;
         request.comment   = "NeuralEA_CLOSE";

         if(posType == POSITION_TYPE_BUY)
         {
            request.type  = ORDER_TYPE_SELL;
            request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         }
         else
         {
            request.type  = ORDER_TYPE_BUY;
            request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         }

         if(!OrderSend(request, result))
            Print("ERROR: Close order failed for ticket=", ticket, " retcode=", result.retcode);
         else
            Print("Closed position ticket=", ticket);
      }
   }
}

//+------------------------------------------------------------------+
//| Count open positions for this EA                                  |
//+------------------------------------------------------------------+
int CountPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      count++;
   }
   return count;
}

//+------------------------------------------------------------------+
//| Manage trailing stop on open positions                            |
//+------------------------------------------------------------------+
void ManageTrailingStop()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;

      double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double posSL    = PositionGetDouble(POSITION_SL);
      double posTP    = PositionGetDouble(POSITION_TP);
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      if(posType == POSITION_TYPE_BUY)
      {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double trailTrigger = posPrice + InpTrailStart * _Point;
         double newSL = bid - InpTrailStep * _Point;
         newSL = NormalizeDouble(newSL, _Digits);

         if(bid >= trailTrigger && (posSL < newSL || posSL == 0))
         {
            ModifyPosition(ticket, newSL, posTP);
         }
      }
      else if(posType == POSITION_TYPE_SELL)
      {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double trailTrigger = posPrice - InpTrailStart * _Point;
         double newSL = ask + InpTrailStep * _Point;
         newSL = NormalizeDouble(newSL, _Digits);

         if(ask <= trailTrigger && (posSL > newSL || posSL == 0))
         {
            ModifyPosition(ticket, newSL, posTP);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Modify position SL/TP                                             |
//+------------------------------------------------------------------+
bool ModifyPosition(ulong ticket, double sl, double tp)
{
   MqlTradeRequest request = {};
   MqlTradeResult  result  = {};

   request.action   = TRADE_ACTION_SLTP;
   request.position = ticket;
   request.symbol   = _Symbol;
   request.sl       = NormalizeDouble(sl, _Digits);
   request.tp       = NormalizeDouble(tp, _Digits);

   if(!OrderSend(request, result))
   {
      Print("ERROR: ModifyPosition failed, ticket=", ticket, " retcode=", result.retcode);
      return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Simple JSON parser - extract double value by key                  |
//+------------------------------------------------------------------+
double JsonGetDouble(const string &json, const string &key)
{
   string search = "\"" + key + "\":";
   int pos = StringFind(json, search);
   if(pos < 0) return 0.0;
   pos += StringLen(search);

   //--- Skip whitespace
   while(pos < StringLen(json) && StringGetCharacter(json, pos) == ' ') pos++;

   //--- Extract number
   string numStr = "";
   while(pos < StringLen(json))
   {
      ushort ch = StringGetCharacter(json, pos);
      if((ch >= '0' && ch <= '9') || ch == '.' || ch == '-' || ch == '+' || ch == 'e' || ch == 'E')
      {
         numStr += CharToString((uchar)ch);
         pos++;
      }
      else break;
   }
   return StringToDouble(numStr);
}

//+------------------------------------------------------------------+
//| Simple JSON parser - extract string value by key                  |
//+------------------------------------------------------------------+
string JsonGetString(const string &json, const string &key)
{
   string search = "\"" + key + "\":\"";
   int pos = StringFind(json, search);
   if(pos < 0) return "";
   pos += StringLen(search);

   string result = "";
   while(pos < StringLen(json))
   {
      ushort ch = StringGetCharacter(json, pos);
      if(ch == '"') break;
      result += CharToString((uchar)ch);
      pos++;
   }
   return result;
}

//+------------------------------------------------------------------+
//| Tick function (unused - using OnTimer instead)                    |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- All logic handled in OnTimer for consistent 1s interval
}
//+------------------------------------------------------------------+
