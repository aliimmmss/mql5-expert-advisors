# Developing a multi-currency Expert Advisor (Part 12): Developing prop trading level risk manager

**Source:** [https://www.mql5.com/en/articles/14764](https://www.mql5.com/en/articles/14764)

---

Русский
Deutsch
日本語
Português
Developing a multi-currency Expert Advisor (Part 12): Developing prop trading level risk manager
MetaTrader 5
—
Trading
| 10 October 2024, 11:56
1 439
8
Yuriy Bykov
Introduction
Throughout the entire
series
, we addressed the topic of risk control several times. The concepts of a normalized trading strategy were introduced, the parameters of which ensure that a drawdown level of 10% is achieved during the test period. However, normalizing trading strategy instances, as well as groups of trading strategies, in this way can only provide a given drawdown over a historical period. We cannot be sure that the specified drawdown level will be observed when starting a test of a normalized group of strategies on the forward period, or launching it on a trading account.
Recently, the topic of risk management was considered in the articles
Risk manager for manual trading
and
Risk manager for algorithmic trading
. In these articles, the author proposed a programmatic implementation that controls the compliance of various trading parameters with pre-set indicators. For example, if the set loss level for a day, week or month is exceeded, trading is suspended.
The article
Take a few lessons from Prop Firms
also turned out to be interesting. The author examines the trading requirements imposed by prop trading companies to challenge traders wishing to receive capital for management. Despite the ambiguous attitude towards the activities of such companies, which can be found on various resources dedicated to trading, the use of clear risk management rules is one of the most important components of successful trading. So it would be reasonable to take advantage of the already accumulated experience and implement our own risk manager, using the risk control model used in prop trading companies as a basis.
Model and concepts
For the risk manager, the following concepts will be useful to us:
Base balance
— initial account balance (or part of the account balance) the values of the remaining parameters can be calculated from. Here we will use the value of 10,000.
Daily base balance
— trading account balance at the beginning of the current daily period. For simplicity, we will assume that the beginning of the daily period coincides with the appearance of a new bar in the terminal on the D1 timeframe.
Daily base funds
is the amount of funds in the trading account at the beginning of the current daily period.
Daily level
is the maximum of the daily base balance and funds. It is determined at the beginning of the daily period and retains its value for the beginning of the next daily period.
Maximum daily loss
— the amount of downward deviation of funds on the account from the daily level, at which trading should be stopped on the current daily period. Trading will be resumed on the next daily period. A stop can be understood as various actions aimed at reducing the size of open positions up to complete closure. To begin with, we will use exactly this simple model: when the maximum daily loss is reached, all open market positions will be closed.
Maximum total loss
— downward deviation of funds in the account from the value of the base balance, at which trading stops completely (it will not resume in the following periods). When this level is reached, all open positions are closed.
We will limit ourselves to only two levels for stopping trading: daily and total. A weekly or monthly level can also be added in a similar way. But since prop trading companies do not have them, we will not complicate the first implementation of our risk manager. They can be added later if necessary.
Different prop trading companies may have slightly different approaches to calculating maximum daily and total loss. Therefore, we will provide in our risk manager three possible ways of setting a numerical value for calculating the maximum loss:
Fixed in deposit currency
. Here we directly pass the loss value in the parameter, expressed in units of the trading account currency. We will set it as a positive number.
As a percentage of the base balance
. In this case, the value is perceived as a percentage of the established base balance. Since the base balance in our model is a constant value (until the account and the EA are restarted with a manually set different base balance value), the maximum loss calculated in this way will also be a constant value. It would be possible to reduce this case to the first one, but since it is usually the percentage of maximum loss that is indicated, we will leave it as a separate case.
As a percentage of the daily level
. In this option, at the beginning of each daily period, we recalculate the maximum loss level as a specified percentage of the daily level just calculated. As the balance or funds increase, the size of the maximum loss will also increase. This method will mainly be used to calculate the maximum daily loss only. The maximum total loss is usually fixed relative to the base balance.
Let's begin implementing our risk manager class, as always guided by the least action principle. Let's first make the minimum necessary implementation, laying out the possibility of its further complication if necessary.
CVirtualRiskManager
class
The development of this class went through several stages. At first it was made as a completely static object so that it could be freely used from all objects. Then the idea came up that we could also optimize the risk manager parameters, and it would be nice to be able to save them as an initialization string. For this purpose, the class was made a descendant of the
CFactorable
class. The Singleton pattern was implemented to ensure the ability to use the risk manager in objects of different classes. But then it turned out that the risk manager is needed only in one single class - the
CVirtualAdvisor
EA class. Therefore, we removed the implementation of the Singleton pattern from the risk manager class.
First of all, let's create enumerations for possible risk manager states and possible methods of calculating limits:
// Possible risk manager states
enum
ENUM_RM_STATE {
   RM_STATE_OK,
// Limits are not exceeded
RM_STATE_DAILY_LOSS,
// Daily limit is exceeded
RM_STATE_OVERALL_LOSS
// Overall limit is exceeded
};
// Possible methods for calculating limits
enum
ENUM_RM_CALC_LIMIT {
   RM_CALC_LIMIT_FIXED,
// Fixed (USD)
RM_CALC_LIMIT_FIXED_PERCENT,
// Fixed (% from Base Balance)
RM_CALC_LIMIT_PERCENT
// Relative (% from Daily Level)
};
In the description of the risk manager class, we will have several properties to store the inputs passed through the initialization string to the constructor. We will also add properties for storing various calculation characteristics - current balance, funds, profit, and others. Let's declare some helper methods in the protected section. In the open section, we will essentially only have a constructor and a method for handling each tick. We will only mention the save/load methods and the string conversion operator for now, and write the implementation later.
Then the class description will look something like this:
//+------------------------------------------------------------------+
//| Risk management class (risk manager)                             |
//+------------------------------------------------------------------+
class
CVirtualRiskManager :
public
CFactorable {
protected
:
// Main constructor parameters
bool
m_isActive;
// Is the risk manager active?
double
m_baseBalance;
// Base balance
ENUM_RM_CALC_LIMIT m_calcDailyLossLimit;
// Method of calculating the maximum daily loss
double
m_maxDailyLossLimit;
// Parameter of calculating the maximum daily loss
ENUM_RM_CALC_LIMIT m_calcOverallLossLimit;
// Method of calculating the total daily loss
double
m_maxOverallLossLimit;
// Parameter of calculating the maximum total loss
// Current state
ENUM_RM_STATE     m_state;
// Updated values
double
m_balance;
// Current balance
double
m_equity;
// Current equity
double
m_profit;
// Current profit
double
m_dailyProfit;
// Daily profit
double
m_overallProfit;
// Total profit
double
m_baseDailyBalance;
// Daily basic balance
double
m_baseDailyEquity;
// Daily base balance
double
m_baseDailyLevel;
// Daily base level
double
m_virtualProfit;
// Profit of open virtual positions
// Managing the size of open positions
double
m_prevDepoPart;
// Used part of the total balance
// Protected methods
double
DailyLoss();
// Maximum daily loss
double
OverallLoss();
// Maximum total loss
void
UpdateProfit();
// Update current profit values
void
UpdateBaseLevels();
// Updating daily base levels
void
CheckLimits();
// Check for excess of permissible losses
void
CheckDailyLimit();
// Check for excess of the permissible daily loss
void
CheckOverallLimit();
// Check for excess of the permissible total loss
double
VirtualProfit();
// Determine the real size of the virtual position
public
:
                     CVirtualRiskManager(
string
p_params);
// Constructor
virtual
void
Tick();
// Tick processing in risk manager
virtual
bool
Load(
const
int
f);
// Load status
virtual
bool
Save(
const
int
f);
// Save status
virtual
string
operator
~()
override
;
// Convert object to string
};
The constructor of the risk manager object will expect the initialization string to contain six numeric values, which, after being converted to the appropriate data types, will be assigned to the main properties of the object. Also, when creating, we set the state to normal (the limits are not exceeded). If the object is recreated when the EA is restarted somewhere in the middle of the day, then when loading the saved information, the status should be corrected to what it was at the time of the last save. The same applies to setting the share of the account balance allocated for trading - the value set in the constructor can be predefined when loading saved risk manager information.
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CVirtualRiskManager::CVirtualRiskManager(
string
p_params) {
// Save the initialization string
m_params = p_params;
// Read the initialization string and set the property values
m_isActive = (
bool
) ReadLong(p_params);
   m_baseBalance = ReadDouble(p_params);
   m_calcDailyLossLimit = (ENUM_RM_CALC_LIMIT) ReadLong(p_params);
   m_maxDailyLossLimit = ReadDouble(p_params);
   m_calcOverallLossLimit = (ENUM_RM_CALC_LIMIT) ReadLong(p_params);
   m_maxOverallLossLimit = ReadDouble(p_params);
// Set the state: Limits are not exceeded
m_state = RM_STATE_OK;
// Remember the share of the account balance allocated for trading
m_prevDepoPart = CMoney::DepoPart();
// Update base daily levels
UpdateBaseLevels();
// Adjust the base balance if it is not set
if
(m_baseBalance ==
0
) {
      m_baseBalance = m_balance;
   }
}
The risk manager will perform the main work on each tick in the event handler. This will involve checking the risk manager activity and, if active, updating the current profit values and base daily levels if necessary, as well as checking whether the loss limits have been exceeded:
//+------------------------------------------------------------------+
//| Tick processing in the risk manager                              |
//+------------------------------------------------------------------+
void
CVirtualRiskManager::Tick() {
// If the risk manager is inactive, exit
if
(!m_isActive) {
return
;
   }
// Update the current profit values
UpdateProfit();
// If a new daily period has begun, then we update the base daily levels
if
(IsNewBar(
Symbol
(),
PERIOD_D1
)) {
      UpdateBaseLevels();
   }
// Check for exceeding loss limits
CheckLimits();
}
We would like to note one more point separately. Thanks to the developed structure involving virtual positions, which the recipient of trading volumes turns into real market positions, and a capital management module that allows us to set the required scaling factor between the sizes of virtual and real positions, we can very easily implement a safe closure of market positions that does not violate the trading logic of working strategies. To do this, simply set the scaling factor in the capital management module to 0:
CMoney::DepoPart(
0
);
// Set the used portion of the total balance to 0
If before this we remember the previous ratio in the
m_prevDepoPart
property, then after a new day comes and the daily limit is updated, we can restore previously closed real positions by simply returning this ratio to its previous value:
CMoney::DepoPart(m_prevDepoPart);
// Return the used portion of the total balance
At the same time, of course, we cannot know in advance whether the positions will be reopened at a worse or better price. But we can be sure that adding the risk manager did not affect the performance of all instances of trading strategies.
Now let's move on to looking at the remaining methods of the risk manager class.
In the
UpdateProfits()
method, we update the current values of balance, funds and profit, and calculate the daily profit as the difference between the current funds and the daily level. It should be noted that this value will not always coincide with the current profit. The difference will appear if some trades have already been closed since the beginning of the new daily period. We calculate the total loss as the difference between the current funds and the base balance.
//+------------------------------------------------------------------+
//| Updating current profit values                                   |
//+------------------------------------------------------------------+
void
CVirtualRiskManager::UpdateProfit() {
   m_equity =
AccountInfoDouble
(
ACCOUNT_EQUITY
);
   m_balance =
AccountInfoDouble
(
ACCOUNT_BALANCE
);
   m_profit = m_equity - m_balance;
   m_dailyProfit = m_equity - m_baseDailyLevel;
   m_overallProfit = m_equity - m_baseBalance;
   m_virtualProfit = VirtualProfit();
if
(IsNewBar(
Symbol
(),
PERIOD_H1
) &&
PositionsTotal
() >
0
) {
PrintFormat
(
__FUNCTION__
" | VirtualProfit = %.2f | Profit = %.2f | Daily Profit = %.2f"
,
                  m_virtualProfit, m_profit, m_dailyProfit);
   }
}
In this method, we also calculate the so-called current virtual profit. It is calculated based on open virtual positions. If we leave virtual positions open when the risk manages restrictions are triggered, then even in the absence of real open positions, we can at any time estimate what the approximate profit would be if the real positions closed by the risk manager remained open. Unfortunately, this calculated parameter does not give a completely accurate result (with an error of several percent). However, it is still useful.
The
VirtualProfit()
method calculates the current virtual profit. In this method, we get a pointer to the virtual volume receiver object, since we need to find out the total number of virtual positions from it and have the ability to access each virtual position. Then we loop through all virtual positions and ask our money management module to calculate the virtual profit of each position, scaling it for the current trading funds:
//+------------------------------------------------------------------+
//| Determine the profit of open virtual positions                   |
//+------------------------------------------------------------------+
double
CVirtualRiskManager::VirtualProfit() {
// Access the receiver object
CVirtualReceiver *m_receiver = CVirtualReceiver::Instance();
double
profit =
0
;
// Find the profit sum for all virtual positions
FORI(m_receiver.
OrdersTotal
(), profit += CMoney::Profit(m_receiver.Order(i)));
return
profit;
}
In this method, we have used a new macro
FORI
, which will be discussed below.
When a new daily period begins, we will recalculate the base daily balance, funds and level. We will also check that if the daily loss limit was reached on the previous day, then we need to restore trading and reopen real positions in accordance with the open virtual positions. The
UpdateBaseLevels()
method handles this:
//+------------------------------------------------------------------+
//| Update daily base levels                                         |
//+------------------------------------------------------------------+
void
CVirtualRiskManager::UpdateBaseLevels() {
// Update balance, funds and base daily level
m_baseDailyBalance = m_balance;
   m_baseDailyEquity = m_equity;
   m_baseDailyLevel =
MathMax
(m_baseDailyBalance, m_baseDailyEquity);
PrintFormat
(
__FUNCTION__
" | DAILY UPDATE: Balance = %.2f | Equity = %.2f | Level = %.2f"
,
               m_baseDailyBalance, m_baseDailyEquity, m_baseDailyLevel);
// If the daily loss level was reached earlier, then
if
(m_state == RM_STATE_DAILY_LOSS) {
// Restore the status to normal:
CMoney::DepoPart(m_prevDepoPart);
// Return the used portion of the total balance
m_state = RM_STATE_OK;
// Set the risk manager to normal
CVirtualReceiver::Instance().Changed();
// Notify the recipient about changes
PrintFormat
(
__FUNCTION__
" | VirtualProfit = %.2f | Profit = %.2f | Daily Profit = %.2f"
,
                  m_virtualProfit, m_profit, m_dailyProfit);
PrintFormat
(
__FUNCTION__
" | RESTORE: depoPart = %.2f"
,
                  m_prevDepoPart);
   }
}
To calculate the maximum losses according to the methods specified in the parameters, we will have two methods:
DailyLoss()
and
OverallLoss()
. Their implementation is very similar to each other, the only differences are numerical and method parameters used for the calculation:
//+------------------------------------------------------------------+
//| Maximum daily loss                                               |
//+------------------------------------------------------------------+
double
CVirtualRiskManager::DailyLoss() {
if
(m_calcDailyLossLimit == RM_CALC_LIMIT_FIXED) {
// To get a fixed value, just return it
return
m_maxDailyLossLimit;
   }
else
if
(m_calcDailyLossLimit == RM_CALC_LIMIT_FIXED_PERCENT) {
// To get a given percentage of the base balance, calculate it
return
m_baseBalance * m_maxDailyLossLimit /
100
;
   }
else
{
// if(m_calcDailyLossLimit == RM_CALC_LIMIT_PERCENT)
// To get a specified percentage of the daily level, calculate it
return
m_baseDailyLevel * m_maxDailyLossLimit /
100
;
   }
}
//+------------------------------------------------------------------+
//| Maximum total loss                                               |
//+------------------------------------------------------------------+
double
CVirtualRiskManager::OverallLoss() {
if
(m_calcOverallLossLimit == RM_CALC_LIMIT_FIXED) {
// To get a fixed value, just return it
return
m_maxOverallLossLimit;
   }
else
if
(m_calcOverallLossLimit == RM_CALC_LIMIT_FIXED_PERCENT) {
// To get a given percentage of the base balance, calculate it
return
m_baseBalance * m_maxOverallLossLimit /
100
;
   }
else
{
// if(m_calcDailyLossLimit == RM_CALC_LIMIT_PERCENT)
// To get a specified percentage of the daily level, calculate it
return
m_baseDailyLevel * m_maxOverallLossLimit /
100
;
   }
}
The
CheckLimits()
method of checking the limits simply calls two auxiliary methods to check the daily and total loss:
//+------------------------------------------------------------------+
//| Check loss limits                                                |
//+------------------------------------------------------------------+
void
CVirtualRiskManager::CheckLimits() {
   CheckDailyLimit();
// Check daily limit
CheckOverallLimit();
// Check total limit
}
The daily loss check method uses the
DailyLoss()
method to obtain the maximum allowable daily loss limit and compares it with the current daily profit. When the limit is exceeded, the risk manager is switched to the "Daily limit exceeded" state, and the closure of open positions is initiated by setting the size of the used trading balance equal to 0:
//+------------------------------------------------------------------+
//| Check daily loss limit                                           |
//+------------------------------------------------------------------+
void
CVirtualRiskManager::CheckDailyLimit() {
// If daily loss is reached and positions are still open
if
(m_dailyProfit < -DailyLoss() && CMoney::DepoPart() >
0
) {
// Switch the risk manager to the achieved daily loss state:
m_prevDepoPart = CMoney::DepoPart();
// Save the previous value of the used part of the total balance
CMoney::DepoPart(
0
);
// Set the used portion of the total balance to 0
m_state = RM_STATE_DAILY_LOSS;
// Set the risk manager to the achieved daily loss state
CVirtualReceiver::Instance().Changed();
// Notify the recipient about changes
PrintFormat
(
__FUNCTION__
" | VirtualProfit = %.2f | Profit = %.2f | Daily Profit = %.2f"
,
                  m_virtualProfit, m_profit, m_dailyProfit);
PrintFormat
(
__FUNCTION__
" | RESET: depoPart = %.2f"
,
                  CMoney::DepoPart());
   }
}
The total loss test method works similarly, with the only difference being that it compares the total profit to the total acceptable loss. If the total limit is exceeded, the risk manager is switched to the "Total limit exceeded" state.
Save the obtained code in the
VirtualRiskManager.mqh
file of the current folder.
Let's now look at the changes and additions we will need to make to the previously created project files in order to be able to use our new risk manager class.
Useful macros
I have added a new macro
FORI(N, D)
to the list of useful macros for working with arrays. It arranges a loop with the
i
variable, which performs
N
times the
D
expression:
// Useful macros for array operations
#ifndef
__MACROS_INCLUDE__
#define
APPEND(A, V)    A[
ArrayResize
(A,
ArraySize
(A) +
1
) -
1
] = V;
#define
FIND(A, V, I)   {
for
(I=
ArraySize
(A)-
1
;I>=
0
;I--) {
if
(A[I]==V)
break
; } }
#define
ADD(A, V)       {
int
i; FIND(A, V, i)
if
(i==-
1
) { APPEND(A, V) } }
#define
FOREACH(A, D)   {
for
(
int
i=
0
, im=
ArraySize
(A);i<im;i++) {D;} }
#define
FORI(N, D)      {
for
(
int
i=
0
; i<N;i++) {D;} }
#define
REMOVE_AT(A, I) {
int
s=
ArraySize
(A);
for
(
int
i=I;i<s-
1
;i++) { A[i]=A[i+
1
]; }
ArrayResize
(A, s-
1
);}
#define
REMOVE(A, V)    {
int
i; FIND(A, V, i)
if
(i>=
0
) REMOVE_AT(A, i) }
#define
__MACROS_INCLUDE__
#endif
Save the changes in the
Macros.mqh
file of the current folder.
СMoney
money management class
In this class, we will add a method for calculating the profit of a virtual position taking into account the scaling factor of its volume. Actually, we perform a similar operation in the
Volume()
method to determine the calculated size of a virtual position: based on information about the current available balance size for trading, and the balance size corresponding to the volume of the virtual position, we find a scaling factor equal to the ratio of these balances. This factor is then multiplied by the virtual position volume to obtain the calculated volume, i.e. the one that will be opened in the trading account.
Therefore, let us first take out of the
Volume()
method the part of the code that finds the scaling factor into a separate
Coeff()
method:
//+------------------------------------------------------------------+
//| Calculate the virtual position volume scaling factor             |
//+------------------------------------------------------------------+
double
CMoney::Coeff(CVirtualOrder *p_order) {
// Request the normalized strategy balance for the virtual position
double
fittedBalance = p_order.FittedBalance();
// If it is 0, then the scaling factor is 1
if
(fittedBalance ==
0.0
) {
return
1
;
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
// Return the volume scaling factor
return
totalBalance * s_depoPart / fittedBalance;
}
After this, the implementation of the
Volume()
and
Profit()
methods becomes very similar: we take the desired value (volume or profit) from the virtual position and multiply it by the resulting scaling factor:
//+------------------------------------------------------------------+
//| Determine the calculated size of the virtual position            |
//+------------------------------------------------------------------+
double
CMoney::Volume(CVirtualOrder *p_order) {
return
p_order.Volume() * Coeff(p_order);
}
//+------------------------------------------------------------------+
//| Determining the calculated profit of a virtual position          |
//+------------------------------------------------------------------+
double
CMoney::Profit(CVirtualOrder *p_order) {
return
p_order.Profit() * Coeff(p_order);
}
Of course, we need to add new methods to the class description:
//+------------------------------------------------------------------+
//| Basic money management class                                     |
//+------------------------------------------------------------------+
class
CMoney {
   ...
// Calculate the scaling factor of the virtual position volume
static
double
Coeff(CVirtualOrder *p_order);
public
:
   CMoney() =
delete
;
// Disable the constructor
// Determine the calculated size of the virtual position
static
double
Volume(CVirtualOrder *p_order);
// Determine the calculated profit of a virtual position
static
double
Profit(CVirtualOrder *p_order);  

   ...
};
Save the changes made to the
Money.mqh
file in the current folder.
СVirtualFactory
class
Since the risk manager class we created is a descendant of the
CFactorable
class, then to ensure the possibility of its creation it is necessary to expand the composition of objects created by
CVirtualFactory
. Inside the
Create()
static method, add a code block responsible for creating an object of the
CVirtualRiskManager
class:
//+------------------------------------------------------------------+
//| Object factory class                                             |
//+------------------------------------------------------------------+
class
CVirtualFactory {
public
:
// Create an object from the initialization string
static
CFactorable* Create(
string
p_params) {
// Read the object class name
string
className = CFactorable::ReadClassName(p_params);
// Pointer to the object being created
CFactorable*
object
= NULL;
// Call the corresponding constructor  depending on the class name
if
(className ==
"CVirtualAdvisor"
) {
object
=
new
CVirtualAdvisor(p_params);
      }
else
if
(
className ==
"CVirtualRiskManager"
) {
object
=
new
CVirtualRiskManager(p_params);
}
else
if
(className ==
"CVirtualStrategyGroup"
) {
object
=
new
CVirtualStrategyGroup(p_params);
      }
else
if
(className ==
"CSimpleVolumesStrategy"
) {
object
=
new
CSimpleVolumesStrategy(p_params);
      }
      
      ...
return
object
;
   }
};
Save the obtained code in the
VirtualFactory.mqh
file of the current folder.
CVirtualAdvisor
class
We will need to make more significant changes to the
CVirtualAdvisor
EA class. Since we have decided that the risk manager object will be used only within this class, we will add the corresponding property to the class description:
//+------------------------------------------------------------------+
//| Class of the EA handling virtual positions (orders)              |
//+------------------------------------------------------------------+
class
CVirtualAdvisor :
public
CAdvisor {
protected
:
   CVirtualReceiver     *m_receiver;
// Receiver object that brings positions to the market
CVirtualInterface    *m_interface;
// Interface object to show the status to the user
CVirtualRiskManager  *m_riskManager
;
// Risk manager object
...
};
Let's also agree that the risk manager initialization string will be embedded into the EA initialization string immediately after the strategy group initialization string. Also, let's add reading this initialization string into the
riskManagerParams
variable in the constructor and the subsequent creation of the risk manager from it:
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CVirtualAdvisor::CVirtualAdvisor(
string
p_params) {
// Save the initialization string
m_params = p_params;
// Read the initialization string of the strategy group object
string
groupParams = ReadObject(p_params);
// Read the initialization string of the risk manager object
string
riskManagerParams = ReadObject(p_params)
;
// Read the magic number
ulong
p_magic = ReadLong(p_params);
// Read the EA name
string
p_name = ReadString(p_params);
// Read the work flag only at the bar opening
m_useOnlyNewBar = (
bool
) ReadLong(p_params);
// If there are no read errors,
if
(IsValid()) {
      ...
// Create the risk manager object
m_riskManager = NEW(riskManagerParams)
;
   }
}
Since we have created an object in the constructor, we should also take care of deleting it in the destructor:
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
void
CVirtualAdvisor::~CVirtualAdvisor() {
if
(!!m_receiver)
delete
m_receiver;
// Remove the recipient
if
(!!m_interface)
delete
m_interface;
// Remove the interface
if
(!!m_riskManager)
delete
m_riskManager
;
// Remove risk manager
DestroyNewBar();
// Remove the new bar tracking objects
}
The most important thing is calling the
Tick()
handler for the risk manager from the relevant EA handler. Please note that the risk manager handler is launched before adjusting market volumes, so that if the loss limits are exceeded, or, conversely, the limits are updated, then the recipient can adjust the open volumes of market positions when handling the same tick:
//+------------------------------------------------------------------+
//| OnTick event handler                                             |
//+------------------------------------------------------------------+
void
CVirtualAdvisor::Tick(
void
) {
// Define a new bar for all required symbols and timeframes
bool
isNewBar = UpdateNewBar();
// If there is no new bar anywhere, and we only work on new bars, then exit
if
(!isNewBar && m_useOnlyNewBar) {
return
;
   }
// Receiver handles virtual positions
m_receiver.Tick();
// Start handling in strategies
CAdvisor::Tick();
// Risk manager handles virtual positions
m_riskManager.Tick()
;
// Adjusting market volumes
m_receiver.Correct();
// Save status
Save();
// Render the interface
m_interface.Redraw();
}
Save the changes made to the
VirtualAdvisor.mqh
file in the current folder.
SimpleVolumesExpertSingle
EA
To test the risk manager, all that remains is to add the ability to specify its parameters in the EA and generate the required initialization string. For now, let's move all six parameters of the risk manager into separate EA inputs:
input
group
"===  Risk management"
input
bool
rmIsActive_             =
true
;
input
double
rmStartBaseBalance_     =
10000
;
input
ENUM_RM_CALC_LIMIT
                  rmCalcDailyLossLimit_   = RM_CALC_LIMIT_FIXED;
input
double
rmMaxDailyLossLimit_    =
200
;
input
ENUM_RM_CALC_LIMIT
                  rmCalcOverallLossLimit_ = RM_CALC_LIMIT_FIXED;
input
double
rmMaxOverallLossLimit_  =
500
;
In the
OnInit()
function, it is necessary to add the creation of the risk manager initialization string and embedding it into the EA initialization string. At the same time, we will slightly rewrite the code for creating initialization strings for a strategy and a group that includes this one strategy, separating the initialization strings of individual objects into different variables:
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int
OnInit
() {
   CMoney::FixedBalance(fixedBalance_);
   CMoney::DepoPart(
1.0
);
// Prepare the initialization string for a single strategy instance
string
strategyParams =
StringFormat
(
"class CSimpleVolumesStrategy(\"%s\",%d,%d,%.2f,%.2f,%d,%.2f,%.2f,%d,%d)"
,
Symbol
(),
Period
(),
                              signalPeriod_, signalDeviation_, signaAddlDeviation_,
                              openDistance_, stopLevel_, takeLevel_, ordersExpiration_,
                              maxCountOfOrders_
                           );
// Prepare the initialization string for a group with one strategy instance
string
groupParams =
StringFormat
(
"class CVirtualStrategyGroup(\n"
"       [\n"
"        %s\n"
"       ],%f\n"
"    )"
,
                           strategyParams, scale_
                        );
// Prepare the initialization string for the risk manager
string
riskManagerParams =
StringFormat
(
"class CVirtualRiskManager(\n"
"       %d,%.2f,%d,%.2f,%d,%.2f"
"    )"
,
                                 rmIsActive_, rmStartBaseBalance_,
                                 rmCalcDailyLossLimit_, rmMaxDailyLossLimit_,
                                 rmCalcOverallLossLimit_, rmMaxOverallLossLimit_
                              );
// Prepare the initialization string for an EA with a group of a single strategy and the risk manager
string
expertParams =
StringFormat
(
"class CVirtualAdvisor(\n"
"    %s,\n"
"    %s,\n"
"    %d,%s,%d\n"
")"
,
                            groupParams,
                            riskManagerParams,
                            magic_,
"SimpleVolumesSingle"
,
true
);
PrintFormat
(
__FUNCTION__
" | Expert Params:\n%s"
, expertParams);
// Create an EA handling virtual positions
expert = NEW(expertParams);
if
(!expert)
return
INIT_FAILED
;
return
(
INIT_SUCCEEDED
);
}
Save the obtained code in the
SimpleVolumesExpertSingle.mq5
file of the current folder. Now everything is ready to test the risk manager operation.
Test
Let's use the parameters of one of the trading strategy instances obtained during the optimization at the previous stages of development. We will call this instance of a trading strategy a model strategy. The model strategy parameters are shown in Fig. 1.
Fig. 1. Model strategy parameters
Let's run a single tester pass with these parameters and the risk manager turned off for the period of 2021-2022. We get the following results:
Fig. 2. Model strategy results without the risk manager
The graph shows that there were several noticeable drawdowns in funds over the selected time period. The largest of them occurred at the end of October 2021 (~USD 380) and in June 2022 (~USD 840).
Now let's turn on the risk manager and set the maximum daily loss limit equal to USD 150, and the maximum total loss equal to USD 450. We get the following results:
Fig. 3. Model strategy results without the risk manager (max losses: USD 150 and USD 450)
The graph shows that in October 2021, the risk manager closed loss-making market positions twice, but virtual positions remained open. Therefore, when the next day arrived, market positions were opened again. Unfortunately, the reopening took place at a less favorable price, so the total drawdown by the balance and funds slightly exceeded the drawdown by equity in case of the disabled risk manager. It is also clear that after closing the positions, the strategy, instead of receiving a small profit (as is the case without the risk manager), received some loss.
In June 2022, the risk manager has already been triggered seven times, closing market positions upon reaching a daily loss of USD 150. Again, it turned out that the reopening took place at less favorable prices, and as a result of this series of transactions, a loss was incurred. But if such an EA worked on a demo account of a prop trading company with such parameters of maximum daily and total losses, then without the risk manager the account would be stopped for violating the trading rules, and with a risk manager the account would continue to work, receiving a slightly smaller profit as a result.
Even though I set the total loss to USD 450, and in June the total balance drawdown exceeded USD 1000, the total maximum loss was not reached, since it is calculated from the base balance. In other words, it is achieved if the funds fall below (10,000 - 450) = USD 9550. But due to the previously accumulated profit, the amount of funds during that period definitely did not fall below USD 10,000. Therefore, the EA continued its work, accompanied by the opening of market positions.
Let's now simulate the triggering of reaching a total loss. To do this, we will increase the scaling factor of position sizes so that in October 2021 the total maximum loss would not yet be exceeded, and in June 2022 the exceeding would occur. Let's set scale_ = 50 and look at the result:
Fig. 4. Model strategy results without the risk manager (max losses: USD 150 and USD 450), scale_ = 50
As we can see, trading ends in June 2022. In the subsequent period, the EA did not open a single position. This happened due to reaching the total loss limit (USD 9550). It can also be noted that the daily loss was now reached more often occurring not only in October 2021, but also during several other periods.
So both of our limiters are working correctly.
The risk manager can be useful even outside of prop trading companies. As an illustration, let's try to optimize the parameters of the risk manager of our model strategy, trying to increase the size of the positions opened, but without going beyond the permissible drawdown of 10%. To do this, in the risk manager parameters we will set the maximum total loss equal to 10% of the daily level. We will also go through the maximum daily loss, also calculated as a percentage of the daily level, during the optimization.
Fig. 5. Results of the model strategy optimization with the risk manager
The results show that the standardized profit for one year increased almost one and a half times when using the risk manager: from USD 1560 to USD 2276 (Result column). Here is what the best pass looks like when shown separately:
Fig. 6. Model strategy results without the risk manager (max losses: 7.6% and 10%, scale_ = 88)
Note that the EA continued to open trades throughout the entire test period. This means that the overall limit of 10% was never violated. Clearly, there is no particular point in applying a risk manager to individual instances of trading strategies, since we do not plan to launch them on a real account one by one. However, what works for one instance should work similarly for an EA with many instances. Therefore, even such cursory results allow us to say that the risk manager can definitely be useful.
Conclusion
So, we now have a basic implementation of a risk manager for trading that allows us to adhere to the specified levels of maximum daily and total losses. It does not yet support saving and loading the status when restarting the EA, so I do not recommend using it on a real account. But this modification does not present any particular difficulties. I will return to it later.
At the same time, it will be possible to try adding the ability to limit trading by various time periods, ranging from disabling trading at certain hours of certain days of the week, to prohibiting opening new positions during important economic news releases. Other possible areas for the risk manager development are a smoother change in the size of positions (for example, a two-fold reduction when half the limit is exceeded), and a more "intelligent" restoration of volumes (for example, only when the loss exceeds a position reduction level).
I will postpone this for later. For now, I will get back to automating the EA optimization. The first stage has already been implemented in the previous
article
. It is time to move on to the second stage.
Thank you for your attention! See you soon!
Translated from Russian by MetaQuotes Ltd.
Original article:
https://www.mql5.com/ru/articles/14764
Attached files
|
Download ZIP
VirtualRiskManager.mqh
(24.7 KB)
Macros.mqh
(2.4 KB)
Money.mqh
(6.52 KB)
VirtualFactory.mqh
(4.46 KB)
VirtualAdvisor.mqh
(23.02 KB)
SimpleVolumesExpertSingle.mq5
(14.09 KB)
Warning:
All rights to these materials are reserved by MetaQuotes Ltd. Copying or reprinting of these materials in whole or in part is prohibited.
Other articles by this author
Developing a multi-currency Expert Advisor (Part 11): Automating the optimization (first steps)
Developing a multi-currency Expert Advisor (Part 10): Creating objects from a string
Developing a multi-currency Expert Advisor (Part 9): Collecting optimization results for single trading strategy instances
Developing a multi-currency Expert Advisor (Part 8): Load testing and handling a new bar
Developing a multi-currency Expert Advisor (Part 7): Selecting a group based on forward period
Developing a multi-currency Expert Advisor (Part 6): Automating the selection of an instance group
Last comments |
Go to discussion
(8)
Yuriy Bykov
|
29 May 2024 at 07:33
Thanks for the feedback!
Правильно я понимаю, что при контроле рисков в методе DailyLoss() не учитывается риск просадки по еквити?
Probably wrong. The
DailyLoss()
method does not evaluate how big the drawdown was. It only converts the specified maximum drawdown level to the account currency from per cent if necessary. The comparison itself takes place in the
CheckDailyLimit()
method:
if
(
m_dailyProfit < -DailyLoss()
&& CMoney::DepoPart() >
0
) { ... }
The value of
m_dailyProfit
is updated on
each tick
and is calculated as the difference of the current funds (equity) and the daily level
(the maximum of the balance value and the funds
at the beginning of the daily period):
m_dailyProfit = m_equity - m_baseDailyLevel;
So it seems that the drawdown on funds is just taken into account. Or did I misunderstand the question?
Why do you use macros when working with arrays?
For compactness of the code. Macros also allow you to pass a code block as a parameter, while when implementing such operations through functions, you cannot pass a code block to functions as a parameter.
Aleksandr Seredin
|
29 May 2024 at 19:12
Yuriy Bykov each tick and is calculated as the difference between the current funds (equity) and the daily level
(the maximum of the balance and funds
at the beginning of the daily period):
So it seems that the drawdown on funds is just taken into account. Or did I misunderstand the question?
For code compactness. Also, macros allow passing a code block as a parameter, while when implementing such operations through functions, you cannot pass a code block to functions as a parameter.
Thank you very much for your extended answer )) We will wait for new articles! )
pensaval
|
19 Oct 2024 at 19:28
Dear Yuriy,
I'm trying to compile the code but I get the following error in VirtualRiskManager.mqh:
"Changed - undeclared identifier" on line  CVirtualReceiver::Instance().Changed(); // Notify the recipient about changes
I've checked the code multiple times but no way. Can you explain me what I'm missing?
I'm looking forward to the next article of this serie.
Thanks
Yuriy Bykov
|
21 Oct 2024 at 16:52
Hello!
I apologise, I forgot to attach at least one more file to which edits were made. Starting with Part 16, a complete archive of the
project
files is attached to each article. I will attach it here for this article.
pensaval
|
21 Oct 2024 at 20:08
Yuriy Bykov
#
:
Hello!
I apologise, I forgot to attach at least one more file to which edits were made. Starting with Part 16, a complete archive of the
project
files is attached to each article. I will attach it here for this article.
Many Thanks
Creating an MQL5 Expert Advisor Based on the PIRANHA Strategy by Utilizing Bollinger Bands
In this article, we create an Expert Advisor (EA) in MQL5 based on the PIRANHA strategy, utilizing Bollinger Bands to enhance trading effectiveness. We discuss the key principles of the strategy, the coding implementation, and methods for testing and optimization. This knowledge will enable you to deploy the EA in your trading scenarios effectively
Header in the Connexus (Part 3): Mastering the Use of HTTP Headers for Requests
We continue developing the Connexus library. In this chapter, we explore the concept of headers in the HTTP protocol, explaining what they are, what they are for, and how to use them in requests. We cover the main headers used in communications with APIs, and show practical examples of how to configure them in the library.
Ordinal Encoding for Nominal Variables
In this article, we discuss and demonstrate how to convert nominal predictors into numerical formats that are suitable for machine learning algorithms, using both Python and MQL5.
Reimagining Classic Strategies (Part IX): Multiple Time Frame Analysis (II)
In today's discussion, we examine the strategy of multiple time-frame analysis to learn on which time frame our AI model performs best. Our analysis leads us to conclude that the Monthly and Hourly time-frames produce models with relatively low error rates on the EURUSD pair. We used this to our advantage and created a trading algorithm that makes AI predictions on the Monthly time frame, and executes its trades on the Hourly time frame.
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