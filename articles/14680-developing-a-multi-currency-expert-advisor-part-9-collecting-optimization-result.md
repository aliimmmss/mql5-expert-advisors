# Developing a multi-currency Expert Advisor (Part 9): Collecting optimization results for single trading strategy instances

**Source:** [https://www.mql5.com/en/articles/14680](https://www.mql5.com/en/articles/14680)

---

Русский
Developing a multi-currency Expert Advisor (Part 9): Collecting optimization results for single trading strategy instances
MetaTrader 5
—
Tester
| 6 September 2024, 14:13
359
0
Yuriy Bykov
Introduction
We have already implemented a lot of interesting things in the previous
articles
. We have a trading strategy or several trading strategies that we can implement in the EA. Besides, we have developed a structure for connecting many instances of trading strategies in a single EA, added tools for managing the maximum allowable drawdown, looked at possible ways of automated selection of sets of strategy parameters for their best work in a group, learned how to assemble an EA from groups of strategy instances and even from groups of different groups of strategy instances. But the value of the results already obtained will greatly increase if we manage to combine them together.
Let's try to outline a general structure within the article framework: single trading strategies are fed into the input, while the output is a ready-made EA, which uses selected and grouped copies of the original trading strategies that provide the best trading results.
After drawing up a rough road map, let's take a closer look at some section of it, analyze what we need to implement the selected stage, and get down to the actual implementation.
Main stages
Let's list the main stages that we will have to go through while developing the EA:
Implementing a trading strategy
. We develop the class derived from
CVirtualStrategy
, which implements the trading logic of opening, maintaining and closing virtual positions and orders. We did this in the first four parts of the series.
Trading strategy optimization
. We select good sets of inputs for a trading strategy that show noteworthy results. If none are found, then we return to point 1.
As a rule, it is more convenient for us to perform optimization on one symbol and timeframe. For genetic optimization, we will most likely need to run it several times with different optimization criteria, including some of our own. It will only be possible to use brute force optimization in strategies with a very small number of parameters. Even in our model strategy, exhaustive search is too expensive. Therefore, further on, while speaking about optimization,
I will imply genetic optimization in the MetaTrader 5 strategy tester. The optimization process was not described in detail in the articles, since it is pretty standard.
Clustering of sets
. This step is not mandatory, but will save some time in the next step. Here we significantly reduce the number of sets of parameters of trading strategy instances, among which we will select suitable groups. This is described in the sixth part.
Selecting groups of parameter sets
. Based on the results of the previous stage, perform optimization selecting
the most compatible sets of parameters of trading strategy instances that produce the best results. This is also mainly described in the sixth and seventh parts.
Selecting groups from groups of parameter sets
. Now combine the results of the previous stage into groups using the same principle as when combining the sets of single instance parameter sets.
Iterating through symbols and timeframes
. Repeat steps 2 - 5 for all desired symbols and timeframes. Perhaps, in addition to a symbol and timeframe, it is possible to conduct separate optimization on certain classes of other inputs for some trading strategies.
Other strategies
. If you have other trading strategies in mind, then repeat steps 1 - 6 for each of them.
Assembling the EA
. We collect all the best groups of groups found for different trading strategies, symbols, timeframes and other parameters into one final EA.
Each stage, upon completion, generates some data that needs to be saved and used in the next stages. So far we have been using temporary improvised means, convenient enough to use once or twice, but not particularly convenient for repeated use.
For example, we saved the optimization results after the second stage in an Excel file, then manually added the missing columns, and then, having saved it as a CSV file, used it in the third stage.
We either used the results of the third stage directly from the strategy tester interface, or saved them again in Excel files, carried out some processing there, and again used the results obtained from the tester interface.
We did not actually carry out the fifth stage, only noting the possibility of carrying it out. Therefore, it never came to fruition.
For all these received data, we would like to implement a single storage and usage structure.
Implementation options
Essentially, the main type of data we need to store and use is the optimization results of multiple EAs. As you know, the strategy tester records all optimization results in a separate cache file with the *.opt extension, which can then be reopened in the tester or even opened in the tester of another MetaTrader 5 terminal. The file name is determined from the hash calculated based on the name of the optimized EA and the optimization parameters. This allows us not to lose information about the passes already made when continuing optimization after its early interruption or after changing the optimization criterion.
Therefore, one of the options under consideration is the use of optimization cache files to store intermediate results. There is a good
library
from
fxsaber
allowing us to access all saved information from MQL5 programs.
But as the number of optimizations performed increases, the number of files with their results will also increase. In order not to get confused, we will need to come up with some additional structure for arranging the storage and working with these cache files. If optimization is not carried out on one server, then it will be necessary to implement synchronization or storing all cache files in one place. In addition, for the next stage we will still need some processing to export the obtained optimization results to the EA at the next stage.
Then let's look at arranging the storage of all results in the database. At first glance, this would require quite a lot of time to implement. But this work can be broken down into smaller stages, and we will be able to use its results immediately, without waiting for full implementation. This approach also allows for greater freedom in choosing the most convenient means of intermediate processing of stored results. For example, we can assign some processing to simple SQL queries, something will be calculated in MQL5, and something in Python or R programs. We will be able to try different processing options and choose the most suitable one.
MQL5 offers built-in functions for working with the SQLite database. There were also implementations of third-party libraries that allow working, say, with MySQL. It is not yet clear whether SQLite capabilities will be enough for us, but most likely this database will be sufficient for our needs. If it is not sufficient, then we will think about migrating to another DBMS.
Let's start designing the database
First, we need to identify the entities whose information we want to store. Of course, one test run is one of them. The fields of this entity will include test input data fields and test result fields. Generally, they can be distinguished as separate entities. The essence of the input data can be broken down into even smaller entities: the EA, optimization settings and EA single-pass parameters. But let's continue to be guided by the principle of least action. To begin with, one table with fields for the pass results that we used in previous articles and one or two text fields for placing the necessary information about the pass inputs will be sufficient for us.
Such a table can be created with the following SQL query:
CREATE TABLE passes (
    id                    INTEGER  PRIMARY KEY AUTOINCREMENT,
    pass                  INT,	-- pass index

    inputs                TEXT, -- pass input values
    params                TEXT, -- additional pass data

    initial_deposit       REAL, -- pass results...
    withdrawal            REAL,
    profit                REAL,
    gross_profit          REAL,
    gross_loss            REAL,
    max_profittrade       REAL,
    max_losstrade         REAL,
    conprofitmax          REAL,
    conprofitmax_trades   REAL,
    max_conwins           REAL,
    max_conprofit_trades  REAL,
    conlossmax            REAL,
    conlossmax_trades     REAL,
    max_conlosses         REAL,
    max_conloss_trades    REAL,
    balancemin            REAL,
    balance_dd            REAL,
    balancedd_percent     REAL,
    balance_ddrel_percent REAL,
    balance_dd_relative   REAL,
    equitymin             REAL,
    equity_dd             REAL,
    equitydd_percent      REAL,
    equity_ddrel_percent  REAL,
    equity_dd_relative    REAL,
    expected_payoff       REAL,
    profit_factor         REAL,
    recovery_factor       REAL,
    sharpe_ratio          REAL,
    min_marginlevel       REAL,
    deals                 REAL,
    trades                REAL,
    profit_trades         REAL,
    loss_trades           REAL,
    short_trades          REAL,
    long_trades           REAL,
    profit_shorttrades    REAL,
    profit_longtrades     REAL,
    profittrades_avgcon   REAL,
    losstrades_avgcon     REAL,
    complex_criterion     REAL,
custom_ontester       REAL,
    pass_date             DATETIME DEFAULT (datetime('now') )
                                   NOT NULL
);
Let's create the auxiliary
CDatabase
class, which will contain methods for working with the database. We can make it static, since we do not need many instances in one program, just one is sufficient. Since we are currently planning to accumulate all the information in one database, we can rigidly specify the database file name in the source code.
This class will contain the
s_db
field for storing the open database handle. The
Open()
database opening method will set its value. If the database has not yet been created at the time of opening, it will be created by calling the
Create()
method. Once opened, we can execute single SQL queries to the database using the Execute() method or bulk SQL queries in a single transaction using the
ExecuteTransaction()
method. At the end, we will close the database using the
Close()
method.
We can also declare a short macro that allows us to replace the long
CDatabase
class name with the shorter
DB
.
#define
DB CDatabase
//+------------------------------------------------------------------+
//| Class for handling the database                                  |
//+------------------------------------------------------------------+
class
CDatabase {
static
int
s_db;
// DB connection handle
static
string
s_fileName;
// DB file name
public
:
static
bool
IsOpen();
// Is the DB open?
static
void
Create();
// Create an empty DB
static
void
Open();
// Opening DB
static
void
Close();
// Closing DB
// Execute one query to the DB
static
bool
Execute(
string
&query);
// Execute multiple DB queries in one transaction
static
bool
ExecuteTransaction(
string
&queries[]);
};
int
CDatabase::s_db       =
INVALID_HANDLE
;
string
CDatabase::s_fileName =
"database.sqlite"
;
In the database creation method, we will simply create an array with SQL queries for creating tables and execute them in one transaction:
//+------------------------------------------------------------------+
//| Create an empty DB                                               |
//+------------------------------------------------------------------+
void
CDatabase::Create() {
// Array of DB creation requests
string
queries[] = {
"DROP TABLE IF EXISTS passes;"
,
"CREATE TABLE passes ("
"id                    INTEGER  PRIMARY KEY AUTOINCREMENT,"
"pass                  INT,"
"inputs                TEXT,"
"params                TEXT,"
"initial_deposit       REAL,"
"withdrawal            REAL,"
"profit                REAL,"
"gross_profit          REAL,"
"gross_loss            REAL,"
...
"pass_date             DATETIME DEFAULT (datetime('now') ) NOT NULL"
");"
,
   };
// Execute all requests
ExecuteTransaction(queries);
}
In the open database method, we will first try to open an existing database file. If it does not exist, then we create and open it, after which we create the database structure by calling the
Create()
method:
//+------------------------------------------------------------------+
//| Is the DB open?                                                  |
//+------------------------------------------------------------------+
bool
CDatabase::IsOpen() {
return
(s_db !=
INVALID_HANDLE
);
}
...
//+------------------------------------------------------------------+
//| Open DB                                                          |
//+------------------------------------------------------------------+
void
CDatabase::Open() {
// Try to open an existing DB file
s_db =
DatabaseOpen
(s_fileName,
DATABASE_OPEN_READWRITE
|
DATABASE_OPEN_COMMON
);
// If the DB file is not found, try to create it when opening
if
(!IsOpen()) {
      s_db =
DatabaseOpen
(s_fileName,
DATABASE_OPEN_READWRITE
|
DATABASE_OPEN_CREATE
|
DATABASE_OPEN_COMMON
);
// Report an error in case of failure
if
(!IsOpen()) {
PrintFormat
(
__FUNCTION__
" | ERROR: %s open failed with code %d"
,
                     s_fileName,
GetLastError
());
return
;
      }
// Create the database structure
Create();
   }
PrintFormat
(
__FUNCTION__
" | Database %s opened successfully"
, s_fileName);
}
In the method of executing multiple
ExecuteTransaction()
queries, we create a transaction and start executing all SQL queries in a loop one by one. If an error occurs while executing the next request, we interrupt the loop, report the error, and cancel all previous requests within this transaction. If no errors occur, confirm the transaction:
//+------------------------------------------------------------------+
//| Execute multiple DB queries in one transaction                   |
//+------------------------------------------------------------------+
bool
CDatabase::ExecuteTransaction(
string
&queries[]) {
// Open a transaction
DatabaseTransactionBegin
(s_db);
bool
res =
true
;
// Send all execution requests
FOREACH(queries, {
      res &= Execute(queries[i]);
if
(!res)
break
;
   });
// If an error occurred in any request, then
if
(!res) {
// Report it
PrintFormat
(
__FUNCTION__
" | ERROR: Transaction failed, error code=%d"
,
GetLastError
());
// Cancel transaction
DatabaseTransactionRollback
(s_db);
   }
else
{
// Otherwise, confirm transaction
DatabaseTransactionCommit
(s_db);
PrintFormat
(
__FUNCTION__
" | Transaction done successfully"
);
   }
return
res;
}
Save the changes in the
Database.mqh
file of the current folder.
Modifying the EA to collect optimization data
When using only agents on the local computer in the optimization process, we can arrange saving the pass results to the database either in
OnTester()
, or
OnDeinit()
handler. When using agents in a local network or in the MQL5 Cloud Network, it will be very difficult, if possible, to achieve saving the results. Fortunately, MQL5 offers a great standard way to get any information from test agents, wherever they are, by creating, sending and receiving data frames.
This mechanism is described in sufficient detail in the
reference
and in the
AlgoBook
. In order to use it, we need to add three additional event handlers to the optimized:
OnTesterInit()
,
OnTesterPass()
and
OnTesterDeinit()
.
Optimization is always launched from some MetaTrader 5 terminal, which we will henceforth conditionally call the main one. When an EA with such handlers is launched from the main terminal for optimization, a new chart is opened in the main terminal, and another instance of the EA is launched on this chart before distributing the EA instances to testing agents to perform normal optimization passes with different sets of parameters.
This instance is launched in a special mode: the standard
OnInit()
,
OnTick()
and
OnDeinit()
handlers are not executed in it. Only these three new handlers are executed instead. This mode even has its own name - the mode of collecting frames of optimization results. If necessary, we can check that the EA is running in this mode in the EA functions by calling the
MQLInfoInteger()
function the following way:
// Check if the EA is running in data frame collection mode
bool
isFrameMode =
MQLInfoInteger
(
MQL_FRAME_MODE
);
As the names suggest, in frame collection mode, the
OnTesterInit()
handler runs once before optimization,
OnTesterPass()
runs every time any of the test agents completes its pass, while
OnTesterDeinit()
runs once after all scheduled optimization passes are completed or when optimization is interrupted.
The EA instance launched on the main terminal chart in the frame collection mode will be responsible for collecting data frames from all test agents. "Data frame" is just a convenient name to use when describing the data exchange between test agents and the EA in the main terminal. It denotes a data set with a name and a numeric ID that the test agent created and sent to the main terminal after completing a single optimization pass.
It should be noted that it makes sense to create data frames only in the EA instances operating in normal mode on the test agents, and to collect and handle data frames only in the EA instance in the main terminal operating in frame collection mode. So let's start with creating frames.
We can place the creation of frames in the EA in the OnTester() handler or in any function or method called from OnTester(). The handler is launched after the completion of the pass, and we can get in it the values of all statistical characteristics of the completed pass and, if necessary, calculate the value of the user criterion for evaluating the pass results.
We currently have the code in it that calculates a custom criterion showing the predicted profit that could be obtained given the maximum achievable drawdown of 10%:
//+------------------------------------------------------------------+
//| Test results                                                     |
//+------------------------------------------------------------------+
double
OnTester
(
void
) {
// Maximum absolute drawdown
double
balanceDrawdown =
TesterStatistics
(
STAT_EQUITY_DD
);
// Profit
double
profit =
TesterStatistics
(
STAT_PROFIT
);
// The ratio of possible increase in position sizes for the drawdown of 10% of fixedBalance_
double
coeff = fixedBalance_ *
0.1
/ balanceDrawdown;
// Recalculate the profit
double
fittedProfit = profit * coeff;
return
fittedProfit;
}
Let's move this code from the
SimpleVolumesExpertSingle.mq5
EA file to the new
CVirtualAdvisor
method class, while the EA is left with returning the method call result:
//+------------------------------------------------------------------+
//| Test results                                                     |
//+------------------------------------------------------------------+
double
OnTester
(
void
) {
return
expert.Tester();
}
When moving, we should consider that we can no longer use the
fixedBalance_
variable inside the method, since it may not be present in another EA as well. But its value can be obtained from the
CMoney
static class by calling the
CMoney::FixedBalance()
method. Along the way, we will make one more change to the calculation of our user criterion. After determining the projected profit, we will recalculate it per unit of time, for example, profit per year. This will allow us to roughly compare the results of passes over periods of different lengths.
To do this, we need to remember the test start date in the EA. Let's add the new property
m_fromDate
, which is to store the current time in the EA object constructor.
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
datetime
m_fromDate;
public
:
   ...
virtual
double
Tester()
override
;
// OnTester event handler
...
};
//+------------------------------------------------------------------+
//| OnTester event handler                                           |
//+------------------------------------------------------------------+
double
CVirtualAdvisor::Tester() {
// Maximum absolute drawdown
double
balanceDrawdown =
TesterStatistics
(
STAT_EQUITY_DD
);
// Profit
double
profit =
TesterStatistics
(
STAT_PROFIT
);
// The ratio of possible increase in position sizes for the drawdown of 10% of fixedBalance_
double
coeff = CMoney::FixedBalance() *
0.1
/ balanceDrawdown;
// Calculate the profit in annual terms
long
totalSeconds =
TimeCurrent
() - m_fromDate;
double
fittedProfit = profit * coeff *
365
*
24
*
3600
/ totalSeconds ;
// Perform data frame generation on the test agent
CTesterHandler::Tester(fittedProfit,
                          ~((CVirtualStrategy *) m_strategies[
0
]));
return
fittedProfit;
}
Later, we might make several custom optimization criteria, and then this code will be moved again to a new location. But for now, let's not get distracted by the extensive topic of studying various fitness functions for optimizing EAs and leave the code as is.
The
SimpleVolumesExpertSingle.mq5
EA file now gets new handlers
OnTesterInit()
,
OnTesterPass()
and
OnTesterDeinit()
. Since, according to our plan, the logic of these functions should be the same for all EAs, we will first lower their implementation to the EA level (
CVirtualAdvisor
class object).
It should be taken into account that when the EA is launched in the main terminal in the frame collection mode, the
OnInit()
function, in which the EA instance is created, will not be executed. Therefore, in order not to add creation/deletion of an EA instance to new handlers, make the methods for handling these events static in the
CVirtualAdvisor
class. Then we need to add the following code to the EA:
//+------------------------------------------------------------------+
//| Initialization before starting optimization                      |
//+------------------------------------------------------------------+
int
OnTesterInit
(
void
) {
return
CVirtualAdvisor::TesterInit();
}
//+------------------------------------------------------------------+
//| Actions after completing the next optimization pass              |
//+------------------------------------------------------------------+
void
OnTesterPass
() {
   CVirtualAdvisor::TesterPass();
}
//+------------------------------------------------------------------+
//| Actions after optimization is complete                           |
//+------------------------------------------------------------------+
void
OnTesterDeinit
(
void
) {
   CVirtualAdvisor::TesterDeinit();
}
Another change we can make for the future is to get rid of the separate call to the
CVirtualAdvisor::Add()
method for adding trading strategies to the EA after it is created. Instead, we will immediately transfer information about strategies to the EA's constructor, while it will call the
Add()
method on its own. Then this method can be removed from the public part.
With this approach, the
OnInit()
EA initialization function will look as follows:
int
OnInit
() {
   CMoney::FixedBalance(fixedBalance_);
// Create an EA handling virtual positions
expert =
new
CVirtualAdvisor(
new
CSimpleVolumesStrategy(
         symbol_, timeframe_,
         signalPeriod_, signalDeviation_, signaAddlDeviation_,
         openDistance_, stopLevel_, takeLevel_, ordersExpiration_,
         maxCountOfOrders_,
0
),
// One strategy instance
magic_,
"SimpleVolumesSingle"
,
true
);
return
(
INIT_SUCCEEDED
);
}
Save the changes in the
SimpleVolumesExpertSingle.mq5
file of the current folder.
Modifying the EA class
To avoid overloading the
CVirtualAdvisor
EA class, let's move the code of the
TesterInit
,
TesterPass
and
OnTesterDeinit
event handlers to the separate
CTesterHandler
class, in which we will create static methods to handle each of these events. In this case, we need to add to the
CVirtualAdvisor
class approximately the same code as in the main EA file:
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
static
int
TesterInit();
// OnTesterInit event handler
static
void
TesterPass();
// OnTesterDeinit event handler
static
void
TesterDeinit();
// OnTesterDeinit event handler
};
//+------------------------------------------------------------------+
//| Initialization before starting optimization                      |
//+------------------------------------------------------------------+
int
CVirtualAdvisor::TesterInit() {
return
CTesterHandler::TesterInit();
}
//+------------------------------------------------------------------+
//| Actions after completing the next optimization pass              |
//+------------------------------------------------------------------+
void
CVirtualAdvisor::TesterPass() {
   CTesterHandler::TesterPass();
}
//+------------------------------------------------------------------+
//| Actions after optimization is complete                           |
//+------------------------------------------------------------------+
void
CVirtualAdvisor::TesterDeinit() {
   CTesterHandler::TesterDeinit();
}
Let's also make some additions to the EA object constructor code. Move all actions from the constructor to the new
Init()
initialization method with future improvements in mind. This will allow us to add multiple constructors with different sets of parameters that will all use the same initialization method after a little preprocessing of the parameters.
Let's add constructors whose first argument will be either a strategy object or a strategy group object. Then we can add strategies to the EA directly in the constructor. In this case, we no longer need to call the
Add()
method in the
OnInit()
EA function.
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
datetime
m_fromDate;
public
:
                     CVirtualAdvisor(CVirtualStrategy *p_strategy,
ulong
p_magic =
1
,
string
p_name =
""
,
bool
p_useOnlyNewBar =
false
);
// Constructor
CVirtualAdvisor(CVirtualStrategyGroup *p_group,
ulong
p_magic =
1
,
string
p_name =
""
,
bool
p_useOnlyNewBar =
false
);
// Constructor
void
CVirtualAdvisor::Init(CVirtualStrategyGroup *p_group,
ulong
p_magic =
1
,
string
p_name =
""
,
bool
p_useOnlyNewBar =
false
);
   ...
};

...
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CVirtualAdvisor::CVirtualAdvisor(CVirtualStrategy *p_strategy,
ulong
p_magic =
1
,
string
p_name =
""
,
bool
p_useOnlyNewBar =
false
) {
   CVirtualStrategy *strategies[] = {p_strategy};
   Init(
new
CVirtualStrategyGroup(strategies), p_magic, p_name, p_useOnlyNewBar);
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CVirtualAdvisor::CVirtualAdvisor(CVirtualStrategyGroup *p_group,
ulong
p_magic =
1
,
string
p_name =
""
,
bool
p_useOnlyNewBar =
false
) {
   Init(p_group, p_magic, p_name, p_useOnlyNewBar);
};
//+------------------------------------------------------------------+
//| EA initialization method                                         |
//+------------------------------------------------------------------+
void
CVirtualAdvisor::Init(CVirtualStrategyGroup *p_group,
ulong
p_magic =
1
,
string
p_name =
""
,
bool
p_useOnlyNewBar =
false
) {
// Initialize the receiver with a static receiver
m_receiver = CVirtualReceiver::Instance(p_magic);
// Initialize the interface with the static interface
m_interface = CVirtualInterface::Instance(p_magic);
   m_lastSaveTime =
0
;
   m_useOnlyNewBar = p_useOnlyNewBar;
   m_name =
StringFormat
(
"%s-%d%s.csv"
,
                         (p_name !=
""
? p_name :
"Expert"
),
                         p_magic,
                         (
MQLInfoInteger
(
MQL_TESTER
) ?
".test"
:
""
)
                        );

   m_fromDate =
TimeCurrent
();

   Add(p_group);
delete
p_group;
};
Save the changes in the
VirtualExpert.mqh
of the current folder.
Optimization event handling class
Let's now focus directly on the implementation of actions performed before the start, after the completion of the pass, and after the completion of the optimization. We will create the
CTesterHandler
class and add to it methods for handling the necessary events, as well as a couple of auxiliary methods placed in the closed part of the class:
//+------------------------------------------------------------------+
//| Optimization event handling class                                |
//+------------------------------------------------------------------+
class
CTesterHandler {
static
string
s_fileName;
// File name for writing frame data
static
void
ProcessFrames();
// Handle incoming frames
static
string
GetFrameInputs(
ulong
pass);
// Get pass inputs
public
:
static
int
TesterInit();
// Handle the optimization start in the main terminal
static
void
TesterDeinit();
// Handle the optimization completion in the main terminal
static
void
TesterPass();
// Handle the completion of a pass on an agent in the main terminal
static
void
Tester(
const
double
OnTesterValue,
const
string
params
);
// Handle completion of tester pass for agent
};
string
CTesterHandler::s_fileName =
"data.bin"
;
// File name for writing frame data
The event handlers for the main terminal look very simple, since we will move the main code into auxiliary functions:
//+------------------------------------------------------------------+
//| Handling the optimization start in the main terminal             |
//+------------------------------------------------------------------+
int
CTesterHandler::TesterInit(
void
) {
// Open / create a database
DB::Open();
// If failed to open it, we do not start optimization
if
(!DB::IsOpen()) {
return
INIT_FAILED
;
   }
// Close a successfully opened database
DB::Close();
return
INIT_SUCCEEDED
;
}
//+------------------------------------------------------------------+
//| Handling the optimization completion in the main terminal        |
//+------------------------------------------------------------------+
void
CTesterHandler::TesterDeinit(
void
) {
// Handle the latest data frames received from agents
ProcessFrames();
// Close the chart with the EA running in frame collection mode
ChartClose
();
}
//+--------------------------------------------------------------------+
//| Handling the completion of a pass on an agent in the main terminal |
//+--------------------------------------------------------------------+
void
CTesterHandler::TesterPass(
void
) {
// Handle data frames received from the agent
ProcessFrames();
}
The actions performed after the completion of one pass will exist in two versions:
For the test agent
. It is there that, after the passage, the necessary information will be collected and a data frame will be created for sending to the main terminal. These actions will be collected in the
Tester()
event handler.
For the main terminal
. Here we can receive data frames from test agents, parse the information received in the frame and enter it into the database. These actions will be collected in the
TesterPass()
handler.
Generating a data frame for the test agent should be performed in the EA, namely inside the
OnTester
handler. Since we moved its code to the EA object level (to the
CVirtualAdvisor
class), then this is where we need to add the
CTesterHandler::Tester()
method. We will pass the newly calculated value of the custom optimization criterion and a string describing the parameters of the strategy, that was used in the optimized EA, as the method parameters. To form such a string, we will use the already created ~ (tilde) for the
CVirtualStrategy
class objects.
//+------------------------------------------------------------------+
//| OnTester event handler                                           |
//+------------------------------------------------------------------+
double
CVirtualAdvisor::Tester() {
// Maximum absolute drawdown
double
balanceDrawdown =
TesterStatistics
(
STAT_EQUITY_DD
);
// Profit
double
profit =
TesterStatistics
(
STAT_PROFIT
);
// The ratio of possible increase in position sizes for the drawdown of 10% of fixedBalance_
double
coeff = CMoney::FixedBalance() *
0.1
/ balanceDrawdown;
// Calculate the profit in annual terms
long
totalSeconds =
TimeCurrent
() - m_fromDate;
double
fittedProfit = profit * coeff *
365
*
24
*
3600
/ totalSeconds ;
// Perform data frame generation on the test agent
CTesterHandler::Tester(fittedProfit,
~((CVirtualStrategy *) m_strategies[
0
]));
return
fittedProfit;
}
In the
CTesterHandler::Tester()
method itself, go through all possible names of available statistical characteristics, get their values, convert them to strings and add these strings to the
stats
array. Why did we need to convert real numeric characteristics to strings? Only so that they could be passed in one frame with a string description of the strategy parameters. In one frame, we can pass either an array of values of one of the simple types (strings do not apply to) or a pre-created file with any data. Therefore, in order to avoid the hassle of sending two different frames (one containing numbers and the other containing strings from a file), we will convert all the data into strings, write them to a file, and send its contents in one frame:
//+------------------------------------------------------------------+
//| Handling completion of tester pass for agent                     |
//+------------------------------------------------------------------+
void
CTesterHandler::Tester(
double
custom,
// Custom criteria
string
params
// Description of EA parameters in the current pass
) {
// Array of names of saved statistical characteristics of the pass
ENUM_STATISTICS
statNames[] = {
STAT_INITIAL_DEPOSIT
,
STAT_WITHDRAWAL
,
STAT_PROFIT
,
      ...
   };
// Array for values of statistical characteristics of the pass as strings
string
stats[];
ArrayResize
(stats,
ArraySize
(statNames));
// Fill the array of values of statistical characteristics of the pass
FOREACH(statNames, stats[i] =
DoubleToString
(
TesterStatistics
(statNames[i]),
2
));
// Add the custom criterion value to it
APPEND(stats,
DoubleToString
(custom,
2
));
// Screen the quotes in the description of parameters just in case
StringReplace
(params,
"'"
,
"\\'"
);
// Open the file to write data for the frame
int
f =
FileOpen
(s_fileName,
FILE_WRITE
|
FILE_TXT
|
FILE_ANSI
);
// Write statistical characteristics
FOREACH(stats,
FileWriteString
(f, stats[i] +
","
));
// Write a description of the EA parameters
FileWriteString
(f,
StringFormat
(
"'%s'"
, params));
// Close the file
FileClose
(f);
// Create a frame with data from the recorded file and send it to the main terminal
if
(!
FrameAdd
(
""
,
0
,
0
, s_fileName)) {
PrintFormat
(
__FUNCTION__
" | ERROR: Frame add error: %d"
,
GetLastError
());
   }
}
Finally, let's consider an auxiliary method that will accept data frames and save the information from them to the database. In this method, we receive in a loop all incoming frames that have not yet been handled at the current moment. From each frame, we obtain data in the form of a character array and convert them into a string. Next, we form a string with the names and values of the parameters of the pass with the given index. We use the obtained values to form an SQL query to insert a new row into the
passes
table in our database. Add the created SQL query to the SQL query array.
After handling all currently received data frames in this way, we execute all SQL queries from the array within a single transaction.
//+------------------------------------------------------------------+
//| Handling incoming frames                                         |
//+------------------------------------------------------------------+
void
CTesterHandler::ProcessFrames(
void
) {
// Open the database
DB::Open();
// Variables for reading data from frames
string
name;
// Frame name (not used)
ulong
pass;
// Frame pass index
long
id;
// Frame type ID (not used)
double
value;
// Single frame value (not used)
uchar
data[];
//  Frame data array as a character array
string
values;
// Frame data as a string
string
inputs;
// String with names and values of pass parameters
string
query;
// A single SQL query string
string
queries[];
// SQL queries for adding records to the database
// Go through frames and read data from them
while
(
FrameNext
(pass, name, id, value, data)) {
// Convert the array of characters read from the frame into a string
values =
CharArrayToString
(data);
// Form a string with names and values of the pass parameters
inputs = GetFrameInputs(pass);
// Form an SQL query from the received data
query =
StringFormat
(
"INSERT INTO passes "
"VALUES (NULL, %d, %s,\n'%s',\n'%s');"
,
                           pass, values, inputs,
TimeToString
(
TimeLocal
(),
TIME_DATE
|
TIME_SECONDS
));
// Add it to the SQL query array
APPEND(queries, query);
   }
// Execute all requests
DB::ExecuteTransaction(queries);
// Close the database
DB::Close();
}
The
GetFrameInputs()
auxiliary method for forming a string with names and values of input variables of the pass has been taken from the
AlgoBook
and slightly supplemented to suit our needs.
Save the obtained code in the
TesterHandler.mqh
file of the current folder.
Checking operation
To test the functionality, let's run optimization with a small number of parameters to be iterated over a relatively short time period. After the optimization process is completed, we can look at the results in the strategy tester and in the created database.
Fig. 1. Optimization results in the strategy tester
Fig. 2. Optimization results in the database
As we can see, the database results match the results in the tester: with the same sorting by user criteria, we observe the same sequence of profit values in both cases. The best pass reports that the expected profit may exceed USD 5000 within a year with the initial deposit of USD 10,000 and a maximum achievable drawdown of 10% of the initial deposit (USD 1000). Currently, however, we are not so interested in the quantitative characteristics of the optimization results as in the fact that they can now be stored in a database.
Conclusion
So, we are one step closer to our goal. We managed to save the results of the conducted optimizations of the EA parameters to our database. In this way, we have provided the foundation for further automated implementation of the second stage of the EA development.
There are still quite a few questions left behind the scenes. Many things had to be postponed for the future, since their implementation would require significant costs. But having received the current results, we can more clearly formulate the direction of further project development.
The implemented saving currently works only for one optimization process in the sense that we save information about the passes, but it is still difficult to extract groups of strings related to one optimization process from them. To do this, we will need to make changes to the database structure, which is now made extremely simple. In the future, we will try to automate the launch of several sequential optimization processes with preliminary assignment of different options for the parameters to be optimized.
Thank you for your attention! See you soon!
Translated from Russian by MetaQuotes Ltd.
Original article:
https://www.mql5.com/ru/articles/14680
Attached files
|
Download ZIP
Advisor.mqh
(4.4 KB)
Database.mqh
(13.37 KB)
Interface.mqh
(3.21 KB)
Macros.mqh
(2.28 KB)
Money.mqh
(4.61 KB)
NewBarEvent.mqh
(11.52 KB)
Receiver.mqh
(1.79 KB)
SimpleVolumesExpertSingle.mq5
(9.92 KB)
SimpleVolumesStrategy.mqh
(33.63 KB)
Strategy.mqh
(1.73 KB)
TesterHandler.mqh
(17.5 KB)
VirtualAdvisor.mqh
(22.65 KB)
VirtualChartOrder.mqh
(10.84 KB)
VirtualInterface.mqh
(8.41 KB)
VirtualOrder.mqh
(39.52 KB)
VirtualReceiver.mqh
(17.43 KB)
VirtualStrategy.mqh
(9.22 KB)
VirtualStrategyGroup.mqh
(6.1 KB)
VirtualSymbolReceiver.mqh
(33.82 KB)
Warning:
All rights to these materials are reserved by MetaQuotes Ltd. Copying or reprinting of these materials in whole or in part is prohibited.
Other articles by this author
Developing a multi-currency Expert Advisor (Part 8): Load testing and handling a new bar
Developing a multi-currency Expert Advisor (Part 7): Selecting a group based on forward period
Developing a multi-currency Expert Advisor (Part 6): Automating the selection of an instance group
Developing a multi-currency Expert Advisor (Part 5): Variable position sizes
Developing a multi-currency Expert Advisor (Part 4): Pending virtual orders and saving status
Developing a multi-currency Expert Advisor (Part 3): Architecture revision
Go to discussion
Creating an MQL5-Telegram Integrated Expert Advisor (Part 5): Sending Commands from Telegram to MQL5 and Receiving Real-Time Responses
In this article, we create several classes to facilitate real-time communication between MQL5 and Telegram. We focus on retrieving commands from Telegram, decoding and interpreting them, and sending appropriate responses back. By the end, we ensure that these interactions are effectively tested and operational within the trading environment
Introduction to MQL5 (Part 9): Understanding and Using Objects in MQL5
Learn to create and customize chart objects in MQL5 using current and historical data. This project-based guide helps you visualize trades and apply MQL5 concepts practically, making it easier to build tools tailored to your trading needs.
Formulating Dynamic Multi-Pair EA (Part 1): Currency Correlation and Inverse Correlation
Dynamic multi pair Expert Advisor leverages both on correlation and inverse correlation strategies to optimize trading performance. By analyzing real-time market data, it identifies and exploits the relationship between currency pairs.
Neural Networks Made Easy (Part 86): U-Shaped Transformer
We continue to study timeseries forecasting algorithms. In this article, we will discuss another method: the U-shaped Transformer.
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