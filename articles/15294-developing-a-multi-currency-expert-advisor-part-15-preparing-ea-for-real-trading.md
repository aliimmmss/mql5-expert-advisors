# Developing a multi-currency Expert Advisor (Part 15): Preparing EA for real trading

**Source:** [https://www.mql5.com/en/articles/15294](https://www.mql5.com/en/articles/15294)

---

Русский
Español
Português
Developing a multi-currency Expert Advisor (Part 15): Preparing EA for real trading
MetaTrader 5
—
Tester
| 16 January 2025, 13:07
622
2
Yuriy Bykov
Introduction
We have already achieved certain results in the previous
articles
, but there is still much to do. The end result we would like to see is a multi-currency EA that can be set to work on a real account or several real accounts with different brokers. So far, our efforts have been focused on achieving good trading results during testing, since without this it is impossible to achieve good trading with a developed EA on a real account. Now that we have more or less decent test results, we can look a little towards ensuring correct operation on a real account.
We have already partially touched upon this aspect of the EA's development. In particular, the development of a risk manager
was a step towards ensuring compliance with requirements that may arise during the actual trading process. A risk manager is not needed to test trading ideas, as it is an important, but auxiliary tool.
Within the framework of this article, we will try to provide other important mechanisms, without which it is not advisable to start trading on real accounts. Since these will be things that should handle situations that do not occur when running the EA in the strategy tester, then we will most likely have to develop additional EAs to debug them and check the validity of their operation.
Mapping out the path
There are quite a few nuances that require consideration and attention when trading on real accounts. Let's focus for now on a few of them, which are listed below:
Substitution of symbols
. We performed optimization and formed the initialization strings of EAs using very specific names of trading instruments (symbols). But it may happen that on a real account the names of trading instruments differ from those we used. Possible differences may include, for example, suffixes or prefixes in names (EURGBP.x or xEURGBP instead of EURGBP), or using a different case (eurgbp instead of EURGBP). In the future, the list of trading symbols might be expanded to include those whose differences in names will be even more significant. Therefore, it is necessary to be able to set rules for substituting names of trading instruments so that the EA is able to work on the symbols that a specific broker uses.
Trading completion mode
. Since we plan to periodically update the composition and settings of trading strategy instances that work simultaneously inside the EA, it is desirable to provide the ability to switch an already working EA to a special mode, in which it will work "only for closing", that is, it will strive to complete trading by closing (preferably with a total profit) all open positions. This may take some time if we decide to stop trading with this EA when incurring losses on open positions.
Recovering after a restart
. This means the ability of the EA to continue its work after the terminal is rebooted, which can be caused by various reasons. It is impossible to insure against some of these causes. However, the EA should not just continue to work, but it should do so exactly as the EA would have worked if there had been no reboot. Therefore, it is necessary to ensure that the EA saves all the necessary information during operation, which will allow it to restore its state after a restart.
Let's start implementing our plans.
Substitution of symbols
Let's start with the simplest thing
— the ability to set rules for substituting names of trading symbols in the EA settings. Typically, the differences will be in the presence of additional suffixes and/or prefixes. Therefore, at first glance, we can add two new parameters for setting suffixes and prefixes to the inputs.
However, this method is less flexible, since it implies the ability to use only a fixed algorithm for obtaining the correct symbol name from the original names taken from the initialization string. Besides, converting to lower case will require one more parameter. Therefore, we will implement another method.
We will add one parameter to the EA, which will contain a string like this:
<Symbol1>=<TargetSymbol1>;<Symbol2>=<TargetSymbol2>;...<SymbolN>=<TargetSymbolN>
Here
<Symbol[i]>
stands for the original names of trading symbols used in the initialization string, while
<TargetSymbol[i]>
stands for target names of the trading symbols that will be used for real trading. For example:
EURGBP=EURGBPx;
EURUSD=EURUSDx;
GBPUSD=GBPUSDx
We will pass the value of this parameter to a special method of the EA object (
CVirtualAdvisor
class), which will perform all necessary further actions. If an empty string is passed to this method, no changes to the names of trading symbols are required.
Let's call this method
SymbolsReplace
and add calling it to the EA initialization function code:
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
...
input
string
symbolsReplace_   =
""
;
// - Symbol replacement rules
datetime
fromDate =
TimeCurrent
();


CVirtualAdvisor     *expert;
// EA object
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int
OnInit
() {
   ...
// Create an EA handling virtual positions
expert = NEW(expertParams);
// If the EA is not created, then return an error
if
(!expert)
return
INIT_FAILED
;
// If an error occurred while replacing symbols, then return an error
if
(!expert.SymbolsReplace(symbolsReplace_))
return
INIT_FAILED
;
// Successful initialization
return
(
INIT_SUCCEEDED
);
}
Save the changes made to the
SimpleVolumesExpert.mq5
file in the current folder.
Let's add a description of the EA method that performs the substitution of symbol names to the EA class and its implementation. Inside this method, we will parse the passed replacement string into its component parts, separating it first by semicolon ';' and then by equal sign '='. From the obtained parts we will form a glossary that links the names of a source symbol with the name of a target symbol. We will then pass the glossary to each instance of the trading strategy in turn, so that they can perform the necessary substitution if their symbols are present as keys in this glossary.
At each step where an error might occur, we update the result variable so that the upstream function can know if the symbol name substitutions failed. In this case, the EA reports an initialization failure.
//+------------------------------------------------------------------+
//| Class of the EA handling virtual positions (orders)              |
//+------------------------------------------------------------------+
class
CVirtualAdvisor :
public
CAdvisor {
protected
:
   ...
public
:
   ...
bool
SymbolsReplace(
const
string
p_symbolsReplace);
// Replace symbol names
};

...
//+------------------------------------------------------------------+
//| Replace symbol names                                             |
//+------------------------------------------------------------------+
bool
CVirtualAdvisor::SymbolsReplace(
string
p_symbolsReplace) {
// If the replacement string is empty, then do nothing
if
(p_symbolsReplace ==
""
) {
return
true
;
   }
// Variable for the result
bool
res =
true
;
string
symbolKeyValuePairs[];
// Array for individual replacements
string
symbolPair[];
// Array for two names in one replacement
// Split the replacement string into parts representing one separate replacement
StringSplit
(p_symbolsReplace,
';'
, symbolKeyValuePairs);
// Glossary for mapping target symbol to source symbol
CHashMap<
string
,
string
> symbolsMap;
// For all individual replacements
FOREACH(symbolKeyValuePairs, {
// Get the source and target symbols as two array elements
StringSplit
(symbolKeyValuePairs[i],
'='
, symbolPair);
// Check if the target symbol is in the list of available non-custom symbols
bool
custom =
false
;
      res &=
SymbolExist
(symbolPair[
1
], custom);
// If the target symbol is not found, then report an error and exit
if
(!res) {
PrintFormat
(
__FUNCTION__
" | ERROR: Target symbol %s for mapping %s not found"
, symbolPair[
1
], symbolKeyValuePairs[i]);
return
res;
      }
// Add a new element to the glossary: key is the source symbol, while value is the target symbol
res &= symbolsMap.Add(symbolPair[
0
], symbolPair[
1
]);
   });
// If no errors occurred, then for all strategies we call the corresponding replacement method
if
(res) {
      FOREACH(m_strategies, res &= ((CVirtualStrategy*) m_strategies[i]).SymbolsReplace(symbolsMap));
   }
return
res;
}
//+------------------------------------------------------------------+
Save the changes in the
VirtualAdvisor.mqh
file in the current folder.
We will add a method of the same name to the trading strategy class, but it will no longer accept a string with substitutions as an argument, accepting the glossary of substitutions instead. Unfortunately, we are unable to add its implementation in the
CVirtualStrategy
class, since we still know nothing about the used trading symbols at the class level. So let's make it virtual, moving the responsibility for implementation to a lower level
—
to child classes.
//+------------------------------------------------------------------+
//| Class of a trading strategy with virtual positions               |
//+------------------------------------------------------------------+
class
CVirtualStrategy :
public
CStrategy {
   ...
public
:
   ...
// Replace symbol names
virtual
bool
SymbolsReplace(CHashMap<
string
,
string
> &p_symbolsMap) {
return
true
;
   }
};
Save the changes in the
VirtualStrategy
.mqh
file in the current folder.
We only have one child class so far, and it has the
m_symbol
property, which stores the name of the trading symbol. Let's add the
SymbolsReplace()
method, which will simply check if the passed glossary contains a key, that matches the name of the current trading symbol, and change the trading instrument if necessary:
//+------------------------------------------------------------------+
//| Trading strategy using tick volumes                              |
//+------------------------------------------------------------------+
class
CSimpleVolumesStrategy :
public
CVirtualStrategy {
protected
:
string
m_symbol;
// Symbol (trading instrument)
...
public
:
   ...
// Replace symbol names
virtual
bool
SymbolsReplace(CHashMap<
string
,
string
> &p_symbolsMap);
};

...
//+------------------------------------------------------------------+
//| Replace symbol names                                             |
//+------------------------------------------------------------------+
bool
CSimpleVolumesStrategy::SymbolsReplace(CHashMap<
string
,
string
> &p_symbolsMap) {
// If there is a key in the glossary that matches the current symbol
if
(p_symbolsMap.ContainsKey(m_symbol)) {
string
targetSymbol;
// Target symbol
// If the target symbol for the current one is successfully retrieved from the glossary
if
(p_symbolsMap.TryGetValue(m_symbol, targetSymbol)) {
// Update the current symbol
m_symbol = targetSymbol;
      }
   }
return
true
;
}
Save the changes in the
SimpleVoumesStrategy
.mqh
file in the current folder.
This completes the edits related to this subtask. The tester check showed that the EA successfully starts trading on new symbols, in accordance with the substitution rules. It is worth noting that since we use the
CHashMap::Add()
method to fill the substitution glossary, then an attempt to add a new element (target symbol) with an already existing key (source symbol) results in an error.
This means that if we specify the substitution rule for the same symbol twice in the substitution string, the EA will not pass initialization. It will be necessary to adjust the substitution string, excluding the repetition of substitution rules for the same trading symbols from it.
Trading completion mode
The next scheduled task is adding the ability to set a special mode of EA operation
—
trading completion. First, we need to agree on what we mean by this. Since we plan to enable this mode only when we want to launch a new EA with different parameters instead of the one already running, then, on the one hand, we are interested in closing all positions opened by the old EA as soon as possible. On the other hand, we would not want to close positions if the floating profit on them is currently negative. In this case, it might be better to wait a while until the EA comes out of the drawdown.
Therefore, we formulate the problem as follows: when the trading completion mode is enabled, the EA should close all positions and not open new ones as soon as the floating profit is non-negative. If the profit is non-negative at the moment this mode is turned on, then we will not have to wait at all
—
the EA closes all positions immediately. If not, then we will have to wait.
The next question is how long we have to wait. Looking at the results of historical testing, we can observe drawdowns that lasted for several months. Therefore, if we simply wait, then if the timing of the trading completion mode launch is unsuccessful, waiting may drag on for quite a long time. Perhaps, it would be more profitable to close all positions of the old version without waiting for profit, that is, to accept the current losses. This would allow the new version to be put into operation more quickly, which, while waiting for the old version to go into profit, could possibly generate a profit that would cover the accepted losses incurred
when stopping the old version
.
However, we cannot know in advance either the time of the old version exiting the drawdown, or the potential profit of the new version during this period, since at the moment of decision-making these results are located in the future.
One possible compromise in this situation could be to introduce some maximum waiting time, after which all positions of the old version are forcibly closed at any current drawdown. We can come up with more complex options. For example, we can use this time limit as a parameter of a linear or non-linear function of time that returns the funds, at which we are currently willing to close all positions. In the simplest case, this will be a threshold function that returns 0 before this time limit. After that, it will return a value less than the current funds in the account. This will result in a guaranteed closure of all positions after the specified time.
Let's proceed with the implementation. The first option was to add two inputs (enable close mode and limit time in days) to the EA file and then use them in the initialization function further on:
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
...
input
bool
useOnlyCloseMode_ =
false
;
// - Enable close mode
input
double
onlyCloseDays_    =
0
;
// - Maximum time of closing mode (days)
...
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int
OnInit
() {
   ...
// Prepare the initialization string for an EA with a group of several strategies
string
expertParams =
StringFormat
(
"class CVirtualAdvisor(\n"
"    class CVirtualStrategyGroup(\n"
"       [\n"
"        %s\n"
"       ],%f\n"
"    ),\n"
"    class CVirtualRiskManager(\n"
"       %d,%.2f,%d,%.2f,%.2f,%d,%.2f,%.2f,%d,%.2f,%.2f,%.2f"
"    )\n"
"    ,%d,%s,%d\n"
"    ,%d,%.2f\n"
")"
,
                            strategiesParams, scale_,
                            rmIsActive_, rmStartBaseBalance_,
                            rmCalcDailyLossLimit_, rmMaxDailyLossLimit_, rmCloseDailyPart_,
                            rmCalcOverallLossLimit_, rmMaxOverallLossLimit_, rmCloseOverallPart_,
                            rmCalcOverallProfitLimit_, rmMaxOverallProfitLimit_,
                            rmMaxRestoreTime_, rmLastVirtualProfitFactor_,
                            magic_,
"SimpleVolumes"
, useOnlyNewBars_,
useOnlyCloseMode_, onlyCloseDays_
);
// Create an EA handling virtual positions
expert = NEW(expertParams);

   ...
// Successful initialization
return
(
INIT_SUCCEEDED
);
}
However, as we progressed, it became clear that we would have to write the code that was very similar to what we had been doing just recently. As it turned out, the required behavior in the closing mode is very similar to the behavior of an EA whose risk manager has a target profit value set equal to the difference between the current balance at the start of the closing mode and the base balance. So why not modify the risk manager a little so that the closing mode could be implemented simply by setting the necessary parameters in the risk manager?
Let's think about what we lack in the risk manager to implement work in closing mode. In the simplest case, if we do not deal with the maximum time, then the risk manager does not need any revision. In the old version, we just need to set the target profit parameter to a value equal to the difference between the current account balance and the base balance and wait for it to reach this value. We can even go further and change it periodically over time. It is expected that this mechanism will be used quite rarely. But automatic closing after the specified time would be preferable. Therefore, let's add to the risk manager the ability to set not only the target profit, but also the maximum allowable waiting time. It will play the role of the maximum time for closing positions.
It is more convenient for us to convey this time in the form of a specific date and time, thus eliminating the need to remember the start date of work the specified interval should be counted from. Let's add this parameter to the set of inputs related to the risk manager. We will also add the substitution of its value to the initialization string:
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
...
input
group
":::  Risk manager"
...
input
ENUM_RM_CALC_OVERALL_PROFIT
rmCalcOverallProfitLimit_                    = RM_CALC_OVERALL_PROFIT_MONEY_BB;
// - Method for calculating total profit
input
double
rmMaxOverallProfitLimit_   =
1000000
;
// - Overall profit
input
datetime
rmMaxOverallProfitDate_    =
0
;
// - Maximum time of waiting for the total profit (days)
...
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int
OnInit
() {

...
// Prepare the initialization string for an EA with a group of several strategies
string
expertParams =
StringFormat
(
"class CVirtualAdvisor(\n"
"    class CVirtualStrategyGroup(\n"
"       [\n"
"        %s\n"
"       ],%f\n"
"    ),\n"
"    class CVirtualRiskManager(\n"
"       %d,%.2f,%d,%.2f,%.2f,%d,%.2f,%.2f,%d,%.2f,
%d
,%.2f,%.2f"
"    )\n"
"    ,%d,%s,%d\n"
")"
,
                            strategiesParams, scale_,
                            rmIsActive_, rmStartBaseBalance_,
                            rmCalcDailyLossLimit_, rmMaxDailyLossLimit_, rmCloseDailyPart_,
                            rmCalcOverallLossLimit_, rmMaxOverallLossLimit_, rmCloseOverallPart_,
                            rmCalcOverallProfitLimit_, rmMaxOverallProfitLimit_,
rmMaxOverallProfitDate_
,
                            rmMaxRestoreTime_, rmLastVirtualProfitFactor_,
                            magic_,
"SimpleVolumes"
, useOnlyNewBars_
                         );
// Create an EA handling virtual positions
expert = NEW(expertParams);

...
// Successful initialization
return
(
INIT_SUCCEEDED
);
}
Save the changes in the
SimpleVolumesExpert.mq5
file in the current folder.
In the risk manager class, first add a new property for the maximum time to wait for a given profit and set its value in the constructor from the initialization string. Also, add the new method
OverallProfit()
, which will return the desired profit value for closing:
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
...
   ENUM_RM_CALC_OVERALL_PROFIT m_calcOverallProfitLimit;
// Method for calculating maximum overall profit
double
m_maxOverallProfitLimit;
// Parameter for calculating the maximum overall profit
datetime
m_maxOverallProfitDate
;
// Maximum time of reaching the total profit
...
// Protected methods
double
DailyLoss();
// Maximum daily loss
double
OverallLoss();
// Maximum total loss
double
OverallProfit()
;
// Maximum profit
...
};
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
   m_calcDailyLossLimit = (ENUM_RM_CALC_DAILY_LOSS) ReadLong(p_params);
   m_maxDailyLossLimit = ReadDouble(p_params);
   m_closeDailyPart = ReadDouble(p_params);
   m_calcOverallLossLimit = (ENUM_RM_CALC_OVERALL_LOSS) ReadLong(p_params);
   m_maxOverallLossLimit = ReadDouble(p_params);
   m_closeOverallPart = ReadDouble(p_params);
   m_calcOverallProfitLimit = (ENUM_RM_CALC_OVERALL_PROFIT) ReadLong(p_params);
   m_maxOverallProfitLimit = ReadDouble(p_params);
m_maxOverallProfitDate  = (
datetime
) ReadLong(p_params)
;
   m_maxRestoreTime = ReadDouble(p_params);
   m_lastVirtualProfitFactor = ReadDouble(p_params);

   ...
}
The
OverallProfit()
method first checks if the time to achieve the desired profit is set. If the time is set and the current time has already exceeded the set time, then the method returns the current profit value, since the current value is already a desired one. This will eventually result in all positions being closed and trading being stopped. If the time has not yet been reached, then the method returns the value of the desired profit calculated from the input:
//+------------------------------------------------------------------+
//| Maximum total profit                                             |
//+------------------------------------------------------------------+
double
CVirtualRiskManager::OverallProfit() {
// Current time
datetime
tc =
TimeCurrent
();
// If the current time is greater than the specified maximum time,
if
(m_maxOverallProfitDate && tc > m_maxOverallProfitDate) {
// Return the value that guarantees the positions are closed
return
m_overallProfit;
   }
else
if
(m_calcOverallProfitLimit == RM_CALC_OVERALL_PROFIT_PERCENT_BB) {
// To get a given percentage of the base balance, calculate it
return
m_baseBalance * m_maxOverallProfitLimit /
100
;
   }
else
{
// To get a fixed value, just return it
// RM_CALC_OVERALL_PROFIT_MONEY_BB
return
m_maxOverallProfitLimit;
   }
}
We will use this method when checking the need for closing inside the
CheckOverallProfitLimit()
method:
//+------------------------------------------------------------------+
//| Check if the specified profit has been achieved                  |
//+------------------------------------------------------------------+
bool
CVirtualRiskManager::CheckOverallProfitLimit() {
// If overall loss is reached and positions are still open
if
(
m_overallProfit >= OverallProfit()
&& CMoney::DepoPart() >
0
) {
// Reduce the multiplier of the used part of the overall balance by the overall loss
m_overallDepoPart =
0
;
// Set the risk manager to the achieved overall profit state
m_state = RM_STATE_OVERALL_PROFIT;
// Set the value of the used part of the overall balance
SetDepoPart();

      ...
return
true
;
   }
return
false
;
}
Save the changes in the
VirtualRiskManager.mqh
file in the current folder.
The changes regarding the shutdown mode are mostly complete. We will add the rest later as we work to ensure that functionality can be recovered after a restart.
Recovering after a restart
The need to provide such a possibility was envisaged starting from the first parts of the series. Many of the classes we created already have
Save()
and
Load()
methods intended specifically for saving and loading the object status. In some of these methods, we already had working code, but then we were busy with other things and did not keep these methods working properly since this was unnecessary. It is time to focus on them and get them back into working order.
Perhaps, the main changes we will have to make again are in the risk manager class, since these methods are still completely empty there. We will also need to ensure that the risk manager save and load methods are called when loading/saving the EA, since the risk manager appeared later and was not added to the saved information.
Let's start by adding an input to the EA that determines whether to restore the previous state. By default it will be True. If we want to start the EA from scratch, we can set it to False, restart the EA (in this case, all previously saved information will be overwritten with new one), and then return this parameter to True again. In the EA initialization function, check whether the previous state needs to be loaded, and if yes, load it:
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
...
input
bool
usePrevState_
=
true
;
// - Load the previous state
...
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int
OnInit
() {
   ...
// Create an EA handling virtual positions
expert = NEW(expertParams);
// If the EA is not created, then return an error
if
(!expert)
return
INIT_FAILED
;
// If an error occurred while replacing symbols, then return an error
if
(!expert.SymbolsReplace(symbolsReplace_))
return
INIT_FAILED
;
// If we need to restore the state,
if
(usePrevState_) {
// Load the previous state if available
expert.Load()
;
      expert.Tick();
   }
// Successful initialization
return
(
INIT_SUCCEEDED
);
}
Save the changes in the
SimpleVolumesExpert.mq5
file in the current folder.
Before we move on to the methods of saving/loading state, let's pay attention to the following aspect. In the previous version, we formed the file name for saving from the EA's name, its magic number and the word ".test" when running in visual testing mode. The EA name is a constant value.
It is embedded in the source code and does not change via the EA inputs. The magic number can be changed via the inputs. This means that if we change the magic number, the EA will no longer load the file generated with the previously used magic number. But this also means that if we change the composition of single instances of trading strategies, but leave the same magic number, the EA will try to use the previous file to load the status.
This will most likely lead to errors, so we need to protect ourselves from such a situation. One possible way is to include some part in the file name that will depend on the trading strategy instances used. Then if their composition changes, then this part of the file name also changes, which means the EA will not use the old file after updating the composition of strategies.
It is possible to form such a changing part of the file name by calculating some hash function from the EA initialization string or part of it. In fact, we talked about the need to use a different file only when changing the composition of trading strategies. If we change, for example, the risk manager settings, this changes the initialization string, but should not lead to a change in the name of the file used to save the status. Therefore, we will calculate the hash function only from the part of the initialization string containing information about single instances of trading strategies.
To do this, add the new method
HashParams()
and make changes to the EA constructor:
//+------------------------------------------------------------------+
//| Class of the EA handling virtual positions (orders)              |
//+------------------------------------------------------------------+
class
CVirtualAdvisor :
public
CAdvisor {
protected
:
   ...
virtual
string
HashParams(
string
p_name);
// Hash value of EA parameters
public
:
   ...
};

...
//+------------------------------------------------------------------+
//| Hash value of EA parameters                                      |
//+------------------------------------------------------------------+
string
CVirtualAdvisor::HashParams(
string
p_params) {
uchar
hash[], key[], data[];
// Calculate the hash from the initialization string
StringToCharArray
(p_params, data);
CryptEncode
(
CRYPT_HASH_MD5
, data, key, hash);
// Convert it from the array of numbers to a string with hexadecimal notation
string
res =
""
;
   FOREACH(hash, res +=
StringFormat
(
"%X"
, hash[i]);
if
(i %
4
==
3
&& i <
15
) res +=
"-"
);
return
res;
}
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CVirtualAdvisor::CVirtualAdvisor(
string
p_params) {


...
// If there are no read errors,
if
(IsValid()) {

      
...
// Form the name of the file for saving the state from the EA name and parameters
m_name =
StringFormat
(
"%s-%d
-%s
%s.csv"
,
                            (p_name !=
""
? p_name :
"Expert"
),
                            p_magic,
HashParams(groupParams)
,
                            (
MQLInfoInteger
(
MQL_TESTER
) ?
".test"
:
""
)
                           );;

      
...
   }
}
Add saving/loading the risk manager to the corresponding EA methods:
//+------------------------------------------------------------------+
//| Save status                                                      |
//+------------------------------------------------------------------+
bool
CVirtualAdvisor::Save() {
bool
res =
true
;
// Save status if:
if
(
true
// later changes appeared
&& m_lastSaveTime < CVirtualReceiver::s_lastChangeTime
// currently, there is no optimization
&& !
MQLInfoInteger
(
MQL_OPTIMIZATION
)
// and there is no testing at the moment or there is a visual test at the moment
&& (!
MQLInfoInteger
(
MQL_TESTER
) ||
MQLInfoInteger
(
MQL_VISUAL_MODE
))
     ) {
int
f =
FileOpen
(m_name,
FILE_CSV
|
FILE_WRITE
,
'\t'
);
if
(f !=
INVALID_HANDLE
) {
// If file is open, save
FileWrite
(f, CVirtualReceiver::s_lastChangeTime);
// Time of last changes
// All strategies
FOREACH(m_strategies, ((CVirtualStrategy*) m_strategies[i]).Save(f));
m_riskManager.Save(f)
;
FileClose
(f);
// Update the last save time
m_lastSaveTime = CVirtualReceiver::s_lastChangeTime;
PrintFormat
(
__FUNCTION__
" | OK at %s to %s"
,
TimeToString
(m_lastSaveTime,
TIME_DATE
|
TIME_MINUTES
|
TIME_SECONDS
), m_name);
      }
else
{
PrintFormat
(
__FUNCTION__
" | ERROR: Operation FileOpen for %s failed, LastError=%d"
,
                     m_name,
GetLastError
());
         res =
false
;
      }
   }
return
res;
}
//+------------------------------------------------------------------+
//| Load status                                                      |
//+------------------------------------------------------------------+
bool
CVirtualAdvisor::Load() {
bool
res =
true
;
// Load status if:
if
(
true
// file exists
&&
FileIsExist
(m_name)
// currently, there is no optimization
&& !
MQLInfoInteger
(
MQL_OPTIMIZATION
)
// and there is no testing at the moment or there is a visual test at the moment
&& (!
MQLInfoInteger
(
MQL_TESTER
) ||
MQLInfoInteger
(
MQL_VISUAL_MODE
))
     ) {
int
f =
FileOpen
(m_name,
FILE_CSV
|
FILE_READ
,
'\t'
);
if
(f !=
INVALID_HANDLE
) {
// If the file is open, then load
m_lastSaveTime =
FileReadDatetime
(f);
// Last save time
PrintFormat
(
__FUNCTION__
" | LAST SAVE at %s"
,
TimeToString
(m_lastSaveTime,
TIME_DATE
|
TIME_MINUTES
|
TIME_SECONDS
));
// Load all strategies
FOREACH(m_strategies, {
            res &= ((CVirtualStrategy*) m_strategies[i]).Load(f);
if
(!res)
break
;
         });
if
(!res) {
PrintFormat
(
__FUNCTION__
" | ERROR loading strategies from file %s"
, m_name);
         }
res &= m_riskManager.Load(f)
;
if
(!res) {
PrintFormat
(
__FUNCTION__
" | ERROR loading risk manager from file %s"
, m_name);
         }
FileClose
(f);
      }
else
{
PrintFormat
(
__FUNCTION__
" | ERROR: Operation FileOpen for %s failed, LastError=%d"
, m_name,
GetLastError
());
         res =
false
;
      }
   }
return
res;
}
Save the changes in the
VirtualAdvisor.mq5
file in the current folder.
Now all we have to do is write the implementation of the methods of
saving/loading the risk manager. Let's look at what we need to save for the risk manager. Risk manager inputs do not need to be saved
—
they are always taken from the EA inputs. During the next launch, the changed values can already be substituted. There is also no need to save values updated by the risk manager itself: balance, equity, daily profit and others. The only thing worth keeping
is
the daily base level, as it is calculated only once a day.
All the properties that relate to the current state and management of the size of open positions (except
the used part of the overall balance) should be preserved.
// Current state
ENUM_RM_STATE     m_state;
// State
double
m_lastVirtualProfit;
// Profit of open virtual positions at the moment of loss limit
datetime
m_startRestoreTime;
// Start time of restoring the size of open positions
datetime
m_startTime;
// Updated values
...
// Managing the size of open positions
double
m_baseDepoPart;
// Used (original) part of the total balance
double
m_dailyDepoPart;
// Multiplier of the used part of the total balance by daily loss
double
m_overallDepoPart;
// Multiplier of the used part of the total balance by overall loss
Taking into account the above, the implementation of these methods might look like this:
//+------------------------------------------------------------------+
//| Save status                                                      |
//+------------------------------------------------------------------+
bool
CVirtualRiskManager::Save(
const
int
f) {
FileWrite
(f,
             m_state, m_lastVirtualProfit, m_startRestoreTime, m_startTime,
             m_dailyDepoPart, m_overallDepoPart);
return
true
;
}
//+------------------------------------------------------------------+
//| Load status                                                      |
//+------------------------------------------------------------------+
bool
CVirtualRiskManager::Load(
const
int
f) {
   m_state = (ENUM_RM_STATE)
FileReadNumber
(f);
   m_lastVirtualProfit =
FileReadNumber
(f);
   m_startRestoreTime =
FileReadDatetime
(f);
   m_startTime =
FileReadDatetime
(f);
   m_dailyDepoPart =
FileReadNumber
(f);
   m_overallDepoPart =
FileReadNumber
(f);
return
true
;
}
Save the changes in the
VirtualRiskManager.mq5
file in the current folder.
Test
To test the added functionality, we will take two paths. First, let's install the compiled EA on the chart and make sure the status data file is created. For further verification, we need to wait until the EA opens any positions. But we can wait for this for quite a long time, and we will have to wait even longer for the risk manager to trigger, so that we can check the correctness of the EA’s resumption of work after its intervention. Second, we will use the strategy tester and simulate the situation of resuming the EA’s work after stopping.
To do this, we will create a new EA based on the existing one, to which we will add two new inputs: the stop time before restarting and the start time of the restart. They will be handled as follows:
if the stop time before restart is not specified (equal to zero or 1970-01-01 00:00:00) or it does not fall within the test interval, then the EA works as the original one;
if a specific stop time is specified that falls within the test interval, then when this time is reached, the EA stops executing the tick handler for the EA object until the time specified in the second parameter.
In the code, these two parameters look like this:
input
datetime
restartStopTime_  =
0
;
// - Stop time before restart
input
datetime
restartStartTime_ =
0
;
// - Restart launch time
Let's make changes to the tick handling function in the EA. To remember that a break has occurred, we will add the global boolean variable
isRestarting
. If it is True, then the EA is currently standing by. As soon as the current time exceeds the resumption time, we load the previous EA status and reset the
isRestarting
flag:
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void
OnTick
() {
// If the stop time is specified,
if
(restartStopTime_ !=
0
) {
// Define the current time
datetime
tc =
TimeCurrent
();
// If we are in the interval between stopping and resuming,
if
(tc >= restartStopTime_ && tc <= restartStartTime_) {
// Save the status and exit
isRestarting =
true
;
return
;
      }
// If we were in a state between stopping and resuming,
// and it is time to resume work,
if
(isRestarting && tc > restartStartTime_) {
// Load the EA status
expert.Load();
// Reset the status flag between stop and resume
isRestarting =
false
;
      }
   }
// Perform tick handling
expert.Tick();
}
Save the changes in the
SimpleVolumesTestRestartExpert.mq5
file in the current folder.
Let's look at the results without interruption in the 2021-2022 interval.
Fig. 1. Test results without interrupting trading
Let's now take a short break from the EA's work at some point in time. After the test run, the results were exactly the same as without a break. This indicates that after a short break the EA successfully restores its status and continues working.
To see the difference, let's take a longer break, for example, 4 months. We get the following results:
Fig. 2. Test results with a trading break from 2021.07.27 to 2021.11.29
On the chart, the approximate break position is shown by a rectangle with a yellow border. At this time, the positions opened by the EA were abandoned. But then the EA got back into action, picked up its open positions and was able to get generally good results. So, the ability to save and load the EA status can also be considered implemented.
Conclusion
Let's take another look at the results achieved. We have already begun to seriously prepare our EA for work on a real account. For this purpose, various scenarios have been considered not encountered in the tester but mostly in real trading.
We looked at how to ensure the EA works on an account where the names of the trading symbols are slightly different from those it was optimized on. For this purpose, the ability to replace symbol names was implemented. We have also implemented the ability to softly end a trade if it is necessary to launch an EA with other inputs. Another important development was the addition of the ability to save the state of the EA to ensure proper resumption of work after restarting the terminal.
However, these are not all the preparations that should be made when installing an EA to work on a real trading account. We would like to somehow better arrange the display of various types of auxiliary information, as well as provide the display of summary data on the EA current state on the chart. But more important is the modification that allows the EA to work in the absence of a database with optimization results in the terminal's working folder. At the moment, we cannot do without it, since it is from this database that the components for forming the EA initialization string are taken. We will consider these improvements in the following articles.
Thank you for your attention! See you soon!
Translated from Russian by MetaQuotes Ltd.
Original article:
https://www.mql5.com/ru/articles/15294
Attached files
|
Download ZIP
SimpleVolumesTestRestartExpert.mq5
(19.48 KB)
SimpleVolumesExpert.mq5
(17.4 KB)
VirtualAdvisor.mqh
(32.74 KB)
VirtualRiskManager.mqh
(49.76 KB)
SimpleVolumesStrategy.mqh
(28.26 KB)
VirtualStrategy.mqh
(9.84 KB)
VirtualStrategyGroup.mqh
(11.12 KB)
Warning:
All rights to these materials are reserved by MetaQuotes Ltd. Copying or reprinting of these materials in whole or in part is prohibited.
Other articles by this author
Developing a multi-currency Expert Advisor (Part 14): Adaptive volume change in risk manager
Developing a multi-currency Expert Advisor (Part 13): Automating the second stage — selection into groups
Developing a multi-currency Expert Advisor (Part 12): Developing prop trading level risk manager
Developing a multi-currency Expert Advisor (Part 11): Automating the optimization (first steps)
Developing a multi-currency Expert Advisor (Part 10): Creating objects from a string
Developing a multi-currency Expert Advisor (Part 9): Collecting optimization results for single trading strategy instances
Last comments |
Go to discussion
(2)
Максим Курбатов
|
23 Jul 2024 at 17:26
Hello! The Expert Advisor does not compile. At first it requires different mqh files to be included - I tried to take the corresponding files from your previous articles. It still does not compile - apparently, I load the wrong versions of files.... Could you please tell me which versions of include files are relevant for this EA code? Thank you!
Yuriy Bykov
|
24 Jul 2024 at 07:43
Hello!
I will try to check it soon. In each article I try to double-check that all files that have been modified are attached. So you did the right thing: those files that are not attached to the current article should be taken from the most recent article, where such a file exists.
Chaos theory in trading (Part 1): Introduction, application in financial markets and Lyapunov exponent
Can chaos theory be applied to financial markets? In this article, we will consider how conventional Chaos theory and chaotic systems are different from the concept proposed by Bill Williams.
Hidden Markov Models for Trend-Following Volatility Prediction
Hidden Markov Models (HMMs) are powerful statistical tools that identify underlying market states by analyzing observable price movements. In trading, HMMs enhance volatility prediction and inform trend-following strategies by modeling and anticipating shifts in market regimes. In this article, we will present the complete procedure for developing a trend-following strategy that utilizes HMMs to predict volatility as a filter.
Neural Networks in Trading: Dual-Attention-Based Trend Prediction Model
We continue the discussion about the use of piecewise linear representation of time series, which was started in the previous article. Today we will see how to combine this method with other approaches to time series analysis to improve the price trend prediction quality.
Price Action Analysis Toolkit Development (Part 7): Signal Pulse EA
Unlock the potential of multi-timeframe analysis with 'Signal Pulse,' an MQL5 Expert Advisor that integrates Bollinger Bands and the Stochastic Oscillator to deliver accurate, high-probability trading signals. Discover how to implement this strategy and effectively visualize buy and sell opportunities using custom arrows. Ideal for traders seeking to enhance their judgment through automated analysis across multiple timeframes.
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