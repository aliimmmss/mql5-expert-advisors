# MQL5 Standard Library

> Source: https://www.mql5.com/en/docs/standardlibrary

This group of chapters contains the technical details of the MQL5 Standard Library and descriptions of all its key components.

MQL5 Standard Library is written in MQL5 and is designed to facilitate writing programs (indicators, scripts, experts) for end users. Library provides convenient access to the most of the internal MQL5 functions.

MQL5 Standard Library is placed in the working directory of the terminal in the 'Include' folder.

Section

Location

## Library Structure

- **Mathematics** (`/en/docs/standardlibrary/mathematics`)
- **OpenCL** (`/en/docs/standardlibrary/copencl`)
- **Basic Class CObject** (`/en/docs/standardlibrary/cobject`)
- **Data Collections** (`/en/docs/standardlibrary/datastructures`)
- **Generic Data Collections** (`/en/docs/standardlibrary/generic`)
- **Files** (`/en/docs/standardlibrary/fileoperations`)
- **Strings** (`/en/docs/standardlibrary/stringoperations`)
- **Graphic Objects** (`/en/docs/standardlibrary/chart_object_classes`)
- **Custom Graphics** (`/en/docs/standardlibrary/canvasgraphics`)
- **3D Graphics** (`/en/docs/standardlibrary/3dgraphics`)
- **Price Charts** (`/en/docs/standardlibrary/cchart`)
- **Scientific Charts** (`/en/docs/standardlibrary/graphics`)
- **Indicators** (`/en/docs/standardlibrary/technicalindicators`)
- **Trade Classes** (`/en/docs/standardlibrary/tradeclasses`)
- **Strategy Modules** (`/en/docs/standardlibrary/expertclasses`)
- **Panels and Dialogs** (`/en/docs/standardlibrary/controls`)


---

## Trade Classes (CExpert)

### CTrade Class
```mql5
#include <Trade\Trade.mqh>

CTrade trade;

// Configuration
trade.SetExpertMagicNumber(12345);
trade.SetDeviationInPoints(10);
trade.SetTypeFilling(ORDER_FILLING_FOK);
trade.SetMarginMode();

// Order execution
trade.Buy(0.1);                      // Buy at market
trade.Sell(0.1);                     // Sell at market
trade.Buy(0.1, _Symbol, 1.1000);     // Buy at specific price
trade.Sell(0.1, _Symbol, 1.1050);    // Sell at specific price

// Pending orders
trade.BuyStop(0.1, 1.1100);          // Buy Stop
trade.SellStop(0.1, 1.0900);         // Sell Stop
trade.BuyLimit(0.1, 1.0950);         // Buy Limit
trade.SellLimit(0.1, 1.1050);        // Sell Limit

// Position management
trade.PositionModify(ticket, sl, tp);
trade.PositionClose(ticket);
trade.PositionClosePartial(ticket, volume);

// Order management
trade.OrderDelete(ticket);

// Results
uint retcode = trade.ResultRetcode();
ulong order = trade.ResultOrder();
ulong deal = trade.ResultDeal();
```

### CPositionInfo Class
```mql5
#include <Trade\PositionInfo.mqh>

CPositionInfo pos_info;

// Select position
if(pos_info.Select(_Symbol))
{
    ulong ticket = pos_info.Ticket();
    long type = pos_info.PositionType();
    double volume = pos_info.Volume();
    double price = pos_info.PriceOpen();
    double profit = pos_info.Profit();
    double sl = pos_info.StopLoss();
    double tp = pos_info.TakeProfit();
    long magic = pos_info.Magic();
    string comment = pos_info.Comment();
    
    // Check if profitable
    if(pos_info.Profit() > 0)
        Print("Position is profitable");
}
```

### COrderInfo Class
```mql5
#include <Trade\OrderInfo.mqh>

COrderInfo order_info;

// Iterate pending orders
for(int i = OrdersTotal() - 1; i >= 0; i--)
{
    if(order_info.SelectByIndex(i))
    {
        ulong ticket = order_info.Ticket();
        string symbol = order_info.Symbol();
        long type = order_info.OrderType();
        double volume = order_info.VolumeCurrent();
        double price = order_info.PriceOpen();
        long magic = order_info.Magic();
    }
}
```

### CHistoryOrderInfo Class
```mql5
#include <Trade\HistoryOrderInfo.mqh>

CHistoryOrderInfo hist_order;

// Select history
HistorySelect(0, TimeCurrent());
for(int i = HistoryOrdersTotal() - 1; i >= 0; i--)
{
    if(hist_order.SelectByIndex(i))
    {
        ulong ticket = hist_order.Ticket();
        long state = hist_order.State();
        double volume = hist_order.VolumeCurrent();
        datetime time = hist_order.TimeSetup();
    }
}
```

### CDealInfo Class
```mql5
#include <Trade\DealInfo.mqh>

CDealInfo deal_info;

HistorySelect(0, TimeCurrent());
for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
{
    if(deal_info.SelectByIndex(i))
    {
        ulong ticket = deal_info.Ticket();
        long entry = deal_info.Entry();
        double profit = deal_info.Profit();
        double commission = deal_info.Commission();
        double swap = deal_info.Swap();
        string symbol = deal_info.Symbol();
        
        if(entry == DEAL_ENTRY_IN)
            Print("Entry deal: ", ticket);
        else if(entry == DEAL_ENTRY_OUT)
            Print("Exit deal: ", ticket, " Profit: ", profit);
    }
}
```

### CSymbolInfo Class
```mql5
#include <Trade\SymbolInfo.mqh>

CSymbolInfo sym_info;

sym_info.Name(_Symbol);
sym_info.Refresh();

double bid = sym_info.Bid();
double ask = sym_info.Ask();
double spread = sym_info.Spread();
double point = sym_info.Point();
int digits = sym_info.Digits();
double tick_value = sym_info.TickValue();
double tick_size = sym_info.TickSize();
double contract_size = sym_info.ContractSize();
double volume_min = sym_info.LotsMin();
double volume_max = sym_info.LotsMax();
double volume_step = sym_info.LotsStep();
```

### CAccountInfo Class
```mql5
#include <Trade\AccountInfo.mqh>

CAccountInfo acc_info;

long login = acc_info.Login();
string name = acc_info.Name();
string server = acc_info.Server();
string currency = acc_info.Currency();
double balance = acc_info.Balance();
double equity = acc_info.Equity();
double margin = acc_info.Margin();
double free_margin = acc_info.FreeMargin();
double margin_level = acc_info.MarginLevel();
double profit = acc_info.Profit();
long leverage = acc_info.Leverage();
long account_type = acc_info.AccountStopoutMode();
ENUM_ACCOUNT_TRADE_MODE trade_mode = acc_info.TradeMode();
```

---

## Expert Advisor Framework (CExpert)

### Using CExpert Base Class

```mql5
#include <Expert\Expert.mqh>

class MyExpert : public CExpert
{
protected:
    virtual bool InitIndicators();
    virtual bool CheckOpenLong();
    virtual bool CheckOpenShort();
    virtual bool CheckCloseLong();
    virtual bool CheckCloseShort();
};

bool MyExpert::InitIndicators()
{
    // Initialize your indicators here
    return true;
}

bool MyExpert::CheckOpenLong()
{
    // Return true to open a buy position
    return false;
}

bool MyExpert::CheckOpenShort()
{
    // Return true to open a sell position
    return false;
}

bool MyExpert::CheckCloseLong()
{
    // Return true to close buy position
    return false;
}

bool MyExpert::CheckCloseShort()
{
    // Return true to close sell position
    return false;
}
```

### Signal Modules (CExpertSignal)

```mql5
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalRSI.mqh>
#include <Expert\Signal\SignalMACD.mqh>
#include <Expert\Signal\SignalAC.mqh>
#include <Expert\Signal\SignalAO.mqh>
#include <Expert\Signal\SignalAlligator.mqh>
#include <Expert\Signal\SignalBollinger.mqh>
#include <Expert\Signal\SignalSAR.mqh>
#include <Expert\Signal\SignalStochastic.mqh>
```

### Money Management Modules (CExpertMoney)

```mql5
#include <Expert\Money\MoneyFixedLot.mqh>
#include <Expert\Money\MoneyFixedRisk.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
#include <Expert\Money\MoneySizeOptimal.mqh>
#include <Expert\Money\MoneyFixedBalance.mqh>
```

### Trailing Stop Modules (CExpertTrailing)

```mql5
#include <Expert\Trailing\TrailingNone.mqh>
#include <Expert\Trailing\TrailingFixedPips.mqh`
#include <Expert\Trailing\TrailingFractalChaos.mqh`
#include <Expert\Trailing\TrailingMA.mqh`
#include <Expert\Trailing\TrailingParabolicSAR.mqh`
#include <Expert\Trailing\TrailingFractal.mqh`
```

---

## File Operations (CFile, CFileTxt, etc.)

```mql5
#include <Files\FileTxt.mqh>
#include <Files\FileBin.mqh>
#include <Files\FileCsv.mqh>

// Writing to text file
CFileTxt file;
if(file.Open("data.txt", FILE_WRITE|FILE_TXT) != INVALID_HANDLE)
{
    file.WriteString("Hello MQL5\n");
    file.Close();
}

// Reading from file
if(file.Open("data.txt", FILE_READ|FILE_TXT) != INVALID_HANDLE)
{
    string content = file.ReadString(100);
    file.Close();
}
```

---

## Arrays and Collections (CArrayObj, CHashMap)

```mql5
#include <Arrays\ArrayObj.mqh>
#include <Arrays\List.mqh>
#include <Generic\HashMap.mqh>

// Dynamic array of objects
CArrayObj *list = new CArrayObj();
list.Add(new CObject());
list.Sort();
list.Clear();
delete list;

// HashMap
CHashMap<string, double> map;
map.Add("key1", 1.0);
map.Add("key2", 2.0);

double value;
if(map.TryGetValue("key1", value))
    Print("Value: ", value);
```

---

## Indicators Library (CiMA, CiRSI, etc.)

```mql5
#include <Indicators\Trend.mqh>
#include <Indicators\Oscilators.mqh>
#include <Indicators\BillsWilliams.mqh>
#include <Indicators\Volumes.mqh>

// Using indicator classes
CiMA ma;
CiRSI rsi;
CiMACD macd;
CiBollinger bands;

int OnInit()
{
    ma.Create(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
    rsi.Create(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
    macd.Create(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
    bands.Create(_Symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
    return(INIT_SUCCEEDED);
}

void OnTick()
{
    double ma_val = ma.Main(0);
    double rsi_val = rsi.Main(0);
    double macd_main = macd.Main(0);
    double macd_signal = macd.Signal(0);
    double bb_upper = bands.Upper(0);
    double bb_lower = bands.Lower(0);
}
```

---

## Chart Objects (CChartObject*)

```mql5
#include <ChartObjects\ChartObjectsLines.mqh>
#include <ChartObjects\ChartObjectsShapes.mqh>
#include <ChartObjects\ChartObjectsArrows.mqh>
#include <ChartObjects\ChartObjectsText.mqh>

// Create horizontal line
CChartObjectHLine hline;
hline.Create(0, "MyLine", 0, 1.1000);
hline.Color(clrRed);
hline.Width(2);
hline.Style(STYLE_DASH);

// Create text label
CChartObjectLabel label;
label.Create(0, "MyLabel", 0, 100, 50);
label.Description("Buy Signal");
label.Color(clrGreen);
label.FontSize(12);
```

---

## Calendar Functions (CCalendar)

```mql5
#include <Calendar\Calendar.mqh>

// Get economic calendar events
MqlCalendarValue values[];
CalendarValueHistory(values, D'2024.01.01', D'2024.12.31');

for(int i = 0; i < ArraySize(values); i++)
{
    Print("Event: ", values[i].event_id);
    Print("Time: ", TimeToString(values[i].time));
    Print("Actual: ", values[i].GetActualValue());
    Print("Forecast: ", values[i].GetForecastValue());
}
```

---

## Database Access (CDatabase)

```mql5
#include <Database\Database.mqh>

CDatabase db;
if(db.Open("test.db"))
{
    // Execute SQL
    db.Execute("CREATE TABLE IF NOT EXISTS trades (id INTEGER PRIMARY KEY, symbol TEXT, profit REAL)");
    db.Execute("INSERT INTO trades VALUES (1, 'EURUSD', 100.5)");
    
    // Query
    CDatabaseQuery *query = db.Query("SELECT * FROM trades");
    while(query.Next())
    {
        int id = query.GetInt(0);
        string symbol = query.GetString(1);
        double profit = query.GetDouble(2);
    }
    delete query;
    db.Close();
}
```

---

## Error Handling (CError)

```mql5
#include <errordescription.mqh>

// Get error description
uint error = GetLastError();
string desc = ErrorDescription(error);
Print("Error ", error, ": ", desc);
```
