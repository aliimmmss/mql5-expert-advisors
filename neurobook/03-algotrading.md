# Chapter 03: MetaTrader 5 Features for Algorithmic Trading

*Source: [https://www.mql5.com/en/neurobook/index/algotrading](https://www.mql5.com/en/neurobook/index/algotrading)*

---

## MetaTrader 5 features for algorithmic trading

For the practical part of this book, we will use the [MetaTrader 5](https://www.metaquotes.net/en/metatrader5) trading terminal. It is a modern, constantly evolving platform developed by [MetaQuotes Ltd](https://www.metaquotes.net/).

MetaTrader 5

MetaTrader 5 is a multi-asset trading platform. It is widely used by traders all around the world to execute trading operations in the Forex market, stock exchanges, and futures markets. MetaTrader 5 is a comprehensive program that enables trading operations and provides extensive capabilities for conducting detailed technical and fundamental analysis of the market situation.

The platform features an extended Depth of Market with a tick chart and the Time and Sales window. This tool enables the analysis of the current state and the one-click execution of trading operations. Moreover, there is the option to set stop loss and take profit levels for placed orders, which proves quite beneficial for implementing scalping trading strategies.

The provided Depth of Market allows placing market and pending orders, as well as modifying them. For more information on the capabilities of this tool, please visit [https://www.metatrader5.com/en/terminal/help/trading/depth_of_market](https://www.metatrader5.com/en/terminal/help/trading/depth_of_market).

Additionally, for conducting technical analysis, there are extensive capabilities for adding various graphical objects directly onto the price chart. The range of applied objects is quite impressive. Among these are simple lines (vertical, horizontal, and various diagonal trend lines), as well as various channels, Fibonacci levels, and more complex shapes. There's the possibility to assign different colors and visual styles to objects, as well as adding custom names and descriptions to objects.

Depth of Market

Objects of technical analysis on the chart

The platform features a comprehensive list of oscillators, volume indicators, and trend indicators, capable of meeting the requirements of any user. At the same time, if the available range of indicators is not enough for you, it is possible to create a custom indicator based on your own formula. You can create it yourself or order it from experienced programmers via the [Freelance](https://www.mql5.com/en/job) service at [mql5.com](https://www.mql5.com).

Furthermore, in the [Market](https://www.mql5.com/en/market) section of the platform, you can purchase or download indicators from various third-party developers, and the list of these indicators is constantly updated and expanded. It's unlikely that any other platform could offer such a broad spectrum of technical analysis tools.

Indicators on the chart

The capability to analyze each instrument across 21 timeframes, ranging from 1 minute to 1 month, provides a comprehensive and detailed analysis.

The indicators and graphical objects applied to the price chart can be saved as templates, which can then be easily reloaded onto the chart with just a couple of mouse clicks.

For enthusiasts of fundamental analysis, the platform provides a news feed and a calendar of financial events, allowing the display of markers for past and upcoming events directly on the instrument's chart. This enables tracking changes and analyzing trading situations rapidly in the future.

The one-click trading feature from the chart of the trading instrument helps traders execute operations swiftly and at the best price.

In addition, the platform gives almost unlimited possibilities for algorithmic trading, that is, for automated trading by using robots. MetaQuotes specialists have developed the MQL5 IDE (Integrated Development Environment) specifically for the platform. This environment allows users to create their own indicators and trading strategies, as well as test and optimize them using the built-in strategy tester with historical data gathered from real ticks.

The MetaTrader 5 platform is widely adopted and offered for use by the majority of brokers around the world, enabling traders to choose a trading provider according to their preferences.

One-click trading

In the context of the book's theme, you will undoubtedly be interested in exploring the potential for implementing neural network technologies and algorithms through the tools provided by the MetaTrader 5 platform. Let's take a closer look at the proposed tool.

## OpenCL: Parallel computations in MQL5

A large huge number of calculations are carried out while training and running neural networks. This is a rather resource-intensive process. Solving more complex problems also requires more complex neural networks with a large number of neurons. With an increase in the number of neurons in the network, the amount of computations performed increases, and consequently, the consumption of resources and time also increases. While humanity has learned to create new and more advanced computational machines, managing time is still beyond our capabilities.

It's natural that the next wave of neural network development has come with the advancement of computational power. As a rule, neurons perform fairly simple operations, but in large numbers. At the same time, there are a lot of similar neurons in the neural network. This allows for parallelizing individual blocks of computations on different computational resources and then consolidating the obtained data. As a result, the time for performing operations is significantly reduced.

The development of computing technologies has led to the emergence of video cards (GPU) with a large number of computing cores capable of performing simple mathematical operations. Next, it became possible to transfer part of the calculations from the CPU to the GPU, which made it possible to parallelize the calculation process both between the microprocessor and the video card, and at the video card level between different computing units.

[OpenCL](https://www.khronos.org/opencl/) (Open Computing Language) is an open free standard for cross-platform parallel programming of various accelerators used in supercomputers, cloud servers, personal computers, mobile devices, and embedded platforms.

OpenCL is a C-like programming language that allows GPU computing. The support of this language in MQL5 allows us to organize multi-threaded calculations of our neural networks on the GPU directly from the MQL5 program.

To understand the organization of GPU computing, it is necessary to make a short digression into the architecture of video cards and the OpenCL API.

In OpenCL terminology, a computer's microprocessor (CPU) is a Host. It manages all the processes of the program that is being executed. All microprocessors with support for OpenCL technology in the CPU and GPU are Devices. Each device has its own unique number within the platform.

One Device can have multiple Computer Units. Their number is determined by the number of physical and virtual microprocessor cores. For video cards, these will be SIMD cores. Each SIMD core contains several Stream Cores. Each thread processor has several processing elements Processing Elements (or ALU).

The specific number of Computer Units, SIMD cores, Stream Cores, and Processing Elements depends on the architecture of a particular device.

An important feature of the GPU is vector computing. Each microprocessor consists of several computing modules. They can all execute the same instruction. At the same time, different executable threads may have different initial data. This allows all threads of the GPU program to process data in parallel. Thus, all computing modules are loaded evenly. A big advantage is that vectorization of computations is done automatically at the hardware level, without the need for additional processing in the program code.

OpenCL was developed as a cross-platform environment for creating programs using mass parallel computing technology. The applications created in it have their own hierarchy and structure. Organization of the program, preparation, and consolidation of data are carried out in the Host program.

The Host, like a regular application, starts and runs on the CPU. To organize multi-threaded computations, a context is allocated, which is an environment for executing specialized objects of the OpenCL program. A context combines a set of OpenCL devices for running a program, the program objects themselves with their source codes, and a set of memory objects visible to the host and to OpenCL devices. The function responsible for creating a context in MQL5 is [CLContextCreate](https://www.mql5.com/en/docs/opencl/clcontextcreate), in which the device for executing the program is specified as a parameter. The function returns a context handle.

```
int CLContextCreate(

  int          device       // OpenCL device sequence number or macro

  );
```

Inside the context, an OpenCL program is created using the [CLProgramCreate](https://www.mql5.com/en/docs/opencl/clprogramcreate) function. The parameters of this function include the context handle and the source code of the program itself. As a result of the function execution, we obtain a program handle.

```
int CLProgramCreate(

  int          context,     // handle for OpenCL context

  const string source       // source

  );
```

An OpenCL program is divided into separate kernels which are executable functions. The [CLKernelCreate](https://www.mql5.com/en/docs/opencl/clkernelcreate) function is provided for declaring a kernel. In the parameters of the function, you specify the handle of the previously created program and the name of the kernel within it. At the output, we get the handle of the kernel.

```
int CLKernelCreate(

  int          program,     // handle to an OpenCL object

  const string kernel_name  // kernel name

  );
```

Please note that later, when the kernel is called from the main program on the GPU, several of its instances are launched in different parallel threads. This defines the index space, NDRange, which can be one-dimensional, two-dimensional, or three-dimensional. NDRange is an array of integers. The size of the array indicates the dimension of the space, and its elements indicate the dimension in each of the directions.

Each copy of the kernel is executed for each index from this space and is called a Work-Item. Each work item is provided with a global index ID. In addition, each such unit executes the same code, but the data for execution may be different.

Work items are organized into Work-Groups. Work groups represent a larger partition in the index space. Each group is assigned a group index ID. The dimensionality of work groups corresponds to the dimensionality used for addressing individual elements. Each element is assigned a unique local index ID within the group. Thus, work units can be addressed either by the global index ID or by a combination of group and local indices.

This approach allows for reducing the computation time, but at the same time complicates the process of data exchange between different kernel instances. This needs to be taken into account when creating programs.

As mentioned above, the OpenCL program operates within its own context, isolated from the calling program. As a consequence, it does not have access to the variables and arrays of the main program. Therefore, before starting the program, you need to copy all the data necessary for executing the program from RAM to GPU memory. After the kernel has finished its execution, the obtained results need to be loaded back from the GPU memory. At this point, you need to understand that the time spent on copying data from RAM to GPU memory and back is an overhead time when performing calculations on video cards. Therefore, in order to reduce the overall execution time of the entire program, transferring calculations to the GPU is advisable only when the time saved from GPU computations significantly outweighs the costs of data transfer.

Inside the GPU, there is also a ranking of memory into global, local, and private. The fastest access is achieved for the kernel to private memory, but access to it is only possible from the current instance of the kernel. The most time-consuming access is required for the global memory, but its capacity is the largest among the three mentioned. All running instances of the kernel have access to it. Global memory is used to exchange information with the main program.

Global memory provides read and write access to elements for all work groups. Each Work-Item can write to and read from any part of the global memory.

Local memory is a group-local memory area, in which you can create variables shared by the entire group. It can be implemented as dedicated memory on the OpenCL device or allocated as a region within the global memory.

Private memory is an area visible only to the Work-Item. Variables defined in the private memory of one work item are not visible to others.

Sometimes constant memory is also allocated. This is an area of global memory that remains constant during the execution of the kernel. The host allocates and initializes memory objects located in constant memory.

Let's consider two implementations of a single task: one using the OpenCL technology and the other without. As you will see later, one of the main operations we will be using is matrix multiplication. We will be performing matrix multiplication of matrix by matrix and matrix by vector. For the experiment, I propose comparing the multiplication of a matrix by a vector.

For the matrix-vector multiplication function in the classical implementation, we will use a system of two nested loops. Below is an example of such an implementation. The function parameters include a matrix and two vectors: the matrix and one vector of input data, as well as one vector for storing the results. According to the rules of vector mathematics, multiplication is only possible when the number of columns in the matrix is equal to the size of the vector. The result of such an operation will be a vector with a size equal to the number of rows in the matrix.

```
//+------------------------------------------------------------------+

//|  CPU vector multiplication function                              |

//+------------------------------------------------------------------+

bool MultCPU(matrix<TYPE> &source1, vector<TYPE> &source2, vector<TYPE> &result)

  {

//---

   ulong rows = source1.Rows();

   ulong cols = source1.Cols();

   if(cols != source2.Size())

     {

      PrintFormat("Size of vectors not equal: %d != %d", cols, source2.Size());

      return false;

     }

//---

   result = vector<TYPE>::Zeros(rows);

   for(ulong r = 0; r < rows; r++)

     {

      result[r] = 0;

      for(ulong c = 0; c < cols; c++)

         result[r] += source1[r, c] * source2[c];

     }

//---

   return true;

  }

//+------------------------------------------------------------------+
```

In the body of the function, we will first determine the dimensions of the matrix, check for compatibility with the vector size, and set the size of the output vector to be equal to the number of rows in the input matrix. After that, we will construct a system of loops. The outer loop will iterate over the rows of the matrix and, accordingly, the elements of the result vector. In the body of this loop, we will start by setting the corresponding element of the result vector to zero. Then, we will create a nested loop and calculate the sum of the products of corresponding elements of the current matrix row and the vector.

The function is not complicated. However, the weak point of such an implementation is the increase in execution time proportional to the growth of the number of elements in the matrix and the vector.

This issue can be solved by using OpenCL. Of course, such an implementation will be a little more complicated. First, let's write an OpenCL program and save it in the mult_vect_ocl.cl file. The *.cl extension is generally accepted for OpenCL programs, but not necessary for implementation in the MQL5 environment. In this case, we will use the file only to store the program text, while the program will be loaded as text.

We will enable support for the double data type in the program code. Please note that not all GPUs support the double type. And even if they do, in most cases this functionality is disabled by default.

```
//--- By default some GPUs don't support doubles

//--- cl_khr_fp64 directive is used to enable work with doubles

#pragma OPENCL EXTENSION cl_khr_fp64 : enable
```

And another aspect to consider. MetaTrader 5 allows the use of OpenCL devices for calculations with both double precision support and without. Therefore, when using the double data type in your OpenCL program, it's important to check the compatibility of the used device. Otherwise, we can get an error during the execution of the OpenCL program and while terminating its operation.

At the same time, MetaTrader 5 does not limit the ability to use all available data types. The OpenCL language allows for the use of various scalar data types:

- Boolean: bool

- Integers: char, uchar, short, ushort, int, uint, long, ulong

- Floating-point: float, double

Similar data types are also supported in MQL5. It's important to remember that each data type has its own limitations on the possible range of values, as well as the amount of memory used to store the data. Therefore, if your program doesn't require high precision or the range of possible values isn't too large, it's recommended to use less resource-intensive data types. This will allow more efficient use of device memory and reduce the cost of copying data between the main memory and OpenCL context memory. In particular, the type double can be replaced with float. It provides lower precision, but it occupies half the memory and is supported by all modern OpenCL devices. This helps reduce the costs of data transfer between devices and expand the application's usability.

OpenCL also allows you to use vector data types. Vectorization allows parallelizing computations at the microprocessor level rather than at the software level. Using a vector of four elements of the type double allows you to completely fill the 256-bit vector of SIMD instructions and perform calculations on the entire vector in one cycle. In this way, during one clock cycle of the microprocessor, we perform operations on four elements of our data array.

OpenCL supports vector variables of all integer and floating point types of 2, 3, 4, 8, and 16 elements. However, the possibility of using them depends on the specific device. Therefore, before choosing a vector dimension, check the technical characteristics of your equipment.

Now back to our program. Please provide the kernel code for calculating the vector product of a matrix row with a vector. In the kernel parameters, we will specify pointers to the arrays of input data and results. We will also pass the number of columns in the matrix as a parameter. The number of rows in the matrix does not matter for operations in the kernel, since it only performs operations of multiplying one row by a vector. Essentially, it is the multiplication of two vectors.

Note here that instead of the type of data buffers, we specified the abstract type TYPE. You will not find such a data type in any documentation. In fact, as mentioned above, not all OpenCL devices support the type double. To make our program more versatile, it was decided to replace the data type using a macro substitution. We will specify the actual data type in the main program. This approach allows us to literally change the data type in one place in the main program. After that, the entire program will switch to working with the specified data type without the risk of losing information due to type mismatch.

In the kernel body, the get_global_id function will specify the global ID index of the running Work-Item unit. In this case, the index serves as an equivalent to the iteration counter of the outer loop in the classical implementation. It specifies the sequence number of the matrix array and the element of the result vector. Next, we will calculate the sum of values for the corresponding thread in a similar manner to the calculation inside the nested loop of the classical implementation. But there is a nuance here. For the calculations, we will utilize vector operations with four elements. In turn, to use vector operations, we need to prepare the data. We get an array of scalar elements from the Host program, so we will transfer the necessary elements to our private vector variables using the ToVect function (we will consider its code below). Then, using the vector operation dot, we obtain the value of the multiplication of two vectors of four elements. In other words, with one operation, we obtain the sum of the products of four pairs of values. The obtained value is added to a local variable where the product of the matrix row and the vector accumulates.

After exiting the loop, we will save the accumulated sum into the corresponding element of the result vector.

```
//+------------------------------------------------------------------+

//| Mult of vectors                                                  |

//+------------------------------------------------------------------+

__kernel void MultVectors(__global TYPE *source1,

                          __global TYPE *source2,

                          __global TYPE *result,

                          int cols)

  {

   int shift = get_global_id(0) * cols;

   TYPE z = 0;

   for(int i = 0; i < cols; i+=4)

     {

      TYPE4 x = ToVect(source1, i, cols, shift);

      TYPE4 y = ToVect(source2, i, cols, 0);

      z += dot(x,y);

     }

   result[get_global_id(0)] = z;

  }
```

As mentioned earlier, to transfer data from the scalar value buffer to a vector variable, we have created the ToVect function. In the function parameters, we pass a pointer to the data buffer, the starting element, the total number of elements in the vector (matrix row), and the offset in the buffer before the beginning of the vector. The last parameter, offset, is needed to accurately determine the start of a row in the matrix buffer since OpenCL uses one-dimensional data buffers.

Next, we check the number of elements until the end of the vector to avoid going beyond its bounds and transfer the data from the buffer to the private vector variable. We fill the missing elements with zero values.

```
TYPE4 ToVect(__global TYPE *array, int start, int size, int shift)

  {

   TYPE4 result = (TYPE4)0;

   if(start < size)

     {

      switch(size - start)

        {

         case  1:

            result = (TYPE4)(array[shift+start], 0, 0, 0);

            break;

         case  2:

            result = (TYPE4)(array[shift+start], array[shift+start + 1], 0, 0);

            break;

         case  3:

            result = (TYPE4)(array[shift+start], array[shift+start + 1],

                             array[shift+start + 2], 0);

            break;

         default:

            result = (TYPE4)(array[shift+start], array[shift+start + 1],

                             array[shift+start + 2], array[shift+start + 3]);

            break;

        }

     }

   return result;

  }
```

As a result, the function returns the created vector variable with the corresponding values.

This completes the OpenCL program. Next, we will continue working on the side of the main program (Host). MQL5 provides the [COpenCL](https://www.mql5.com/en/docs/standardlibrary/copencl) class in the standard library OpenCL.mqh for operations with OpenCL.

First, let's perform the preparatory work: we will include the standard library, load the previously created OpenCL program as a resource, and declare constants for the kernel, buffer, and program parameters indices. We will also specify the data type used in the program. I specified the float type because my laptop's integrated GPU does not support double.

```
#include <OpenCL/OpenCL.mqh>

#resource "mult_vect_ocl.cl" as string OCLprogram

#define TYPE                        float

const string ExtType = StringFormat("#define TYPE %s\r\n"

                                    "#define TYPE4 %s4\r\n",

                                    typename(TYPE), typename(TYPE));

//+------------------------------------------------------------------+

//|  Defines                                                         |

//+------------------------------------------------------------------+

#define cl_program                  ExtType+OCLprogram

//---

#define k_kernel                    0

#define k_source1                   0

#define k_source2                   1

#define k_result                    2

#define k_cols                      3
```

Let's declare an instance of the class for working with OpenCL and variables for storing data buffer handles.

```
COpenCL*                  cOpenCL;

int                       buffer_Source1;

int                       buffer_Source2;

int                       buffer_Result;
```

In the next step, we will initialize an instance of the class. To do this, we will create the OpenCL_Init function. In the function parameters, we will pass the matrix and the vector of input data.

In the function body, we will create an instance of the class for working with OpenCL, initialize the program, specify the number of kernels, and create pointers to the kernel and data buffers. We will also copy the input data into the context memory. At each step, we check the results of the operations, and in case of an error, we exit the method with a result of false. The function code is provided below.

```
bool OpenCL_Init(matrix<TYPE> &source1, vector<TYPE> &source2)

  {

//--- creation of OpenCL program, kernel and buffers

   cOpenCL = new COpenCL();

   if(!cOpenCL.Initialize(cl_program, true))

      return false;

   if(!cOpenCL.SetKernelsCount(1))

      return false;

   if(!cOpenCL.KernelCreate(k_kernel, "MultVectors"))

      return false;

   buffer_Source1 = CLBufferCreate(cOpenCL.GetContext(),

                                      (uint)(sizeof(TYPE) * source1.Rows() *

                                             source1.Cols()), CL_MEM_READ_ONLY);

   buffer_Source2 = CLBufferCreate(cOpenCL.GetContext(),

                                     (uint)(sizeof(TYPE) * source2.Size()),

                                            CL_MEM_READ_ONLY);
```

```
buffer_Result = CLBufferCreate(cOpenCL.GetContext(),

                                     (uint)(sizeof(TYPE) * source1.Rows()),

                                            CL_MEM_WRITE_ONLY);

   if(buffer_Result <= 0 || buffer_Source1 <= 0 || buffer_Source2 <= 0)

      return false;

   if(!CLBufferWrite(buffer_Source1,0,source1) ||

      !CLBufferWrite(buffer_Source2,0,source2))

     return false;

//---

   return true;

  }
```

The actual calculations will be carried out in the kernel. To run it, let's write the MultOCL function. In the function parameters, we will pass a pointer to the result vector and the dimensions of the input data matrix.

First, we will pass pointers to data buffers and parameters of buffer sizes to the kernel. These operations are performed by the CLSetKernelArgMem and SetArgument methods. We define the index space in the NDRange array according to the number of rows in the source data matrix. The kernel is launched for execution using the Execute method. After executing the entire array of kernel instances, we read the computation results from the device memory using the CLBufferRead method.

```
bool MultOCL(int rows, int cols, vector<TYPE> &result)

  {

   result=vector<TYPE>::Zeros(rows);

//--- Set parameters

   if(!CLSetKernelArgMem(cOpenCL.GetKernel(k_kernel), k_source1, buffer_Source1))

      return false;

   if(!CLSetKernelArgMem(cOpenCL.GetKernel(k_kernel), k_source2, buffer_Source2))

      return false;

   if(!CLSetKernelArgMem(cOpenCL.GetKernel(k_kernel), k_result, buffer_Result))

      return false;

   if(!cOpenCL.SetArgument(k_kernel, k_cols, cols))

      return false;

//--- Run kernel

   int off_set[] = {0};

   int NDRange[] = {rows};

   if(!cOpenCL.Execute(k_kernel, 1, off_set, NDRange))

      return false;

//--- Get result

   uint data_read = CLBufferRead(buffer_Result, 0, result);

   if(data_read <= 0)

      return false;

//---

   return true;

  }
```

After the program has finished running, it's necessary to release resources and delete the instance of the class for working with OpenCL. This functionality is performed in the OpenCL_Deinit function. In it, we will first check the validity of the pointer to the object, then call the Shutdown method to release resources, and finally delete the object.

```
void OpenCL_Deinit()

  {

   if(!cOpenCL)

      return;

//---

   cOpenCL.Shutdown();

   delete cOpenCL;

  }
```

Obviously, when using OpenCL, the amount of work for the programmer increases. What do we get in return?

To evaluate the performance, let's create a small script opencl_test.mq5. In the external parameters of the script, we specify the size of the input data matrix.

```
//+------------------------------------------------------------------+

//| External parameters                                              |

//+------------------------------------------------------------------+

sinput int Rows = 100000;   // Rows in a matrix

sinput int Colms = 100;     // Columns in a matrix
```

In the body of the script, let's declare the matrix and data vectors We will fill the input data with random values.

```
//+------------------------------------------------------------------+

//| Script Program                                                   |

//+------------------------------------------------------------------+

void OnStart()

  {

   matrix<TYPE> X = matrix<TYPE>::Zeros(Rows, Colms);

   vector<TYPE> Y = vector<TYPE>::Zeros(Colms);

   vector<TYPE> Z;

   for(int i = 0; i < Colms; i++)

     {

      for(int r = 0; r < Rows; r++)

         X[r, i] = MathRand() / (TYPE)32767;

      Y[i] = MathRand() / (TYPE)32767;

     }
```

In the next step, we will initialize the OpenCL context by calling the previously discussed OpenCL_Init function. At the same time, do not forget to check the results of the operations.

```
if(!OpenCL_Init(X, Y))

      return;
```

Now we can measure the speed of operations in the OpenCL context. Using the GetTickCount function, we get the number of milliseconds from the system start before and after the calculations. Calculations are feasible in the previously considered MultOCL function.

```
uint start = GetTickCount();

   if(!MultOCL(Rows, Colms, Z))

      Print("Error OCL function");

   uint end = GetTickCount();

   PrintFormat("%.1e OCL duration %0 000d msec, result %.5e",

                           Rows * Colms, end - start, Z.Sum());

   OpenCL_Deinit();
```

After performing the operations, we clear the OpenCL context.

In a similar manner, we will measure the execution time of operations using the classical method on the CPU.

```
start = GetTickCount();

   if(!MultCPU(X, Y, Z))

      Print("Error CPU function");

   end = GetTickCount();

   PrintFormat("%.1e CPU duration %0 000d msec, result %.5e",

                            Rows * Colms, end - start, Z.Sum());
```

In conclusion of the script, we will once again add a timing measurement for the matrix-vector multiplication using matrix operations in MQL5.

```
start = GetTickCount();

   Z = X.MatMul(Y);

   end = GetTickCount();

   PrintFormat("%.1e matrix operation duration %0 000d msec, result %.5e",

                                        Rows * Colms, end - start, Z.Sum());

  }
```

The described script was tested on a laptop with an Intel Core i7-1165G7 CPU and an integrated Intel(R) Iris(R) Xe GPU. Based on the measured execution times, the OpenCL technology emerged as the winner. The slowest was the classical implementation using the nested loops system. Furthermore, the computation results were identical in all three variants.

The results of the comparative testing of computations using OpenCL and without it are as follows:

It's important to note that when measuring the computation speed using OpenCL technology, we excluded overhead costs such as the initialization and deinitialization of the OpenCL context, program, buffers, and data transfer. Therefore, when performing individual operations, its usage might not be as efficient. However, as will be shown further, during the training and operation of neural networks, there will be many such operations, and the process of initializing the OpenCL context and program will only occur once, during the program launch. At the same time, we will try to minimize the process of data exchange between devices. Therefore, utilizing this technology will be highly beneficial.

## Program types and their construction features

The [MetaTrader 5 platform](https://www.metaquotes.net/en/metatrader5) package includes a modern development environment [MetaEditor](https://www.metatrader5.com/en/metaeditor/help) which enables the creation of various programs for algorithmic trading. Programs can be written in the specially designed programming language called MetaQuotes Language 5 (MQL5). The language syntax is closely aligned with C++, enabling programming in an object-oriented style. This facilitates the transition to using MQL5 for a large community of programmers.

The interaction of the MetaTrader 5 platform with programs is organized in such a way that the price movements of instruments and changes in the trading account are tracked by the platform. When predetermined changes occur, the platform generates [events](https://www.mql5.com/en/docs/runtime/event_fire) in the instrument chart open in the platform. When an event occurs, the user programs attached to the chart are checked. These can be software Expert Advisors, indicators, and scripts. [Event handlers](https://www.mql5.com/en/docs/basis/function/events) are defined in the platform for each event and program type.

An event handler is a special function defined by the MQL5 programming language. Such a function has a strictly specified name, return value type, and a list and type of parameters. Based on the return value type and the parameter types, the event handler of the client terminal identifies functions for processing the occurred event. If a function has parameters that do not match the predetermined ones or if a different return value type is specified, then such a function will not be used to process the event.

Built-in development environment MetaEditor

Each type of program can only handle certain events. Thus, if the event handler does not correspond to the program type, such a function will not be called by the terminal.

The MQL5 language includes a series of [trading functions](https://www.mql5.com/en/docs/trading) and predefined event handlers, which are used for Expert Advisors to allow them to execute the trading strategies embedded in them. It also offers an opportunity to write your own technical analysis indicators, scripts, services, and libraries of included functions.

Each program type is designed to perform its specific tasks and has special features of construction.

#### Expert Advisors (EAs)

Probably, at the forefront of algorithmic trading are Expert Advisors (trading robots) which are programs capable of independently analyzing the market and conducting trading operations based on a programmed strategy and its trading rules.

Technically, in MetaTrader 5, an Expert Advisor is tied to a specific chart on which it runs. In doing so, it only handles predefined [events](https://www.mql5.com/en/docs/basis/function/events) from this specific chart. The occurrence of each event triggers the corresponding functionality of the trading strategy. Among such events can be program launch and deinitialization, timer triggering, arrival of a new tick, scheduled events, and user events.

At the same time, the trading strategy of the Expert Advisor can include the analysis of other timeframes of the current instrument, as well as the analysis of any instrument in the terminal on any timeframe. This allows you to build multi-currency and multi-timeframe strategies.

In addition, Expert Advisors have the technical ability to receive data from any technical indicator installed in the terminal. This greatly expands the possibilities for building different trading strategies.

Each predefined event calls the corresponding EA function, in which the program code for event processing is written.

Immediately after launching the Expert Advisor, the terminal generates an Init event, which triggers the OnInit function. Global variables and objects are initialized in the body of this function. If necessary, a timer is started. The function has no input parameters but returns an integer value of the return code as a result of its execution. A non-zero return code indicates a failed initialization. In this case, the terminal generates a program termination event called Deinit.

```
//+------------------------------------------------------------------+

//| Expert initialization function                                   |

//+------------------------------------------------------------------+

int OnInit()

  {

//---

//--- create timer

   EventSetTimer(60);

//---

   return(INIT_SUCCEEDED);

  }
```

When the program is completed, the MetaTrader 5 terminal generates a Deinit event that triggers the execution of the OnDeinit function. The function has one input integer parameter which receives the code of the reason for the program termination. Inside the function body, if necessary, global variables, classes, and graphical objects are removed, data is saved in file resources, the timer initiated during program initialization is closed, and other operations required for the proper termination of the program and the cleanup of its traces in the terminal are performed.

```
//+------------------------------------------------------------------+

//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+

void OnDeinit(const int reason)

  {

//---

//--- destroy timer

   EventKillTimer();

  }
```

When a new tick arrives for the symbol chart on which the Expert Advisor is running, the NewTick event is generated. This triggers the OnTick function. This event is generated only for Expert Advisors, so the OnTick function will not be launched in other programs. Of course, the specified function can always be called forcibly from any place in the program, but it will no longer be the NewTick event processing.

The OnTick function has no input parameters and does not return any code. The main purpose of the function is to execute the price fluctuations handler in the advisor, which evaluates changes in the market situation and checks the rules of the embedded strategy for the need to perform any trading operations. Sometimes, according to the trading strategy rules, the Expert Advisor should perform operations not at every price movement, but, for example, at the opening of a new candlestick. In such cases, checking for the occurrence of the expected event is added to the OnTick function.

```
//+------------------------------------------------------------------+

//| Expert tick function                                             |

//+------------------------------------------------------------------+

void OnTick()

  {

//---

  }
```

If the algorithm of an Expert Advisor does not require the processing of each price movement but is based on the execution of cyclic operations with a certain time interval, even if there are no price movements observed during this time, the use of a timer can be very beneficial.

For this, when initializing the program in the OnInit function, it is necessary to initialize the timer using the EventSetTimer function. The function parameters specify the timer delay period in seconds. After that, the terminal will generate a Timer event for the chart, and the OnTimer function of the Expert Advisor will be launched for execution.

```
//+------------------------------------------------------------------+

//| Timer function                                                   |

//+------------------------------------------------------------------+

void OnTimer()

  {

//---

  }
```

When using a timer in the program's code, it is necessary to unload it from the terminal's memory upon program termination within the OnDeinit function. The EventKillTimer function is used for this purpose. This function has no parameters. It should be noted that the platform provides for the use of only one timer on the chart.

Within one EA, you can use both the OnTick and OnTimer functions, if necessary.

Among Expert Advisors, there is a subclass of semi-automatic Expert Advisors and trading panels. Such programs are not capable of independent trading without human intervention. Programs of this type perform trading operations at the trader's command. The programs themselves are designed to facilitate the trader's work and to take over some routine operations. This can be money management, setting stop loss and take profit levels, position maintenance, and much more.

The interaction between the program and the user is implemented through ChartEvent group events in Expert Advisors. These events trigger the execution of the OnChartEvent function, which accepts four parameters from the terminal:

- id: event identifier,

- lparam: event parameter of type long,

- dparam: event parameter of type double,

- sparam: event parameter of type string.

```
//+------------------------------------------------------------------+

//| ChartEvent function                                              |

//+------------------------------------------------------------------+

void OnChartEvent(const int id,

                  const long &lparam,

                  const double &dparam,

                  const string &sparam)

  {

//---

  }
```

The event can be generated for Expert Advisors and technical indicators. In this case, for each type of event, the input parameters of the function have certain values required to process the event.

#### Technical indicators

Another program type is a custom indicator. Indicators are programs that perform analytical functions to assist traders in conducting technical analysis of the market situation. During their operation, indicators process each price movement on the chart of their trading instrument. They can display various graphical objects, thus generating signals for subsequent analysis by the trader.

Like Expert Advisors, custom indicators can use data from other indicators, instruments, and timeframes in their calculations. But at the same time, indicators cannot perform trading operations. Thus, the indicator application scope is limited to the framework of technical analysis.

Similar to Expert Advisors, technical indicators have Init, Timer, and ChartEvent event handlers. The construction of functions for processing these events is similar to the corresponding functions of electronic Expert Advisors, but instead of the NewTick event, the Calculate event is generated for indicators. This event is handled by the OnCalculate function. There are two types of OnCalculate function depending on the scope of the indicator:

- shorthand

```
//+------------------------------------------------------------------+

//| Custom indicator iteration function                              |

//+------------------------------------------------------------------+

int OnCalculate (const int rates_total,

                 const int prev_calculated,

                 const int begin,

                 const double& price[]

  {

//---

//--- return value of prev_calculated for the next call

   return(rates_total);

  }
```

- full

```
//+------------------------------------------------------------------+

//| Custom indicator iteration function                              |

//+------------------------------------------------------------------+

int OnCalculate(const int rates_total,

                const int prev_calculated,

                const datetime &time[],

                const double &open[],

                const double &high[],

                const double &low[],

                const double &close[],

                const long &tick_volume[],

                const long &volume[],

                const int &spread[])

  {

//---

//--- return value of prev_calculated for the next call

   return(rates_total);

  }
```

Within a single indicator, you can only use one of the versions of the function.

Both versions of the OnCalculate function have parameters:

- rates_total: number of items in the timeseries,

- prev_calculated: number of recalculated elements of the time series at the previous run of the function.

The use of the prev_calculated parameter allows you to implement algorithms in which the indicator does not recalculate previously calculated historical values. This reduces the number of iterations in processing each new price fluctuation.

The work of indicators in the MetaTrader 5 terminal is organized as follows. The prev_calculated parameter receives the value that the function returned at the previous run. Therefore, in the general case, at the end of a successful function completion, it's sufficient to return the value of the rates_total parameter. If errors occur while the function is running, you can return the current value of prev_calculated. In this case, the function will start recalculating from the current location the next time it is run. If you return 0, upon the next launch, the indicator will be recalculated for the entire history, as it was during the initial launch.

When defined briefly, the function has only one input array of time series (price) and a parameter for shifting significant values relative to the beginning of the time series (begin). In this version, the calculation of indicator values is based on the data of one time series. Which time series will be used is set by the trader when launching the technical indicator. This can be either any of the price time series or the buffer values of another indicator.

When using the full version of the OnCalculate function, the function gets all price time series in its parameters. In such a case, the user does not have the option to choose a time series when launching the indicator. If it's necessary to use a buffer of data from another indicator, it needs to be explicitly written in the program code of the indicator.

In MetaTrader 5, there is a limitation in the ability to run only one Expert Advisor for each chart. If you need to run two or more Expert Advisors in one terminal, you should open an individual chart for each Expert Advisor. There is no such limitation for indicators as MetaTrader 5 allows you to use built-in and custom indicators in different versions in parallel on one chart of a trading instrument. The indicator can display data both on the price chart of the instrument itself and in sub-windows.

#### Scripts

Following launching, Expert Advisors and custom indicators remain in the terminal memory until they are forcibly closed by the trader. As certain events occur, the terminal launches the relevant functionality of Expert Advisors and indicators. Scripts are provided to perform any one-time operations. This is a separate type of program that does not handle any events other than its startup event.

Immediately after being launched, they perform the designated functionality and are unloaded from the terminal's memory. Along with Expert Advisors, scripts are able to perform trading operations, but it is impossible to run more than one script on a symbol chart at the same time.

There is only one OnStart event handler in the body of the script, which is launched immediately after the program starts. The OnStart function does not receive any parameters and does not return any codes.

```
//+------------------------------------------------------------------+

//| Script program start function                                    |

//+------------------------------------------------------------------+

void OnStart()

  {

//---

  }
```

A separate program type is Services. Unlike the aforementioned types of programs, a service does not require binding to a specific price chart of a trading instrument. Just like scripts, services do not process any events other than their own launch. However, they are capable of generating custom events themselves and sending them to charts for further processing in Expert Advisors.

The MetaEditor development environment provides the possibility to create libraries and include files. These files are designed to store and distribute frequently used program blocks. Libraries are compiled files and provide individual functions for export to other running programs. The code of the executed functions itself is hidden. Plug-in files, unlike libraries, are open-source files. In terms of performance, it's preferable to use include files, but they do not ensure code secrecy during distribution.

In addition to event handlers, all programs can contain other functions and classes that will need to be called from the event handler functions. They can also have external input parameters set by the user when the program is launched.

Another technical aspect should also be taken into consideration. MetaTrader 5 is positioned as a platform with multi-threaded computing. In this case, three threads are allocated for each trading instrument's chart: one for the Expert Advisor, one for the script, and one for indicators. All indicators loaded onto one trading instrument's chart operate within the same thread as the chart itself. Therefore, it's not recommended to perform complex calculations within indicators.

Hence, we can use EAs or scripts to build our neural network.

## Integration with Python

Python is a high-level programming language with dynamic typing and automatic memory management. It is oriented towards improving developer productivity and code readability, and it belongs to fully object-oriented programming languages.

Python belongs to interpreted programming languages. It is often used to create scripts.

The syntax of the language is minimalistic, which increases the productivity of the programmer. In conjunction with the language interpretability, this allows for quick coding and immediate testing of individual program components. This helps reduce the time spent on finding and fixing errors during debugging of software products, and in some cases, it enables the evaluation of solution effectiveness at the design stage without the need to create a complete product.

At the same time, interpreted programming languages are noticeably inferior to compiled ones in terms of program execution speed. The solution to this problem lies within the Python architecture itself. It is designed so that its small core can be easily extended with a set of libraries, including those written in compiled programming languages.

Thus, Python can be compared to a constructor in which programs are assembled from ready-made blocks that are already written and defined in libraries. This explains the large number of standard libraries. Moreover, in your program, you utilize only the functionality that is necessary to solve a specific task.

An unusual feature of the language is the use of whitespace indentation to denote code blocks. If you're accustomed to the clear delineation of code blocks with curly braces in C-like languages, this might seem inconvenient. On the other hand, structuring the program code makes it visually understandable. One glance at the code is enough to determine the presence of nested blocks and their boundaries.

At the same time, this places a certain responsibility on the programmer. While in languages where the compiler checks for the presence of opening and closing braces and issues an error message if they don't match, in the case of structuring code with indentation, the responsibility lies entirely on the programmer. In this case, an incorrect structure can change the course of program execution.

Dynamic typing allows the programmer to be less concerned about data compatibility when storing them in variables, as the variables will automatically acquire the type of data being assigned.

The standard library contains a large set of useful functions. There are tools for working with text, and for writing network applications.

Additional functionality can be implemented using a wide range of third-party libraries. Among them, you can find tools for mathematical modeling, and for writing web applications, and for developing games. In addition, there is the possibility of integrating libraries written in C or C++ and other languages.

A specialized software repository has been created for software written in Python, which provides tools for easy installation of packages into the operating system. Among the repository libraries, you can find functions to suit any preference, including those for currency markets and machine learning.

Considering all the above, Python has become one of the most popular programming languages. It is used in data analysis and machine learning. As of July 2021, Python is ranked third in the TIOBE Programming Language Popularity Rankings with a score of 10.95%.

Starting the with Build 2085 version, released in June 2019, MetaTrader 5 received API for requesting data from the terminal to Python applications. Since then, this functionality has been constantly developed. Currently, you can run Python scripts directly on the terminal chart along with MQL5 applications.

At the same time, the functionality of Python applications is also expanding. You can fetch quotes from the terminal for analysis and based on the analysis results, open and close positions, and set pending orders. There's also the capability to retrieve information about the current account status, open positions, and orders. For a complete list of features, see the [Python integration documentation page](https://www.mql5.com/en/docs/python_metatrader5).

To set up a Python connection to MetaTrader 5, you first need to download and install the latest version of the interpreter from [https://www.python.org/downloads/windows/](https://www.python.org/downloads/windows/).

When installing Python, be sure to check the "Add Python 3.9 to PATH%" checkbox (version may vary) to be able to run Python scripts from the command line.

After that, launch and update the MetaTrader5 module. In this case, we are talking about the Python library, not the terminal. To do this, enter the following commands at the command prompt.

```
pip install MetaTrader5

pip install --upgrade MetaTrader5
```

After these iterations, Python scripts will be able to access operations with the MetaTrader 5 terminal.

MetaEditor also has Python support. In the editor settings on the "Compilers" tab, all you need to do is specify the location of the interpreter.

After that, you can create multilingual projects in the MetaEditor integrated environment. Such projects will include programs written in MQL and Python. Similarly, you can add support for the C/C++ language.

Python integration in MetaEditor

## Statistical analysis and fuzzy logic tools

The [MetaEditor](https://www.metatrader5.com/en/metaeditor/help) development environment provides a separate type of include files with the mqh extension, which enable the exchange of frequently used code blocks. MetaQuotes delivers MetaTrader 5 with a vast Standard Library, which includes classes and methods for implementing a wide variety of tasks. This includes classes available for analyzing data using mathematical statistics and fuzzy logic.

The library of mathematical statistics offers functionality for working with basic statistical distributions. It has more than twenty distributions and five features are presented for each:

1. Calculation of distribution density.

2. Calculation of probabilities.

3. Calculation of distribution quantiles.

4. Generation of random numbers with a given distribution.

5. Calculation of theoretical distribution moments.

The library also allows you to calculate the statistical characteristics of a given data set. With the help of this library, one can easily perform statistical analysis of a sample from the historical data of the analyzed instrument. You can also compare the statistical indicators of several instruments and observe the dynamics of the statistical indicators of one instrument based on historical data from different time intervals.

Additionally, one can conduct a multifaceted and comprehensive analysis, and use its results as the foundation for building one's trading system.

Before discussing the capabilities of the fuzzy logic library, let us consider the concept itself. The concept of fuzzy logic was proposed by American scientist Lotfi Zadeh in 1965. This innovation allows the addition of a certain share of subjectivity inherent in real life to calculations. After all, you'll agree that when describing certain objects and processes, we often use vague and approximate reasoning.

We often hear the phrase "Words are used out of context." This suggests that the interpretation of words and their use in speech is highly dependent on the context. It is also difficult to describe a single candlestick on a chart. We can tell what color it is and mention the presence of shadows. But you'll agree, with such a description, we can divide all candlesticks into two classes based on their color. In fuzzy logic theory, these would be two sets.

Candlesticks

For further description, we will need to introduce additional concepts and measurements. We can compare a candlestick with neighboring candlesticks, calculate some kind of average, or take some kind of benchmark and compare to it. In doing so, we again get an inaccurate description. The deviation from our benchmark or average can vary, just as the influence of a factor can change significantly depending on the size of this deviation. The application of fuzzy logic allows us to solve this problem by introducing "fuzzy" set boundaries.

Three stages are distinguished in the history of fuzzy systems development:

- 1960-70s: development of theoretical aspects of fuzzy logic and fuzzy sets;

- 1970s-80s: the first practical results in the field of fuzzy systems control;

- From the 1980s to the present day: the creation of various software packages for constructing fuzzy systems significantly broadens the application scope of fuzzy logic.

Let us review the basic concepts of fuzzy set theory.

First, it is a fuzzy set, that is, a set of values unified by some rules.

The mathematical description of these rules is combined into a membership function which is a characteristic of a fuzzy set and is denoted by MFC(x) — the degree of the x value membership in the fuzzy set C.

The set of values of initial data satisfying the membership function is called the term set.

A collection of fuzzy sets and their rules are combined into a fuzzy model (system).

The results of the fuzzy model operation are determined from a combination of fuzzy sets using a system of fuzzy logical inferences. The MQL5 fuzzy logic library implements the Mamdani and Sugeno fuzzy logic inference systems.

To understand the differences between the usual mathematical description and the fuzzy logic membership function, let us consider an example of the description of a Doji candlestick (a candlestick without a body). Such candlesticks often act as harbingers of a trend change, as they appear in the area of supply and demand equilibrium.

In practice, it's rare to encounter a candlestick with a zero body size, where the opening price equals the closing price with mathematical precision. Therefore, some sort of tolerance is used when specifying a Doji. For example, let's assume that a Doji candlestick is any candlestick with a body of no more than 5 pips.

With such an assumption, using conventional logic, candlesticks with a body size of 1 point and 4 points will be classified as Doji and will have the same value for the strategy being used. At the same time, a candlestick with a body of 6 pips will no longer fall into the Doji category and will be ignored by the strategy. Why is it that a deviation of 3 points in the first case (4 - 1 = 3) doesn't matter, but a smaller deviation of 2 points (6 - 4 = 2) in the second case makes a fundamental difference? The application of fuzzy logic can smooth out these angles and account for deviations in both cases.

The figure below shows the chart of assigning a candlestick to the Doji class (set) depending on the length of the candlestick body. The red line represents the classical mathematical logic with the previously accepted allowance, and the green line reflects the rule of fuzzy logic. As we can see from the graph, the use of fuzzy logic rules will allow us to make decisions depending on the strength level of the incoming signal. For instance, if the candlestick body is larger and approaches the boundaries of the fuzzy set, we can reduce the risk for the operation or even ignore such a signal.

Mathematically, the function showing the membership of a candlestick in the Doji fuzzy set can be represented as:

Graph of assigning a candle to the Doji class (red - mathematical logic, green - fuzzy logic)

In this case, we have obtained a special case of the symmetric triangular activation function. To define it, in fact, we needed only one parameter a which stands for boundary of the the range of 5 points. The center of the distribution is at point 0. In the general case, to define a triangular membership function, three parameters are required: the lower bound, the center, and the upper bound of the fuzzy set.

There are other membership functions, but the most widespread are the aforementioned triangular, trapezoidal, and Gaussian membership functions. Meanwhile, the triangular and trapezoidal functions can be symmetric (when the left and right zones of boundary fuzziness are equal) and asymmetric.

The graph of a trapezoidal function differs from the graph of a triangular function by the presence of a plateau in the upper part. To define such a function, four points are required, indicating the upper and lower boundaries of the left and right zones of fuzziness. Between the blur zones, the function takes the value 1, and to the left and right of these zones, it takes the value 0. For instance, let's introduce a rule to determine the size of the body of an average candlestick with a body size ranging from 5 to 15 points and a fuzziness boundary zone of 5 points. The mathematical notation of such a rule will take the form:

Thus, we have already defined the second rule for the candlestick body. It is common to show the set of rules for a single variable on a single graph. In the chart below, the red triangular term represents the Doji candlestick, and the green trapezoidal term represents the average candlestick.

The aggregate term sets of Doji (red) and the average statistical candlestick (green).

Please note that on the graph, there is no sharp division between the Doji and the average candlestick at the 5-point mark, as it would be with threshold classification. Instead, we have a line crossing at about 2.5 points. In this case, the membership function will take a value of about 0.5. This means that a candlestick with a body of 2.5 points is equally applicable to the fuzzy Dodgy and medium candlestick sets. In such a case, secondary factors should be looked at to determine the controlling influence.

Continuing such iterations, we can describe the rules for a candlestick with a large body, as well as add rules for the candlestick shadows. Once we have done the work of defining the rules for describing candlesticks and their components, we will be able to describe various candlestick patterns with ease. For example, we can use fuzzy logic tools to describe a pin bar in quite a simple way by definition: a candlestick with a long one shadow, a small body, and a small or absent second shadow.

Note that using the rules of fuzzy logic allows us to move from clear values to some abstract definitions and approximate reasoning inherent in human logic. Therefore, the concepts of linguistic and fuzzy variables are introduced in fuzzy logic theory.

The linguistic variable has:

- A name, in the above examples it is "Candlestick Body";

- A set of its values referred to as the base termset. In our case, these are the Doji, Medium (regular) and Large candlesticks;

- A set of permitted values;

- A syntactic rule that describes terms using natural language words;

- A semantic rule defining the correspondence between the values of a linguistic variable and a fuzzy set of valid values.

In general practice, the fuzziness of the boundaries of fuzzy sets allows us to consider the natural symbiosis of the influence of different forces in the areas of their intersection. It also allows us to account for the fact that the effect of the force fades as the distance from the source of the impact increases.

The presence of fuzzy rules is an important, but not the sole, part of constructing a model. The process of fuzzy model building can be divided into three conventional stages:

1. Selecting baseline data

2. Defining a knowledge base (set of rules)

3. Defining the fuzzy logic inference method

It is quite natural that the entire construction process depends on the initial stage: the determination of the set of source data influences both the overall possibility of their classification and the number of possible classes (terms). Consequently, the set of rules (as well as their filling) for defining fuzzy sets is also determined based on the set of permitted values and the task at hand. It should be noted that even for the same set of input data, the underlying term set and rule set may vary depending on the task at hand.

Very often the parameters of the rules for defining fuzzy sets are strongly influenced by the subjective knowledge and experience of the model architect. Therefore, the practice of hybrid models has become widespread. In them, the parameter selection of rules is carried out by a neural network during its training on a training dataset.

Based on the created knowledge base, a fuzzy logic inference system is defined in the model. Fuzzy logical inference is the process of obtaining a fuzzy set that corresponds to the current input values, using fuzzy rules and fuzzy operations.

A number of logical operations have been developed for fuzzy sets, just as for regular sets. The main ones are union (fuzzy OR) and intersection (fuzzy AND). There is a general approach to performing fuzzy intersection, union, and complement operations.

To build the process of fuzzy logical inference, the MQL5 library offers the implementation of two main methods: [Mamdani](https://www.mql5.com/en/docs/standardlibrary/mathematics/fuzzy_logic/fuzzy_system/cmamdanifuzzysystem) and [Sugeno](https://www.mql5.com/en/docs/standardlibrary/mathematics/fuzzy_logic/fuzzy_system/csugenofuzzysystem).

When using the Mamdani method, the value of the output variable is defined by a fuzzy term. The fuzzy rule of this method can be described as follows:

Where:

- X = a vector of input variables

- Y = an output variable

- a = a vector of initial data

- d = a value of the output variable

- W = the rule weight

In the Sugeno method, unlike Mamdani, the value of the output variable is determined not by a fuzzy set but by a linear function of the input data. The rule of this method is of the form:

where b is the vector of weights at free terms of the output value function.
