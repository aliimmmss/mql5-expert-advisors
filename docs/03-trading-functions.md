# MQL5 Trade Functions

> Source: https://www.mql5.com/en/docs/trading

This is the group of functions intended for managing trading activities.

General information about trading operations is available in the client terminal help.

Trading functions can be used in Expert Advisors and scripts. Trading functions can be called only if in the properties of the Expert Advisor or script the "Allow live trading" checkbox is enabled.

Trading can be allowed or prohibited depending on various factors described in the Trade Permission section.

## Function Reference

### Order Management

- `OrderCalcMargin()` - /en/docs/trading/ordercalcmargin
- `OrderCalcProfit()` - /en/docs/trading/ordercalcprofit
- `OrderCheck()` - /en/docs/trading/ordercheck
- `OrderSend()` - /en/docs/trading/ordersend
- `OrderSendAsync()` - /en/docs/trading/ordersendasync
- `OrdersTotal()` - /en/docs/trading/orderstotal
- `OrderGetTicket()` - /en/docs/trading/ordergetticket
- `OrderSelect()` - /en/docs/trading/orderselect
- `OrderGetDouble()` - /en/docs/trading/ordergetdouble
- `OrderGetInteger()` - /en/docs/trading/ordergetinteger
- `OrderGetString()` - /en/docs/trading/ordergetstring

### Position Management

- `PositionsTotal()` - /en/docs/trading/positionstotal
- `PositionGetSymbol()` - /en/docs/trading/positiongetsymbol
- `PositionSelect()` - /en/docs/trading/positionselect
- `PositionSelectByTicket()` - /en/docs/trading/positionselectbyticket
- `PositionGetDouble()` - /en/docs/trading/positiongetdouble
- `PositionGetInteger()` - /en/docs/trading/positiongetinteger
- `PositionGetString()` - /en/docs/trading/positiongetstring
- `PositionGetTicket()` - /en/docs/trading/positiongetticket
- `HistorySelectByPosition()` - /en/docs/trading/historyselectbyposition

### History (Orders)

- `HistorySelect()` - /en/docs/trading/historyselect
- `HistorySelectByPosition()` - /en/docs/trading/historyselectbyposition
- `HistoryOrderSelect()` - /en/docs/trading/historyorderselect
- `HistoryOrdersTotal()` - /en/docs/trading/historyorderstotal
- `HistoryOrderGetTicket()` - /en/docs/trading/historyordergetticket
- `HistoryOrderGetDouble()` - /en/docs/trading/historyordergetdouble
- `HistoryOrderGetInteger()` - /en/docs/trading/historyordergetinteger
- `HistoryOrderGetString()` - /en/docs/trading/historyordergetstring

### History (Deals)

- `HistoryDealSelect()` - /en/docs/trading/historydealselect
- `HistoryDealsTotal()` - /en/docs/trading/historydealstotal
- `HistoryDealGetTicket()` - /en/docs/trading/historydealgetticket
- `HistoryDealGetDouble()` - /en/docs/trading/historydealgetdouble
- `HistoryDealGetInteger()` - /en/docs/trading/historydealgetinteger
- `HistoryDealGetString()` - /en/docs/trading/historydealgetstring

---

## OrderSend

The OrderSend() function is used for executing trade operations by sending requests to a trade server.

Parameters

request

[in]  Pointer to a structure of MqlTradeRequest type describing the trade activity of the client.

result

[in,out]  Pointer to a structure of MqlTradeResult type describing the result of trade operation in case of a successful completion (if true is returned).

Return Value

In case of a successful basic check of structures (index checking) returns true. However, this is not a sign of successful execution of a trade operation. For a more detailed description of the function execution result, analyze the fields of result structure.

Note

The trade requests go through several stages of checking on a trade server. First of all, it checks if all the required fields of the request parameter are filled out correctly. If there are no errors, the server accepts the order for further processing. If the order is successfully accepted by the trade server, the OrderSend() function returns true.

---

## OrderCheck

The OrderCheck() function checks if there are enough money to execute a required trade operation. The check results are placed to the fields of the MqlTradeCheckResult structure.

Parameters

request

[in]  Pointer to the structure of the MqlTradeRequest type, which describes the required trade action.

result

[in,out]  Pointer to the structure of the MqlTradeCheckResult type, to which the check result will be placed.

Return Value

If funds are not enough for the operation, or parameters are filled out incorrectly, the function returns false. In case of a successful basic check of structures (check of pointers), it returns true. However, this is not an indication that the requested trade operation is sure to be successfully executed. For a more detailed description of the function execution result, analyze the fields of the result structure.

In order to obtain information about the error, call the GetLastError() function.

Example:

---

## PositionsTotal

---

## PositionGetTicket

The function returns the ticket of a position with the specified index in the list of open positions and automatically selects the position to work with using functions PositionGetDouble, PositionGetInteger, PositionGetString.

Parameters

index

[in]  The index of a position in the list of open positions, numeration starts with 0.

Return Value

The ticket of the position. Returns 0 if the function fails.

Note

For the "netting" interpretation of positions (ACCOUNT_MARGIN_MODE_RETAIL_NETTING and ACCOUNT_MARGIN_MODE_EXCHANGE), only one position can exist for a symbol at any moment of time. This position is a result of one or more deals. Do not confuse positions with valid pending orders, which are also displayed on the Trading tab of the Toolbox window.

If individual positions are allowed (ACCOUNT_MARGIN_MODE_RETAIL_HEDGING), multiple positions can be open for one symbol.

To ensure receipt of fresh data about a position, it is recommended to call PositionSelect() right before referring to them.

---

## OrderCalcMargin

The function calculates the margin required for the specified order type, on the current account, in the current market environment not taking into account current pending orders and open positions. It allows the evaluation of margin for the trade operation planned. The value is returned in the account currency.

Parameters

action

[in]  The order type, can be one of the values of the ENUM_ORDER_TYPE enumeration.

symbol

[in]  Symbol name.

volume

[in]  Volume of the trade operation.

price

[in]  Open price.

---

## OrderCalcProfit

The function calculates the profit for the current account, in the current market conditions, based on the parameters passed. The function is used for pre-evaluation of the result of a trade operation. The value is returned in the account currency.

Parameters

action

[in]  Type of the order, can be one of the two values of the ENUM_ORDER_TYPE enumeration: ORDER_TYPE_BUY or ORDER_TYPE_SELL.

symbol

[in]  Symbol name.

volume

[in]  Volume of the trade operation.

price_open

[in]  Open price.

---


## Complete Trading Examples

### Opening a Buy Order (Market Order)

```mql5
#include <Trade\Trade.mqh>

CTrade trade;

void OnTick()
{
    if(!PositionSelect(_Symbol))
    {
        // No open position, open a buy
        double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        double sl = ask - 100 * _Point;  // 100 points stop loss
        double tp = ask + 200 * _Point;  // 200 points take profit
        
        trade.Buy(0.1, _Symbol, ask, sl, tp, "Buy Order");
    }
}
```

### Using CTrade Class (Recommended)

```mql5
#include <Trade\Trade.mqh>

CTrade trade;
int ma_handle;

int OnInit()
{
    trade.SetExpertMagicNumber(12345);
    ma_handle = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
    return(INIT_SUCCEEDED);
}

void OnTick()
{
    double ma[];
    CopyBuffer(ma_handle, 0, 0, 2, ma);
    
    double close = iClose(_Symbol, PERIOD_CURRENT, 1);
    
    // Buy when price crosses above MA
    if(close > ma[1] && !PositionSelect(_Symbol))
    {
        trade.Buy(0.1);
    }
    // Sell when price crosses below MA
    else if(close < ma[1] && !PositionSelect(_Symbol))
    {
        trade.Sell(0.1);
    }
}
```

### Checking Trade Conditions Before Order

```mql5
#include <Trade\Trade.mqh>

CTrade trade;

bool CanTrade()
{
    if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
        return false;
    if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        return false;
    if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
        return false;
    if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
        return false;
    return true;
}

void OnTick()
{
    if(!CanTrade()) return;
    
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = 0.1;
    request.type = ORDER_TYPE_BUY;
    request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    request.deviation = 10;
    request.magic = 12345;
    request.comment = "Test order";
    
    if(!OrderCheck(request, result))
    {
        Print("Order check failed: ", result.retcode);
        return;
    }
    
    if(!OrderSend(request, result))
    {
        Print("OrderSend failed: ", result.retcode);
    }
    else
    {
        Print("Order sent successfully. Ticket: ", result.order);
    }
}
```

### Getting Position Information

```mql5
void OnTick()
{
    // Check if there's an open position
    if(PositionSelect(_Symbol))
    {
        ulong ticket = PositionGetTicket(0);
        long type = PositionGetInteger(POSITION_TYPE);
        double volume = PositionGetDouble(POSITION_VOLUME);
        double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
        double current_price = PositionGetDouble(POSITION_PRICE_CURRENT);
        double profit = PositionGetDouble(POSITION_PROFIT);
        double sl = PositionGetDouble(POSITION_SL);
        double tp = PositionGetDouble(POSITION_TP);
        string symbol = PositionGetString(POSITION_SYMBOL);
        long magic = PositionGetInteger(POSITION_MAGIC);
        
        Print("Position #", ticket);
        Print("  Type: ", (type == POSITION_TYPE_BUY ? "BUY" : "SELL"));
        Print("  Volume: ", volume);
        Print("  Open Price: ", open_price);
        Print("  Current Price: ", current_price);
        Print("  Profit: ", profit);
        Print("  SL: ", sl, " TP: ", tp);
    }
}
```

### Modifying Stop Loss and Take Profit

```mql5
#include <Trade\Trade.mqh>

CTrade trade;

void ModifyPosition()
{
    if(PositionSelect(_Symbol))
    {
        ulong ticket = PositionGetInteger(POSITION_TICKET);
        double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
        
        // Move SL to breakeven
        double new_sl = open_price;
        double current_tp = PositionGetDouble(POSITION_TP);
        
        trade.PositionModify(ticket, new_sl, current_tp);
    }
}
```

### Working with Pending Orders

```mql5
#include <Trade\Trade.mqh>

CTrade trade;

void PlaceBuyStop()
{
    double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + 100 * _Point;
    double sl = price - 100 * _Point;
    double tp = price + 200 * _Point;
    
    trade.BuyStop(0.1, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, "Buy Stop");
}

void PlaceSellLimit()
{
    double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + 200 * _Point;
    double sl = price + 100 * _Point;
    double tp = price - 300 * _Point;
    
    trade.SellLimit(0.1, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, "Sell Limit");
}
```

## MqlTradeRequest Structure

```mql5
struct MqlTradeRequest
{
    ENUM_TRADE_REQUEST_ACTIONS action;  // Trade operation type
    ulong magic;           // Expert Advisor ID
    ulong order;           // Order ticket
    string symbol;         // Trade symbol
    double volume;         // Requested volume
    double price;          // Price
    double stoplimit;      // StopLimit level
    double sl;             // Stop Loss
    double tp;             // Take Profit
    ulong deviation;       // Maximum price deviation
    ENUM_ORDER_TYPE type;  // Order type
    ENUM_ORDER_TYPE_FILLING type_filling;  // Order execution type
    ENUM_ORDER_TYPE_TIME type_time;  // Order expiration type
    datetime expiration;   // Order expiration time
    string comment;        // Order comment
    ulong position;        // Position ticket
    ulong position_by;     // Opposite position ticket
};
```

## MqlTradeResult Structure

```mql5
struct MqlTradeResult
{
    uint retcode;          // Operation return code
    ulong deal;            // Deal ticket
    ulong order;           // Order ticket
    double volume;         // Volume confirmed by broker
    double price;          // Confirmed price
    double bid;            // Current Bid
    double ask;            // Current Ask
    string comment;        // Broker comment
    uint request_id;       // Request ID
    uint retcode_external; // Return code of external system
};
```

## CTrade Class Methods (Standard Library)

```mql5
#include <Trade\Trade.mqh>

CTrade trade;

// Set magic number
trade.SetExpertMagicNumber(12345);

// Set deviation
trade.SetDeviationInPoints(10);

// Set type filling
trade.SetTypeFilling(ORDER_FILLING_FOK);

// Market orders
trade.Buy(double volume, string symbol=NULL, double price=0, 
           double sl=0, double tp=0, string comment="");
trade.Sell(double volume, string symbol=NULL, double price=0,
            double sl=0, double tp=0, string comment="");

// Pending orders
trade.BuyStop(volume, price, symbol, sl, tp, type_time, expiration, comment);
trade.SellStop(volume, price, symbol, sl, tp, type_time, expiration, comment);
trade.BuyLimit(volume, price, symbol, sl, tp, type_time, expiration, comment);
trade.SellLimit(volume, price, symbol, sl, tp, type_time, expiration, comment);

// Modify position
trade.PositionModify(ticket, sl, tp);
trade.PositionClose(ticket);

// Delete pending order
trade.OrderDelete(ticket);

// Get result
trade.ResultRetcode();
trade.ResultOrder();
trade.ResultDeal();
```

## Order Types

- `ORDER_TYPE_BUY` - Market buy order
- `ORDER_TYPE_SELL` - Market sell order
- `ORDER_TYPE_BUY_STOP` - Buy Stop pending order
- `ORDER_TYPE_SELL_STOP` - Sell Stop pending order
- `ORDER_TYPE_BUY_LIMIT` - Buy Limit pending order
- `ORDER_TYPE_SELL_LIMIT` - Sell Limit pending order
- `ORDER_TYPE_BUY_STOP_LIMIT` - Buy Stop Limit
- `ORDER_TYPE_SELL_STOP_LIMIT` - Sell Stop Limit

## Order Filling Types

- `ORDER_FILLING_FOK` - Fill Or Kill
- `ORDER_FILLING_IOC` - Immediate Or Cancel
- `ORDER_FILLING_RETURN` - Return order in queue

## Trade Return Codes

- `TRADE_RETCODE_DONE` (0) - Request completed
- `TRADE_RETCODE_PLACED` (10008) - Order placed
- `TRADE_RETCODE_DONE_PARTIAL` (10009) - Partially completed
- `TRADE_RETCODE_REQUOTE` (10004) - Requote
- `TRADE_RETCODE_REJECT` (10006) - Request rejected
- `TRADE_RETCODE_CANCEL` (10007` - Request canceled
- `TRADE_RETCODE_INVALID` (10013) - Invalid request
- `TRADE_RETCODE_INVALID_VOLUME` (10014) - Invalid volume
- `TRADE_RETCODE_INVALID_PRICE` (10015) - Invalid price
- `TRADE_RETCODE_INVALID_STOPS` (10016) - Invalid stops
- `TRADE_RETCODE_TRADE_DISABLED` (10024) - Trade disabled
- `TRADE_RETCODE_MARKET_CLOSED` (10018) - Market closed
- `TRADE_RETCODE_NO_MONEY` (10019) - Not enough money
- `TRADE_RETCODE_PRICE_CHANGED` (10020) - Price changed
- `TRADE_RETCODE_PRICE_OFF` (10021) - No prices
- `TRADE_RETCODE_INVALID_EXPIRATION` (10022) - Invalid expiration
- `TRADE_RETCODE_ORDER_CHANGED` (10023) - Order state changed
- `TRADE_RETCODE_TOO_MANY_REQUESTS` (10026) - Too many requests
