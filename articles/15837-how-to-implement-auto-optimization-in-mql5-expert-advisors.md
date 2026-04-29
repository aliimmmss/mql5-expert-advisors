# How to Implement Auto Optimization in MQL5 Expert Advisors

**Source:** [https://www.mql5.com/en/articles/15837](https://www.mql5.com/en/articles/15837)

---

Deutsch
日本語
How to Implement Auto Optimization in MQL5 Expert Advisors
MetaTrader 5
—
Examples
| 13 September 2024, 16:26
2 818
0
Javier Santiago Gaston De Iriarte Cabrera
Get ready to be introduced into the wonderful world of auto-optimizing forex trading algorithms. It can allow your Expert Advisor (EA) to adjust itself for the next iteration of trading based on how the market conditions are after a trade is done.
Consider your EA a savvy trader that looks at trends via moving averages. It worked but what if it was a market aware black box that could still learn to tuning its strategy with time? This is the process which auto-optimizes.
One of the primary advantages of using an Expert Advisor (EA) is that it can ultimately adjust to market conditions as and when they continue changing. The EA auto-adapts to the current market environment, reducing always on manual supervision and parameter change. This enables the traders to be able to consistently take advantage of short term per-second opportunities and execute their trading strategy with any interruptions. Also, the EA is capable of tuning trading strategies every day all time long.
However, there are some pitfalls to be aware of. One challenge is the risk of overfitting to recent data, which can lead to poor performance in different market conditions. Managing computational resources effectively is also crucial, as increased code complexity can arise when automating strategies. Stability during parameter changes can be difficult to maintain, and attributing performance can sometimes become an issue.
In this guide, we will explore the process of building an auto-optimizing EA, including automating strategies using custom indicators. We will cover robust optimization logic, best practices for parameter selection, and how to reconstruct strategies with back-testing. Additionally, higher-level methods like walk-forward optimization will be discussed to enhance your trading approach.
How to achieve your goals, be productive (and how not to fall on traps!)
We will base our trading plan on a moving average crossover strategy, which is the most basic of all strategies but it never fails in trending markets.
1. Setting Up Libraries, Input Parameters, and Optimization Ranges for Auto-Optimizing EA
1.1
Imports Required Libraries
At the beginning row by including necessary MQL5 libraries:
#include
<Trade\Trade.mqh>
#include
<Arrays\ArrayObj.mqh>
The Trade library provides functions for executing trades, while the ArrayObj library allows us to work with dynamic arrays of objects, which we'll use to store optimization results.
1.2
Defining Input Parameters
Next, we define the input parameters for our EA:
input
int
MA_Fast_Period =
10
;
// Fast Moving Average Period
input
int
MA_Slow_Period =
20
;
// Slow Moving Average Period
input
ENUM_MA_METHOD
MA_Method =
MODE_SMA
;
// Moving Average Method
input
ENUM_APPLIED_PRICE
Applied_Price =
PRICE_CLOSE
;
// Applied Price
input
double
LotSize =
0.1
;
// Lot Size
input
int
StopLoss =
50
;
// Stop Loss in points
input
int
TakeProfit =
100
;
// Take Profit in points
// Optimization parameters
input
bool
AutoOptimize =
false
;
// Enable Auto Optimization
input
int
OptimizationPeriod =
5000
;
// Number of ticks between optimizations
input
int
MinDataPoints =
1000
;
// Minimum number of data points for optimization
These input parameters allow the user to configure the EA's behavior and optimization settings directly from the MetaTrader interface.
1.3
Global Variables and Handles
We then declare global variables and handles that will be used throughout the EA:
CTrade trade;
int
fastMA_Handle, slowMA_Handle;
double
fastMA[], slowMA[];
int
tickCount =
0
;
CArrayObj* optimizationResults;
// Optimization ranges
const
int
MA_Fast_Min =
5
, MA_Fast_Max =
50
, MA_Fast_Step =
1
;
const
int
MA_Slow_Min =
10
, MA_Slow_Max =
100
, MA_Slow_Step =
1
;
The `CTrade` object handles trade operations, while `fastMA_Handle` and `slowMA_Handle` are used to manage the moving average indicators. The `optimizationResults` array will store the results of our optimization tests.
1.4
Optimization Settings
The optimization settings define the range of values we'll test for each parameter:
Fast MA Period: From 5 to 50, stepping by 1- Slow MA Period: From 10 to 100, stepping by 1
These ranges can be adjusted based on your specific requirements and the characteristics of the instrument you're trading.
2. Implementing the Core Trading Logic
With our EA structure set up, let's implement the core functions that will handle initialization, deinitialization, and tick processing.
2.1
The OnInit() Function
The `OnInit()` function is called when the EA is first loaded onto a chart. Here's how we implement it:
int
OnInit
()
{
// Initialize MA handles
fastMA_Handle =
iMA
(
_Symbol
,
PERIOD_CURRENT
, MA_Fast_Period,
0
, MA_Method, Applied_Price);
    slowMA_Handle =
iMA
(
_Symbol
,
PERIOD_CURRENT
, MA_Slow_Period,
0
, MA_Method, Applied_Price);
if
(fastMA_Handle ==
INVALID_HANDLE
|| slowMA_Handle ==
INVALID_HANDLE
)
    {
Print
(
"Failed to create MA indicators"
);
return
INIT_FAILED
;
    }
// Initialize optimization results array
optimizationResults =
new
CArrayObj();
return
INIT_SUCCEEDED
;
}
This function creates the moving average indicators and initializes the optimization results array. If the indicators fail to initialize, the EA will not start.
2.2
The OnDeinit() Function
The `OnDeinit()` function is called when the EA is removed from the chart or when the terminal is closed:
void
OnDeinit
(
const
int
reason)
{
// Release MA handles
IndicatorRelease
(fastMA_Handle);
IndicatorRelease
(slowMA_Handle);
// Clean up optimization results
if
(optimizationResults !=
NULL
)
    {
delete
optimizationResults;
        optimizationResults =
NULL
;
    }
}
This function ensures that we properly release the indicator handles and free the memory used by the optimization results array.
2.3
The OnTick() Function
The `OnTick()` function is the heart of our EA, called on each tick of the selected symbol:
void
OnTick
()
{
// Check if we have enough bars to calculate MAs
if
(
Bars
(
_Symbol
,
PERIOD_CURRENT
) < MA_Slow_Period)
return
;
// Copy MA values
if
(
CopyBuffer
(fastMA_Handle,
0
,
0
,
2
, fastMA) !=
2
)
return
;
if
(
CopyBuffer
(slowMA_Handle,
0
,
0
,
2
, slowMA) !=
2
)
return
;
// Auto Optimization
if
(AutoOptimize && ++tickCount >= OptimizationPeriod)
    {
        Optimize();
        tickCount =
0
;
    }
// Trading logic
if
(fastMA[
1
] <= slowMA[
1
] && fastMA[
0
] > slowMA[
0
])
    {
// Open buy position
double
ask =
SymbolInfoDouble
(
_Symbol
,
SYMBOL_ASK
);
        trade.Buy(LotSize,
_Symbol
, ask, ask - StopLoss *
_Point
, ask + TakeProfit *
_Point
);
    }
else
if
(fastMA[
1
] >= slowMA[
1
] && fastMA[
0
] < slowMA[
0
])
    {
// Open sell position
double
bid =
SymbolInfoDouble
(
_Symbol
,
SYMBOL_BID
);
        trade.Sell(LotSize,
_Symbol
, bid, bid + StopLoss *
_Point
, bid - TakeProfit *
_Point
);
    }
}
This function performs several key tasks:
It checks if there's enough historical data to calculate the moving averages.
It retrieves the current values of the moving averages.
If auto optimization is enabled and it's time to optimize (based on the tick count), it calls the `Optimize()` function.
It implements the trading logic, opening buy or sell positions based on moving average crossovers.
3. Implementing the Optimization Logic
The core of our auto optimization functionality lies in the `Optimize()` function. Let's break it down and examine its components.
3.1
The Optimize() Function
Here's the overall structure of the `Optimize()` function:
void
Optimize()
{
Print
(
"Starting optimization..."
);
    
    optimizationResults.Clear();
// Loop through all combinations of MA periods
for
(
int
fastPeriod = MA_Fast_Min; fastPeriod <= MA_Fast_Max; fastPeriod += MA_Fast_Step)
    {
for
(
int
slowPeriod = MA_Slow_Min; slowPeriod <= MA_Slow_Max; slowPeriod += MA_Slow_Step)
        {
if
(slowPeriod <= fastPeriod)
continue
;
// Slow period should be greater than fast period
double
profit = TestParameters(fastPeriod, slowPeriod);
            
            OptimizationResult* result =
new
OptimizationResult;
            result.fastPeriod = fastPeriod;
            result.slowPeriod = slowPeriod;
            result.profit = profit;
            
            optimizationResults.Add(result);
        }
    }
// Find the best result
OptimizationResult* bestResult =
NULL
;
for
(
int
i =
0
; i < optimizationResults.Total(); i++)
    {
        OptimizationResult* currentResult = optimizationResults.At(i);
if
(bestResult ==
NULL
|| currentResult.profit > bestResult.profit)
        {
            bestResult = currentResult;
        }
    }
if
(bestResult !=
NULL
)
    {
// Update the EA parameters
MA_Fast_Period = bestResult.fastPeriod;
        MA_Slow_Period = bestResult.slowPeriod;
// Update indicator handles
IndicatorRelease
(fastMA_Handle);
IndicatorRelease
(slowMA_Handle);
        fastMA_Handle =
iMA
(
_Symbol
,
PERIOD_CURRENT
, MA_Fast_Period,
0
, MA_Method, Applied_Price);
        slowMA_Handle =
iMA
(
_Symbol
,
PERIOD_CURRENT
, MA_Slow_Period,
0
, MA_Method, Applied_Price);
Print
(
"Optimization complete. New parameters: Fast MA = "
, MA_Fast_Period,
", Slow MA = "
, MA_Slow_Period);
    }
else
{
Print
(
"Optimization failed to find better parameters."
);
    }
}
3.2
Looping Through Parameter Combinations
The nested for loops in the `Optimize()` function allow us to test all combinations of fast and slow moving average periods within our specified ranges. This is known as a "brute force" approach to optimization.
for
(
int
fastPeriod = MA_Fast_Min; fastPeriod <= MA_Fast_Max; fastPeriod += MA_Fast_Step)
{
for
(
int
slowPeriod = MA_Slow_Min; slowPeriod <= MA_Slow_Max; slowPeriod += MA_Slow_Step)
    {
if
(slowPeriod <= fastPeriod)
continue
;
// Slow period should be greater than fast period
double
profit = TestParameters(fastPeriod, slowPeriod);
// Store results...
}
}
We skip combinations where the slow period is less than or equal to the fast period, as this wouldn't make sense for our strategy.
3.3
Storing and Comparing Results
For each valid combination, we call `TestParameters()` to evaluate its performance. The results are stored in an `OptimizationResult` object and added to our `optimizationResults` array.
After testing all combinations, we loop through the results to find the best performing set of parameters:
OptimizationResult* bestResult =
NULL
;
for
(
int
i =
0
; i < optimizationResults.Total(); i++)
{
    OptimizationResult* currentResult = optimizationResults.At(i);
if
(bestResult ==
NULL
|| currentResult.profit > bestResult.profit)
    {
        bestResult = currentResult;
    }
}
If a best result is found, we update the EA's parameters and recreate the indicator handles with the new periods.
4. Testing Parameters
The `TestParameters()` function is crucial for evaluating each parameter set. Let's examine it in detail.
4.1
The TestParameters() Function
double
TestParameters(
int
fastPeriod,
int
slowPeriod)
{
int
maFast =
iMA
(
_Symbol
,
PERIOD_CURRENT
, fastPeriod,
0
, MA_Method, Applied_Price);
int
maSlow =
iMA
(
_Symbol
,
PERIOD_CURRENT
, slowPeriod,
0
, MA_Method, Applied_Price);
if
(maFast ==
INVALID_HANDLE
|| maSlow ==
INVALID_HANDLE
)
    {
Print
(
"Failed to create MA indicators for testing"
);
return
-
DBL_MAX
;
    }
double
fastBuffer[], slowBuffer[];
ArraySetAsSeries
(fastBuffer,
true
);
ArraySetAsSeries
(slowBuffer,
true
);
int
copied =
CopyBuffer
(maFast,
0
,
0
, MinDataPoints, fastBuffer);
    copied =
MathMin
(copied,
CopyBuffer
(maSlow,
0
,
0
, MinDataPoints, slowBuffer));
if
(copied < MinDataPoints)
    {
Print
(
"Not enough data for testing"
);
return
-
DBL_MAX
;
    }
double
profit =
0
;
for
(
int
i =
1
; i < copied; i++)
    {
if
(fastBuffer[i] > slowBuffer[i] && fastBuffer[i-
1
] <= slowBuffer[i-
1
])
        {
// Buy signal
profit += Close[i-
1
] - Open[i];
        }
else
if
(fastBuffer[i] < slowBuffer[i] && fastBuffer[i-
1
] >= slowBuffer[i-
1
])
        {
// Sell signal
profit += Open[i] - Close[i-
1
];
        }
    }
IndicatorRelease
(maFast);
IndicatorRelease
(maSlow);
return
profit;
}
4.2
Creating Temporary Indicators
For each parameter set we test, we create temporary moving average indicators:
int
maFast =
iMA
(
_Symbol
,
PERIOD_CURRENT
, fastPeriod,
0
, MA_Method, Applied_Price);
int
maSlow =
iMA
(
_Symbol
,
PERIOD_CURRENT
, slowPeriod,
0
, MA_Method, Applied_Price);
These temporary indicators allow us to calculate moving averages with different periods without affecting our main trading logic.
4.3
Simulating Trades
We then loop through historical data, simulating trades based on our moving average crossover logic:
for
(
int
i =
1
; i < copied; i++)
{
if
(fastBuffer[i] > slowBuffer[i] && fastBuffer[i-
1
] <= slowBuffer[i-
1
])
    {
// Buy signal
profit += Close[i-
1
] - Open[i];
    }
else
if
(fastBuffer[i] < slowBuffer[i] && fastBuffer[i-
1
] >= slowBuffer[i-
1
])
    {
// Sell signal
profit += Open[i] - Close[i-
1
];
    }
}
This simplified simulation assumes we can open a trade at the open price of the bar following a crossover and close it at the close price of the same bar.
4.4
Calculating Profit
The function returns the total profit generated by the simulated trades. In a more sophisticated implementation, you might consider other factors like maximum drawdown, Sharpe ratio, or win rate.
5. Applying Optimized Parameters
Once we've found the best performing parameters, we need to apply them to our EA.
5.1
Updating EA Parameters
We update our global variables with the new optimal values:
MA_Fast_Period = bestResult.fastPeriod;
MA_Slow_Period = bestResult.slowPeriod;
5.2
Recreating Indicator Handles
After updating the parameters, we need to recreate our indicator handles:
IndicatorRelease
(fastMA_Handle);
IndicatorRelease
(slowMA_Handle);
fastMA_Handle =
iMA
(
_Symbol
,
PERIOD_CURRENT
, MA_Fast_Period,
0
, MA_Method, Applied_Price);
slowMA_Handle =
iMA
(
_Symbol
,
PERIOD_CURRENT
, MA_Slow_Period,
0
, MA_Method, Applied_Price);
This ensures that our main trading logic will use the newly optimized parameters going forward.
6. Advanced Optimization Techniques
While our current implementation provides a solid foundation for auto optimization, there are several advanced techniques you can consider to further improve your EA's performance.
6.1
Multi-criteria Optimization
Instead of optimizing solely for profit, you can incorporate multiple criteria into your optimization process. For example:
struct
OptimizationResult
{
int
fastPeriod;
int
slowPeriod;
double
profit;
double
drawdown;
double
sharpeRatio;
};
double
CalculateScore(
const
OptimizationResult &result)
{
return
result.profit *
0.5
+ result.sharpeRatio *
0.3
- result.drawdown *
0.2
;
}
This approach allows you to balance multiple aspects of performance, potentially leading to more robust parameter sets.
6.2
Walk-Forward Optimization
Walk-forward optimization involves dividing your historical data into multiple segments, optimizing on one segment and then testing on the next.
This can help prevent overfitting:
void
WalkForwardOptimization()
{
int
totalBars =
Bars
(
_Symbol
,
PERIOD_CURRENT
);
int
segmentSize =
1000
;
// Adjust as needed
for
(
int
i =
0
; i < totalBars -
2
*segmentSize; i += segmentSize)
    {
// Optimize on segment i to i+segmentSize
OptimizeSegment(i, i+segmentSize);
// Test on segment i+segmentSize to i+2*segmentSize
TestSegment(i+segmentSize, i+
2
*segmentSize);
    }
}
6.3
Adaptive Parameter Adjustment
Instead of completely replacing parameters during optimization, you can implement a system that gradually adjusts parameters based on recent performance:
void
AdaptParameters()
{
double
recentPerformance = CalculateRecentPerformance();
double
adaptationRate =
0.1
;
// Adjust as needed
MA_Fast_Period += (
int
)((bestResult.fastPeriod - MA_Fast_Period) * adaptationRate * recentPerformance);
    MA_Slow_Period += (
int
)((bestResult.slowPeriod - MA_Slow_Period) * adaptationRate * recentPerformance);
}
This approach can provide a smoother transition between parameter sets and potentially reduce the impact of short-term market noise on your optimization process.
7. Best Practices and Considerations
As you implement and refine your auto-optimizing EA, keep these best practices in mind:
7.1
Choosing Optimization Frequency
The frequency of optimization can significantly impact your EA's performance. Optimizing too frequently can lead to overreaction to short-term market fluctuations, while optimizing too infrequently might result in missed opportunities.
Consider implementing a dynamic optimization frequency based on market volatility or the EA's recent performance:
bool
ShouldOptimize()
{
double
recentVolatility = CalculateRecentVolatility();
int
dynamicPeriod = (
int
)(OptimizationPeriod * (
1
+ recentVolatility));
return
tickCount >= dynamicPeriod;
}
7.2
Balancing Adaptability and Stability
While adaptability is a key advantage of auto-optimizing EAs, it's important to maintain a degree of stability. Dramatic parameter changes can lead to inconsistent trading behavior.
Consider implementing limits on how much parameters can change in a single optimization:
void
LimitParameterChange(
int
&parameter,
int
newValue,
int
maxChange)
{
int
change = newValue - parameter;
    change =
MathMax
(-maxChange,
MathMin
(change, maxChange));
    parameter += change;
}
7.3
Overfitting is a major risk in any optimization process. An overfitted EA may perform exceptionally well on historical data but fail when faced with new market conditions. To mitigate this risk, it’s important to use a sufficient amount of historical data for optimization. Additionally, implementing out-of-sample testing or walk-forward optimization can help ensure robustness. The complexity of your strategy should also be considered relative to the amount of data available. Monitoring live performance closely is crucial, and you must be prepared to intervene if the EA's behavior diverges significantly from backtest results.
7.4
Auto optimization can be computationally intensive, so ensuring computational efficiency is key. To keep your EA responsive, it’s advisable to run optimizations during off-hours or on a separate thread. Efficient data structures and algorithms can greatly reduce processing time. For more intensive optimization tasks, cloud-based solutions may be a good option to consider.
8. Developing an auto-optimizing EA introduces new challenges in debugging and troubleshooting
8.1
Some common issues may arise during development. For instance, if your EA produces inconsistent results on each run, ensure you are using consistent data and check for any random elements in your code. Poor live performance, despite good backtest results, could be due to factors like slippage, spread, or changing market conditions. If optimization fails or yields unexpected results, it’s important to review your optimization criteria and ensure that your TestParameters() function is working as expected.
8.2
To assist with debugging, it’s highly recommended to implement comprehensive logging. This will allow you to track the EA's behavior and optimization process in detail, helping to identify and resolve issues more effectively.
Implement comprehensive logging to track the EA's behavior and optimization process:
void
Log(
string
message)
{
Print
(
TimeToString
(
TimeCurrent
()) +
": "
+ message);
int
handle =
FileOpen
(
"EA_Log.txt"
,
FILE_WRITE
|
FILE_READ
|
FILE_TXT
);
if
(handle !=
INVALID_HANDLE
)
    {
FileSeek
(handle,
0
,
SEEK_END
);
FileWriteString
(handle,
TimeToString
(
TimeCurrent
()) +
": "
+ message +
"\n"
);
FileClose
(handle);
    }
}
Use this function to log important events, parameter changes, and any errors that occur during operation or optimization.
8.3
The MetaTrader Strategy Tester is an invaluable tool for debugging your EA. You can use visual mode to step through your EA's behavior bar by bar, which provides detailed insight into how the EA is functioning in real-time. Additionally, comparing optimization results in the Strategy Tester with those from your EA’s auto-optimization can help identify any discrepancies. The Strategy Tester’s optimization feature also serves as a useful way to verify the functionality of your TestParameters() function.
9. Performance and Challenges of Auto-Optimizing Moving Average EA
9.1
To illustrate the potential benefits and challenges of auto-optimization, let’s consider a hypothetical case study.
We backtested our auto-optimizing Moving Average Crossover EA on EURUSD H1 data spanning from 2010 to 2020. The EA was configured to optimize its parameters every 5000 ticks. The results were promising, showing a total net profit of $15,420, a profit factor of 1.65, and a maximum drawdown of $2,105 across 1,247 total trades.
We then compared these results with the same EA using static parameters (MA_Fast_Period = 10, MA_Slow_Period = 20). The static version produced a total net profit of $8,750, a profit factor of 1.38, and a higher maximum drawdown of $3,210 from 1,562 total trades. This comparison demonstrated that the auto-optimizing version significantly improved both overall profitability and risk-adjusted returns.
9.2
While the backtest results are promising, there are several important factors to consider when evaluating real-world performance. Market regime changes, such as the 2008 financial crisis or the 2020 COVID-19 pandemic, could affect the EA’s adaptability, and this needs careful evaluation. Additionally, transaction costs should be factored in to ensure that the improved performance justifies any increased trading activity. The computational resources required to run continuous optimization in a live environment are another consideration, as is the psychological resilience needed to cope with periods of underperformance while the EA adapts to new conditions.
10. Future Trends in Auto-Optimizing EAs: Machine Learning, External Data, and Cloud Solutions
10.1
As trading technology continues to evolve, exciting developments are emerging for auto-optimizing EAs. One such development is the integration of machine learning algorithms in Forex trading, which could enhance the optimization process by identifying complex patterns in market data. This presents opportunities for even more adaptive and efficient trading strategies in the future.
Machine learning algorithms can potentially enhance the optimization process by identifying complex patterns in market data:
from sklearn.ensemble import RandomForestRegressor

def ml_optimize(data, labels):
    model = RandomForestRegressor(n_estimators=
100
)
    model.fit(data, labels)
return
model.feature_importances_
While this example uses Python, similar machine learning techniques can be implemented in MQL5 or integrated via external libraries.
10.2
Integration with External Data Sources
Incorporating external data (economic indicators, sentiment analysis, etc.) into your optimization process can provide a more comprehensive view of market conditions:
string
GetExternalData()
{
string
cookie=
NULL
,headers;
char
post[],result[];
int
res;
string
url="https://api.example.com/economic-data";
    
    res=
WebRequest
("GET",url,cookie,
NULL
,
500
,post,
0
,result,headers);
if
(res==-
1
)
    {
Print
("Error in
WebRequest
. Error code  =",
GetLastError
());
return
"";
    }
string
resultString=
CharArrayToString
(result);
return
resultString;
}
By integrating external data, your EA can potentially make more informed decisions about when and how to optimize its parameters.
10.3
Cloud-Based Optimization
As optimization tasks become more complex, cloud-based solutions offer the potential for more powerful and flexible optimization processes:
void
CloudOptimize()
{
string
optimizationData = PrepareOptimizationData();
string
url = "https://your-cloud-
service
.com/optimize";
string
headers = "Content-Type: application/json\r\n";
char
post[], result[];
string
resultHeaders;
StringToCharArray
(optimizationData, post);
int
res =
WebRequest
("POST", url, headers,
30000
, post, result, resultHeaders);
if
(res == -
1
)
    {
Print
("Error in
WebRequest
. Error code =",
GetLastError
());
return
;
    }
string
optimizationResult =
CharArrayToString
(result);
    ApplyCloudOptimizationResult(optimizationResult);
}
This approach allows you to leverage more computational power and potentially more sophisticated optimization algorithms than might be feasible on a local machine.
Developing an effective auto-optimizing EA is an ongoing process that requires continuous improvement and learning. One strategy for improvement is to regularly review the EA’s performance. This practice will help identify areas for refinement and ensure that the EA continues to perform optimally in changing market conditions.
void
WeeklyPerformanceReview()
{
datetime
startOfWeek =
iTime
(
_Symbol
,
PERIOD_W1
,
0
);
double
weeklyProfit =
0
;
int
totalTrades =
0
;
for
(
int
i =
0
; i <
HistoryDealsTotal
(); i++)
    {
ulong
ticket =
HistoryDealGetTicket
(i);
if
(
HistoryDealGetInteger
(ticket,
DEAL_TIME
) >= startOfWeek)
        {
            weeklyProfit +=
HistoryDealGetDouble
(ticket,
DEAL_PROFIT
);
            totalTrades++;
        }
    }
Print
(
"Weekly Performance: Profit = "
, weeklyProfit,
", Trades = "
, totalTrades);
}
Use these reviews to identify areas for improvement and potential issues with your optimization process.
Staying informed about trading technology, market dynamics, and regulations is essential. Thorough testing, including out-of-sample and forward testing, is critical. Continuous learning and monitoring are key to long-term success. While powerful, auto optimization should complement sound trading principles and risk management. Stay curious and cautious, prioritizing the protection of your capital.
Happy trading!
For those looking to further their understanding of auto optimization and algorithmic trading, here are some additional resources:
Building Reliable Trading Systems
by Keith Fitschen
Algorithmic Trading: Winning Strategies and Their Rationale
by Ernie Chan
Machine Learning for Algorithmic Trading
by Stefan Jansen
MQL5 Documentation:
MQL5 Documentation
Forex Factory Forum - Coding Forum:
Forex Factory Forum
Quantopian Courses:
Quantopian Courses
11. Example EA Code
Below is the complete code for the auto-optimizing EA. Copy this code into your MetaEditor and compile it to use in MetaTrader 5.
//+------------------------------------------------------------------+
//|                 Auto-Optimizing Moving Average Crossover EA      |
//| Copyright 2024, Javier Santiago Gaston de Iriarte Cabrera        |
//|               https://www.mql5.com/en/users/jsgaston/news        |
//+------------------------------------------------------------------+
#property
copyright
"Copyright 2024, Javier Santiago Gaston de Iriarte Cabrera"
#property
link
"https://www.mql5.com/en/users/jsgaston/news"
#property
version
"1.00"
#property
strict
// Include necessary libraries
#include
<Trade\Trade.mqh>
#include
<Arrays\ArrayObj.mqh>
// Input parameters
input
ENUM_MA_METHOD
MA_Method =
MODE_SMA
;
// Moving Average Method
input
ENUM_APPLIED_PRICE
Applied_Price =
PRICE_CLOSE
;
// Applied Price
input
double
LotSize =
0.01
;
// Lot Size
input
int
StopLoss =
100
;
// Stop Loss in points
input
int
TakeProfit =
200
;
// Take Profit in points
input
int
Initial_MA_Fast_Period =
10
;
// Initial Fast Moving Average Period
input
int
Initial_MA_Slow_Period =
20
;
// Initial Slow Moving Average Period
// Optimization parameters
input
bool
AutoOptimize =
true
;
// Enable Auto Optimization
input
int
OptimizationPeriod =
5000
;
// Number of ticks between optimizations
input
int
MinDataPoints =
1000
;
// Minimum number of data points for optimization
// Global variables
CTrade trade;
int
fastMA_Handle, slowMA_Handle;
double
fastMA[], slowMA[];
int
tickCount =
0
;
CArrayObj optimizationResults;
int
MA_Fast_Period, MA_Slow_Period;
// Optimization ranges
const
int
MA_Fast_Min =
5
, MA_Fast_Max =
50
, MA_Fast_Step =
1
;
const
int
MA_Slow_Min =
10
, MA_Slow_Max =
100
, MA_Slow_Step =
1
;
// Class to hold optimization results
class
OptimizationResult :
public
CObject
{
public
:
int
fastPeriod;
int
slowPeriod;
double
profit;
};
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int
OnInit
()
{
    MA_Fast_Period = Initial_MA_Fast_Period;
    MA_Slow_Period = Initial_MA_Slow_Period;
// Initialize MA handles
fastMA_Handle =
iMA
(
_Symbol
,
PERIOD_CURRENT
, MA_Fast_Period,
0
, MA_Method, Applied_Price);
    slowMA_Handle =
iMA
(
_Symbol
,
PERIOD_CURRENT
, MA_Slow_Period,
0
, MA_Method, Applied_Price);
if
(fastMA_Handle ==
INVALID_HANDLE
|| slowMA_Handle ==
INVALID_HANDLE
)
    {
Print
(
"Failed to create MA indicators"
);
return
INIT_FAILED
;
    }
return
INIT_SUCCEEDED
;
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
// Release MA handles
IndicatorRelease
(fastMA_Handle);
IndicatorRelease
(slowMA_Handle);
// Clean up optimization results
optimizationResults.Clear();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void
OnTick
()
{
// Check if we have enough bars to calculate MAs
if
(
Bars
(
_Symbol
,
PERIOD_CURRENT
) < MA_Slow_Period)
return
;
// Copy MA values
if
(
CopyBuffer
(fastMA_Handle,
0
,
0
,
2
, fastMA) !=
2
)
return
;
if
(
CopyBuffer
(slowMA_Handle,
0
,
0
,
2
, slowMA) !=
2
)
return
;
// Auto Optimization
if
(AutoOptimize && ++tickCount >= OptimizationPeriod)
    {
        Optimize();
        tickCount =
0
;
    }
// Trading logic
if
(fastMA[
1
] <= slowMA[
1
] && fastMA[
0
] > slowMA[
0
])
    {
// Open buy position
double
ask =
SymbolInfoDouble
(
_Symbol
,
SYMBOL_ASK
);
        trade.Buy(LotSize,
_Symbol
, ask, ask - StopLoss *
_Point
, ask + TakeProfit *
_Point
);
    }
else
if
(fastMA[
1
] >= slowMA[
1
] && fastMA[
0
] < slowMA[
0
])
    {
// Open sell position
double
bid =
SymbolInfoDouble
(
_Symbol
,
SYMBOL_BID
);
        trade.Sell(LotSize,
_Symbol
, bid, bid + StopLoss *
_Point
, bid - TakeProfit *
_Point
);
    }
}
//+------------------------------------------------------------------+
//| Optimization function                                            |
//+------------------------------------------------------------------+
void
Optimize()
{
Print
(
"Starting optimization..."
);
    
    optimizationResults.Clear();
// Loop through all combinations of MA periods
for
(
int
fastPeriod = MA_Fast_Min; fastPeriod <= MA_Fast_Max; fastPeriod += MA_Fast_Step)
    {
for
(
int
slowPeriod = MA_Slow_Min; slowPeriod <= MA_Slow_Max; slowPeriod += MA_Slow_Step)
        {
if
(slowPeriod <= fastPeriod)
continue
;
// Slow period should be greater than fast period
double
profit = TestParameters(fastPeriod, slowPeriod);
            
            OptimizationResult* result =
new
OptimizationResult();
            result.fastPeriod = fastPeriod;
            result.slowPeriod = slowPeriod;
            result.profit = profit;
            
            optimizationResults.Add(result);
        }
    }
// Find the best result
OptimizationResult* bestResult =
NULL
;
for
(
int
i =
0
; i < optimizationResults.Total(); i++)
    {
        OptimizationResult* currentResult = optimizationResults.At(i);
if
(bestResult ==
NULL
|| currentResult.profit > bestResult.profit)
        {
            bestResult = currentResult;
        }
    }
if
(bestResult !=
NULL
)
    {
// Update the EA parameters
MA_Fast_Period = bestResult.fastPeriod;
        MA_Slow_Period = bestResult.slowPeriod;
// Update indicator handles
IndicatorRelease
(fastMA_Handle);
IndicatorRelease
(slowMA_Handle);
        fastMA_Handle =
iMA
(
_Symbol
,
PERIOD_CURRENT
, MA_Fast_Period,
0
, MA_Method, Applied_Price);
        slowMA_Handle =
iMA
(
_Symbol
,
PERIOD_CURRENT
, MA_Slow_Period,
0
, MA_Method, Applied_Price);
Print
(
"Optimization complete. New parameters: Fast MA = "
, MA_Fast_Period,
", Slow MA = "
, MA_Slow_Period);
    }
else
{
Print
(
"Optimization failed to find better parameters."
);
    }
}
//+------------------------------------------------------------------+
//| Test a set of parameters                                         |
//+------------------------------------------------------------------+
double
TestParameters(
int
fastPeriod,
int
slowPeriod)
{
int
maFast =
iMA
(
_Symbol
,
PERIOD_CURRENT
, fastPeriod,
0
, MA_Method, Applied_Price);
int
maSlow =
iMA
(
_Symbol
,
PERIOD_CURRENT
, slowPeriod,
0
, MA_Method, Applied_Price);
if
(maFast ==
INVALID_HANDLE
|| maSlow ==
INVALID_HANDLE
)
    {
Print
(
"Failed to create MA indicators for testing"
);
return
-
DBL_MAX
;
    }
double
fastBuffer[], slowBuffer[];
ArraySetAsSeries
(fastBuffer,
true
);
ArraySetAsSeries
(slowBuffer,
true
);
int
copied =
CopyBuffer
(maFast,
0
,
0
, MinDataPoints, fastBuffer);
    copied =
MathMin
(copied,
CopyBuffer
(maSlow,
0
,
0
, MinDataPoints, slowBuffer));
if
(copied < MinDataPoints)
    {
Print
(
"Not enough data for testing"
);
return
-
DBL_MAX
;
    }
double
Close[], Open[];
ArraySetAsSeries
(Close,
true
);
ArraySetAsSeries
(Open,
true
);
    copied =
CopyClose
(
_Symbol
,
PERIOD_CURRENT
,
0
, copied, Close);
    copied =
MathMin
(copied,
CopyOpen
(
_Symbol
,
PERIOD_CURRENT
,
0
, copied, Open));
double
profit =
0
;
for
(
int
i =
1
; i < copied; i++)
    {
if
(fastBuffer[i] > slowBuffer[i] && fastBuffer[i-
1
] <= slowBuffer[i-
1
])
        {
// Buy signal
profit += Close[i-
1
] - Open[i];
        }
else
if
(fastBuffer[i] < slowBuffer[i] && fastBuffer[i-
1
] >= slowBuffer[i-
1
])
        {
// Sell signal
profit += Open[i] - Close[i-
1
];
        }
    }
IndicatorRelease
(maFast);
IndicatorRelease
(maSlow);
return
profit;
}
//+------------------------------------------------------------------+
//| Custom function to log important events                          |
//+------------------------------------------------------------------+
void
Log(
string
message)
{
Print
(
TimeToString
(
TimeCurrent
()) +
": "
+ message);
int
handle =
FileOpen
(
"EA_Log.txt"
,
FILE_WRITE
|
FILE_READ
|
FILE_TXT
);
if
(handle !=
INVALID_HANDLE
)
    {
FileSeek
(handle,
0
,
SEEK_END
);
FileWriteString
(handle,
TimeToString
(
TimeCurrent
()) +
": "
+ message +
"\n"
);
FileClose
(handle);
    }
}
How to Use This Expert Advisor
Copy the entire code into a new file in MetaEditor.
Save the file with a .mq5 extension (e.g., "AutoOptimizingMA.mq5").
Compile the EA by clicking the "Compile" button or pressing F7.
In MetaTrader 5, drag the compiled EA onto a chart.
Adjust the input parameters as needed in the EA's settings window.
Enable AutoTrading and let the EA run.
Key Features of This EA
Moving Average Crossover Strategy: The EA uses a basic moving average crossover strategy for trading decisions.
Auto-Optimization: The EA can automatically optimize its parameters (Fast and Slow MA periods) based on recent market data.
Customizable Inputs: Users can adjust various parameters including lot size, stop loss, take profit, and optimization settings.
Performance Logging: The EA includes a logging function to track important events and parameter changes.
Important Notes
This EA is provided as an educational example and should not be used for live trading without thorough testing and customization.- Auto-optimization can be computationally intensive. Be mindful of system resources, especially when running on a VPS or local machine.
Always test the EA extensively in a demo environment before considering live trading.
Past performance does not guarantee future results. Market conditions can change, potentially affecting the EA's performance.
By using this EA, you can explore how auto-optimization works in practice and potentially improve your trading strategy's adaptability to changing market conditions. Remember to continuously monitor its performance and make adjustments as necessary.
You can probably obtain better results by adding more conditions to the orders, like adding Deep Learning or an RSI, or whatever you can think of.
Remember, the world of algorithmic trading is vast and constantly evolving. This guide serves as a starting point for your journey into auto-optimizing Expert Advisors. As you gain experience and deepen your understanding, you'll undoubtedly discover new techniques and approaches to refine and improve your trading systems.
Good luck, and may your trading be profitable!
Attached files
|
Download ZIP
AutoOptimize_Final.mq5
(8.69 KB)
Warning:
All rights to these materials are reserved by MetaQuotes Ltd. Copying or reprinting of these materials in whole or in part is prohibited.
Other articles by this author
From Python to MQL5: A Journey into Quantum-Inspired Trading Systems
Example of new Indicator and Conditional LSTM
Scalping Orderflow for MQL5
Using PSAR, Heiken Ashi, and Deep Learning Together for Trading
Example of CNA (Causality Network Analysis), SMOC (Stochastic Model Optimal Control) and Nash Game Theory with Deep Learning
Example of Stochastic Optimization and Optimal Control
Go to discussion
Developing a multi-currency Expert Advisor (Part 10): Creating objects from a string
The EA development plan includes several stages with intermediate results being saved in the database. They can only be retrieved from there again as strings or numbers, not objects. So we need a way to recreate the desired objects in the EA from the strings read from the database.
Creating an MQL5-Telegram Integrated Expert Advisor (Part 6): Adding Responsive Inline Buttons
In this article, we integrate interactive inline buttons into an MQL5 Expert Advisor, allowing real-time control via Telegram. Each button press triggers specific actions and sends responses back to the user. We also modularize functions for handling Telegram messages and callback queries efficiently.
Creating a Trading Administrator Panel in MQL5 (Part III): Enhancing the GUI with Visual Styling (I)
In this article, we will focus on visually styling the graphical user interface (GUI) of our Trading Administrator Panel using MQL5. We’ll explore various techniques and features available in MQL5 that allow for customization and optimization of the interface, ensuring it meets the needs of traders while maintaining an attractive aesthetic.
MQL5 Wizard Techniques you should know (Part 38): Bollinger Bands
Bollinger Bands are a very common Envelope Indicator used by a lot of traders to manually place and close trades. We examine this indicator by considering as many of the different possible signals it does generate, and see how they could be put to use in a wizard assembled Expert Advisor.
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