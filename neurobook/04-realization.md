# Chapter 04: Building the First Neural Network Model in MQL5

*Source: [https://www.mql5.com/en/neurobook/index/realization](https://www.mql5.com/en/neurobook/index/realization)*

---

## Building the first neural network model using MQL5

This book should not be regarded as a textbook for studying artificial intelligence and neural networks. Its purpose is not to serve as a comprehensive work that encompasses all aspects of this field. On the contrary, the book provides only the basic concepts without delving into the mathematical explanations of specific points.

It aims to be a practical work. We invite you to explore possible solutions to a practical case and compare the effectiveness of different algorithms in solving a particular problem. We believe this book will be useful in studying the practical implementation of various neural network algorithms, their training, and practical use.

And, of course, our case study will be directly related to financial markets. Artificial intelligence technologies have long been used in the financial sector, but this topic has not yet received wide coverage. This is largely due to the commercial use of such products.

This chapter delves into the topic of algorithmic trading, with an emphasis on demonstrating various methodologies for addressing tasks related to algorithmic trading, as well as analyzing and comparing the performance of different algorithmic approaches. The discussion is based on a clear [statement of the problem](https://www.mql5.com/en/neurobook/index/realization/task), which includes defining key objectives and constraints specific to the financial markets context.

A separate section covers the [selection and analysis of raw data](https://www.mql5.com/en/neurobook/index/realization/initial_data), including the choice of suitable financial metrics and the analysis of their correlations. It also explains the features of time series, which are critically important for successfully forecasting market movements. Also, the chapter shows how to create the [framework of the future program](https://www.mql5.com/en/neurobook/index/realization/basic) in MQL5 and how to declare constants to ensure code robustness and portability. You will learn how to describe the structure of the created neural network and how to effectively organize work with complex network architectures.

In the section on [creating the base neural network class](https://www.mql5.com/en/neurobook/index/realization/basic/neuron_base), you will be introduced to the concepts of feed-forward and backpropagation runs in the context of neural network programming. Special attention is given to dynamic arrays for storing neural layers, greatly simplifying the management of complex data structures during the development process.

The description of methods for integrating a neural network into a Python program provides an understanding of how various components of a neural network can be combined into a single system using the capabilities of this popular programming language. The section on the [fully connected neural layer](https://www.mql5.com/en/neurobook/index/realization/perceptron) provides details about its architecture and creation principles, explaining the general structure and operation of such layers in neural networks. In addition, it covers the process of creating an activation function class and selecting appropriate activation functions.

The section on [parallel computing using OpenCL](https://www.mql5.com/en/neurobook/index/realization/pr_opencl) demonstrates how this technology can be used to speed up computational processes in neural networks. This solution can significantly increase the efficiency of data processing by distributing tasks among several computing devices.

## Creating the framework for the future MQL5 program

In the previous section, we talked about preparatory work and methods for selecting indicators for analysis by a neural network. After conducting the analysis, we have determined a set of indicators to train the neural network and the depth of historical data to be loaded.

Now let's move on to the practical part of our book. We will look at various neural network algorithms and architectures. You will learn the specifics of constructing and implementing a fully connected perceptron, convolutional neural networks, and recurrent neural networks. After that, we will discuss the features and advantages of attention mechanisms. Finally, we will look at the GPT architecture, which, at the time of writing the book, demonstrates the best results in natural language processing problems.

As we explore the algorithms, step by step, we will create a tool for designing and organizing neural networks using MQL5. Each algorithm under consideration will be implemented in three versions: MQL5, OpenCL, and Python.

We will build and train neural networks using all the learned algorithms. Then, we will practically assess the strengths and weaknesses of their use for time series forecasting. We will train and test the built models on real data. And, of course, during the training process, we will discuss the nuances of this process.

The book will showcase the practical results of using neural networks to solve the problem defined in the previous sections, using real-world data. During testing, we will conduct a comparative analysis of various implementations and evaluate the practical effectiveness of each implementation in solving the given problem.

Let's begin working on refining the architecture of our future tool. It's quite logical to consolidate our entire development into a single entity (class) that can be easily integrated into any program. This way, we'll be able to configure the entire operation of our model within this class.

At the same time, we need to ensure the ability to create models of various architectures within our main model. The architecture of the model itself will be defined in the main program and passed to the class through created interfaces. To make this process convenient and easy to use, it is necessary to standardize it. To address standardization matters, we will use constants and named enumerations.

## Neural network base class and organization of forward and backward pass processes

We have already done preparatory work to create constants and an interface for transferring the architecture of the created neural network. Lets continue. Now I propose to move on to creating a top-level class CNet, which will act as the manager of our neural network.

To do this work, we will create a new included library file neuronnet.mqh in a [subdirectory](https://www.mql5.com/en/neurobook/index/realization/basic/constants#full_path) of our library. In it, we will collect all the code of our CNet neural network class. Next, we will create a separate file for each new class. File names will correspond to the names of the classes — this will allow for structuring the project and quickly accessing the code of a specific class.

We won't be able to write the complete code for the methods of this class right now, as during their implementation we will need to refer to the neural layer classes and their methods. There are currently no such classes. Why have I decided to start by creating the top-level object instead of creating the lower-level objects first? Here, I am addressing the issue of the integrity of the structure and the standardization of methods and data transfer interfaces between individual blocks of our neural network.

Later, when examining the architectural features of the neural layers, you will be able to notice differences in their functionality and, to some extent, in the information flow. When solving the problem from the bottom up, we run the risk of obtaining quite different methods and interfaces, which will then be difficult to integrate into a unified system. On the contrary, I want to create a top-level "skeleton" of our development right from the beginning, and later fill it with functionality. By early planning the architecture and functionality of the interfaces, we will simply integrate new neural layer architectures into the already established information flow.

Let's define the functionality of the CNet class. The first thing this class should do is directly assemble the neural network with the architecture provided by the user. This can be done in the class constructor, or you can create a separate method, Create. I picked the second option. Using the base class constructor without parameters will allow us to create an "empty" class instance, for example, to load a previously trained neural network. It will also make it easier to inherit the class for possible future development.

Since we have started on the issue of loading a pre-trained network, the following class functionality follows from here: saving (Save) and loading (Load) our model.

Whether it is newly created (generated) neural layers or loaded from a file, we will need to store them and work with them. When elaborating and defining constants, we allocated a separate constant for the dynamic array storing the neural layers. We will add an instance of this object to the class variables (m_cLayers).

Let's take a look at how the work of the neural network is organized. Here we need to implement feed-forward pass (FeedForward) and backpropagation pass (Backpropagation) algorithms. Let's display the process of updating the weights UpdateWeights as a separate method.

Of course, you can update the weights in the backpropagation method, which is what is most commonly encountered in practice. But we're talking about a universal constructor. At the time of writing the code, we don't know if batch normalization (batch size) will be used. Therefore, there is no clear understanding at what point it will be necessary to update the weights.

A complex problem is always easier to solve step by step. Dividing a process into smaller subprocesses makes it easier to both write code and debug it. Therefore, I decided to separate the process of updating the weights.

Let's recall the [neuron optimization](https://www.mql5.com/en/neurobook/index/about_ai/study/optimization) methods. Almost all methods use a learning rate, and some require additional parameters, such as decay coefficients. We also need to allow the user to specify them. In this case, the user specifies once, and we will need them at each iteration. So we need to store them somewhere. Let's add a method for specifying learning parameters (SetLearningRates) and variables for storing data (m_dLearningRate and m_adBeta). For the decay coefficients, we will create a vector of two elements, which, in my opinion, will make the code more readable.

In the process of practical use of a neural network, the user may need to obtain the results of processing of the same source data several times. This option should be possible. However, in order not to make a direct pass every time, we will output the possibility of obtaining the results of the last direct pass using a separate GetResults method.

In addition, in the process of training and operating the neural network, we will need to control the process of accuracy and correctness of the forward pass data. The main indicator of the neural network's correct operation is the value of the loss function. The actual calculation of the loss function will be carried out in the Backpropagation method. The calculated value of the loss function will be stored in the m_dNNLoss variable. Let's add the GetRecentAverageLoss method to display the variable value at the user's request.

Now, speaking of the loss function. A specific loss function should be selected by the user. Therefore, we need a method to be able to get it from the user (LossFunction). The actual calculation of the value of the loss function will be carried out by standard means of matrix operations in MQL5. Here we will create a variable to store the type of the loss function (m_eLossFunction).

When defining constants, we didn't create a separate enumeration for regularization methods. Then we agreed to implement Elastic Net and manage the process through regularization coefficients. I suggest adding the specification of regularization coefficients to the loss function method. After all, look at how the number of class methods grows. Therefore, the question is not only in the implementation of our constructor. On the contrary, when building the constructor, all possible usage scenarios should be anticipated. This will help make it more flexible.

At the same time, the actual use of such a constructor should be as easy and intuitive as possible. In other words, we should provide the user with an interface that allows for the most flexible configuration of a new neural network with the minimum number of iterations required from the user.

Note that the algorithm of the normalization layers and Dropout differ depending on the mode of use (training or operation). Of course, this could have been done as a separate parameter in the forward and backward pass methods, but it's important to have a clear correspondence between the operations of the forward and backward passes. Performing a backward pass in training mode after a working forward pass and vice versa can only destabilize the neural network. Therefore, to avoid overloading the aforementioned methods with additional checks, we'll create separate functions to set and query the TrainMode operating mode.

There's another aspect regarding the operating mode of the neural network, specifically, the choice of tool for conducting computational operations. We have already discussed the topic of using [OpenCL](https://www.mql5.com/en/neurobook/index/algotrading/opencl) technology for parallel computing. This will allow parallel computation of mathematical operations on the GPU and speed up calculations during the operation of the neural network. The standard MQL5 library OpenCL.mqh provides the COpenCL class for working with OpenCL.

In the process of working with this class, I decided to slightly supplement its functionality, for which I created a new class CMyOpenCL that inherits the standard COpenCL class. Inheritance allowed me to write the code for just a couple of methods while still utilizing the full power of the parent class.

To use the CMyOpenCL class, add a pointer to an instance of the m_cOpenCL class. We will also add the m_bOpenCL flag, which will inform you if the functionality is enabled in our neural network. We will also add methods for initializing the functionality and managing it (InitOpenCL, UseOpenCL).

Let's not forget that we plan to use neural networks to work with timeseries. This leaves a certain imprint on their work. Do you remember the time-shift correlation score plot of the [initial data](https://www.mql5.com/en/neurobook/index/realization/initial_data)? As the time lag increases, the impact of the indicator on the target result decreases. This once again confirms the importance of taking into account the position of the analyzed indicator on the timeline. Therefore, it will be necessary to implement such a mechanism.

We will talk about the method itself a little later. For now, let's create an instance of the CPositionEncoder class to implement positional encoding. We will also create a flag for controlling the activity of the function and declare methods for managing the function.

Let's add another class identification method to our list and get the following CNet class structure.

```
class CNet  : public CObject

  {

protected:

   bool               m_bTrainMode;

   CArrayLayers*      m_cLayers;

   CMyOpenCL*         m_cOpenCL;

   bool               m_bOpenCL;

   TYPE               m_dNNLoss;

   int                m_iLossSmoothFactor;

   CPositionEncoder*  m_cPositionEncoder;

   bool               m_bPositionEncoder;

   ENUM_LOSS_FUNCTION m_eLossFunction;

   VECTOR             m_adLambda;

   TYPE               m_dLearningRate;

   VECTOR             m_adBeta;
```

```
public:

                      CNet(void);

                     ~CNet(void);

   //--- Methods for creating an object

   bool               Create(........);

   //--- Organization of work with OpenCL

   void               UseOpenCL(bool value);

   bool               UseOpenCL(void)          const { return(m_bOpenCL);          }

   bool               InitOpenCL(void);
```

```
//--- Methods of working with positional coding

   void               UsePositionEncoder(bool value);

   bool               UsePositionEncoder(void) const { return(m_bPositionEncoder); }

   //--- Organization of the basic algorithms of the model

   bool               FeedForward(........);

   bool               Backpropagation(........);

   bool               UpdateWeights(........);

   bool               GetResults(........);

   void               SetLearningRates(TYPE learning_rate, TYPE beta1 = defBeta1,

                                                           TYPE beta2 = defBeta2);

   //--- Methods of the loss function

   bool               LossFunction(ENUM_LOSS_FUNCTION loss_function,

                          TYPE lambda1 = defLambdaL1, TYPE lambda2 = defLambdaL2);

   ENUM_LOSS_FUNCTION LossFunction(void)       const { return(m_eLossFunction);    }

   ENUM_LOSS_FUNCTION LossFunction(TYPE &lambda1, TYPE &lambda2);
```

```
TYPE               GetRecentAverageLoss(void) const { return(m_dNNLoss);        }

   void               LossSmoothFactor(int value)   { m_iLossSmoothFactor = value; }

   int                LossSmoothFactor(void)   const { return(m_iLossSmoothFactor);}

   //--- Model operation mode control

   bool               TrainMode(void)          const { return m_bTrainMode;        }

   void               TrainMode(bool mode);

   //--- Methods for working with files

l   virtual bool      Save(........);

   virtual bool       Load(........);

   //--- object identification method

   virtual int        Type(void)               const { return(defNeuronNet);       }

   //--- Retrieving pointers to internal objects

   virtual CBufferType* GetGradient(uint layer)     const;

   virtual CBufferType* GetWeights(uint layer)      const;

   virtual CBufferType* GetDeltaWeights(uint layer) const;

  };
```

You can note that in the declaration of several methods, I left ellipsis instead of specifying parameters. Now we will analyze the class methods and add the missing data.

Let's start with the class constructor. In it, we initialize the variables with initial values and create instances of the classes used.

```
CNet::CNet(void)     :  m_bTrainMode(false),

                        m_bOpenCL(false),

                        m_bPositionEncoder(false),

                        m_dNNLoss(-1),

                        m_iLossSmoothFactor(defLossSmoothFactor),

                        m_dLearningRate(defLearningRate),

                        m_eLossFunction(LOSS_MSE)

  {

   m_adLambda.Init(2);

   m_adBeta.Init(2);

   m_adLambda[0] = defLambdaL1;

   m_adLambda[1] = defLambdaL2;

   m_adBeta[0]   = defBeta1;

   m_adBeta[1]   = defBeta2;

   m_cLayers     = new CArrayLayers();

   m_cOpenCL     = new CMyOpenCL();

   m_cPositionEncoder = new CPositionEncoder();

  }
```

In the class destructor, we will clear the memory by deleting the instances of the previously created objects.

```
CNet::~CNet(void)

  {

   if(!!m_cLayers)

      delete m_cLayers;

   if(!!m_cPositionEncoder)

      delete m_cPositionEncoder;

   if(!!m_cOpenCL)

      delete m_cOpenCL;

  }
```

Lets consider the Create method that creates a neural network. I omitted the parameters of this method earlier, and now I suggest we discuss them.

The interface for passing the structure of a neural network to a class was described in the previous chapter. Of course, we will pass it to this method. But is this data enough or not? From a technical perspective, this data is quite sufficient to specify the architecture of the neural network. We have provided additional methods for specifying learning rates and loss functions.

But if we look at the question from the user's perspective: how convenient is it to use three methods to specify all the necessary parameters when initializing the neural network? In fact, it is a matter of personal habits and preferences of the user. Some prefer to use multiple methods specifying one or two parameters and monitor the process at each step. Others would prefer to 'throw' all the parameters into one method in a single line of code, check the result once, and move on.

When we work directly with the customer, we can discuss their preferences and make the product convenient for them. But when creating a universal product, it's logical to try to satisfy the preferences of all potential users. Moreover, the user can choose different options depending on the task at hand. Therefore, we will use the ability to overload functions and create several methods with the same name to satisfy all possible usage scenarios.

First, we'll create a method with a minimal number of parameters, which will only receive a dynamic array describing the architecture of the neural network. At the beginning of the method, we will check the validity of the pointer to the object received in the method parameter. Then we check the number of neural layers in the passed description.

We already mentioned earlier that there cannot be less than two layers, as the first input layer is used to input the initial data, and the last layer is for outputting the result of the neural network's operation. If at least one check fails, we exit the method with a false result.

```
bool CNet::Create(CArrayObj *descriptions)

  {

//--- Control block

   if(!descriptions)

      return false;

//--- Check the number of layers to be created

   int total = descriptions.Total();

   if(total < 2)

      return false;
```

After successfully passing the controls, we initialize the class to work with the OpenCL technology. Unlike the previous checks, we will not return false in the case of initialization errors. We will simply disable this functionality and continue operating in the standard mode. This approach is implemented to enable the replication of the finished product on various computing machines without altering the program code. This, in general, expands the potential customer base for distributing the end product.

```
//--- Initialize OpenCL objects

   if(m_bOpenCL)

      m_bOpenCL = InitOpenCL();

   if(!m_cLayers.SetOpencl(m_cOpenCL))

      m_bOpenCL = false;
```

For all objects of our neural network to work in the same OpenCL context, we will pass a pointer to an instance of the CMyOpenCL class to the storage array of neural layers. From there, it will subsequently be passed to each neural layer.  

Then we will organize a loop with the number of iterations equal to the number of layers of our network. In it, we will sequentially iterate through all the elements of the dynamic array describing neural layers. During this process, we will validate the validity of the description object for each layer, as well as ensure that the specified parameters adhere to the model's integrity. In the method's code, you can observe the validation of specific parameters for various types of neural layers, which we will become acquainted with a little later.

After that, we will call the method to create the corresponding layer. It is worth noting that we will entrust the creation of the neural layer directly to the element creation method, CreateElement of the m_cLayers dynamic storage array of neural layers.

```
//--- Organize a loop to create neural layers

   for(int i = 0; i < total; i++)

     {

      CLayerDescription *temp = descriptions.At(i);

      if(!temp)

         return false;

      if(i == 0)

        {

         if(temp.type != defNeuronBase)

            return false;

         temp.window = 0;

        }
```

```
else

        {

         CLayerDescription *prev = descriptions.At(i - 1);

         if(temp.window <= 0 || temp.window > prev.count ||

            temp.type == defNeuronBase)

           {

            switch(prev.type)

              {

               case defNeuronConv:

               case defNeuronProof:

                  temp.window = prev.count * prev.window_out;

                  break;

               case defNeuronAttention:

               case defNeuronMHAttention:

                  temp.window = prev.count * prev.window;

                  break;

               case defNeuronGPT:

                  temp.window = prev.window;

                  break;

               default:

                  temp.window = prev.count;

                  break;

              }
```

```
switch(temp.type)

              {

               case defNeuronAttention:

               case defNeuronMHAttention:

               case defNeuronGPT:

                  break;

               default:

                  temp.step = 0;

              }

           }

        }

      if(!m_cLayers.CreateElement(i, temp))

         return false;

     }
```

At the end of the method, we initialize the positional encoding class. Please note that the actual code for each position remains unchanged throughout the training and utilization of the neural network. The elements will change, but the size of the input layer of neurons will stay the same. That means, upon creating the network, we can calculate and store the position code for each element right away, and subsequently use the saved values instead of repeatedly recalculating the code.

```
//--- Initialize positional coding objects

   if(m_bPositionEncoder)

     {

      if(!m_cPositionEncoder)

        {

         m_cPositionEncoder = new CPositionEncoder();

         if(!m_cPositionEncoder)

            m_bPositionEncoder = false;

         return true;

        }

      CLayerDescription *temp = descriptions.At(0);

      if(!m_cPositionEncoder.InitEncoder(temp.count, temp.window))

         UsePositionEncoder(false);

     }

//---

   return true;

  }
```

When organizing method overloads for Create, we won't rewrite the entire code; we'll only carry out the user's tasks and make calls to the necessary methods with the received parameters. Below are the possible variations of the overloaded method.

```
bool CNet::Create(CArrayObj *descriptions,

                  TYPE learning_rate,

                  TYPE beta1,TYPE beta2,

                  ENUM_LOSS_FUNCTION loss_function,

                  TYPE lambda1,TYPE lambda2)

  {

   if(!Create(descriptions))

      return false;

   SetLearningRates(learning_rate,beta1,beta2);

   if(!LossFunction(loss_function,lambda1,lambda2))

      return false;

//---

   return true;

  }
```

```
bool CNet::Create(CArrayObj *descriptions,

                  ENUM_LOSS_FUNCTION loss_function,

                  TYPE lambda1,TYPE lambda2)

  {

   if(!Create(descriptions))

      return false;

   if(!LossFunction(loss_function,lambda1,lambda2))

      return false;

//---

   return true;

  }
```

```
bool CNet::Create(CArrayObj *descriptions,

                  TYPE learning_rate,

                  TYPE beta1,TYPE beta2)

  {

   if(!Create(descriptions))

      return false;

   SetLearningRates(learning_rate,beta1,beta2);

//---

   return true;

  }
```

When creating overloaded methods, be sure to declare any method overloads that you use in the class declaration.

Lets move on. Let's talk about the FeedForward fees forward method. The method parameters are omitted in the declaration above. Let's think about what data we need to perform a direct pass. First of all, we need initial data. They must be transferred to the neural network from the outside. We are adding the dynamic array CBufferType to the parameters. We will create this class later; it will serve all our data buffers.

During the forward pass, the input data is multiplied by the weights stored in the neural layer objects. This means that the neural network already knows them. The obtained values are passed through an activation function. The functions used for each layer are specified during the neural network's creation stage in the architecture description.

Thus, to implement the direct pass, it is enough for us to receive an array of initial data at the input.

In the method body, we will validate the pointers to the array of input data and the first neural layer of our network. We will not create a separate type of neural layer for the initial data. Instead, we take a basic fully connected neural layer and write the received initial data to the buffer of output (resulting) values of neurons. Thus, we get the unification of neural layers.

```
bool CNet::FeedForward(const CBufferType *inputs)

  {

//--- control block

   if(!inputs)

      return false;

   CNeuronBase *InputLayer = m_cLayers.At(0);

   if(!InputLayer)

      return false;
```

In the next step, if necessary, we will position the initial values.

```
CBufferType *Inputs = InputLayer.GetOutputs();

   if(!Inputs)

      return false;

   if(Inputs.Total() != inputs.Total())

      return false;

//--- Transfer the source data to the neural layer

   Inputs.m_mMatrix = inputs.m_mMatrix;

//--- Apply positional coding

   if(m_bPositionEncoder && !m_cPositionEncoder.AddEncoder(Inputs))

      return false;

   if(m_bOpenCL)

      Inputs.BufferCreate(m_cOpenCL);
```

At this stage, the preparation of the initial data can be considered complete. Let's proceed directly to the forward pass: we will organize a loop that iterates through all the neural layers in our network sequentially, from the first to the last. For each layer, we will call its corresponding forward pass method. Note that the loop starts at layer index 1. The neural layer with the initial data recorded has an index of 0.

Another point to which you should also pay attention. In the process of enumeration, we use one class CNeuronBase for all objects of neural layers. This is our base class for the neural layer. All other classes of neural layers will inherit from it.

In addition, we will create the virtual method FeedForward that will be overridden in all other types of neural layers. This implementation allows us to use the neural layer base class and call the forward pass virtual method. The task of distributing and utilizing the specific type of neuron's forward pass method will be handled by the compiler and system on our behalf.

```
//--- Create a loop with a complete search of all neural layers

//--- and call the forward pass method for each of them

   CNeuronBase *PrevLayer = InputLayer;

   int total = m_cLayers.Total();

   for(int i = 1; i < total; i++)

     {

      CNeuronBase *Layer = m_cLayers.At(i);

      if(!Layer)

         return false;

      if(!Layer.FeedForward(PrevLayer))

         return false;

      PrevLayer = Layer;

     }
```

It should be noted here that when using the OpenCL technology, when the kernel is sent for execution, it is queued. To "push" its execution, we need to initiate the retrieval of the operation results. We have previously discussed the need to minimize the exchange of data between RAM and the OpenCL context. Therefore, we will not retrieve data after each kernel is added to the queue. Instead, we will enqueue the entire chain of operations and only after completing the loop iterating through all the neural layers, we will request the results of the operations from the last neural layer. Since our data is passed sequentially from one layer to another, the entire queue of operations will be pulled along. But do not forget that data loading is only necessary when using the OpenCL technology.

```
if(m_bOpenCL)

      if(!PrevLayer.GetOutputs().BufferRead())

         return false;

//---

   return true;

  }
```

During the feed-forward pass, we obtained certain calculated data. On an untrained neural network, the obtained result will be quite random. We aim for our neural network to produce results that are as close as possible to real outcomes. And in order to get closer to them, we need to train [a neural network](https://www.mql5.com/en/neurobook/index/about_ai/study). The supervised learning process is based on an iterative approach with the gradual adjustment of weights to the correct answers. As we said earlier, this process consists of two stages: forward and [backward (backpropagation) pass](https://www.mql5.com/en/neurobook/index/about_ai/study/back_propagation). We have already written about the forward pass method. Let's look at the backpropagation method.

Above, when describing the class, I also omitted the parameters of this method. Please take another look at the algorithm for the [backward pass](https://www.mql5.com/en/neurobook/index/about_ai/study/back_propagation). Here we need only correct answers from the external system. Therefore, we will add a dynamic array of correct answers to the method parameters. But at the input of the method, we will receive only reference values for the output neural layer. Therefore, we need to calculate the error gradient for each neuron in our network. The only exception is the neurons in the input layer: their values are provided by an external system and are independent of the neural network state. Hence, calculating the error gradient for the input data is unnecessary work that has no practical value and logical meaning.

At the beginning of the method, as always, we will perform data validation for the method operation. In this block, we will validate the received pointer to the dynamic array of target values and compare the result buffer size with the size of the obtained vector of target values. After that, we calculate the value of the loss function. The calculation of the loss function itself is hidden in the standard MQL5 matrix operations. The algorithm for calculating the value of the function was shown when considering possible options for the [loss function](https://www.mql5.com/en/neurobook/index/about_ai/study/loss). We will check the obtained loss function value and calculate the smoothed error over the entire training period.

```
bool CNet::Backpropagation(CBufferType *target)

  {

//--- Control block

   if(!target)

      return false;

   int total = m_cLayers.Total();

   CNeuronBase *Output = m_cLayers.At(total - 1);

   if(!Output ||Output.Total()!=target.Total())

      return false;

//--- Calculate the value of the loss function

   TYPE loss = Output.GetOutputs().m_mMatrix.Loss(target.m_mMatrix,

                                                  m_eLossFunction);
```

```
if(loss == FLT_MAX)

      return false;

   m_dNNLoss = (m_dNNLoss < 0 ? loss :

                m_dNNLoss + (loss - m_dNNLoss) / m_iLossSmoothFactor);
```

In the next block of our backward pass method, we will bring the error gradient to each neuron of our network. To achieve this, we will first calculate the error gradient at the output layer and then set up a backward loop. While iterating from the output of the neural network to its input, for each neural layer, we will invoke the gradient calculation method. We will discuss the differences in gradient calculation algorithms for the output and hidden layers of the neural network a bit later while exploring the [fully connected neural layer](https://www.mql5.com/en/neurobook/index/realization/perceptron).

Right here, we will calculate how the weights of our neural network should change in order for it to produce correct results for the current set of input data. In the sequential enumeration of neural layers, for each layer we will call the method for calculating deltas.

```
//--- Calculate the error gradient at the output of a neural network

   CBufferType* grad = Output.GetGradients();

   grad.m_mMatrix = target.m_mMatrix;

   if(m_cOpenCL)

     {

      if(!grad.BufferWrite())

         return false;

     }

   if(!Output.CalcOutputGradient(grad, m_eLossFunction))

      return false;

//--- Create a loop with enumeration of all neural layers in reverse order

   for(int i = total - 2; i >= 0; i--)

     {

      CNeuronBase *temp = m_cLayers.At(i);

      if(!temp)

         return false;

      //--- Call the method for distributing the error gradient through the hidden layer

      if(!Output.CalcHiddenGradient(temp))

         return false;

      //--- Call the method for distributing the error gradient to the weight matrix

      if(!Output.CalcDeltaWeights(temp, i == 0))

         return false;

      Output = temp;

     }
```

Similarly to the forward pass, in the case of using OpenCL technology, we need to download the results of the operations of the last kernel in the queue.

```
if(m_cOpenCL)

     {

      for(int i = 1; i < m_cLayers.Total(); i++)

        {

         Output = m_cLayers.At(i);

         if(!Output.GetDeltaWeights() || !Output.GetDeltaWeights().BufferRead())

            continue;

         break;

        }

     }

//---

   return true;

  }
```

The goal of training a neural network is not to find deviations, but to adjust it for the maximum likelihood of producing accurate results. A neural network is tuned by adjusting the correct weights. Therefore, after calculating the deltas, we must update the weights. For the above reasons, I moved the update of the weights into a separate method UpdateWeights.

When declaring a method in the class description, the parameters are not specified. Let's think: we have already calculated the deltas for updating the weights, and the training and regularization coefficients are set when initializing the neural network. At first glance, we have everything we need to update the weights. But look at the deltas. At each iteration, we will summarize them. If a batch of a certain size is used for updating coefficients, there is a high likelihood of obtaining an exaggerated delta. In such a situation, it is logical to use the average delta. To get the average of the sum of the packet deltas, it is enough to divide the available sum by the packet size. Of course, mathematically speaking, batch size can be factored into the learning rate. If we pre-divide the learning rate by the batch size, the final result will remain unchanged.

But this is manual control, and as always, it's a matter of user preference. We will give the opportunity to use both options: we will add a parameter to the method to specify the batch size and set its default value to one. Thus, the user can specify the batch size in the method parameters or can call the method without specifying parameters. In that case, the batch size will be set to the default value, and the delta will be adjusted only by the learning coefficient.

The algorithm of the method is quite straightforward. First, we will validate the specified batch size as it must be a positive integer value. Next, we will set up a loop to iterate through all the neural layers in our network, calling the corresponding method for each layer. The very process of updating the weights will be carried out at the level of the neural layer.

```
bool CNet::UpdateWeights(uint batch_size = 1)

  {

//--- Control block

   if(batch_size <= 0)

      return false;

//--- Organize a loop of enumeration of all hidden layers

   int total = m_cLayers.Total();

   for(int i = 1; i < total; i++)

     {

      //--- Check the validity of the pointer to the neural layer object

      CNeuronBase *temp = m_cLayers.At(i);

      if(!temp)

         return false;

      //--- Call the method of updating the matrix of the weights of the inner layer

      if(!temp.UpdateWeights(batch_size, m_dLearningRate, m_adBeta, m_adLambda))

         return false;

     }

//---

   return true;

  }
```

Of course, the user should have the ability to obtain the results of the neural network operation after the forward pass is executed. This will be implemented by the GetResult method.

What external data should the method receive? Logically reasoning, the function should not receive but rather return data to an external program. However, we do not know what this data will be and in what numbers. Knowing the possible options for the neuron activation functions, it is logical to assume that the output of each neuron will be a certain number. The number of such values will be equal to the number of neurons in the output layer. Accordingly, it will be known at the stage of generation of the neural network. The logical way out of this situation would be a dynamic array of the appropriate type. Previously we used the data buffer class CBufferType for passing data into our model. Here we will use a similar object. Thus, for data exchange between the main program and the model, we will always use one dynamic array class.

In the method body, we first obtain a pointer to the array of output layer neuron values and validate this pointer. Then we check the validity of the pointer to the dynamic array for storing the results. We received a link to the last array in the method parameters from an external program. If the pointer is invalid, then we initiate the creation of a new instance of the data buffer class. After successfully creating a new buffer, we copy the values from the output layer neurons into it and exit the method.

```
bool CNet::GetResults(CBufferType *&result)

  {

   int total = m_cLayers.Total();

   CNeuronBase *temp = m_cLayers.At(total - 1);

   if(!temp)

      return false;

   CBufferType *output = temp.GetOutputs();

   if(!output)

      return false;

   if(!result)

     {

      if(!(result = new CBufferType()))

         return false;

     }

   if(m_cOpenCL)

      if(!output.BufferRead())

         return false;

   result.m_mMatrix = output.m_mMatrix;

//---

   return true;

  }
```

It's important to note that depending on the complexity of the task, neural networks can vary significantly in terms of architectural complexity and the number of synaptic connections. The training time of the network heavily depends on its complexity. Retraining the neural network every time is inefficient and is impossible in most cases. Therefore, the once-trained neural network must be saved and, at the next start, all the coefficients should be loaded from the file. Only after that, if necessary, you can retrain the neural network for the current realities.

The method responsible for saving the trained neural network is called Save. This virtual method is created in the CObject base class and is overridden in every new class. I intentionally did not immediately rewrite the method parameters from the parent class. The reason is that the parameters there are designed to receive a file handle for writing the object. That is, the file must first be opened in an external program, and after saving the data, the external program closes the file.

In other words, the control over opening and closing the file is removed from the class and placed onto the calling program. This approach is convenient when the object is part of a larger project and allows sequentially writing all project objects into a single shared file. And we will definitely use this when saving the objects that make up our neural network.

However, when we're talking about the top level of our program, it would be desirable to have a single method for saving the entire project. This method should handle the task of opening and closing the file, iterating through and saving all the necessary information for reconstructing the entire neural network from the file. At the same time, we cannot exclude the possibility that the neural network will be just a part of something larger.

Taking into consideration the ideas presented above, we will create two methods with the same name: one will receive a file handle in its parameters similar to the parent class method, and the other will be passed a file name for data writing.

Now, let's think about the minimum information we need to fully reconstruct a trained neural network. Of course, we need the architecture of the network, the number of layers and the number of neurons in them. Besides, we need all weights. To do this, we need to save the entire array of neural layers.

However, it's important to understand that a trained neural network will work correctly only within the environment for which it was trained. Therefore, we will save information about the loss function and position encoding.

I propose to write information about the symbol and timeframe in the name of the file. This will allow the Expert Advisor to quickly determine the presence of a pre-trained network on the disk in the future. Moreover, changing just the file name would be sufficient to transfer and test a pre-trained neural network on a different tool or timeframe. In most cases, fine-tuning a neural network will be easier than training it from random weights.

To gauge the extent of training for the neural network saved in the file, let's add the final average loss value and the smoothing coefficient. For convenient continuation of training, we will save the training and regularization parameters. To complete the picture, we will also add a flag indicating whether to use OpenCL.

Let's look at the algorithm of the method with the file handle in the parameters. At the beginning of the method, we will check the validity of the received file handle for data writing, as well as the pointers to the instances of loss functions and the dynamic array of neural layers.

```
bool CNet::Save(const int file_handle)

  {

   if(file_handle == INVALID_HANDLE ||

      !m_cLayers)

      return false;
```

Next, we will save the above parameters.

```
//--- Storing constants

   if(!FileWriteInteger(file_handle, (int)m_bOpenCL) ||

      !FileWriteDouble(file_handle, m_dNNLoss) ||

      !FileWriteInteger(file_handle, m_iLossSmoothFactor) ||

      !FileWriteInteger(file_handle, (int)m_bPositionEncoder) ||

      !FileWriteDouble(file_handle, (double)m_dLearningRate) ||

      !FileWriteDouble(file_handle, (double)m_adBeta[0]) ||

      !FileWriteDouble(file_handle, (double)m_adBeta[1]) ||

      !FileWriteDouble(file_handle, (double)m_adLambda[0]) ||

      !FileWriteDouble(file_handle, (double)m_adLambda[1]) ||

      !FileWriteInteger(file_handle, (int)m_eLossFunction))

      return false;
```

Let's check the flag for using the positional encoding of the input sequence and, if necessary, call the CPositionEncoder class instance saving method. At the end of the method, let's call the method that saves a dynamic array of neural layers. We will get acquainted with the called methods in more detail while analyzing the classes containing them.

```
//--- Save the positional coding object if necessary

   if(m_bPositionEncoder)

     {

      if(!m_cPositionEncoder ||

         !m_cPositionEncoder.Save(file_handle))

         return false;

     }

//-- Call the method for saving the data of a dynamic array of neural layers

   return m_cLayers.Save(file_handle);

  }
```

The algorithm method with the file name in the parameters will be a bit simpler. We will not rewrite the data saving algorithm in full. We will simply set up the file for writing information, and then pass the obtained file handle to the method discussed above. After the method execution is complete, we will close the file.

Please note that if an empty file name is provided in the parameters, we will replace it with the default file name and then proceed to execute the method in the standard mode.

Also, after executing the file opening function, we should check the success of the operation by checking the received handle. I deliberately omitted this step as it is the first operation in the Save method discussed above, and doing the same operation twice will only slow things down.

```
bool CNet::Save(string file_name = NULL)

  {

   if(file_name == NULL || file_name == "")

      file_name = defFileName;

//---

   int handle = FileOpen(file_name, FILE_WRITE | FILE_BIN);

//---

   bool result = Save(handle);

   FileClose(handle);

//---

   return result;

  }
```

For the reverse operation of loading neural network data from a file, we will create two similar Load methods with a handle and a file name in the parameters. While the algorithm for loading data with a specified file name in the parameters is identical to the corresponding data saving method, the algorithm for the second method becomes slightly more complex due to the initialization operations of objects.

At the beginning of the method, just like during saving, we validate the validity of the received file handle for loading data.

```
bool CNet::Load(const int file_handle)

  {

   if(file_handle == INVALID_HANDLE)

      return false;
```

Then we load all the previously saved parameters of the neural network. At the same time, we make sure that the sequence of reading data strictly corresponds to the sequence of their recording.

```
//--- Reading constants

   m_bOpenCL = (bool)FileReadInteger(file_handle);

   m_dNNLoss = FileReadDouble(file_handle);

   m_iLossSmoothFactor = FileReadInteger(file_handle);

   m_bPositionEncoder = (bool)FileReadInteger(file_handle);

   m_dLearningRate = (TYPE)FileReadDouble(file_handle);

   m_adBeta[0] = (TYPE)FileReadDouble(file_handle);

   m_adBeta[1] = (TYPE)FileReadDouble(file_handle);

   m_adLambda[0] = (TYPE)FileReadDouble(file_handle);

   m_adLambda[1] = (TYPE)FileReadDouble(file_handle);

   m_eLossFunction = (ENUM_LOSS_FUNCTION) FileReadInteger(file_handle);
```

Please note that when saving the data, we wrote the positional encoding object to the file only when the function was enabled. Consequently, we first check if the function was enabled when saving the data, and if necessary, initiate the process of reading the positional encoding method. We check the existence of the corresponding created object. If it has not been created before, then before loading the data, we initiate the creation of an instance of the object.

```
//--- Load the positional coding object

   if(m_bPositionEncoder)

     {

      if(!m_cPositionEncoder)

        {

         m_cPositionEncoder = new CPositionEncoder();

         if(!m_cPositionEncoder)

            return false;

        }

      if(!m_cPositionEncoder.Load(file_handle))

         return false;

     }
```

To initialize the OpenCL context object, we won't repeat the entire initialization code. Instead, we will use the appropriate method. We just need to call it and control the result of the operations.

```
//--- Initialize the object for working with OpenCL

   if(m_bOpenCL)

     {

      if(!InitOpenCL())

         m_bOpenCL = false;

     }

   else

      if(!!m_cOpenCL)

        {

         m_cOpenCL.Shutdown();

         delete m_cOpenCL;

        }
```

Next, we need to load the neural layers of the model and their parameters directly. To load this information, it would be sufficient to call the method for loading the dynamic array of neural layers. But before accessing the class method, we need to ensure the validity of the pointer to the class instance. Otherwise, we risk getting a critical program execution error. Therefore, we validate the pointer validity and create a new instance of the dynamic array object if necessary. Here we pass a valid pointer to the object to work with the OpenCL context into the object. Only after the preparatory work is done, we call the method that loads the dynamic array of neural layers.

```
//--- Initialize and load the data of a dynamic array of neural layers

   if(!m_cLayers)

     {

      m_cLayers = new CArrayLayers();

      if(!m_cLayers)

         return false;

     }

   if(m_bOpenCL)

      m_cLayers.SetOpencl(m_cOpenCL);

//---

   return m_cLayers.Load(file_handle);

  }
```

Perhaps, here we should explain why we're only loading the dynamic array instead of all the neural layers. The reason is that our dynamic array of neural layers serves as a container containing pointers to all the neural layer objects in the model. During saving, all the neural layers were sequentially stored in the array. Now, when loading the data, objects will also be sequentially created while preserving the pointers in the array. We will get acquainted with this mechanism in more detail when considering the methods of this class.

So, we've covered the main methods of our neural network class. In conclusion, taking into account everything mentioned above, its final structure will look as follows.

```
class CNet  : public CObject

  {

protected:

   bool               m_bTrainMode;

   CArrayLayers*      m_cLayers;

   CMyOpenCL*         m_cOpenCL;

   bool               m_bOpenCL;

   TYPE               m_dNNLoss;

   int                m_iLossSmoothFactor;

   CPositionEncoder*  m_cPositionEncoder;

   bool               m_bPositionEncoder;

   ENUM_LOSS_FUNCTION m_eLossFunction;

   VECTOR             m_adLambda;

   TYPE               m_dLearningRate;

   VECTOR             m_adBeta;
```

```
public:

                      CNet(void);

                     ~CNet(void);

   //--- Methods for creating an object

   bool               Create(CArrayObj *descriptions);

   bool               Create(CArrayObj *descriptions, TYPE learning_rate,

                                                      TYPE beta1, TYPE beta2);

   bool               Create(CArrayObj *descriptions,

                 ENUM_LOSS_FUNCTION loss_function, TYPE lambda1, TYPE lambda2);

   bool               Create(CArrayObj *descriptions, TYPE learning_rate,

                             TYPE beta1, TYPE beta2,

                 ENUM_LOSS_FUNCTION loss_function, TYPE lambda1, TYPE lambda2);
```

```
//--- Implement work with OpenCL

   void               UseOpenCL(bool value);

   bool               UseOpenCL(void)          const { return(m_bOpenCL);         }

   bool               InitOpenCL(void);

   //--- Methods for working with positional coding

   void               UsePositionEncoder(bool value);

   bool               UsePositionEncoder(void) const { return(m_bPositionEncoder);}

   //--- Implement the main algorithms of the model

   bool               FeedForward(const CBufferType *inputs);

   bool               Backpropagation(CBufferType *target);

   bool               UpdateWeights(uint batch_size = 1);

   bool               GetResults(CBufferType *&result);

   void               SetLearningRates(TYPE learning_rate, TYPE beta1 = defBeta1,

                                                           TYPE beta2 = defBeta2);

   //--- Loss Function Methods

   bool               LossFunction(ENUM_LOSS_FUNCTION loss_function,

                          TYPE lambda1 = defLambdaL1, TYPE lambda2 = defLambdaL2);

   ENUM_LOSS_FUNCTION LossFunction(void)       const { return(m_eLossFunction);    }

   ENUM_LOSS_FUNCTION LossFunction(TYPE &lambda1, TYPE &lambda2);
```

```
TYPE               GetRecentAverageLoss(void) const { return(m_dNNLoss);        }

   void               LossSmoothFactor(int value)    { m_iLossSmoothFactor = value;}

   int                LossSmoothFactor(void)   const { return(m_iLossSmoothFactor);}

   //--- Model operation mode control

   bool               TrainMode(void)          const { return m_bTrainMode;        }

   void               TrainMode(bool mode);

   //--- Methods for working with files

   virtual bool       Save(string file_name = NULL);

   virtual bool       Save(const int file_handle);

   virtual bool       Load(string file_name = NULL, bool common = false);

   virtual bool       Load(const int file_handle);

   //--- object identification method

   virtual int        Type(void)               const { return(defNeuronNet);      }

   //--- Retrieve pointers to internal objects

   virtual CBufferType* GetGradient(uint layer)     const;

   virtual CBufferType* GetWeights(uint layer)      const;

   virtual CBufferType* GetDeltaWeights(uint layer) const;

  };
```

## Gradient distribution verification

Now is the moment when we will assemble the first neural network using MQL5. However, I won't raise your hopes too much as our first neural network will not analyze or predict anything. Instead, it will perform a control function and verify the correctness of the work done earlier. The reason is that before we proceed directly to training the neural network, we need to check the correctness of the error gradient distribution throughout the neural network. I believe it is clear that the correctness of implementing this process significantly affects the overall result of the neural network training. After all, it is the error gradient on each weight that determines the magnitude and direction of its change.

To verify the correctness of gradient distribution, we can use the fact that there are two options to determine the derivative of a function:

- Analytical: determining the gradient of a function based on its first-order derivative. This method is implemented in our backward pass method.

- Empirical: under other equal conditions, the value of one indicator is changed and its effect on the final result of the function is evaluated.

In its geometric interpretation, the gradient is the slope of the tangent to the graph of the function at the current point. It indicates how the value of the function changes with a change in the parameter value.

In geometry terms, the gradient is the slope of the tangent to the graph of the function at the current point

To draw a line, we need two points. Therefore, in two simple iterations, we can find these points on the graph of the function. First, we need to add a small number to the current value of the parameter and calculate the value of the function without changing the other parameters. This will be the first point. We repeat the iteration, but this time we subtract the same number from the current value and get the second point. The line passing through these two points will approximate the desired tangent with a certain degree of error. The smaller the number used to change the parameter, the smaller this error will be. This is the basis of the empirical method for determining the gradient.

If this method is so simple, why not use it consistently? Everything is quite simple here. The method simplicity hides a large number of operations:

- Perform a forward pass and save its result.

- Slightly increase one parameter and repeat the forward pass with the result saved.

- Slightly decrease one parameter and repeat the forward pass with the result saved.

- Based on the found points, construct a line and determine its slope.

All these steps are performed to determine the gradient at only one step for one parameter. Imagine how much time and computational resources we would need if we used this method in training a neural network with even just a hundred parameters. Do not forget that modern neural networks contain significantly more parameters. For instance, a giant model like GPT-3 contains 175 billion parameters. Of course, we will not build such giants on a home computer. However, the use of the analytical method greatly reduces the number of necessary iterations and the time for their execution.

At the same time, we can build a small neural network and compare the results of the two methods on it. Their similarity will indicate the correctness of the implemented analytical method algorithm. Significant discrepancies in the results of the two methods will indicate the need to reevaluate the backward pass algorithm implemented in the analytical method.

To implement this idea in practice, let's create the script check_gradient_percp.mq5. This script will receive three external parameters:

- the size of the initial data vector,

- flag for using OpenCL technology,

- function to activate the hidden layer.

Please note that we haven't specified the source of the original data. The reason is that for this work, it doesn't matter at all what data will be input into the model. We only check the correctness of the backward pass methods. Therefore, we can use a vector of random values as initial data.

```
//+------------------------------------------------------------------+

//| External parameters for the script                               |

//+------------------------------------------------------------------+

// Source data vector size

input int      BarsToLine    = 40;

// Use OpenCL

input bool     UseOpenCL     =  true;

// Hidden Layer Activation Function

input ENUM_ACTIVATION_FUNCTION HiddenActivation = AF_SWISH;
```

In addition, in the global scope of the script, we will connect our library and declare a neural network object.

```
//+------------------------------------------------------------------+

//| Connecting the Neural Network Library                            |

//+------------------------------------------------------------------+

#include "..\..\..\Include\NeuroNetworksBook\realization\neuronnet.mqh"

CNet Net;
```

At the beginning of the script body, let's define the architecture of a small neural network. However, since we will need to perform similar tasks multiple times to validate the correctness of the process in different architectural solutions, we will encapsulate the model creation in a separate procedure called CreateNet. In the parameters, this procedure receives a pointer to the object of the neural network model being created.

Let me remind you that earlier we created the [CNet::Create](https://www.mql5.com/en/neurobook/index/realization/basic/neuron_base#cnetcreate) method to create a neural network model. In parameters, this method takes a dynamic array of descriptions of the neural network architecture. Therefore, we need to organize a similar description of the new model. Let's collect the description of each neural layer into a separate instance of the [CLayerDescription](https://www.mql5.com/en/neurobook/index/realization/basic/description) class. We will combine them into a dynamic array CArrayObj. When adding neuron descriptions to a dynamic array, make sure that their sequence strictly corresponds to the arrangement of neural layers in the neural network. In my practice, I simply create layer descriptions sequentially in the order of their arrangement in the neural network and add them to the array as I create them.

```
bool CreateNet(CNet &net)

  {

   CArrayObj *layers = new CArrayObj();

   if(!layers)

     {

      PrintFormat("Error creating CArrayObj: %d", GetLastError());

      return false;

     }
```

To check the correctness of the implemented error propagation algorithm, we will create a three-layer neural network. All layers will be built on the basis of the [CNeuronBase](https://www.mql5.com/en/neurobook/index/realization/perceptron/pr_mql5) class we created. The size of the first neural layer of the initial data was specified by the user in the external parameter BarsToLine. We will create it without an activation function and weight update method. In theory, this is the basic approach to creating a source data layer.

```
//--- source data layer

   CLayerDescription *descr = new CLayerDescription();

   if(!descr)

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      delete layers;

      return false;

     }

   descr.type = defNeuronBase;

   descr.count = BarsToLine;

   descr.window = 0;

   descr.activation = AF_NONE;

   descr.optimization = None;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete layers;

      delete descr;

      return false;

     }
```

We will set the number of neurons in the second (hidden) neural layer to be 10 times greater than the input data layer. However, the actual size of the neural layer does not directly affect the process of analyzing the algorithm performance. This layer will already receive the activation function that the user specifies in the external parameter of the HiddenActivation script. For example, I used Swish. I would recommend experimenting with all the activation functions you're using. At this stage, we want to verify the correctness of all the methods we've written so far. Exactly, the more diverse your testing is, the more potential issues you can address at this stage. This will help you avoid distractions during the actual training of the neural network and focus on improving its performance.

At this stage, we will not perform weight updates. Therefore, the specified method of updating the weights will not affect our testing results in any way.

```
//--- hidden layer

   descr = new CLayerDescription();

   if(!descr)

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      delete layers;

      return false;

     }

   descr.type = defNeuronBase;

   descr.count = 10 * BarsToLine;

   descr.activation = HiddenActivation;

   descr.optimization = Adam;

   descr.activation_params[0] = (TYPE)1;

   descr.activation_params[1] = (TYPE)0;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete layers;

      delete descr;

      return false;

     }
```

The third neural layer will contain only one output neuron and a linear activation function.

```
//--- result layer

   descr = new CLayerDescription();

   if(!descr)

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      delete layers;

      return false;

     }

   descr.type = defNeuronBase;

   descr.count = 1;

   descr.activation = AF_LINEAR;

   descr.optimization = Adam;

   descr.activation_params[0] = 1;

   descr.activation_params[1] = 0;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete layers;

      delete descr;

      return false;

     }
```

Having collected a complete description of the neural network in a single dynamic array, we generate a neural network. To do this, we call the CNet::Create method of our base neural network class, in which the neural network is generated according to the passed description. At each step, we check the correctness of performing operations on the returned results. Receiving the boolean value true corresponds to the correct execution of the method's operations. If any of the errors occur, the method will return false.

We will specify the flag for using OpenCL. For full testing, we have to check the correctness of the backpropagation method in both modes of operation of the neural network.

```
//--- initialize the neural network

   if(!net.Create(layers, (TYPE)3.0e-4, (TYPE)0.9, (TYPE)0.999, LOSS_MAE, 0, 0))

     {

      PrintFormat("Error of init Net: %d", GetLastError());

      delete layers;

      return false;

     }

   delete layers;

   net.UseOpenCL(UseOpenCL);

   PrintFormat("Use OpenCL %s", (string)net.UseOpenCL());

//---

   return true;

  }
```

We conclude or work with the model creation procedure and move on to the main procedure of our OnStart script. In it, to create a neural network model, we just need to call the above procedure.

```
void OnStart()

  {

//--- create a model

   if(!CreateNet(Net))

      return;
```

At this stage, the neural network object is ready for testing. However, we still need initial data for testing. As mentioned above, we will simply populate them with random values. We will create the [CBufferType](https://www.mql5.com/en/neurobook/index/realization/pr_opencl/opencl_transfer_data#cbuffertype) data buffer to store a sequence of initial data. Target results are not of interest at this point. When generating the neural network, we filled the weight matrix with random values and do not expect to hit the target values. We also do not plan to train the neural network at this stage. Therefore, we will not waste resources on downloading unnecessary information.

```
//--- create a buffer to read the source data

   CBufferType *pattern = new CBufferType();

   if(!pattern)

     {

      PrintFormat("Error creating Pattern data array: %d", GetLastError());

      return;

     }
```

In the loop, fill the entire buffer with random values.

```
//--- generate random source data

   if(!pattern.BufferInit(1, BarsToLine))

      return;

   for(int i = 0; i < BarsToLine; i++)

      pattern.m_mMatrix[0, i] = (TYPE)MathRand() / (TYPE)32767;
```

Now there is enough information to conduct a forward pass of the neural network. We will implement it by calling the [FeedForward](https://www.mql5.com/en/neurobook/index/realization/basic/neuron_base#feedforward) method of our neural network. The results of the direct pass will be stored in a separate data buffer of reference values. Probably the name reference for a randomly obtained result sounds strange. But within the scope of our testing, this will be the reference against which we will consider deviations when changing the input data or weights.

```
//--- perform a forward and reverse pass to obtain analytical gradients

   const TYPE delta = (TYPE)1.0e-5;

   TYPE dd = 0;

   CBufferType *init_pattern = new CBufferType();

   init_pattern.m_mMatrix.Copy(pattern.m_mMatrix);

   if(!Net.FeedForward(pattern))

     {

      PrintFormat("Error in FeedForward: %d", GetLastError());

      return;

     }

   CBufferType *etalon_result = new CBufferType();

   if(!Net.GetResults(etalon_result))

     {

      PrintFormat("Error in GetResult: %d", GetLastError());

      return;

     }
```

In the next step, we add a small constant to the result of the feed-forward pass and run the backpropagation pass of our neural network to calculate the error gradients analytically. In the above example, I used the constant 1*10-5 as a deviation.

```
//--- create a result buffer

   CBufferType *target = new CBufferType();

   if(!target)

     {

      PrintFormat("Error creating Pattern Target array: %d", GetLastError());

      return;

     }

//--- save obtained data to separate buffers

   target.m_mMatrix.Copy(etalon_result.m_mMatrix);

   target.m_mMatrix[0, 0] = etalon_result.m_mMatrix[0, 0] + delta;

   if(!Net.Backpropagation(target))

     {

      PrintFormat("Error in Backpropagation: %d", GetLastError());

      delete target;

      delete etalon_result;

      delete pattern;

      delete init_pattern;

      return;

     }

   CBufferType *input_gradient = Net.GetGradient(0);

   CBufferType *weights = Net.GetWeights(1);

   CBufferType *weights_gradient = Net.GetDeltaWeights(1);

   if(UseOpenCL)

     {

      input_gradient.BufferRead();

      weights.BufferRead();

      weights_gradient.BufferRead();

     }
```

Please note that we need to keep the reference result unchanged. That's why we needed to create another data buffer object, into which we copied values from the benchmark values buffer. In this buffer, we correct the data for the backpropagation pass.

According to the results of the backpropagation pass, we will save the error gradients obtained analytically at the level of the initial data and weights. We also save the weights themselves, which we will need when analyzing the distribution of error gradients at the level of the weight matrix.

Perhaps it's worth mentioning that since we adjust the weights during the training process, obtaining accurate gradients at the weight matrix level is most informative for us. Accurate gradients at the level of input data mostly serve as indirect evidence of the correctness of gradient distribution throughout the entire neural network. This is due to the fact that before determining the error gradient at the level of the initial data, we have to consistently draw it analytically through all layers of our neural network.

We obtained the error gradients by an analytical method. Next, we need to determine the gradients empirically and compare them with the results of the analytical method.

Let's look at the initial data level first. To achieve this, we will copy our pattern of input data into a new dynamic array, which will allow us to modify the required indicators without the fear of losing the original pattern.

We will organize a loop to enumerate all the indicators of our pattern. Inside the loop, we will first add our constant 1*10-5 to each indicator of the original pattern in turn and implement a feed-forward pass neural network. After the feed-forward pass, we take the result obtained and compare it with the reference one that was saved earlier. The difference between the results of the feed-forward pass will be stored in a separate variable. Then we subtract a constant from the initial value of the same indicator and repeat the feed-forward pass. The result of the feed-forward pass is also comparable to the reference result. Let's find the arithmetic mean of two passes.

```
//--- in the loop, alternately change the elements of the source data and compare

//--- empirical result with the value of the analytical method

   for(int k = 0; k < BarsToLine; k++)

     {

      pattern.m_mMatrix.Copy(init_pattern.m_mMatrix);

      pattern.m_mMatrix[0, k] = init_pattern.m_mMatrix[0, k] + delta;

      if(!Net.FeedForward(pattern))

        {

         PrintFormat("Error in FeedForward: %d", GetLastError());

         return;

        }

      if(!Net.GetResults(target))

        {

         PrintFormat("Error in GetResult: %d", GetLastError());

         return;

        }

      TYPE d = target.At(0) - etalon_result.At(0);
```

```
pattern.m_mMatrix[0, k] = init_pattern.m_mMatrix[0, k] - delta;

      if(!Net.FeedForward(pattern))

        {

         PrintFormat("Error in FeedForward: %d", GetLastError());

         return;

        }

      if(!Net.GetResults(target))

        {

         PrintFormat("Error in GetResult: %d", GetLastError());

         return;

        }

      d -= target.At(0) - etalon_result.At(0);

      d /= 2;

      dd += input_gradient.At(k) - d;

     }

   delete pattern;
```

At this point, you should be careful with the signs of the operation and deviations. In the first case, we added a constant and obtained some deviation in the results. The deviation is considered as the current value minus the reference.

In the second case, we subtracted the constant from the original value. Similarly, using the same formula for calculating the deviation, we will obtain a value with the opposite sign. Therefore, to combine the obtained results in magnitude and preserve the correct direction of the gradient, we need to subtract the second deviation from the first one.

The result is divided by 2 to get the mean deviation. The result obtained is comparable to the result of the analytical method.

We repeat the operations described above for all parameters of the initial pattern.

There is another aspect that we should take into account. The gradient indicates how the function value changes when the parameter changes by 1. Our constant is much smaller. Therefore, the empirically calculated gradient we obtained is significantly underestimated. To compensate for this, let's divide the empirically obtained value by our constant and display the total result in the MetaTrader 5 log.

```
//--- display the total value of deviations at the level of the initial data in the journal

   PrintFormat("Delta at input gradient between methods %.5e", dd / delta);
```

Similarly, we determine the empirical gradient at the level of the weight matrix. Note that to access the matrix of weights, we obtain not a copy of the matrix but a pointer to the object. This is a very important point. Thanks to this, we can modify the values of weights directly in our script without creating additional methods to update buffer values in the neural network and neural layer classes. However, this approach is more of an exception than a general practice. The reason is that with this approach, we cannot track changes to the weight matrix from the neural layer object.

The cumulative result of comparing empirical and analytical gradients at the weight matrix level is also printed to the MetaTrader 5 log.

```
//--- reset the value of the sum and repeat the loop for the gradients of the weights

   dd = 0;

   CBufferType *initial_weights = new CBufferType();

   if(!initial_weights)

     {

      PrintFormat("Error creating reference weights buffer: %d", GetLastError());

      return;

     }

   if(!initial_weights.m_mMatrix.Copy(weights.m_mMatrix))

     {

      PrintFormat("Error copying weights to initial weights buffer: %d",

                                                              GetLastError());

      return;

     }
```

```
for(uint k = 0; k < weights.Total(); k++)

     {

      if(k > 0)

         weights.Update(k - 1, initial_weights.At(k - 1));

      weights.Update(k, initial_weights.At(k) + delta);

      if(UseOpenCL)

         if(!weights.BufferWrite())

            return;

      if(!Net.FeedForward(init_pattern))

        {

         PrintFormat("Error in FeedForward: %d", GetLastError());

         return;

        }

      if(!Net.GetResults(target))

        {

         PrintFormat("Error in GetResult: %d", GetLastError());

         return;

        }

      TYPE d = target.At(0) - etalon_result.At(0);
```

```
weights.Update(k, initial_weights.At(k) - delta);

      if(UseOpenCL)

         if(!weights.BufferWrite())

            return;

      if(!Net.FeedForward(init_pattern))

        {

         PrintFormat("Error in FeedForward: %d", GetLastError());

         return;

        }

      if(!Net.GetResults(target))

        {

         PrintFormat("Error in GetResult: %d", GetLastError());

         return;

        }

      d -= target.At(0) - etalon_result.At(0);

      d /= 2;

      dd += weights_gradient.At(k) - d;

     }

--- display the total value of deviations at the level of weights in the journal

   PrintFormat("Delta at weights gradient between methods %.5e", dd / delta);
```

After completing all the iterations, we clear the memory by deleting the used objects and exit the program.

```
//--- clear the memory before exiting the script

   delete init_pattern;

   delete etalon_result;

   delete initial_weights;

   delete target;

  }
```

The results of my testing are shown in the screenshot below. Based on the testing results, I obtained a deviation in the 11th to 12th decimal place. For comparison, deviations in the 8—9th decimal places are considered acceptable in different sources. And it's not worth noting that when using OpenCL, the deviation turned out to be an order of magnitude smaller. This is not an advantage of using technology, but rather the influence of a random factor. At each run, a random matrix of weights and initial data was re-generated. As a result, the comparison was carried out on different parts of the neural network function with different curvature.

Results of comparing analytical and empirical error gradients

In general, we can say that the testing confirmed the correctness of our implementation of the error backpropagation algorithm both by means of MQL5 and using the OpenCL multi-threaded computing technology. Our next step is to assemble a more complex perceptron, and we will try to train it on a training set.

## Creating training and testing samples

We have come quite a long way in building our library for building neural networks. We have completed the work on constructing the basic dispatcher class for our neural network and have created everything necessary for building a fully connected neural layer. We still have a lot of work to do. However, we can already build our first neural network and test its performance using real data. Since we will have several implementations of various architectural solutions, to compare the results of model performance, we will take a small data subset. Let's create two data samples: a larger one for training the neural network and a smaller one for testing the trained neural network.

Allocating a separate sample for training is a common practice. During the training process of a neural network, weights are adjusted in such a way that the neural network accurately describes the training dataset to the best extent possible. By using a sufficiently large number of weights, the neural network is able to learn the training sample down to the smallest detail. However, in doing so, the neural network loses the ability to generalize the data. In such a state, the neural network is called "overfitted". It is not possible to detect this in a training sample. However, if you compare the performance of the neural network on the training dataset and on data that is not part of the training dataset, the difference in results will clearly indicate this. A slight deterioration of the results on the test sample is allowed, but it should not be drastic. Of course, the data in the samples should be comparable. Most often, to achieve this, the overall available data is randomly divided into two sets in a ratio of 70-80% for the training dataset and 20-30% for the testing dataset. In most cases, it will be necessary to divide the general population into three subsamples:

- training 60%

- validation 20%

- test 20%

The validation dataset is used to select the best training parameters and neural network architecture. However, we will not be using a validation dataset at this point, as we would like to compare different implementations under otherwise equal conditions.

To generate samples, let's create the script create_initial_data.mq5. In the script we will specify the following parameters:

- The period for loading data is specified as a start date and an end date; within this period, we will retrieve historical data and indicator data from the server;

- Timeframe used to load the analyzed data;

- Number of analyzed historical bars per pattern;

- Name of files for recording training and test samples;

- Data normalization flag.

Earlier, we discussed extensively the importance of normalizing the data that is fed into the neural network as input. Now, we can practically verify how data normalization affects the results of training the neural network. It is to assess the impact of this factor that I introduced the data normalization parameter. Here, it's important to note that the data fed into the neural network as input should be comparable both in the testing and training datasets, as well as during the practical application operation of the neural network. Therefore, in practice, it will be necessary to store the normalization parameters and use them when normalizing data coming in during the practical application of the neural network.

Recall that in the section on [selecting the input data](https://www.mql5.com/en/neurobook/index/realization/initial_data) to feed into the neural network, we selected two indicators: RSI and MACD. We will use them during the process of training neural networks within the practical experiments outlined in this book.

Let's look at the script algorithm. Initially, following the analogy with the scripts discussed while selecting the source data, we will connect the selected indicators to the chart and obtain handles for accessing the indicator data.

```
//+------------------------------------------------------------------+

//| External parameters for script operation                         |

//+------------------------------------------------------------------+

// Beginning of the period of the general population

input datetime Start = D'2015.01.01 00:00:00';

// End of the period of the general population

input datetime End = D'2020.12.31 23:59:00';

// Timeframe for data loading

input ENUM_TIMEFRAMES TimeFrame = PERIOD_M5;

// Number of historical bars in one pattern

input int      BarsToLine = 40;

// File name for recording the training sample

input string   StudyFileName = "study_data.csv";

// File name for recording the test sample

input string   TestFileName  = "test_data.csv";

// Data normalization flag

input bool     NormalizeData = true;

//+------------------------------------------------------------------+

//| Beginning of the script program                                  |

//+------------------------------------------------------------------+

void OnStart(void)

  {

//--- Connect indicators to the chart

   int h_ZZ = iCustom(_Symbol, TimeFrame, "Examples\\ZigZag.ex5", 48, 1, 47);

   int h_RSI = iRSI(_Symbol, TimeFrame, 12, PRICE_TYPICAL);

   int h_MACD = iMACD(_Symbol, TimeFrame, 12, 48, 12, PRICE_TYPICAL);

   double close[];

   if(CopyClose(_Symbol, TimeFrame, Start, End, close) <= 0)

      return;
```

After that, we check the validity of the obtained handles and load the historical data of indicators into dynamic arrays. It should be noted that for the ZigZag indicator, we will load a bit more data. The reason for this is the specifics of this indicator. The buffer of this indicator points only to the found extrema. In other cases, the indicator returns zero values. Therefore, for the last patterns analyzed, the target values may be outside the analyzed period.

```
//--- Load indicator data into dynamic arrays

   double zz[], macd_main[], macd_signal[], rsi[];

   datetime end_zz = End + PeriodSeconds(TimeFrame) * 500;

   if(h_ZZ == INVALID_HANDLE ||

      CopyBuffer(h_ZZ, 0, Start, end_zz, zz) <= 0)

     {

      PrintFormat("Error loading indicator %s data", "ZigZag");

      return;

     }

   if(h_RSI == INVALID_HANDLE ||

      CopyBuffer(h_RSI, 0, Start, End, rsi) <= 0)

     {

      PrintFormat("Error loading indicator %s data", "RSI");

      return;

     }

   if(h_MACD == INVALID_HANDLE ||

      CopyBuffer(h_MACD, MAIN_LINE, Start, End, macd_main) <= 0 ||

      CopyBuffer(h_MACD, SIGNAL_LINE, Start, End, macd_signal) <= 0)

     {

      PrintFormat("Error loading indicator %s data", "MACD");

      return;

     }
```

In addition to the selected indicators, let's load the candlestick closing prices. We will use these handles to determine the direction of price movement towards the nearest extremum and the strength of the upcoming movement.

After loading the data, we organize the process of determining the target values at each step of the historical data. To do this, we will create a reverse loop and loop through all the values of the ZigZag indicator and if the value differs from zero, we will save it to the extremum variable. Simultaneously, we will iterate through closing price values, and by measuring the deviation of the last recorded extremum from the closing price, we will determine the direction and strength of the upcoming movement. Let's save the obtained values into dynamic arrays target1 and target2.

```
int total = ArraySize(close);

   double target1[], target2[], macd_delta[], test[];

   if(ArrayResize(target1, total) <= 0 ||

      ArrayResize(target2, total) <= 0 ||

      ArrayResize(test, total) <= 0 ||

      ArrayResize(macd_delta, total) <= 0)

      return;

//--- Calculate targets: direction and distance

//--- to the nearest extremum

   double extremum = -1;

   for(int i = ArraySize(zz) - 2; i >= 0; i--)

     {

      if(zz[i + 1] > 0 && zz[i + 1] != EMPTY_VALUE)

         extremum = zz[i + 1];

      if(i >= total)

         continue;

      target2[i] = extremum - close[i];

      target1[i] = (target2[i] >= 0 ? 1 : -1);

      macd_delta[i] = macd_main[i] - macd_signal[i];

     }
```

Here, it's important to note that on a time chart, the extremum should always come after the analyzed closing price. Therefore, the closing price is taken from the previous bar compared to the last checked value of the ZigZag indicator.

In the same loop, we will determine the distance between the main and signal lines of the MACD indicator and store them in a separate dynamic array called macd_delta.

After calculating the targets and the distance between the MACD indicator lines, we normalize the data. Of course, we will perform normalization only when this requirement is specified by the user in the script parameters. The purpose of normalization is to transform the original data so that its values are in the range of -1 to 1 centered on point 0. It's important to pay attention to a series of introductory aspects that stem from the characteristics of the indicators themselves.

The RSI indicator is constructed in such a way that its values are normalized within a range from 0 to 100. Hence, we do not need to determine the maximum and minimum data value of this indicator to normalize it. Therefore, the algorithm for normalizing the readings of this indicator is limited by the constant 50 which is the middle of the range of possible indicator values. The formula for normalizing the values is as follows.

The values of the MACD indicator do not have an upper and lower boundary of the range, but they are centered around point 0. This is because, based on the construction principles of the indicator, it reflects whether the price is above or below the moving average. The same can be said about the calculated distance between the base and signal lines of the indicator. The signal line can be either above or below the base line. However, at the moment the lines cross, the distance between them is 0. Therefore, for normalizing the data, we will take the value of the indicator and divide it by the absolute value of the maximum deviation over the analyzed period.

Here, I want to once again emphasize the importance of data comparability for the training, testing dataset, and data used during practical application. If we normalize the training and test sample data now, we will have to keep the normalization parameters of all three indicators of the MACD indicator for practical application.

After defining the normalization parameters, we will organize a cycle for enumeration and appropriate correction of historical values of indicators.

Only the initial data is normalized, not the target values.

```
//--- Data normalization

   if(NormalizeData)

     {

      double main_norm = MathMax(MathAbs(macd_main[ArrayMinimum(macd_main)]),

                                         macd_main[ArrayMaximum(macd_main)]);

      double sign_norm = MathMax(MathAbs(macd_signal[ArrayMinimum(macd_signal)]),

                                         macd_signal[ArrayMaximum(macd_signal)]);

      double delt_norm = MathMax(MathAbs(macd_delta[ArrayMinimum(macd_delta)]),

                                         macd_delta[ArrayMaximum(macd_delta)]);

      for(int i = 0; i < total; i++)

        {

         rsi[i] = (rsi[i] - 50.0) / 50.0;

         macd_main[i] /= main_norm;

         macd_signal[i] /= sign_norm;

         macd_delta[i] /= delt_norm;

        }

     }
```

Certainly, sometimes it can be useful to normalize the target values to fit them into the range of a specific activation function. However, in such cases, similar to normalizing input data, it's crucial to preserve the normalization parameters for decoding the neural network's outputs in industrial applications. These considerations lie at the interface between the neural network and the main program, and the solution largely depends on the specific task.

After preparing the dataset, the next step is to split it into training and testing sets. A common practice is to randomly select records from the entire dataset for the test set, with the remaining data used for training. It is highly discouraged to take consecutive patterns for the test set, whether they are the first or last in the dataset. This is primarily because a small subset of data is more susceptible to the influence of local trends. Such a sample may not be representative for extrapolating the evaluation to the entire dataset. On the other hand, randomly selecting records from the entire dataset provides a higher probability of extracting patterns that differ significantly for the test set. This kind of sample will be more independent of local trends and more representative to enable the evaluation of the neural network performance on the global dataset. However, it should be noted that there are cases where consecutive patterns are chosen for the test set, but these are specific instances related to the architecture of certain models.

To split the dataset into training and testing sets, we will create an array of flags called test. This array will have the same size as our global dataset. The values of its elements will indicate the usage direction of the pattern:

- 0 means the training sample

- 1 means the testing sample

For binary classification, you can also use an array of logical values. However, when we need to add a validation dataset, we can easily use the value 2 for it, whereas using an array of logical values doesn't provide us with such flexibility.

Our flag array will be first initialized with zero values. In other words, we establish that by default the pattern belongs to the training dataset. We then determine the number of patterns for the test set. Then we create a loop based on the number of elements for the testing dataset, generating random values within this loop. The random value generator should return an integer number between 0 and the size of the general population. In my solution, I used the MQL5 built-in MathRand function to generate pseudo-random numbers. This function returns an integer value in the range of 0 to 32767. However, since the size of the dataset is expected to be over 33,000 elements, I multiplied two random numbers. Such a version is capable of generating more than 1 billion random values. To scale the obtained random number to the size of our population, we first divide the generated random number by the square of 32767, thereby normalizing the random number within the range of 0 to 1. Then multiply by the number of elements in our general population. The resulting number will tell us the ordinal number of the pattern for the test sample.

All we have to do is write 1 to the corresponding element of the flag array. However, there is still a chance of landing twice (or even more times) on the same element of the flag array. If we do not control for this, we are very likely to get a test sample smaller than expected. Therefore, before writing 1 to the selected element of the flag array, we first check its current state. If it already contains 1, we decrease the loop iteration count by 1 and generate the next random number. Thus, if we hit the same element, the loop iteration counter will not be incremented, ensuring that we obtain a testing dataset of the expected size as output.

```
//--- Generate randomly the data indices for the test sample

   ArrayInitialize(test, 0);

   int for_test = (int)((total - BarsToLine) * 0.2);

   for(int i = 0; i < for_test; i++)

     {

      int t = (int)((double)(MathRand() * MathRand()) / MathPow(32767.0, 2) *

                    (total - 1 - BarsToLine)) + BarsToLine;

      if(test[t] == 1)

        {

         i--;

         continue;

        }

      test[t] = 1;

     }
```

This is the end of the preparatory work. The only thing left to do is to save the prepared data into the appropriate files. To write the data, we open two files for writing according to the names specified in the script parameters. An obvious thing to do would be to create binary files to record numeric data. They take up less disk space and are faster to work with. But since we are going to load data from applications written in other programming languages, in particular from Python scripts, the most universal approach is to use CSV files.

We open two CSV files for writing and immediately check the resulting handles for accessing the files. Erroneous handles will signal a file opening error. The corresponding message will be displayed in the terminal log.

```
//--- Open the training sample file for writing

   int Study = FileOpen(StudyFileName, FILE_WRITE |

                                       FILE_CSV |

                                       FILE_ANSI, ",", CP_UTF8);

   if(Study == INVALID_HANDLE)

     {

      PrintFormat("Error opening file %s: %d", StudyFileName, GetLastError());

      return;

     }

//--- Open the test sample file for writing

   int Test = FileOpen(TestFileName, FILE_WRITE |

                                     FILE_CSV |

                                     FILE_ANSI, ",", CP_UTF8);

   if(Test == INVALID_HANDLE)

     {

      PrintFormat("Error opening file %s: %d", TestFileName, GetLastError());

      return;

     }
```

After successfully opening the files, we set up a loop to iterate through all elements of the population. Note that the loop does not start from the zeroth element, but from the element corresponding to the number of bars in the pattern. After all, for a complete pattern record, we must specify the data of several previous candles. We will divide the training and test samples at the stage of writing to the file. By checking the value of the corresponding element in the flag array, we will replace the file handle for pattern recording with the file handle of the correct dataset. The actual pattern writing to the file is encapsulated in a separate function, which we will review a little later. To track the process, we will output the percentage of completion in the comments on the chart.

Upon completion of the loop, we will clear the comments on the chart, close the files, and log information about the file names and paths to the journal.

```
//--- Write samples to files

   for(int i = BarsToLine - 1; i < total; i++)

     {

      Comment(StringFormat("%.2f%%", i * 100.0 / (double)(total - BarsToLine)));

      if(!WriteData(target1, target2, rsi, macd_main, macd_signal, macd_delta, i,

                                      BarsToLine, (test[i] == 1 ? Test : Study)))

        {

         PrintFormat("Error to write data: %d", GetLastError());

         break;

        }

     }

//--- Close the files

   Comment("");

   FileFlush(Study);

   FileClose(Study);

   FileFlush(Test);

   FileClose(Test);

   PrintFormat("Study data saved to file %s\\MQL5\\Files\\%s",

               TerminalInfoString(TERMINAL_DATA_PATH), StudyFileName);

   PrintFormat("Test data saved to file %s\\MQL5\\Files\\%s",

               TerminalInfoString(TERMINAL_DATA_PATH), TestFileName);

  }
```

To write information about the pattern to a file, we will create a function called WriteData. In the function parameters, we will pass pointers to arrays of source and target data, the sequential number of the last bar in the pattern in the data arrays, the number of bars to analyze for one pattern, and the file handle for writing data. The choice of the last bar in the pattern instead of the first is made in an attempt to approximate the pattern construction to the real conditions of neural network operation. When working with real-time stock price time series, we are always on the latest known bar at the current moment. We analyze information from several recent bars, which already constitute history, and try to understand the most probable upcoming price movement. Similarly, the bar specified in the parameters here represents the "current moment" for us. We take the specified number of bars before it, and all of this constitutes the pattern we analyze. Based on this pattern, our neural network should determine the probable price movement and its strength.

```
//+------------------------------------------------------------------+

//| Function for writing a pattern to a file                         |

//+------------------------------------------------------------------+

bool WriteData(double &target1[], // Buffer 1 of target values

               double &target2[], // Buffer 2 target values

               double &data1[],   // Buffer 1 of historical data

               double &data2[],   // Buffer 2 of historical data

               double &data3[],   // Buffer 2 of historical data

               double &data4[],   // Buffer 2 of historical data

               int cur_bar,       // Current bar of the end of the pattern

               int bars,          // Number of historical bars

                                  // in one pattern

               int handle)        // Handle of the file to be written

  {
```

Let's first collect the information on the pattern into a string variable of type string. In doing so, we don't forget to insert a delimiter between the values of the elements. The delimiter must match the delimiter specified when opening the CSV file. Collecting data into a string variable is a forced compromise. The point is that the FileWrite function for writing to a text file has a limit of 63 parameters to write, and each call to write is terminated with an end-of-line character. Now, we have two problems before us:

- By specifying all pattern data within one call of the WriteData function, using 4 indicators per 1 bar, we will be able to describe no more than 15 candlesticks.

- We have to collect information on all the bars at once.

We cannot use a loop to iterate through the array values. We need to manually specify all the elements to be written in the parameters of the data-writing function. The use of a string variable helps address these issues. In a simple loop, we can collect all values into one text string. In this process, we are not limited in the number of included parameters. Of course, during the collection of indicators into the string, we will need to insert a delimiter between them, thus simulating a CSV file string. Moreover, we will write the already assembled string to the file only once. Consequently, the function will insert an end-of-line character at the end of the write once. Thus, the entire pattern in our file will be recorded in a single line.

```
//--- check the file handle

   if(handle == INVALID_HANDLE)

     {

      Print("Invalid Handle");

      return false;

     }

//--- determine the index of the first record of the historical data of the pattern

   int start = cur_bar - bars + 1;

   if(start < 0)

     {

      Print("Too small current bar");

      return false;

     }
```

```
//--- Check the correctness of the index of the data and the data written to the file

   int size1 = ArraySize(data1);

   int size2 = ArraySize(data2);

   int size3 = ArraySize(data3);

   int size4 = ArraySize(data4);

   int sizet1 = ArraySize(target1);

   int sizet2 = ArraySize(target2);

   string pattern = (string)(start < size1 ? data1[start] : 0.0) + "," +

                    (string)(start < size2 ? data2[start] : 0.0) + "," +

                    (string)(start < size3 ? data3[start] : 0.0) + "," +

                    (string)(start < size4 ? data4[start] : 0.0);

   for(int i = start + 1; i <= cur_bar; i++)

     {

      pattern = pattern + "," + (string)(i < size1 ? data1[i] : 0.0) + "," +

                                (string)(i < size2 ? data2[i] : 0.0) + "," +

                                (string)(i < size3 ? data3[i] : 0.0) + "," +

                                (string)(i < size4 ? data4[i] : 0.0);

     }

   return (FileWrite(handle, pattern,

                    (double)(cur_bar < sizet1 ? target1[cur_bar] : 0),

                    (double)(cur_bar < sizet2 ? target2[cur_bar] : 0)) > 0);

  }
```

As a result, we obtain a structured CSV file in which a delimiter is placed between every two adjacent elements and each row represents a separate pattern for analyzing the data.

It should also be noted that to prevent an array out-of-bounds error, we should check the index values against the array sizes before accessing the data arrays. In case of an incorrect index, we write 0 instead of the indicator value. During the operation of the neural algorithm, all values of the input indicator vector are multiplied by the weights, and the resulting products are summed into a common sum. Multiplying any weight by 0 always returns 0. Therefore, zero-valued indicators have no direct effect on the outcome of the neuron performance. Of course, we can talk about indirect influence here. Indeed, there could be a situation where the contribution of a particular indicator to the overall sum is insufficient to activate the neuron. However, this is a lesser evil, and we accept these risks.

Perhaps, it is worth mentioning that for future tests of our models, we will immediately create two sets of training data:

- We will write the training samples with non-normalized initial data to the files study_data_not_norm.csv and test_data_not_norm.csv.

- We will write the training datasets with non-normalized source data into files named study_data.csv and test_data.csv.

To create the aforementioned training datasets, we will use the previously described script from the file create_initial_data.mq5. We will run it twice to collect the same historical data but change the filenames for data recording and the "Data normalization flag."

## File arrangement structure

In this book, we will create many files for various purposes. Before proceeding, I suggest that you decide on the structure of the file arrangement. It should be noted that working in the MQL5 development environment imposes some limitations on the file structure: each type of program has its own directory.

- terminal_dir\MQL5\Experts is the directory for storing Expert Advisors;

- terminal_dir\MQL5/Indicators stores indicators;

- terminal_dir\MQL5\Scripts is the directory for scripts;

- terminal_dir\MQL5\Include is the directory for storing various libraries of included files;

- terminal_dir\MQL5\Libraries is the directory for storing compiled dynamic libraries.

At the same time, the development environment does not restrict the creation of subdirectories for organizing files. Within the scope of this book, we will be creating three types of files. First and foremost, we have our library of include files, where we will primarily focus on organizing the operation of neural network models. As part of testing the created models, we will be generating and using various scripts. At the end of the book, we will create an Expert Advisor template to demonstrate the approaches of using models in practical trading.

Thus, we will create our files in three subdirectories:

- terminal_dir\MQL5\Experts for Expert Advisors;

- terminal_dir\MQL5\Scripts for scripts;

- terminal_dir\MQL5\Include for various libraries of included files.

To separate our files from all others, we will create a NeuroNetworksBook subdirectory in each of the specified directories. We will specify deeper structuring for each file we create.

## Choosing the input data

Having defined the problem statement, let's now turn our attention to the selection of input data. There are specific approaches to this task. At first glance, it might seem like you could load all available information into the neural network and let it learn the correct dependencies during training. This approach will prolong learning indefinitely, without guaranteeing the desired outcome.

The first challenge we face is the volume of information. To convey a large amount of information to the neural network, we would need a considerably large input layer of neurons with a substantial number of connections. Hence, more training time will be required.

Furthermore, we will encounter the issue of data incomparability. Samples of different metrics will have very different statistical characteristics. For example, the price of an instrument will always be positive, while its change can be both positive and negative.

Some indicators have normalized values and others do not. The magnitudes of values for various indicators and the amplitude of their changes can differ by orders of magnitude. However, their impact on the outcome may be comparable, or an indicator with lower values may have an even greater impact.

Such a situation will significantly complicate the training process, as it will be challenging to discern the impact of small values within an array of large values.

Another problem lies in the use of highly correlated features. The presence of a correlation between features can indicate either a cause-and-effect relationship between them or that both variables are dependent on a common underlying factor. Consequently, the use of correlated variables combines the two mentioned problems and their consequences. Using multiple variables depending on one factor exaggerates its impact on the overall outcome. Unnecessary neural connections complicate the model and delay learning.

#### Selecting features

Let's undertake preparatory work, taking into account the considerations mentioned above. Of course, we won't manually select and compare data, as we live in the era of computer technology. To calculate the correlation coefficient, let's create a small script in the file initial_data.mq5.

As a reminder, according to the previously described [directory structure](https://www.mql5.com/en/neurobook/index/realization/files_struct), all scripts are saved in the folder terminal_dir\MQL5\Scripts. For the scripts in our book, we will create the NeuroNetworksBook subdirectory, and for all the scripts in this chapter, we will create the initial_data subdirectory. So the full path of the file to be created will be:

- terminal_dir\MQL5\Scripts\NeuroNetworksBook\initial_data\initial_data.mq5

We will directly calculate the correlation coefficient using the Mathematical Statistics Library from the MetaTrader 5 platform. In the script header, include the necessary library, and in the external parameters, specify the period for analysis.

```
#include <Math\Stat\Math.mqh>

//+------------------------------------------------------------------+

//| Script Parameters                                                |

//+------------------------------------------------------------------+

input datetime Start = D'2015.01.01 00:00:00';   // Period Start

input datetime End  = D'2020.12.31 23:59:00';    // Period End
```

When you run a script, MetaTrader 5 generates a Start event that is handled by the OnStart function in the script body. At the beginning of this function, we get multiple indicator handles for further analysis.

Note that first on my list of indicators is ZigZag, which we will use to get reference values when training the neural network. Here, we will use it to check the correlation of indicator readings with reference values.

Indicator settings are defined by the user at the problem statement stage. The neural network will be trained on the M5 timeframe data, so I set the Depth parameter to 48, which corresponds to four hours. In this way, I expect that the indicator will reflect 4-hour extremes.

The selection of the indicators list and parameters is up to the neural network architect. Parameter tuning is also possible when assessing correlation, which we will explore a bit later. At this stage, let us specify the indicators and their parameters from our subjective considerations.

```
void OnStart(void)

  {

   int h_ZZ=iCustom(_Symbol,PERIOD_M5,"Examples\\ZigZag.ex5",48,1,47);

   int h_CCI=iCCI(_Symbol,PERIOD_M5,12,PRICE_TYPICAL);

   int h_RSI=iRSI(_Symbol,PERIOD_M5,12,PRICE_TYPICAL);

   int h_Stoh=iStochastic(_Symbol,PERIOD_M5,12,8,3,MODE_LWMA,STO_LOWHIGH);

   int h_MACD=iMACD(_Symbol,PERIOD_M5,12,48,12,PRICE_TYPICAL);

   int h_ATR=iATR(_Symbol,PERIOD_M5,12);

   int h_BB=iBands(_Symbol,PERIOD_M5,48,0,3,PRICE_TYPICAL);

   int h_SAR=iSAR(_Symbol,PERIOD_M5,0.02,0.2);

   int h_MFI=iMFI(_Symbol,PERIOD_M5,12,VOLUME_TICK);
```

The next step is to load historical quotes and indicator data. To obtain historical data, we will create a series of arrays with names corresponding to the names of indicators and quotes. This will help us avoid confusion while working with them.

Price data in MQL5 can be obtained by CopyOpen, CopyHigh, CopyLow, and CopyClose functions. The functions are created according to the same template, and it is clear from the function name which quotes it returns. The CopyBuffer function is responsible for receiving data from indicator buffers. The function call is similar to the function for obtaining quotes, with the only difference being that the instrument's name and timeframe are replaced with the indicator handle and the buffer number. I'll remind you that we obtained the indicator handles a little earlier.

```
double close[], open[],high[],low[];

   if(CopyClose(_Symbol,PERIOD_M5,Start,End,close)<=0 ||

      CopyOpen(_Symbol,PERIOD_M5,Start,End,open)<=0   ||

      CopyHigh(_Symbol,PERIOD_M5,Start,End,high)<=0   ||

      CopyLow(_Symbol,PERIOD_M5,Start,End,low)<=0)

      return;
```

All functions write data to the specified array and return the number of copied values. So, when making the call, we check for the presence of loaded data, and if there is no data, we exit the script. In this case, we'll give the terminal some time to load quotes from the server and recalculate indicator values. After that, we will rerun the script.

```
double zz[], cci[], macd_main[], macd_signal[],rsi[],atr[], bands_medium[];

   double bands_up[], bands_low[], sar[],stoch[],ssig[],mfi[];

   datetime end_zz=End+PeriodSeconds(PERIOD_M5)*(12*24*5);

   if(CopyBuffer(h_ZZ,0,Start,end_zz,zz)<=0 ||

      CopyBuffer(h_CCI,0,Start,End,cci)<=0  ||

      CopyBuffer(h_RSI,0,Start,End,rsi)<=0  ||

      CopyBuffer(h_MACD,MAIN_LINE,Start,End,macd_main)<=0     ||

      CopyBuffer(h_MACD,SIGNAL_LINE,Start,End,macd_signal)<=0 ||

      CopyBuffer(h_ATR,0,Start,End,atr)<=0  ||

      CopyBuffer(h_BB,BASE_LINE,Start,End,bands_medium)<=0 ||

      CopyBuffer(h_BB,UPPER_BAND,Start,End,bands_up)<=0    ||

      CopyBuffer(h_BB,LOWER_BAND,Start,End,bands_low)<=0   ||

      CopyBuffer(h_SAR,0,Start,End,sar)<=0  ||

      CopyBuffer(h_Stoh,MAIN_LINE,Start,End,stoch)<=0  ||

      CopyBuffer(h_Stoh,SIGNAL_LINE,Start,End,ssig)<=0 ||

      CopyBuffer(h_MFI,0,Start,End,mfi)<=0)

     {

      return;

     }
```

As mentioned above, not all variables are comparable. Although linear transformations will not significantly affect the correlation coefficient, we still need to preprocess some values.

First, this applies to parameters that directly point to the instrument price. Since our goal is to create a tool capable of projecting accumulated knowledge onto future market situations, where there will be similar price movements but at a new price level, we need to move away from absolute price values and move toward a relative range.

So, instead of using the candlestick opening and closing prices, we can take their difference (the size of the candlestick body) as an indicator of price movement intensity. We will also replace the High and Low candlestick extremes with their deviation from the opening or closing price. We will treat SAR and Bollinger Bands indicators in the same way.

Remember the classic MACD trading rules. In addition to the actual indicator values, their position relative to the signal line within the histogram is also crucial. To test this relationship, lets add the difference between the indicator lines as another variable.

Now, let's address our reference point for the price movement. The ZigZag indicator gives absolute price values of extremes on a particular candlestick. However, we ideally want to know the price reference point for each market situation. In other words, we need a price guide for the upcoming movement on each candlestick. In doing so, we will consider two options for such a benchmark:

- Direction of movement (vector target1).

- Magnitude of movement (vector target2).

We can solve this task using a loop. We will iterate over the ZigZag indicator values in reverse order (from the newest values to the oldest values). If the indicator finds an extremum, we will save its value in a local variable extremum. If there is no extremum, we will use the last saved value.

Simultaneously, in the same loop, we will calculate and save the target values for our dataset. For this, we will subtract the closing price of the analyzed bar from the price value of the last peak. This way we get the magnitude of the movement to the nearest future extremum (target2 vector). The sign of this value will indicate the direction of movement (vector target1).

```
int total = ArraySize(close);

   double target1[], target2[], oc[], bmc[], buc[], blc[], macd_delta[];

   if(ArrayResize(target1, total) <= 0 || ArrayResize(target2, total) <= 0 ||

      ArrayResize(oc, total) <= 0 || ArrayResize(bmc, total) <= 0   ||

      ArrayResize(buc, total) <= 0 || ArrayResize(blc, total)  <= 0 ||

      ArrayResize(macd_delta, total) <= 0)

      return;
```

```
double extremum = -1;

   for(int i = ArraySize(zz) - 2; i >= 0; i--)

     {

      if(zz[i + 1] > 0 && zz[i + 1] != EMPTY_VALUE)

         extremum = zz[i + 1];

      if(i >= total)

         continue;

      target2[i] = extremum - close[i];

      target1[i] = (target2[i] >= 0);

      oc[i] = close[i] - open[i];

      sar[i] -= close[i];

      bands_low[i] = close[i] - bands_low[i];

      bands_up[i] -= close[i];

      bands_medium[i] -= close[i];

      macd_delta[i] = macd_main[i] - macd_signal[i];

     }
```

After completing the preparatory work, we will proceed to check the data correlation. Since we'll be performing the same operation for different indicator data, it makes sense to encapsulate this iteration in a separate function. From the body of the Start function, we will only make the function call, passing different source data to it. The results of the correlation analysis will be saved to a CSV file for further processing.

```
int handle = FileOpen("correlation.csv", FILE_WRITE | FILE_CSV | FILE_ANSI,

                                                                "\t", CP_UTF8);

   string message = "Indicator\tTarget 1\tTarget 2";

   if(handle != INVALID_HANDLE)

      return;

   FileWrite(handle, message);

//---

   Correlation(target1, target2, oc, "Close - Open", handle);

   Correlation(target1, target2, hc, "High - Close %.5f", handle);

   Correlation(target1, target2, lc, "Close - Low", handle);

   Correlation(target1, target2, cci, "CCI %.5f", handle);

   Correlation(target1, target2, rsi, "RSI", handle);

   Correlation(target1, target2, atr, "ATR", handle);

   Correlation(target1, target2, sar, "SAR", handle);

   Correlation(target1, target2, macd_main, "MACD Main", handle);

   Correlation(target1, target2, macd_signal, "MACD Signal", handle);

   Correlation(target1, target2, macd_delta, "MACD Main-Signal", handle);
```

```
Correlation(target1, target2, bands_medium, "BB Main", handle);

   Correlation(target1, target2, bands_low, "BB Low", handle);

   Correlation(target1, target2, bands_up, "BB Up", handle);

   Correlation(target1, target2, stoch, "Stochastic Main", handle);

   Correlation(target1, target2, ssig, "Stochastic Signal", handle);

   Correlation(target1, target2, mfi, "MFI", handle);

//---

   FileFlush(handle);

   FileClose(handle);

  }
```

The algorithm of our correlation test method is pretty straightforward. The correlation coefficient is calculated using the MathCorrelationPearson function from the MQL5 standard statistical analysis library. We will call this function sequentially for two sets of data:

- Indicator and direction of the upcoming movement; and

- Indicator and strength of the upcoming movement.

The results of the analysis are used to form a text message, which is then written to a local file.

```
void Correlation(double &target1[], double &target2[],

                          double &indicator[], string name,

                          int handle)

  {

//---

   double correlation=0;

   string message="";

   if(MathCorrelationPearson(target1,indicator,correlation))

      message=StringFormat("%s\t%.5f",name,correlation);

   if(MathCorrelationPearson(target2,indicator,correlation))

      message=StringFormat("%s\t%.5f",message,correlation);

   if(handle!=INVALID_HANDLE)

      FileWrite(handle,message);

  }
```

The results of my analysis are presented in the graph below. The data show that there is no correlation between our target data and the ATR indicator values. The deviation from the extremes of the candlestick to its closing price (High — Close, Close — Low) also shows a low correlation with the expected price movement. Consequently, we can safely exclude these figures from our further analysis.

Correlation of indicator values with expected price movements

In general, the conducted analysis shows that determining the direction of the upcoming movement is much easier than predicting its strength. All indicators showed a higher correlation with the direction rather than the magnitude of the upcoming movement. However, the correlation with all values remains rather low. The RSI indicator demonstrated the highest correlation, with a value of 0.40 for the direction and 0.22 for the magnitude of the movement.

The correlation coefficient takes values from -1 (inverse relationship) to 1 (direct relationship), with 0 indicating a complete absence of dependence between random variables.

It's worth noting that among the three arrays of data obtained from the MACD indicator (histogram, signal line, and the difference between them), it's the distance between the MACD lines that demonstrated the highest correlation with the target data. This only confirms the validity of the classical approach to using indicator signals.

The next step is to test the correlation between data from different indicators. To avoid comparing each indicator with all others, we will analyze the correlation of indicators with RSI (the winner of the previous stage). We will perform the task using the previously created script with minor modifications. The new script will be saved in the file initial_data_rsi.mq5 in our [subdirectory](https://www.mql5.com/en/neurobook/index/realization/initial_data#full_path).

Correlation of indicator values to RSI

The analysis showed a strong correlation of RSI with a range of indicators. Stochastic, CCI, and MFI have a correlation coefficient with RSI which is greater than 0.70, while the main line of Bollinger Bands showed an inverse correlation of -0.76 with RSI. This indicates that the indicators mentioned above will only duplicate signals. Including them for analysis in our neural network will only complicate its architecture and maintenance. The expected impact of their use will be minimal. Therefore, we are excluding the aforementioned indicators from further analysis.

The indicators that show the minimum correlation with RSI are the two deviation variables:

- MACD signal line (0.40);

- Between opening and closing prices (0.23).

The deviation of the MACD signal line from the histogram in the first step showed a strong correlation with the target data of the upcoming price movement. Based on this data, it is MACD that will be taken into our indicator basket. Next, we will check its correlation with the remaining indicators.

The updated script is saved in the file initial_data_macd.mq5 in the [subdirectory](https://www.mql5.com/en/neurobook/index/realization/initial_data#full_path).

Correlation of indicator values to MACD Main-Signal

The SAR indicator here shows some interesting data. With moderate levels of inverse correlation to the target data, it shows a relatively high negative correlation with both selected indicators. The correlation coefficient with MACD was -0.66 and for RSI it was -0.62. This gives us reason to exclude the SAR indicator from the basket of analyzed indicators.

A similar situation is observed for all three Bollinger Bands indicator lines.

So far, we have selected two indicators for our indicator basket for further training of the neural network.

But this is not the end of the road to initial data selection. It should be noted that the neural network analyzes linear dependencies between the target values and the initial data in their pure form. So, it analyzes the data that is input into it. Each indicator is analyzed in isolation from other data available on the neuron input layer.

Hence, the neural network won't be able to capture the relationship between the source data and target values if it's not a linear relationship, such as being power law or logarithmic instead. To find such relationships, we need to prepare data beforehand. And to test the usefulness of such work, we need to test the correlation between such values.

In the script initial_data_rsi_pow.mq5, we will analyze the change in correlation with the expected price movement when the RSI indicator values are set to different degrees. The new script can be saved in the appropriate [subdirectory](https://www.mql5.com/en/neurobook/index/realization/initial_data#full_path).

The dynamics of how the correlation of RSI values changes in relation to the expected movement when raising the indicator to a power.

The presented graph clearly shows that as the exponentiation of the indicator values increases, the correlation with the original values decreases much faster than with the expected price movement. This observation gives us a potential opportunity to expand the basket of original data indicators with exponential values of the selected indicators. A little later, we will be able to see how it works in practice.

It's important to note that when using exponential operations on indicators, you need to consider the properties of exponents and the nature of indicator values. Indeed, when raising any number to an even exponent, the result will always be positive. In other words, we lose the sign of the number.

For example, if we have two equal-magnitude values of a certain indicator with opposite signs, and they correlate with the target data. If the indicator is positive, the target function grows and if it is negative, it falls. Squared values for such an indicator will give us the same value. In this case, we will observe a decrease in correlation or a complete absence of it, as our target function remains unchanged while the indicator loses its sign.

This effect is noticeable when analyzing the change in correlation when raising the power of the difference between the lines of the MACD indicator, which we conducted in the script initial_data_macd_pow.mq5 from our [subdirectory](https://www.mql5.com/en/neurobook/index/realization/initial_data#full_path).

Dynamics of changing the correlation of MACD values to expected movement when raising the indicator to the power

Similarly, you can test the correlation of various indicators with the target values. The only limit is your ability and common sense. In addition to standard indicators and price quotes, these could also include custom indicators, and quotes from other instruments, including synthetic ones. Don't be afraid to experiment. Sometimes you can find good indicators in the most unexpected places.

 

#### Effect of the time shift on the correlation coefficient

After selecting the indicators for analysis, let's remember that we are dealing with time series data. One of the features of time series is their "historical memory". Each subsequent value depends not only on one previous value but also on a certain depth of historical values.

Certainly, one approach could be experimental — building a neural network and conducting a series of experiments to identify the optimal configuration. In this approach, it will take time to create and train several experimental models. Optionally, we could use our sample to test the correlation of the data with the historical shift.

To solve this problem, let's modify the script slightly and replace the Correlation function with ShiftCorrelation. The new function is a complete descendant of the Correlation function and is built using the same algorithm.

In the function parameters, we add a new variable max_shift to which we pass the maximum shift for analysis.

Time offsets are organized by copying the data to the new shifted arrays. The initial data will be copied without offset but to a lesser extent. Data reduction corresponds to time offset. At the same time, we will transfer the target values data to new arrays with offsets. However, since the size of the target data in our dataset is constant, when shifting, the number of elements for correlation analysis decreases. Therefore, after copying the data, we get data sets that are comparable in size and with a given time shift.

All we need to do is call the correlation coefficient calculation function and write the resulting data to a file.

To analyze the change in correlation with the increase in displacement over time, wrap all operations in a loop. The number of looping iterations corresponds to the max_shift parameter.

```
void ShiftCorrelation(double &targ1[], double &targ2[],

                      double &signal[], string name,

                      int max_shift, int handle)

  {

   int total = ArraySize(targ1);

   if(max_shift > total)

      max_shift = total - 10;

   if(max_shift < 10)

      return;

   double correlation = 0;

   for(int i = 0; i < max_shift; i++)

     {

      double t1[], t2[], s[];

      if(ArrayCopy(t1, targ1, 0, i, total - i) <= 0 ||

         ArrayCopy(t2, targ2, 0, i, total - i) <= 0 ||

         ArrayCopy(s, signal, 0, 0, total - i) <= 0)

        {

         continue;

        }

      //---
```

```
string message;

      if(MathCorrelationPearson(s, t1, correlation))

         message = StringFormat("%d\t%.5f", i, correlation);

      if(MathCorrelationPearson(s, t2, correlation))

         message = StringFormat("%s\t%.5f", message, correlation);

      if(handle != INVALID_HANDLE)

         FileWrite(handle, message);

     }

//---

   return;

  }
```

Dynamics of the correlation between RSI values and the expected movement, with time shift

To analyze the effect of shifting RSI indicator values over time on the correlation with target data, we will create a new script in the file initial_data_rsi_shift.mq5 in the specified initial_data_rsi_shift.mq5 [subdirectory](https://www.mql5.com/en/neurobook/index/realization/initial_data#full_path).

The results of the analysis show a rapid decline in the correlation up to the 30th bar. Then, a slight inverse correlation with a peak coefficient of -0.042 is observed around the 60th bar, followed by a gradual approach to 0. In such a situation, the use of the first 30 bars would be most effective. Further expansion of the analysis depth may lead to a decrease in the efficiency of utilizing computational resources. The value of such a solution can be tested in practice.

A similar analysis of MACD indicator data in the script initial_data_macd_shift.mq5 showed a similar dynamic with a slight shift in the transition zone from direct to inverse correlation at around the 40th bar.

Thus, conducting a correlation analysis of available source data and target values allows us to choose the optimal set of indicators and historical depth during the preparatory phase. This helps in analyzing data and forecasting target values more effectively. This enables us to significantly reduce expenses during the neural network creation and training phases with relatively low effort spent on the preparatory stage.  

Dynamics of the correlation between MACD values and the expected movement, with time shift

## Fully connected neural layer

In the previous sections, we established the fundamental logic of organizing and operating a neural network. Now we are moving on to its specific content. We begin the construction of actual working elements — neural layers and their constituent neurons. We will start with constructing a fully connected neural layer.

It was precisely the fully connected neural layers that formed the Perceptron, created by Frank Rosenblatt in 1957. In this architecture, each neuron of the layer has connections with all neurons of the previous layer. Each link has its own weight factor. The figure below shows a perceptron with two hidden fully connected layers. The output neuron can also be represented as a fully connected layer with one neuron. Almost always, at the output of a neural network, we will use at least one fully connected layer.

It can be said that each neuron assesses the overall picture of the input vector and responds to the emergence of a certain pattern. Through the adjustment of various weights, a model is constructed in which each neuron responds to its specific pattern in the input signal. It is this property that makes it possible to use a fully connected neural layer at the output of classifier models.

Perceptron has two hidden fully connected layers.

If we consider a fully connected neural layer from the perspective of vector mathematics, in the framework of which the input values vector represents a certain point in the N-dimensional space (where N is the number of elements in the input vector), then each neuron builds a projection of this point on its own vector. In this case, the activation function decides whether to transmit the signal further, or not.

Here, it's important to pay attention to the displacement of the obtained projection relative to the origin of the coordinates. While the activation function is designed to make decisions within a strict range of input data, this displacement is, for us, a systematic error. To compensate for this bias, an additional constant called bias is introduced on each neuron. In practice, this constant is tuned during the training process along with the weights. For this, another element with a constant value of 1 is added to the input signal vector, and the selected weight for this element will play the role of bias.

## Organizing parallel computing using OpenCL

In the previous chapters, we have already become acquainted with the organization of the operation of a fully connected neural layer using MQL5. I would like to remind you that in our implementation, we used matrix operations to multiply the input data vector by the weight matrix. From one neural layer to another, the signal flows sequentially, and we cannot initiate operations on the subsequent neural layer until the operations on the previous one are fully completed. In contrast to this, the results of operations within one neuron in a layer do not depend on the operations being carried out with other neurons within the same neural layer. Consequently, we can reduce the time cost of processing a single neural layer if we can organize parallel computation. The more neurons we process simultaneously, the less time we spend on processing one signal and training the neural network as a whole.

As we have already discussed earlier, [OpenCL](https://www.mql5.com/en/neurobook/index/algotrading/opencl) technology will help us in organizing parallel computations. Of course, this will require extra work to customize the process. Let's consider which processes we will transfer to OpenCL to make it as efficient as possible. Let me remind you that due to the overhead time for data transfer between devices, we can achieve real performance improvement only with a large number of concurrent operation threads.

The first thing that can be carried over is the computation of forward pass operations. We can move the execution of operations on each individual neuron into the realm of parallel computing. First, we calculate the weighted sum of the input signal for each neuron and then calculate the activation function for each neuron.

We can also move the operations of the backward pass into the realm of parallel computations. Let's break down the steps of the backward pass.

Deviation of calculated values from the reference values at the output layer of the neural network can be easily divided into separate threads for each neuron.

Furthermore, we can also adjust the obtained deviation for each neuron based on the derivative of the activation function. As a result of such an operation, we obtain the error gradient before the neuron activation function.

Following the backpropagation process, in the next step we need to distribute the resulting error gradient to the neurons of the previous layer. In a fully connected neural layer, all neurons from the previous layer are connected to all neurons in the subsequent layer. In each element of the error gradient vector, there is a component from every neuron in the previous layer. There are two seemingly equivalent approaches here:

- We can create threads for each element of the error gradient vector, and within each thread, iterate through all neurons of the previous layer and add the value of its gradient error component.

- Conversely, we can divide the threads for each neuron in the previous layer and assemble the gradient error components from the previous layer.

Despite their apparent equivalence, the first approach has several drawbacks. Since we will be summing up the gradient error components from different neurons of the subsequent layer, it's necessary to initialize the value of the current vector to zero before starting the operations. This means additional costs in time and resources. In addition, there are also technical nuances. Working with global memory is slower than working with a thread's private memory. Therefore, it's preferable to assemble values in fast memory and transfer them to global memory once. The most challenging aspect of this approach is that there's a significant likelihood of multiple threads attempting to write values to a single neuron in the previous layer simultaneously. And that is highly undesirable for us.

Based on the combination of the above factors, the second option becomes more attractive for implementation.

Splitting the following two processes into threads (calculating deltas for weight adjustment and directly updating the weight matrix) doesn't raise any questions, as each weight is involved in only one connection between two neurons and doesn't affect the others.

## Implementing the perceptron model in Python

To implement the fully connected perceptron model in Python, we will use the [template](https://www.mql5.com/en/neurobook/index/realization/py_struct) we created earlier. As you may recall, in this template, we left the description of the neural layers in our model unfilled.

```
# Create a neural network model

model = keras.Sequential([keras.Input(shape=inputs),

                         # Fill the model with a description of the neural layers

                         ])
```

To create fully connected layers in a neural network, we will use the layers.Dense class from the Keras library. The following operation is performed within this layer:

where:

- activation = activation function, set in parameters

- input = an array of source data

- kernel = a weight matrix

- dot = a vector multiplication operation

- bias = a displacement element

Dense provides parameters to control the neural layer creation process:

- units — the dimension of the output space (the number of neurons in the layer);

- activation — the activation function used;

- use_bias — is an optional parameter that indicates whether to use a vector of displacement elements;

- kernel_initializer — the method of initializing the matrix of weights;

- bias_initializer — a method for initializing a vector of displacement elements;

- kernel_regularizer — a weight matrix regularization method;

- bias_regularizer — a method for regularizing the displacement vector;

- activity_regularizer — a method of regularizing the activation function;

- kernel_constraint — a weight matrix restriction function;

- bias_constraint — a displacement vector restriction function.

Please note that you cannot change the settings after the first access to the layer.

In addition to the above parameters, Dense can take an input_shape parameter that indicates the size of the input array. This parameter is valid only for the first layer of the neural network. When this parameter is used, an input layer is created to be inserted in front of the current layer. The operation can be considered as an equivalent to explicitly defining the input layer.

We'll start implementing our first neural network model by copying our script template into a new perceptron.py file. In the created file, we will create the first model with one hidden layer of 40 neurons and 2 neurons in the results layer. In the hidden layer, we'll use Swish as an activation function. The neurons in the output layer will be activated by the hyperbolic tangent.

```
# Create a neural network model

model1 = keras.Sequential([keras.Input(shape=inputs),

                           keras.layers.Dense(40, activation=tf.nn.swish),

                           keras.layers.Dense(targerts, activation=tf.nn.tanh)

                          ])
```

In theory, this is enough to start training the model. However, we study the operation of various models and want to understand the influence of changing the neural network architecture on the model ability to learn and generalize the initial data. So I've added two more models. One model has two additional hidden layers. The result is a model with three hidden layers. All three hidden layers are completely identical: they have 40 elements each and are activated by the Swish function. The first and last layers remain unchanged.

```
# Create a model with three hidden layers

model2 = keras.Sequential([keras.Input(shape=inputs),

                           keras.layers.Dense(40, activation=tf.nn.swish),

                           keras.layers.Dense(40, activation=tf.nn.swish),

                           keras.layers.Dense(40, activation=tf.nn.swish),

                           keras.layers.Dense(targerts, activation=tf.nn.tanh)

                         ])
```

The following steps should be repeated for each model. First, let's prepare the model for training using the compile method.

```
model2.compile(optimizer='Adam',

               loss='mean_squared_error',

               metrics=['accuracy'])
```

After that, we will start the model training process and save the trained model.

```
history2 = model2.fit(train_data, train_target,

                      epochs=500, batch_size=1000,

                      callbacks=[callback],

                      verbose=2,

                      validation_split=0.2,

                      shuffle=True)

model2.save(os.path.join(path,'perceptron2.h5'))
```

We will build the third model on the basis of the second model with the addition of regularization. For each neural layer, we will specify in the kernel_regularizer parameter the keras.regularizers.l1_l2 class object with the L1 and L2-regularization parameters. As you can see from the class name, we'll be using ElasticNet.

```
# Add regularization to the model with three hidden layers

model3 = keras.Sequential([keras.Input(shape=inputs),

               keras.layers.Dense(40, activation=tf.nn.swish,

                  kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

               keras.layers.Dense(40, activation=tf.nn.swish,

                  kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

               keras.layers.Dense(40, activation=tf.nn.swish,

                  kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

               keras.layers.Dense(targerts, activation=tf.nn.tanh)

                         ])
```

Next, we'll compile and train the model. All three models use identical training parameters. This will make it possible to directly assess the impact of the model architecture on the learning outcome. At the same time, we will eliminate the influence of other factors as much as possible.

```
model3.compile(optimizer='Adam',

               loss='mean_squared_error',

               metrics=['accuracy'])

history3 = model3.fit(train_data, train_target,

                      epochs=500, batch_size=1000,

                      callbacks=[callback],

                      verbose=2,

                      validation_split=0.2,

                      shuffle=True)

model3.save(os.path.join(path,'perceptron3.h5'))
```

Since we are training not one but three models in this script, we also need to correct the visualization unit. Let's display the training results of all three models on one graph. This will demonstrate differences in the training and validation process. We will make changes to the blocks for constructing both graphs.

```
# Plot the training results of the three models

plt.figure()

plt.plot(history1.history['loss'],

         label='Train 1 hidden layer')

plt.plot(history1.history['val_loss'],

         label='Validation 1 hidden layer')

plt.plot(history2.history['loss'],

         label='Train 3 hidden layers')

plt.plot(history2.history['val_loss'],

         label='Validation 3 hidden layers')

plt.plot(history3.history['loss'],

         label='Train 3 hidden layers vs regularization')

plt.plot(history3.history['val_loss'],

         label='Validation 3 hidden layer vs regularization')

plt.ylabel('$MSE$ $Loss$')

plt.xlabel('$Epochs$')

plt.title('Dynamic of Models train')

plt.legend(loc='lower left')
```

```
plt.figure()

plt.plot(history1.history['accuracy'],

         label='Train 1 hidden layer')

plt.plot(history1.history['val_accuracy'],

         label='Validation 1 hidden layer')

plt.plot(history2.history['accuracy'],

         label='Train 3 hidden layers')

plt.plot(history2.history['val_accuracy'],

         label='Validation 3 hidden layers')

plt.plot(history3.history['accuracy'],

         label='Train 3 hidden layers\nvs regularization')

plt.plot(history3.history['val_accuracy'],

         label='Validation 3 hidden layer\nvs regularization')

plt.ylabel('$Accuracy$')

plt.xlabel('$Epochs$')

plt.title('Dynamic of Models train')

plt.legend(loc='upper left')
```

After training, our template tests the model performance on a test sample. Here, we also have to test three models under similar conditions. I'll skip the test sample loading block, as it moved from the template unchanged. Here is just a code for directly testing models.

```
# Check the results of models on a test sample

test_loss1, test_acc1 = model1.evaluate(test_data,

                                        test_target,

                                        verbose=2)

test_loss2, test_acc2 = model2.evaluate(test_data,

                                        test_target,

                                        verbose=2)

test_loss3, test_acc3 = model3.evaluate(test_data,

                                        test_target,

                                        verbose=2)
```

The test results in the template were published in a journal. Now we have the results of testing three models. It will be more efficient to compare the results on the graph. We will use the Matplolib library to build graphs.

In this case, we will not display the dynamics of the process, as before, but compare the values. Therefore, it will be more convenient to use a column chart to display values. The library offers the bar method for constructing diagrams. This method takes two arrays in its parameters: in the first, we will specify the labels of the compared parameters, and in the second, their values. To complete the picture, let's add the title of the graph and the vertical axis using the title and ylabel methods, respectively.

```
plt.figure()

plt.bar(

    ['1 hidden layer','3 hidden layers', '3 hidden layers\nvs regularization'],

    [test_loss1,test_loss2,test_loss3])

plt.ylabel('$MSE$ $Loss$')

plt.title('Result of test')

plt.figure()

plt.bar(

    ['1 hidden layer','3 hidden layers', '3 hidden layers\nvs regularization'],

    [test_acc1,test_acc2,test_acc3])

plt.ylabel('$Accuracy$')

plt.title('Result of test')
```

We will see how the script works a little later. In the next chapter, we'll prepare data for training and testing models.

## Description of a Python script structure

Python is an interpreted programming language with a minimalistic syntax. Such syntax enables the fast creation of small code blocks and the immediate testing of their functionality. Therefore, Python allows you to focus on solving the problem rather than programming. Perhaps, it's precisely due to this feature that Python has gained such popularity.

Despite the fact that interpreted programming languages run slower than compiled ones, Python has currently become the most popular programming language for creating and conducting experiments with neural networks. The issue of execution speed is solved by using various libraries written, among others, in compiled programming languages. Fortunately, Python has the ability to easily expand and incorporate libraries written in practically all available programming languages.

We, too, won't be constructing complex algorithms and will make use of ready-made solutions, including libraries both for building neural networks and for trading. Let's start by familiarizing ourselves with some of them.

The os module contains functions for working with the operating system. Using this library enables the creation of cross-platform applications, as the functionality of this module operates independently of the installed operating system. Here are just some of the functions of the os library:

- os.name returns the name of the operating system. The following options are possible as a result of executing the function: 'posix', 'nt', 'mac', 'os2', 'ce', 'java'.

- os.environ is a function for working with environment variables, allowing you to modify, add and delete environment variables.

- os.path contains a number of functions for working with file and directory paths.

The Pandas module is a library for processing and analyzing data. The library provides specialized data structures and operations for processing numeric tables and time series. It enables data analysis and modeling without using specialized programming languages for statistical processing, such as R or Octave.

The package is designed for data cleaning and initial assessment based on general statistical indicators. It can be used to calculate mean, quantiles, etc. At the same time, the package cannot be considered purely statistical in nature. However, the datasets it creates, such as DataFrame and Series types, are used as inputs in most data analysis and machine learning modules like SciPy, Scikit-Learn, and others.

The DataFrame object is created in the Pandas library. It is designed to work with indexed arrays of two-dimensional data.

In addition, the library provides:

- Tools for data exchange between structures in memory and files of different formats;

- Built-in data matching tools and ways to handle missing information;

- Reformatting datasets, including creating pivot tables;

- Advanced indexing and sampling capabilities from large datasets;

- Grouping capabilities that enable performing three-step operations like split, apply, combine;

- Merging and combining different datasets.

The library provides the ability to create hierarchical indexing, allowing you to work with high-dimensional data within structures of lower dimensions. Functions for working with time series allow you to form time periods and change intervals. The library is optimized for high performance, with the most important parts of the code written in Cython and C.

Another library for working with multidimensional arrays, NumPy, is an open-source library. The main capabilities of this module include support for multidimensional arrays (including matrices) and high-level mathematical functions designed for working with multidimensional arrays.

The NumPy library implements computational algorithms in the form of functions and operators that are optimized for working with multidimensional arrays. The library offers the ability to perform vector operations on data. All functions are written in C and optimized for maximum performance. As a result, any algorithm that can be expressed as a sequence of operations on arrays (matrices) and implemented using NumPy runs as fast as the equivalent code executed in MATLAB.

At the same time, NumPy can be considered as an alternative to using MATLAB. Both languages are interpreted and allow performing operations on arrays.

NumPy is often used as a base for working with multidimensional arrays in other libraries. The aforementioned Pandas also uses the NumPy library for low-level array operations.

The Matplotlib module is a comprehensive library for creating static, animated, and interactive visualizations. It can be used to visualize large volumes of data.

We will use the TensorFlow library to create neural network models. This is a comprehensive open-source platform for machine learning. It has a flexible ecosystem of tools, libraries, and community resources that allow researchers to advance the latest achievements in machine learning while enabling developers to easily create and deploy machine learning-based applications.

The library enables the creation and training of machine learning models using intuitive high-level APIs with eager execution, such as Keras. This provides immediate integration of the model and facilitates debugging.

Of course, to integrate with the MetaTrader 5 terminal, we will use the MetaTrader5 library of the same name. It provides a set of functions for data exchange with the terminal, including functions for retrieving market information and executing trading operations.

For technical analysis of data, you can make use of the TA-lib library, which offers a wide range of functions for technical indicators.

Before you can use the libraries, you must install them in the Python environment you are using. To do this, in the command prompt or Windows PowerShell with administrator privileges, you need to execute a series of commands:

- NumPy installation

```
pip install numpy
```

- installing Pandas

```
pip install pandas
```

- installing Matplotlib

```
pip install matplotlib
```

- installing TensorFlow

```
pip install tensorflow
```

- installing Keras

```
pip install keras
```

- installing MetaTrader 5 library

```
pip install MetaTrader5
```

Moving directly to the structure of our script, let's create a template template.py. The script will consist of several blocks. First, we need to connect the necessary libraries to our script.

```
# import libraries

import os

import pandas as pd

import numpy as np

import tensorflow as tf

from tensorflow import keras

import matplotlib as mp

import matplotlib.pyplot as plt

import matplotlib.font_manager as fm

import MetaTrader5 as mt5
```

After training the models, we will create visualization plots to depict the training process and compare the performance of different models. To standardize the plots, we will define common parameters for their construction.

```
# set parameters for results graphs

mp.rcParams.update({'font.family':'serif',

                    'font.serif':'Clear Sans',

                    'axes.labelsize':'medium',

                    'legend.fontsize':'small',

                    'figure.figsize':[6.0,4.0],

                    'xtick.labelsize':'small',

                    'ytick.labelsize':'small',

                    'axes.titlesize': 'x-large',

                    'axes.titlecolor': '#333333',

                    'axes.labelcolor': '#333333',

                    'axes.edgecolor': '#333333'

                   })
```

We will perform the training and testing of all models on a single dataset, which we will specifically preload into a file on the local disk. This approach will allow us to eliminate the influence of disparate data and assess the performance of different neural network models under consistent conditions.

Hence, in the next step, we will load the initial data from the file into the table. Please note the following: since MetaTrader 5 restricts access to files from its programs within the sandboxed environment, you need to provide the full path to the source data file. It will be stored in the MQL5\Files directory of your terminal or its subdirectories if they were specified when saving the data file.

Instead of hardcoding the path to the terminal sandbox in our program code, we will retrieve it from MetaTrader 5 using the provided API. To achieve this, we first establish a connection to the installed terminal and verify the outcome of this operation.

```
# Connecting to the MetaTrader 5 terminal

if not mt5.initialize():

    print("initialize() failed, error code =",mt5.last_error())

    quit()
```

After successfully connecting to the terminal, we will request the sandbox path and then disconnect from the terminal. Subsequent operations involving model creation and training will be conducted using Python tools. We do not plan to perform any trading operations in this script.

```
# Requesting a sandbox path

path=os.path.join(mt5.terminal_info().data_path,r'MQL5\Files')

mt5.shutdown()
```

In the following short data loading block, you can observe the usage of functions from all three aforementioned libraries simultaneously. Using the os.path.join function, we concatenate the path to the working directory with the name of the training sample file. With the read_table function from the Pandas library, we read and convert the contents of the CSV file into a table. Then we convert the obtained table into a two-dimensional array using the NumPy library function.

```
# Loading a training sample

filename = os.path.join(path,'study_data.csv')

data = np.asarray( pd.read_table(filename,

                   sep=',',

                   header=None,

                   skipinitialspace=True,

                   encoding='utf-8',

                   float_precision='high',

                   dtype=np.float64,

                   low_memory=False))
```

The actual reading of the CSV file contents and the transformation of rows into a table are performed using the read_table function from the Pandas library. This function has quite a few parameters for precise configuration of the methods to transform string data into the desired numerical data type. Their full description can be found in the library [documentation](https://pandas.pydata.org/docs/reference/api/pandas.read_table.html). We will only describe those we use:

- filename gives the name of the file to be read, specifying full or relative path;

- sep specifies the data separator used in the file;

- header provides row numbers to be used as column names and the beginning of the data, in the absence of headers we specify the value None;

- skipinitialspace is a boolean parameter that specifies whether to skip spaces after the delimiter;

- encoding specifies the type of encoding used;

- float_precision determines which converter should be used for floating point values;

- dtype specifies the final data type;

- low_memory internally processes the file piecemeal, which will result in less memory usage during parsing.

As a result of these operations, all training sample data were loaded into a two-dimensional array object of type numpy.ndarray from the NumPy library. Among the loaded data, there are elements of the source data and target values. However, for training a neural network, we need to separately feed the source data as input to the network and then compare the obtained output with the target values after the forward pass. It turns out that the input data and targets for the neural network are separated in time and place of use.

Hence, we need to split this data into separate arrays. Let each data row represent an individual data pattern, with the last two elements of the row containing the target points for that pattern. The shape function will show the size of our array, which means we can use it to determine the dimensions of the initial data and target values. Only by knowing these dimensions can we copy specific samples into new arrays.

In the block below, we will divide the training sample into 2 tables. In doing so, we are separating only the columns while preserving the entire structure of rows. Thus, we get the initial data in one array and the target values in the other array. The patterns can be mapped to the corresponding target values by row number.

```
# Dividing the training sample into baseline data and targets

inputs=data.shape[1]-2

targerts=2

train_data=data[:,0:inputs]

train_target=data[:,inputs:]
```

Now that we have the training data, we can start building the neural network model. We will create models using the function Sequential from the Keras library.

```
# Create a neural network model

model = keras.Sequential([....])
```

The Sequential model is a linear stack of layers. You can create a Sequential model by passing a list of layers to the model's constructor, and you can also add layers using the add method.

First of all, our model needs to know what dimensionality of data to expect at the input. In this regard, the first layer of the Sequential model must obtain information about the dimensionality of the input data. All subsequent layers perform an automatic dimensionality calculation.

There are several ways to specify the dimensions of the raw data:

- Pass the input_shape argument to the first layer.

- Some 2D layers support the specification of the dimensionality of the input data via the input_dim argument. Some 3D layers support input_dim and input_length arguments.

- Use a special type of neural layer for the original Input data with the shape parameter that specifies the size of the layer.

```
# Create a neural network model

model = keras.Sequential([keras.Input(shape=inputs),

 # Fill the model with a description of the neural layers

                         ])
```

We will become familiar with the types of proposed neural layers as we study their architectures. Now let's look at the general principles of building and organizing models.

Once the model is created, you need to prepare it for training and customize the process. This functionality is performed in the [compile](https://www.tensorflow.org/api_docs/python/tf/keras/Model#compile) method which has several parameters:

- optimizer — an optimizer, can be specified as a string identifier of an existing optimizer or as an instance of the Optimizer class;

- loss — a loss function, can be specified by a string identifier of an existing loss function, or an eigenfunction;

- metrics — a list of metrics that the model should evaluate during training and testing, for example, 'accuracy' could be used for the classification task;

- loss_weights — an optional list or dictionary that defines scalar coefficients for weighting the loss contributions of various model outputs;

- weighted_metrics — a list of metrics that will be evaluated and weighted during training and testing.

For each parameter, the Keras library offers a different list of possible values, but it does not limit the user to the proposed options. For each parameter, there is a possibility to add custom classes and algorithms.

```
model.compile(optimizer='Adam',

              loss='mean_squared_error',

              metrics=['accuracy'])
```

Next, we can start training the created model using the [fit](https://www.tensorflow.org/api_docs/python/tf/keras/Model#fit) method, which allows training a model with a fixed number of epochs. This method has parameters to customize the learning process.

- x — an array of initial data;

- y — an array of target results;

- batch_size — an optional parameter, specifies the number of sets of "source data - target values" pairs before updating the weights matrix;

- epochs — a number of epochs of training;

- verbose — an optional parameter, specifies the level of detail of training logging: 0 - no messages, 1 - progress bar, 2 - one line per epoch, auto - automatic selection;

- callbacks — a list of callbacks to apply during training;

- validation_split — carries out allocation of a part of the training sample for validation, specified in fractions from 1.0;

- validation_data — a separate sample for validating the learning process;

- shuffle — a logical value that indicates the need to shuffle the training sample data before the next epoch;

- class_weight — an optional dictionary mapping class indices to a weight value used to weight the loss function (only during training);

- sample_weight — an optional array of NumPy weights for the training sample used to weight the loss function (only during training);

- initial_epoch — a training start epoch, can be useful for resuming a previous training cycle;

- steps_per_epoch — a total number of packets before declaring one epoch completed and starting the next, by default equal to the training sample size;

- validation_steps — the total number of packets from the validation sample before stopping when performing validation at the end of each epoch, defaults to the validation sample size;

- validation_batch_size — a number of samples per validation batch;

- validation_freq — an integer, specifies the number of training periods before performing a new validation run.

Of course, we will not use the full set of parameters in the first model. I propose to stop at the parameter [callbacks](https://www.tensorflow.org/api_docs/python/tf/keras/callbacks/Callback) which sets a callback list. This option provides methods for interacting with the learning process in an interactive way.

Its usage allows configuring the retrieval of real-time information about the training process and managing the process itself. In particular, you can accumulate the average values of indicators for an epoch or save the results of each epoch to a CSV file. You can also monitor training metrics and adjust the learning rate or even stop the training process when the monitored metric stops improving. At the same time, it is possible to add your own callback classes.

I suggest using early stopping in the training procedure if there is no improvement in the error function metric over five epochs.

```
callback = tf.keras.callbacks.EarlyStopping(monitor='loss', patience=5)

history = model.fit(train_data, train_target,

                      epochs=500, batch_size=1000,

                      callbacks=[callback],

                      verbose=2,

                      validation_split=0.2,

                      shuffle=true)
```

After training is complete, save the trained model to a file on the local disk. To do this, let's use the methods of the Keras and os libraries.

```
# Saving the learned model

model.save(os.path.join(path,'model.h5'))
```

For clarity and understanding of the training process, let's plot the dynamics of metric changes during training and validation. Here we will use the methods of the Matplotlib library.

```
# Drawing model learning results

plt.plot(history.history['loss'], label='Train')

plt.plot(history.history['val_loss'], label='Validation')

plt.ylabel('$MSE$ $Loss$')

plt.xlabel('$Epochs$')

plt.title('Dynamic of Models train')

plt.legend(loc='upper right')

plt.figure()

plt.plot(history.history['accuracy'], label='Train')

plt.plot(history.history['val_accuracy'], label='Validation')

plt.ylabel('$Accuracy$')

plt.xlabel('$Epochs$')

plt.title('Dynamic of Models train')

plt.legend(loc='lower right')
```

After training, it's necessary to evaluate our model's performance on the test dataset, as before deploying the model in real conditions, we need to understand how it will perform on new data. To do this, we will load a test sample. The data loading procedure is entirely analogous to loading the training dataset, with the only difference being the filename.

```
# Loading a test sample

test_filename = os.path.join(path,'test_data.csv')

test = np.asarray( pd.read_table(test_filename,

                   sep=',',

                   header=None,

                   skipinitialspace=true,

                   encoding='utf-8',

                   float_precision='high',

                   dtype=np.float64,

                   low_memory=false))
```

After loading the data, we will split the obtained table into source data and target labels, just as we did with the training dataset.

```
# Dividing the test sample into raw data and targets

test_data=test[:,0:inputs]

test_target=test[:,inputs:]
```

We will check the quality of the trained model on the test sample using the [evaluate](https://www.tensorflow.org/api_docs/python/tf/keras/Model#evaluate) method from the Keras library. As a result of calling the specified method, we obtain the loss value and metrics on the test dataset. The method has a number of parameters to customize the testing process:

- x — an array of initial data of the test sample;

- y — an array of test sample targets;

- batch_size — a size of the test batch;

- verbose — a mode of process logging detailing (0 - no logging, 1 - progress indication);

- sample_weight — an optional parameter used to weight the loss function;

- steps — a total number of steps to declare the testing process complete;

- callbacks — a list of callbacks used in the training process;

- return_dict — a boolean variable that defines the format of the method output (True = as a "metric-value" dictionary, False = as a list).

Most of the above parameters are optional and also have default values. To initiate the testing process, in most cases, it's sufficient to simply provide the data arrays.

```
# Validation of model results on test sample

ltest_loss, test_acc = model.evaluate(test_data, test_target)
```

Finally, let's output the test results to the log and display the previously plotted graphs.

```
# Logging test results

print('Model in test')

print('Test accuracy:', test_acc)

print('Test loss:', test_loss)

# Output of created charts

plt.show()
```

At this point, the basic script template can be considered complete. It's worth noting that attempting to run this script will result in an error. It has nothing to do with errors in template construction. Indeed, we haven't provided a description of our model yet and left the block empty. During the process of exploring various neural network solutions, we will fill in the model architecture description block, allowing us to fully assess the performance of our template.

## Comparative testing of implementations

In the previous section, we verified the correctness of the backpropagation algorithm operation. Now we can safely move on to training our perceptron. We will perform this work in the script perceptron_test.mq5. The first block of the script will remind you of the script from the previous section. This is a consequence of using our library to create neural networks. We will create a neural network using it. Hence, the algorithm for initializing and using the neural network will be identical in all cases.

To enable various testing scenarios, we will add the following external parameters to the script:

- The name of the file containing the training sample.

- The name of the file to record the dynamics of the error change. Using these values, we will be able to plot the error change graph during the training process, which will help us visualize the neural network learning process.

- The number of historical bars used in the description of one pattern.

- The number of input layer neurons per bar.

- Switch flag for using OpenCL technology in the process of training a neural network.

- Batch size for one iteration of weight matrix update.

- Learning rate.

- The number of hidden layers.

- The number of neurons in a single hidden layer.

- The number of iterations of updating the weight matrix.

Just like in the previous section, after declaring the external parameters in the global scope of the script, we will include our library for creating a neural network and declare an object of the base class CNet.

```
//+------------------------------------------------------------------+

//| External parameters for script operation                         |

//+------------------------------------------------------------------+

// Name of the file with the training sample

input string   StudyFileName  = "study_data.csv";

// File name for recording the error dynamics

input string   OutputFileName = "loss_study.csv";

// Number of historical bars in one pattern

input int      BarsToLine     = 40;

// Number of input layer neurons per 1 bar

input int      NeuronsToBar   = 4;

// Use OpenCL

input bool     UseOpenCL      = false;

// Packet size for updating the weights matrix

input int      BatchSize      = 10000;

// Learning rate

input double   LearningRate   = 3e-5;

// Number of hidden layers

input int      HiddenLayers   = 1;

// Number of neurons in one hidden layer

input int      HiddenLayer    = 40;

// Number of iterations of updating the weights matrix

input int      Epochs         = 1000;

//+------------------------------------------------------------------+

//| Connect the neural network library                               |

//+------------------------------------------------------------------+

#include <NeuroNetworksBook\realization\neuronnet.mqh>

CNet *net;
```

Before moving on to writing the script code, let's consider what functionality we need to incorporate into it.

First, we need to create the model. For this, we will define the model architecture and call the model initialization method. Similar operations were performed in the script to check the correctness of the error gradient distribution.

Next, to train our model, we need to load the previously created training dataset, which will contain a set of input data and target values.

Only after successfully completing these steps, we can start the model training process. This is a cyclic process that includes a feed-forward pass, a backpropagation pass, and weight matrix updates. There are several approaches to the duration of model training. The most common one involves limiting the number of training epochs and tracking changes in the model error. We will use the first approach. The analysis of the error dynamics during the training process will allow us to develop criteria for applying the second method. Therefore, during training, we need to record the model error change and save the collected sequence after training. At the end of the training, we will save the obtained model.

Thus, we have defined the necessary functionality for our script. To create clear and readable code, we will divide it into blocks corresponding to the tasks mentioned above. In the body of the main function OnStart, we will sequentially call the corresponding functions with control over the execution of operations.

First, we will create a vector to record the dynamics of the model error during training. Its size will be equal to the number of training epochs.

```
//+------------------------------------------------------------------+

//| Beginning of the script program                                  |

//+------------------------------------------------------------------+

void OnStart()

  {

//--- prepare a vector to store the network error history

   VECTOR loss_history = VECTOR::Zeros(Epochs);
```

Next, we initialize our model for training. Here we instantiate a neural network class and pass the object pointer to the model initialization function. Be sure to check the result of the operation.

```
//--- 1. Initialize model

   CNet net;

   if(!NetworkInitialize(net))

      return;
```

The next step is to load the training sample. For this purpose, we will need two dynamic arrays: one for loading the patterns of source data, and the other for the target values. Both arrays will be synchronized.

The data loading is performed in the LoadTrainingData function, in the parameters of which we will pass the file for data loading and pointers to the created dynamic array objects.

```
//--- 2. Load the training sample data

   CArrayObj data;

   CArrayObj targets;

   if(!LoadTrainingData(StudyFileName, data, targets))

      return;
```

As mentioned earlier, after creating the model and loading the training dataset, we can start the training process. This functionality will be assigned to the NetworkFit method, in the parameters to which we will pass pointers to our model, a training sample with target values, and a vector recording the dynamics of the model error variation during training.

```
//--- 3. Train model

   if(!NetworkFit(net, data, targets, loss_history))

      return;
```

After completing the model training process, we save the history of the model error change during training. We will also keep the trained model. We do not need to create a separate function to save the trained model. We can use the previously created method of our base neural network class to save the model.

```
//--- 4. Save the error history of the model

   SaveLossHistory(OutputFileName, loss_history);

//--- 5. Save the obtained model

   net.Save("Study.net");

   Print("Done");

  }
```

To confirm the successful completion of all operations, we will print an informational message to the log and terminate the script.

As you can see, the code of the main function of the script turned out to be quite short, but clearly structured. This distinguishes it from the gradient distribution correctness check script in the previous section. The choice of programming style remains with the programmer and does not affect the functionality of our library. We go back to our script and now we will write the functions that we called above from the main function of the script.

First on the list is the NetworkInitialize model initialization function. In the parameters of this function, we pass a pointer to the object of the model being created. In the body of the function, we have to initialize the model before training. To initialize the model, we need to provide a description of the model to be created. I remind you that we create the model description in a dynamic array, each element of which contains a pointer to an instance of the object CLayerDescription with the description of the architecture of a specific neural layer. The very operation of creating such a model description has been moved to a separate function, CreateLayersDesc, which is a natural extension of the structured code concept.

```
//+------------------------------------------------------------------+

//| Initializing the model                                           |

//+------------------------------------------------------------------+

bool NetworkInitialize(CNet &net)

  {

   CArrayObj layers;

//--- create a description of the network layers

   if(!CreateLayersDesc(layers))

      return false;
```

After creating the model architecture description, we call the initialization method of our neural network [CNet::Create](https://www.mql5.com/en/neurobook/index/realization/basic/neuron_base#cnetcreate). Into it, we pass the description of the model architecture, the learning rate, optimization parameters, loss function, and regularization parameters. Don't forget to check the result of the model creation operations.

```
//--- initialize the network

   if(!net.Create(&layers,(TYPE)LearningRate,(TYPE)0.9,(TYPE)0.999,LOSS_MSE,0,0))

     {
```

After the successful initialization of the model, we set the flag for using OpenCL and set the batch size for model error averaging. In the provided example, regularization is set at the level of the weight matrix update batch.

To complete the description of the model initialization process, let's take a look at the CreateLayersDesc function, which is responsible for creating the architecture description of the model. In the parameters, the method receives a pointer to a dynamic array, into which we will write the architecture of the created model.

We first create a description of the initial data layer. The number of neurons in the input layer of the raw data depends on two external parameters: the number of historical bars in one pattern (BarsToLine) and the number of input layer neurons per bar (NeuronsToBar). The quantity is determined by their product. The input layer will be without an activation function and will not be trained. That's clear and should not raise any questions. In this layer, you're essentially storing the initial parameters from an external system in the results array of the layer. Within the layer, no operations are performed on the data.

```
bool CreateLayersDesc(CArrayObj &layers)

  {

//--- create source data layer

   CLayerDescription *descr;   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }

   descr.type         = defNeuronBase;

   descr.count        = NeuronsToBar * BarsToLine;

   descr.window       = 0;

   descr.activation   = AF_NONE;

   descr.optimization = None;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      return false;

     }
```

When using fully-connected neural layers, each neuron in the hidden layer can be considered as a specific pattern that the neural network learns during the training process. In this logic, the number of neurons in the hidden layer represents the number of patterns that the neural network is capable of memorizing. Certainly, you can establish a logical relationship between the number of elements in the previous layer and the number of possible combinations, which will represent patterns. But let's not forget that our previous neural layer results are non-binary quantities, and the range of variation is quite large. Therefore, the total number of possible combinatorial variants of patterns will turn out to be very large. The average probability of their occurrence will vary greatly. Indeed, most of the time, the number of neurons in each hidden layer will be determined by the neural network architect within a certain range, and the exact number is often fine-tuned based on the best performance on a validation dataset. For this reason, we gave the user the ability to specify the number of neurons in the hidden layer in the external parameter HiddenLayer. But let's say right away that we will create all neural layers of the same architecture and size.

The number of hidden layers depends on the complexity of the problem being solved and is also determined by the neural network architect. In this test, I will use a neural network with one hidden layer. However, I suggest that you independently conduct a few experiments with different numbers of layers and assess the impact of changing this parameter on the results. To perform such experiments, we have derived a separate external parameter — the number of HiddenLayers.

In practice, we create one hidden layer description and then add it to the dynamic array of architecture descriptions as many times as we need to create hidden neural layers.

```
//--- hidden layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }

   descr.type         = defNeuronBase;

   descr.count        = HiddenLayer;

   descr.activation   = AF_SWISH;

   descr.optimization = Adam;

   descr.activation_params[0] = 1;

   for(int i = 0; i < HiddenLayers; i++)

      if(!layers.Add(descr))

        {

         PrintFormat("Error adding layer: %d", GetLastError());

         return false;

        }
```

Within this section, I do not aim to fully train the neural network with the best possible results. We will only compare the performance of our library in different modes and their impact on learning outcomes. Let's also see in practice the impact of some of the approaches we discussed in the theoretical part of the book. Therefore, we will not delve deeply into the careful selection of architectural parameters for the neural network to achieve maximum results at this moment.

I have specified Swish as the activation function for the hidden layer. This is one of those functions whose range of values is limited at the bottom and not limited at the top. In this case, the function is differentiable over the whole range of permitted values. However, we will be able to evaluate other activation features during the testing process.

Choosing the activation function for the output layer is a compromise. The challenge here is that we have two goals: direction and strength of movement. This is not a standard approach to solving the problem, as our neural network output consists of two neurons with completely different values. One might consider the direction of movement as a binary classification (buy or sell), while determining the strength of movement is a regression task. It would probably be logical to train the neural network only to determine the strength of the movement, and the direction would correspond to the sign of the result. However, we are learning and experimenting. Let's observe the behavior of the neural network in such a non-standard situation. We will try to activate the neurons with a linear function, which is standard for solving regression tasks.

I have specified Adam as the training method for both neural layers.

The algorithm for describing neural layers is completely identical to the one discussed in the previous section. First, we describe each layer in an object of the CLayerDescription class. The sequence of describing layers corresponds to their sequence in the neural network, from the input layer of raw data to the output layer of results. As the layers are getting their descriptions, add them to the collection of the previously created dynamic array.

```
//--- results layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }

   descr.type         = defNeuronBase;

   descr.count        = 2;

   descr.activation   = AF_LINEAR;

   descr.optimization = Adam;

   descr.activation_params[0] = 1;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      return false;

     }

   return true;

  }
```

The next step in our script was loading the training dataset in the LoadTrainingData function. We will load it from the file specified in the function parameters. In the body of the function, we immediately open the specified file for reading and check the result of the operation based on the value of the obtained handle.

```
//+------------------------------------------------------------------+

//| Uploading training data                                          |

//+------------------------------------------------------------------+

bool LoadTrainingData(string path, CArrayObj &data, CArrayObj &targets)

  {

   CBufferType *pattern;

   CBufferType *target;

//--- open the file with the training sample

   int handle = FileOpen(path, FILE_READ | FILE_CSV | FILE_ANSI | FILE_SHARE_READ,

                                                                     ",", CP_UTF8);

   if(handle == INVALID_HANDLE)

     {

      PrintFormat("Error opening study data file: %d", GetLastError());

      return false;

     }
```

We will carry out the operation of loading the training sample in two steps. First, we will first patterns and target values into the two CBufferType buffers, piece by piece. We will collect the source data elements of one pattern in the pattern buffer and the relevant target results in the target buffer.

```
//--- display the progress of training data loading in the chart comment

   uint next_comment_time = 0;

   enum

     {

      OutputTimeout = 250 // no more than once every 250 milliseconds

     };

//--- organize the cycle of loading the training sample

   while(!FileIsEnding(handle) && !IsStopped())

     {

      if(!(pattern = new CBufferType()))

        {

         PrintFormat("Error creating Pattern data array: %d", GetLastError());

         return false;

        }

      if(!pattern.BufferInit(1, NeuronsToBar * BarsToLine))

         return false;

      if(!(target = new CBufferType()))

        {

         PrintFormat("Error creating Pattern Target array: %d", GetLastError());

         return false;

        }

      if(!target.BufferInit(1, 2))

         return false;

      for(int i = 0; i < NeuronsToBar * BarsToLine; i++)

         pattern.m_mMatrix[0, i] = (TYPE)FileReadNumber(handle);

      for(int i = 0; i < 2; i++)

         target.m_mMatrix[0, i] = (TYPE)FileReadNumber(handle);
```

After loading information about one pattern from the file, we will store pointers to objects with the data in two dynamic arrays, CArrayObj. We also got pointers to them in the function parameters. One array is used for source data patterns (data) and the second array is used for target values (targets). We repeat the operations in a loop until we reach the end of the file. To allow the user to monitor the process, we will display information about the number of loaded patterns on the chart in the comments field.

Note that since we are passing pointers to data objects into dynamic arrays, we need to create new instances of CBufferType objects after writing the pointers to the array. Otherwise, we will fill the entire dynamic array with a pointer to the same instance of an object, and the buffer will contain generic information about all patterns, the manipulation of which will require a different algorithm. Consequently, the entire neural network will not work correctly.

```
if(!data.Add(pattern))

        {

         PrintFormat("Error adding study data to array: %d", GetLastError());

         return false;

        }

      if(!targets.Add(target))

        {

         PrintFormat("Error adding study data to array: %d", GetLastError());

         return false;

        }

      //--- output download progress in chart comment

      //--- (not more than once every 250 milliseconds)

      if(next_comment_time < GetTickCount())

        {

         Comment(StringFormat("Patterns loaded: %d", data.Total()));

         next_comment_time = GetTickCount() + OutputTimeout;

        }

     }

   FileClose(handle);

   return true;

  }
```

After completing the loop for reading the data, we will obtain two arrays of objects with the same number of elements. In these, elements with the same index will constitute the source-target pair of the pattern data. Here we close the training sample file.

Now that we have the neural network already created and the training sample loaded, we can start training in the NetworkFit function. In its parameters, this method receives pointers to objects of the neural network and the training dataset. Additionally, it receives a pointer to a vector recording the dynamics of the model's error changes during the training process. To train the neural network, we will create two nested loops. We will initiate the first loop with the number of iterations equal to the external parameter Epochs which is the number of weight matrix updates. In the nested loop, we will create a number of iterations equal to BatchSize, i.e. the batch size to update the weights.

```
bool NetworkFit(CNet &net, const CArrayObj &data,

                const CArrayObj &target, VECTOR &loss_history)

  {

//--- training

   int patterns = data.Total();

//--- loop through the eras

   for(int epoch = 0; epoch < Epochs; epoch++)

     {

      ulong ticks = GetTickCount64();

      //--- teach by batches

      for(int i = 0; i < BatchSize; i++)

        {

         //--- check to see if the training has stopped

         if(IsStopped())

           {

            Print("Network training stopped by user");

            return true;

           }
```

In the body of the nested loop, we will randomly select one pattern from the training dataset. For each selected pattern, we will first make a forward pass on the corresponding input data. Then open the target values and do a backward pass.

```
//--- select a random pattern

         int k = (int)((double)(MathRand() * MathRand()) / MathPow(32767.0, 2) *

                                                                        patterns);

         if(!net.FeedForward(data.At(k)))

           {

            PrintFormat("Error in FeedForward: %d", GetLastError());

            return false;

           }

         if(!net.Backpropagation(target.At(k)))

           {

            PrintFormat("Error in Backpropagation: %d", GetLastError());

            return false;

           }

        }
```

By repeating iterations of feed-forward and backpropagation passes, we accumulate the error gradient on each element of the weight matrix. After completing the specified number of iterations of feed-forward and backpropagation passes up to the batch size for weight matrix updates, we exit the inner loop. Then we update the weights in the direction of the average gradient of the error, clear the buffer of accumulated error gradients, and save the current value of the loss function in a vector to monitor the training process. After that, we enter a new loop of training iterations.

```
//--- reconfigure the network weights

      net.UpdateWeights(BatchSize);

      printf("Use OpenCL %s, epoch %d, time %.5f sec", (string)UseOpenCL,

                               epoch, (GetTickCount64() - ticks) / 1000.0);

      //--- report on a bygone era

      TYPE loss = net.GetRecentAverageLoss();

      Comment(StringFormat("Epoch %d, error %.5f", epoch, loss));

      //--- remember the epoch error to save to file

      loss_history[epoch] = loss;

     }

   return true;

  }
```

In the proposed example, the training process is constrained by an external parameter of the number of iterations of updating the weight matrix. In practice, a common approach is often used where the training process stops upon achieving specified performance metrics. This could be the value of the loss function, the accuracy rate of hitting expected results, and so on. A hybrid approach can also be employed, where both metrics are monitored while also setting a maximum number of training iterations.

After the training process is completed, we save the dynamics of the loss function to a file. This functionality is performed by the SaveLossHistory function, in the parameters of which we will pass the name of the file to record the data and the vector of dynamics of changes in the model error during training.

In the body of the function, we open or create a new CSV file to record the data and in a loop store all the model error values received during training.

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

   printf("The dynamics of the error change is saved to a file %s\\MQL5\\Files\\%s",

                             TerminalInfoString(TERMINAL_DATA_PATH), OutputFileName);

  }
```

After writing the data to the file, we close the file and output an informational message to the log indicating the full path of the saved file.

The presented example of the script implementation shows a full loading of the training sample into memory. Of course, working with RAM is always faster than accessing permanent memory. However, the sizes of the training dataset do not always allow it to be fully loaded into RAM. In such cases, the training sample is loaded and processed in batches.

#### Normalizing data at the neural network output

After creating such a script, we can conduct several instructive experiments. For example, we have previously discussed the importance of normalizing the initial data before feeding it to the input of a neural network. But how important is that? Why is it not possible to adjust the appropriate weights during the neural network training process to account for the data scale? Yes, we were talking about the impact of large values. But now we can do a practical experiment and see the effect of input data normalization on the model training result.

Let's take historical data for the EURUSD instrument, with a five-minute timeframe covering the period from 01.01.2015 to 12.31.2020, and create two training datasets: one with normalized data and the other with unnormalized data. Let's run the above neural network training script on both samples. We made the script for creating the training sample in Section [3.9](https://www.mql5.com/en/neurobook/index/realization/create_data).

The graph depicting the dynamics of the loss function says it all. The error on normalized data is much lower, even if we start with random weights. If the initial value of the loss function on unnormalized data is around 120, then on normalized data, it's only 0.6. Of course, during the training process, the value of the loss function on non-normalized data drops rapidly and after 200 iterations of weighting factor updates it drops to 6, and after 1000 iterations it reaches 4.5. But despite such a rapid rate of decline in the loss function index, it still significantly outperforms that for normalized data. On the final iterations, after 1000 weight matrix update iterations, the loss function approaches approximately 0.44.

Graph of the dynamics of the MSE loss function during the training of a neural network, on both normalized and unnormalized data

Graph of the dynamics of the MSE loss function during the training of a neural network, on both normalized and unnormalized data (scale)

I conducted a similar experiment both with and without using OpenCL technology. The results of the neural network were comparable. But in terms of performance on such a small neural network, the CPU won. Obviously, the data transfer overhead was much higher than the performance gains from utilizing multithreading technology. These results were expected. As we discussed earlier, using such technology is justified for large neural networks when the costs of data transmission between devices are offset by the performance gains achieved by splitting computational iterations into parallel threads.

I suggest repeating a similar experiment with your data — then you won't have any questions about the necessity of normalizing the input data. I believe that after conducting the experiment it is obvious that further testing should be performed on normalized data.

#### Choosing the learning rate

The next question that always arises for creators of neural networks is the choice of the learning rate. When tackling this issue, it's essential to strike a balance between performance and the quality of learning. Choosing an intentionally high learning rate allows for faster error reduction at the beginning of training. But then the rate of learning rapidly declines and at best stops far from the intended goal. In the worst case, the error starts to increase. Choosing an excessively small learning rate reduces the training speed. The process takes more time, and there's an increased risk of getting stuck in a local minimum without reaching the desired goal.

For experimental testing of the impact of learning rate on the neural network training process, let's train the previously created neural network using four different learning rates: 0.003, 0.0003, 0.00003 and 0.000003. The results of the test are shown in the graph below.

Comparison of the loss function dynamics when using different learning rates

During the training of the neural network using a learning rate of 0.003, fluctuations in the loss function are observed. During the learning process, the amplitude of the oscillations increases. In general, there is a tendency for the model error to increase. Such behavior is characteristic of an excessively high learning rate.

Reducing the learning rate makes the training schedule smoother. However, at the same time, the rate of decrease in the loss function value diminishes with each weight matrix update. The most gradual decrease in the loss function value is demonstrated by the training process with a learning rate of 0.000003. However, achieving the smoothness of the graph came at the cost of increasing the number of weight matrix update iterations required to reach the optimal result. Throughout the entire training process with 1000 weight matrix update iterations, a learning rate of 0.000003 exhibited the worst result among all.

Training the neural network with coefficients of 0.0003 and 0.00003 showed similar results. The loss function graph with a learning rate of 0.00003 turned out to be more jagged. But at the same time, the best result in terms of error value was shown by training with a rate of 0.0003.

Comparison of the loss function dynamics when using different learning rates (scale)

#### Selecting the number of neurons in the hidden layer

The next aspect I'd like to demonstrate in practice is the impact of the number of neurons in the hidden layer on the training process and its outcome. When we talk about fully connected neural layers, where each neuron in the subsequent layer has connections to all neurons in the previous layer, and each connection is individual and independent, it's logical to assume that each neuron will be activated by its own combination of states from the neurons in the previous layer. Thus, each neuron responds to a different state pattern of the previous layer. Consequently, having a greater number of neurons in the hidden layer has the potential to memorize more such patterns and make them more detailed. At the same time, we are not programming pattern variations; we allow the neural network to learn them autonomously from the presented training dataset. It would seem that in this logic, increasing the number of neurons in the hidden layer can only increase the quality of training of the neural network.

But in practice, not all patterns have an equal probability of occurrence. The goal of training a neural network is not to memorize each individual state down to the finest details. Their goal is to use the training dataset to generalize the presented data, identify and highlight dependencies and regularities. The obtained data should allow the construction of a function that describes the relationship between the target values and the input data with the required accuracy. Therefore, an excessive increase in neurons in the hidden layer reduces the neural network's ability to generalize and leads to overfitting.

The other aspect of increasing the number of neurons in the hidden layer is the increase in the consumption of time and computational resources. The point is that adding one neuron in the hidden layer adds as many elements to the weight matrix as the previous layer contains plus one element for bias. Therefore, when choosing the number of neurons in the hidden layer, it's important to consider the balance between the achieved learning quality and the training costs for such a neural network. At the same time, you need to think about the risk of overfitting.

Certainly, there are established methods to combat overfitting in neural networks. These primarily include increasing the training dataset size and [regularization](https://www.mql5.com/en/neurobook/index/about_ai/improvement/regularization) techniques. We have discussed theoretical aspects of regularization earlier, and we will talk about practical applications a little later.

Now I suggest looking at the graphs of the error function values during the training of a neural network with a single hidden layer, where the number of neurons changes while keeping other conditions constant. When testing, I compared the training of 4 neural networks with 20, 40, 60 and 80 neurons in the hidden layer. Of course, such a number of neurons is too small to get any decent training results on a sample of 350 thousand patterns. Moreover, there is no risk of overtraining here. But they are enough to look at the impact of this factor on learning.

Comparison of the loss function dynamics when using different numbers of neurons in the hidden layer

As can be seen in the graph, the model with 20 neurons in the hidden layer showed the worst result. They are clearly insufficient for such a task.

Regarding the other three models, it can be said that the variation in the graphs during the first 100 weight update iterations can be attributed to the randomness factor due to initializing the models with random weights. After about 250-300 iterations of updates to the weight matrix, the graphs are intertwined into a single bundle and from this point go on together.

Increasing the scale of the graph allows us to identify the main trend: as the number of neurons in the layer increases, the number of iterations required to reach local minima and overall train the neural network also increases. At the same time, local minima of neural networks with a large number of neurons fall lower, and their graphs have a lower frequency of oscillations.

Overall, throughout the entire training process, the model with 60 neurons demonstrates the best performance. Slightly behind, almost in parallel, is the graph of the model with 40 neurons in the hidden layer. For a model with 80 neurons in the hidden layer, 1000 iterations of updating the weight matrix were insufficient. This model shows a slower decrease in the value of the loss function. At the same time, the dynamics of the loss function values graph demonstrate the potential for further reducing the loss function value with continued training of the model. There are valid reasons to expect a decrease in the performance achieved by the model with 60 neurons in the hidden layer.

Comparison of loss function dynamics using different numbers of neurons in the hidden layer (scale)

However, it's important to note that a decrease in error on the training dataset could also be associated with model overfitting. Therefore, before the practical deployment of a trained model, it's always important to test it on "unseen" data.

#### Training, validation, testing.

During training, we adjust the weight matrix parameters to achieve the minimum error on the training dataset. But how will the model behave on new data beyond the training sample? It's also important to consider that we are dealing with non-static data that is constantly changing, influenced by a large number of factors. Some of these factors are known to us, while we might not even be aware of others. And even about the factors known to us, we cannot say with certainty how they will change in the future. Moreover, we don't know how this will impact the variation of the data we are studying. It is most likely that the performance of the neural network will deteriorate on the new data. But what will that deterioration be? Are we willing to accept such risks?

The first step towards addressing this issue is the validation of the model's training parameters. For model validation, a dataset that is not part of the training set is used. Most often, the entire set of initial data is divided into three blocks:

- training sample (~60%)

- validation sample (~20%)

- test sample (~20%)

The percentage distribution for each dataset is given as an example and can vary significantly depending on the specific task at hand.

The essence of the validation process lies in testing the parameters of the trained model on data that is not part of the training dataset. During validation, hyperparameters of the trained model are tuned to achieve the best possible performance.

When writing a script for a [fully connected perceptron](https://www.mql5.com/en/neurobook/index/realization/pr_py) in Python, we allocated 20% of the training dataset for validation. The training of the first model demonstrated results similar to those obtained when training the model created in MQL5. That's a positive signal for us. Obtaining similar results when training models created in three different programming languages can indicate the correctness of the algorithm we have implemented.

Change in performance of a model with a single hidden layer on validation at pace with its training

Evaluating the graphs of the test results, one can notice a tendency for the error to decrease during the learning process. This is a positive signal that indicates the model's ability to learn and establish relationships between input data and target labels. At the same time, there's an increase in error on the validation data, which could indicate both the overfitting of the model and the non-representativeness of the validation dataset.

The issue might be that we specified a portion of the data for validation within the training dataset. In this case, the TenzorFlow library takes the latest data in the training sample set. However, this approach doesn't always yield accurate results, as the outcomes of individual periods can be significantly influenced by local trends.

In the graph below, I can see the impact of both factors. The overall trend of increasing error on the validation data indicates the model's tendency to overfit, while the initial validation error being lower than the training error might be due to the influence of local trends.

Change in performance of a model with a single hidden layer on validation at pace with its training

The graph of the accuracy metric shows similar trends. The metric itself reflects the model accuracy as a proportion of correct answers in the total number of results. Here we observe an increase in the indicator during training with an almost unchanged indicator on validation. This may indicate that the model learns patterns that do not occur in the validation sample.

In theory, adding hidden layers should enhance the model's ability to learn and recognize more complex patterns and structures. We created the second model in Python with three hidden layers. Indeed, in this model in training, the error decreased significantly. But at the same time, it has further increased in the validation process. This is a clear sign of the model overfitting. When the model, due to its capabilities, does not generalize dependencies and simply "memorizes" pairs "initial data - target values", the result appears randomly on new data not included in the training sample.

Change in performance of a model with three hidden layers on validation at pace with its training

The dynamics of the accuracy metric have trends similar to those of the loss function. The only difference is that the loss function decreases during the training process, while the accuracy increases.

One way to combat overfitting is to regularize the model. We added ElasticNet regularization to the third model, and it did the job. When the model was trained with regularization, the error decreased at a slower rate. At the same time, the increase in error on the validation set has slowed down.

Once again, on the accuracy metric graph, we observe the same trends as on the loss function graph.

Note that the training and regularization parameters were not meticulously tuned. Therefore, learning outcomes cannot be considered definitive.

Change in performance of a model with three hidden layers on validation at pace with its training

The change in the performance of the model with three hidden layers and regularization on validation is occurring at a similar pace to its training.

The change in the performance of the model with three hidden layers and regularization on validation is occurring at a similar pace to its training.

After training the models, we will evaluate them using the test dataset. In contrast to validation, the model with three hidden layers and no regularization demonstrated the lowest error on the test dataset. The model with regularization showed the maximum error. Such differences in results between the test and validation datasets can possibly be explained by the way the datasets were created. While the validation sample included only the most recent data from the training sample, the test sample collected random data sets from the entire population. Thus, the test sample can be considered more representative, as it is deprived of the influence of local tendencies.

Measuring the accuracy metric on the test sample showed similar results. The best result was obtained on the model with three hidden layers.

Comparison of model results on a test sample

Comparison of model results on a test sample

We can summarize the results of our practical work.

- Normalizing the raw data before feeding it to the input of the neural network greatly increases the chances of convergence of the neural network and reduces the training time.

- The learning rate should be carefully selected experimentally. Too high learning rates lead to unbalancing of the neural network and an increase in error. Too low learning rates lead to more time and computational resources spent on training the neural network. This increases the risk of stopping the learning process at a local minimum without achieving the desired result.

- Increasing the number of neurons in the hidden layer gives improved results of training. But at the same time, training costs are also rising. When choosing the size of the hidden layer, it is necessary to find a balance between the training error and the resource cost of conducting the training of the neural network. It should be kept in mind that an excessive increase in the number of neurons in the hidden layer increases the risk of neural network overfitting.

- Increasing the number of hidden layers also increases the model's ability to learn and recognize more complex shapes and structures. In this case, the model's propensity to overfitting increases significantly.

- The use of a set of recent training sample values for validation is not always able to show true trends, as such a validation sample is strongly influenced by local trends and cannot be representative.

However, we are building a model for financial markets. It is important to us to make a profit both in the long term and in the present moment. Of course, there may be some localized losses, but they should not be large and frequent. Therefore, it is important to obtain acceptable results both on a single localized dataset and on a more representative sample. Probably, getting better results on a local segment has a higher impact: after making a local profit, we can retrain the model to adapt to new trends and make a profit on a new local segment. At the same time, if training costs exceed possible local losses, the profitability over a long period using a representative sample becomes more significant.

## Problem statement

Before embarking on the practical implementation of our first neural network, it's essential to define the objective and the means to achieve it. When developing the architecture of a neural network, we must have a clear understanding of what data should be provided as input and output for the neural network. The number of neurons in the input layer and their type entirely depend on the dataset being used. The architecture of the output layer depends on the expected outcome and on how the results of the developed neural network's work will be represented.

Let's formulate a problem that we would like to solve using artificial intelligence. We work on financial markets, and we need a tool to forecast the future movement of the analyzed instrument. The task seems somewhat familiar and is often on the minds of traders. Everyone tries to solve it in their own way.

But there are no specifics in this task. What do we mean by "future movement"? Does the future arrive in 5 minutes, 1 hour, 1 day, or 1 month? How about something in between? What is the minimum price movement we will react to? What metrics can we use to evaluate the accuracy of our model's performance? Our goal must be specific and measurable.

We realize that price does not move in a straight line. There are always large and small price fluctuations. Small fluctuations are essentially noise. To identify trends and tendencies that can potentially yield profits, we must filter out this noise. The MetaTrader 5 platform provides the ZigZag indicator. It is one of the oldest indicators used in financial markets. The sole purpose of this indicator is to identify the most significant extremes on the instrument's chart, thereby indicating trends and tendencies while excluding minor noisy fluctuations.

ZigZag on the price chart of the instrument

Three parameters are used to customize the indicator:

- Depth sets the number of candlesticks to search for extrema. As the parameter increases, the indicator highlights the most significant extremes.

- Deviation defines the number of points between two neighboring extrema to be displayed on the chart.

- Backstep indicates the minimum distance between neighboring extrema in candlesticks.

In our case, we can use ZigZag to find extrema and specify training targets for our neural network. By applying the indicator to historical data of the training set, we can determine the direction and distance to the nearest extreme for each candlestick and its preceding candlestick combination. By doing so, we will teach the model to determine the potential direction and strength of a future price movement.

Metrics for evaluating the model's performance can include both the proportion of correctly predicted directional movements and the accuracy in determining the strength of such movements.

The task of predicting the upcoming direction of movement is regarded as a binary classification problem. Based on the ZigZag indicator data, at any given point we can have either an upward movement of the price chart (Buy) or a downward movement of the price chart (Sell). This does not contradict the generally accepted division of trend movements into BUY, SELL, and FLAT, as flat movements are essentially alternating Buy and Sell oscillations of small amplitude.

At the same time, using mathematical statistics alone, we cannot provide a definitive answer about the direction of the upcoming movement. We can only provide a probabilistic answer based on our past experience. We will "draw" this experience from the training sample.

As for predicting the strength of movement, here we would like to obtain a quantitative assessment. This will help to correctly assess the risk of the trade and determine the point for setting take profit with the highest probability of achievement.

In this way, the task of predicting future movement becomes specific and measurable. Let's formulate it as forecasting the most probable direction of the upcoming price movement and its expected strength.

## Defining constants and enumerations

The process of defining constants is one of those basic processes that is often overlooked. Moreover, it enables the organization and systematization of future work on creating a software product. Particular attention should be given to it when creating complex, structured products with a multi-block branched architecture.

Here, we won't discuss specific local variables and constants, as their scope will often be determined by separate blocks or functions. We will discuss creating constants that will serve as a common thread throughout our program and will frequently be used for organizing interactions both between blocks within our product and for data exchange with external programs.

Starting a large project by creating constants and enumerations is a very useful practice. Here, we can also include the creation of global variables. Primarily, this is one of the integral parts of developing project architecture. When contemplating the list of global constants and enumerations, we are re-evaluating our project as a whole, reconsidering its objectives and the means to achieve them. Even in broad strokes, we conceptualize the project structure and define the tasks of each block and the flow of information between them. We also understand what information needs to be obtained from an external program, what information needs to be returned, and at which stage of the process.

The work done at this stage will be our roadmap when creating the project. A detailed examination of data exchange interface organization allows us to assess the necessity of having specific information at each stage. This also provides the opportunity to identify the sources of information and uncover potential data deficits. Eliminating data deficits during the design stage will be much easier than during the implementation phase. At that point, we would have to revisit the design stage to search for the necessary data sources. Next, it will be necessary to consider possible ways of transmitting information from the source to the processing location and attempt to seamlessly integrate them into the established architecture with minimal adjustments. This will lead to an unpredictable number of revisions in the already established processes, and it will be necessary to assess the impact of these revisions on adjacent processes.

We will collect all the files of the library to be built in the NeuroNetworksBook\realization subdirectory according to the [file structure](https://www.mql5.com/en/neurobook/index/realization/files_struct).

All global constants of our project will be collected in one file, defines.mqh.

So what constants are we going to define?

Let's take a look at the architecture of the project. As we've discussed, the result of our work will be a class that encompasses the complete organization of a neural network's operation. In the MQL5 architecture, all objects are inherited from the base class [CObject](https://www.mql5.com/en/docs/standardlibrary/cobject). It includes the virtual Type method which is defined for class identification and which returns an integer value. Consequently, for a unique identification of our class, we should define a certain constant, preferably distinct from the constants of existing classes. This will serve as a prototype for the business card of our class within the program. To create named constants, we will utilize the mechanism of macro substitution.

```
#define defNeuronNet             0x8000
```

Next, our neural network will consist of neurons. Neurons are organized into layers, and a neural network may consist of multiple layers. Since we are constructing a universal constructor, at this stage, we don't know the number of layers in the neural network or the number of neurons in each layer. Therefore, we assume that there will be a dynamic array for storing pointers to neuron layers. Most likely, in addition to simple storage of pointers to neural layer objects, we will need to create additional methods for working with them. Based on these considerations, we will create a separate class for such storage. Consequently, we will also create a business card for it.

```
#define defArrayLayers           0x8001
```

Next in the structure, we will create a separate class for the neural layer. Later, when we approach the implementation of computation algorithms using the OpenCL technology, we will discuss the organization of vector computations and the means of transferring data to the GPU memory. In this context, creating classes for each individual neuron might not be very convenient, but we will need a class for storing information and organizing data exchange buffering. Thus, we must create "business cards" for these objects as well.

It should be noted that the book will explore several architectural solutions for organizing neurons. Each architecture has its own peculiarities in terms of forward and backward propagation algorithms. However, we have already decided that we will not create distinct objects for neurons. So, we need to introduce identification at the level of neural layers. Therefore, we will create separate identifiers for each architecture of the neural layer.

```
#define defBuffer                0x8002

#define defActivation            0x8003

#define defLayerDescription      0x8004

#define defNeuronBase            0x8010

#define defNeuronConv            0x8011

#define defNeuronProof           0x8012

#define defNeuronLSTM            0x8013

#define defNeuronAttention       0x8014

#define defNeuronMHAttention     0x8015

#define defNeuronGPT             0x8016

#define defNeuronDropout         0x8017

#define defNeuronBatchNorm       0x8018
```

We have defined constants and object identifiers and can move further. Let's recall what this book starts with. At the very beginning of the book, we considered a mathematical model of a neuron. Each neuron has an [activation function](https://www.mql5.com/en/neurobook/index/about_ai/activation). We've seen several options for activation functions, and all of them are valid choices. Due to the absence of a derivative, we'll exclude the threshold function from the list. However, we'll implement the remaining discussed activation functions using the OpenCL technology. In the case of working with the CPU, we will use vector operations in which activation functions are already implemented. To maintain consistency in approaches and to indicate the used activation function, we use the standard enumeration [ENUM_ACTIVATION_FUNCTION](https://www.mql5.com/en/docs/matrix/matrix_types/matrix_enumerations#enum_activation_function).

However, it's worth noting that later, when discussing convolutional neural network algorithms, we will become familiar with the organization of a pooling layer. It utilizes other functions.

```
//--- pooling layer activation functions

enum ENUM_PROOF

  {

   AF_MAX_POOLING,

   AF_AVERAGE_POOLING

  };
```

Take a look at the chapter [Training a neural network](https://www.mql5.com/en/neurobook/index/about_ai/study). In it, we discussed various options for loss functions and optimization methods for neural networks. In my understanding, we should provide the user with the ability to choose what they want to use. However, we need to restrict the choices to the capabilities of our library. For a loss function, we can use the standard enumeration [ENUM_LOSS_FUNCTION](https://www.mql5.com/en/docs/matrix/matrix_types/matrix_enumerations#enum_loss_function) by analogy with the activation function. For model optimization methods, we will create a new enumeration.

As you can observe, in the enumeration of optimization methods, I added the None element to allow the option of disabling training for a specific layer. Such an approach is often utilized when using a pre-trained network on new data. For instance, we might have a trained and functioning neural network that works well on one financial instrument, and we would like to replicate it for other instruments or timeframes. In all likelihood, without retraining, its performance will drop dramatically.

```
enum ENUM_OPTIMIZATION

  {

   None=-1,

   SGD,

   MOMENTUM,

   AdaGrad,

   RMSProp,

   AdaDelta,

   Adam

  };
```

In this case, we have a choice: to train the neural network from scratch or to retrain the existing network. The second option usually requires less time and resources. However, to avoid disrupting the entire network, the retraining process starts with a low learning rate and focuses on the final layers (decision-making neurons), while leaving the initial analytical layers untrained.

Along with the learning methods, we discussed [techniques for improving the convergence](https://www.mql5.com/en/neurobook/index/about_ai/improvement) of neural networks. In this regard, normalization and dropout will be organized as separate layers — for them, we have already defined constants when discussing neural layers. We will implement one regularization — Elastic Net. The process will be controlled through the variables λ1 and λ2. If both variables are zero, regularization is disabled. In the case where one of the parameters is equal to zero, we will obtain L1 or L2 regularization, depending on the non-zero parameter.

Have you noticed that in this chapter we have refreshed our memories of the major milestones of the material we have studied? In addition, behind each constant or enumeration element, there is a specific functionality that we still need to implement.

But I'd like to add one more point. When introducing the OpenCL technology, we discussed that not all OpenCL-enabled devices work with the double type. It would probably be foolish to create copies of the library for different data types.

Here it's important to understand that different data types provide different levels of precision for computations. Therefore, when creating a model, it's important to ensure consistent conditions for all scenarios of model operation, both with and without using the OpenCL technology. To address this issue, we will introduce data type macros along with corresponding types for vectors and matrices.

```
#define TYPE                      double

#define MATRIX                    matrix<TYPE>

#define VECTOR                    vector<TYPE>
```

We organize a similar macro substitution for an OpenCL program.

```
#resource "opencl_program.cl" as string OCLprogram

//---

#define LOCAL_SIZE                256

const string ExtType=StringFormat("#define TYPE %s\r\n"

                                  "#define TYPE4 %s4\r\n"

                                  "#define LOCAL_SIZE %d\r\n",

                                   typename(TYPE),typename(TYPE),LOCAL_SIZE);

#define cl_program                ExtType+OCLprogram
```

Here we can also add to the models various hyperparameters. For example, it could be a learning rate. You can also add parameters for optimization and regularization methods.

```
#define defLossSmoothFactor       1000

#define defLearningRate           (TYPE)3.0e-4

#define defBeta1                  (TYPE)0.9

#define defBeta2                  (TYPE)0.999

#define defLambdaL1               (TYPE)0

#define defLambdaL2               (TYPE)0
```

However, it's important to keep in mind that the hyperparameter values mentioned here are just default values. During the operation of the model, we will use variables that will be initialized with these values when the model is created. However, the user has the right to specify different values without changing the library code. We will discuss the mechanism of such a process when constructing classes and their methods.

## Mechanism for describing the structure of the future neural network

We have already decided that we will build a universal constructor for the convenient creation of neural networks of various configurations. Hence, we need some mechanism (interface) to be able to pass the model configuration to be built. Let's think about what information we need to get from the user to unambiguously understand what kind of neural network is supposed to be created.

First of all, we need to understand how many layers of neurons our network will have. There should be at least two such layers: an input layer with initial data and an output layer with results. Additionally, the new neural network may include a varying quantity of hidden layers. Their quantity may vary, and we will not limit them now.

To create each layer of the neural network, we need to know the number of neurons in that layer. Hence, in addition to the number of neural layers, the user must specify the number of neurons in each layer.

Now let's recall that in the previous section, we defined constants for several types of neural layers, which will differ by the type of neurons. To understand what kind of layer the user wants to create, you need to get that initial information. So, the user should be able to specify it for each layer that is created.

In addition, we considered different variants of activation functions. Which one should be used when creating neurons?

When creating a universal tool, we must provide the user with the option to choose the activation function. Hence, we add the activation function to the list of parameters that the user should specify.

Then there is another question: will all neurons in the same layer use the same activation function? Or will there be options to use different activation features within a single layer? I propose to focus on the first option, where all neurons of one layer use one activation function.

Let me explain my point. While discussing techniques to improve the convergence of neural networks and, in particular, data [normalization](https://www.mql5.com/en/neurobook/index/about_ai/improvement/normalization), we talked about the importance of data comparability at the input of the neural layer. The use of different activation functions, on the other hand, is highly likely to lead to data imbalance. This is due to the nature of the activation functions themselves. Remember, the sigmoid returns data in the range from 0 to 1. The value range of the hyperbolic tangent lies in the range from -1 to 1. ReLU can return values from 0 to +∞. Evidently, different activation functions will produce significantly different values and only complicate the training and operation of the neural network.

Additionally, from a technical perspective, there are also advantages to using one activation function for the entire neural layer. In this case, we can then limit ourselves to a single integer value to store the activation code of neurons in a layer regardless of the number of neurons. To store individual activation functions, we would have had to create a whole vector of values the size of the number of neurons in the layer.

The next thing we need to know when creating the architecture of a neural network is the weight optimization method. In the chapter [Neural network optimization methods](https://www.mql5.com/en/neurobook/index/about_ai/study/optimization), we covered six optimization methods. In the previous chapter, we set up an enumeration to identify them. Now you can take advantage of this enumeration and let the user choose one of them.

Why is it important for us to know the optimization method now, at the stage of creating the neural network, rather than during its training? It's very simple. Different optimization methods require different amounts of objects to store information, so when creating a neural network, it is necessary to create all the required objects. Given that we have memory constraints on our computing machine, we need to use it rationally and not create unnecessary objects.

When creating layers such as normalization and Dropout, we will need some specific information. For normalization, we need the normalization sample size (batch), and for Dropout, we need to specify the probability of "dropping out" neurons during training.

Looking ahead, for some types of neural layers, we will still need the size of the input and output window, as well as the step size from the beginning of one input window to the beginning of the next window.

To make it easier for the user to create consecutively identical layers, let's add another parameter to specify such a sequence.

As a result, we have accumulated a dozen parameters that the user needs to specify for each layer. Let's add to this the total number of layers to create in a neural network. These are all things we want to get from the user before creating the neural network. We will not overly complicate the data transfer process, and to describe one neural layer, we will create a class named CLayerDescription with elements to store the specified parameters.

```
class CLayerDescription    :  public CObject

  {

public:

                     CLayerDescription(void);

                    ~CLayerDescription(void) {};

   //---

   int               type;         // Type of neural layer

   int               count;        // Number of neurons in a layer

   int               window;       // Source data window size

   int               window_out;   // Results window size

   int               step;         // Input data window step

   int               layers;       // Number of neural layers

   int               batch;        // Weight Matrix Update Packet Size

   ENUM_ACTIVATION_FUNCTION   activation;  // Activation function type

   VECTOR            activation_params[2]; // Array of activation function parameters

   ENUM_OPTIMIZATION optimization; // Weight matrix optimization type

   TYPE              probability;  // masking probability, Dropout only

  };
```

Note that the created class is inherited from the CObject class, which is the base class for all objects in MQL5. It's a small point that we'll exploit a little later.

We will not complicate the class constructor in any way, but only set some default values. You can use any of your values here. I recommend, however, that you specify the most commonly used parameters. This will make it easier for you to specify them later in the program code.

```
CLayerDescription::CLayerDescription(void)   :  type(defNeuronBase),

                                                count(100),

                                                window(100),

                                                step(100),

                                                layers(1),

                                                activation(AF_TANH),

                                                optimization(Adam),

                                                probability(0.1),

                                                batch(100)

  {

   activation_params = VECTOR::Ones(2);

   activation_params[1] = 0;

  }
```

Now let's get back to why it was important to inherit from CObject. Here everything is quite straightforward: we have created an object to describe one neural layer but not the whole neural network. We have not yet specified the total number of layers and their sequence.

I decided not to complicate the process and use the [CArrayObj](https://www.mql5.com/en/docs/standardlibrary/datastructures/carrayobj) class from the standard MQL5 library. This is a dynamic array class for storing pointers to CObject objects and their successors. Hence, we can write our neural layer description objects into it. In this way, we address the issue of a container for storing and transmitting information about neural networks. The sequence of neural layers will correspond to the sequence of stored descriptions from the zero-index input layer to the output layer.

In my opinion, this is a rather simple and intuitive way to describe the structure of a neural network. But every reader can make use of their own developments.

## Dynamic array of neural layer storage

It is worth mentioning a few words about the dynamic array CArrayLayers that stores neural layers. As previously announced, it is based on the standard CArrayObj object array class.

The functionality of the parent class almost entirely meets our requirements for a dynamic array. When examining the source code of the parent class, you can find all the functionality related to the dynamic array operations and accessing its elements. Additionally, methods for working with files (writing and reading an array) are also implemented. For this, special thanks to the [MetaQuotes](https://www.metaquotes.net/) team.

When examining the algorithm of the method that reads an array from the Load file in detail, pay attention to the CreateElement method which creates a new element.

In the previous section, when discussing the method for reading a neural network from a file, prior to reading the data, we instantiated an object of the corresponding class. The mentioned method performs similar functionality, but it is not implemented in the parent class. This is quite understandable and reasonable, as the creators of the class couldn't anticipate the specific objects their array would store, and thus couldn't create a method generating an unknown class. Therefore, they left a virtual method to be overridden in the user-defined class.

And as consumers of their product, we create our own dynamic array class by inheriting the core functionality from the parent class. In this case, we override the method of creating a new array element.

```
class CArrayLayers   :  public CArrayObj

  {

protected:

   CMyOpenCL*        m_cOpenCL;

   int               m_iFileHandle;

public:

                     CArrayLayers(void) : m_cOpenCL(NULL),

                                          m_iFileHandle(INVALID_HANDLE)

                     { }

                    ~CArrayLayers(void) { };

   //---

   virtual bool      SetOpencl(CMyOpenCL *opencl);

   virtual bool      Load(const int file_handle) override;

   //--- method creating an element of an array

   virtual bool      CreateElement(const int index) override;

   virtual bool      CreateElement(const int index,

                                   CLayerDescription* description);

   //--- method identifying the object

   virtual int       Type(void) override const { return(defArrayLayers); }

  };
```

One more point should be noted. In order for our overridden method to be called from the parent class method, its definition must fully match the definition of the parent class method, including parameters and return value. Of course, there is nothing complex in this, but we are faced with the same question that the team of creators of the parent class had: what object to create?

We know it will be a neural layer object, but we don't know what type. We can save the type of the required neural layer to a file before writing the contents of the object itself. However, how can we read it from the file if the method doesn't receive a file handle for loading data?

At the same time, we pass the file handle when we call the data loading method Load. Evidently, we need to override the load method as well. But I wouldn't want to rewrite the whole method. Therefore, I added the variable m_iFileHandle, in which I save the file handle for loading data when the Load method is called. Then I call a similar method of the parent class.

```
bool CArrayLayers::Load(const int file_handle)

  {

   m_iFileHandle = file_handle;

   return CArrayObj::Load(file_handle);

  }
```

Now let's look directly at the method of creating a new neural layer in a dynamic array. In the parameters, the method receives the index of the element to be created. At the beginning of the method, we check that the resulting index is not negative, because the index of an element of a dynamic array cannot be less than zero. We will also check the saved file handle for loading — without it, we won't be able to determine the type of the element being created.

Next, we reserve an element in our array, read the type of the element to be created from the file, and create an instance of the type we need. Let's not forget to check the result of creating a new object, pass a pointer to the OpenCL object into the new element, and save the pointer to the new neural layer into our array. In conclusion, let's ensure that the index of the new element does not exceed the maximum number of elements in the array.

```
bool CArrayLayers::CreateElement(const int index)

  {

//--- source data verification block

   if(index < 0 || m_iFileHandle==INVALID_HANDLE)

      return false;

//--- reserving an array element for a new object

   if(!Reserve(index + 1))

      return false;

//--- read the type of the desired object from the file and create the corresponding neural layer

   CNeuronBase *temp = NULL;

   int type = FileReadInteger(m_iFileHandle);

   switch(type)

     {

      case defNeuronBase:

         temp = new CNeuronBase();

         break;

      case defNeuronConv:

         temp = new CNeuronConv();

         break;

      case defNeuronProof:

         temp = new CNeuronProof();

         break;

      case defNeuronLSTM:

         temp = new CNeuronLSTM();

         break;

      case defNeuronAttention:

         temp = new CNeuronAttention();

         break;

      case defNeuronMHAttention:

         temp = new CNeuronMHAttention();

         break;

      case defNeuronGPT:

         temp = new CNeuronGPT();

         break;

      case defNeuronDropout:

         temp = new CNeuronDropout();

         break;

      case defNeuronBatchNorm:

         temp = new CNeuronBatchNorm();

         break;

      default:

         return false;

     }

//--- control over the creation of a new object

   if(!temp)

      return false;

//--- add a pointer to the created object to the array

   if(m_data[index])

      delete m_data[index];

   temp.SetOpenCL(m_cOpenCL);

   m_data[index] = temp;

//---

   return true;

  }
```

Since a new class has been created, I decided to add a couple more methods to it. The first thing I added was a similar method for generating a new item. The difference is that the new method creates a new layer based on the description obtained in the method parameters. The algorithm of the method is almost completely the same as above, except for some details.

```
bool CArrayLayers::CreateElement(const int index, CLayerDescription *desc)

  {

//--- source data verification block

   if(index < 0 || !desc)

      return false;

//--- reserve an array element for a new object

   if(!Reserve(index + 1))

      return false;

//--- create the corresponding neural layer

   CNeuronBase *temp = NULL;

   switch(desc.type)

     {

      case defNeuronBase:

         temp = new CNeuronBase();

         break;

      case defNeuronConv:

         temp = new CNeuronConv();

         break;

      case defNeuronProof:

         temp = new CNeuronProof();

         break;

      case defNeuronLSTM:

         temp = new CNeuronLSTM();

         break;

      case defNeuronAttention:

         temp = new CNeuronAttention();

         break;

      case defNeuronMHAttention:

         temp = new CNeuronMHAttention();

         break;

      case defNeuronGPT:

         temp = new CNeuronGPT();

         break;

      case defNeuronDropout:

         temp = new CNeuronDropout();

         break;

      case defNeuronBatchNorm:

         temp = new CNeuronBatchNorm();

         break;

      default:

         return false;

     }

//--- control over the creation of a new object

   if(!temp)

      return false;

//--- add a pointer to the created object to the array

   if(!temp.Init(desc))

      return false;

   if(m_data[index])

      delete m_data[index];

   temp.SetOpenCL(m_cOpenCL);

   m_data[index] = temp;

   m_data_total  = fmax(m_data_total, index + 1);

//---

   return true;

  }
```

The second added method is responsible for passing a pointer to the OpenCL object to all previously created layers of our neural network, as the decision to use this technology can be made either before or after the neural network is generated. For example, a neural network can be created and tested for performance without using OpenCL technology. Further, the technology can be leveraged to accelerate the learning process.

The algorithm of the method is quite simple. We first check if the pointer was previously set and delete the old object if necessary. Then we save the new pointer and start the loop for enumerating the elements of the dynamic array. In this case, we will pass a new pointer to an OpenCL object to each element of the array.

```
bool CArrayLayers::SetOpencl(CMyOpenCL *opencl)

  {

//--- source data verification block

   if(m_cOpenCL)

      delete m_cOpenCL;

   m_cOpenCL = opencl;

//--- passing a pointer to all array elements

   for(int i = 0; i < m_data_total; i++)

     {

      if(!m_data[i])

         return false;

      if(!((CNeuronBase *)m_data[i]).SetOpenCL(m_cOpenCL))

         return false;

     }

//---

   return(!!m_cOpenCL);

  }
```

## Creating a neural layer using MQL5 tools

When starting to implement a fully connected neural layer, it should be taken into account that this will be the base class for all subsequent architectural solutions of neural layers. Therefore, we must make it as versatile as possible while also allowing for a potential expansion of functions. At the same time, we should provide the possibility to easily integrate extensions into the existing solution.

Let's start by creating our neural layer base class CNeuronBase inherited from the CObject class. We define the internal variables of the class:

- m_cOpenCL — a pointer to an instance of the class for working with OpenCL technology

- m_cActivation — a pointer to an activation function object

- m_eOptimization — the type of neuron optimization method during training

- m_cOutputs — an array of values at the output of neurons

- m_cWeights — an array of weights

- m_cDeltaWeights — an array for accumulating outstanding weight updates (cumulative error gradient for each weight since the last update)

- m_cGradients — the error gradient at the output of the neural layer as a result of the last iteration of the backward pass

- m_cMomenum — unlike other variables, this will be an array of two elements for recording pointers to arrays of accumulated moments

To facilitate access to variables from derived classes, all variables will be declared in a block called protected.

In the class constructor, we initialize the above variables with default parameters. I have specified Adam and Swish optimization method as an activation function but you can choose your preferred optimization method and activation function. We will leave the pointer to the class working with OpenCL empty and create instances for all other classes used.

```
CNeuronBase::CNeuronBase(void)   : m_eOptimization(Adam)

  {

   m_cOpenCL = NULL;

   m_cActivation = new CActivationSwish();

   m_cOutputs = new CBufferType();

   m_cWeights = new CBufferType();

   m_cDeltaWeights = new CBufferType();

   m_cGradients = new CBufferType();

   m_cMomenum[0] = new CBufferType();

   m_cMomenum[1] = new CBufferType();

  }
```

We immediately create a class destructor so we don't forget about memory cleanup after the class finishes its work.

```
CNeuronBase::~CNeuronBase(void)

  {

   if(!!m_cActivation)

      delete m_cActivation;

   if(!!m_cOutputs)

      delete m_cOutputs;

   if(!!m_cWeights)

      delete m_cWeights;

   if(!!m_cDeltaWeights)

      delete m_cDeltaWeights;

   if(!!m_cGradients)

      delete m_cGradients;

   if(!!m_cMomenum[0])

      delete m_cMomenum[0];

   if(!!m_cMomenum[1])

      delete m_cMomenum[1];

  }
```

Next, we create a neural layer initialization method. In the parameters, the method receives an instance of the CLayerDescription class with a description of the layer to be created. To avoid getting lost in the intricacies of the method algorithm, I suggest breaking it down into separate logical blocks

The method starts with a block in which we check input parameters. First, we check the validity of the pointer to the object. Then we check the type of the layer being created and the number of neurons in the layer: each layer should have at least one neuron, because from the logical perspective of constructing a neural network, a layer without neurons blocks the passage of the signal and paralyzes the entire network. Note that when checking the type of the created layer, we use the virtual method Type and not the constant defNeuronBase which it returns. This is a very important point for future class inheritance. The fact is that when using a constant, calling such a method for descendant classes would always return false when trying to create a layer other than the base one. Using a virtual method allows us to obtain a constant identifier of the final derived class, and the check will yield a true comparison result between the specified type of neural layer and the object being created.

```
bool CNeuronBase::Init(const CLayerDescription *desc)

  {

//--- source data control block

   if(!desc || desc.type != Type() || desc.count <= 0)

      return false;
```

In the next block, we will verify the validity of previously created buffers for recording the data flow coming out of the neural layer and the gradient to them (if necessary, we create new instances of the class). We initialize arrays with zero values.

```
//--- creating a results buffer

   if(!m_cOutputs)

      if(!(m_cOutputs = new CBufferType()))

         return false;

   if(!m_cOutputs.BufferInit(1, desc.count, 0))

      return false;

//--- creating error gradient buffer

   if(!m_cGradients)

      if(!(m_cGradients = new CBufferType()))

         return false;

   if(!m_cGradients.BufferInit(1, desc.count, 0))

      return false;
```

After that, we check the number of elements of the input signal. In the case of using the neural layer as an array of incoming signals, we will not have preceding neural layers, and other data buffers will not be required. We can remove them without any problem and clear the memory. Then we check the validity of the pointer to the object in m_cOpenCL and, if the result is positive, we create a copy of the data buffer in the OpenCL context.

```
//--- removing unused features for the source data layer

   if(desc.window <= 0)

     {

      if(m_cActivation)

         delete m_cActivation;

      if(m_cWeights)

         delete m_cWeights;

      if(m_cDeltaWeights)

         delete m_cDeltaWeights;

      if(m_cMomenum[0])

         delete m_cMomenum[0];

      if(m_cMomenum[1])

         delete m_cMomenum[1];

      if(m_cOpenCL)

         if(!m_cOutputs.BufferCreate(m_cOpenCL))

            return false;

      m_eOptimization = desc.optimization;

      return true;

     }
```

Further method code is executed only if there are previous neural layers. Let's create and initialize an instance of the activation function method. We have moved this process to a separate method, SetActivation, which we are now simply calling. We will examine the algorithm of the SetActivation method a bit later.

```
//--- initializing an activation function object

   VECTOR ar_temp = desc.activation_params;

   if(!SetActivation(desc.activation, ar_temp))

      return false;
```

The next step is to initialize the matrix of weights. We determine the number of elements in the matrix and initialize it with [random values](https://www.mql5.com/en/neurobook/index/about_ai/initialization#random) using the Xavier method. In the case of using LReLU as an activation function, we will use the He method.

```
//--- initializing a weight matrix object

   if(!m_cWeights)

      if(!(m_cWeights = new CBufferType()))

         return false;

   if(!m_cWeights.BufferInit(desc.count, desc.window + 1, 0))

      return false;

   double weights[];

   double sigma = (desc.activation == AF_LRELU ?

                  2.0 / (double)(MathPow(1 + desc.activation_params[0], 2)

                                                           * desc.window) :

                  1.0 / (double)desc.window);

   if(!MathRandomNormal(0, MathSqrt(sigma), m_cWeights.Total(), weights))

      return false;

   for(uint i = 0; i < m_cWeights.Total(); i++)

      if(!m_cWeights.m_mMatrix.Flat(i, (TYPE)weights[i]))

         return false;
```

We still need to initialize the buffers for deltas and moments. The size of the buffers will be equal to the size of the weight matrix, and we will initialize them with zero values. Remember that not all optimization methods use the moment matrices in the same way. Therefore, we will initialize the matrices of moments depending on the optimization method. We will clear and delete unnecessary arrays to free up memory for productive use.

```
//--- initialization of the gradient accumulation object at the weight matrix level

   if(!m_cDeltaWeights)

      if(!(m_cDeltaWeights = new CBufferType()))

         return false;

   if(!m_cDeltaWeights.BufferInit(desc.count, desc.window + 1, 0))

      return false;

//--- initializing moment objects

   switch(desc.optimization)

     {

      case None:

      case SGD:

         for(int i = 0; i < 2; i++)

            if(m_cMomenum[i])

               delete m_cMomenum[i];

         break;
```

```
case MOMENTUM:

      case AdaGrad:

      case RMSProp:

         if(!m_cMomenum[0])

            if(!(m_cMomenum[0] = new CBufferType()))

               return false;

         if(!m_cMomenum[0].BufferInit(desc.count, desc.window + 1, 0))

            return false;

         if(m_cMomenum[1])

            delete m_cMomenum[1];

         break;
```

```
case AdaDelta:

      case Adam:

         for(int i = 0; i < 2; i++)

           {

            if(!m_cMomenum[i])

               if(!(m_cMomenum[i] = new CBufferType()))

                  return(false);

            if(!m_cMomenum[i].BufferInit(desc.count, desc.window + 1, 0))

               return false;

           }

         break;
```

```
default:

         return false;

         break;

     }

//--- saving parameter optimization method

   m_eOptimization = desc.optimization;

   return true;

  }
```

At the end of the method we save the specified weight optimization method.

The SetOpenCL method is used to save a pointer to the object of work with the OpenCL context and looks simpler than the initialization method. However, unlike all previously considered methods, we do not terminate the method operation upon receiving an invalid pointer to the object. This is because we do not introduce a flag for the use of OpenCL technology in every neural layer class. Instead, we use a single flag in the base class of the neural network. In turn, to check the use of the technology inside the class, we can verify the validity of the pointer in the m_cOpenCL variable.

It should be noted that all objects of the neural network operate within a single OpenCL context. All objects are provided with a pointer to the same object of the CMyOpenCL class. With such an approach, deleting an instance of the class in one of the neural network objects will invalidate the pointer in all objects that use it. The flag may not correspond to the current state of the pointer. Additionally, in the case of disabling the use of technology, we leave the possibility of specifying an empty value of the pointer to the object.

Therefore, the code of our method can be conditionally divided into two parts. The first part of the code will be executed when receiving an invalid pointer to the object. In this case, we need to clear all previously created data buffers in the OpenCL context.

```
bool CNeuronBase::SetOpenCL(CMyOpenCL *opencl)

  {

   if(!opencl)

     {

      if(m_cOutputs)

         m_cOutputs.BufferFree();

      if(m_cGradients)

         m_cGradients.BufferFree();

      if(m_cWeights)

         m_cWeights.BufferFree();

      if(m_cDeltaWeights)

         m_cDeltaWeights.BufferFree();

      for(int i = 0; i < 2; i++)

        {

         if(m_cMomenum[i])

            m_cMomenum[i].BufferFree();

        }

      if(m_cActivation)

         m_cActivation.SetOpenCL(m_cOpenCL, Rows(), Cols());

      m_cOpenCL = opencl;

      return true;

     }
```

The second part of the method will be executed when receiving a valid pointer to the object working with the OpenCL context. Here, we organize the creation of new data buffers in the specified OpenCL context for all objects of the current class.

```
if(m_cOpenCL)

      delete m_cOpenCL;

   m_cOpenCL = opencl;

   if(m_cOutputs)

      m_cOutputs.BufferCreate(opencl);

   if(m_cGradients)

      m_cGradients.BufferCreate(opencl);

   if(m_cWeights)

      m_cWeights.BufferCreate(opencl);

   if(m_cDeltaWeights)

      m_cDeltaWeights.BufferCreate(opencl);

   for(int i = 0; i < 2; i++)

     {

      if(m_cMomenum[i])

         m_cMomenum[i].BufferCreate(opencl);

     }
```

```
if(m_cActivation)

      m_cActivation.SetOpenCL(m_cOpenCL, Rows(), Cols());

//---

   return(!!m_cOpenCL);

  }
```

Earlier, we talked about isolating the activation function initialization procedure into a separate method. I suggest examining this method to complete the description of the new object initialization process. This is one of the few methods where we don't organize a block for data verification. Verification of the activation function parameters is not feasible due to the variance in the range of permissible values when using different functions. In most cases, the range of their values is limited only by common sense and the architectural requirements of the model.

As for the choice of the activation function, it exists implicitly, in the form of a list of allowable values. But even if the user inserts a value not from the enumeration, we will create activation function objects within the body of the switch statement. This means that we will have implicit control over the type of the activation function, and if the specified value is absent in the selection function, we will create a base class without an activation function.

The need to create a base class is due to maintaining the functionality of the class without using an activation function in standard mode. As you will see a little later, in some cases we will use neural layers without activation functions.

```
bool CNeuronBase::SetActivation(ENUM_ACTIVATION_FUNCTION function, VECTOR &params)

  {

   if(m_cActivation)

      delete m_cActivation;
```

```
switch(function)

     {

      case AF_LINEAR:

         if(!(m_cActivation = new CActivationLine()))

            return false;

         break;
```

```
case AF_SIGMOID:

         if(!(m_cActivation = new CActivationSigmoid()))

            return false;

         break;
```

```
case AF_LRELU:

         if(!(m_cActivation = new CActivationLReLU()))

            return false;

         break;
```

```
case AF_TANH:

         if(!(m_cActivation = new CActivationTANH()))

            return false;

         break;
```

```
case AF_SOFTMAX:

         if(!(m_cActivation = new CActivationSoftMAX()))

            return false;

         break;
```

```
case AF_SWISH:

         if(!(m_cActivation = new CActivationSwish()))

            return false;

         break;
```

```
default:

         if(!(m_cActivation = new CActivation()))

            return false;

         break;

     }
```

After creating an instance of the required activation function object, we pass the function parameters and a pointer to the OpenCL context object to the new object.

```
if(!m_cActivation.Init(params[0], params[1]))

      return false;

   m_cActivation.SetOpenCL(m_cOpenCL, m_cOutputs.Rows(), m_cOutputs.Cols());

   return true;

  }
```

Feed-forward operations will be implemented in the FeedForward method. In the parameters, the method receives a pointer to the object of the previous layer. Since we are planning to build the classes of all neural layers based on one base class, we can use the class of the base neural layer in the method parameters to get a pointer to the previous layer of any type. The use of virtual access methods to the internal objects of the class allows you to build a universal interface without being tied to a specific type of neural layer.

At the beginning of the method, we check the validity of pointers to all objects used in the method. This is our initial data: the pointer to the previous layer received in the parameters, as well as the buffer of the neurons' output states contained in it. Together with them, we will check the pointers to the weight matrix and the buffer for recording the results of the forward pass of the current layer, that is, the buffer of the output states of the neurons of the current layer. Again, it's a good practice to check the pointer to the instance of the class for calculating the values of the activation function.

```
bool CNeuronBase::FeedForward(CNeuronBase * prevLayer)

  {

//--- control block

   if(!prevLayer || !m_cOutputs || !m_cWeights ||

      !prevLayer.GetOutputs() || !m_cActivation)

      return false;

   CBufferType* input_data = prevLayer.GetOutputs();
```

Then we check the pointer to the object working with OpenCL. If the pointer is valid, we move on to the block that is using this technology. We will talk about it a little later when considering the organization of the process of parallel computing. In case of an invalid pointer to an object or its absence, we move on to the block of calculations using standard MQL5 tools. Here, we will first check the consistency of matrix sizes and reformat the source data matrix into a vector, adding a unit element for the bias. We will perform the operation of matrix multiplication by the weight matrix. The result will be written to the outgoing stream buffer. Before exiting the method, do not forget to compute the values of the activation function at the output of the neural layer.

```
//---branching of the algorithm depending on the device for performing operations

   if(!m_cOpenCL)

     {

      if(m_cWeights.Cols() != (input_data.Total() + 1))

         return false;

      //---

      MATRIX m = input_data.m_mMatrix;

      if(!m.Reshape(1, input_data.Total() + 1))

         return false;

         m[0, m.Cols() - 1] = 1;

         m_cOutputs.m_mMatrix = m.MatMul(m_cWeights.m_mMatrix.Transpose());

        }
```

```
else

     {

      //--- Here is the code for accessing the OpenCL program

      return false;

     }

//---

   return m_cActivation.Activation(m_cOutputs);

  }
```

The forward pass is followed by the [backpropagation pass](https://www.mql5.com/en/neurobook/index/about_ai/study/back_propagation). We break down this neural network training procedure into component parts and create four methods:

- CalcOutputGradient for calculating the error gradient at the output of the neural network,

- CalcHiddenGradient to enable the gradient propagation through the hidden layer,

- CalcDeltaWeights for calculating the necessary weight adjustments,

- UpdateWeights for updating the weight matrix.

We will move along the data flow path and consider the algorithm of each method.

In the process of supervised learning, after the forward pass, the calculated output values of the neural network are compared with the target values. The deviation on each neuron of the output layer is determined at this moment. We perform this operation in the CalcOutputGradient method. The algorithm of this method is quite simple: the method receives an array of target values and the type of the loss function used as parameters. At the beginning of the method, we will validate the pointers to the used objects as well as ensure the compatibility of the array sizes.

```
bool CNeuronBase::CalcOutputGradient(CBufferType * target, ENUM_LOSS_FUNCTION loss)

  {

//--- control block

   if(!target || !m_cOutputs || !m_cGradients ||

      target.Total() < m_cOutputs.Total() ||

      m_cGradients.Total() < m_cOutputs.Total())

      return false;
```

Next, similar to the feed-forward method, we will create a branching in the algorithm depending on the device used for calculations. The algorithm using the OpenCL technology will be discussed in the next chapter, and now let's look at the process construction using MQL5.

Let's take a look at the process of computing the error gradient at the output of the neural network. At first glance, we should move in the direction of minimizing the error for each neuron. In other words, calculate the difference between the reference and calculated values and minimize this difference. In this case, we get a linear dependence of the error and the gradient. This is true when using [mean absolute error](https://www.mql5.com/en/neurobook/index/about_ai/study/loss#mae) as a loss function, with all the resulting advantages and disadvantages.

When we were talking about the [loss function](https://www.mql5.com/en/neurobook/index/about_ai/study/loss), we considered other options and discussed their advantages and disadvantages. But how can we take advantage of them? The answer here is pretty simple. One should consider the loss function and the trainable model as a single complex function. In this case, we should minimize not the deviation for each neuron of the output layer, but directly the value of the loss function. Just as when propagating the error gradient through the neural network, we calculate the derivative of the loss function and multiply it by the deviation of the loss function value from zero. Moreover, for MAE and MSE we can consider only the derivative of the loss function as the error and disregard multiplying it by the value of the loss function since this linear scaling will be compensated by the learning rate, while when using cross-entropy, we are compelled to multiply it by the value of the loss function. The reason is that if the target and calculated values are equal, the loss function will give 0, and its derivative will be equal to −1. If we don't multiply the derivative by the error, we will continue adjusting the model parameters in the absence of an error.

In this case, it is not at all necessary to fully calculate the value of the loss function. Cross-entropy is commonly used as the loss function in classification tasks. Therefore, as target values, we expect to obtain a vector in which only one element will be set to one, while all others will be zero. For zero values, the derivative will also be zero, and multiplication by 1 doesn't change the result. Therefore, it is enough for us to multiply the derivative by the logarithm of the calculated value. It is the logarithm of 1 that will give 0, indicating that there is no error.

Taking into account the above, to calculate the corresponding error gradient at the model's output, we will use a switch statement to create a branching process based on the employed loss function. In case the specified loss function is not present, we will calculate the simple deviation of the calculated results from the target values.

```
//---branching of the algorithm depending on the device for performing operations

   if(!m_cOpenCL)

     {

      switch(loss)

        {

         case LOSS_MAE:

            m_cGradients.m_mMatrix = target.m_mMatrix - m_cOutputs.m_mMatrix;

            break;

         case LOSS_MSE:

            m_cGradients.m_mMatrix = (target.m_mMatrix - m_cOutputs.m_mMatrix) * 2;

            break;

         case LOSS_CCE:

            m_cGradients.m_mMatrix = target.m_mMatrix /

           (m_cOutputs.m_mMatrix + FLT_MIN) * MathLog(m_cOutputs.m_mMatrix) * (-1);

            break;
```

```
case LOSS_BCE:

            m_cGradients.m_mMatrix = (target.m_mMatrix-m_cOutputs.m_mMatrix) /

               (MathPow(m_cOutputs.m_mMatrix, 2) - m_cOutputs.m_mMatrix + FLT_MIN);

            break;

         default:

            m_cGradients.m_mMatrix = target.m_mMatrix - m_cOutputs.m_mMatrix;

            break;

        }

     }

   else

      return false;

//---

   return true;

  }
```

After obtaining the error at the neural network output, it's necessary to determine the influence of each neuron in our network on this error. To achieve this, we need to propagate the error gradient layer by layer, reaching every neuron. The responsibility for organizing the loop that iterates through the layers of the neural network lies with the network manager, that is, [the neural network base class](https://www.mql5.com/en/neurobook/index/realization/basic/neuron_base#back_propfgation) CNet. Now we will examine the organization of the process within a single neural layer.

In the parameters, the CalcHiddenGradient method receives a pointer to the previous layer of the neural network. We will need it to write the transmitted error gradient. In the previous method, we determined the error at the neuron output, but the neuron output value depends on the activation function. To determine the influence of each element of the input data on the final result, it's necessary to exclude the influence of the activation function on the error. To achieve this, we will adjust the error gradient using the derivative of the activation function. This operation, like the computation of the activation function itself, is implemented in a separate class.

```
bool CNeuronBase::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

//--- adjusting the incoming gradient to the derivative of the activation function

   if(!m_cActivation.Derivative(m_cGradients))

      return false;
```

Next comes the block in which we check pointers of used objects. First, we validate the received pointer to the previous layer. Then, we extract and validate the pointers to the buffers of results and gradients from the previous layer. We also verify the consistency of the number of elements in the specified buffers. Additionally, we check the presence of a sufficient number of elements in the weight matrix. Such a number of preventive checks are necessary for the stable operation of the method and to prevent potential errors when accessing data arrays.

```
//--- checking the buffers of the previous layer

   if(!prevLayer)

      return false;

   CBufferType *input_data = prevLayer.GetOutputs();

   CBufferType *input_gradient = prevLayer.GetGradients();

   if(!input_data || !input_gradient ||

      input_data.Total() != input_gradient.Total())

      return false;

//--- checking the correspondence between the size of the source data buffer and the weight matrix

   if(!m_cWeights || m_cWeights.Cols() != (input_data.Total() + 1))

      return false;
```

After successfully passing all the checks, we proceed directly to the computational part. Let me remind you that the derivative of the product of a variable and a constant is a constant. In this case, the derivative with respect to the neuron is the corresponding weight. Consequently, the neuron influence on the result is the product of the error gradient at the output of the function and the corresponding weight. We will calculate the sum of such products for each neuron in the previous layer. We will write the obtained values into the corresponding cell of the gradient buffer of the previous layer.

As in the methods described above, we carry out the separation of the algorithm depending on the computing device used. We will get acquainted with the algorithm for implementing multi-threaded calculations a little later. Let's now consider the implementation of the algorithm using MQL5 tools. As mentioned earlier, we need to calculate the sum of products of error gradients from neurons dependent on a given neuron and their corresponding weights. Performing this operation is easily accomplished using matrix multiplication. In this case, it suffices to multiply the error gradient matrix by the matrix of weights. We will store the result of the operation in a local matrix.

We cannot immediately write the result of the operation to the error gradient matrix of the previous layer. If you look at the forward pass method, you will see how we added the bias element. Accordingly, when multiplying matrices, we will get the result, taking into account the error on the bias element. However, the previous layer does not expect this value, and the size of the matrix of gradients is smaller. Therefore, we will first resize the matrix obtained from the multiplication operation to the required dimensions, and then transfer its values to the gradient matrix of the previous layer.

Note that in this method, we do not adjust the gradient obtained at the output of the previous layer by the derivative of the activation function of neurons in the previous layer, as we did with a similar operation at the beginning of this method. Therefore, if the previous layer is the hidden layer of our network, then the first thing that will be done when calling the considered method on the lower layer is to adjust the gradient for the derivative of the activation function. Doubling the operation will lead to errors.

```
//--- branching of the algorithm depending on the device for performing operations

   if(!m_cOpenCL)

     {

      MATRIX grad = m_cGradients.m_mMatrix.MatMul(m_cWeights.m_mMatrix);

      if(!grad.Reshape(input_data.Rows(), input_data.Cols()))

         return false;

      input_gradient.m_mMatrix = grad;

     }

   else

      return false;

//---

   return true;

  }
```

We now have a calculated error gradient on each neuron in our network. There is enough data to update the weights. However, as we know, the weights are not always updated after each iteration of the backpropagation pass. Therefore, we separated the process of updating the weight matrix into two methods. In the first one, we will calculate the error gradient for each weight similarly to how we calculated the error gradient for the neuron in the previous layer. In the second one, we will adjust the weight matrix.

We will calculate the value of the error gradient for the weight matrix in the CalcDeltaWeights method. In the parameters of the method, similar to the previous one, there will be a pointer to the preceding layer of the neural network, but now we will use not the gradient buffer from it, but the array of output values.

Similar to the previously discussed methods, this method starts with a block of checks. It is followed by a block of calculations.

```
bool CNeuronBase::CalcDeltaWeights(CNeuronBase *prevLayer, bool read);

  {

//--- control block

   if(!prevLayer || !m_cDeltaWeights || !m_cGradients)

      return false;

   CBufferType *Inputs = prevLayer.GetOutputs();

   if(!Inputs)

      return false;
```

In the previous method, we have already adjusted the gradient for the derivative of the activation function. Therefore, we will skip this iteration and proceed directly to the calculation of the gradient on the weights. Here, as in other methods, there is a branching of the algorithm based on the computation device. In the MQL5 block, similarly to the previous method, we will employ matrix multiplication, because, in essence, both methods perform a similar operation only for different matrices. But there are a few differences here.

First, in the previous method, we removed the bias element. However, in this case, we need to add a unitary element to the vector of the previous layer results in order to determine the error gradient on the corresponding weight.

Second, earlier we multiplied the matrix of gradients by the matrix of weights. Now we multiply the transposed matrix of error gradients by the vector of the previous layer results with the bias element.

In addition, we were overwriting the error gradient of the previous layer, but for the weight gradient, we will sum them up, thereby accumulating the error gradient over the entire period between weight update operations.

```
//--- branching of the algorithm depending on the device for performing operations

   if(!m_cOpenCL)

     {

      MATRIX m = Inputs.m_mMatrix;

      if(!m.Reshape(1, Inputs.Total() + 1))

         return false;

      m[0, Inputs.Total()] = 1;

      m = m_cGradients.m_mMatrix.Transpose().MatMul(m);

      m_cDeltaWeights.m_mMatrix += m;

     }

   else

      return false;

//---

   return true;

  }
```

At the conclusion of the backpropagation process, we need to adjust the weight matrix. To perform this functionality, our class provides the UpdateWeights method. However, let's not forget that we have different options available for choosing the optimization method. The question was resolved using a simple and intuitive approach. The public method for updating the weights provides a dispatcher function to select the optimization method based on the user's choice. The actual process of adjusting the weight matrix is implemented in separate methods, with one method for each optimization method version.

```
bool CNeuronBase::UpdateWeights(int batch_size, TYPE learningRate,

                                VECTOR &Beta, VECTOR &Lambda)

  {

//--- control block

   if(!m_cDeltaWeights || !m_cWeights ||

       m_cWeights.Total() < m_cDeltaWeights.Total() || batch_size <= 0)

      return false;

//---

   bool result = false;

   switch(m_eOptimization)

     {

      case None:

         result = true;

         break;
```

```
case SGD:

         result = SGDUpdate(batch_size, learningRate, Lambda);

         break;

      case MOMENTUM:

         result = MomentumUpdate(batch_size, learningRate, Beta, Lambda);

         break;

      case AdaGrad:

         result = AdaGradUpdate(batch_size, learningRate, Lambda);

         break;

      case RMSProp:

         result = RMSPropUpdate(batch_size, learningRate, Beta, Lambda);

         break;

      case AdaDelta:

         result = AdaDeltaUpdate(batch_size, Beta, Lambda);

         break;

      case Adam:

         result = AdamUpdate(batch_size, learningRate, Beta, Lambda);

         break;

     }

//---

   return result;

  }
```

Algorithms for each of the [weight optimization methods](https://www.mql5.com/en/neurobook/index/about_ai/study/optimization) have already been presented earlier, while we considered their features. We will not duplicate them here, but we will implement them in the protected block in our base class of the neural layer.

We have already discussed the implementation of feed-forward and backpropagation operations in a fully connected neural layer. However, we will not re-train the neural network at each launch. Therefore, we need methods for working with files: writing and reading data from the state of the neural layer. We should be resource-efficient, so let's consider which information we need to save. The general rule is to save a minimum amount of information, but it should be sufficient for a quick startup and the functioning of the class without interrupting the process. Let's take a look at internal class variables and critically evaluate the need to save their contents to a file.

- m_cOpenCL — a pointer to an instance of the class for working with OpenCL technology, which is responsible for a separate functionality, but does not contain additional information. Not to be written to file.

- m_cActivation — a pointer to an activation function object. The activation function type is set by the user when constructing a neural network. Using a different activation function can lead to distortion of the results across the entire network. Save.

- m_eOptimization — a type of neuron optimization method during training, which is specified by the user when constructing a neural network. Influences the learning process. Save.

- m_cOutputs — an array of neuron output values. The number of elements is set by the neural network architect. The content is overwritten on every forward pass. It's sufficient to save the number of neurons in the layer and not save the entire array.

- m_cWeights — a weight matrix. The value of the elements is formed in the process of training the neural network. Save.

- m_cDeltaWeights — a matrix for accumulating failed weight updates (cumulative error gradient for each weight since the last update). Values ​​are accumulated between weights matrix updates and reset to zero after weights adjustments. The size of the array is equal to the weight matrix. Not to be written to a file.

- m_cGradients — the error gradient at the output of the neural layer as a result of the last iteration of the backward pass. The content is overwritten on every backward pass. The size of the array is equal to the buffer of the output signal. Not to be written to a file.

- m_cMomenum – unlike other variables, this will be an array of two elements for writing pointers to moment accumulation arrays. The use of buffers depends on the optimization method. The content is accumulated during the training of the neural network. Save.

After determining the data to be written to the file, let's proceed to create the file writing method Save. This virtual method exists in all descendant classes of the CObject class. In the parameters, the method receives the handle of the file to be written.

In the body of the method, we first check the received handle and the validity of the pointer to the result buffer of the neural layer. As we remember, a neural layer can be used with both full functionality and not. When using an object as a layer of input data, we deleted all buffers except for the input data buffer. Therefore, the presence of this buffer is mandatory for the neural layer. If any of the checks fail, we exit the method with a result of false.

Next, we write the type of the neural layer and the size of the result buffer to the file. At the same time, do not forget to check the results of the operations.

```
bool CNeuronBase::Save(const int file_handle)

  {

//--- control block

   if(file_handle == INVALID_HANDLE)

      return false;

//--- writing result buffer data

   if(!m_cOutputs)

      return false;

   if(FileWriteInteger(file_handle, Type()) <= 0 ||

      FileWriteInteger(file_handle, m_cOutputs.Total()) <= 0)

      return false;
```

After successfully writing the size of the result buffer, we check the validity of the pointers to the activation function objects and the weight matrices. In the absence of at least one object, we consider the current neural layer to be the initial data layer. To confirm this, we write 1 as a flag to indicate the preservation of the input data layer in the file. Otherwise, we save 0, which will indicate the preservation of the full-functionality neural layer.

```
//--- checking and writing the source data layer flag

   if(!m_cActivation || !m_cWeights)

     {

      if(FileWriteInteger(file_handle, 1) <= 0)

         return false;

      return true;

     }

   if(FileWriteInteger(file_handle, 0) <= 0)

      return false;
```

Then, using the optimization method, we determine the number of moments required for recording to the buffer.

```
int momentums = 0;

   switch(m_eOptimization)

     {

      case SGD:

         momentums = 0;

         break;

      case MOMENTUM:

      case AdaGrad:

      case RMSProp:

         momentums = 1;

         break;

      case AdaDelta:

      case Adam:

         momentums = 2;

         break;

      default:

         return false;

         break;

     }
```

Immediately, we organize a loop to validate the pointers to the momentum buffers.

```
for(int i = 0; i < momentums; i++)

      if(!m_cMomenum[i])

         return false;
```

After the block of checks, there are operations for directly writing data to the file. First, we save the values of variables, and then we call the file writing methods for the objects that need to be saved.

As seen from the provided code, we simply skip objects that do not need to be saved. However, this approach is not applicable when loading data from a file, as even skipped objects are necessary for the normal functioning of the neural layer. Therefore, the data loading method Load must be supplemented with a missing object initialization block. Let's see how it is implemented.

Just like when writing to a file, the method also receives a file handle for data in its parameters. Therefore, at the beginning of the method, we validate the received file handle.

```
bool CNeuronBase::Load(const int file_handle)

  {

//--- control block

   if(file_handle == INVALID_HANDLE)

      return false;
```

Reading data from the file should be done in precise accordance with the sequence of data writing. First, we saved the type of neural layer and the number of elements in the buffer in the results buffer. The type of the neural layer will be read by the method of the top-level object (dynamic array of neural layers) to create the required neural layer. In the body of this method, we will read the number of elements in the result buffer and initialize a buffer of the corresponding size.

```
//--- loading result buffer

   if(!m_cOutputs)

      if(!(m_cOutputs = new CBufferType()))

         return false;

   int outputs = FileReadInteger(file_handle);

   if(!m_cOutputs.BufferInit(1, outputs, 0))

      return false;
```

Immediately create a gradient buffer of the same size.

```
//--- creating error gradient buffer

   if(!m_cGradients)

      if(!(m_cGradients = new CBufferType()))

         return false;

   if(!m_cGradients.BufferInit(1, outputs, 0))

      return false;
```

Next, we check the flag for loading the input data neural layer. In the case of loading it, we delete unused objects and exit the method with a positive result.

```
//--- checking the source data layer flag

   int input_layer = FileReadInteger(file_handle);

   if(input_layer == 1)

     {

      if(m_cActivation)

         delete m_cActivation;

      if(m_cWeights)

         delete m_cWeights;

      if(m_cDeltaWeights)

         delete m_cDeltaWeights;

      if(m_cMomenum[0])

         delete m_cMomenum[0];

      if(m_cMomenum[1])

         delete m_cMomenum[1];

      if(m_cOpenCL)

         if(!m_cOutputs.BufferCreate(m_cOpenCL))

            return false;

      m_eOptimization = None;

      return true;

     }
```

Further code is executed only when loading a fully functional neural layer. At the beginning of this block, we read the optimization method from the file and the number of used momentum buffers.

```
m_eOptimization = (ENUM_OPTIMIZATION)FileReadInteger(file_handle);

   int momentums = FileReadInteger(file_handle);
```

After that, we check the pointer to the weights matrix object. If necessary, we will create a new instance of the object and immediately call the data buffer loading method.

```
//--- creating objects before loading data

   if(!m_cWeights)

      if(!(m_cWeights = new CBufferType()))

         return false;

//--- loading data from file

   if(!m_cWeights.Load(file_handle))

      return false;
```

Then, we read the type of the activation function from the file and initialize an instance of the corresponding class using the SetActivation method. The activation function parameters will be loaded by calling the method with the same name for loading data from the activation function object.

```
//--- activation function

   if(FileReadInteger(file_handle) != defActivation)

      return false;

   ENUM_ACTIVATION_FUNCTION activation =

                         (ENUM_ACTIVATION_FUNCTION)FileReadInteger(file_handle);

   if(!SetActivation(activation,VECTOR::Zeros(2)))

      return false;

   if(!m_cActivation.Load(file_handle))

      return false;
```

Similarly, we will load the data of the momentum buffers.

```
//---

   for(int i = 0; i < momentums; i++)

     {

      if(!m_cMomenum[i])

         if(!(m_cMomenum[i] = new CBufferType()))

            return false;

      if(!m_cMomenum[i].Load(file_handle))

         return false;

     }
```

After loading the data, we initialize the m_cDeltaWeights buffer. The buffer will be initialized with zero values. In this case, the buffer size is equal to the number of elements in the weights matrix.

First, check the pointer to the object and create a new one if necessary. Then, we will write 0 into all elements of the buffer.

```
//--- initializing remaining buffers

   if(!m_cDeltaWeights)

      if(!(m_cDeltaWeights = new CBufferType()))

         return false;

   if(!m_cDeltaWeights.BufferInit(m_cWeights.m_mMatrix.Rows(),

                                  m_cWeights.m_mMatrix.Cols(), 0))

      return false;
```

At the end of the method, we pass the current pointer m_cOpenCL to all internal objects. Here, we are not adding a check for the validity of the pointer. Since all objects of the neural network work within the same OpenCL context, we pass even an invalid pointer to the objects.

```
//--- passing a pointer to the OpenCL context to objects

   SetOpenCL(m_cOpenCL);

//---

   return true;

  }
```

As a result of implementing all the methods described above, the final structure of our class has taken the following form.

```
class CNeuronBase    :  public CObject

  {

protected:

   bool              m_bTrain;

   CMyOpenCL*        m_cOpenCL;

   CActivation*      m_cActivation;

   ENUM_OPTIMIZATION m_eOptimization;

   CBufferType*      m_cOutputs;

   CBufferType*      m_cWeights;

   CBufferType*      m_cDeltaWeights;

   CBufferType*      m_cGradients;

   CBufferType*      m_cMomenum[2];
```

```
//---

   virtual bool      SGDUpdate(int batch_size, TYPE learningRate,

                                                    VECTOR &Lambda);

   virtual bool      MomentumUpdate(int batch_size, TYPE learningRate,

                                                    VECTOR &Beta, VECTOR &Lambda);

   virtual bool      AdaGradUpdate(int batch_size, TYPE learningRate,

                                                    VECTOR &Lambda);

   virtual bool      RMSPropUpdate(int batch_size, TYPE learningRate,

                                                    VECTOR &Beta, VECTOR &Lambda);

   virtual bool      AdaDeltaUpdate(int batch_size,

                                                    VECTOR &Beta, VECTOR &Lambda);

   virtual bool      AdamUpdate(int batch_size, TYPE learningRate,

                                                    VECTOR &Beta, VECTOR &Lambda);

   virtual bool      SetActivation(ENUM_ACTIVATION_FUNCTION function,

                                                    VECTOR &params);
```

```
public:

                     CNeuronBase(void);

                    ~CNeuronBase(void);

   //---

   virtual bool      Init(const CLayerDescription *description);

   virtual bool      SetOpenCL(CMyOpenCL *opencl);

   virtual bool      FeedForward(CNeuronBase *prevLayer);

   virtual bool      CalcOutputGradient(CBufferType *target,

                                                    ENUM_LOSS_FUNCTION loss);

   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer);

   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer);

   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,

                                                    VECTOR &Beta, VECTOR &Lambda);

   virtual void      TrainMode(bool flag)         {  m_bTrain = flag;            }

   virtual bool      TrainMode(void)        const {  return m_bTrain;            }

   //---

   CBufferType       *GetOutputs(void)      const {  return(m_cOutputs);         }

   CBufferType       *GetGradients(void)    const {  return(m_cGradients);       }

   CBufferType       *GetWeights(void)      const {  return(m_cWeights);         }

   CBufferType       *GetDeltaWeights(void) const {  return(m_cDeltaWeights);    }
```

```
virtual bool      SetOutputs(CBufferType* buffer, bool delete_prevoius = true);

   //--- methods for working with files

   virtual bool      Save(const int file_handle);

   virtual bool      Load(const int file_handle);

   //--- method of identifying the object

   virtual int       Type(void)             const { return(defNeuronBase);       }

   virtual ulong     Rows(void)             const { return(m_cOutputs.Rows());   }

   virtual ulong     Cols(void)             const { return(m_cOutputs.Cols());   }

   virtual ulong     Total(void)            const { return(m_cOutputs.Total());  }

  };
```

## Activation function class

We still have some open questions regarding the implementation of the neural layer base class. One of them is the neuron activation function class.

The activation function class will contain the operations for calculating the activation function and its derivative. There are various types of activation functions, and the book does not provide the full list of such functions, while it only covers the more commonly used ones. New, well-performing activation functions can emerge. So, if you need to add a new activation function to this library, the easiest way would be to do so by creating a new class that inherits from a certain base class. In this way, by overriding a couple of methods responsible for the direct calculation of the function and its derivative, the changes will be propagated to all neural network objects, including those created earlier.

Following this logic, I decided to create not a single activation function class that would cover all the functions discussed earlier, but a class structure in which each class would contain an algorithm for only one activation function. In this structure, there would be one base class at the top, which would define the interfaces for interaction with other objects and serve as an object for accessing methods from other objects without being tied to a specific activation function.

By creating a single branching point in the algorithm during the initialization of a specific activation function class, we move away from checking the used function at each iteration of the forward and backward passes.

The parent class for all activation functions CActivation is inherited from the CObject class, which is the base class for all objects in MQL5.

The CActivation class only contains methods for organizing the interface and does not describe any of the activation functions. In turn, to organize the activation function classes, I defined the following methods:

- CActivation — a class constructor;

- ~CActivation — a class destructor;

- Init — passing parameters to calculate the activation function;

- GetFunction — getting the used activation function and its parameters;

- Activation — performs calculation of the activation function value based on the reference value;

- Derivative — derivative from the activation function;

- SetOpenCL — writing a pointer to an OpenCL object;

- Save and Load — virtual methods for working with files;

- Type — a virtual method for class identification.

In general, the class looks much simpler than those discussed previously. In the constructor of the class, we will set the default activation function parameters.

```
CActivation::CActivation(void) : m_iRows(0),

                                 m_iCols(0),

                                 m_cOpenCL(NULL)

  {

   m_adParams = VECTOR::Ones(2);

   m_adParams[1] = 0;

  }
```

Note that to calculate the derivative of certain activation functions, we only need the value of the activation function itself. In other cases, we will need values before the activation function. Therefore, let's introduce two pointers to the corresponding data buffers:

- m_cInputs

- m_cOutputs

In the body of this class, we will create only one instance of a buffer, and in another variable, we will save a pointer to the buffer that calls the neural layer. Due to this, in the destructor of the class, we will only delete one object.

```
CActivation::~CActivation(void)

  {

   if(!!m_cInputs)

      delete m_cInputs;

  }
```

In the class initialization method, we store the resulting activation function parameters and create a data buffer object. It's important to note that at this stage, we are merely creating an instance of the class; we are initializing the buffer itself because we don't yet know the required buffer data sizes.

```
bool CActivation::Init(VECTOR &params)

  {

   m_adParams = params;

//---

   m_cInputs = new CBufferType();

   if(!m_cInputs)

      return false;

//---

   return true;

  }
```

The activation parameter reading method is straightforward. We only return the value of the variables.

```
ENUM_ACTIVATION_FUNCTION CActivation::GetFunction(VECTOR &params)

  {

   params = m_adParams;

   return GetFunction();

  }
```

The Activation method that calculates the values of the activation function, in the parameters receives a pointer to the neural layer result buffer. This buffer contains neuron performance data prior to the activation function. We need to activate the obtained values and overwrite them into the specified buffer. However, as we know, the obtained values might be needed when calculating derivatives of certain functions. Therefore, we "play" with the pointers to the buffer objects, saving the obtained pointer in the variable m_cInputs. In the variable received in parameters and in the m_cOutputs variable, we save the buffer from the m_cInputs variable. The current class corresponds to the absence of an activation function, so we don't perform any operations on the obtained data.

However, there is one nuance. Since we don't perform any operations on the obtained data, we need to return them to the calling program. At this point, we have already replaced the buffer that we will return. Therefore, we check the used activation function, and if no further actions are required on the obtained data, we will return the pointer to the buffer back and delete the unnecessary object.

It might seem like there are many unnecessary actions in the method that didn't alter the data in any way. However, these are our small investments in the functionality of the inheriting classes.

```
bool CActivation::Activation(CBufferType *&output)

  {

   if(!output || output.Total() <= 0)

      return false;

   m_cOutputs = m_cInputs;

   m_cInputs = output;

   output = m_cOutputs;

   if(GetFunction() == AF_NONE && output != m_cInputs)

     {

      delete output;

      output = m_cInputs;

     }

//---

   return true;

  }
```

At the same time, the method for calculating the derivative of the activation function in this class will remain nominal. In all cases it will return a positive value.

The SetOpenCL method for activating multi-threaded computation functionality receives in the parameters a pointer to an object for working with the OpenCL context object and the size of the result buffer for the calling neural layer. We will need these buffer sizes for initialization and creation of the buffer in the context.

In the body of the method, we store the resulting dimensions and pointer, then initialize the data buffer of the specified size with null values and create a buffer in the OpenCL context.

```
bool CActivation::SetOpenCL(CMyOpenCL *opencl, const ulong rows, const ulong cols)

  {

   m_iRows = rows;

   m_iCols = cols;

   if(m_cOpenCL != opencl)

     {

      if(m_cOpenCL)

         delete m_cOpenCL;

      m_cOpenCL = opencl;

     }

//---

   if(!!m_cInputs)

     {

      if(!m_cInputs.BufferInit(m_iRows, m_iCols, 0))

         return false;

      m_cInputs.BufferCreate(m_cOpenCL);

     }//---

   return(!!m_cOpenCL);

  }
```

As you can see, the methods of the class are quite simple. All we have to do is look at file-handling techniques. Their algorithm is also simple. In the body of the Save method, as usual, we check the file handle for writing the data we receive in the parameters and store the activation function type and parameter value.

```
bool CActivation::Save(const int file_handle)

  {

   if(file_handle == INVALID_HANDLE)

      return false;

   if(FileWriteInteger(file_handle, Type()) <= 0 ||

      FileWriteInteger(file_handle, (int)GetFunction()) <= 0 ||

      FileWriteInteger(file_handle, (int)m_iRows) <= 0 ||

      FileWriteInteger(file_handle, (int)m_iCols) <= 0 ||

      FileWriteDouble(file_handle, (double)m_adParams[0]) <= 0 ||

      FileWriteDouble(file_handle, (double)m_adParams[1]) <= 0)

      return false;

//---

   return true;

  }
```

The data loading method Load also receives a file handle in parameters. In the method body, we check the validity of the received handle and read the values of the constants. After that, we initialize one data buffer. At the same time, we do not forget to control the operation process.

```
bool CActivation::Load(const int file_handle)

  {

   if(file_handle == INVALID_HANDLE)

      return false;

   m_iRows = (uint)FileReadInteger(file_handle);

   m_iCols = (uint)FileReadInteger(file_handle);

   m_adParams.Init(2);

   m_adParams[0] = (TYPE)FileReadDouble(file_handle);

   m_adParams[1] = (TYPE)FileReadDouble(file_handle);

//---

   if(!m_cInputs)

     {

      m_cInputs = new CBufferType();

      if(!m_cInputs)

         return false;

     }

   if(!m_cInputs.BufferInit(m_iRows, m_iCols, 0))

      return false;

//---

   return true;

  }
```

We have reviewed all the methods of the base class of the CActivation activation function. So, we have the following class structure.

```
class CActivation : protected CObject

  {

protected:

   ulong             m_iRows;

   ulong             m_iCols;

   VECTOR            m_adParams;

   CMyOpenCL*        m_cOpenCL;

   //---

   CBufferType*      m_cInputs;

   CBufferType*      m_cOutputs;

public:

                     CActivation(void);

                    ~CActivation(void) {if(!!m_cInputs) delete m_cInputs; }

   //---

   virtual bool      Init(VECTOR &params);

   virtual ENUM_ACTIVATION_FUNCTION  GetFunction(VECTOR &params);

   virtual ENUM_ACTIVATION_FUNCTION   GetFunction(void) { return AF_NONE; }

   virtual bool      Activation(CBufferType*& output);

   virtual bool      Derivative(CBufferType*& gradient) { return true;    }

   //---

   virtual bool      SetOpenCL(CMyOpenCL *opencl, const ulong rows,

                                                  const ulong cols);
```

```
//--- methods for working with files

   virtual bool      Save(const int file_handle);

   virtual bool      Load(const int file_handle);

   //--- object identification method

   virtual int       Type(void)             const { return defActivation; }

  };
```

However, as we discussed earlier, this class only lays the groundwork for future classes of various activation functions. To add the actual activation function algorithm, you need to create a new class by overriding several methods. For example, let's create a class of a linear activation function. The structure of this class is given below.

```
class CActivationLine   :  public CActivation

  {

public:

                     CActivationLine(void) {};

                    ~CActivationLine(void) {};

   //---

   virtual ENUM_ACTIVATION_FUNCTION   GetFunction(void) override

                                              { return AF_LINEAR; }

   virtual bool      Activation(CBufferType*& output) override;

   virtual bool      Derivative(CBufferType*& gradient) override;

  };
```

The new CActivationLine class is publicly inherited from the created above base class of the CActivation activation function. The constructor and destructor of the class are empty. All we have to do is redefine three methods:

- GetFunction — gets the used activation function and its parameters;

- Activation — performs calculation of the activation function value based on the reference value;

- Derivative — a derivative of the activation function.

In the GetFunction method, we only change the return type of the activation function to the corresponding class.

The Activation method in the parameters receives a pointer to the initial data buffer similar to the method of the parent class. In the body of the method, we don't check the received pointer; we simply call the method of the parent class, where we check the received pointer and "play" with the pointers to data buffers. After this, the algorithm is split into two threads: one using the OpenCL technology and the other without it. We will learn about multi-threaded operations a little later. In the block of operations without using multi-threading, we simply invoke the activation function for the matrix of obtained values, specifying the activation function type as AF_LINEAR and the function parameters.

```
bool CActivationLine::Activation(CBufferType*& output)

  {

   if(!CActivation::Activation(output))

      return false;

//---

   if(!m_cOpenCL)

     {

      if(!m_cInputs.m_mMatrix.Activation(output.m_mMatrix, AF_LINEAR,

                                          m_adParams[0], m_adParams[1]))

         return false;

     }

   else // OpenCL block

     {

      return false;

     }

//---

   return true;

  }
```

The method that calculates the derivative is even more straightforward. In the parameters, the method receives a pointer to the error gradient object. The obtained values must be corrected for the derivative of the activation function. As you know, the derivative of a linear function is its coefficient at the variable. So, the only thing we have to do is multiply the resulting gradient vector by the parameter of the activation function with the index of 0.

```
bool CActivationLine::Derivative(CBufferType*& gradient)

  {

   if(!m_cInputs || !m_cOutputs ||

      !gradient || gradient.Total() < m_cOutputs.Total())

      return false;

//---

   if(!m_cOpenCL)

     {

      gradient.m_mMatrix = gradient.m_mMatrix * m_adParams[0];

     }

   else // OpenCL block

     {

      return false;

     }

//---

   return true;

  }
```

As you can see, the mechanism for describing the new activation function is quite simple. Let's create a class for using ReLU as the activation function in a similar manner.

```
class CActivationLReLU : public CActivation

  {

public:

                     CActivationLReLU(void) { m_adParams[0] = (TYPE)0.3; };

                    ~CActivationLReLU(void) {};

   //---

   virtual ENUM_ACTIVATION_FUNCTION   GetFunction(void) override { return AF_LRELU; }

   virtual bool      Activation(CBufferType*& output) override;

   virtual bool      Derivative(CBufferType*& gradient) override;

  };
```

In the activation function of the new class, we will also use a matrix activation function call specifying the corresponding function type, AF_LRELU.

```
bool CActivationLReLU::Activation(CBufferType*& output)

  {

   if(!CActivation::Activation(output))

      return false;

//---

   if(!m_cOpenCL)

     {

      if(!m_cInputs.m_mMatrix.Activation(output.m_mMatrix, AF_LRELU,m_adParams[0]))

         return false;

     }

   else // OpenCL block

     {

      return false;

     }

//---

   return true;

  }
```

We'll use a similar approach in the derivative method of the activation function.

```
bool CActivationLReLU::Derivative(CBufferType*& gradient)

  {

   if(!m_cOutputs || !gradient ||

      m_cOutputs.Total() <= 0 || gradient.Total() < m_cOutputs.Total())

      return false;

//---

   if(!m_cOpenCL)

     {

      MATRIX temp;

      if(!m_cInputs.m_mMatrix.Derivative(temp, AF_LRELU,m_adParams[0]))

         return false;

      gradient.m_mMatrix *= temp;

     }
```

```
else // OpenCL block

     {

      return false;

     }

//---

   return true;

  }
```

The reader may have a reasonable question as to why we should create new classes if we use the activation matrix functions embedded in the MQL5 language. This is done more to ensure a unified approach with and without OpenCL multi-threaded technologies. These methods will incorporate code for organizing multi-threaded computations in the OpenCL context. The use of the described classes enables a unified call to activation function algorithms using both MQL5 tools and multi-threaded computations in the OpenCL context.

## Architecture and principles of implementation of a fully connected layer

When constructing the base class for the neural network and the dynamic array to store pointers to neuron layers, we defined the main methods and interfaces for data exchange between the neural network manager and its components. This is what defines the basic public methods of all our neural layer classes. I suggest summarizing the mentioned sections briefly now. Let's highlight the key class methods we have yet to write and their functionality.

Please note that all neural layer objects must be descendants of the CObject base class. This is the fundamental requirement for placing pointers to instances of these objects into the dynamically created array we've designed.

Adhering to the general principles of object organization, in the class constructor, we initialize internal variables and constants. In the destructor, we will perform memory cleanup: deleting all internal instances of various classes and clearing arrays.

In parameters, the Init method receives an instance of the CLayerDescription class containing the description of the neural layer to be created. Therefore, this method should be organized to create the entire internal architecture for the proper functioning of our neural layer. We will need to create several arrays to store the data.

It is an array for recording the states at the output of neurons. This array will have a size equal to the number of neurons in our layer.

We will also need an array to store the weights. This will be a matrix, where the size of the first dimension is equal to the number of neurons in our layer, and the size of the second dimension is one more than the size of the input data array. For a fully connected neural layer, the array of input data consists of the output values of the neurons from the previous layer. Consequently, the size of the second dimension will be one element larger than the size of the previous layer. The added element will serve to adjust the bias.

For the backward pass, we will need an array to store gradients (deviations of calculated values from reference values at the output of neurons). Its size will correspond to the number of neurons in our layer.

Additionally, depending on the training method, we might need one or two matrices to store accumulated moments. The sizes of these matrices will be equal to the size of the weight matrix.

We will not always update the weights after every iteration of the backward pass. It is possible to update the weights after a full pass of the training sample or based on some batch. We will not store the intermediate states of all neurons and their inputs. On the contrary, after each iteration of the backward pass, we will calculate the necessary change for each weight as if we were updating the weights at every iteration. But instead of changing the weights, we will summarize the resulting deltas into a separate array. If updating is necessary, we will simply take the average delta value over the period and adjust the weights accordingly. For this purpose, we will need another matrix with a size equal to the weight matrix.

For all arrays, we will create a special class called CBufferType. It will inherit from the base class [CObject](https://www.mql5.com/en/docs/standardlibrary/cobject) with the addition of the necessary functionality to organize the operation of the data buffer.

In addition to creating arrays and matrices, we need to fill them with initial values. We will fill all arrays, except the weights, with zeros, and initialize the weight matrix with random values.

In addition to data arrays, our class will also use local variables. We will need to save the activation and optimization parameters of the neurons. We will store the type of optimization method in a variable, and for activation functions, we will create a whole structure of separate classes inheriting from a common base class.

Let me remind you that we are building a universal platform for creating neural networks and their operation in the MetaTrader 5 terminal. We plan to provide users with the ability to utilize multi-threaded computations using the OpenCL technology. All objects in our neural network will operate in the same context. This will reduce the time spent on unnecessary data overload. The actual instance of the class for working with the OpenCL technology will be created in the base neural network class, and a pointer to the created object will be passed to all elements of the neural network. Therefore, all objects that make up the neural network, including our neural layer, should have a method for obtaining the SetOpenCL pointer and a variable for storing it.

The forward pass will be organized in the FeedForward method. The only parameter of this method will be a pointer to the CNeuronBase object of the previous layer of the neural network. We will need the output states of the neurons from the previous layer, which will form the incoming data stream. To access them, let's create the GetOutputs method.

The backward pass, unlike the forward pass, will be divided into several methods:

- CalcOutputGradient calculates the error gradient at the output layer of the neural network by reference values.

- CalcHiddenGradient skips the error gradient through the hidden layer from output to input. As a result, we will pass the error gradients to the previous layer. To access the array of gradients from the previous layer, we will need a method to access them — GetGradients.

- CalcDeltaWeights calculates the necessary changes in weights based on the analysis of the last iteration.

- UpdateWeights is a method to directly update the weights.

Let's not forget the common for all objects methods of working with files and identification, namely Save, Load, and Type.

In our object detailing, we will focus on the neural layer class and will not create separate objects for each neuron. In fact, there are a number of reasons for this. From what lies on the surface:

- Using the Softmax activation function involves working with the entire neural layer.

- Using the Dropout and Layer Normalization methods requires the processing of the entire neural layer data.

- This approach allows us to efficiently organize multi-threaded computations based on matrix operations.

Let's delve more into matrix operations and see how they allow us to distribute operations across multiple parallel threads. Consider a small example of three elements in the input (vector Inputs) and two neurons in the layer. Both neurons have their weight vectors W1 and W2. In this case, each vector of weights contains three elements.

According to the [mathematical model of the neuron](https://www.mql5.com/en/neurobook/index/about_ai/neuron), we need to element-wise multiply the input data vector with the weight vector, sum up the obtained values, and apply the activation function to them. Essentially, the same process, except for the activation function, is achieved through matrix multiplication.

Matrix multiplication is an operation resulting in a matrix. The elements of the new matrix are obtained by summing the element-wise products of rows from the first matrix with columns from the second matrix.

Thus, to obtain the sum of element-wise products of the input data vector and the weight vector of one of the neurons, it is necessary to multiply the input data row vector by the weight column vector.

This rule is applicable to any matrices. The only condition is that the number of columns in the first matrix must be equal to the number of rows in the second matrix. Therefore, we can assemble the weight vectors of all neurons in the layer into a single matrix W, where each column will represent the weight vector of an individual neuron.

You can see that the computation of any element in vector Z is independent of the other elements of the same vector. Accordingly, we can load the matrices of input data and weights into memory and then concurrently compute the values of all elements in the output vector.

We can go even further and load not just a single vector of input data, but a matrix where the rows represent individual states of the system. When working with time series data, each row represents a snapshot of the system's state at a certain moment in time. As a result, we will increase the number of parallel threads of operations and potentially reduce the time to process data.

Naturally, we can also use multi-threading to calculate the activation function values for each independent element of matrix Z. An exception might be the use of the [Softmax](https://www.mql5.com/en/neurobook/index/about_ai/activation#softmax) activation function due to the peculiarities of its computation. However, even in this case, parallelization of computations at different stages of the function calculation is possible.

## Creating an OpenCL program

We will start porting calculations by creating an OpenCL program. The choice of this approach is very obvious. We have already organized the process using MQL5 tools. Therefore, the whole process of operations is clear and transparent. Computation operations will be performed in the OpenCL program. In the main program, we have to organize the process of transferring data and calling the OpenCL program. The latter process is easier to organize when we already know what data and to which kernel we need to transfer.

The program code will be written to a separate file opencl_program.cl. The file name and extensions can be anything, as we will later load it in the main program code as a resource. I use the *.cl extension as a common extension to denote OpenCL programs. In general, the use of standard extensions makes it easier to read projects with complex file structures.

For a feed-forward pass, similar to the [MQL5](https://www.mql5.com/en/neurobook/index/realization/perceptron/pr_mql5#feedforward) implementation, we will create kernel PerceptronFeedForward. To carry out operations, we need the result vector of the previous layer (inputs) and the weight matrix (weights) as the initial data. The result of the operations will be written to the result vector (outputs). In addition to the data sets, we need to know the number of neurons in the previous layer to ensure control over potential output exceeding the array limits.

As we discussed earlier, the number of threads will correspond to the number of neurons in the layer. Therefore, at the beginning of the kernel, we need to call the get_global_id function, which will return the thread identifier to us. Let's use this value as the ordinal number of the neuron being processed.

The weight matrix in our buffer is represented as a vector in which N weights of the first neuron go sequentially, followed by N weights of the second neuron, and so on. The value of N is one element greater than the number of neurons in the previous layer since we are using the bias element. We already have the neuron's ordinal number and the number of neurons in the previous layer, so we can determine the offset in the weight vector to the first weight of our neuron.

Next, we will create a local variable to accumulate the sum of products and initialize it with the bias offset coefficient. After that, we organize a loop and calculate the sum of products of the original signal by the weights for a specific neuron in our stream. OpenCL supports vector operations which allow the microprocessor to perform one operation simultaneously on multiple values in a single cycle. In the proposed implementation, I used vectors of type double4. This is a vector of four elements of type double. To convert data from an array of discrete values to a vector, I created a function called ToVect4, which we will discuss a bit later. To obtain the sum of products, I used the built-in dot function. It belongs to vector operations and allows obtaining the discrete value of the product of two vectors. This allowed us to use a step of 4 in the loop and thereby reduce the number of iterations by 4 times.

It should be noted that double4 is not the only vector data type supported by OpenCL. The ability to use them depends on the technical specifications of the hardware being used. The double4 type, in my personal opinion, is the most versatile for use on a wide range of available equipment. When creating your own libraries, you can use a different type of data that is most optimal for your equipment.

After completing the iterations of the loop, we will save the accumulated sum of the vector product to the corresponding element of the result buffer.

The full kernel code is presented below.

```
__kernel void PerceptronFeedForward(__global TYPE *inputs,

                                    __global TYPE *weights,

                                    __global TYPE *outputs,

                                    int inputs_total)

  {

   const int n = get_global_id(0);

   const int weights_total = get_global_size(0) * (inputs_total + 1);

   int shift = n * (inputs_total + 1);

   TYPE s = weights[shift + inputs_total];

   for(int i = 0; i < inputs_total; i += 4)

      s += dot(ToVect4(inputs, i, 1, inputs_total, 0),

               ToVect4(weights, i, 1, weights_total, shift));

   outputs[n] = s;

  }
```

Let's examine the algorithm of the ToVect4 function. In parameters, the function receives a pointer to a vector of discrete values, the position of the first element to copy, the step between two elements to copy, the size of the data array, and the offset in the array to the first copied element. The parameters of the position of the first element and the offset serve a similar purpose but differ in the context of operations. The offset determines the displacement in the data vector from the element with index 0. For the feed-forward function, this offset is to the first weight of the processed neuron. The position of the first element to copy specifies the element without considering the step between elements. In the example given, this is the number of neurons in the preceding layer. When considering an example with a step of one element, one parameter can be easily expressed in terms of the other. The difference in using parameters will be more noticeable when discussing the backpropagation pass, where the weight copying step will be equal to the size of the weight vector for one neuron.

At the beginning of the function, we initialize the result vector with zero values and ensure that the step is at least one element. Then, we check how many elements we can take from the original data array starting from the initial position, considering the offset and step. This operation is necessary to prevent accessing data beyond the array boundaries. Next, we fill the result vectors with the available values, leaving the missing elements as zero. Thus, the size of the original array becomes a multiple of four. Meanwhile, the final value for calling functions remains unchanged, and the use of vector operations overall helps reduce time costs for operations.

```
TYPE4 ToVect4(__global TYPE *array, int start, int step, int size, int shift)

  {

   TYPE4 result = (TYPE4)(0, 0, 0, 0);

m   step = max(1, step);

   int st = start * step + shift;

   if(st < size)

     {

      int k = (size - shift + step - 1)  /  step;
```

```
switch(k)

        {

         case 0:

            break;

         case  1:

            result = (TYPE4)(array[st], 0, 0, 0);

            break;

         case  2:

            result = (TYPE4)(array[st], array[st + step], 0, 0);

            break;

         case  3:

            result = (TYPE4)(array[st], array[st + step], array[st + 2 * step], 0);

            break;

         default:

         result = (TYPE4)(array[st], array[st + step], array[st + 2 * step], array[st + 3 * step]);

               break;

        }

     }

   return result;

  }
```

To fully understand the forward pass, let's explore the activation functions. In general, they repeat the relevant implementations in MQL5, except for the kernel design. For example, below is the code for the implementation of a sigmoid. The kernel parameters include pointers to the input data buffers, output buffers, and activation function parameters. In the kernel body, we first determine the thread identifier, which indicates the ordinal number of the processed element in the data buffer, and then organize the process of calculating the activation function. As you can see, the code for calculating the value of the function is very similar to the relevant MQL5 code presented in the [activation function](https://www.mql5.com/en/neurobook/index/about_ai/activation#sigmoid) description section.

```
__kernel void SigmoidActivation(__global TYPE* inputs,

                                __global TYPE* outputs,

                                const TYPE a, const TYPE b)

  {

   size_t i = get_global_id(0);

   outputs[i] = a / (1 + exp(-inputs[i])) - b;

  }
```

The same can be said about the implementation of the [Swish](https://www.mql5.com/en/neurobook/index/about_ai/activation#swish) activation function.

```
__kernel void SwishActivation(__global TYPE* inputs,

                              __global TYPE* outputs,

                              const TYPE b)

  {

   size_t i = get_global_id(0);

   TYPE value = inputs[i];

   outputs[i] = value / (1 + exp(-b * value));

  }
```

However, there are some difficulties in implementing the Softmax function. This is due to the difficulty of transferring data between threads to calculate the sum of all the values of the exponent vector in the neural layer. To resolve the issue, I decided to divide the process into several stages. In addition, we'll take advantage of the Work-group's ability to use shared arrays in local memory.

In the kernel parameters, we pass pointers to the buffers of input data and results, as well as the size of the input data buffer. In the kernel body, we first get all the necessary identifiers. These are the global IDs in two dimensions, and the thread ID in the local group. We will talk about the use of two dimensions in the global task space later.

```
__kernel void SoftMaxActivation(__global TYPE* inputs,

                                __global TYPE* outputs,

                                const ulong total)

  {

   uint i = (uint)get_global_id(0);

   uint l = (uint)get_local_id(0);

   uint h = (uint)get_global_id(1);

   uint ls = min((uint)get_local_size(0), (uint)LOCAL_SIZE);
```

Then we will create a local array in which we allocate one element for each thread to sum up exponential values.

Note that OpenCL does not allow the creation of dynamic arrays. Therefore, the size of the local array must be determined before the program is compiled. So, we need to look for some kind of compromise. Excessive size leads to inefficient memory utilization. On the other hand, if the array size is too small, this limits the number of active parallel threads. Of course, solving such a task is much easier when you know the parameters of the device you are using and the architecture of the model. Therefore, we need a mechanism that allows us to easily and quickly change this parameter before compiling the program. The best solution for this is to use macro substitution, just like we did for the data type. In the code, we specify the LOCAL_SIZE constant, the value of which we assign in our constant file [defines.mqh](https://www.mql5.com/en/neurobook/index/realization/basic/constants#mql5includeneuronetworksbookrealizationdefines.mqh).

Next, we organize a loop in which each thread sums its part of the exponential values. The resulting value is written to the corresponding element of the local array.

```
__local TYPE temp[LOCAL_SIZE];

   uint count = 0;

   for(count = l; (count < total && l < ls); count += ls)

     {

      uint shift = h * total + count;

      temp[l] = (count > l ? temp[l] : 0) + exp(inputs[shift]);

     }

   barrier(CLK_LOCAL_MEM_FENCE);
```

After the loop operations are complete, we set a barrier that allows all the threads of the local group to be synchronized. This operation suspends the execution of each thread, waiting for all threads within the local group to complete their loop iterations.

After obtaining several individual sums computed by each separate thread, it is necessary to combine them into a single sum. To do this, we will organize another cycle. In its body, we will sum the values of the local array in pairs. The trick is that we will divide the entire local array into two equal parts. The first half of the active threads will add the value from the second half to its value in the local array. In the next iteration of the loop, we will halve the number of active threads and sum the values obtained in the previous iteration of the loop. The loop repeats until the sum of all elements is collected in the first element of the array.

Here we insert a barrier in the body of the loop because before the start of each subsequent iteration, all threads must finish the previous iteration.

```
count = ls;

   do

     {

      count = (count + 1) / 2;

      temp[l] += (l < count && (l + count) < ls ? temp[l + count] : 0);

      barrier(CLK_LOCAL_MEM_FENCE);

     }

   while(count > 1);
```

After obtaining the sum of the exponents of all the values in the buffer, we can calculate the value of each element after the activation function. This is what we will do in the next cycle.

```
//---

   TYPE sum=temp[0];

   for(count = l; count < total; count += ls)

     {

      uint shift = h * total + count;

      outputs[shift] = exp(inputs[shift]) / (sum + 1e-37f);

     }

  }
```

A forward pass is followed by a backward pass. It begins with the definition of error gradients at the output of the neural layer. This function is performed by the CalcOutputGradient kernel. In the kernel parameters, it receives pointers to three vectors: the first two vectors of target values and forward pass results are the input data for the function, while the third one is used to store the calculation results. The parameters also specify the loss function to be used. The kernel code completely repeats the algorithm of the previously considered relevant method written using MQL5 tools. It also shows the branching of the algorithm depending on the loss function used.

```
__kernel void CalcOutputGradient(__global TYPE *target,

                                 __global TYPE *outputs,

                                 __global TYPE *gradients,

                                 int loss_function)

  {

   const int n = get_global_id(0);

   switch(loss_function)

     {

      case 0:

         gradients[n] = target[n] - outputs[n];

         break;

      case 1:

         gradients[n] = 2 * (target[n] - outputs[n]);

         break;

      case 2:

         gradients[n] = -target[n] /

                        (outputs[n] + 1e-37f) * log(outputs[n] + 1e-37f);

         break;

      case 3:

         gradients[n] = (target[n] - outputs[n]) /

                        (outputs[n] * (outputs[n] - 1) + 1e-37f);

         break;

      default:

         gradients[n] = target[n] - outputs[n];

         break;

     }

  }
```

The next step in our backpropagation process is to adjust the error gradient based on the derivative of the activation function. Recall that we have moved the activation function and all related processes to a separate class. Furthermore, each activation function has its own class. We will create a separate kernel for each activation function. Similarly, we will create a separate kernel for determining the derivative of each activation function.

When creating kernels for calculating derivative functions, we take into account the specific features of each of them. For example, the derivative of a linear activation function will always be its parameter a, and I see no reason to put this in a separate kernel. To adjust the error gradient to the derivative of this function, we can use the forward pass kernel by specifying 0 instead of the b parameter.

A similar situation arises when using [LReLU](https://www.mql5.com/en/neurobook/index/about_ai/activation#relu). A linear relationship is also used here, but the linearity factor varies from the value to the activation function. Therefore, we need to create a new kernel that, in its parameters, will receive pointers to three data buffers and a leakage coefficient, whereas the forward pass kernel only received pointers to two buffers and the coefficient.

In the kernel body, we define the global thread identifier, which will identify the element to be processed in the data buffers. Then we check the value of the corresponding element before the function. If the number is greater than 0, we use the coefficient of 1. Otherwise, we will use the leakage factor. The error gradient obtained from the subsequent neural layer will be multiplied by the selected coefficient. The value of the operation will be written to the corresponding element of the result buffer.

```
__kernel void LReLUDerivative(__global TYPE* outputs,

                              __global TYPE* output_gr,

                              __global TYPE* input_gr,

                              const TYPE a)

  {

   size_t i = get_global_id(0);

   input_gr[i] = (outputs[i] > 0 ? (TYPE)1 : a) * output_gr[i];

  }
```

The value of derivatives of S-shaped functions, such as the sigmoid and the hyperbolic tangent, can be easily calculated through the result of the activation function.

It is this approach that we will embed into the kernel algorithm for calculating the derivatives of these functions. The general approaches to the organization of kernel work remain the same.

```
__kernel void SigmoidDerivative(__global TYPE* outputs,

                                __global TYPE* output_gr,

                                __global TYPE* input_gr,

                                const TYPE a, const TYPE b

                               )

  {

   size_t i = get_global_id(0);

   if(a == 0)

      input_gr[i] = 0;

   else

     {

      TYPE z = clamp(outputs[i] + b, (TYPE)0, a);

      input_gr[i] = z * (1 - z / a) * output_gr[i];

     }

  }
```

```
__kernel void TanhDerivative(__global TYPE* outputs, __global TYPE* output_gr,

                             __global TYPE* input_gr)

  {

   size_t i = get_global_id(0);

   input_gr[i] = (1 - pow(outputs[i], 2)) * output_gr[i];

  }
```

To calculate the derivative of the Swish function, we will need the values both before and after activation. The mathematical formula of the derivative is presented below.

As you can see, the derivative of the function is expressed in terms of the activation function value, sigmoid values, and the activation function's parameter β. Substituting the sigmoid formula, we get the following expression.

To implement the formula mentioned, you need to pass pointers to four data buffers to the kernel: the corresponding values before and after activation, the error gradient from the subsequent layer, and the results buffer.

In the kernel body, calculate the derivative value using the provided formula and then multiply this value by the error gradient obtained from the subsequent layer. The result of the operation will be written to the corresponding element of the results buffer.

```
__kernel void SwishDerivative(__global TYPE* outputs,

                              __global TYPE* output_gr,

                              __global TYPE* input_gr,

                              const TYPE b,

                              __global TYPE* inputs)

  {

   size_t i = get_global_id(0);

   TYPE by = b * outputs[i];

   input_gr[i] = (by + (1 - by) / (1 + exp(-b * inputs[i]))) * output_gr[i];

  }
```

The kernel of calculating the derivative of the function [Softmax](https://www.mql5.com/en/neurobook/index/about_ai/activation#softmax) is the most difficult. As in the case of the S-shaped functions, the values of the activation function itself are sufficient to calculate the derivative of the Softmax function. To compute the value of one element in the vector during the feed-forward pass, we used the values of all elements in the vector before the activation function (calculating the total sum of exponents). Therefore, the value of each element after activation depends on all elements of the vector before activation. This means that each element must receive its share of the error from each element at the output of the neural layer before activation. In general, the derivative of the Softmax function is calculated using the formula below.

In the parameters of the SoftMaxDerivative kernel, we will pass pointers to three data buffers: the values of the activation function, the error gradient from the next layer, and the result buffer.

In the kernel body, we define the global thread ID, which this time only points to an element in the results buffer. The global thread identifier in the second dimension is used when working with a matrix in which the Softmax function was applied row-by-row. In this case, this identifier will help us determine the offset to the analyzed data.

Next, we prepare two private variables: one to store the value of the corresponding element after activation, and the other to accumulate the total gradient error value.

After that, we organize a loop for collecting error gradients from all elements at the output of the neural layer. Each specific gradient is calculated using the above formula.

After completing the loop iterations, we will save the accumulated sum of gradients in the corresponding element of the results buffer.

```
__kernel void SoftMaxDerivative(__global TYPE* outputs,

                                __global TYPE* output_gr,

                                __global TYPE* input_gr)

  {

   size_t i = get_global_id(0);

   size_t outputs_total = get_global_size(0);

   size_t shift = get_global_id(1) * outputs_total;

   TYPE output = outputs[shift + i];

   TYPE result = 0;

   for(int j = 0; j < outputs_total; j++)

      result += outputs[shift + j] * output_gr[shift + j] *

                                    ((TYPE)(i == j ? 1 : 0) - output);

   input_gr[shift + i] = result;

  }
```

After adjusting the error gradient for the activation function derivative, we need to distribute the obtained values to the neurons of the previous neural layer. As it was mentioned above, here we will divide the threads by the number of neurons in the lower neural layer. For each neuron, we will collect gradients from all neurons dependent on it.

The distribution of the error gradient through the neural layer will be carried out in the CalcHiddenGradient kernel. Pointers to 3 arrays are input into the kennel:

- weights: a matrix of weights;

- gradients: an array of gradients adjusted for the derivative of the activation function;

- gradient_inputs: an array for recording the gradients of the preceding layer.

In addition, the parameters indicate the number of neurons in the top layer (the size of the gradients array). The kernel construction algorithm is very similar to the forward pass method, as we also use the dot and ToVect4 functions. The difference lies in the arrays being used: during the forward pass, we took the input signal and multiplied it by the weights, whereas now we multiply the error gradient by the weights. There is one more point in using the ToVect4 function for the matrix of weights. When we considered this function for the feed-forward pass, we talked about a similar function of the parameters of the first element for copying start and for shifting shift. Then we used step of 1 element. Now, by iterating over the array of gradients, we will select the appropriate weights. However, in the feed-forward pass, neurons and weights followed in order, while in the backward pass, we take the weights across the weight matrix. In the vector expression of the weight matrix, we will use the step between the two elements to copy 1 element more than the number of neurons in the previous layer (the bias element). At the same time, the shift will be equal to the ordinal number of the processed neuron of the lower layer.

We do not specify the number of neurons in the lower neural layer in the parameters but use this value as a step to read values from the weight matrix. The get_global_size function allows us to get the specified value, which returns the total number of running kennel threads. Since we launched one thread for each neuron of the previous layer, the number of threads in this case will correspond to the number of neurons in the layer. Here, we calculate the number of elements in the weight matrix by multiplying the number of neurons in the layer by the number of neurons in the previous layer plus the bias element.

In other respects, we also use vector operations that allow us to utilize a loop in steps of 4 elements.

```
__kernel void CalcHiddenGradient(__global TYPE *gradient_inputs,

                                 __global TYPE *weights,

                                 __global TYPE *gradients,

                                 int outputs_total)

  {

   const int n = get_global_id(0);

   const int inputs_total = get_global_size(0);

   int weights_total = (inputs_total + 1) * outputs_total;

//---

   TYPE grad = 0;

   for(int o = 0; o < outputs_total; o += 4)

      grad += dot(ToVect4(gradients, o, 1, outputs_total, 0),

                  ToVect4(weights, o, (inputs_total + 1), weights_total, n));

   gradient_inputs[n] = grad;

  }
```

If you look at the [error backpropagation](https://www.mql5.com/en/neurobook/index/about_ai/study/back_propagation) algorithm, we have already reached the finish line. After propagating the error gradient, all we have to do is update the weight matrix. However, we remember from the MQL5 implementation that the weight matrix will not be updated after each iteration. Again, the process of updating the weight matrix will be divided into 2 stages:

- Accumulating error gradients over a certain interval.

- Averaging of the accumulated gradient and adjustment of the weight matrix.

We will collect error gradients for each weight in the CalcDeltaWeights kernel. In the kernel parameters, pointers to the array of data from the output of the previous layer, the gradient array, and an array for accumulating deltas needed for weight adjustments are passed.

All weights are calculated independently, so we can run the error calculation for each weighting factor in a separate thread. To make the structure of the threads more visual and understandable, we will create a task space in two dimensions. The first dimension will be equal to the number of neurons in the current layer, and the second will be equal to the number of neurons in the previous layer.

In the kernel body, we will determine the dimension of the weight matrix over the problem space and the position of the analyzed element in this matrix. After that, we will determine the offset of the element in the result buffer.

Let's not forget that we accumulate the error gradient until the moment of direct updating of the weights. Therefore, we will add to the previously accumulated sum the product of the corresponding error gradient by the result element of the previous layer.

Note that we are using an additional bias element. For this element, a constant value of the incoming element equal to one is used. We didn't take it into account when creating the task space, but we must also accumulate an error gradient for it. From a mathematical point of view, the derivative of multiplication by 1 is equal to 1. This means that the error gradient for a given element is equal to the error gradient before the activation function of the corresponding neuron. To avoid duplicating the iteration for writing the bias weight error gradient, we will perform this iteration only for the thread with index 0 in the second dimension.

```
__kernel void CalcDeltaWeights(__global TYPE *inputs,

                               __global TYPE *delta_weights,

                               __global TYPE *gradients)

  {

   const int n = get_global_id(0);

   const int outputs_total = get_global_size(0);

   const int i = get_global_id(1);

   const int inputs_total = get_global_size(1);

//---

   TYPE grad = gradients[n];

   int shift = n * (inputs_total + 1);

   delta_weights[shift + i] = inputs[i] * grad + delta_weights[shift + i];

   if(i == 0)

      delta_weights[shift + inputs_total] += grad;

  }
```

Now, we need to organize the process of updating the matrix of weights. We have studied and already implemented several methods for updating weights in the main program. When implementing this process in [MQL5](https://www.mql5.com/en/neurobook/index/realization/perceptron/pr_mql5#update), we created a dispatch method that redirected the logical chain of operations to the method corresponding to the selected method for updating the weights. Then, within these methods, we defined the device to perform the operations. To maintain the integrity of this approach, we have to create several kernels by analogy with the main program, implementing all the methods used to optimize the weight matrix.

All kernels were created using a single approach and therefore have many features in common. However, there are differences due to the specific features of each method. Let's start exploring kernels with the [stochastic gradient](https://www.mql5.com/en/neurobook/index/about_ai/study/optimization#sgd)descent method.

In the kernel parameters, we pass pointers to the matrix of accumulated gradients and the matrix of weights. In addition to pointers to matrices, the kernel parameters include the total number of elements in the weight matrix, the batch size for averaging, the learning rate, and regularization parameters.

As before, we will use vector operations, so the number of threads will be four times smaller than the size of the weight matrix. In the kernel body, we first define the offset in the array for the working elements of our stream and load them into vector variables. When reading the accumulated deltas, we immediately divide the obtained values by the batch size, which will give us the average value of the gradient. After that, we adjust the weights for the regularization coefficients and the average value of the accumulated deltas, taking into account the learning rate.

In conclusion, we return the obtained values to the weight matrix and reset the array of accumulated deltas.

```
__kernel void SGDUpdate(__global TYPE *delta_weights,

                        __global TYPE *weights,

                        int total,

                        int batch_size,

                        TYPE learningRate,

                        TYPE Lambda1,

                        TYPE Lambda2

                       )

  {

   int start = 4 * get_global_id(0);

   TYPE4 delta4 = ToVect4(delta_weights, start, 1, total, 0);

   TYPE4 weights4 = ToVect4(weights, start, 1, total, 0);

   TYPE lr = learningRate / ((TYPE)batch_size);

   weights4 -= (TYPE4)(Lambda1) + Lambda2 * weights4;

   weights4 += (TYPE4)(lr) * delta4;

   D4ToArray(weights, weights4, start, 1, total, 0);

   D4ToArray(delta_weights, (TYPE4)(0), start, 1, total, 0);

  }
```

Next, we studied the [accumulated momentum](https://www.mql5.com/en/neurobook/index/about_ai/study/optimization#momentum) method. In the same sequence, we will create kernels for the implementation of methods. The MomentumUpdate kernel algorithm is very similar to the stochastic gradient descent kernel discussed above. The main differences are the introduction of an additional array for storing the accumulated pulse, updating the weights, and the pulse smoothing parameter.

In the kernel body, as in the previous method, we read the corresponding array values into vector variables. At the same time, we average the accumulated gradient. Then we adjust the weights for the regularization parameters. After this, we first update the momentum of the weight change, taking into account the average gradient and the previously accumulated momentum. Only after this step, we adjust the weights based on the updated momentum. Before exiting the kernel, transfer the values of the vector variables to the corresponding elements of the weights and moments matrices. The cumulative array of deltas will be zeroed.

```
__kernel void MomentumUpdate(__global TYPE* delta_weights,

                             __global TYPE* weights,

                             __global TYPE* momentum,

                             int total, int batch_size,

                             TYPE learningRate,

                             TYPE beta,

                             TYPE Lambda1, TYPE Lambda2)

  {

   int start = 4 * get_global_id(0);

//---

   TYPE4 delta4 = ToVect4(delta_weights, start, 1, total, 0) /

                                                      ((TYPE4)batch_size);

   TYPE4 weights4 = ToVect4(weights, start, 1, total, 0);

   TYPE4 momentum4 = ToVect4(momentum, start, 1, total, 0);

   weights4 -= (TYPE4)(Lambda1) + Lambda2 * weights4;

   momentum4 = (TYPE4)(learningRate) * delta4 + (TYPE4)(beta) * momentum4;

   weights4 += momentum4;

   D4ToArray(weights, weights4, start, 1, total, 0);

   D4ToArray(momentum, momentum4, start, 1, total, 0);

   D4ToArray(delta_weights, (TYPE4)(0), start, 1, total, 0);

  }
```

The [AdaGrad](https://www.mql5.com/en/neurobook/index/about_ai/study/optimization#adagrad) optimization method, like the accumulated momentum method, uses a single array to accumulate moments. But unlike the previous method, we will sum up the squares of the gradients and there is no smoothing coefficient.

The approach to the use of the accumulated moment has also changed. In the previous method, we used accumulated momentum to reduce the randomness of updates and maintain smooth movements in the direction of the anti-gradient. Now, in the adaptive gradient method, the accumulated square of gradients is used to decrease the learning rate with each iteration. This is reflected in the kernel code below.

```
__kernel void AdaGradUpdate(__global TYPE* delta_weights,

                            __global TYPE* weights,

                            __global TYPE* momentum,

                            int total, int batch_size,

                            TYPE learningRate,

                            TYPE Lambda1, TYPE Lambda2)

  {

   int start = 4 * get_global_id(0);

//---

   TYPE4 delta4 = ToVect4(delta_weights, start, 1, total, 0) /

                                                      ((TYPE4)batch_size);

   TYPE4 weights4 = ToVect4(weights, start, 1, total, 0);

   TYPE4 momentum4 = ToVect4(momentum, start, 1, total, 0);

//---

   weights4 -= (TYPE4)(Lambda1) + Lambda2 * weights4;

   momentum4 = momentum4 + pow(delta4, 2);

   weights4 += learningRate / sqrt(momentum4 + 1.0e-37f);

   D4ToArray(weights, weights4, start, 1, total, 0);

   D4ToArray(momentum, momentum4, start, 1, total, 0);

   D4ToArray(delta_weights, (TYPE4)(0), start, 1, total, 0);

  }
```

The main problem of the adaptive gradient method is the constant accumulation of the gradient square. With long-term training, this can lead to a decrease in the learning rate to zero and a practical stop in the training of the neural network. This problem is solved in [RMSProp](https://www.mql5.com/en/neurobook/index/about_ai/study/optimization#rmsprop) by introducing a smoothing factor for accumulating gradient squares. This allows us to limit the growth of the accumulated sum of squares of gradients and thereby limit the decrease in the learning rate.

Otherwise, the kernel algorithm repeats the previously considered methods for updating weights.

```
__kernel void RMSPropUpdate(__global TYPE* delta_weights,

                            __global TYPE* weights,

                            __global TYPE* momentum,

                            int total, int batch_size,

                            TYPE learningRate,

                            TYPE beta,

                            TYPE Lambda1, TYPE Lambda2)

  {

   int start = 4 * get_global_id(0);

//---

   TYPE4 delta4 = ToVect4(delta_weights, start, 1, total, 0) /

                                                      ((TYPE4)batch_size);

   TYPE4 weights4 = ToVect4(weights, start, 1, total, 0);

   TYPE4 momentum4 = ToVect4(momentum, start, 1, total, 0);

//---

   weights4 -= (TYPE4)(Lambda1) + Lambda2 * weights4;

   momentum4 = beta * momentum4 + (1 - beta) * pow(delta4, 2);

   weights4 += delta4 * learningRate / (sqrt(momentum4) + 1.0e-37f);

   D4ToArray(weights, weights4, start, 1, total, 0);

   D4ToArray(momentum, momentum4, start, 1, total, 0);

   D4ToArray(delta_weights, (TYPE4)(0), start, 1, total, 0);

  }
```

In the [AdaDelta](https://www.mql5.com/en/neurobook/index/about_ai/study/optimization#adadelta) optimization update method, the authors tried to exclude the learning rate. But the price for this was the introduction of an additional momentum buffer and a second smoothing factor.

The method uses two exponential averages. The first one averages the square values of the corresponding weight, while the second one, like in the two previous methods, calculates the square of gradients on this weight. Instead of the learning rate, the ratio of the square roots of the two specified averages is used. As a result, we obtain a method in which, with an increase in the absolute value of the weight, the learning rate also increases. At the same time, an increase in the absolute value of the error gradient leads to a decrease in the learning rate.

Let's consider the implementation of this method in the AdaDeltaUpdate kernel. In the parameters, pointers to four data arrays are passed to the kernel:

- delta_weights: an array of accumulated error gradients;

- weights: a matrix of weights;

- momentumW: a matrix of exponential mean squares of the weights;

- momentumG: a matrix of exponential squares of error gradients.

In addition to the pointers to arrays, the kernel parameters include the size of the arrays, batch size, two exponential smoothing coefficients, and regularization parameters.

In the kernel body, we define the shift to the elements to be processed in this thread and read the necessary elements from the arrays into vector variables for further processing. The next step is to adjust the weights based on regularization parameters and update the weight moments and gradients. After that, we will update the weights themselves. Finally, write the new values to the data arrays and reset the array of accumulated gradients.

```
__kernel void AdaDeltaUpdate(__global TYPE* delta_weights,

                             __global TYPE* weights,

                             __global TYPE* momentumW,

                             __global TYPE* momentumG,

                             int total, int batch_size,

                             TYPE beta1, TYPE beta2,

                             TYPE Lambda1, TYPE Lambda2)

  {

   int start = 4 * get_global_id(0);

//---

   TYPE4 delta4 = ToVect4(delta_weights, start, 1, total, 0) /

                                                      ((TYPE4)batch_size);

   TYPE4 weights4 = ToVect4(weights, start, 1, total, 0);

   TYPE4 momentumW4 = ToVect4(momentumW, start, 1, total, 0);

   TYPE4 momentumG4 = ToVect4(momentumG, start, 1, total, 0);

//---

   weights4 -= (TYPE4)(Lambda1) + Lambda2 * weights4;

   momentumW4 = beta1 * momentumW4 + (1 - beta1) * pow(weights4, 2);

   momentumG4 = beta2 * momentumG4 + (1 - beta2) * pow(delta4, 2);

   weights4 += delta4 * sqrt(momentumW4) / (sqrt(momentumG4) + 1.0e-37f);

   D4ToArray(weights, weights4, start, 1, total, 0);

   D4ToArray(momentumW, momentumW4, start, 1, total, 0);

   D4ToArray(momentumG, momentumG4, start, 1, total, 0);

   D4ToArray(delta_weights, (TYPE4)(0), start, 1, total, 0);

  }
```

The last method we studied was the [Adam](https://www.mql5.com/en/neurobook/index/about_ai/study/optimization#adam) adaptive moment estimation method. Below are the mathematical formulas of this method.

Compared to the methods discussed earlier, the formulas may appear more complex, but there's nothing daunting about them, and this method is implementable. Like AdaDelta, the method uses two buffers to accumulate moments. We accumulate the momentum of the gradients in the first buffer and the momentum of the gradient squares in the second one. Both buffers use exponential smoothing, but each uses a different smoothing factor. In addition, the learning rate is returned to the method.

Let's consider the implementation of the method in the AdamUpdate kernel. In the kernel parameters, we will pass pointers to the data arrays:

- delta_weights: accumulated gradient deltas;

- weights: a matrix of weights;

- momentumM: a matrix of accumulated gradients;

- momentumV: a matrix of accumulated gradient squares.

We will also pass the size of the arrays, batch size, learning rate, smoothing coefficients, and regularization parameters in the kernel parameters.

At the beginning of the kernel, as in the implementation of the previous optimization methods, we define the shift to the processed elements in the arrays. To avoid unnecessary confusion, we will synchronously use the elements of the arrays, that is, the size of the arrays and the shift to the corresponding elements will be identical.

Let's copy the processed array elements into vector variables. As always, we will immediately divide the accumulated deltas by the batch size and store the arithmetic mean of the error gradient.

Next, we calculate the updated values of the accumulated pulses and adjust them, as proposed by the authors of the method.

After the preparatory work, we will adjust our weights. As before, we will first adjust for regularization parameters, and then move towards the anti-gradient direction according to the optimization method rules. In other words, we will subtract the product of the learning rate and the ratio of the first moment of the gradient to the square root of its second moment from the current weight.

At the end of the kernel, we will save the obtained values to the corresponding arrays. Do not forget to reset the array of accumulated deltas.

```
__kernel void AdamUpdate(__global TYPE* delta_weights,

                         __global TYPE* weights,

                         __global TYPE* momentumM,

                         __global TYPE* momentumV,

                         int total, int batch_size,

                         TYPE learningRate,

                         TYPE beta1, TYPE beta2,

                         TYPE Lambda1, TYPE Lambda2)

  {

   int start = 4 * get_global_id(0);

//---

   TYPE4 delta4 = ToVect4(delta_weights, start, 1, total, 0) /

                                                      ((TYPE4)batch_size);

   TYPE4 weights4 = ToVect4(weights, start, 1, total, 0);

   TYPE4 momentumM4 = ToVect4(momentumM, start, 1, total, 0);

   TYPE4 momentumV4 = ToVect4(momentumV, start, 1, total, 0);

//---

   momentumM4 = beta1 * momentumM4 + (1 - beta1) * delta4;

   momentumV4 = beta2 * momentumV4 + (1 - beta2) * pow(delta4, 2);

   TYPE4 m = momentumM4 / (1 - beta1);

   TYPE4 v = momentumV4 / (1 - beta2);

   weights4 -= (TYPE4)(Lambda1) + Lambda2 * weights4;

   weights4 += learningRate * m / (sqrt(v) + 1.0e-37f);

   D4ToArray(weights, weights4, start, 1, total, 0);

   D4ToArray(momentumM, momentumM4, start, 1, total, 0);

   D4ToArray(momentumV, momentumV4, start, 1, total, 0);

   D4ToArray(delta_weights, (TYPE4)(0), start, 1, total, 0);

  }
```

At this stage, we have completed the work on writing the OpenCL program. Of course, we will return to this work when implementing other architectural solutions for neural layers. However, in terms of a fully connected neural layer, this work can be considered complete. We save the code we've written and move on to implementing the processes of data exchange between the main program and the OpenCL kernels, as well as the functions for invoking the kernels. We have to do this work on the side of the main program.

## Implementing functionality on the main program side

The implementation of the functionality on the main program side will require some knowledge of process organization and effort. Let's start with the preparatory work. First, in our [file of definitions](https://www.mql5.com/en/neurobook/index/realization/basic/constants#mql5includeneuronetworksbookrealizationdefines.mqh), we need to [add the loading of the OpenCL program](https://www.mql5.com/en/neurobook/index/realization/basic/constants#mql5includeneuronetworksbookrealizationdefines.mqh) written above as a resource and assign its contents to a string variable. Here, we will also add predefined macro substitutions for data types and the size of the local array to the program.

```
#resource "opencl_program.cl" as string OCLprogram

//---

#define TYPE                         float

#define LOCAL_SIZE                   256

const string ExtType = StringFormat("#define TYPE %s\r\n"

                                    "#define TYPE4 %s4\r\n"

                                    "#define LOCAL_SIZE %d\r\n",

                                     typename(TYPE),typename(TYPE),LOCAL_SIZE);

#define cl_program                   ExtType+OCLprogram
```

When declaring kernels in the main program, the [CLKernelCreate](https://www.mql5.com/en/docs/opencl/clkernelcreate) function returns a handle. To work with OpenCL technology, we will use the CMyOpenCL class, which is derived from the standard COpenCL class. The aforementioned classes implement arrays for storing handles. A specific kernel is accessed by an index in the array. To simplify working with these indices and make the program code more readable, let's add constants for the indices of all the kernels created above. To explicitly identify the kernel index in the program code, we will start all named kernel constants with def_k.

```
//+------------------------------------------------------------------+

//| OpenCL Kernels                                                   |

//+------------------------------------------------------------------+

#define def_k_PerceptronFeedForward    0

#define def_k_LineActivation           1

#define def_k_SigmoidActivation        2

#define def_k_SigmoidDerivative        3

#define def_k_TANHActivation           4

#define def_k_TANHDerivative           5

#define def_k_LReLuActivation          6

#define def_k_LReLuDerivative          7

#define def_k_SoftMAXActivation        8

#define def_k_SoftMAXDerivative        9

#define def_k_SwishActivation          10

#define def_k_SwishDerivative          11

#define def_k_CalcOutputGradient       12

#define def_k_CalcHiddenGradient       13

#define def_k_CalcDeltaWeights         14

#define def_k_SGDUpdate                15

#define def_k_MomentumUpdate           16

#define def_k_AdaGradUpdate            17

#define def_k_RMSPropUpdate            18

#define def_k_AdaDeltaUpdate           19

#define def_k_AdamUpdate               20
```

To specify parameters when calling kernels, we can also use indices. However, now they are not specified explicitly. Instead, the serial number in the list of OpenCL kernel parameters is used. All kernels use their own set of parameters, so we will define named constants for all created kernels. To avoid confusion between identical parameters of different kernels, we will include a pointer to the respective kernel in the constant name. For example, the parameter constants for the forward pass kernel of the basic fully connected layer will start with def_pff.

```
//--- perceptron feed forward pass

#define def_pff_inputs                 0

#define def_pff_weights                1

#define def_pff_outputs                2

#define def_pff_inputs_total           3
```

We will declare constants for all written kernels in a similar way.

```
//--- calculating the error gradient of the result layer

#define def_outgr_target               0

#define def_outgr_outputs              1

#define def_outgr_gradients            2

#define def_outgr_loss_function        3
```

```
//--- calculating the error gradient of the hidden layer

#define def_hidgr_gradient_inputs      0

#define def_hidgr_weights              1

#define def_hidgr_gradients            2

#define def_hidgr_outputs_total        3
```

```
//--- calculating the error gradient at the level of the weight matrix

#define def_delt_inputs                0

#define def_delt_delta_weights         1

#define def_delt_gradients             2
```

```
//--- parameter optimization by stochastic gradient descent

#define def_sgd_delta_weights          0

#define def_sgd_weights                1

#define def_sgd_total                  2

#define def_sgd_batch_size             3

#define def_sgd_learningRate           4

#define def_sgd_Lambda1                5

#define def_sgd_Lambda2                6
```

```
//--- parameter optimization using the moment method

#define def_moment_delta_weights       0

#define def_moment_weights             1

#define def_moment_momentum            2

#define def_moment_total               3

#define def_moment_batch_size          4

#define def_moment_learningRate        5

#define def_moment_beta                6

#define def_moment_Lambda1             7

#define def_moment_Lambda2             8
```

```
//--- parameter optimization using the AdaGrad method

#define def_adagrad_delta_weights      0

#define def_adagrad_weights            1

#define def_adagrad_momentum           2

#define def_adagrad_total              3

#define def_adagrad_batch_size         4

#define def_adagrad_learningRate       5

#define def_adagrad_Lambda1            6

#define def_adagrad_Lambda2            7
```

```
//--- parameter optimization using the RMSProp method

#define def_rms_delta_weights          0

#define def_rms_weights                1

#define def_rms_momentum               2

#define def_rms_total                  3

#define def_rms_batch_size             4

#define def_rms_learningRate           5

#define def_rms_beta                   6

#define def_rms_Lambda1                7

#define def_rms_Lambda2                8
```

```
//--- parameter optimization using the AdaDelta method

#define def_adadelt_delta_weights      0

#define def_adadelt_weights            1

#define def_adadelt_momentumW          2

#define def_adadelt_momentumG          3

#define def_adadelt_total              4

#define def_adadelt_batch_size         5

#define def_adadelt_beta1              6

#define def_adadelt_beta2              7

#define def_adadelt_Lambda1            8

#define def_adadelt_Lambda2            9
```

```
//--- parameter optimization using the Adam method

#define def_adam_delta_weights         0

#define def_adam_weights               1

#define def_adam_momentumM             2

#define def_adam_momentumV             3

#define def_adam_total                 4

#define def_adam_batch_size            5

#define def_adam_learningRate          6

#define def_adam_beta1                 7

#define def_adam_beta2                 8

#define def_adam_Lambda1               9

#define def_adam_Lambda2               10
```

```
//--- activation functions

#define def_activ_inputs               0

#define def_activ_outputs              1

#define def_activ_param_a              2

#define def_activ_param_b              3
```

```
//--- adjusting the gradient to the derivative of the activation function

#define def_deactgr_outputs            0

#define def_deactgr_gradients          1

#define def_deactgr_deact_gradient     2

#define def_deactgr_act_param_a        3

#define def_deactgr_act_param_b        4
```

I intentionally provided a complete set of constants above to offer you a reference guide. It will assist in reading and understanding the code for our next steps in implementing OpenCL technology into the project.

After describing the constants, we will move on to creating classes that will be responsible for servicing OpenCL tools. We have already mentioned them multiple times. It's time to learn more about their features.

First, this is the CMyOpenCL class. It inherits from the COpenCL class from the MQL5 standard libraries. The standard library is well-written and has sufficient functionality to organize work. However, I found one aspect inconvenient personally: when working with buffers for data exchange between the main program and the OpenCL context, a similar approach is used as with other process objects. When creating a buffer, we have to specify its index in the general array of buffers. This is a perfectly workable option when we know all the buffers and their quantity in advance. However, our case is a little more complicated.

```
class CMyOpenCL   :  public COpenCL

  {

public:

                     CMyOpenCL(void)   {};

                    ~CMyOpenCL(void)   {};

   //--- initialization and shutdown

   virtual bool      Initialize(const string program, const bool show_log = true);

   //---

   template<typename T>

   int               AddBufferFromArray(T &data[], const uint data_array_offset,

                                   const uint data_array_count, const uint flags);

   int               AddBufferFromArray(MATRIX &data,

                                  const uint data_array_offset, const uint flags);

   int               AddBuffer(const uint size_in_bytes, const uint flags);

   bool              CheckBuffer(const int index);

   //---

   bool              BufferFromMatrix(const int buffer_index, MATRIX &data,

                                  const uint data_array_offset, const uint flags);

   bool              BufferRead(const int buffer_index, MATRIX &data,

                                                     const uint cl_buffer_offset);

   bool              BufferWrite(const int buffer_index, MATRIX &data,

                                                     const uint cl_buffer_offset);

  };
```

Earlier, we discussed that the number of used buffers for accumulating moments can vary depending on the chosen method for updating weights. In addition, we cannot know in advance how many neural layers the user will use to solve their tasks. Hence, I needed a dynamic array to store handles of data buffers. This problem was solved by adding a small AddBufferFromArray method. The parameters of this method are similar to those of the [BufferFromArray](https://www.mql5.com/en/docs/standardlibrary/copencl/copenclbufferfromarray) method of the parent class except for the buffer index. The body of the method body a loop to search for empty cells in the buffer handle storage array. The first empty cell is used to create the buffer. When there are no free elements in the array, the method expands the array. The buffer is directly created by calling the above parent class method.

As a result of the operations, the method returns the index of the created buffer. If errors occur during operations, the method will return the INVALID_HANDLE constant.

I'd like to point out another aspect, which is that the method is created using the function template pattern. This allows you to use one method to create buffers of different types of data.

```
template<typename T>

int CMyOpenCL::AddBufferFromArray(T &data[], const uint data_array_offset,

                                  const uint data_array_count, const uint flags

                                 )

  {

   int result=INVALID_HANDLE;

   for(int i=0; i<m_buffers_total; i++)

     {

      if(m_buffers[i]!=INVALID_HANDLE)

         continue;

      result=i;

      break;

     }

//---

   if(result<0)

     {

      if(ArrayResize(m_buffers,m_buffers_total+1)>0)

        {

         m_buffers_total=ArraySize(m_buffers);

         result=m_buffers_total-1;

         m_buffers[result]=INVALID_HANDLE;

        }

      else

         return result;

     }

//---

   if(!BufferFromArray(result,data,data_array_offset,data_array_count,flags))

      return INVALID_HANDLE;

//---

   return result;

  }
```

The method created above allows the creation of buffers from arrays of any data types but it is not applicable when working with matrices. Therefore, the method was overloaded. The method algorithm remains unchanged.

```
int CMyOpenCL::AddBufferFromArray(MATRIX &data,

                                  const uint data_array_offset,

                                  const uint flags

                                 )

  {

//--- Search for a free element in a dynamic array of pointers

   int result = -1;

   for(int i = 0; i < m_buffers_total; i++)

     {

      if(m_buffers[i] != INVALID_HANDLE)

         continue;

      result = i;

      break;

     }

//--- If a free item is not found, add a new item to the array

   if(result < 0)

     {

      if(ArrayResize(m_buffers, m_buffers_total + 1) > 0)

        {

         m_buffers_total = ArraySize(m_buffers);

         result = m_buffers_total - 1;
```

```
m_buffers[result] = INVALID_HANDLE;

  }

      else

         return result;

     }

//--- Create a buffer in the OpenCL context

   if(!BufferFromMatrix(result, data, data_array_offset, flags))

      return -1;

   return result;

  }
```

Anticipating a bit, I want to mention that we won't always be creating buffers based on ready-made arrays. Sometimes, we just need to create a buffer in the OpenCL context without duplicating it in the main memory. Or, for example, a specific buffer is only used to obtain results, and there is no need to load its data into the context before performing operations. As we've mentioned before, the data copying process is an expensive operation, and we would like to minimize such operations. Therefore, it would be easier for us to simply create a data buffer in the context of a certain size without copying the data. For such cases, we will create the AddBuffer method. As you can notice, the algorithm of the method is almost identical to the methods of the previous class. The only difference is that this method receives the buffer size in bytes as a parameter instead of an array. At the end of the method, we call the BufferCreate method, which will create a buffer of the specified size in the OpenCL context.

```
int CMyOpenCL::AddBuffer(const uint size_in_bytes, const uint flags)

  {

//--- Search for a free element in a dynamic array of pointers

   int result = -1;

   for(int i = 0; i < m_buffers_total; i++)

     {

      if(m_buffers[i] != INVALID_HANDLE)

         continue;

      result = i;

      break;

     }

//--- If a free item is not found, add a new item to the array

   if(result < 0)

     {

      if(ArrayResize(m_buffers, m_buffers_total + 1) > 0)

        {

         m_buffers_total = ArraySize(m_buffers);

         result = m_buffers_total - 1;

         m_buffers[result] = INVALID_HANDLE;

  }
```

```
else

         return result;

     }

//--- Create a buffer in the OpenCL context

   if(!BufferCreate(result, size_in_bytes, flags))

      return -1;

   return result;

  }
```

We also created methods for reading (BufferRead) and writing (BufferWrite) data of the OpenCL context buffer to the main memory matrix. The method algorithm is completely identical. Let's consider the data reading method as an example. In the method parameters, it receives the buffer identifier in the dynamic array of our class, a matrix for writing data, and an offset in the context buffer.

Please do not confuse the buffer identifier in the dynamic class array and the buffer handle in the OpenCL context. The class operation is structured in such a way that we only pass the ordinal number of an element in the dynamic array of our class to the external program, which contains the handle of that buffer. As a result, when creating a buffer in the context using the class, the external program does not have direct access to the created buffer in the context. All work with the buffer should be done using class methods.

In the method body, we first check the received buffer ID for the size of our dynamic array. We then check the validity of the specified buffer handle. In addition, we will check the validity of the OpenCL context and program handles. Only after successfully passing all the controls, we call the function for reading data from the buffer. Don't forget to check the results of the operations at every step. At the end of the method, we will return the logical result of the operations.

```
bool CMyOpenCL::BufferRead(const int buffer_index, MATRIX &data,

                                     const uint cl_buffer_offset)

  {

//--- checking parameters

   if(buffer_index < 0 || buffer_index >= m_buffers_total || data.Rows() <= 0)

      return(false);

   if(m_buffers[buffer_index] == INVALID_HANDLE)

      return(false);

   if(m_context == INVALID_HANDLE || m_program == INVALID_HANDLE)

      return(false);

//--- reading buffer data from the OpenCL context

   if(!CLBufferRead(m_buffers[buffer_index], cl_buffer_offset, data))

      return(false);

//---

   return(true);

  }
```

The second class that we will create and use to transfer data between the main program and the OpenCL context is the CBufferType data buffer class. The class was created as a descendant of the CObject base class. Since the parent class is the base class, we need to recreate all the necessary functionality.

In addition to creating new methods in the new class, two new variables have appeared:

- m_cOpenCL — a pointer to an object of the CMyOpenCL class

- m_myIndex — the index of the current buffer in the dynamic array for storing buffer handles in the CMyOpenCL class.

The m_mMatrix matrix for storing data has also been introduced. Here we have slightly deviated from the generally accepted rules for creating classes. It is usually customary to restrict access to internal variables, and all interactions with them are built through class methods. Each such method restricts the degree of freedom to internal variables and requires additional time for executing the method's additional operations. Of course, this approach allows for complete control over changes in variable states. However, in building neural models, we aim to minimize the time spent on each iteration, as milliseconds per iteration can result in significant time overhead due to repeated calls. That is why we announced the m_mMatrix data matrix in public space. Of course, the fact that the class will be used to store and transmit data within our global project and that all buffers will be private or protected objects of other classes, minimizes our risks.

```
class CBufferType: public CObject

  {

protected:

   CMyOpenCL*        m_cOpenCL;     // OpenCL context object

   int               m_myIndex;     // data buffer index in context

public:

                     CBufferType(void);

                    ~CBufferType(void);

   //--- data matrix

   MATRIX            m_mMatrix;

   //--- method of initializing the buffer with initial values

   virtual bool      BufferInit(const ulong rows, const ulong columns,

                                                          const TYPE value = 0);

   //--- create a new buffer in the OpenCL context

   virtual bool      BufferCreate(CMyOpenCL *opencl);

   //--- delete the buffer in the context of OpenCL

   virtual bool      BufferFree(void);

   //--- read buffer data from the OpenCL context

   virtual bool      BufferRead(void);

   //--- write buffer data to the OpenCL context

   virtual bool      BufferWrite(void);

   //--- get the buffer index

   virtual int       GetIndex(void);

   //--- change the buffer index

   virtual bool      SetIndex(int index)

                       {

                        if(!m_cOpenCL.BufferFree(m_myIndex))

                           return false;

                        m_myIndex = index;

                        return true;

                       }

   //--- copy buffer data to an array

   virtual int       GetData(TYPE &values[], bool load = true);

   virtual int       GetData(MATRIX &values, bool load = true);

   virtual int       GetData(CBufferType* values, bool load = true);

   //--- calculate the average value of the data buffer

   virtual TYPE      MathMean(void);

   //--- vector operations

   virtual bool      SumArray(CBufferType* src);

   virtual int       Scaling(TYPE value);

   virtual bool      Split(CBufferType* target1, CBufferType* target2,

                                                            const int position);

   virtual bool      Concatenate(CBufferType* target1, CBufferType* target2,

                                    const int positions1, const int positions2);

   //--- methods for working with files

   virtual bool      Save(const int file_handle);

   virtual bool      Load(const int file_handle);

   //--- class identifier

   virtual int       Type(void)              const { return defBuffer;              }

   //--- methods for working with the data matrix

   ulong             Rows(void)              const { return m_mMatrix.Rows();       }

   ulong             Cols(void)              const { return m_mMatrix.Cols();       }

   uint              Total(void)             const { return (uint)(m_mMatrix.Rows() *

                                                                 m_mMatrix.Cols()); }

   TYPE              At(uint index)          const { return m_mMatrix.Flat(index);  }

   TYPE              operator[](ulong index) const { return m_mMatrix.Flat(index);  }

   VECTOR            Row(ulong row)                { return m_mMatrix.Row(row);     }

   VECTOR            Col(ulong col)                { return m_mMatrix.Col(col);     }

   bool              Row(VECTOR& vec,  ulong row)  { return m_mMatrix.Row(vec, row);}

   bool              Col(VECTOR& vec,  ulong col)  { return m_mMatrix.Col(vec, col);}

   bool              Activation(MATRIX& mat_out, ENUM_ACTIVATION_FUNCTION func)

                                      { return m_mMatrix.Activation(mat_out, func); }

   bool              Derivative(MATRIX& mat_out, ENUM_ACTIVATION_FUNCTION func)

                                      { return m_mMatrix.Derivative(mat_out, func); }

   bool              Reshape(ulong rows, ulong cols)

                                      { return m_mMatrix.Reshape(rows, cols);       }

//---

   bool              Update(uint index, TYPE value)

                       {

                        if(index >= Total())

                           return false;

                        m_mMatrix.Flat(index, value);

                        return true;

                       }
```

```
bool              Update(uint row, uint col, TYPE value)

                       {

                        if(row >= Rows() || col >= Cols())

                           return false;

                        m_mMatrix[row, col] = value;

                        return true;

                       }

  };
```

The structure of the class methods is quite diverse. Some of them are similar to matrix functions and perform the same functionality — designed to work with a data matrix. Others carry out the functionality of interacting with the OpenCL context. Let's take a closer look at some of them.

In the class constructor, we will only set the initial values of the new variables. They are filled with empty values.

```
CBufferType::CBufferType(void)  : m_myIndex(-1)

  {

   m_cOpenCL = NULL;

  }
```

In the class destructor, we will perform memory cleaning operations. Here we'll clear the buffer in the context of OpenCL.

```
CBufferType::~CBufferType(void)

  {

   if(m_cOpenCL && m_myIndex >= 0 && m_cOpenCL.BufferFree(m_myIndex))

        {

         m_myIndex = -1;

         m_cOpenCL = NULL;

  }

  }
```

We have already used the BufferInit buffer initialization method in the neural layer class constructor. The main functionality of this method is to create a matrix of a specified size and populate it with initial values. The buffer size and initial values are specified in the method parameters. As part of this project, we will fill arrays with zero values during the initialization of the neural network and reset the buffers of accumulated deltas after updating the weight matrix.

```
bool CBufferType::BufferInit(ulong rows, ulong columns, TYPE value)

  {

   if(rows <= 0 || columns <= 0)

      return false;

   m_mMatrix = MATRIX::Full(rows, columns, value);

   if(m_cOpenCL)

     {

      CMyOpenCL *opencl=m_cOpenCL;

      BufferFree();

      return BufferCreate(opencl);

     }

//---

   return true;

  }
```

The next method is to create a buffer in the OpenCL context. In parameters, the method receives a pointer to an instance of the CMyOpenCL class in the context of which the buffer should be created.

The method starts with a control block. First, we check the validity of the obtained pointer - in case of receiving an invalid pointer, we delete the buffer previously created in the OpenCL context and exit the method.

```
bool CBufferType::BufferCreate(CMyOpenCL *opencl)

  {

//--- initial data validation block

   if(!opencl)

     {

      BufferFree();

      return false;

     }
```

Then we check that it matches the previously saved pointer. If the pointers are identical and the buffer index is already saved, we won't create a new buffer in the OpenCL context but will simply copy the data from the matrix to the data exchange buffer again. To do this, we call the BufferWrite method. This method has its own set of checks, which we will become familiar with a bit later, and it returns a logical result of the operation. We exit the method with the result of the method of writing data to the OpenCL context.

```
//--- if the received pointer matches the one previously saved,

//--- simply copy the buffer contents into the context memory

   if(opencl == m_cOpenCL && m_myIndex >= 0)

      return BufferWrite();
```

The subsequent code of the method will be executed only if we have not exited the method during the preceding operations. Here, we check the validity of the previously saved pointer to an instance of the CMyOpenCL class and the presence of an index in the dynamic array storing handles of data buffers. If this condition is met, we must clear the memory and delete the existing buffer using the BufferFree method before continuing operations. Only after successfully deleting the old buffer do we have the right to open a new one. Otherwise, uncontrolled use of memory resources will lead to memory shortages and corresponding consequences.

```
//--- checking for a previously saved pointer to the OpenCL context

//--- if available, remove the buffer from the unused context

   if(m_cOpenCL && m_myIndex >= 0)

     {

      if(m_cOpenCL.BufferFree(m_myIndex))

        {

         m_myIndex = -1;

         m_cOpenCL = NULL;

  }

      else

         return false;

     }
```

At the end of the method, we initiate the creation of a new data buffer in the specified context. To do this, we call the AddBufferFromArray method discussed above. The index obtained in response to the call will be stored in the m_myIndex variable. If the buffer opening operation is successful, we will save the CMyOpenCL instance pointer received as input to the method before exiting.

```
//--- create a new buffer in the specified OpenCL context

   if((m_myIndex = opencl.AddBufferFromArray(m_mMatrix, 0, CL_MEM_READ_WRITE)) < 0)

      return false;

   m_cOpenCL = opencl;

//---

   return true;

  }
```

In this method, we used two new methods: one for clearing the buffer and the other for writing data. The BufferFree method is responsible for clearing the buffer. The method algorithm is quite simple. First, we check for the presence of a stored pointer to an instance of the CMyOpenCL class and an index in the dynamic buffer array. If they are available, call the CMyOpenCL class buffer cleaning method and specify the buffer index to delete. If the buffer is successfully removed from the context, clear the pointer to the CMyOpenCL class instance and the buffer index variable.

It should be noted that calling this method clears memory and deletes the buffer only in the context of OpenCL. At the same time, the data matrix itself and its contents remain in RAM. We will be able to exploit this property to use OpenCL context memory more efficiently a little later.

```
bool CBufferType::BufferFree(void)

  {

//--- checking for a previously saved pointer to the OpenCL context

//--- if available, remove the buffer from the unused context

   if(m_cOpenCL && m_myIndex >= 0)

      if(m_cOpenCL.BufferFree(m_myIndex))

        {

         m_myIndex = -1;

         m_cOpenCL = NULL;

         return true;

  }

   if(m_myIndex >= 0)

      m_myIndex = -1;

//---

   return false;

  }
```

Next, I suggest considering methods for transferring information between the main program and the OpenCL context. This work is done in two similar methods: BufferRead and BufferWrite. Despite the differences in the operation directions, the algorithm of the methods is identical. At the beginning of the methods, a control block is organized that checks the validity of the pointer to an instance of the CMyOpenCL class and the presence of an index in the dynamic buffer array. And only after the control block has been successfully passed, the OpenCL context class method of the same name is called, specifying the buffer index, matrix, and offset in the OpenCL buffer.

```
bool CBufferType::BufferRead(void)

  {

   if(!m_cOpenCL || m_myIndex < 0)

      return false;

//---

   return m_cOpenCL.BufferRead(m_myIndex, m_mMatrix, 0);

  }
```

```
bool CBufferType::BufferWrite(void)

  {

   if(!m_cOpenCL || m_myIndex < 0)

      return false;

//---

   return m_cOpenCL.BufferWrite(m_myIndex, m_mMatrix, 0);

  }
```

We have separately created methods for obtaining and directly specifying the buffer index in the dynamic array of GetIndex and SetIndex buffer handles. Their code is straightforward, so I don't even move them outside the class declaration block.

We've added three GetData methods of the same name to the class. They all perform the same function which is copying matrix data into a given structure. The difference is in the data receiver. This can be a dynamic array, matrix, or another instance of the CBufferType class.

In the first case, the method parameters contain a reference to the array and a flag that indicates the need to read data from the OpenCL context before copying the data. The introduction of the flag is a necessary measure. As you may have noticed when considering a method for reading data from the context, if there is no pointer to the CMyOpenCL object or index in the dynamic buffer array, the method will return false. This will block receiving data from an array without a buffer created in the OpenCL context. The introduction of a flag allows you to control this process.

At the beginning of the method, we check the flag and read data from the context, if necessary. Only then do we change the size of the receiver array and create a data copying cycle. Finally, the method returns the number of copied items.

```
int CBufferType::GetData(TYPE &values[], bool load = true)

  {

   if(load && !BufferRead())

      return -1;

   if(ArraySize(values) != Total() &&

      ArrayResize(values, Total()) <= 0)

      return false;

//---

   for(uint i = 0; i < Total(); i++)

      values[i] = m_mMatrix.Flat(i);

   return (int)Total();

  }
```

The other two methods are built on the basis of a similar algorithm but they take into account the specifics of the receiver object.

```
int CBufferType::GetData(MATRIX &values, bool load = true)

  {

   if(load && !BufferRead())

      return -1;

//---

   values = m_mMatrix;

   return (int)Total();

  }
```

```
int CBufferType::GetData(CBufferType *values, bool load = true)

  {

   if(!values)

      return -1;

   if(load && !BufferRead())

      return -1;

   values.m_mMatrix.Copy(m_mMatrix);

   return (int)values.Total();

  }
```

Now that we have prepared constants and classes for working with the OpenCL context, we can continue to work on organizing the process directly in our neural network classes.

When creating methods for our [neural network base class](https://www.mql5.com/en/neurobook/index/realization/basic/neuron_base), we did not add two methods, UseOpenCL and InitOpenCL. As can be seen from the names of the methods, they are designed to initialize and control the process of working with OpenCL. The first one is used to switch the operating mode and enables and disables the use of OpenCL. The second one initializes the operation of an instance of the CMyOpenCL class.

Let's take a step back and fill these gaps. In the parameters of the UseOpenCL method, we will specify the new state as a logical value. Using a logical value to convey a binary state to enable/disable a function seems intuitive to me. It is quite logical to use true to enable the functionality and false to turn it off.

In the method body, we will organize the algorithm to branch out depending on the state being set. When we receive a command to disable the functionality, we will check the current pointer to an instance of the CMyOpenCL class that is stored in the m_Copencl variable. If the pointer is invalid, the functionality has not been initialized before, and we have nothing to disable. In this case, we will just update the state of the technology usage flag and exit the method.

If the functionality was previously activated and a signal to deactivate it has now been received, we will initiate the process of cleaning up the object and deleting it. After that, we will distribute a new (empty) pointer to neural network objects, save the flag, and exit the method.

```
void CNet::UseOpenCL(bool value)

  {

   if(!value)

     {

      if(!m_cOpenCL)

        {

         m_bOpenCL = value;

         return;

  }

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      if(!!m_cLayers)

         m_cLayers.SetOpencl(m_cOpenCL);

      m_bOpenCL = value;

      return;

     }
```

Further operations will be performed only when the OpenCL functionality is enabled. When we receive a signal to enable the use of OpenCL, we start the process of creating and initializing a new instance of the CMyOpenCL class, which is placed in a separate InitOpenCL method.

Before exiting the method, save the new flag for using OpenCL and distribute the pointer to the new object across all objects of the neural network. To do this, we will pass a new pointer into the dynamic array object storing the layers of the neural network, and from there, the pointer will be passed down the hierarchical chain to each object in the neural network.

```
//---

   if(!!m_cOpenCL)

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

     }

   m_bOpenCL = InitOpenCL();

   if(!!m_cLayers)

      m_cLayers.SetOpencl(m_cOpenCL);

   return;

  }
```

The actual process of creating a new instance of the CMyOpenCL class and initializing it is placed in a separate InitOpenCL method.

At the beginning of the method, we check for the existence of a previously saved pointer to an object of the CMyOpenCL class. At this point, the question arises about what we want to do next if there is a previously instantiated object. We can continue using a previously initialized instance of the class or create a new one. Using an existing facility seems less labor-intensive at this stage. However, in this case, we may need an additional method to restart the functionality in the event of an error of some kind. This is an additional effort that is likely to require developing an additional control system for the entire project code.

We chose the forced restart option. Therefore, if we have a valid pointer to a previously created instance of the CMyOpenCL class, we start the process of deleting its contents from memory, and then the object itself. Only after clearing the memory, we start the process of creating and initializing a new object. The process of creating an OpenCL context and program is implemented in the COpenCL::Initialize method. As parameters to this method, we will pass a text variable containing our program. Remember, we wrote our program code from a file resource into it?

```
bool CNet::InitOpenCL(void)

  {

//--- Delete previously created OpenCL objects

   if(!!m_cOpenCL)

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

     }

//--- Create a new object to work with OpenCL

   m_cOpenCL = new CMyOpenCL();

   if(!m_cOpenCL)

      return false;

//--- Initialize the object for working with OpenCL

   if(!m_cOpenCL.Initialize(cl_program, true))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

Next, let's specify the number of kernels and buffers used. Above, we have declared constants for 20 kernels, each using no more than 4 data buffers. I intentionally don't specify a large number of buffers at this stage, as thanks to our new method, the array will automatically expand when a new data buffer is created. However, the number of kernels in the program is static and does not depend on the neural network architecture.

```
if(!m_cOpenCL.SetKernelsCount(20))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }

   if(!m_cOpenCL.SetBuffersCount(4))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

After that, we will initialize all program kernels and save the handles for calling them into an array within the CMyOpenCL class object.

We are not creating all the data buffers one by one at this stage for one simple reason: their quantity depends on the architecture of the neural network and may exceed the available OpenCL context memory capacity. If it is insufficient, dynamic memory allocation can be used. This implies loading buffers as needed and subsequently freeing memory when a specific data buffer is not planned to be used. However, this approach leads to an increase in the overhead of copying data between the main memory and the OpenCL context. Therefore, its use is justified only if there is a lack of GPU memory.

The kernel creation algorithm is identical. Here are just a few examples.

```
if(!m_cOpenCL.KernelCreate(def_k_PerceptronFeedForward, "PerceptronFeedForward"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

```
if(!m_cOpenCL.KernelCreate(def_k_CalcOutputGradient, "CalcOutputGradient"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

```
if(!m_cOpenCL.KernelCreate(def_k_CalcHiddenGradient, "CalcHiddenGradient"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

```
if(!m_cOpenCL.KernelCreate(def_k_CalcDeltaWeights, "CalcDeltaWeights"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

So we have come to the stage of organizing work with the OpenCL context directly in the neural layer class. When creating many class methods, we branched the method algorithm depending on the device for performing operations. Then we created the process organization code using MQL5 and left gaps in the process organization on the OpenCL side. Let's go back and fill in these gaps.

We will start with the direct pass method. We have previously discussed the organization of operations using MQL5. Now let's look at the implementation of working with the OpenCL context.

```
bool CNeuronBase::FeedForward(CNeuronBase * prevLayer)

  {

//--- control block

   if(!prevLayer || !m_cOutputs || !m_cWeights ||

      !prevLayer.GetOutputs() || !m_cActivation)

      return false;

   CBufferType *input_data = prevLayer.GetOutputs();

//--- algorithm branching depending on the operating device

   if(!m_cOpenCL)

     {

      if(m_cWeights.Cols() != (input_data.Total() + 1))

         return false;

      //---

      MATRIX m = input_data.m_mMatrix;

      if(!m.Reshape(1, input_data.Total() + 1))

         return false;

      m[0, m.Cols() - 1] = 1;

      m_cOutputs.m_mMatrix = m.MatMul(m_cWeights.m_mMatrix.Transpose());

     }
```

First, we'll check that the initial data array, the weight matrix, and the result buffer have a buffer index. The logic here is simple. If we receive a pointer to a data array with an existing buffer in the method's parameters, we assume that the data is already loaded into the OpenCL context. Above, when creating a data buffer in the CBufferType class, we immediately created a buffer in the OpenCL context. Therefore, the absence of a buffer index may indicate an error. Because of this, in such a case, we end the method with a false result. If you use dynamic memory allocation, then at this point you will need to create copies of all data buffers used in this kernel and copy the contents of the source data buffers into the OpenCL context.

```
else // OpenCL block

     {

      //--- checking data buffers

      if(input_data.GetIndex() < 0)

         return false;

      if(m_cWeights.GetIndex() < 0)

         return false;

      if(m_cOutputs.GetIndex() < 0)

         return false;
```

Then we will specify the parameters for the feed-forward kernel. Here we will specify their indices for buffers and specific values for discrete parameters.

```
//--- passing arguments to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_PerceptronFeedForward, def_pff_inputs,

                                                           input_data.GetIndex()))

         return false;
```

```
if(!m_cOpenCL.SetArgumentBuffer(def_k_PerceptronFeedForward, def_pff_weights,

                                                            m_cWeights.GetIndex()))

         return false;
```

```
if(!m_cOpenCL.SetArgumentBuffer(def_k_PerceptronFeedForward, def_pff_outputs,

                                                            m_cOutputs.GetIndex()))

         return false;
```

```
if(!m_cOpenCL.SetArgument(def_k_PerceptronFeedForward, def_pff_inputs_total,

                                                               input_data.Total()))

         return false;
```

In the NDRange array, we will specify the number of parallel threads required by the number of neurons in the current layer and launch the kernel for execution. Note that the Execute method does not literally start kernel execution, but only queues it for execution. The kernel is launched directly when you try to read the results of its operation. However, we will not download the results of each kernel's operations. Instead, we'll queue up a forward pass through the entire section and download only the result of the model's work from the last layer. This will take up the entire queue of operations. Thus, we will reduce the amount of data transferred and the time it takes to download it.

In the case of dynamic memory allocation, after queuing the kernel, it will be necessary to load all changes from the OpenCL context into the data matrices and delete unused buffers from the context. Note that you need to download the contents of all buffers whose data changes during the kernel operation.

```
//--- putting the kernel in the execution queue

      uint off_set[] = {0};

      uint NDRange[] = {m_cOutputs.Total()};

      if(!m_cOpenCL.Execute(def_k_PerceptronFeedForward, 1, off_set, NDRange))

         return false;

     }

//---

   return m_cActivation.Activation(m_cOutputs);

  }
```

After performing the above-described operations, we call the activation method of the required activation function class and exit the method.

It is also necessary to supplement the code for backpropagation methods. In the gradient computation kernel at the output of the neural network, three buffers are used: for target values, for the results of the last feed-forward pass, and for writing the obtained gradients. We'll check them at the beginning of the OpenCL block.

```
bool CNeuronBase::CalcOutputGradient(CBufferType* target, ENUM_LOSS_FUNCTION loss)

  {

//--- control block

   if(!target || !m_cOutputs || !m_cGradients ||

      target.Total() < m_cOutputs.Total() ||

      m_cGradients.Total() < m_cOutputs.Total())

      return false;
```

```
//--- algorithm branching depending on the operating device

   if(!m_cOpenCL)

     {

      switch(loss)

        {

         case LOSS_MAE:

            m_cGradients.m_mMatrix = target.m_mMatrix - m_cOutputs.m_mMatrix;

            break;

         case LOSS_MSE:

            m_cGradients.m_mMatrix = (target.m_mMatrix - m_cOutputs.m_mMatrix) * 2;

            break;

         case LOSS_CCE:

            m_cGradients.m_mMatrix=target.m_mMatrix/(m_cOutputs.m_mMatrix+FLT_MIN)*

                                     log(m_cOutputs.m_mMatrix) * (-1);

            break;

         case LOSS_BCE:

            m_cGradients.m_mMatrix = (target.m_mMatrix-m_cOutputs.m_mMatrix)/

                                     (MathPow(m_cOutputs.m_mMatrix,2) -

                                      m_cOutputs.m_mMatrix+FLT_MIN);

            break;

         default:

            m_cGradients.m_mMatrix = target.m_mMatrix - m_cOutputs.m_mMatrix;

            break;

  }

     }
```

```
else // OpenCL block

     {

      //--- checking data buffers

      if(target.GetIndex() < 0)

         return false;

      if(m_cOutputs.GetIndex() < 0)

         return false;

      if(m_cGradients.GetIndex() < 0)

         return false;
```

Next, we will specify their indices in our kernel parameters. We will also specify the loss function used in the kernel parameters.

```
//--- pass arguments to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcOutputGradient, def_outgr_target,

                                                                target.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcOutputGradient, def_outgr_outputs,

                                                            m_cOutputs.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcOutputGradient,def_outgr_gradients,

                                                          m_cGradients.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_CalcOutputGradient, def_outgr_loss_function,

                                                                        (int)loss))

         return false;
```

The number of independent operation threads launched equals the number of neurons at the output of our model.

Start the kernel execution and complete the method.

```
//--- put the kernel in the execution queue

      uint NDRange[] = { m_cOutputs.Total() };

      uint off_set[] = {0};

      if(!m_cOpenCL.Execute(def_k_CalcOutputGradient, 1, off_set, NDRange))

         return false;

     }

//---

   return true;

  }
```

The process of distributing the gradient through the hidden layer to the neurons of the previous layer is divided into two sub-processes. In the first buffer, we will adjust the error gradient based on the derivative of the activation function, and in the second one, we will distribute the error gradient values to the neurons of the previous layer according to their influence on the final result. We have created a separate kernel for each sub-process. We placed the correction of the error gradient for the derivative of the activation function into a separate class of the activation function. Therefore, in the CalcHiddenGradient method, we will only have to launch the error gradient distribution kernel in the OpenCL program.

```
bool CNeuronBase::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

//--- adjust the incoming gradient by the derivative of the activation function.

   if(!m_cActivation.Derivative(m_cGradients))

      return false;

//--- check the buffers of the previous layer

   if(!prevLayer)

      return false;

   CBufferType *input_data = prevLayer.GetOutputs();

   CBufferType *input_gradient = prevLayer.GetGradients();

   if(!input_data || !input_gradient ||

      input_data.Total() != input_gradient.Total())

      return false;

//--- check the match between the size of the input data buffer and the weight matrix

   if(!m_cWeights || m_cWeights.Cols() != (input_data.Total() + 1))

      return false;

//--- algorithm branching depending on the operating device

   if(!m_cOpenCL)

     {

      MATRIX grad = m_cGradients.m_mMatrix.MatMul(m_cWeights.m_mMatrix);

      grad.Reshape(input_data.Rows(), input_data.Cols());

      input_gradient.m_mMatrix = grad;

     }
```

Again, at the beginning of the OpenCL block, we check for the availability of previously created buffers in the OpenCL context for the current kernel to work.

```
else // OpenCL block

     {

      //--- check data buffers

      if(m_cWeights.GetIndex() < 0)

         return false;

      if(input_gradient.GetIndex() < 0)

         return false;

      if(m_cGradients.GetIndex() < 0)

         return false;
```

After successfully passing the control block, we will pass the buffer handles and the number of neurons in the layer to the kernel.

```
//--- pass arguments to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcHiddenGradient,

                             def_hidgr_gradient_inputs, input_gradient.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcHiddenGradient, def_hidgr_weights,

                                                             m_cWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcHiddenGradient,def_hidgr_gradients,

                                                          m_cGradients.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_CalcHiddenGradient, def_hidgr_outputs_total,

                                                             m_cGradients.Total()))

         return false;
```

The number of threads in this case will be equal to the number of neurons in the previous layer. We will write their value to the first element of the NDRange array. Let's start kernel operations.

```
//--- put the kernel in the execution queue

      uint NDRange[] = {input_data.Total()};

      uint off_set[] = {0};

      if(!m_cOpenCL.Execute(def_k_CalcHiddenGradient, 1, off_set, NDRange))

         return false;

     }

//---

   return true;

  }
```

After propagating the error gradient across all neurons in our network based on their influence on the final result, the next step is to organize the process of updating the weight matrix. We have divided this process into two sub-processes. The weight matrix will not always be updated after every iteration. Therefore, at each iteration, we calculate the error gradient for each weight and add it to a separate buffer. Upon receiving a command from the main program, we adjust the weight matrix by the size of the batch, which gives us the average value from the accumulated error gradient.

Error gradients are accumulated in the CalcDeltaWeights method. To perform the kernel operations of this method, we need three buffers:

- the buffer of the results of the last direct pass of the previous layer,

- the current layer's gradient buffer,

- the buffer for accumulating weight gradients.

```
bool CNeuronBase::CalcDeltaWeights(CNeuronBase *prevLayer, bool read);

  {

//--- control block

   if(!prevLayer || !m_cDeltaWeights || !m_cGradients)

      return false;

   CBufferType *Inputs = prevLayer.GetOutputs();

   if(!Inputs)

      return false;

//--- algorithm branching depending on the operating device

   if(!m_cOpenCL)

     {

      MATRIX m = Inputs.m_mMatrix;

      m.Resize(1, Inputs.Total() + 1);

      m[0, Inputs.Total()] = 1;

      m = m_cGradients.m_mMatrix.Transpose().MatMul(m);

      m_cDeltaWeights.m_mMatrix += m;

     }
```

First, as usual, we check the availability of used buffers in the OpenCL context.

```
else // OpenCL block

     {

      //--- check data buffers

      if(m_cGradients.GetIndex() < 0)

         return false;

      if(m_cDeltaWeights.GetIndex() < 0)

         return false;

      if(Inputs.GetIndex() < 0)

         return false;
```

We pass the pointers to them to the kernel parameters.

```
//--- pass arguments to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcDeltaWeights,

                              def_delt_delta_weights, m_cDeltaWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcDeltaWeights, def_delt_inputs,

                                                               Inputs.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcDeltaWeights, def_delt_gradients,

                                                         m_cGradients.GetIndex()))

         return false;
```

In this case, we will use a two-dimensional task space to launch the kernel. In one dimension, we specify the number of neurons in the current layer, and in the other dimension, the number of neurons in the previous layer.

After the preparatory work is completed, we will start the kernel execution.

Then we will check the data reading flag and, if necessary, load the result of operations from the context.

And of course, do not forget to monitor the process of performing operations at every step.

```
//--- put the kernel in the execution queue

      uint NDRange[] = {m_cGradients.Total(), Inputs.Total()};

      uint off_set[] = {0, 0};

      if(!m_cOpenCL.Execute(def_k_CalcDeltaWeights, 2, off_set, NDRange))

         return false;

      if(read && !m_cDeltaWeights.BufferRead())

         return false;

     }

//---

   return true;

  }
```

We are successfully moving forward in the process of creating our project. To complete the work on the fully connected neuron, we need to describe the sub-process of updating the weight matrix. In our project, we decided to implement several algorithms for updating the weights. We have created our own kernel for each algorithm for updating the weight matrix. Let's add calls to these kernels to the corresponding methods of our class.

We will start with the stochastic gradient descent method. The implementation of this method requires only two buffers: accumulated deltas and the weight matrix. We check the availability of these buffers in the OpenCL context.

```
bool CNeuronBase::SGDUpdate(int batch_size, TYPE learningRate, VECTOR &Lambda)

  {

//--- algorithm branching depending on the operating device

   if(!m_cOpenCL)

     {

      TYPE lr = learningRate / ((TYPE)batch_size);

      m_cWeights.m_mMatrix -= m_cWeights.m_mMatrix * Lambda[1] + Lambda[0];

      m_cWeights.m_mMatrix += m_cDeltaWeights.m_mMatrix * lr;

      m_cDeltaWeights.m_mMatrix.Fill(0);

     }

   else // OpenCL block

     {

      //--- check data buffers

      if(m_cWeights.GetIndex() < 0)

         return false;

      if(m_cDeltaWeights.GetIndex() < 0)

         return false;
```

Then we will pass pointers to them to the kernel parameters. In addition, we need to transfer training parameters to the kernel:

- batch_size

- learningRate

- Lambda vector (regularization parameters)

```
//--- pass arguments to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_SGDUpdate, def_sgd_delta_weights,

                                                     m_cDeltaWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_SGDUpdate, def_sgd_weights,

                                                          m_cWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_SGDUpdate, def_sgd_total,

                                                        (int)m_cWeights.Total()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_SGDUpdate, def_sgd_batch_size, batch_size))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_SGDUpdate, def_sgd_learningRate,

                                                                   learningRate))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_SGDUpdate, def_sgd_Lambda1, Lambda[0]))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_SGDUpdate, def_sgd_Lambda2, Lambda[1]))

         return false;
```

Let's determine the number of threads to be launched. There will be four times fewer elements in these buffers than in the weight matrix. This effect is achieved through the use of vector operations.

Please note the following while working with the algorithm for determining the number of threads. We can't just divide the number of neurons by four because we can't be sure that the number of neurons will always be a multiple of four. But we must be sure that the number of threads covers all neurons in our layer. So we need a function similar to rounding up to an integer. Instead, we will use the property of integer division to discard the fractional part, in other words, rounding down. To get the result we want, before dividing by the vector size, we'll increase the number of neurons by a value one greater than the vector size. After such a small mathematical trick, the result of integer division will be the required number of threads. When using this trick, you should be particularly careful with the data type used because the desired effect can only be achieved when all variables in the operation are integers.

```
//--- put the kernel in the execution queue

      int NDRange[] = { (int)((m_cWeights.Total() + 3) / 4) };

      int off_set[] = {0};

      if(!m_cOpenCL.Execute(def_k_SGDUpdate, 1, off_set, NDRange))

         return false;

     }

   return true;

  }
```

After the preparatory work, we will request the kernel to be completed.

In the description of the weight matrix update process using the accumulated momentum method, we have an additional buffer for storing moments and a momentum averaging coefficient. For the rest, the principles of constructing the algorithm laid down in the previous method are preserved.

```
bool CNeuronBase::MomentumUpdate(int batch_size, TYPE learningRate,

                                 VECTOR &Beta, VECTOR &Lambda)

  {

   if(Beta[0] == 0)

      return SGDUpdate(batch_size, learningRate, Lambda);

//--- control block

   if(!m_cMomenum[0])

      return false;

   if(m_cMomenum[0].Total() < m_cWeights.Total())

      return false;

//--- algorithm branching depending on the operating device

   if(!m_cOpenCL)

     {

      TYPE lr = learningRate / ((TYPE)batch_size);

      m_cWeights.m_mMatrix -= m_cWeights.m_mMatrix * Lambda[1] + Lambda[0];

      m_cMomenum[0].m_mMatrix = m_cDeltaWeights.m_mMatrix * lr +

                                        m_cMomenum[0].m_mMatrix * Beta[0] ;

      m_cWeights.m_mMatrix += m_cMomenum[0].m_mMatrix;

      m_cDeltaWeights.m_mMatrix.Fill(0);

     }
```

```
else // OpenCL block

     {

      //--- check data buffers

      if(m_cWeights.GetIndex() < 0)

         return false;

      if(m_cDeltaWeights.GetIndex() < 0)

         return false;

      if(m_cMomenum[0].GetIndex() < 0)

         return false;
```

```
//--- pass arguments to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_MomentumUpdate,

                          def_moment_delta_weights, m_cDeltaWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_MomentumUpdate, def_moment_weights,

                                                         m_cWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_MomentumUpdate,

                                 def_moment_momentum, m_cMomenum[0].GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_MomentumUpdate, def_moment_total,

                                                        (int)m_cWeights.Total()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_MomentumUpdate, def_moment_batch_size,

                                                                    batch_size))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_MomentumUpdate, def_moment_learningRate,

                                                                  learningRate))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_MomentumUpdate, def_moment_Lambda1,

                                                                     Lambda[0]))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_MomentumUpdate, def_moment_Lambda2,

                                                                     Lambda[1]))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_MomentumUpdate, def_moment_beta, Beta[0]))

         return false;
```

We will set the number of threads to 4 times less than the number of elements in the weight matrix and start performing operations.

```
//--- put the kernel in the execution queue

      int NDRange[] = { (int)((m_cWeights.Total() + 3) / 4) };

      int off_set[] = {0};

      if (! m_copencl. Execute (def_k_momentumUpdate, 1, off_set, ndRange))

         return false;

     }

   return true;

  }
```

Please note the constants used in kernels and their parameters. Despite the similarity of operations, a small detail or a typo with a constant can often lead to a critical error and program termination.

Let's move on to the next implementation. The AdaGrad optimization method is implemented in the AdaGradUpdate method and in the respective kernel, which we will identify by the def_k_AdaGradUpdate constant. To avoid possible errors when specifying parameters, all parameter constants for this kernel start with def_adagrad_. As you can see, all constant names are intuitive and logically connected. This reduces the risk of a possible error. This method is very convenient when there are a large number of constants.

The AdaGrad method, like the cumulative pulse method, uses a moment accumulation buffer. However, unlike the previous method, there is no averaging factor here. At this point, we don't care about differences in the use of parameters and buffers. We are only interested in their availability: the use of buffers and parameters is already described in the OpenCL program kernel, and here we organize the process of transferring data from the main program to the OpenCL context.

The algorithm for organizing the process of working with the OpenCL context in the AdaGradUpdate method is similar to that used in the methods described earlier.

- First, check for buffers in the OpenCL context.

- Then we will send pointers to buffers and optimization parameters to the kernel.

- Start kernel execution.

```
bool CNeuronBase::AdaGradUpdate(int batch_size, TYPE learningRate, VECTOR &Lambda)

  {

//--- control block

   if(!m_cMomenum[0])

      return false;

   if(m_cMomenum[0].Total() < m_cWeights.Total())

      return false;

//--- algorithm branching depending on the operating device

   if(!m_cOpenCL)

     {

      m_cWeights.m_mMatrix -= m_cWeights.m_mMatrix * Lambda[1] + Lambda[0];

      MATRIX delta = m_CDeltaWeights . m_mMatrix /((TYPE) batch_size);

      MATRIX G = m_cMomenum[0].m_mMatrix = m_cMomenum[0].m_mMatrix + delta.Power(2);

      G = MathPow(MathSqrt(G) + 1e-32, -1);

      G = G * learningRate;

      m_cWeights.m_mMatrix += G * delta;

       m_cDeltaWeights.m_mMatrix.Fill(0);

    }
```

```
else // OpenCL block

     {

      //--- check data buffers

      if(m_cWeights.GetIndex() < 0)

         return false;

      if(m_cDeltaWeights.GetIndex() < 0)

         return false;

      if(m_cMomenum[0].GetIndex() < 0)

         return false;
```

```
//--- pass arguments to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdaGradUpdate,

                           def_adagrad_delta_weights, m_cDeltaWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdaGradUpdate, def_adagrad_weights,

                                                           m_cWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdaGradUpdate, def_adagrad_momentum,

                                                        m_cMomenum[0].GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdaGradUpdate, def_adagrad_total,

                                                          (int)m_cWeights.Total()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdaGradUpdate, def_adagrad_batch_size,

                                                                      batch_size))

         return false;

      if (! m_copencl. SetArgument (Def_K_AdaGradUpdate, Def_Adagrad_LearningRate,

                                                                    learningRate))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdaGradUpdate, def_adagrad_Lambda1,

                                                                       Lambda[0]))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdaGradUpdate, def_adagrad_Lambda2,

                                                                       Lambda[1]))

         return false;
```

```
//--- put the kernel in the execution queue

      int NDRange[] = { (int)((m_cWeights.Total() + 3) / 4) };

      int off_set[] = {0};

      if(!m_cOpenCL.Execute(def_k_AdaGradUpdate, 1, off_set, NDRange))

         return false;

     }

   return true;

  }
```

The RMSProp optimization method is functionally similar to AdaGrad, but it includes a coefficient for averaging the accumulated momentum.

We're following the established framework: check the availability of OpenCL context buffers, then send pointers to buffers and optimization parameters to the kernel while also ensuring the use of the proper method and constant naming:

- RMS PropUpdate method

- def_k_ RMSPropUpdate kernel constant

- def_rms_ parameter constants

After specifying the parameters, launch the kernel.

```
bool CNeuronBase::RMSPropUpdate(int batch_size, TYPE learningRate,

                                VECTOR &Beta, VECTOR &Lambda)

  {

//--- control block

   if(!m_cMomenum[0])

      return false;

   if(m_cMomenum[0].Total() < m_cWeights.Total())

      return false;

//--- algorithm branching depending on the operating device

   if(!m_cOpenCL)

     {

      TYPE lr = learningRate;

      m_cWeights.m_mMatrix -= m_cWeights.m_mMatrix * Lambda[1] + Lambda[0];

      MATRIX delta = m_CDeltaWeights . m_mMatrix /((TYPE) batch_size);

      MATRIX G = m_cMomenum[0].m_mMatrix = m_cMomenum[0].m_mMatrix * Beta[0] +

                                                delta.Power(2) * (1 - Beta[0]);

      G = MathPow(MathSqrt(G) + 1e-32, -1);

      G = G * learningRate;

      m_cWeights.m_mMatrix += G * delta;

      m_cDeltaWeights.m_mMatrix.Fill(0);

     }
```

```
else // OpenCL block

     {

      //--- check data buffers

      if(m_cWeights.GetIndex() < 0)

         return false;

      if(m_cDeltaWeights.GetIndex() < 0)

         return false;

      if(m_cMomenum[0].GetIndex() < 0)

         return false;
```

```
//--- pass arguments to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_RMSPropUpdate, def_rms_delta_weights,

                                                      m_cDeltaWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_RMSPropUpdate, def_rms_weights,

                                                           m_cWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_RMSPropUpdate, def_rms_momentum,

                                                        m_cMomenum[0].GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_RMSPropUpdate, def_rms_total,

                                                          (int)m_cWeights.Total()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_RMSPropUpdate, def_rms_batch_size,

                                                                      batch_size))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_RMSPropUpdate, def_rms_learningRate,

                                                                    learningRate))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_RMSPropUpdate, def_rms_Lambda1, Lambda[0]))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_RMSPropUpdate, def_rms_Lambda2, Lambda[1]))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_RMSPropUpdate, def_rms_beta, Beta[0]))

         return false;
```

```
//--- put the kernel in the execution queue

      int NDRange[] = { (int)((m_cWeights.Total() + 3) / 4) };

      int off_set[] = {0};

      if(!m_cOpenCL.Execute(def_k_RMSPropUpdate, 1, off_set, NDRange))

         return false;

     }

//---

   return true;

  }
```

The developers of the AdaDelta method opted to not use a learning rate but compensated for it by introducing an additional buffer for moments with an additional averaging coefficient. Accordingly, we will use one more buffer in this kernel.

When setting kernel parameters, again, mind the naming:

- AdaDeltaUpdate method

- def_k_AdaDeltaUpdate kernel constant

- def_adadelt parameter constants

Furthermore, for seamless portability of the constructed neural network, we need to ensure the consistency of buffer usage in terms of performing operations using MQL5 and in the OpenCL context. When used within the same platform, changing the sequence in which the momentum arrays are used will not have an effect. Whatever we call them, their content will be appropriate to the context of use. However, when transferring a pre-trained neural network to another platform, we will likely get unexpected results. At the same time, we should remember the purpose and functionality of arrays. The moments are only used during the weight matrix update process in the training of the neural network and do not participate in the feed-forward pass. So, the impact of mixed-up buffers will only become apparent when attempting to retrain the neural network. This should not be neglected. If we use a once built neural network for a long time, we will need to periodically refine it. This is necessary to keep weights relevant in our changing world.

Taking into account the above, we will pass pointers to the loaded buffers and training parameters to the kernel.

Let's calculate the number of required threads and launch the kernel.

```
bool CNeuronBase::AdaDeltaUpdate(int batch_size, VECTOR &Beta, VECTOR &Lambda)

  {

//--- control block

   for(int i = 0; i < 2; i++)

     {

      if(!m_cMomenum[i])

         return false;

      if(m_cMomenum[i].Total() < m_cWeights.Total())

         return false;

     }

//--- algorithm branching depending on the operating device

   if(!m_cOpenCL)

     {

      MATRIX delta = m_CDeltaWeights . m_mMatrix /((TYPE) batch_size);

      MATRIX W = m_cMomenum[0].m_mMatrix = m_cMomenum[0].m_mMatrix * Beta[0] +

                                  m_cWeights.m_mMatrix.Power(2) * (1 - Beta[0]);

      m_cMomenum[1].m_mMatrix = m_cMomenum[1].m_mMatrix * Beta[1] +

                                                 delta.Power(2) * (1 - Beta[1]);

      m_cWeights.m_mMatrix -= m_cWeights.m_mMatrix * Lambda[1] + Lambda[0];

      W = MathSqrt(W) / (MathSqrt(m_cMomenum[1].m_mMatrix) + 1e-32);

      m_cWeights.m_mMatrix += W * delta;

      m_cDeltaWeights.m_mMatrix.Fill(0);

     }
```

```
else // OpenCL block

     {

      //--- create data buffers

      if(m_cWeights.GetIndex() < 0)

         return false;

      if(m_cDeltaWeights.GetIndex() < 0)

         return false;

      if(m_cMomenum[0].GetIndex() < 0)

         return false;

      if(m_cMomenum[1].GetIndex() < 0)

         return false;
```

```
//--- pass arguments to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdaDeltaUpdate,

                           def_adadelt_delta_weights, m_cDeltaWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdaDeltaUpdate, def_adadelt_weights,

                                                           m_cWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdaDeltaUpdate, def_adadelt_momentumW,

                                                        m_cMomenum[0].GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdaDeltaUpdate, def_adadelt_momentumG,

                                                        m_cMomenum[1].GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdaDeltaUpdate, def_adadelt_total,

                                                          (int)m_cWeights.Total()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdaDeltaUpdate, def_adadelt_batch_size,

                                                                      batch_size))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdaDeltaUpdate, def_adadelt_Lambda1,

                                                                       Lambda[0]))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdaDeltaUpdate, def_adadelt_Lambda2,

                                                                       Lambda[1]))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdaDeltaUpdate, def_adadelt_beta1, Beta[0]))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdaDeltaUpdate, def_adadelt_beta2, Beta[1]))

         return false;
```

```
//--- put the kernel in the execution queue

      int NDRange[] = { (int)((m_cWeights.Total() + 3) / 4) };

      int off_set[] = {0};

      if(!m_cOpenCL.Execute(def_k_AdaDeltaUpdate, 1, off_set, NDRange))

         return false;

     }

//---

   return true;

  }
```

Our description of the operations performed in the fully connected neural layer is nearing completion. One method remains to be described, and it's the weight update method — specifically, the Adam optimization algorithm. This method, though the last on the list, is not of lesser importance. Like AdaDelta, the Adam method also employs two momentum buffers, but in addition, it returns the learning rate.

Let's recap the main stages of our algorithm and highlight key checkpoints:

- Verify the presence of the necessary data in the OpenCL context memory.

- Pass pointers to data buffers and training parameters to the kernel. Ensure naming consistency: Method AdamUpdate а kernel constant def_k_AdamUpdate а parameter constants def_adam_...

- Monitor the consistent use of buffers between MQL5 and the OpenCL context.

- Execute the kernel.

```
bool CNeuronBase::AdamUpdate(int batch_size, TYPE learningRate,

                             VECTOR &Beta, VECTOR &Lambda)

  {

//--- control block

   for(int i = 0; i < 2; i++)

     {

      if(!m_cMomenum[i])

         return false;

      if(m_cMomenum[i].Total() != m_cWeights.Total())

         return false;

     }

//--- algorithm branching depending on the operating device

   if(!m_cOpenCL)

     {

      MATRIX delta = m_CDeltaWeights . m_mMatrix /((TYPE) batch_size);

      m_cMomenum[0].m_mMatrix = m_cMomenum[0].m_mMatrix * Beta[0] +

                                                      delta * (1 - Beta[0]);

      m_cMomenum[1].m_mMatrix = m_cMomenum[1].m_mMatrix * Beta[1] +

                                           MathPow(delta,2) * (1 - Beta[1]);

      MATRIX M = m_cMomenum[0].m_mMatrix / (1 - Beta[0]);

      MATRIX V = m_cMomenum[1].m_mMatrix / (1 - Beta[1]);

      m_cWeights.m_mMatrix -= m_cWeights.m_mMatrix * Lambda[1] + Lambda[0];

      m_cWeights.m_mMatrix += M * learningRate  / MathSqrt(V);

      m_cDeltaWeights.m_mMatrix.Fill(0);

     }
```

```
else // OpenCL block

     {

      //--- check data buffers

      if(m_cWeights.GetIndex() < 0)

         return false;

      if(m_cDeltaWeights.GetIndex() < 0)

         return false;

      if(m_cMomenum[0].GetIndex() < 0)

         return false;

      if(m_cMomenum[1].GetIndex() < 0)

         return false;
```

```
//--- pass arguments to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdamUpdate, def_adam_delta_weights,

                                                    m_cDeltaWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdamUpdate, def_adam_weights,

                                                         m_cWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdamUpdate, def_adam_momentumM,

                                                      m_cMomenum[0].GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdamUpdate, def_adam_momentumV,

                                                      m_cMomenum[1].GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdamUpdate, def_adam_total,

                                                       (int)m_cWeights.Total()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdamUpdate, def_adam_batch_size,

                                                                    batch_size))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdamUpdate, def_adam_Lambda1, Lambda[0]))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdamUpdate, def_adam_Lambda2, Lambda[1]))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdamUpdate, def_adam_beta1, Beta[0]))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdamUpdate, def_adam_beta2, Beta[1]))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AdamUpdate, def_adam_learningRate,

                                                                  learningRate))

         return false;
```

```
//--- put the kernel in the execution queue

      int NDRange[] = { (int)((m_cWeights.Total() + 3) / 4) };

      int off_set[] = {0};

      if(!m_cOpenCL.Execute(def_k_AdamUpdate, 1, off_set, NDRange))

         return false;

     }

//---

   return true;

  }
```

We have completed a description of the processes of a fully connected neural layer. Now, we've reached the stage where we can look at the work done and assess the initial results. In fact, we already have enough created base classes to build a small perceptron model with several fully connected layers. One of them will serve as the receiver of input data (input layer), the last neural layer will produce the results (output layer), and hidden layers will be in between.
