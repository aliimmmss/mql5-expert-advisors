# Chapter 08: Testing Trading Capabilities of the Model

*Source: [https://www.mql5.com/en/neurobook/index/trade_check](https://www.mql5.com/en/neurobook/index/trade_check)*

---

## Testing trading capabilities of the model

We have done quite a bit of work studying various architectural solutions for organizing neural networks. We have created a library for building various neural layers, and now with its help, we can create different neural network models to find the best solution for our tasks. This is all very good and useful, of course. However, we are doing this not just for the sake of science or self-enlightenment, although that is certainly not a bad reason to study something. In this case, we embarked on the study of the organization of neural networks and their architectural solutions with a practical purpose to find a solution for use in the financial markets. There are two visions for such a solution:

- Creating an indicator based on a neural network model.

- Creating an Expert Advisor capable of executing trading operations based on the signals of the neural network model.

We will not discuss which of the above options is preferable. In fact, this is a rhetorical question because it depends on the user's personal preferences. In any case, we need to organize the correct operation of the model and the interpretation of its signals.

At the same time, we would like to assess the expected profitability of our model. To conduct such work, the MetaTrader 5 terminal offers the use of the Strategy Tester.

In this chapter, we move from the theoretical study and creation of neural networks to the practical application of the developed models in the financial sector. Our goal is to evaluate the effectiveness of neural networks for creating indicators and Expert Advisors capable of performing trading operations in financial markets. We'll start by examining the [functionality of the MetaTrader 5 Strategy Tester](https://www.mql5.com/en/neurobook/index/trade_check/strategy_tester), which is a key tool for evaluating the performance of our models.

Next, we will move on to creating an [Expert Advisor template](https://www.mql5.com/en/neurobook/index/trade_check/expert_template) using the MQL5 programming language. This will allow us to apply our models in real trading conditions. Then we will focus on [creating a model for testing](https://www.mql5.com/en/neurobook/index/trade_check/tester_model). In this part, we will see how to properly prepare and configure the model to produce the most accurate and useful results.

After that, we will discuss the [definition of Expert Advisor parameters](https://www.mql5.com/en/neurobook/index/trade_check/set_ea_settiongs), which includes setting various parameters and options that optimize the Expert Advisor operation in accordance with the user's trading strategies and goals. Finally, we will [test the model](https://www.mql5.com/en/neurobook/index/trade_check/forward_testing) using new data, which is a critical step in assessing the model's ability to adapt to changing market conditions and predict future trading signals.

This chapter focuses on the practical application of the developed neural networks in real-world trading strategies, covering model testing and optimization stages.

## Developing an Expert Advisor template using MQL5

To effectively assess the performance of our model in the strategy tester, we need to encapsulate it in a trading robot. Hence, in this section, I decided to present a small template of an Expert Advisor utilizing a neural network as the primary and sole decision-making block. I must clarify that this is just a template, aimed at demonstrating implementation principles and approaches. Its code is considerably simplified and is not intended for use on real accounts. Nevertheless, it is fully functional and can serve as a foundation for constructing a working Expert Advisor. Additionally, I want to caution you that financial market trading implies high-risk investments. You perform all your operations at your own risk and under your full responsibility, including if you use Expert Advisors on your accounts. Of course, unless the creators of such trading robots offer explicit guarantees, subject to your individual agreements.

Regarding Expert Advisors, before installing them on your real trading accounts and entrusting them with your funds, carefully study their parameters and configuration options. Also, validate their performance across various modes in the strategy tester and on demo accounts.

I hope this clarification is comprehensible to everyone. Now, let's proceed to the implementation of the template. Primarily, as I mentioned earlier, the presented template is significantly simplified, omitting several essential functions required for Expert Advisors that are not related to the operation of our model. In particular, the Expert Advisor completely lacks a money management block. For simplicity, we use a fixed Lot. We also use a fixed StopLoss and set the range for take profit between MinTarget and MaxTP. This approach to setting the take profit stems from the fact that in the models we are testing, the second target variable precisely represented the distance to the nearest future extreme point.

```
sinput string          Model = "our_model.net";

sinput int             BarsToPattern = 40;

sinput bool            Common = true;

input ENUM_TIMEFRAMES  TimeFrame = PERIOD_M5;

input double           TradeLevel=0.9;

input double           Lot = 0.01;

input int              MaxTP= 500;

input double           ProfitMultiply = 0.8;

input int              MinTarget=100;

input int              StopLoss=300;
```

Additionally, I have opted for a simplified approach to model usage. Rather than creating and training the model within the Expert Advisor, I approached it from a different angle. In all the scripts we created to test the architectural solutions of neural layers, we saved the trained models. So why not simply load one of the trained models? You can create and train your own model, and then just specify the file name of the trained model in the external Model parameter and use it. All that remains is to specify the storage location of the Common file, the number of bars describing one pattern BarsToPattern, and the TimeFrame used. Also, to make a decision, we will indicate the minimum predicted probability of profit TradeLevel.

To increase the probability of closing a trade at the take profit level, we add the ProfitMultiply parameter in which we indicate the coefficient of confidence in the predicted movement strength. In other words, when specifying the take profit level for an open position, we will adjust the size of the expected movement by this coefficient.

Using the Common parameter to specify the location of the trained model file is quite important, as strange as it may seem. The reason is that access to files in MetaTrader 5 is restricted within its sandbox. Each terminal installed on the computer has its own sandbox. So, each of the two terminals installed on the same computer works in its own sandbox and does not interfere with the second. For cases where data exchange is needed between terminals on the same computer, a separate common folder is used. So, the true value of the Common parameter indicates the use of this common folder.

When using the strategy tester optimization mode, each testing agent works in its own separate sandbox, even within the same trading terminal. Therefore, to provide equal access to the trained model for all testing agents, you need to place it in the common terminal folder and specify the corresponding flag value.

After declaring the external parameters of our Expert Advisor, we include our library for working with neural network models [neuronnet.mqh](https://www.mql5.com/en/neurobook/index/realization/basic/neuron_base) and the standard library for trading operations Trade\Trade.mqh in the global space.

```
#include "..\..\Include\NeuroNetworksBook\realization\neuronnet.mqh"

#include <Trade\Trade.mqh>

CNet *net;

CTrade *trade;

datetime lastbar = 0;

int h_RSI;

int h_MACD;
```

Next, we declare global variables:

- net — pointer to the model object

- trade — pointer to the object of trade operations

- lastbar — time of the last analyzed bar, used to check the new candlestick opening event

- h_RSI — handle of the RSI indicator

- h_MACD — handle of the MACD indicator

Our template will contain a minimum set of functions. But this does not mean that your Expert Advisor should contain exactly the same number of them.

In the OnInit function, we initialize the Expert Advisor. At the beginning of the function, we create a new instance of a neural network object and immediately check the result of the operation. If the creation of a new object is successful, we load the model from the specified file. Of course, we verify the result of these operations.

```
int OnInit()

  {

//---

   if(!(net = new CNet()))

     {

      PrintFormat("Error creating Net: %d", GetLastError());

      return INIT_FAILED;

     }

   if(!net.Load(Model, Common))

     {

      PrintFormat("Error loading mode %s: %d", Model, GetLastError());

      return INIT_FAILED;

     }

   net.UseOpenCL(UseOpenCL);
```

After loading the model, we load the required indicators. Within the framework of this book, we trained models on [historical datasets](https://www.mql5.com/en/neurobook/index/realization/initial_data) from two indicators: RSI and MACD. As always, we check the result of the operation.

```
h_RSI = iRSI(_Symbol, TimeFrame, 12, PRICE_TYPICAL);

   if(h_RSI == INVALID_HANDLE)

     {

      PrintFormat("Error loading indicator %s", "RSI");

      return INIT_FAILED;

     }

   h_MACD = iMACD(_Symbol, TimeFrame, 12, 48, 12, PRICE_TYPICAL);

   if(h_MACD == INVALID_HANDLE)

     {

      PrintFormat("Error loading indicator %s", "MACD");

      return INIT_FAILED;

     }
```

The next step is to create an instance of an object to perform trading operations. Again, we check the object creation result and set the order execution type.

```
void OnDeinit(const int reason)

  {

   if(!!net)

      delete net;

   if(!!trade)

      delete trade;

   IndicatorRelease(h_RSI);

   IndicatorRelease(h_MACD);

  }
```

At the end of the function, we set the initial value for the time of the last bar and exit the function.

Immediately after the initialization function, we create the OnDeinit deinitialization function, in which we delete the objects created in the program. We also close the indicators.

```
void OnDeinit(const int reason)

  {

   if(CheckPointer(net) == POINTER_DYNAMIC)

      delete net;

   if(CheckPointer(trade) == POINTER_DYNAMIC)

      delete trade;

   IndicatorRelease(h_RSI);

   IndicatorRelease(h_MACD);

  }
```

We write the entire algorithm of the Expert Advisor in the OnTick function. The terminal calls this function when a new tick event occurs on the chart with the program running. At the beginning of the function, we check if a new bar has opened. If the candlestick has already been processed, we exit the function and wait for a new tick. The essence of this action is simple: we feed our model with information only from closed candlesticks, and to ensure the information is as up-to-date as possible, we do this at the opening of a new candlestick.

```
void OnTick()

  {

   if(lastbar >= iTime(_Symbol, TimeFrame, 0))

      return;

   lastbar = iTime(_Symbol, TimeFrame, 0);
```

There are no functions in our template that process every tick, so we will only perform actions at the opening of a new candlestick. If you include functions in your program that need to process every tick, such as trailing stops, moving orders to breakeven, or anything else, you will need to call these functions before checking for the new candlestick event.

When a new candlestick event occurs, we load information from our indicators into local dynamic arrays. Here we need to be sure to check the result of the operations.

```
double macd_main[], macd_signal[], rsi[];

   if(h_RSI == INVALID_HANDLE || CopyBuffer(h_RSI, 0, 1, BarsToPattern, rsi) <= 0)

     {

      PrintFormat("Error loading indicator %s data", "RSI");

      return;

     }

   if(h_MACD == INVALID_HANDLE || CopyBuffer(h_MACD, MAIN_LINE, 1, BarsToPattern, macd_main) <= 0 ||

      CopyBuffer(h_MACD, SIGNAL_LINE, 1, BarsToPattern, macd_signal) <= 0)

     {

      PrintFormat("Error loading indicator %s data", "MACD");

      return;

     }
```

Once the indicator data is loaded, we create an instance of a data buffer object to collect the current state. Also, we run a loop to fill the data buffer with the current state of the indicators. Here we should organize exactly the same sequence of values describing the current state, as we filled in the training dataset file. Otherwise, the result of the model will be unpredictable.

```
CBufferType *input_data = new CBufferType();

   if(!input_data)

     {

      PrintFormat("Error creating Input data array: %d", GetLastError());

      return;

     }

   if(!input_data.BufferInit(BarsToPattern, 4, 0))

      return;
```

```
for(int i = 0; i < BarsToPattern; i++)

     {

      if(!input_data.Update(i, 0, (TYPE)rsi[i]))

        {

         PrintFormat("Error adding Input data to array: %d", GetLastError());

         delete input_data;

         return;

        }
```

```
if(!input_data.Update(i, 1, (TYPE)macd_main[i]))

        {

         PrintFormat("Error adding Input data to array: %d", GetLastError());

         delete input_data;

         return;

        }
```

```
if(!input_data.Update(i, 2, (TYPE)macd_signal[i]))

        {

         PrintFormat("Error adding Input data to array: %d", GetLastError());

         delete input_data;

         return;

        }
```

```
if(!input_data.Update(i, 3, (TYPE)(macd_main[i] - macd_signal[i])))

        {

         PrintFormat("Error adding Input data to array: %d", GetLastError());

         delete input_data;

         return;

        }

     }

   if(!input_data.Reshape(1,input_data.Total())

     return;
```

When we have fully gathered the description of the current state in the data buffer, we proceed to work on our model. First, we validate the model pointer and then call the feed-forward method. After a successful completion of the feed-forward method, we obtain its results in a local buffer. We do not create a new instance of an object for the results buffer; instead, we use the input data buffer.

```
if(!net)

     {

      delete input_data;

      return;

     }

   if(!net.FeedForward(input_data))

     {

      PrintFormat("Error of Feed Forward: %d", GetLastError());

      delete input_data;

      return;

     }
```

Next comes the decision-making block based on signals from our model. As a result of the feed-forward pass, the model returns two numbers. The first number is trained to determine the direction of the upcoming movement, while the second one determines the distance to the nearest extreme point. Thus, to execute operations, we will rely on both signals, which should be aligned.

First, we check the buy signal. The parameter responsible for the direction of movement must be positive. We also immediately check for open positions. If there are open long positions, we refrain from opening a new position and exit the function until the next tick.

Please note that we do not check for the presence of an open sell position. In our simplified version of the EA, we trust the forecasts of our model and expect all open positions to be closed by the take profit or stop loss. Consequently, we excluded the position management block from our Expert Advisor. As a result, we expect the possibility of simultaneously holding two opposite positions, which is only possible with position hedging. Therefore, testing such an Expert Advisor is possible only on the corresponding accounts.

This approach allows us to assess the effectiveness of forecasts made by our model. But when building Expert Advisors for real market usage, I would recommend considering and adding a position management block to the Expert Advisor.

```
if(!net.GetResults(input_data))

     {

      PrintFormat("Error of Get Result: %d", GetLastError());

      delete input_data;

      return;

     }

   if(input_data.At(0) > 0.0)

     {

      bool opened = false;

      for(int i = 0; i < PositionsTotal(); i++)

        {

         if(PositionGetSymbol(i) != _Symbol)

            continue;

         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)

            opened = true;

        }
```

```
if(opened)

        {

         delete input_data;

         return;

        }
```

If there are no open long positions, we check the strength of the signal (probability of movement in the desired direction) and the expected movement to the upcoming extreme point. If at least one of the parameters does not meet the requirements, we exit the function until the next tick.

```
if(input_data.At(0) < TradeLevel ||

         input_data.At(1) < (MinTarget * SymbolInfoDouble(_Symbol, SYMBOL_POINT)))

        {

         delete input_data;

         return;

        }
```

If, however, a decision is made to open a position, we determine the stop loss and take profit levels and send a buy order.

```
double tp = SymbolInfoDouble(_Symbol, SYMBOL_BID) + MathMin(input_data.At(1) *

                    ProfitMultiply, MaxTP * SymbolInfoDouble(_Symbol, SYMBOL_POINT));

      double sl = SymbolInfoDouble(_Symbol, SYMBOL_BID) -

                  StopLoss * SymbolInfoDouble(_Symbol, SYMBOL_POINT);

      trade.Buy(Lot, _Symbol, 0, sl, tp);

     }
```

The algorithm for making a sell decision is organized in a similar way.

```
if(input_data.At(0) < 0)

     {

      bool opened = false;

      for(int i = 0; i < PositionsTotal(); i++)

        {

         if(PositionGetSymbol(i) != _Symbol)

            continue;

         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)

            opened = true;

        }
```

```
if(opened)

        {

         delete input_data;

         return;

        }
```

```
if(input_data.At(0) > -TradeLevel ||

         input_data.At(1) > -(MinTarget * SymbolInfoDouble(_Symbol, SYMBOL_POINT)))

        {

         delete input_data;

         return;

        }
```

```
double tp = SymbolInfoDouble(_Symbol, SYMBOL_BID) + MathMax(input_data.At(1) *

                   ProfitMultiply, -MaxTP * SymbolInfoDouble(_Symbol, SYMBOL_POINT));

      double sl = SymbolInfoDouble(_Symbol, SYMBOL_BID) +

                  StopLoss * SymbolInfoDouble(_Symbol, SYMBOL_POINT);

      trade.Sell(Lot, _Symbol, 0, sl, tp);

     }

   delete input_data;

  }
```

After performing all the operations according to the described algorithm, we delete the buffer of the current state and exit the function.

The Expert Advisor has been made very simplified, but it will also allow you to test the operation of our model in the MetaTrader 5 strategy tester.

## Testing the model on new data

In the previous section, we optimized the parameters of our Expert Advisor on the training dataset and determined the optimal set of parameters. Now we need to test the performance of our model on new data. We are creating a model to potentially earn money in the financial market, arent we? So far, we have only trained the model and optimized the EA parameters using historical data for the period from 2015 to 2020 inclusive. We have identified the optimal set of parameters that allow us to make a profit on historical data. While we cannot travel back in time and make money on historical data, we can run our Expert Advisor on a trading account and hope for a comparable return in the future. To confirm or refute the possibility of future profitability, let's test our Expert Advisor with the trained model and optimized parameters on historical data outside the training set using data for 2021. Thus, we will test the profitability of the model on new data.

As in the case of parameter optimization, we go to the MetaTrader 5 strategy tester and in the Settings tab, specify the testing period 2021, select the type of modeling based on real ticks and disable parameter optimization. Also, do not forget to specify the correct financial instrument and timeframe.

After that, we will go to the EA parameters tab and specify the values of the parameters that we defined in the previous section. Start the testing process with the Start button.

Forward testing of the model

Forward testing of the model

During the testing period, the Expert Advisor made a profit over a long time interval. In general, the year was closed with a positive result. It should be noted that for testing the model, we use a rather simplified Expert Advisor algorithm without the use of money management and position tracking features. But even in this version, the EA shows profit. This is indicative of the overall profitability of the trading signals generated by the model. Potentially, adding money management and position tracking features will increase the profitability of Expert Advisor performance.

Results of forward testing of the model

The balance change chart shows sideways movement in the first half of the year, but from May, there is a clear trend of capital growth.

Results of forward testing of the model

Analysis of the Expert Advisor performance on new data showed that on some variables it even surpasses the values obtained on the training set. For instance, the profit factor on the new data was 1.48, whereas, during the parameter optimization on the training set, this indicator was at 1.22. The margin level in this case is not indicative, as all trades were made with a minimal volume, which greatly inflated this indicator.

Results of forward testing of the model

In total, for the whole of 2021, the EA opened 36 positions, 21 of which were closed with a profit. This accounted for 58.33% of the total number of positions. The obtained value is very close to the 60% expected return from the model's signals. Let me remind you that the threshold level for conducting trading operations is a 60% probability of the price moving in the predicted direction (parameter TradeLevel=0.6).

The maximum number of consecutive losing trades is three, while the maximum number of profitable trades is six.

Results of forward testing of the model

We did not integrate time-based transaction filtering into our Expert Advisor, nor did we provide time benchmarks for the training model. As a result, we see that the Expert Advisor opens positions more or less evenly throughout all trading sessions.

Results of forward testing of the model

However, throughout the week, we see a significant advantage in opening positions on Wednesday (about 30%). Friday and Monday follow next. The fewest positions are opened on Tuesday and Thursday.

Results of forward testing of the model

The Expert Advisor achieves the highest profitability on Wednesday and Monday. At the same time, the profit-to-loss ratio is better on Monday. On Friday, the profit and loss are balanced around the break-even point. However, on Tuesday and Thursday, the losses exceed the profits obtained. Such analysis potentially allows us to increase the profitability of the Expert Advisor by excluding inherently unprofitable trades. For instance, if we add a filter for opening positions based on the days of the week, we can increase the overall profitability of the Expert Advisor by making trades only on Monday and Wednesday.

Results of forward testing of the model

In general, the result of the Expert Advisor profitability on new data allows for the following conclusions:

- During technical analysis, it's possible to identify certain patterns that can generate quite stable signals for executing trades with profitability of at least 60%.

- The use of neural network models makes it possible to identify such patterns.

- Building an Expert Advisor based on neural networks allows for stable profitability over an extended period of time.

## Determining Expert Advisor parameters

After we have trained the model, before running it in the trading strategy, we need to learn how to use it. First and foremost, we need to understand its signals. As you know, after the feed-forward pass, our model returns two values:

- The probable direction of movement (the absolute value shows the probability of movement, and the sign shows the direction).

- The expected strength of movement (the absolute value shows the force of motion, and the sign shows the direction).

For each parameter, you need to find the decision threshold. A too-high value can filter out a large number of profitable trades or not provide any signals for trading operations at all. A too-small value can lead to a large number of false signals and even make trading unprofitable. Therefore, it is now very important to find the optimal parameters of the Expert Advisor to work with our trained model.

The best tool to do this is the MetaTrader 5 strategy tester. In the terminal, press Ctrl + R and navigate to the tester. In the Settings tab, in the Expert field, select our Expert Advisor and set the testing parameters.

We trained the model on EURUSD historical data from 2015 to 2020 on the M5 timeframe. We will use the same historical data to determine the optimal parameters of the Expert Advisor. According to the general neural network training rule, the performance of the model should be verified on a validation dataset. However, in this case, we simply determine the optimal parameters for the Expert Advisor when the model is running on the training dataset.

We know that our Expert Advisor analyzes entry points only at the opening of the candlestick, so to check the presence of signals from the model, it would be possible to test only at the opening prices. However, we also need to understand the quality of these signals. At the same time, we want to conduct the initial rough selection of parameters with minimal time and resources. Therefore, let's choose the testing mode based on the control points of the M1 timeframe.

We need to optimize the parameters, so we choose the optimization mode. To select the optimization mode, it's desirable to know the number of upcoming iterations. Counting them requires no effort, as they are automatically calculated when selecting Expert Advisor parameters for optimization. Let's go to the parameters tab and set the initial values of the parameters in the Value column. I would like to point out that parameters such as the model file name and the number of candles in the current pattern are not optimized because they should match the model being used.

Optimization of Expert Advisor parameters

In the first stage, we will roughly optimize only one parameter: the TradeLevel decision-making threshold. Select the checkbox of this parameter. At the output of our model, we used the hyperbolic tangent (tanh) as the activation function. Therefore, the output values of neurons are normalized in the range from −1 to 1. The sign shows the direction of movement. This means that the decision-making level can be in the range from 0 to 1. Obviously, making trades with a probability of making a profit of less than 50% looks risky, to say the least. Therefore, let's try to choose the level of decision-making in the range from 0.5 to 1.0. Recall that this is the first and rough selection of the parameter, so we will use step 0.05. The strategy tester immediately counted 11 iterations for us. As you can see, there are quite a few of them. Let's go back to the Settings tab and select the Slow complete algorithm optimization type. We also select optimization for the maximum balance and start the optimization process by clicking on the Start button.

Optimization of Expert Advisor parameters

The screenshot below shows the optimization results. As you can see, with a decision threshold of 0.65 or higher, the Expert Advisor does not execute any trades. From this, we can conclude that during the training process, our neural network did not identify patterns with a probability of one-directional movement equal to or greater than 65%. You should not be alarmed by the loss incurred by the Expert Advisor at this stage, as we have only conducted preliminary rough optimization with a crude determination of the decision-making level. Next, we have to optimize a few more parameters of our Expert Advisor.

Results of the first optimization

Results of the first optimization

First, let's try to optimize the parameter of the minimum strength of the upcoming movement MinTarget in order to filter out minor fluctuations. The goal of this iteration is to select the strongest movements. This is because the probability of such patterns triggering in practice is higher, and minor fluctuations may not have enough momentum to reach the target or may not trigger at all. Moreover, using orders with a low level of profitability reduces the risk-reward ratio.

We will optimize the parameter in the range from 50 to 600 points in increments of 50 points. In this iteration, we need to check 12 runs of the Expert Advisor.

Selection of the threshold value of decision-making

Based on the results of this parameter optimization, we can observe the emergence of the first profitable runs with a decision level of 500 and 600 points. However, with such parameter choices, the number of completed trading operations significantly decreases. Indeed, we want to extract the maximum potential from our model. It seems that values of the decision-making threshold around 350-400 pips are the most promising, with a trade count exceeding 1000 and being closest to the breakeven point. Let's take a small gamble and continue optimizing the parameters with the specified parameter range.

Results of Decision Threshold Optimization

Next, let's move on to optimizing the stop-loss parameter, which limits the risks for each trade. We will optimize this parameter in the range from 50 to 500 pips with a step size of 50 pips.

As mentioned above, we have not defined a clear value for the MinTarget parameter. Therefore, for the current optimization process, we will use two optimized parameters. At the same time, the parameter for the forecast strength threshold of the upcoming impulse will only take two permissible values.

Results of Decision Threshold Optimization

Thus, the strategy tester counted 20 passes of the current optimization process.

It is worth noting one more circumstance. In the upcoming optimization process, we are going to find the optimal stop-loss level. Here, it should be noted that in real trading, stop-loss and take-profit levels are handled by the broker on each tick. To get loss values as close as possible to real levels when the stop-loss is triggered, it will be necessary to optimize with each tick processed. Therefore, we go to the Settings tab and change the simulation mode to Every tick based on real ticks, which will switch the strategy tester to the mode of processing real historical ticks. We will also change the optimization mode to Fast genetic based algorithm. This will allow the tester to filter out passes whose results will be significantly worse than those already conducted.

Optimization of stop-loss parameters

Optimization of stop-loss parameters

As a result of optimizing the parameters, unfortunately, we still do not see any profitable passes. However, there is a clear superiority of a larger decision-making parameter based on the strength of the upcoming MinTarget momentum. At the same time, fairly close results were obtained for three stop-loss levels in the range of 300-400 points.

Thus, for further optimization of parameters, we take MinTarget at the level of 400 points, and we will continue optimizing the stop loss in the range of 300-400 points.

Stop-loss selection results

Stop-loss selection results

The next parameter to be optimized is the coefficient of confidence in the predicted strength of the expected momentum. This is the coefficient by which we will multiply the value of the second parameter returned by our model when calculating the take profit for the opened position. We will not overestimate the expected momentum value. Therefore, the upper limit of parameter optimization will be equal to one. We will set the lower limit of optimization at the level of 0.5, which is equivalent to 50% of the predicted momentum. With a step of 0.05, we get 11 optimization passes. Multiplying this number by 3 stop-loss options, we will get 33 passes of the upcoming parameter optimization.

Optimization of the confidence factor

As a result of optimization, we make a clear choice of a stop loss parameter at the level of 400 points and a confidence coefficient at the level of 0.8.

Results of Confidence Factor Optimization

Results of Confidence Factor Optimization

Unfortunately, we must admit the failure of our endeavor. We never got a profitable combination of parameters. Let's go back to the MinTarget parameter expressing the threshold decision-making value based on the strength of the predicted momentum. During the previous optimization of this parameter, we got the maximum profit at the level of 500 points. Let's conduct a small re-optimization of this parameter in the range from 400 to 500 points with a step of 50 points.

Re-optimization of the decision-making parameter

As a result of optimization, we get a profitable combination of parameters at the level of 500 points. I must say that the level of profit received is almost twice as much as previously received. At the same time, the number of trading operations decreased, while the profit factor remained at the level of 1.22.

Results of optimization of the decision-making parameter

Optimization of the profitability constraint parameter

Next, we optimize the MaxTP parameter indicating the maximum take profit limit. This parameter will act as a safeguard against inflated expectations. If the model predicts an exaggerated movement with new values, the Expert Advisor will limit the take profit level to this value, which we will determine from the statistics of the training dataset. We optimize the value of the MaxTP parameter in the range from 300 to 900 points in increments of 100 points.

Based on the optimization results, it can be noticed that when the parameter is increased beyond 600, the performance of the Expert Advisor does not change. Consequently, the level of expected movement does not exceed 600 points for the entire training sample. Therefore, we can safely limit the maximum profit level to 600 points.

Results of optimization of the profitability constraint parameter

Results of optimization of the profitability constraint parameter

Fine-tuning the decision-making parameter

Finally, we will fine-tune the decision-making parameter based on the movement probability level TradeLevel. Earlier, we conducted a rough optimization of this parameter with a step of 0.05 and settled on a level of 0.6. Now we will try to optimize the parameter with a step of 0.01 in the vicinity of the previously chosen level. Thus, we will optimize the parameter in the range of 0.56—0.64.

Strangely enough, the optimization we conducted only confirmed the correctness of the previously chosen decision-making parameter value at the level of 0.6. Any deviation of the parameter from this value has a negative impact on the profitability of our Expert Advisor.

Results of fine-tuning the decision-making parameter

Results of fine-tuning the decision-making parameter

So, as a result of the optimization work, we have the following set of parameters that allow for profitability on the training dataset.

It should be noted that to determine the optimal set of parameters, we went through quite a few iterations of their optimization. At the same time, the MetaTrader 5 strategy tester allows you to optimize any number of parameters in one run of the optimization process. However, you will have to pay for it with time and computing resources. If we calculate the total number of passes made for all iterations of optimization, we get about 95 passes. If we were to run simultaneous optimization of all the parameters mentioned above, the total number of possible parameter combinations for conducting passes would exceed 100,000. One can hope for a reduction in the number of passes through the use of genetic algorithms, but still, their number will significantly exceed what we've conducted. Consequently, it will take much more time to optimize the parameters.

A set of optimized parameters

Now, after determining the optimal set of parameters, let's test the model's performance on new data.

## Introduction to MetaTrader 5 Strategy Tester

MetaTrader 5 provides a built-in strategy tester which enables the validation of trading robot performance. This tool allows you to evaluate the Expert Advisor effectiveness and select the best input parameters before deploying it on a live trading account.

The entire operation of the strategy tester is based on the historical quotes of currencies and stocks. The tester automatically downloads tick history from the brokerage company's trading server and takes into account contract specifications. Therefore, the developer doesn't need to do anything manually. This allows for easy and highly accurate reproduction of all trading environment conditions, down to millisecond intervals between ticks on different symbols. The robot analyzes the accumulated quotes and executes virtual trades according to the algorithm embedded in it. This allows the evaluation of how well the strategy would have performed in the past.

Moreover, the MetaTrader 5 strategy tester is multi-currency. All robots tested in it can receive information about all financial instruments available on the registered account in the terminal and can trade on them. Thus, the tool allows testing even complex Expert Advisors capable of analyzing multiple currencies or stocks and their correlation.

The main advantage of such testing is the evaluation of a trading robot under conditions very close to real without its actual operation in the market. Moreover, it takes much less time since historical ticks are generated by the tester much faster than the real market. This is an undeniable advantage of the strategy tester, but far from its only capability.

The MetaTrader 5 Strategy Tester offers several testing modes. They allow selecting the optimal balance between speed and quality according to the user's needs. The 'Every tick' mode is intended for the most accurate testing; in this case, the simulated conditions will be closest to the real ones. The '1 minute OHLC' mode allows testing a strategy faster with a sufficient level of accuracy. If a very quick and rough estimate is needed, choose the 'Open prices only' mode, in which testing is conducted using only bar opening prices. The highest quality is offered by the 'Every tick based on real ticks' mode, but it also requires the maximum time investment.

The capabilities of the tester are not limited to just testing. It can also be used to solve mass optimization tasks. In the mathematical calculations mode, trading history is not used, and market conditions are not modeled, while only the mathematical calculations embedded in the Expert Advisor are executed.

Stress testing is an opportunity to further approximate the conditions of testing a trading robot to real ones. The mode of arbitrary execution delays simulates network delays in transmitting and processing trading requests, as well as simulates execution delays by dealers during real trading.

One of the main features of the strategy tester is the presentation of Expert Advisor testing results. It's not just dry figures, such as the profit generated by the trading robot during testing. The presentation also includes a wealth of statistical performance metrics:

- Profit and loss percentage ratio

- Number of winning and losing trades

- Risk factor

- Expected payoff

And this is far from a complete list. Additionally, the results of strategy testing are also provided in graphical form, making the analysis of the trading strategy even more convenient and clear.

The existing visual testing mode allows real-time tracking of the robot's trading on historical price data. All Expert Advisor trades are displayed on the chart, making them easy to analyze. The testing process can be slowed down or paused to observe how trading is conducted at specific time intervals.

Visualization mode is not only an opportunity to see how the robot trades. In addition, it allows checking the performance of custom technical indicators. For example, before purchasing through the [Market](https://www.mql5.com/en/market), you can assess its behavior on historical data.

An important function of the strategy tester is the optimization of the trading robot, which allows you to find the best input parameters for a specific Expert Advisor. Various optimization modes allow finding optimal parameters to make the trading robot as profitable and robust as possible, with minimal risk, and so on.

During optimization, one trading robot is tested with different input parameters. After testing is completed, the results of the runs can be compared, and the settings that best meet the requirements placed on the robot can be selected.

The number of input parameter combinations during optimization can reach tens or hundreds of thousands. As a result, optimization can become a very time-consuming process, which can still be significantly reduced using genetic algorithms. This feature disables the sequential enumeration of all input parameter combinations and selects only those that best meet the optimization criteria. In subsequent stages, the optimal combinations are crossbred until the results stop improving. This reduces the number of combinations and the overall optimization time many times over.

In addition, the strategy tester works in a multi-thread mode and allows the utilization of all CPU cores. This will run an Expert Advisor on each core with its own set of parameters. Furthermore, for a large pool of tasks, the strategy tester provides the ability to connect to cloud computing through the use of the MQL5 Cloud Network. This is a network of cloud computing resources that combines thousands of computers worldwide. The strategy tester can use its practically limitless computational power. With the MQL5 Cloud Network, optimization that would take months in regular mode can be completed in just a few hours.

The strategy tester provides powerful tools for visual analysis of optimization results in both 2D and 3D modes. For example, in a two-dimensional representation, you can analyze the dependencies of the final result on two parameters simultaneously, while in 3D, you can see the entire picture of finding the best result during optimization.

In addition to the built-in capabilities, you can use your own visualization methods. There is no need to prepare, export, or process data in an external application. Simply display the optimization results on the screen in real time during its execution.

The built-in forward testing feature helps eliminate "over-optimization" or parameter fitting. With this option enabled, the history of currency and stock quotes is divided into two parts. Optimization occurs in the first segment of the history, and the second segment is used only to confirm the results. If the trading robot efficiency is equally high in both segments, it means that the trading system has the best parameters and parameter fitting is practically eliminated.

The strategy tester is an indispensable tool for Expert Advisor developers. Without it, it is practically impossible to write an efficient trading robot. It saves time and assists in creating a truly profitable tool for use in financial markets.

## Creating a model for testing

In the previous section, we created a template for an Expert Advisor to test the feasibility of using our neural network models for conducting trading operations in financial markets. This is a universal template that can work with any model. However, it has limited parameters for the description of one candlestick and for the configuration of the results layer. As a result of the model operation, it should return a tensor of values that the decision-making block in the template can unambiguously interpret.

For testing purposes, I decided to build a new model that involves multiple types of neural layers. We will create and train the model using a script. The script format is familiar to us from the numerous tests that we examined in this book. We will create a new script in the file gpt_not_norm.mq5. We will save the new script file in the gpt subdirectory of our book in accordance with the [file structure](https://www.mql5.com/en/neurobook/index/realization/files_struct).

At the script's global level, we will declare two constants:

- BarsInHistory — number of bars in the training dataset

- ModelName — file name to save the trained model

Next, we define the external parameters of the script. First of all, this is the name of the file with the training dataset StudyFileName. Please note that we are using a dataset without prior data normalization. In the previous section, in our Expert Advisor template, we did not configure data preprocessing, so the entire calculation relies on using batch normalization layers. The tests we conducted earlier confirm the possibility of such a replacement.

The external parameter OutputFileName contains the name of the file for writing the dynamics of changes in the model error during the training process.

We plan to use a block with the GPT architecture. For such an architecture, it's common to use a parameter to specify the length of the internal buffer sequence for the pattern. To request this parameter from the user, we will create an external parameter BarsToLine.

Next comes the set of parameters that has become standard for such scripts:

- NeuronsToBar — number of input layer neurons per bar

- UseOpenCL — flag for using OpenCL

- BatchSize — batch size between weight matrix updates

- LearningRate — learning rate

- HiddenLayers — number of hidden layers

- HiddenLayer — number of neurons in the hidden layer

- Epochs — number of iterations for updating the weight matrix before the training process stops.

```
#define HistoryBars           40

#define ModelName             "gpt_not_norm.net"

//+------------------------------------------------------------------+

//| External parameters for the script                               |

//+------------------------------------------------------------------+

// Name of the file with the training sample

input string   StudyFileName  = "study_data_not_norm.csv";

// File name for recording error dynamics

input string   OutputFileName = "loss_study_gpt_not_norm.csv";

// Depth of the analyzed history
```

After declaring external parameters, we add our neural network model library to the script.

```
//+------------------------------------------------------------------+

//| Connecting the neural network library                            |

//+------------------------------------------------------------------+

#include "..\..\..\Include\NeuroNetworksBook\realization\neuronnet.mqh"
```

This is where the work in the global field ends. Let's continue writing the script code in the body of the OnStart function. In the body of the function, we use a structured approach to call individual functions, each of which performs specific actions.

```
void OnStart(void)

  {

   VECTOR loss_history;

//--- prepare a vector to store the history of network errors

   if(!loss_history.Resize(0, Epochs))

     {

      Print("Not enough memory for loss history");

      return;

     }

   CNet net;

//--- 1. network initialization

   if(!NetworkInitialize(net))

      return;

//--- 2. loading training sample data

   CArrayObj data;

   CArrayObj result;

   if(!LoadTrainingData(StudyFileName, data, result))

      return;

//--- 3. network training

   if(!NetworkFit(net, data, result, loss_history))

      return;

//--- 4. saving network error history

   SaveLossHistory(OutputFileName, loss_history);

   Print("Done");

  }
```

The first function in our script is the model initialization function NetworkInitialize. In its parameters, this function receives a pointer to the model object that needs to be initialized.

The function body provides two options for model initialization. First, we attempt to load a pre-trained model from the file specified in the external parameters of the script and check the operation result. If the model is successfully loaded, we skip the block that creates a new model and continue working with the loaded model. This capability enables us to stop and resume the learning process if necessary.

```
bool NetworkInitialize(CNet &net)

  {

   if(net.Load(ModelName))

     {

      printf("Loaded pre-trained model %s", ModelName);

      net.SetLearningRates((TYPE)LearningRate,(TYPE)0.9, (TYPE)0.999);

      net.UseOpenCL(UseOpenCL);

      net.LossSmoothFactor(BatchSize);

      return true;

     }
```

If the loading of a pre-trained model fails, we create a new neural network. First, we create a dynamic array to store pointers to objects describing neural layers and then we immediately call the CreateLayersDesc function to create the architecture description of our model.

```
CArrayObj layers;

//--- create a description of the network layers

   if(!CreateLayersDesc(layers))

      return false;
```

As soon as our dynamic array of objects contains the complete description of the model to be created, we call the model generation method, specifying in the parameters a pointer to the dynamic array describing the model, the loss function, and the model optimization parameters.

```
//--- initialize the network

   if(!net.Create(&layers, (TYPE)LearningRate, (TYPE)0.9, (TYPE)0.999, LOSS_MSE,

                                                                    0, (TYPE)0))

     {

      PrintFormat("Error of init Net: %d", GetLastError());

      return false;

     }
```

We ensure to verify the result of the operation.

After creating the model, we set the user-specified flag for using OpenCL technology and the error smoothing range.

```
net.UseOpenCL(UseOpenCL);

   net.LossSmoothFactor(BatchSize);

   return true;

  }
```

This concludes the model initialization function. Let's now consider the algorithm of the CreateLayersDesc function that creates the architecture description of the model. In the parameters, the function receives a pointer to a dynamic array object describing the model architecture. In the body of the function, we immediately clear the received array.

```
bool CreateLayersDesc(CArrayObj &layers)

  {

   layers.Clear();
```

First, we create the initial data layer. The algorithm for creating all neural layers will be the same, so we begin by initiating a new object for describing the neural layer. As always, we verify the result of the operation, that is, check the creation of a new object.

```
CLayerDescription *descr;

//--- create an initial data layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }
```

Once the neural layer description object is created, we fill it with data sufficient to unambiguously understand the architecture of the neural layer being created.

```
descr.type         = defNeuronBase;

   int prev_count = descr.count = NeuronsToBar * GPT_InputBars;

   descr.window       = 0;

   descr.activation   = AF_NONE;

   descr.optimization = None;
```

We will input information about the last three candlesticks into the created model. In fact, this is not enough, both in terms of the amount of information for the neural network to make a decision and from the practical trading perspective. However, we should remember that we will use blocks with the GPT architecture in our model. This architecture involves the accumulation of historical data inside a block, compensating for the lack of information. At the same time, using a small amount of initial data allows for a significant reduction in computational operations at each iteration. Thus, the size of the initial data layer is determined as the product of the number of elements to describe one candlestick and the number of analyzed candlesticks. In our case, the number of description elements for one candlestick is specified in the external parameter NeuronsToBar, and the number of analyzed candlesticks is specified by the GPT_InputBars constant.

The initial data layer does not use either an activation function or parameter optimization. Note that we write the initial data directly to the results buffer.

```
if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }
```

Once we have filled the architecture description object of the neural layer with the necessary set of data, we add it to our dynamic array of pointers to objects.

I would like to remind you that we did not pre-process the initial data. Therefore, in the neural network architecture, we have included the creation of a batch data normalization layer immediately after the initial data layer. According to the above algorithm, we instantiate a new object describing the neural layer. It is important to verify the result of the object creation operation, as in the next stage, we will be populating the elements of this object with the necessary description of the architecture of the created neural layer. Attempting to access the object elements with an invalid pointer will result in a critical error.

```
//--- create a data normalization layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }
```

In the description of the neural layer being created, we specify the type of the neural layer defNeuronBatchNorm, which corresponds to the batch normalization layer. We set the sizes of the neural layer and the window of initial data to be equal to the size of the previous input data neural layer.

We will indicate the batch size at the batch size level between updates of the weight matrix, which the user specified in the external parameter BatchSize.

Similar to the previous layer, the batch normalization layer does not employ an activation function. However, it introduces the Adam optimization method for trainable parameters.

```
descr.type         = defNeuronBatchNorm;

   descr.count        = prev_count;

   descr.window       = prev_count;

   descr.activation   = AF_NONE;

   descr.optimization = Adam;

   descr.batch        = BatchSize;
```

After specifying all the necessary parameters for describing the neural layer to be created, we add a pointer to the object to the dynamic array of pointers describing the architecture of our model.

```
if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }
```

As we have discussed previously, four parameters in the description of one candlestick might be insufficient. Therefore, it would be beneficial to add a few more parameters. To use machine learning methods in conditions of a shortage of parameters, a number of approaches have been developed that have been combined into the field of ​​Feature Engineer. One such approach involves the use of convolutional layers, in which the number of filters exceeds the size of the input window. The logic of this approach is that the description vector of one element is considered as the coordinates of a certain point representing the current state in an N-dimensional space, where N is the length of the description vector of one element. By performing convolution, we project this point onto the convolution vector. We use exactly this property when compressing data and reducing its dimensionality. The same property will be used to increase data dimensionality. As you can see, there is no contradiction here with the previously studied approach to using convolutional layers. We simply use the number of filters exceeding the description vector of one element and thereby increase the space dimension. Let's use the described method and create the next convolutional layer with the number of filters being twice the number of elements in the description of one candlestick. It should be noted that in this case we are making a convolutional layer within the description of one candlestick, so the size of the initial data window and its step size will be equal to the size of the description vector of one candlestick.

The algorithm for creating the description of the neural layer remains the same. First, we create a new instance of the neural layer description object and check the result of the operation.

```
//--- Convolutional layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }
```

Then we fill in the required information.

```
descr.type = defNeuronConv;

   prev_count = descr.count = prev_count / NeuronsToBar;

   descr.window = NeuronsToBar;

   int prev_window = descr.window_out = 2 * NeuronsToBar;

   descr.step = NeuronsToBar;

   descr.activation = AF_SWISH;

   descr.optimization = Adam;

   descr.activation_params[0] = 1;
```

We pass a pointer to the populated instance of the object into the dynamic array describing the architecture of the model being created.

```
if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }
```

After the information passes through the convolutional layer, we expect to obtain a tensor with eight elements describing the state of one candlestick. However, we know that fully connected models do not evaluate the dependence between elements, whereas such dependencies are typically strong when analyzing time series data.

Hence, at the next stage, we aim to analyze such dependencies. We discussed such analysis during our introduction to convolutional networks. Despite seeming peculiar, we employ the same type of neural layers to address two seemingly different tasks. In fact, we are performing a similar task but with different data. In the preceding convolutional layer, we decomposed the description vector of a single candlestick into a larger number of elements. We can look at this task from another perspective. As we discussed during the study of the convolutional layer, the convolution process involves determining the similarity between two functions. That is, in each filter, we identify the similarity of the original data with some reference function. Each filter uses its own reference function. By conducting convolution operations on the scale of a single bar, we sought the similarity of each bar with some reference.

Now we want to analyze the dynamics of changes in candlestick parameters. To do this, we need to perform convolution between identical elements of description vectors for different candles. After convolution, the previous layer returned three values sequentially (the number of analyzed candlesticks) from each filter. So, the next step is to create a convolutional layer with a window of initial data and a step equal to the number of analyzed candlesticks. In this convolutional layer, we will also use eight filters.

Let's create a description for the convolutional neural layer following the algorithm mentioned earlier.

```
//--- Convolutional layer 2

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }
```

```
descr.type = defNeuronConv;

   descr.window = prev_count;

   descr.step = prev_count;

   prev_count = descr.count = prev_window;

   prev_window = descr.window_out = 8;

   descr.activation = AF_SWISH;

   descr.optimization = Adam;

   descr.activation_params[0] = 1;
```

```
if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }
```

Thus, after preprocessing the data in one batch normalization layer and two consecutive convolutional layers, we obtained a tensor with 64 elements (8 * 8). Let me remind you that we fed a tensor of 12 elements to the input of the neural network: 3 candlesticks with 4 elements each.

Next, we will process the signal in a block with the GPT architecture. In it, we will create four sequential neural layers with eight attention heads in each. We have exposed the size of the depth of analyzed data in the external parameters of the script. This will allow us to conduct training with different depths and choose the optimal parameter based on the trade-off between training costs and model performance. The algorithm for creating a description of the neural layer remains the same.

```
//--- GPT layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }
```

```
descr.type = defNeuronGPT;

   descr.count = BarsToLine;

   descr.window = prev_count * prev_window;

   descr.window_out = prev_window;

   descr.step = 8;

   descr.layers = 4;

   descr.activation = AF_NONE;

   descr.optimization = Adam;

   descr.activation_params[0] = 1;
```

```
if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }
```

After the GPT block, we will create a block of fully connected neural layers. All layers in the block will be identical. We included the number of layers and neurons in each into the external parameters of the script. According to the algorithm proposed above, we create a new instance of the neural layer description object and check the result of the operation.

```
//--- Hidden fully connected layers

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }
```

After successfully creating a new object instance, we populate it with the necessary data. As mentioned above, we will take the number of neurons in the layer from the external parameter HiddenLayer. I chose the activation function Swish. Certainly, for greater script flexibility, more parameters can be moved to external settings, and you can conduct multiple training cycles with different parameters to find the best configuration for your model. This approach will require more time and expense for training the model but will allow you to find the most optimal values for the model parameters.

```
descr.type = defNeuronBase;

   descr.count = HiddenLayer;

   descr.activation = AF_SWISH;

   descr.optimization = Adam;

   descr.activation_params[0] = 1;
```

Since we plan to create identical neural layers, we then create a loop with a number of iterations equal to the number of neural layers to be created. In the body of the loop, we will add the created neural layer description to the dynamic array of architecture descriptions for the model being created. And, of course, we check the result of the operations at each iteration of the loop.

```
for(int i = 0; i < HiddenLayers; i++)

     {

      if(!layers.Add(descr))

        {

         PrintFormat("Error adding layer: %d", GetLastError());

         delete descr;

         return false;

        }

     }
```

To complete the model, we will create a results layer. This is a fully connected layer that contains two neurons with the tanh activation function. The choice of this activation function is based on the aggregate assessment of the target values of the trained model:

- The first element of the target value takes 1 for buy targets and −1 for sell targets, which is best configured by the hyperbolic tangent function tanh.

- We trained the models on the EURUSD pair, therefore, the value of the expected movement to the nearest extremum should be in the range from −0.05 to 0.05. In this range of values, the graph of the hyperbolic tangent function tanh is close to linear.

If you plan to use the model on instruments with an absolute value of the expected movement to the nearest extremum of more than 1, you can scale the target result. Then use reverse scaling when interpreting the model signal. You might also consider using a different activation function.

We use the same algorithm to create a description of the neural layer in the architecture of the created model. First, we create a new instance of the neural layer description object and check the result of the operation.

```
//--- Results layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }
```

We then populate the created object with the necessary information: the type of neural layer, the number of neurons, the activation function, and the optimization method for the model parameters.

```
descr.type         = defNeuronBase;

   descr.count        = 2;

   descr.activation   = AF_TANH;

   descr.optimization = Adam;
```

We add a pointer to the populated object to the dynamic array describing the architecture of the model being created and check the operation result.

```
if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }

   return true;

  }
```

We completed the function.

Following in the script algorithm is the LoadTrainingData function that loads the training dataset. In the parameters, the function receives a string variable with the name of the file to load and pointers to two dynamic array objects: data for patterns and result for target values.

```
bool LoadTrainingData(string path, CArrayObj &data, CArrayObj &result)

  {
```

Let me remind you that we will load the training sample without preliminary normalization of the initial data from the file [study_data_not_norm.csv](https://www.mql5.com/en/neurobook/index/realization/create_data#study_files) since we plan to use the model in real-time, and we will use a batch normalization layer to prepare the initial data.

The algorithm for loading the source data will completely repeat what we previously considered while performing the same task in the [GPT](https://www.mql5.com/en/neurobook/index/transformer/gpt/gpt_test) architecture testing script. Lets briefly recap on the process. To load the training dataset, we declare two new variables to store pointers to data buffers, in which we will read patterns and their target values one by one from the file (pattern and target respectively). We will create the object instances later. This is because we will need new object instances to load each pattern. Therefore, we will create objects in the body of the loop before the actual process of loading data from the file.

```
CBufferType *pattern;

   CBufferType *target;
```

After completing the preparatory work, we open the file with the training sample to read the data. When opening a file, among other flags, we specify FILE_SHARE_READ. This flag opens shared access to the file for data reading. That is, by adding this flag, we do not block access to the file from other applications for reading the file. This will allow us to run several scripts in parallel with different parameters, and they will not block each others access to the file. Of course, we can run several scripts in parallel only if the hardware capacity allows it.

```
//--- open the file with the training sample

   int handle = FileOpen(path, FILE_READ | FILE_CSV | FILE_ANSI | FILE_SHARE_READ,

                                                                    ",", CP_UTF8);

   if(handle == INVALID_HANDLE)

     {

      PrintFormat("Error opening study data file: %d", GetLastError());

      return false;

     }
```

Make sure to check the operation result. In case of a file opening error, we inform the user about the error, delete all previously created objects, and exit the program.

After successfully opening the file, we create a loop to read data from the file. The operations in the body of the loop will be repeated until one of the following events occurs:

- The end of the file is reached.

- The user interrupts program execution.

```
//--- show the progress of loading training data in the chart comment

   uint next_comment_time = 0;

   uint OutputTimeout     = 250; // not more often than once every 250 milliseconds

//--- organizing a training dataset loading loop

   while(!FileIsEnding(handle) && !IsStopped())

     {

      if(!(pattern = new CBufferType()))

        {

         PrintFormat("Error creating Pattern data array: %d", GetLastError());

         return false;

        }

      if(!pattern.BufferInit(1, NeuronsToBar * GPT_InputBars))

         return false;
```

In the body of the loop, we first create new instances of objects to record the current pattern and its target values. Again, we immediately check the result of the operation. If an error occurs, we inform the user about the error, delete previously created objects, close the file, and exit the program. It is very important to delete all objects and close the file before exiting the program.

```
if(!(target = new CBufferType()))

        {

         PrintFormat("Error creating Pattern Target array: %d", GetLastError());

         return false;

        }

      if(!target.BufferInit(1, 2))

         return false;
```

After this, we organize a nested loop with the number of iterations equal to the full data pattern. We have created training samples of 40 candlesticks per pattern. Now, we need to sequentially read all the data. However, our model does not require such a large pattern description for training. Therefore, we will skip unnecessary data and will only write the last required data to the buffer.

```
int skip = (HistoryBars - GPT_InputBars) * NeuronsToBar;

      for(int i = 0; i < NeuronsToBar * HistoryBars; i++)

        {

         TYPE temp = (TYPE)FileReadNumber(handle);

         if(i < skip)

            continue;

         pattern.m_mMatrix[0, i - skip] = temp;

        }
```

After loading the current pattern data in full, we organize a similar loop to load target values. This time the number of iterations of the loop will be equal to the number of target values in the training dataset, that is, in our case, two. Before starting the loop, we will check the state of the pattern saving flag. We enter the loop only if the pattern description has been loaded in full.

```
for(int i = 0; i < 2; i++)

         target.m_mMatrix[0, i] = (TYPE)FileReadNumber(handle);
```

After the data loading loops have been executed, we move on to the block in which pattern information is added to our dynamic arrays. We add pointers to objects to the dynamic array of descriptions of patterns and target results. We also check the results of all operations.

```
if(!data.Add(pattern))

        {

         PrintFormat("Error adding study data to array: %d", GetLastError());

         return false;

        }

      if(!result.Add(target))

        {

         PrintFormat("Error adding study data to array: %d", GetLastError());

         return false;

        }
```

After successfully adding to the dynamic arrays, we inform the user about the number of loaded patterns and proceed to load the next pattern.

```
//--- show the loading progress in the chart comment (no more than 1 time every 250 milliseconds)

      if(next_comment_time < GetTickCount())

        {

         Comment(StringFormat("Patterns loaded: %d", data.Total()));

         next_comment_time = GetTickCount() + OutputTimeout;

        }

     }

   FileClose(handle);

   Comment(StringFormat("Patterns loaded: %d", data.Total()));

   return(true);

  }
```

After successfully loading all the data from the training dataset, we close the file and complete the data loading function.

Next, we move on to the procedure for training our model in the NetworkFit function. In its parameters, the function receives pointers to three objects:

- trainable model

- dynamic array of system state descriptions

- dynamic array of target results

```
bool NetworkFit(CNet &net, const CArrayObj &data, const CArrayObj &result, VECTOR &loss_history)

  {
```

In the body of the method, we first do a little preparatory work. We start by preparing local variables.

```
int patterns = data.Total();

   int count = -1;

   TYPE min_loss = FLT_MAX;
```

After completing the preparatory work, we organize nested loops to train our model. The external loop will count the number of updates to the weight matrices, and in the nested loop, we will iterate over the patterns of our training dataset.

Let me remind you that in the GPT architecture, historical data is accumulated in a stack. Therefore, for the model to work correctly, the historical sequence of data input to the model is very important, similar to recurrent models. For this reason, we cannot shuffle the training dataset within a single training batch, and we will feed the model with patterns in chronological order. However, for model training, we can use random batches from the entire training dataset. It is worth noting that when determining the training batch, its size should be increased by the size of the internal accumulation sequence of the GPT block, as maintaining their chronological sequence is necessary for correctly determining dependencies between elements.

Thus, before running the nested loop, we define the boundaries of the current training batch.  

In the body of the nested loop, before proceeding with further operations, we check the flag for the forced termination of the program, and if necessary, we interrupt the function execution.

```
//--- loop through epochs

   for(int epoch = 0; epoch < Epochs; epoch++)

     {

      ulong ticks = GetTickCount64();

      //--- training in batches

      //--- selection of a random pattern

      int k = (int)((double)(MathRand() * MathRand()) / MathPow(32767.0, 2) * (patterns - BarsToLine - 1));

      k = fmax(k, 0);

      for(int i = 0; (i < (BatchSize + BarsToLine) && (k + i) < patterns); i++)

        {

         //--- check if training stopped

         if(IsStopped())

           {

            Print("Network fitting stopped by user");

            return true;

           }
```

First, we perform the feed-forward pass through the model by calling the [net.FeedForward](https://www.mql5.com/en/neurobook/index/realization/basic/neuron_base#feedforward) method. In the parameters of the feed-forward method, we pass a pointer to the object describing the current pattern state and check the result of the operation. If an error occurs during method execution, we inform the user about the error, delete the created objects, and exit the program.

```
if(!net.FeedForward(data.At(k + i)))

           {

            PrintFormat("Error in FeedForward: %d", GetLastError());

            return false;

           }
```

After the successful execution of the feed-forward method, we check the fullness of the buffer of our GPT block. If the buffer is not yet full, move on to the next iteration of the loop.

```
if(i < BarsToLine)

            continue;
```

The backpropagation method [net.Backpropagation](https://www.mql5.com/en/neurobook/index/realization/basic/neuron_base#back_propfgation) is called only after the cumulative sequence of the GPT block is filled. This time, in the parameters of the method, we pass a pointer to the object representing the target values. It is very important to check the result of the operation. If an error occurs, we perform the operations as if there was an error in the direct method.

```
if(!net.Backpropagation(result.At(k + i)))

           {

            PrintFormat("Error in Backpropagation: %d", GetLastError());

            return false;

           }

        }
```

Using the feed-forward and backpropagation methods, we have executed the respective algorithms for training our model. At this stage, the error gradient has already been propagated to each trainable parameter. All that remains is to update the weight matrices. However, we perform this operation not at every training iteration but only after accumulating a batch. In this particular case, we will update the weight matrices after completing the iterations of the nested loop.

```
//--- reconfigure the network weights

      net.UpdateWeights(BatchSize);

      printf("Use OpenCL %s, epoch %d, time %.5f sec", (string)UseOpenCL, epoch, (GetTickCount64() - ticks) / 1000.0);
```

As you have seen in the model testing graphs, the model error dynamics almost never follow a smooth line. Saving the model with minimal error will allow us to save the most appropriate parameters for our model. Therefore, we first check the current model error and compare it to the minimum error achieved during training. If the error has dropped, we save the current model and update the minimum error variable.

```
//--- notify about the past epoch

      TYPE loss = net.GetRecentAverageLoss();

      Comment(StringFormat("Epoch %d, error %.5f", epoch, loss));

      //--- remember the epoch error for saving to a file

      loss_history[epoch] = loss;

      if(loss < min_loss)

         //--- saving the model with minimal error

         if(net.Save(ModelName))

           {

            min_loss = loss;

            count = -1;

           }
```

Additionally, we have introduced the count counter. We will use it to count the number of update iterations from the last minimum error value. If its value exceeds the specified threshold (in the example, it is set to 10 iterations), then we interrupt the training process.

```
if(count >= 10)

         break;

      count++;

     }

   return true;

  }
```

After completing a full training cycle, we will need to save the accumulated dynamics of the model error changes during the training process to a file. To do this, we have created the SaveLossHistory function. In the parameters, the function receives a string variable with the file name for storing the data and a vector of errors during the model training process.

In the function body, we open the file for writing. In this case, we use the file name that the user specified in the parameters. We immediately check the result. If an error occurs when opening the file, we inform the user and exit the function.

```
void SaveLossHistory(string path, const VECTOR &loss_history)

  {

   int handle = FileOpen(OutputFileName, FILE_WRITE | FILE_CSV | FILE_ANSI,

                                                             ",", CP_UTF8);

   if(handle == INVALID_HANDLE)

     {

      PrintFormat("Error creating loss file: %d", GetLastError());

      return;

     }

   for(ulong i = 0; i < loss_history.Size(); i++)

      FileWrite(handle, loss_history[i]);

   FileClose(handle);

   PrintFormat("The dynamics of the error change is saved to a file %s\\MQL5\\Files\\%s",

                                 TerminalInfoString(TERMINAL_DATA_PATH), OutputFileName);

  }
```

If the file was opened successfully, we organize a loop in which we write, one by one, all the values of the model error accumulation vector during training. After completing the full data writing loop, we close the file and inform the user about the location of the file.

With this, our script for creating and training the model is complete, and we can begin training the model on the previously created dataset of non-normalized training data from the file [study_data_not_norm.csv](https://www.mql5.com/en/neurobook/index/realization/create_data#study_files).

The next step is to start the model training process. Here you need to be patient, as the learning process is quite long. Its duration depends on the hardware used. For example, I started training a model with the parameters shown in the screenshot below.

On my Intel Core i7-1165G7 laptop, it takes 35-36 seconds to compute one batch between weight matrix updates. So, full training of the model with 5000 iterations of weight updates will take approximately 2 days of continuous operation. However, if you notice that training has halted and the minimum error hasn't changed for an extended period, you can manually stop the model training. If the achieved performance doesn't meet the requirements, you can continue training the model with different values for the learning rate and batch size for weight updates. The common approach to selecting parameters is as follows:

- The learning rate: training starts with a larger learning rate, and during training, we gradually decrease the learning rate.

- Weight matrix update batch size: training starts with a small batch and gradually increases.

Model training parameters

The techniques mentioned above allow initial fast and rough training of the model followed by finer tuning. If during the model training process, the error consistently increases, it indicates an excessively high learning rate. Using a large batch for weight matrix updates helps to adjust the weight matrices in the most prioritized direction, but it requires more time to perform operations between weight updates. On the other hand, a small batch leads to faster and more chaotic parameter updates, while still maintaining the overall trend. However, when using small batch sizes, it is recommended to decrease the learning rate to reduce model overfitting to specific parts of the training dataset.
