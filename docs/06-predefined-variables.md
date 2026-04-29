# MQL5 Predefined Variables and Constants

> Source: https://www.mql5.com/en/docs/predefined

For each executable mql5-program a set of predefined variables is supported, which reflect the state of the current price chart by the moment a mql5-program (Expert Advisor, script or custom indicator) is started.

Values of predefined variables are set by the client terminal before a mql5-program is started. Predefined variables are constant and cannot be changed from a mql5-program. As exception, there is a special variable _LastError, which can be reset to 0 by the ResetLastError function.

Variable

## Predefined Variables

### _Symbol (Current Symbol)
```mql5
string sym = _Symbol;  // Returns the symbol name of the current chart
```

### _Period (Current Timeframe)
```mql5
ENUM_TIMEFRAMES tf = _Period;  // Returns the period of the current chart
```

### _Digits (Price Digits)
```mql5
int digits = _Digits;  // Number of decimal places for the symbol price
```

### _Point (Point Size)
```mql5
double point = _Point;  // The minimum price change of the symbol
```

### _LastError (Last Error Code)
```mql5
uint error = _LastError;  // The last error code
```

### _RandomSeed (Random Seed)
```mql5
uint seed = _RandomSeed;  // Current random generator seed value
```

### _StopFlag (Stop Flag)
```mql5
bool stopped = _StopFlag;  // Flag indicating program should stop
```

### _UninitReason (Deinit Reason)
```mql5
int reason = _UninitReason;  // Reason for deinitialization
```

### _MQLSetInteger / _MQLGetInteger
Used to set/get MQL5 program properties.

---

## Predefined Chart Variables

### Bars
```mql5
int bars = Bars(_Symbol, _Period);  // Number of bars on chart
```

### Series Arrays (Accessible via functions)
```mql5
// Get close prices
double close[];
CopyClose(_Symbol, _Period, 0, 100, close);

// Get open prices
double open[];
CopyOpen(_Symbol, _Period, 0, 100, open);

// Get high prices
double high[];
CopyHigh(_Symbol, _Period, 0, 100, high);

// Get low prices
double low[];
CopyLow(_Symbol, _Period, 0, 100, low);

// Get time
datetime time[];
CopyTime(_Symbol, _Period, 0, 100, time);

// Get tick volume
long tick_vol[];
CopyTickVolume(_Symbol, _Period, 0, 100, tick_vol);

// Get real volume
long vol[];
CopyRealVolume(_Symbol, _Period, 0, 100, vol);
```

### iClose, iOpen, iHigh, iLow
```mql5
// Get specific bar values
double close_1 = iClose(_Symbol, _Period, 1);   // Close of previous bar
double open_0 = iOpen(_Symbol, _Period, 0);     // Open of current bar
double high_1 = iHigh(_Symbol, _Period, 1);     // High of previous bar
double low_1 = iLow(_Symbol, _Period, 1);       // Low of previous bar
datetime time_1 = iTime(_Symbol, _Period, 1);   // Time of previous bar
long vol_1 = iTickVolume(_Symbol, _Period, 1);  // Tick volume of previous bar
```

---

## Time Variables

```mql5
datetime current_time = TimeCurrent();        // Current server time
datetime local_time = TimeLocal();            // Current local time
datetime gmt_time = TimeGMT();                // Current GMT time
int gmt_offset = TimeGMTOffset();            // GMT offset in seconds
int dst = TimeDaylightSavings();              // DST adjustment

// Convert datetime to components
MqlDateTime dt;
TimeToStruct(current_time, dt);
Print(dt.year, ".", dt.mon, ".", dt.day, " ", dt.hour, ":", dt.min, ":", dt.sec);
Print("Day of week: ", dt.day_of_week);
Print("Day of year: ", dt.day_of_year);
```

---

## Account Variables

```mql5
// Account info functions
double balance = AccountInfoDouble(ACCOUNT_BALANCE);
double equity = AccountInfoDouble(ACCOUNT_EQUITY);
double margin = AccountInfoDouble(ACCOUNT_MARGIN);
double free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
double profit = AccountInfoDouble(ACCOUNT_PROFIT);
long leverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
long login = AccountInfoInteger(ACCOUNT_LOGIN);
string name = AccountInfoString(ACCOUNT_NAME);
string currency = AccountInfoString(ACCOUNT_CURRENCY);
ENUM_ACCOUNT_TRADE_MODE mode = (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
```

---

## Market Info Functions

```mql5
// Symbol properties
double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
double point_val = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
int digits_val = SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
double tick_val = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
double contract = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
double vol_min = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
double vol_max = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
double vol_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
double swap_long = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_LONG);
double swap_short = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_SHORT);
long stops_level = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
long freeze_level = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
```

---

## Trade Environment Variables

```mql5
// Terminal info
bool connected = TerminalInfoInteger(TERMINAL_CONNECTED);
bool trade_allowed = TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
bool dll_allowed = TerminalInfoInteger(TERMINAL_DLLS_ALLOWED);
bool trade_ping = TerminalInfoInteger(TERMINAL_PING_LAST);
string terminal_name = TerminalInfoString(TERMINAL_NAME);
string terminal_path = TerminalInfoString(TERMINAL_PATH);
string data_path = TerminalInfoString(TERMINAL_DATA_PATH);
int build = TerminalInfoInteger(TERMINAL_BUILD);
int cpus = TerminalInfoInteger(TERMINAL_CPU_CORES);
int memory = TerminalInfoInteger(TERMINAL_MEMORY_PHYSICAL);
int disk = TerminalInfoInteger(TERMINAL_DISK_SPACE);
```

---

## MQL5 Program Properties

```mql5
// MQL5 info
bool is_live = MQLInfoInteger(MQL_TRADE_ALLOWED);
bool is_testing = MQLInfoInteger(MQL_TESTER);
bool is_optimization = MQLInfoInteger(MQL_OPTIMIZATION);
bool is_visual = MQLInfoInteger(MQL_VISUAL_MODE);
bool is_frame = MQLInfoInteger(MQL_FRAME_MODE);
string prog_name = MQLInfoString(MQL_PROGRAM_NAME);
string prog_path = MQLInfoString(MQL_PROGRAM_PATH);
string data_dir = MQLInfoString(MQL_DATA_PATH);
string common_dir = MQLInfoString(MQL_COMMONDATA_PATH);
```
