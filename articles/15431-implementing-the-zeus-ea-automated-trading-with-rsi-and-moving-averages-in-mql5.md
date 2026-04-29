# Implementing the Zeus EA: Automated Trading with RSI and Moving Averages in MQL5

**Source:** [https://www.mql5.com/en/articles/15431](https://www.mql5.com/en/articles/15431)

---

Implementing the Zeus EA: Automated Trading with RSI and Moving Averages in MQL5
MetaTrader 5
—
Trading
| 8 August 2024, 15:03
2 661
5
Duke Matwere Kingoina
Introduction
In this article, we will look at the essential components of the Zeus Expert Adviser (EA) including its trading logic, parameter settings and the MQL5 code necessary, for its implementation. This article aims to equip you with the knowledge and tools required to develop and enhance your trading algorithm. By utilizing the Zeus EA you will be able to explore the world of automated trading and be able to discover new opportunities for your trading endeavors.
We will examine the functionality of Zeus EA, an automated trading technique built using MQL5. Our discussion will focus on how Zeus EA incorporates Moving Averages and the Relative Strength Index (RSI) to make trading choices. Through analyzing these indicators, the EA determines the best entry and exit points in the market to maximize trading profitability while minimizing risk.
The Zeus EA is an automated trading system designed for the MetaTrader5 platform that generates buy and sell signals based on moving averages and the relative strength index (RSI). By identifying market trends and detecting overbought or oversold conditions, it seeks to enhance trading decisions. Moreover, it includes risk management tools such as, stop loss, take profit orders, and trailing stops.
Zeus EA overview
Zeus Expert Advisor (EA) relies on indicators such as the Relative Strength Index (RSI) and the Moving Averages to automate trading decisions. The objective of this EA is to improve trading performance and effectively manage risk by using these indicators to produce actionable buy and sell recommendations.
The following are the key elements of the Zeus EA:
Technical measures:
Relative Strength Index (RSI): This momentum oscillator gauges how quickly and how prices move, this helps to determine when the market is overbought or oversold and to respond swiftly to market movements. In our case, the EA will employ a brief 7-day RSI timeframe, with thresholds set at 35 for overbought and 15 for oversold circumstances.
Moving Averages (MA): To find trends over a certain period, the Moving Average levels out the price data. We will use a 25-period Simple Moving Average (SMA) in the Zeus EA to filter trading signals and ascertain the general direction of the market.
2.
Trading Logic:
Buy Signal: When the price is above the Moving Average and the RSI it shows an oversold condition (below 15), indicating a possible upward price movement, and a buy order is placed.
Sell Signal: If the price is below the Moving Average and the RSI it indicates an overbought condition (over 35), suggesting a possible downward trend and a sell order is placed.
3.
Risk Management:
Stop Loss and Take Profit: In our EA we include customizable parameters for the stop loss levels and take profit set to 50 points each, to help manage risk and lock in profits.
Trailing Stop: We use a trailing stop of 25 points to adjust stop loss levels as the price moves favorably, aiming to secure profits while allowing the trade to remain open as long as the market moves in the desired direction.
4. Order Management:
Position Management: The EA ensures that only one position is open at a time by closing any existing positions before opening a new one, based on the trading signals.
The Zeus EA has functions for initialization, tick processing, position opening and closing, and trailing stop adjustments. It is implemented in MQL5, the scripting language used in MetaTrader5. The programming makes sure that risk management guidelines are followed and trading signals are handled effectively.
The Zeus helps to automate trading procedures, reduce emotional decision-making, and also improve trading results by using these features. This article will offer a basis for comprehending design ideas and functionality of the Zeus EA.
Implementation in MQL5
First, we need to open trading positions. We open the trading positions through the inclusion of a file that is dedicated to open positions.
#include
<Trade\Trade.mqh>
CTrade trade;
Here we use the include file to include the trade library. This will enable the Zeus EA to get access to functions for trading operations. At this point, we also define the CTrade class which offers a high level for carrying out trade activities. The EA may use the CTrade class to manage trades because this file is included. Throughout the EA, this object will be used to carry out a various trading tasks, including opening, changing and closing positions.
We look at the crucial input parameters of the Zeus EA in this section. Zeus EA is a complex trading algorithm that uses the Moving Average and RSI indicators to find trade chances. By adjusting these parameters, traders may make the EA behave in a way that best suits their unique trading tactics and risk tolerance.
The input parameters are as below:
input
double
Lots =
0.1
;
// Lot size
input
double
StopLoss =
50
;
// Stop loss in points
input
double
TakeProfit =
50
;
// Take profit in points
input
double
TrailingStop =
25
;
// Trailing stop in points
Lots( Trade Volume)
input
double
Lots =
0.1
;
// Lot size
The size of each trade is specified by the Lots option. The EA is configured to trade 0.1 lots in each transaction in this instance. Traders can manage their exposure to market risk by varying the lot size. A smaller lot size lowers both possible risks and profits while a larger lot size not only raises possible profit but also increases risks. To balance risks and gains, choosing the right lot is essential.
2. StopLoss(Stop Loss in Points)
input
double
StopLoss =
50
;
// Stop loss in points
The maximum permissible loss per trade is defined by the StopLoss option and in our case it is set at 50 points. To stop future losses, the position will automatically shut if the market goes against the transaction beyond this point. This will protect your trading account against large losses.
3. TakeProfit( Take Profit in Points)
input
double
TakeProfit =
50
;
// Take profit in points
We set our profit target for every transaction at 50 points via the TakeProfit parameter. To secure profits, the position will automatically shut when the market shifts by this much in favor of the trade. This will secure the gains ahead of any potential reversal in market conditions therefore, it will enhance profitability.
4. TrailingStop (Points where Trailing Stops)
input
double
TrailingStop =
25
;
// Trailing stop in points
We introduce a stop loss by the TrailingStop parameter, which shifts in the trade's favor. When the market swings in the trade's favor the trailing stop which is initially set at 25 points from the entry price, adjusts to lock in profits. This function will help traders profit from prolonged market fluctuations while safeguarding their gains.
The RSI indicator parameters:
input
int
RSI_Period =
7
;
// RSI period
input
double
RSI_Overbought =
35.0
;
// RSI overbought level
input
double
RSI_Oversold =
15.0
;
// RSI oversold level
5.RSI_Period(RSI Calculation Period)
input
int
RSI_Period =
7
;
// RSI period
The number of periods utilized to generate the Relative Strength Index (RSI) is specified by the RSI_ period parameter, in our case it is set to 7. A momentum oscillator that gauges the velocities and variations in price movements is the RSI. The RSI is more responsive to recent price movements over a short period, such as 7, which is helpful for swiftly identifying overbought or oversold situations.
6. RSI_Overbought(RSI Overbought Level)
input
double
RSI_Overbought =
35.0
;
The threshold for determining the overbought condition is defined by the RSI_Overbought parameter, which is set at 35.0. Generally, an overbought level might be 70, but using this technique, 35.0 denotes a more aggressive selling position. The EA triggers a sell action when the RSI is above this threshold, indicating that a downward market reversal may be imminent.
7. RSI_Oversold(RSI Oversold Levels)
input
double
RSI_Oversold =
15.0
;
// RSI oversold level
The oversold condition threshold is defined by the RSI_Oversold parameter, which has a value of 15.0. Although this approach employs a more conservative level to indicate possible buying opportunities, a typical oversold level might be thirty. The EA  triggers a buy action when the RSI falls below this threshold because it perceives a possible upside market reversal.
Moving average parameters
input
int
MA_Period =
25
;
// Moving Average period
input
ENUM_MA_METHOD
MA_Method =
MODE_SMA
;
// Moving Average method
input
ENUM_APPLIED_PRICE
MA_Price =
PRICE_CLOSE
;
// Applied price for MA
8. MA_Period(Moving Average Period)
input
int
MA_Period =
25
;
// Moving Average period
The Moving Average (MA) calculation period is determined by the MA_Period parameter, which has a value of 25. Price data is smoothened by the MA to spot trends. A 25-period window will offer a well-rounded perspective on market trends, it will not only remove short-term noise but also respond to noteworthy price changes.
9. MA_Method(Moving Average Method)
Moving Average period
input
ENUM_MA_METHOD
MA_Method =
MODE_SMA
;
// Moving Average method
The type of Moving Average that is used in this case, the Simple Moving Average (SMA) is determined by the MA_Method option. The SMA is a simple trend indicator that computes the average of closing prices over a given period. For varying sensitivities, alternative techniques like the Exponential Moving Average (EMA) could be employed, but the simple moving average (SMA) is a dependable and steady trend indicator.
10. MA_Price(Price Applied to MA)
input
ENUM_APPLIED_PRICE
MA_Price =
PRICE_CLOSE
;
// Applied price for MA
The price type utilized for the Moving Average computation is specified by the MA_Price option, which is set to price PRICE_CLOSE. This indicates that the MA is determined using closing prices, which are frequently employed since they represent the closing price of a trading session. By making this decision, the MA is guaranteed to offer a trustworthy indication of the general market trend.
The Zeus EA's trading behavior and risk management are largely determined by its input parameters. Traders can adjust the EA to better suit their unique trading objectives and current market conditions by adjusting these parameters, which include trade volume, risk controls, indicator durations, and thresholds. To fully utilize the Zeus EA in automatic trading, it is essential to comprehend and modify these settings appropriately.
We then discuss our EA new variables based on the Moving Average and RSI indicators. By gaining an understanding of these factors we will be able to know how the EA handles trade execution and analyses market data.
//--- Variables
double
rsiValue;
// RSI value
double
maValue;
// Moving Average value
double
Ask;
double
Bid;
double
Close;
// Initializing Close array with two elements
The RSI value:
double
rsiValue;
// RSI value
The Relative Strength Index's (RSI) current value is stored in the rsiValue variable. As a momentum oscillator, the RSI helps to determine when the market is overbought or oversold by calculating the rate and variation of price changes.
The price type and designated RSI period are used to determine the RSI value. The user-defined parameters and the most recent price data are used by Zeus EA to calculate the RSI.
When the RSI value falls below the RSI_Oversold level, the EA interprets this as a purchase signal. This implies that the market might be oversold and could have an upward reversal.
On the other hand, if the RSI value crosses above the RSI_Overbought level, it is a sell signal. This means that the market might be overbought and could retrace downward.
The Moving Average value:
double
maValue;
// Moving Average value
The Moving Average's (MA) current value is stored in the maValue variable. By smoothing price data across a predetermined time frame, this indicator facilitates trend identification.
The moving average is computed using the technique, price type, and selected period. The closing price of the designated period is used to calculate the MA in our EA.
Trend: The market trend that is currently in place is supported by the MA value. When the price is above the MA, the EA believes the market is in an uptrend and when it is below the MA, it believes that the market is in a downtrend.
Entry signal: The production of trade signals depends on the relationship between the RSI and the MA values. For instance, if the previous close price was higher than the MA value and the RSI is below the RSI_Oversold level, then a buy signal is deemed legitimate. The RSI and MA values are combined in the Zeus EA to help it make wise trading decisions.
double
Ask;
The asset's current ask price is stored in the ask variable. This is the asset's purchase price for traders. It sets the entry price for buy orders in the OpenPosition function. The asking price is the greatest price that can be found at that time to buy the asset. Precise monitoring of this cost guarantees that purchase orders are submitted appropriately.
double
Bid;
The asset's current bid price is recorded in the Bid variable. This is the asset's selling price for traders. It sets the entry price for sell orders in the OpenPosition function. The best price that can be obtained to sell the asset is reflected in the bid price.
double
Close[];
The asset's closing price for a particular period is stored in the Close array. It is enlarged in this EA to store values for the most current usage. The array is used to produce trading signals and analyze price movements. To decide whether to enter a buy or sell signal, the value is compared with the closing prices from the prior period (Close[1]) and the most recent period (Close[0]). This comparison will help us to determine if the price is heading higher or lower.
void
ApplyTrailingStop();
This function will help in the implementation of a trailing stop mechanism. If the current market price moves in favor of the position's stop loss, the function iterates through all open positions and modifies the stop loss. This function ensures that the stop loss stays at its most beneficial position even if the market price changes against the trade by setting a trailing stop.
void
OpenPosition(CTrade trade,
int
orderType);
Based on the order type, this method is intended to open new trading positions. The function determines the take-profit, stop-loss, and entry price based on the type of order. The transaction is carried out using computed parameters by using the CTrade object. This will help the EA to generate signals that might be feature essential for starting trades in the market.
void
ClosePositions(
int
orderType);
With this function, trading positions of a particular order type are closed. All open positions are iterated over, and those that fit the designated order type are closed by the function. This will help in eliminating positions that no longer fit the trading strategy or the state of the market, it will therefore enhance trade management.
//--- Function prototypes
void
ApplyTrailingStop();
void
OpenPosition(CTrade trade,
int
orderType);
We then combine these function prototypes to give the EA the ability to effectively handle trading positions. The OpenPosition method starts trades based on the market conditions, the ClosePositions function controls and closes deals as necessary, and the ApplyTrailingStop function improves trade management by modifying stop losses. All these features combined enable the EA to react quickly to market changes and carry out trades effectively.
Let's now move to the OnInit function. The Zeus EA uses the OnInit function to start trading. It is intended to make trades based on Moving Average and RSI indicators.
//+------------------------------------------------------------------+
//| Expert initialization function                .        |
//+------------------------------------------------------------------+
int
OnInit
()
  {
Print
(
"Zeus EA initialized successfully."
);
return
(
INIT_SUCCEEDED
);
  }
When the terminal launches or the EA is loaded into a chart, the OnInit function is invoked once. Initializing variables, establishing indicator handles, and carrying out any other configuration operations that need the use of this function. We then break its parts as follows:
Print
(
"Zeus EA initialized successfully."
);
The goal of this line of code is to print the message confirming the successful completion of initialization to the Expert Advisor (EA) log. A crucial component of every EA is logging. Therefore, we will be able to verify that the EA has loaded and initialized without any problem. It is also helpful when debugging and making sure that the EA is prepared to start processing market data and executing trades.
return
(
INIT_SUCCEEDED
);
  }
The return (INIT_SUCCEEDED); the statement serves the purpose of notifying the MetaTrader platform that the initialization process has been completed. The EA needs to return INIT_SUCCEEDED to move on to the next stages, like the OnTick function, which is where the main trading logic is carried out. The function might return INIT_FAILED, stopping the EA from operating and averting potential faults during operation, if the initialization has failed for any reason.
Afterward, let's look at the OnDeinit function, this function is crucial to preserving the dependability and integrity of your EA. We will discuss the role of this function. When an EA is recompiled, it is removed from the chart. This action activates the OnDinit function and offers it a chance to carry out cleanup tasks and make sure that resources are appropriately released and any last-minute steps are completed.
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void
OnDeinit
(
const
int
reason)
  {
Print
(
"Zeus EA deinitialized. Reason: "
, reason);
  }
The rationale behind deinitialization is provided via the reason parameter in the OnDeinit function. Debugging and figuring out why the EA was deinitialized can be aided by this. We use the print function in Zeus EA to log this reason.
void
OnDeinit
(
const
int
reason)
  {
Print
(
"Zeus EA deinitialized. Reason: "
, reason);
  }
You can determine if the EA was explicitly removed, recompiled, or the result of the terminal shutdown by looking at this straightforward log, which can offer insightful information during the development and testing stages.
Although the deinitialization reason is the only one that our current OnDeinit implementation logs, this function can be expanded to any necessary cleanup procedures. For example, you may need to close any open resources, release file handles, or save the current state. Resource leaks can be avoided and a clean reinitialization of the EA can be guaranteed with proper cleanup. This is crucial in real-time trading situations when dependability and stability are critical. Correct handling guarantees that performance problems from earlier runs won't interfere with the EA's ability to reload or restart.
We now move to the OnTick function, the OnTick function which is essential to the EA's real-time decision-making process. Every time a new price tick is received, this function is called, it then gives the EA the ability to assess the state of the market and carry out transactions using pre-established techniques. Here are the main functions of the OnTick function and how it combines the Zeus EA's strategy components:
Getting market information;
When the OnTick function first starts, it helps to get the most market data.
Ask =
SymbolInfoDouble
(
_Symbol
,
SYMBOL_ASK
);
    Bid =
SymbolInfoDouble
(
_Symbol
,
SYMBOL_BID
);
ArrayResize
(Close,
2
);
    Close[
0
] =
iClose
(
_Symbol
,
_Period
,
0
);
    Close[
1
] =
iClose
(
_Symbol
,
_Period
,
1
);
This code saves the most recent closing prices and obtains the ask and bid prices. To ensure the Close array has enough space to store the most closing recent price, ArrayResize is used.
Calculation of Technical Indicator;
The Moving Average and the Relative Strength Index are computed by the algorithm.
//--- Calculate RSI value
rsiValue =
iRSI
(
_Symbol
,
_Period
, RSI_Period,
PRICE_CLOSE
,
0
);
if
(rsiValue ==
WRONG_VALUE
)
     {
Print
(
"Error calculating RSI"
);
return
;
     }
//--- Calculate Moving Average value
maValue =
iMA
(
_Symbol
,
_Period
, MA_Period,
0
, MA_Method, MA_Price,
0
);
if
(maValue ==
WRONG_VALUE
)
     {
Print
(
"Error calculating Moving Average"
);
return
;
     }
While the MA value aids in determining trend direction, the RSI value indicates the overbought or oversold conditions. Before continuing the checks make sure the numbers are accurate.
Generation of Trade Signal; After calculating the indicators, the function looks for buy and sell signals:
//--- Check for Buy Signal
if
(rsiValue < RSI_Oversold && Close[
1
] > maValue)
     {
if
(
PositionsTotal
() ==
0
)
        {
         ClosePositions(
ORDER_TYPE_SELL
);
         OpenPosition(
ORDER_TYPE_BUY
);
        }
     }
//--- Check for Sell Signal
if
(rsiValue > RSI_Overbought && Close[
1
] < maValue)
     {
if
(
PositionsTotal
() ==
0
)
        {
         ClosePositions(
ORDER_TYPE_BUY
);
         OpenPosition(
ORDER_TYPE_SELL
);
        }
   }
A buy signal is issued when the current close price is above the Moving Average and the RSI is below the oversold threshold. This situation points to a possible upward reversal.
A sell signal is issued when the closing price is below the Moving Average and the RSI above the overbought threshold. This situation suggests a potential downward reversal.
Application of Trailing Stop; To minimize losses and safeguard winnings, the OnTick function incorporates the logic for applying trailing stop.
//--- Apply trailing stop if specified
if
(TrailingStop >
0
)
     {
      ApplyTrailingStop();
     }
When the trailing stop parameter is set, this section ensures the trailing stop mechanism is engaged. To lock in winnings, the ApplyTrailingStop function modifies the stop-loss level as the price moves in the desired direction.
Opening and closing positions: Using the opening position, the OpenPosition function tries to open a position after determining the entry price, stop loss, and take profit levels. Closing position; all positions are iterated over by the ClosePositions function, which closes those that correspond to the given order type.
This explains how the Zeus EA dynamically adapts to market situations by going over the OnTick function. This function uses the RSI and MA  indicators to produce trade signals and trailing stops to safeguard winnings. With this strategy, the EA is guaranteed to protect the gains and also respond to market changes. Below is the full code of the OnTick function:
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void
OnTick
()
  {
    Ask =
SymbolInfoDouble
(
_Symbol
,
SYMBOL_ASK
);
    Bid =
SymbolInfoDouble
(
_Symbol
,
SYMBOL_BID
);
ArrayResize
(Close,
2
);
    Close[
0
] =
iClose
(
_Symbol
,
_Period
,
0
);
    Close[
1
] =
iClose
(
_Symbol
,
_Period
,
1
);
//--- Calculate RSI value
rsiValue =
iRSI
(
_Symbol
,
_Period
, RSI_Period,
PRICE_CLOSE
,
0
);
if
(rsiValue ==
WRONG_VALUE
)
     {
Print
(
"Error calculating RSI"
);
return
;
     }
//--- Calculate Moving Average value
maValue =
iMA
(
_Symbol
,
_Period
, MA_Period,
0
, MA_Method, MA_Price,
0
);
if
(maValue ==
WRONG_VALUE
)
     {
Print
(
"Error calculating Moving Average"
);
return
;
     }
//--- Check for Buy Signal
if
(rsiValue < RSI_Oversold && Close[
1
] > maValue)
     {
if
(
PositionsTotal
() ==
0
)
        {
         ClosePositions(
ORDER_TYPE_SELL
);
         OpenPosition(
ORDER_TYPE_BUY
);
        }
     }
//--- Check for Sell Signal
if
(rsiValue > RSI_Overbought && Close[
1
] < maValue)
     {
if
(
PositionsTotal
() ==
0
)
        {
         ClosePositions(
ORDER_TYPE_BUY
);
         OpenPosition(
ORDER_TYPE_SELL
);
        }
   }
//--- Apply trailing stop if specified
if
(TrailingStop >
0
)
     {
      ApplyTrailingStop();
     }
Since we are done with the OnTick function let's now freely look at the utility functions of our EA. For the Zeus EA to execute a trade based on signals from the RSI and Moving Average indicators, the open function is essential. The feature ensures the buy and sell orders are placed accurately, taking into account risk management factors.
void
OpenPosition(
int
orderType)
The type of order to be placed is determined by the sole parameter, order type, that the OpenPosition function accepts. For purchase and sell orders, respectively, this might be ORDER_TYPE_BUY or ORDER_TYPE_SELL. The order type determines the order price within the function.
double
price = (orderType ==
ORDER_TYPE_BUY
) ? Ask : Bid;
Using the {Ask} price for a buy order it uses the {Bid} price for a sell order.
To control risk and ensure profits, stop loss (SL) and take profit (TP) thresholds are determined:
double
sl = (orderType ==
ORDER_TYPE_BUY
) ? price - StopLoss *
_Point
: price + StopLoss *
_Point
;
double
tp = (orderType ==
ORDER_TYPE_BUY
) ? price + TakeProfit *
_Point
: price - TakeProfit *
_Point
;
Take profit is put above the order price and the stop loss is set below it for buy orders. The take profit and the stop loss for sell orders are placed below and above the order price respectively. The PositionOpen function from the CTrade{ class is used to open the real position:
bool
result = trade.PositionOpen(
_Symbol
, orderType, Lots, price, sl, tp,
"Zeus EA"
);
This technique requires several parameters:
-{ Symbol}: The symbol used for trading such as EURUSD.
-{ orderType}: The kind of the order (sell or purchase).
-"Lots": The order's lot size.
-{price}: The bid or ask price of the order.
-{sI}: The level of stop loss computation.
-{tp}: The determined take-profit threshold.
-"Zeus EA": An order-related statement.
Following an attempt to open the position, the function verifies the outcome and records a message when necessary.
if
(result)
     {
Print
(
"Order opened successfully. Type: "
, orderType,
", Price: "
, price);
     }
else
{
Print
(
"Failed to open order. Error code: "
,
GetLastError
());
     }
  }
An acknowledgment is printed out if the order is successfully opened. If the order is unable to open, GetLastError is used to retrieve the problem code, which is then noted for troubleshooting.
The full code for the function to open positions is as below:
//+------------------------------------------------------------------+
//| Function to open a position                          |
//+------------------------------------------------------------------+
void
OpenPosition(
int
orderType)
  {
double
price = (orderType ==
ORDER_TYPE_BUY
) ? Ask : Bid;
double
sl = (orderType ==
ORDER_TYPE_BUY
) ? price - StopLoss *
_Point
: price + StopLoss *
_Point
;
double
tp = (orderType ==
ORDER_TYPE_BUY
) ? price + TakeProfit *
_Point
: price - TakeProfit *
_Point
;
bool
result = trade.PositionOpen(
_Symbol
, orderType, Lots, price, sl, tp,
"Zeus EA"
);
if
(result)
     {
Print
(
"Order opened successfully. Type: "
, orderType,
", Price: "
, price);
     }
else
{
Print
(
"Failed to open order. Error code: "
,
GetLastError
());
     }
  } 
)
We are done with one of the utility functions let now look at another one which is a function to close positions. To guarantee that undesired positions are terminated by parameters of the trading strategy, the Zeus EA's ClosePositions function is essential. When certain conditions are met, this function is meant to manage the logic for closing positions of a particular kind (buy or sell). Let's's examine this function's operations and significance to the broader plan.
void
OpenPosition(
int
orderType)
The type of position to close is specified by a single argument orderType, which is taken by the Closepositions function. ODER_TYPE_SELL or ORDER_TYPE_BUY are the possible values for this parameter. The function loops over all open positions at this time and closes the relevant ones.
for
(
int
i =
PositionsTotal
() -
1
; i >=
0
; i--)
     {
if
(PositionSelectByIndex(i))
        {
if
(
PositionGetInteger
(
POSITION_TYPE
) == orderType)
           {
if
(!trade.PositionClose(ticket)
              {
Print
(
"Failed to close position. Error code: "
,
GetLastError
());
              }
          }
     }
  }
The loop advances backward, beginning at the last point. Because shutting a position lowers the overall count of positions, a forward iteration loop may be disrupted, necessitating this reverse iteration. PositionSelectByIndex(!) is used to choose the position at the given index {i}.
The function verifies if the chosen location matches the given {orderType} within the loop.
if
(
PositionGetInteger
(
POSITION_TYPE
) == orderType)
If {orderType} is not equal to this value, the position should not be closed. The function tries to close the position if the type matches.
if
(!trade.PositionClose(ticket)
              {
Print
(
"Failed to close position. Error code: "
,
GetLastError
());
              }
          }
     }
  }
A position is closed by attempting to identify it by its ticket number {trade.PositionClose(ticket)}). An error message with the error code obtained by GetLastError() is printed if the position fails to close. This helps to identify the cause of the position's inability to be closed and facilitates troubleshooting.
The Zeus EA can lock in profits by closing winning positions when they reach a certain profit level. This is achieved by making sure that selected positions are closed under specific conditions.
The full code for the function to close the position is as below:
//+------------------------------------------------------------------+
//| Function to close positions                                      |
//+------------------------------------------------------------------+
void
ClosePositions(
int
orderType)
  {
for
(
int
i =
PositionsTotal
() -
1
; i >=
0
; i--)
     {
if
(PositionSelectByIndex(i))
        {
if
(
PositionGetInteger
(
POSITION_TYPE
) == orderType)
           {
if
(!trade.PositionClose(ticket)
              {
Print
(
"Failed to close position. Error code: "
,
GetLastError
());
              }
          }
     }
  }
Lastly, let's move to our last utility function which is a function to apply trailing stop. You can stop additional losses by closing losing trades. By following the guidelines, such as refraining from holding buy and sell positions at the same time, and hedging. The trailing stop modifies the stop loss levels when the market price shifts in favor of an open position. The ApplyTrailingStop method in the Zeus EA makes sure that this feature is applied effectively. The trailing stop limits potential losses while locking in profits by tracking market fluctuations. Let us discuss how the function works.
void
ApplyTrailingStop()
Since this applies to all open positions on the current symbol, the ApplyTrailingStop method does not require any parameters. Like the ClosePositions function, the function starts by iterating through all open positions:
for
(
int
i =
PositionsTotal
() -
1
; i >=
0
; i--)
     {
if
(PositionSelectByIndex(i) &&
PositionGetSymbol
() ==
_Symbol
)
The loop advances backward, beginning at the last position.
-{PositionSelectByIndex(i)}: This function chooses the entry at index{i}. Verifies that the position is associated with the active trading symbol by using {PositionGetSymbol()==_Symbol}.
The function uses the trailing stop distance and the current market price to determine the new stop level:
double
price = (
PositionGetInteger
(
POSITION_TYPE
) ==
ORDER_TYPE_BUY
) ? Bid : Ask;
double
sl = (
PositionGetInteger
(
POSITION_TYPE
) ==
ORDER_TYPE_BUY
) ? price - TrailingStop *
_Point
: price + TrailingStop *
_Point
;
The trailing stop for buy positions is set below the {bid} price. The trailing stop is positioned above the {Ask} price for sell trades. The function then uses PositionModify to apply the new stop loss level after determining whether it is appropriate:
if
(
PositionGetInteger
(
POSITION_TYPE
) ==
ORDER_TYPE_BUY
&&
PositionGetDouble
(
POSITION_SL
) < sl)
           {
if
(!trade.PositionModify(
PositionGetInteger
(
POSITION_TICKET
), sl,
PositionGetDouble
(
POSITION_TP
)))
              {
Print
(
"Failed to modify position. Error code: "
,
GetLastError
());
              }
           }
else
if
(
PositionGetInteger
(
POSITION_TYPE
) ==
ORDER_TYPE_SELL
&&
PositionGetDouble
(
POSITION_SL
) > sl)
           {
if
(!trade.PositionModify(
PositionGetInteger
(
POSITION_TICKET
), sl,
PositionGetDouble
(
POSITION_TP
)))
              {
Print
(
"Failed to modify position. Error code: "
,
GetLastError
());
              }
           }
        }
Only when the new stop loss level({sI)} exceeds the existing stop loss does the stop loss for your positions get changed. Also when the new stop loss level is less than the existing stop loss is updated for sell positions.
An error message containing the error code is printed if the position modification is unsuccessful. This aids in troubleshooting and also helps to clarify the reason why the trailing stop was not used.
The full code for the function to apply trailing stop is as below:
//+------------------------------------------------------------------+
//| Function to apply trailing stop                                  |
//+------------------------------------------------------------------+
void
ApplyTrailingStop()
  {
for
(
int
i =
PositionsTotal
() -
1
; i >=
0
; i--)
     {
if
(PositionSelectByIndex(i) &&
PositionGetSymbol
() ==
_Symbol
)
        {
double
price = (
PositionGetInteger
(
POSITION_TYPE
) ==
ORDER_TYPE_BUY
) ? Bid : Ask;
double
sl = (
PositionGetInteger
(
POSITION_TYPE
) ==
ORDER_TYPE_BUY
) ? price - TrailingStop *
_Point
: price + TrailingStop *
_Point
;
if
(
PositionGetInteger
(
POSITION_TYPE
) ==
ORDER_TYPE_BUY
&&
PositionGetDouble
(
POSITION_SL
) < sl)
           {
if
(!trade.PositionModify(
PositionGetInteger
(
POSITION_TICKET
), sl,
PositionGetDouble
(
POSITION_TP
)))
              {
Print
(
"Failed to modify position. Error code: "
,
GetLastError
());
              }
           }
else
if
(
PositionGetInteger
(
POSITION_TYPE
) ==
ORDER_TYPE_SELL
&&
PositionGetDouble
(
POSITION_SL
) > sl)
           {
if
(!trade.PositionModify(
PositionGetInteger
(
POSITION_TICKET
), sl,
PositionGetDouble
(
POSITION_TP
)))
              {
Print
(
"Failed to modify position. Error code: "
,
GetLastError
());
              }
           }
        }
The full code for the article is as below:
//+------------------------------------------------------------------+
//|                     Zeus EA                                      |
//|     Copyright 2024, MetaQuotes Ltd.                              |
//|                    https://www.mql5.com                          |
//+------------------------------------------------------------------+
#include
<Trade\Trade.mqh>
CTrade trade;
//--- Input parameters
input
double
Lots =
0.1
;
// Lot size
input
double
StopLoss =
50
;
// Stop loss in points
input
double
TakeProfit =
50
;
// Take profit in points
input
double
TrailingStop =
25
;
// Trailing stop in points
//--- RSI parameters
input
int
RSI_Period =
7
;
// RSI period
input
double
RSI_Overbought =
35.0
;
// RSI overbought level
input
double
RSI_Oversold =
15.0
;
// RSI oversold level
//--- Moving Average parameters
input
int
MA_Period =
25
;
// Moving Average period
input
ENUM_MA_METHOD
MA_Method =
MODE_SMA
;
// Moving Average method
input
ENUM_APPLIED_PRICE
MA_Price =
PRICE_CLOSE
;
// Applied price for MA
//--- Variables
double
rsiValue;
// RSI value
double
maValue;
// Moving Average value
double
Ask;
double
Bid;
double
Close[
2
];
// Initializing Close array with two elements
//--- Function prototypes
void
ApplyTrailingStop();
void
OpenPosition(CTrade &trade,
int
orderType);
// Pass CTrade by reference
void
ClosePositions(
int
orderType);
// pass orderType directly
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int
OnInit
()
  {
Print
(
"Zeus EA initialized successfully."
);
return
(
INIT_SUCCEEDED
);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void
OnDeinit
(
const
int
reason)
  {
Print
(
"Zeus EA deinitialized. Reason: "
, reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void
OnTick
()
  {
//--- Update current prices
Ask =
SymbolInfoDouble
(
_Symbol
,
SYMBOL_ASK
);
    Bid =
SymbolInfoDouble
(
_Symbol
,
SYMBOL_BID
);
ArrayResize
(Close,
2
);
     Close[
0
] =
iClose
(
_Symbol
,
Period
(),
0
);
    Close[
1
] =
iClose
(
_Symbol
,
Period
(),
1
);
//--- Calculate RSI value
rsiValue =
iRSI
(
_Symbol
,
_Period
, RSI_Period,
PRICE_CLOSE
,
0
);
if
(rsiValue ==
WRONG_VALUE
)
     {
Print
(
"Error calculating RSI"
);
return
;
//--- Calculate Moving Average value
maValue =
iMA
(
_Symbol
,
_Period
, MA_Period,
0
, MA_Method, MA_Price,
0
);
if
(maValue ==
WRONG_VALUE
)
     {
Print
(
"Error calculating Moving Average"
);
return
;
     }
//--- Check for Buy Signal
if
(rsiValue < RSI_Oversold && Close[
1
] > maValue)
     {
if
(
PositionsTotal
() ==
0
)
        {
         ClosePositions(
ORDER_TYPE_SELL
);
         OpenPosition(
ORDER_TYPE_BUY
);
        }
     }
//--- Check for Sell Signal
if
(rsiValue > RSI_Overbought && Close[
1
] < maValue)
     {
if
(
PositionsTotal
() ==
0
)
        {
         ClosePositions(
ORDER_TYPE_BUY
);
         OpenPosition(
ORDER_TYPE_SELL
);
        }
      }
//--- Apply trailing stop if specified
if
(TrailingStop >
0
)
     {
      ApplyTrailingStop();
     }
   }
//+------------------------------------------------------------------+
//| Function to open a position                                      |
//+------------------------------------------------------------------+
void
OpenPosition(
int
orderType)
  {
//--- Determine price stop loss, and take profit levels
double
price = (orderType ==
ORDER_TYPE_BUY
) ? Ask : Bid;
double
sl = (orderType ==
ORDER_TYPE_BUY
) ? price - StopLoss *
_Point
: price + StopLoss *
_Point
;
double
tp = (orderType ==
ORDER_TYPE_BUY
) ? price + TakeProfit *
_Point
: price - TakeProfit *
_Point
;
bool
result = trade.PositionOpen(
_Symbol
, orderType, Lots, price, sl, tp,
"Zeus EA"
);
if
(result)
     {
Print
(
"Order opened successfully. Type: "
, orderType,
", Price: "
, price);
     }
else
{
Print
(
"Failed to open order. Error code: "
,
GetLastError
());
     }
  }
//+------------------------------------------------------------------+
//| Function to close positions                                      |
//+------------------------------------------------------------------+
void
ClosePositions(
int
orderType)
  {
for
(
int
i =
PositionsTotal
() -
1
; i >=
0
; i--)
     {
if
(PositionSelectByIndex(i))
        {
//--- Check if the positions type matches the order type to be closed
if
(
PositionGetInteger
(
POSITION_TYPE
) == orderType)
           {
ulong
ticket =
PositionGetInteger
(
POSITION_TICKET
);
if
(!trade.PositionClose(ticket)
              {
Print
(
"Failed to close position. Error code: "
,
GetLastError
());
              }
            }
          }
       }
     }
//+------------------------------------------------------------------+
//| Function to apply trailing stop                                  |
//+------------------------------------------------------------------+
void
ApplyTrailingStop()
  {
for
(
int
i =
PositionsTotal
() -
1
; i >=
0
; i--)
     {
if
(PositionSelectByIndex(i) &&
PositionGetSymbol
() ==
_Symbol
)
        {
double
price = (
PositionGetInteger
(
POSITION_TYPE
) ==
ORDER_TYPE_BUY
) ? Bid : Ask;
double
sl = (
PositionGetInteger
(
POSITION_TYPE
) ==
ORDER_TYPE_BUY
) ? price - TrailingStop *
_Point
: price + TrailingStop *
_Point
;
//--- Trailing  stop logic for buy positions
if
(
PositionGetInteger
(
POSITION_TYPE
) ==
ORDER_TYPE_BUY
&&
PositionGetDouble
(
POSITION_SL
) < sl)
           {
if
(!trade.PositionModify(
PositionGetInteger
(
POSITION_TICKET
), sl,
PositionGetDouble
(
POSITION_TP
)))
              {
Print
(
"Failed to modify position. Error code: "
,
GetLastError
());
              }
           }
//--- Trailing stop logic for sell positions
else
if
(
PositionGetInteger
(
POSITION_TYPE
) ==
ORDER_TYPE_SELL
&&
PositionGetDouble
(
POSITION_SL
) > sl)
           {
if
(!trade.PositionModify(
PositionGetInteger
(
POSITION_TICKET
), sl,
PositionGetDouble
(
POSITION_TP
)))
              {
Print
(
"Failed to modify position. Error code: "
,
GetLastError
());
              }
           }
        }
      }
Congratulations to us! Up to this point, we have implemented our Zeus EA for automating trade.
Here is the results of our test results;
Results obtained:
The test was USDJYP and the back test is from 2024.07.10 to 2024.08.06 on 1H chart. Modeling, every. The parameters used are those we used to study the implementation.
This type of strategy is best in EUR/USD and USD/JPY  but only to those who does not need high win rate. Below is the parameters we have used to carry out the test for our EA:
Conclusion
The Zeus EA uses Moving Averages and the Relative Strength Index (RSI) to generate trading signals, showcasing an advanced trading strategy that integrates technical indicators to manage and capitalize on market opportunities. This guide has detailed the trading logic, risk control, and the MQL5 code underpinning the EA, which automates trading decisions to enhance consistency and reduce emotional bias.
From the graph we can learn that, small parameters for optimization not only reduces risk but also increases loss. Therefore, before deploying an EA in a live trading, thorough testing and optimization in different Symbols are crucial. This will help to ensure it performs well across different market conditions and aligns with specific trading goals.
Regular monitoring and adjustments are necessary to maintain the effectiveness of Zeus EA and similar automated systems. This article provides the essential insights and tools needed to effectively implement and optimize the Zeus EA for trading. Any extra support needed you will be able to access it from MQL5.
Attached files
|
Download ZIP
Zeus_EA33g.mq5
(6.76 KB)
Warning:
All rights to these materials are reserved by MetaQuotes Ltd. Copying or reprinting of these materials in whole or in part is prohibited.
Other articles by this author
Automating Trading Strategies with Parabolic SAR Trend Strategy in MQL5: Crafting an Effective Expert Advisor
Last comments |
Go to discussion
(5)
Cristian-bogdan Buzatu
|
8 Aug 2024 at 15:58
It gives compiling error.
Lucas Damien Lafon
|
8 Aug 2024 at 17:59
Could you please explain why you are using 15 and 35 as limit values for the RSI?
This does not really make sense to me, it seems like a trick to make your
backtest
work for the only 1 month you are showing...
Cornelis Cornelius
|
14 Aug 2024 at 13:57
Cristian-bogdan Buzatu
#
:
It gives compiling error.
I agree and tried to add extra bracket but still keep getting compile error
Cornelis Cornelius
|
14 Aug 2024 at 13:58
Lucas Damien Lafon
#
:
Could you please explain why you are using 15 and 35 as limit values for the RSI?
This does not really make sense to me, it seems like a trick to make your
backtest
work for the only 1 month you are showing...
I agree if you use 15 as oversold level then overbought level should be 85 not 35
mbaas
|
17 Aug 2024 at 11:25
Is someone testing this stuff before it gets published? Missing parens, calling functions with the wrong signature - embarassingly buggy!
Tuning LLMs with Your Own Personalized Data and Integrating into EA (Part 5): Develop and Test Trading Strategy with LLMs(I)-Fine-tuning
With the rapid development of artificial intelligence today, language models (LLMs) are an important part of artificial intelligence, so we should think about how to integrate powerful LLMs into our algorithmic trading. For most people, it is difficult to fine-tune these powerful models according to their needs, deploy them locally, and then apply them to algorithmic trading. This series of articles will take a step-by-step approach to achieve this goal.
Creating an MQL5-Telegram Integrated Expert Advisor (Part 1): Sending Messages from MQL5 to Telegram
In this article, we create an Expert Advisor (EA) in MQL5 to send messages to Telegram using a bot. We set up the necessary parameters, including the bot's API token and chat ID, and then perform an HTTP POST request to deliver the messages. Later, we handle the response to ensure successful delivery and troubleshoot any issues that arise in case of failure. This ensures we send messages from MQL5 to Telegram via the created bot.
MQL5 Wizard Techniques you should know (Part 31): Selecting the Loss Function
Loss Function is the key metric of machine learning algorithms that provides feedback to the training process by quantifying how well a given set of parameters are performing when compared to their intended target. We explore the various formats of this function in an MQL5 custom wizard class.
Data Science and ML (Part 29): Essential Tips for Selecting the Best Forex Data for AI Training Purposes
In this article, we dive deep into the crucial aspects of choosing the most relevant and high-quality Forex data to enhance the performance of AI models.
You are missing trading opportunities:
Free trading apps
Over 8,000 signals for copying
Economic news for exploring financial markets
Registration
Log in
latin characters without spaces
a password will be sent to this email
An error occurred
Log in With Google
You agree to
website policy
and
terms of use
If you do not have an account, please
register
Allow the use of cookies to log in to the MQL5.com website.
Please enable the necessary setting in your browser, otherwise you will not be able to log in.
Forgot your login/password?
Log in With Google