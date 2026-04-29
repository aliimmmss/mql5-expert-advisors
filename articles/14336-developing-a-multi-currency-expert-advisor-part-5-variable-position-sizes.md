# Developing a multi-currency Expert Advisor (Part 5): Variable position sizes

**Source:** [https://www.mql5.com/en/articles/14336](https://www.mql5.com/en/articles/14336)

---

Русский
Português
Developing a multi-currency Expert Advisor (Part 5): Variable position sizes
MetaTrader 5
—
Tester
| 30 July 2024, 16:24
1 628
2
Yuriy Bykov
Introduction
In the previous
part
, we dded the ability to restore the EA's state after a restart. It does not matter what the reason was - rebooting the terminal, changing the timeframe on the chart with the EA, launching a more recent version of the EA - in all cases, restoring the state allowed the EA not to start working from scratch and not to lose already open positions, but to continue handling them.
However, the size of the opened positions remained the same for each instance of the strategy throughout the entire testing period. Their size was set at the EA launch. If, as a result of the EA's operation, the trading account balance increased, then this would allow the use of an increased position size without increasing risk. It would be reasonable to take advantage of this, so let’s start implementing the use of variable position sizes.
Concepts
First of all, we need to agree on the concepts based on a common goal - achieving optimal collaboration between multiple instances of trading strategies.
Fixed strategy size
(
Fixed Lot
) — a certain size used to calculate the sizes of all open positions in a trading strategy. In the simplest case, all opened positions can have a size equal to this value. When using any tricks to increase or decrease the size of the second and subsequent opened positions in a series, a fixed size can set the size of the first position in the series, and subsequent ones are calculated based on it and the number of already open positions. This is not considered a very good technique.
Normalized strategy balance
(
Fitted Balance
) — initial balance, at which the drawdown during the entire testing period reaches, but does not exceed, 10% of the initial balance for the selected
fixed strategy size
. Why exactly 10%? This number is not yet a very large drawdown, which psychologically seems acceptable and turns out to be more convenient for quick rough mental calculations. In general, we can take any value - 1%, 5% or even 50%. This is nothing more than a normalization parameter.
Normalized trading strategy
— a trading strategy, for which a
fixed strategy size
and
normalized strategy balance
were selected. Therefore, when launching such a strategy on the selected testing period, we should get a maximum drawdown value of approximately 10% of the
normalized strategy balance.
Having a trading strategy, we can turn it into a
normalized trading strategy
by performing the following actions:
Select a
fixed strategy size
, for example, 0.01.
Select the testing period (start and end date)
Launch the strategy on the selected testing period with a large initial balance and look at the value of the maximum absolute drawdown by equity.
Find the value of the
normalized strategy balance
multiplying the maximum absolute drawdown by equity by 10.
Let us consider the following example. Suppose that we get a maximum absolute drawdown of USD 440 for the fixed strategy size of 0.01. If we want this value to be exactly 10% of the initial balance, we can divide USD 440 by 0.10 or multiply by 10 (which is the same thing):
USD 440 / 0.10 = USD 440 * 10 = USD 4400
We set these two values (0.01 and 4400) in the parameters for creating a trading strategy instance and get a normalized trading strategy.
Now, for a normalized trading strategy, we can calculate the size of open positions for any balance value while maintaining the maximum relative drawdown by equity equal to 10%. To do this, it is sufficient to change the size of the opened positions in proportion to the ratio of the current total balance (
Total Balance
) and normalized balance (
Fitted Balance
).
CurrentLot = FixedLot * (TotalBalance / FittedBalance)
For example, for the values of 0.01 and 4400 used in the above example, with a balance value of USD 10,000, the size of open positions should be calculated based on the base value:
CurrentLot
= 0.01 * (10,000 / 4400) = 0.0227
It will not be possible to open exactly this size. We will have to round it to 0.02, so the drawdown in this case may be slightly less than 10% on the test. If we round up (to 0.03), then the drawdown may be slightly more than 10%. As the balance increases, rounding errors will decrease.
If we have introduced the concept of a fixed position size for a strategy, then we can entrust any options for managing the size of the strategy positions to the strategy itself. Therefore, we only need to implement three possible options for a money management strategy at the level of the EA that combines various instances of trading strategies:
Fixed size
or the absence of a money management strategy. The fixed size specified in the strategy is applied regardless of the trading account balance. The strategy will be used when testing a separate instance of the strategy to determine the normalized strategy balance.
Constant size for a specified fixed balance
. At the start, the size proportional to the fixed balance for the strategy is calculated based on the strategy normalized balance and fixed size. This size is used throughout the testing period. This strategy will be used to check the uniformity (linearity) of the funds growth curve throughout the entire testing period, subject to the stated maximum absolute drawdown.
Variable size for the current balance
. For each position opening, the size is determined in proportion to the current account balance based on the strategy normalized balance and fixed size. The strategy will be used for real work providing the expected value of the maximum relative drawdown.
Let's provide examples of using these three options. Let's take the EA with one copy of the strategy, set a large starting balance of USD 100,000 and start testing for the period of 2018-2022 with the fixed size of open positions of 0.01 lots. We get the following results:
Fig. 1. Results with the fixed size and the balance of USD 100,000
As we can see, during this testing period there was a maximum absolute drawdown in equity of about USD 153, which amounted to approximately 0.15% of the account balance. More precisely, it is more correct for us to evaluate the relative drawdown regarding the initial account balance. But since the difference between the initial and final balance is small (about 1% of the initial balance), a drawdown of 0.15% will, with good accuracy, amount to the absolute value of USD 150 at whatever point in the test period it occurs.
Let's calculate what size of the initial balance can be set so that the maximum absolute drawdown is 10% of the initial balance:
FittedBalance
=
MaxDrawdown
/ 10% = 153 / 0.10 = 153 * 10 = USD 1530
Let's check our calculations:
Fig. 2. Results with the fixed size and the balance of USD 1530
We can see that the absolute drawdown in equity amounted to the same value of USD 153, but the relative drawdown was not 10%, but only 7.2%. This is normal, since it only means that the largest drawdown occurred when the account balance had already grown somewhat from its initial value, and the value of USD 153 was already less than 10% of the current balance.
Now let's check the second option - a constant size for a given fixed balance. Set a large initial balance of USD 100,000, while allowing to use, say, only the tenth of it, that is, USD 10,000. This is the
Current Balance
value, which remains the same throughout the entire testing period. Under these conditions, the size of the opened positions should be:
CurrentBalance = TotalBalance * 0.1 = 10,000
CurrentLot = FixedLot *  (CurrentBalance / FittedBalance) = 0.01 * (10,000 / 1530) = 0.0653
During operation, this value will be rounded to a multiple of the lot change step. We get the following results:
Fig. 3. Results with the fixed size for the fixed balance of USD 10,000 out of the available USD 100,000
As you can see, the absolute drawdown was USD 1016, which with sufficient accuracy is 10% of the USD 10,000 allocated to this strategy. However, this amounted to only 1% relative to the entire balance.
Finally, let's look at the third option - variable size for the current balance. Set the initial balance equal to USD 10,000 and allow it to be used in full. Here is what happens:
Fig. 4. Results with the variable size for the current balance
Here we see that the maximum absolute drawdown already exceeds 10% of the initial balance, but the relative drawdown continues to remain within the acceptable 10%. We have obtained a normalized trading strategy, for which the value of
Fitted Balance
= 1530, and now we can easily calculate the sizes of open positions to ensure a given drawdown of 10%.
Position size calculation
When considering the following money management options, the following observations can be made:
If we are talking about one copy of the strategy, then could options with a variable lot be useful? Looks like they could not. We only need to use the first option. We can use the second and third ones a couple of times to demonstrate performance, but then we will not need them.
If we are working with an EA that already combines several instances of trading strategies, can trading with a fixed lot be useful? Looks like it cannot. In this case, the second option may be useful to us at the testing stage, and the third one will be the main one used.
This allows us to come to the following conclusion: virtual orders always have a fixed size calculated from the
fixed strategy size
parameter. In the strategies discussed here, it is enough to use the minimum lot as a fixed size, which for most instruments is equal to 0.01.
Based on the workflow, it turns out that the recipient object or symbolic recipients will have to be recalculated into the real position open size. To do this, they will have to receive the value of the normalized balance, which ensures a drawdown of 10% of this balance, from the strategy, or more precisely, from a virtual order.
But what if we want to provide a smaller or larger drawdown? To do this, it is sufficient to change the size of the opened positions in one way or another in proportion to how many times we want to change the expected maximum drawdown compared to the value of 10%.
One of these methods is the explicit introduction of a weighting multiplier, showing what part of the current account balance can be used by the EA.
Allocated balance
(
Current Balance
) is a part of the total account balance allocated to this EA for trading.
Balance multiplier
(
Depo Part
) — ratio of the allocated strategy balance to the total account balance.
DepoPart =  CurrentBalance / TotalBalance
Then the initial position size can be calculated as follows:
CurrentLot = FixedLot * (CurrentBalance / FittedBalance)
CurrentLot =  FixedLot * (DepoPart * TotalBalance / FittedBalance)
Here we can make an important remark, which will be very useful for our implementation. If we recalculate the
normalized balance
after creating a strategy instance, the total balance will be used in the position size calculation equation instead of the current strategy balance:
FittedBalance = FittedBalance / DepoPart
CurrentLot =  FixedLot * (TotalBalance / FittedBalance)
We will perform the recalculation of the normalized balance once when initializing the EA. We will not need the
Depo Part
multiplier after that.
Combining multiple strategies
The previous discussions were made for the case of using one instance of a strategy in an EA. Let's now think about what we need to do case we want to take several standardized strategies and combine them in one EA that allows a drawdown of no more than 10% (or another value specified in advance) during the entire testing period. For now, we will consider the specified drawdown value of exactly 10%.
If we focus on the worst case that can happen when combining strategies, then this is the event of simultaneous achievement of the maximum drawdown of 10% by all strategy instances. In this case, we will have to reduce the position size of each strategy in proportion to the number of instances. For example, if we combine three copies of a strategy, then we need to reduce the size of positions by three times.
This can be achieved by reducing the balance allocated to the strategy by a given number of times, or increasing the normalized balance of strategies by a given number of times. We will use the second option.
If we denote the number of strategies in a group via
StrategiesCount
, then the equation for recalculating the normalized balance looks as follows:
FittedBalance = StrategiesCount * FittedBalance
However, the likelihood of such a worst case is very much reduced as the number of strategy instances increases, if they are selected so that they are as dissimilar from each other as possible. In this case, drawdowns occur at different times, and not simultaneously. This can be seen during the test. Then we can introduce another scaling factor (
Scale
), which will be equal to one by default, but if desired, it can be made larger in order to increase the size of positions by reducing the normalized balance of strategies:
FittedBalance = StrategiesCount * FittedBalance
FittedBalance = FittedBalance / Scale
Due to the selection of the
Scale
multiplier, we can again ensure that a group of strategies provides a specified drawdown throughout the entire testing period. In this case, we will obtain a normalized group of strategies.
Normalized group of strategies
— a group of normalized trading strategies, for which a scaling factor has been selected that ensures a maximum drawdown of no more than 10% when the group works together.
Then, if we have made several normalized groups of strategies, then they can all be combined again into a new normalized group according to the same principle used when combining normalized strategies. In other words, we should choose a multiplier for the group of groups, so that the maximum drawdown is no more than 10% when all strategies from all groups work simultaneously. This unification process can be continued to any number of levels. In this case, the initial normalized balance of each strategy will simply be multiplied by the number of strategies or groups in the group at each level of association and divided by the scaling factors of each level:
FittedBalance = StrategiesCount1 * FittedBalance
FittedBalance = StrategiesCount2 * FittedBalance
...
FittedBalance = FittedBalance / Scale1
FittedBalance = FittedBalance / Scale2
...
Then the final equation for recalculating the normalized balance of each strategy will look like this:
FittedBalance = (StrategiesCount1 *
StrategiesCount1
* ... ) * FittedBalance / (Scale1 * Scale2 * ... )
Finally, apply the last scaling
Depo Part
multiplier in the position size calculation equation for the possible transformation of the normalized group of strategies, which is at the highest level of the combination, into a group with a different specified drawdown instead of 10%:
CurrentLot =  FixedLot * (DepoPart * TotalBalance / FittedBalance)
There are two new classes for implementation. The first class
CVirtualStrategyGroup
will be responsible for recalculating the normalized balances of strategies when combining them into groups. The second class
CMoney
will be responsible for calculating the actual opening volumes based on the strategy fixed size, normalized balance and the allocated balance.
Trading strategy group class
This class will be used to create objects that represent either a group of strategies or a group of strategy groups. In both cases, when creating a group, a scaling factor will be applied via calling the single
Scale()
method.
//+------------------------------------------------------------------+
//| Class of trading strategies group(s)                             |
//+------------------------------------------------------------------+
class
CVirtualStrategyGroup {
protected
:
void
Scale(
double
p_scale);
// Scale normalized balance
public
:
   CVirtualStrategyGroup(CVirtualStrategy *&p_strategies[],
double
p_scale =
1
);
// Constructor for a group of strategies
CVirtualStrategyGroup(CVirtualStrategyGroup *&p_groups[],
double
p_scale =
1
);
// Constructor for a group of strategy groups
CVirtualStrategy      *m_strategies[];
// Array of strategies
CVirtualStrategyGroup *m_groups[];
// Array of strategy groups
};
The constructors will take a scaling factor as parameters and either an array of pointers to strategies or an array of pointers to strategy groups. The resulting array is copied to the corresponding property of the created object, and the Scale() method is applied to each array element. We will need to add this method to the strategy class for strategy objects.
//+------------------------------------------------------------------+
//| Constructor for strategy groups                                  |
//+------------------------------------------------------------------+
CVirtualStrategyGroup::CVirtualStrategyGroup(
   CVirtualStrategy *&p_strategies[],
double
p_scale
) {
ArrayCopy
(m_strategies, p_strategies);
   Scale(p_scale /
ArraySize
(m_strategies));
}
//+------------------------------------------------------------------+
//| Constructor for a group of strategy groups                       |
//+------------------------------------------------------------------+
CVirtualStrategyGroup::CVirtualStrategyGroup(
   CVirtualStrategyGroup *&p_groups[],
double
p_scale
) {
ArrayCopy
(m_groups, p_groups);
   Scale(p_scale /
ArraySize
(m_groups));
}
//+------------------------------------------------------------------+
//| Scale normalized balance                                         |
//+------------------------------------------------------------------+
void
CVirtualStrategyGroup::Scale(
double
p_scale) {
   FOREACH(m_groups,     m_groups[i].Scale(p_scale));
   FOREACH(m_strategies, m_strategies[i].Scale(p_scale));
}
Save the code in the
VirtualStrategyGroup.mqh
file of the current folder.
Let's make the necessary additions to the virtual strategy class. We will need to add two new class properties to store the strategy normalized balance and fixed size. Since they should be installed, a previously unnecessary constructor is needed now. The
FittedBalance()
public method will simply return the value of the strategy normalized balance, while the
Scale()
method will scale it by a specified multiplier.
//+------------------------------------------------------------------+
//| Class of a trading strategy with virtual positions               |
//+------------------------------------------------------------------+
class
CVirtualStrategy :
public
CStrategy {
protected
:
   ...
double
m_fittedBalance;
// Strategy normalized balance
double
m_fixedLot;
// Strategy fixed size
...
public
:
   CVirtualStrategy(
double
p_fittedBalance =
0
,
double
p_fixedLot =
0.01
);
// Constructor
...
double
FittedBalance() {
// Strategy normalized balance
return
m_fittedBalance;
   }
void
Scale(
double
p_scale) {
// Scale normalized balance
m_fittedBalance /= p_scale;
   }
};
Save this code in the
VirtualStrategy.mqh
file of the current folder.
Also, we need to make minor changes in the
CSimpleVolumesStrategy
class. We should implement an additional parameter to the constructor for the strategy normalized balance and remove the parameter for setting the sizes of virtual positions. It will now always be the same and equal to the minimum lot of 0.01.
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSimpleVolumesStrategy::CSimpleVolumesStrategy(
string
p_symbol,
ENUM_TIMEFRAMES
p_timeframe,
int
p_signalPeriod,
double
p_signalDeviation,
double
p_signaAddlDeviation,
int
p_openDistance,
double
p_stopLevel,
double
p_takeLevel,
int
p_ordersExpiration,
int
p_maxCountOfOrders,
double
p_fittedBalance =
0
) :
// Initialization list
CVirtualStrategy(p_fittedBalance,
0.01
)
,
   m_symbol(p_symbol),
   m_timeframe(p_timeframe),
   m_signalPeriod(p_signalPeriod),
   m_signalDeviation(p_signalDeviation),
   m_signaAddlDeviation(p_signaAddlDeviation),
   m_openDistance(p_openDistance),
   m_stopLevel(p_stopLevel),
   m_takeLevel(p_takeLevel),
   m_ordersExpiration(p_ordersExpiration),
   m_maxCountOfOrders(p_maxCountOfOrders) {
   ...
}
Save the changes in the
SimpleVolumesStrategy.mqh
file of the current folder.
We need the ability to add a group of strategies, i.e. the instances of our new
CVirtualStrategyGroup
class, to the EA object. So, let's implement the overloaded
Add()
method to the EA class, which will do exactly that:
//+------------------------------------------------------------------+
//| Class of the EA handling virtual positions (orders)              |
//+------------------------------------------------------------------+
class
CVirtualAdvisor :
public
CAdvisor {
   ...
public
:
   ...
virtual
void
Add(CVirtualStrategyGroup &p_group);
// Method for adding a group of strategies
...
};
//+------------------------------------------------------------------+
//| Method for adding a group of strategies                          |
//+------------------------------------------------------------------+
void
CVirtualAdvisor::Add(CVirtualStrategyGroup &p_group) {
   FOREACH(p_group.m_groups, {
      CVirtualAdvisor::Add(p_group.m_groups[i]);
delete
p_group.m_groups[i];
   });
   FOREACH(p_group.m_strategies, CAdvisor::Add(p_group.m_strategies[i]));
}
Since strategy groups are no longer needed after being added to the EA, we immediately remove them from the dynamic memory area in this method. Save the changes made to the
VirtualAdvisor.mqh
file in the current folder.
Money management class
This class will be responsible for determining the actual size for virtual positions according to the three possible money management strategy options.
The class object should be unique. So we can either use the
Singleton
design pattern for it, or, as was eventually implemented, the class can contain only static fields and methods accessible to any objects.
The main method in this class is the method for determining the real size for the
Volume()
virtual position (order). Two more methods allow us to set the values of two parameters that determine what part of the trading account balance is involved in trading.
//+------------------------------------------------------------------+
//| Basic money management class                                     |
//+------------------------------------------------------------------+
class
CMoney {
static
double
s_depoPart;
// Used part of the total balance
static
double
s_fixedBalance;
// Total balance used
public
:
   CMoney() =
delete
;
// Disable the constructor
static
double
Volume(CVirtualOrder *p_order);
// Determine the real size of the virtual position
static
void
DepoPart(
double
p_depoPart) {
      s_depoPart = p_depoPart;
   }
static
void
FixedBalance(
double
p_fixedBalance) {
      s_fixedBalance = p_fixedBalance;
   }
};
double
CMoney::s_depoPart =
1.0
;
double
CMoney::s_fixedBalance =
0
;
//+------------------------------------------------------------------+
//| Determine the real size of the virtual position                  |
//+------------------------------------------------------------------+
double
CMoney::Volume(CVirtualOrder *p_order) {
// Request the normalized strategy balance for the virtual position
double
fittedBalance = p_order.FittedBalance();
// If it is 0, then the real volume is equal to the virtual one
if
(fittedBalance ==
0.0
) {
return
p_order.Volume();
   }
// Otherwise, find the value of the total balance for trading
double
totalBalance = s_fixedBalance >
0
? s_fixedBalance :
AccountInfoDouble
(
ACCOUNT_BALANCE
);
// Return the calculated real volume based on the virtual one
return
p_order.Volume() * totalBalance * s_depoPart / fittedBalance ;
}
//+------------------------------------------------------------------+
Save this code in the
Money.mqh
file of the current folder.
Test EAs
Let's make changes to the EA files for testing. In the
SimpleVolumesExpertSingle.mq5
file, we just need to remove the position size parameter from the list of parameters of the strategy constructor in the EA initialization function:
int
OnInit
() {
// Create an EA handling virtual positions
expert =
new
CVirtualAdvisor(magic_,
"SimpleVolumesSingle"
);

   expert.Add(
new
CSimpleVolumesStrategy(
                 symbol_, timeframe_,
fixedLot_,
signalPeriod_, signalDeviation_, signaAddlDeviation_,
                 openDistance_, stopLevel_, takeLevel_, ordersExpiration_,
                 maxCountOfOrders_)
             );
// Add one strategy instance
return
(
INIT_SUCCEEDED
);
}
We will not use the EA to search for new good combinations of parameters for individual strategy instances now, since we will use the combinations found earlier. But if necessary, the EA will be ready for an optimization.
Let's make more significant additions to the
SimpleVolumesExpert.mq5
file. We mainly need them to demonstrate the capabilities of the added classes, so we should not consider this as final code.
First of all, we will create an enumeration to represent different ways of grouping instances of trading strategies:
enum
ENUM_VA_GROUP {
   VAG_EURGBP,
// Only EURGBP (3 items)
VAG_EURUSD,
// Only EURUSD (3 items)
VAG_GBPUSD,
// Only GBPUSD (3 items)
VAG_EURGBPUSD_9,
// EUR-GBP-USD (9 items)
VAG_EURGBPUSD_3_3_3
// EUR-GBP-USD (3+3+3 items)
};
The first three values will correspond to the use of three copies of trading strategies for one of the symbols (EURGBP, EURUSD or GBPUSD). The fourth value will correspond to the use of one group of all nine strategy instances. The fifth value will correspond to the use of a group of three normalized groups, which will include three copies of trading strategies for a specific symbol.
Let's expand the list of input parameters a bit:
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input
group
"::: Strategy groups"
input
ENUM_VA_GROUP group_ = VAG_EURGBP;
// - Strategy group
input
group
"::: Money management"
input
double
expectedDrawdown_ =
10
;
// - Maximum risk (%)
input
double
fixedBalance_ =
0
;
// - Used deposit (0 - use all) in the account currency
input
double
scale_ =
1.0
;
// - Group scaling multiplier
input
group
"::: Other parameters"
input
ulong
magic_        =
27183
;
// - Magic
In the EA initialization function, set the money management parameters taking into account the normalization of the maximum allowable drawdown of 10%, create nine copies of strategies, arrange them in accordance with the selected grouping and add them to the EA:
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int
OnInit
() {
// Set parameters in the money management class
CMoney::DepoPart(expectedDrawdown_ /
10.0
);
   CMoney::FixedBalance(fixedBalance_);
// Create an EA handling virtual positions
expert =
new
CVirtualAdvisor(magic_,
"SimpleVolumes_"
+
EnumToString
(group_));
// Create and fill the array of all strategy instances
CVirtualStrategy *strategies[] = {
new
CSimpleVolumesStrategy(
"EURGBP"
,
PERIOD_H1
,
13
,
0.3
,
1.0
,
0
,
10500
,
465
,
1000
,
3
,
1600
),
new
CSimpleVolumesStrategy(
"EURGBP"
,
PERIOD_H1
,
17
,
1.7
,
0.5
,
0
,
16500
,
220
,
1000
,
3
,
900
),
new
CSimpleVolumesStrategy(
"EURGBP"
,
PERIOD_H1
,
51
,
0.5
,
1.1
,
0
,
19500
,
370
,
22000
,
3
,
1600
),
new
CSimpleVolumesStrategy(
"EURUSD"
,
PERIOD_H1
,
24
,
0.1
,
0.3
,
0
,
7500
,
2400
,
24000
,
3
,
2300
),
new
CSimpleVolumesStrategy(
"EURUSD"
,
PERIOD_H1
,
18
,
0.2
,
0.4
,
0
,
19500
,
1480
,
6000
,
3
,
2000
),
new
CSimpleVolumesStrategy(
"EURUSD"
,
PERIOD_H1
,
128
,
0.7
,
0.3
,
0
,
3000
,
170
,
42000
,
3
,
2200
),
new
CSimpleVolumesStrategy(
"GBPUSD"
,
PERIOD_H1
,
80
,
1.1
,
0.2
,
0
,
6000
,
1190
,
1000
,
3
,
2500
),
new
CSimpleVolumesStrategy(
"GBPUSD"
,
PERIOD_H1
,
128
,
2.0
,
0.9
,
0
,
2000
,
1170
,
1000
,
3
,
900
),
new
CSimpleVolumesStrategy(
"GBPUSD"
,
PERIOD_H1
,
13
,
1.5
,
0.8
,
0
,
2500
,
1375
,
1000
,
3
,
1400
),
   };
// Create arrays of pointers to strategies, one symbol at a time, from the available strategies
CVirtualStrategy *strategiesEG[] = {strategies[
0
], strategies[
1
], strategies[
2
]};
   CVirtualStrategy *strategiesEU[] = {strategies[
3
], strategies[
4
], strategies[
5
]};
   CVirtualStrategy *strategiesGU[] = {strategies[
6
], strategies[
7
], strategies[
8
]};
// Create and add selected groups of strategies to the EA
switch
(group_) {
case
VAG_EURGBP: {
      expert.Add(CVirtualStrategyGroup(strategiesEG, scale_));
      FOREACH(strategiesEU,
delete
strategiesEU[i]);
      FOREACH(strategiesGU,
delete
strategiesGU[i]);
break
;
   }
case
VAG_EURUSD: {
      expert.Add(CVirtualStrategyGroup(strategiesEU, scale_));
      FOREACH(strategiesEG,
delete
strategiesEG[i]);
      FOREACH(strategiesGU,
delete
strategiesGU[i]);
break
;
   }
case
VAG_GBPUSD: {
      expert.Add(CVirtualStrategyGroup(strategiesGU, scale_));
      FOREACH(strategiesEU,
delete
strategiesEU[i]);
      FOREACH(strategiesEG,
delete
strategiesEG[i]);
break
;
   }
case
VAG_EURGBPUSD_9: {
      expert.Add(CVirtualStrategyGroup(strategies, scale_));
break
;
   }
case
VAG_EURGBPUSD_3_3_3: {
// Create a group of three strategy groups
CVirtualStrategyGroup *groups[] = {
new
CVirtualStrategyGroup(strategiesEG,
1.25
),
new
CVirtualStrategyGroup(strategiesEU,
2.24
),
new
CVirtualStrategyGroup(strategiesGU,
2.64
)
      };

      expert.Add(CVirtualStrategyGroup(groups, scale_));
break
;
   }
default
:
return
(
INIT_FAILED
);
   }
// Load the previous state if available
expert.Load();
return
(
INIT_SUCCEEDED
);
}
Save the changes made to the
SimpleVolumesExpert.mq5
file in the current folder.
Test
Let's test the first group - three copies of the strategy working on the EURGBP symbol. We get the following results:
Fig. 5. Results for EURGBP with three strategies, Scale=1
As we can see, when combined, the maximum relative drawdown was 8% instead of 10% for each individual instance of the normalized strategy. This means we can increase our position size a little. To achieve the drawdown of 10%, we will set Scale = 10% / 8% = 1.25.
Fig. 6. Results for EURGBP with three strategies, Scale=1.25
Now the drawdown is approximately 10%. Let's perform a similar operation to select a scaling multiplier for the second and third groups. We get the following results:
Fig. 7. Results for EURUSD with three strategies, Scale=2.24
Fig. 8. Results for GBPUSD with three strategies, Scale=2.64
We use the selected values of scaling multipliers in the code to create a normalized group of three normalized groups of strategies:
// Create a group of three strategy groups
CVirtualStrategyGroup *groups[] = {
new
CVirtualStrategyGroup(strategiesEG,
1.25
),
new
CVirtualStrategyGroup(strategiesEU,
2.24
),
new
CVirtualStrategyGroup(strategiesGU,
2.64
)
 };
Now let's select a scaling multiplier for the fourth group. If we combine all 9 instances into one group, we get the following results:
Fig. 9. Results for EURGBP, EURUSD, GBPUSD (9 strategies in total), Scale=1
This allows us to raise the scaling factor to 3.3 and remain within 10% of the relative drawdown:
Fig. 10. Results for EURGBP, EURUSD and GBPUSD (9 strategies in total), Scale=3.3
Finally, the most interesting thing. Let's combine the same 9 normalized strategies, but in a different way: separately normalize groups of three strategies for individual symbols and then combine the resulting three normalized groups into a group. We get the following:
Fig. 11. Results for EURGBP, EURUSD and GBPUSD (3 + 3 + 3 strategies), Scale=1
The final balance has turned out to be greater than for the fourth group with the same Scale=1, but the drawdown has also been greater: 4.57% instead of 3%. Let’s bring the fifth group to the drawdown of 10% and then compare the final result:
Fig. 12. Results for EURGBP, EURUSD, GBPUSD (3 + 3 + 3 strategies), Scale=2.18
Now it is clear that the fifth option for grouping strategies gives much better results while maintaining the maximum relative drawdown within 10%. During the selected testing period, the profit more than doubled compared to the fourth grouping option.
Finally, let’s look at the linearity of the balance growth for the fifth grouping option. This will allow us to assess whether there are any internal periods, in which the EA performs noticeably worse than in other internal periods throughout the testing period. To do this, set the value of the parameter
FixedBalance
= 10,000, so that the EA always uses only this amount of the account balance to calculate position sizes.
Fig. 13. Results for EURGBP, EURUSD, GBPUSD (3 + 3 + 3 strategies), FixedBalance = 10000, Scale=2.18
On the test graph, I marked the internal periods, during which the balance growth was near zero, with green rectangles. Their duration ranges from one to six months. Well, that means there is something to strive for. The easiest way to cope with such periods is more diversification: use more instances of trading strategies that work on different symbols and timeframes.
The maximum drawdown in terms of equity was USD 995 in absolute terms, that is, just about 10% of the USD 10,000 balance used for trading. This confirms that the implemented money management system behaves correctly.
Conclusion
Now we can run our EA on trading accounts with different initial balance values and control how the balance will be distributed for different instances of trading strategies. Some will get more, and they will open larger positions. Others will get less, and their position sizes will be smaller. Generally, with the help of tests, we can select parameters that will comply with the pre-selected maximum allowable drawdown.
It is worth noting that we can only see whether the drawdown is adhered to through tests. We cannot guarantee whether adherence is maintained when the EA is launched on a period not used for optimization. It can change both upwards and (oddly enough) downwards. Therefore, here everyone should make an independent decision about how much they can trust and how to use the results obtained during the tests.
I will continue developing the project. Thank you for reading!
Translated from Russian by MetaQuotes Ltd.
Original article:
https://www.mql5.com/ru/articles/14336
Attached files
|
Download ZIP
Advisor.mqh
(4.3 KB)
Interface.mqh
(3.21 KB)
Macros.mqh
(2.28 KB)
Money.mqh
(4.46 KB)
Receiver.mqh
(1.79 KB)
SimpleVolumesExpert.mq5
(11.68 KB)
SimpleVolumesExpertSingle.mq5
(7.27 KB)
SimpleVolumesStrategy.mqh
(30.11 KB)
Strategy.mqh
(1.73 KB)
VirtualAdvisor.mqh
(13.47 KB)
VirtualChartOrder.mqh
(10.83 KB)
VirtualInterface.mqh
(8.41 KB)
VirtualOrder.mqh
(38.66 KB)
VirtualReceiver.mqh
(17.43 KB)
VirtualStrategy.mqh
(9.1 KB)
VirtualStrategyGroup.mqh
(6.1 KB)
VirtualSymbolReceiver.mqh
(34.04 KB)
Warning:
All rights to these materials are reserved by MetaQuotes Ltd. Copying or reprinting of these materials in whole or in part is prohibited.
Other articles by this author
Developing a multi-currency Expert Advisor (Part 6): Automating the selection of an instance group
Developing a multi-currency Expert Advisor (Part 4): Pending virtual orders and saving status
Developing a multi-currency Expert Advisor (Part 3): Architecture revision
Developing a multi-currency Expert Advisor (Part 2): Transition to virtual positions of trading strategies
Developing a multi-currency Expert Advisor (Part 1): Collaboration of several trading strategies
Last comments |
Go to discussion
(2)
Nigel Philip J Stephens
|
1 Aug 2024 at 08:38
MetaQuotes
:
Check out the new article:
Developing a multi-currency Expert Advisor (Part 5): Variable position sizes
.
Author:
Yuriy Bykov
When I run the EA SimpleVolumesExpert with (3+3+3) and scaling 2.18, The log shows virtual trades opened but no real trades in strategy tester. Have I missed something?
Yuriy Bykov
|
1 Aug 2024 at 10:20
Nigel Philip J Stephens
#
:
When I run SimpleVolumesExpert with (3+3+3) and scaling 2.18, the log shows open virtual trades, but no real trades in the strategy tester. Maybe I missed something?
Check that the initial balance in the tester is $10000 or more. I have this behaviour when the balance is not big enough. In this case, not every virtual position generates a real position. But the reason is probably something else, as your balance is probably correct.
Are there any real trades if the EA is run with other variants of strategy grouping?
Reimagining Classic Strategies: Forecasting Higher Highs And Lower Lows
In this series article, we will empirically analyze classic trading strategies to see if we can improve them using AI. In today's discussion, we tried to predict higher highs and lower lows using the Linear Discriminant Analysis model.
From Novice to Expert: The Essential Journey Through MQL5 Trading
Unlock your potential! You're surrounded by opportunities. Discover 3 top secrets to kickstart your MQL5 journey or take it to the next level. Let's dive into discussion of tips and tricks for beginners and pros alike.
Role of random number generator quality in the efficiency of optimization algorithms
In this article, we will look at the Mersenne Twister random number generator and compare it with the standard one in MQL5. We will also find out the influence of the random number generator quality on the results of optimization algorithms.
Creating a Dynamic Multi-Symbol, Multi-Period Relative Strength Indicator (RSI) Indicator Dashboard in MQL5
In this article, we develop a dynamic multi-symbol, multi-period RSI indicator dashboard in MQL5, providing traders real-time RSI values across various symbols and timeframes. The dashboard features interactive buttons, real-time updates, and color-coded indicators to help traders make informed decisions.
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