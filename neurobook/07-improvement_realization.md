# Chapter 07: Improving Model Convergence

*Source: [https://www.mql5.com/en/neurobook/index/improvement_realization](https://www.mql5.com/en/neurobook/index/improvement_realization)*

---

## Architectural solutions for improving model convergence

We have discussed several different architectural solutions for neural layers. We have created classes to implement the discussed architectural solutions and small models using them. However, in the process of studying neural networks, we cannot bypass the issue of improving neural network convergence. We have considered [theoretical aspects](https://www.mql5.com/en/neurobook/index/about_ai/improvement) of such practices but have not yet implemented them in any model.

In this chapter, we dive deeper into the construction and application of architectural solutions improving the convergence of neural networks, such as Batch Normalization and Dropout techniques. Regarding [batch normalization](https://www.mql5.com/en/neurobook/index/improvement_realization/batch_norm), we start by examining its basic principles, then proceed to a detailed discussion of creating a [batch normalization class using the MQL5 programming language](https://www.mql5.com/en/neurobook/index/improvement_realization/batch_norm/batch_norm_mql), including forward and backward pass methods, as well as file handling methods. The section also covers [multi-threaded computing](https://www.mql5.com/en/neurobook/index/improvement_realization/batch_norm/batch_norm_opencl) in the context of batch normalization and provides the implementation of this approach in Python, including the creation of a script for testing. An important part of the discussion is the [comparative testing of models using batch normalization](https://www.mql5.com/en/neurobook/index/improvement_realization/batch_norm/batch_norm_comparison), showing the practical effectiveness of the approaches considered.

Moving on to the topic of [Dropout](https://www.mql5.com/en/neurobook/index/improvement_realization/dropout_realization), we will examine its implementation in MQL5, including feed-forward, backpropagation and file handling methods. We will see multi-threaded operations for the Dropout mechanism and its [implementation in Python](https://www.mql5.com/en/neurobook/index/improvement_realization/dropout_realization/dropout_py). As we close this chapter, we will conduct [comparative testing of models using Dropout](https://www.mql5.com/en/neurobook/index/improvement_realization/dropout_realization/dropout_comparison) and see the impact of this technique on the convergence and efficiency of neural networks. Thus, we will not only study the theoretical aspects but will also practically apply them to improve the performance and convergence of models.

## Batch normalization

One such practice is [batch normalization](https://www.mql5.com/en/neurobook/index/about_ai/improvement/normalization). It's worth noting that data normalization is quite common in neural network models in various forms. Remember when we created our first fully connected perceptron model, one of the tests involved comparing the model performance on the training dataset with normalized and non-normalized data. Testing showed the advantage of using normalized data.

We also encountered data normalization when studying attention models. The Self-Attention mechanism uses data normalization at the output of the Attention block and at the output of the Feed Forward block. The difference from the previous normalization is in the area of data normalization. In the first case, we took each individual parameter and normalized its values with respect to historical data, while in the second case, we didn't look at the history of values for a single indicator; on the contrary, we took all the indicators at the current moment and normalized their values within the context of the current state. We can say that the data was normalized along the time interval and across it. The first option refers to batch data normalization, and the second is called Layer Normalization.

However, there are other possible uses for data normalization. Let me remind you of the main problem solved by data normalization. Consider a fully connected perceptron with two hidden layers. With a forward pass, each layer generates a set of data that serves as a training sample for the next layer. The output layer result is compared with reference data, and during the backpropagation pass, the error gradient is propagated from the output layer through the hidden layers to the input data. Having obtained the error gradient on each neuron, we update the weights, adjusting our neural network to the training samples from the last forward pass. Here lies a conflict: we are adapting the second hidden layer to the data output of the first hidden layer, while by changing the parameters of the first hidden layer, we have already altered the data array. That is, we adjust the second hidden layer to the dataset that no longer exists. A similar situation arises with the output layer, which adapts to the already altered output of the second hidden layer. If you also consider the distortion between the first and second hidden layers, the error scales increase. Furthermore, the deeper the neural network, the stronger the manifestation of this effect. This phenomenon is called the internal covariance shift.

 

In classical neural networks, the mentioned problem was partially addressed by reducing the learning rate. Small changes in the weights do not significantly change the distribution of the dataset at the output of the neural layer. However, this approach does not solve the problem of scaling with an increase in the number of layers in the neural network as it reduces the learning rate. Another problem with a low learning rate is the risk of getting stuck in local minima.

In February 2015, Sergey Ioffe and Christian Szegedy proposed a Batch Normalization method to solve the problem of internal covariance shift. The idea of the method was to normalize each individual neuron on a certain time interval with the median of the sample shifting to zero and scaling the dataset variance to one.

Experiments conducted by the method authors demonstrate that the use of the Batch Normalization method also acts as a regularizer. With this, there is no need to use other regularization methods, in particular Dropout. Moreover, there are more recent studies that show that the combined use of Dropout and Batch Normalization adversely affects the training results of a neural network.

In modern neural network architectures, variations of the proposed normalization algorithm can be found in various forms. The authors suggest using Batch Normalization immediately before non-linearity (activation formula).

## Comparative testing of models using batch normalization

We have done a lot of work together and created a new class for batch normalization implementation. Its main purpose is to solve the internal covariance shift problem. As a result, the model should learn faster and the results should become more stable. Let's do some experiments and see if that's the case.

First, we will test the model using our class written in MQL5. For experiments, we will use very simple models that consist of only fully connected layers.

In the first experiment, we will try to use a batch normalization layer instead of pre-normalization in the data preparation stage. This approach will reduce the cost of data preparation both for model training and during commercial operation. In addition, the inclusion of normalization in the model allows it to be used with real-time data streams. This is how stock quotes are delivered, and processing them in real-time gives you an advantage.

To test the approach, we will create a script that uses one fully connected hidden layer and a fully connected layer as the neural layer of the results. Between the hidden layer and the initial data layer, we will set up a batch normalization layer.

The task is clear, so let's move on to practical implementation. To create the script, we will use the script from the first test of a fully connected perceptron [perceptron test.mq5](https://www.mql5.com/en/neurobook/index/realization/realizations_comparison) as a base. Let's create a copy of the file with the name perceptron_test_norm.mq5.

At the beginning of the script are the external parameters. We will transfer them to the new script without any changes.

```
//+------------------------------------------------------------------+

//| External parameters for script operation                         |

//+------------------------------------------------------------------+

// Name of the file with the training sample

input string   StudyFileName = "study_data_not_norm.csv";

// File name for recording the error dynamics

input string   OutputFileName = "loss_study_vs_norm.csv";

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

input int      HiddenLayers   =  1;

// Number of neurons in one hidden layer

input int      HiddenLayer    =  40;

// Number of iterations of updating the weights matrix

input int      Epochs         =  1000;
```

In the script, we will only make changes to the CreateLayersDesc function that serves to specify the model architecture. In the parameters, this function receives a pointer to a dynamic array object, which we are to fill with descriptions of the neural layers to be created. To exclude possible misunderstandings, let's clear the obtained dynamic array immediately.

```
bool CreateLayersDesc(CArrayObj &layers)

  {

   layers.Clear();

   CLayerDescription *descr;

//--- creating initial data layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }
```

First, we create a layer to receive the initial data. Before passing the description of the layer to be created, we must create an instance of the neural layer description object CLayerDescription. We create an instance of the object and immediately check the result of the operation. Please note that in case of an error, we display a message to the user, then we delete the dynamically created array object that was created earlier and only then terminate the program execution.

When the object is successfully created, we begin populating it with the desired content. For the initial data neural layer, we specify the basic type of a fully connected neural layer with zero initial data window without activation function and parameter optimization. We specify the number of neurons to be sufficient to receive the entire sequence of the pattern description. In this case, the number is equal to the product of the number of neurons in the pattern description by the number of elements in one candlestick description.

```
descr.type         = defNeuronBase;

   int prev =

      descr.count     = NeuronsToBar * BarsToLine;

   descr.window       = 0;

   descr.activation   = AF_NONE;

   descr.optimization = None;
```

Once all the parameters of the created neural layer are specified, we add our neural layer description object to the dynamic array of the model architecture description and immediately check the result of the operation.

```
if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }
```

After adding the description of a neural layer to the dynamic array, we proceed to the description of the next neural layer. Again, we create a new instance of the neural layer description object and check the result of the operation.

```
//--- batch normalization layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }
```

The second layer of the model will be the batch normalization layer. We will tell the model about this by specifying an appropriate constant in the type field. We specify the number of neurons and the size of the initial data window according to the size of the previous neuron layer. A new batch size parameter is added for the batch normalization layer. For this parameter, we will specify a value equal to the batch size between updates of the batch parameters. We do not use the activation function, but we specify a method to optimize the Adam parameters.

```
descr.type = defNeuronBatchNorm;

   descr.count = prev;

   descr.window = descr.count;

   descr.batch = BatchSize;

   descr.activation = AF_NONE;

   descr.optimization = Adam;
```

After specifying all the necessary parameters of the new neural layer, we add it to the dynamic array of the model architecture description. As always, we check the result of the operation.

```
if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }
```

Next in our model, there is a block of hidden layers. The number of hidden layers is specified in the external script parameters by the user. All hidden layers are basic fully connected layers with the same number of neurons, which is specified in the external parameters of the script. Therefore, to create all the hidden neural layers, you only need one description object for the neural layer, which can be added multiple times to the dynamic array describing the model architecture.

Hence, the next step is to create a new instance of the neural layer description object and check the result of the operation.

```
//--- block of hidden layers

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }
```

After creating the object, we fill it with the necessary values. Also, we specify the base type of the neuron layer defNeuronBase. The number of elements in the neural layer is transferred from the external parameter of the HiddenLayer script. We will use Swish as the activation function and Adam as the parameter optimization method.

```
descr.type         = defNeuronBase;

   descr.count        = HiddenLayer;

   descr.activation   = AF_SWISH;

   descr.optimization = Adam;

   descr.activation_params[0] = 1;
```

Once sufficient information is provided for creating a neural layer, we organize a loop with the number of iterations equal to the number of hidden layers. Within the loop, we will add the created description of the hidden neural layer to the dynamic array describing the model architecture. At the same time, don't forget to control the process of adding the description object to the array at each iteration.

```
for(int i = 0; i < HiddenLayers; i++)

      if(!layers.Add(descr))

        {

         PrintFormat("Error adding layer: %d", GetLastError());

         delete descr;

         return false;

        }
```

In conclusion of the model description, you need to add the description of the output neural layer. For this, we create another instance of the neural layer description object and immediately check the result of the operation.

```
//--- layer of results

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }
```

After creating the object, we fill it with the description of the neural layer to be created. For the output layer, you can use the basic type of fully connected neural layer with two elements (corresponding to the number of target values for the pattern). We use the linear activation function and the Adam optimization method as we did for the other model layers.

```
descr.type         = defNeuronBase;

   descr.count        = 2;

   descr.activation   = AF_LINEAR;

   descr.optimization = Adam;

   descr.activation_params[0] = 1;
```

Add the prepared description of the neural layer to the dynamic array describing the architecture of the model.

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

And of course, don't forget to check the result of the operation

This concludes our work on building the script to run the first test, while the rest of the script code is transferred to this one in an unchanged form. We will run the script on the previously prepared training dataset. I will remind you that for the purity of experiments, all models within this book are trained on a single training dataset. This applies to models created in the MQL5 environment and those written in Python.

From the test results presented in the figures below, it can be confidently stated that the use of batch normalization layers can effectively replace the preprocessing normalization procedure at the data preparation stage.

The direct impact of batch normalization layers can be assessed by comparing the error dynamics graph of a model without a batch normalization layer when trained on a non-normalized training dataset. The gap between the charts is enormous.

Batch normalization of initial data

At the same time, differences in the error dynamics graphs of the model during training on normalized data and on non-normalized data with the use of batch normalization layers may only become apparent when you zoom in on the graph. Only at the beginning of training, there is a gap between the performance of the models. As training iterations increase, the accuracy gap of the models shrinks dramatically. After 200 iterations, the model using the normalization layer shows even better performance. This further confirms the possibility of including batch normalization layers in a model for real-time data normalization, providing additional evidence of its effectiveness.  

Batch normalization of initial data

We performed a similar experiment with models created in Python. This experiment confirmed the earlier findings.

Batch normalization of initial data (MSE)

Batch normalization of initial data (MSE)

Batch normalization of initial data (Accuracy)

Batch normalization of initial data (Accuracy)

Furthermore, within the scope of this experiment, the model using batch normalization layers demonstrated slightly better results both on the training dataset and during validation.

The analysis of the graph for the Accuracy metric suggests similar conclusions.

The second and probably the main option for using a batch normalization layer is to put the batch normalization layer before the hidden layers. The authors proposed using this method in exactly this way to address the problem of internal covariate shift. To test the effectiveness of this approach, let's create a copy of our script with the name perceptron_test_norm2.mq5. We will make small changes in the block of creating hidden layers. This is because, in the new script, we need to alternate between fully connected hidden layers and batch normalization layers, so we will include the creation of batch normalization layers within the loop.

```
//--- Batch Normalization Layer

   CLayerDescription *norm = new CLayerDescription();

   if(!norm)

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }

   norm.type = defNeuronBatchNorm;

   norm.count = prev;

   norm.window = descr.count;

   norm.batch = BatchSize;

   norm.activation = AF_NONE;

   norm.optimization = Adam;

//--- Hidden layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      delete norm;

      return false;

     }

   descr.type         = defNeuronBase;

   descr.count        = HiddenLayer;

   descr.activation   = AF_SWISH;

   descr.optimization = Adam;

   descr.activation_params[0] = 1;

   for(int i = 0; i < HiddenLayers; i++)

     {

      if(!layers.Add(norm))

        {

         PrintFormat("Error adding layer: %d", GetLastError());

         delete descr;

         delete norm;

         return false;

        }

      CLayerDescription *temp = new CLayerDescription();

      if(!temp)

        {

         PrintFormat("Error creating CLayerDescription: %d", GetLastError());

         delete descr;

         return false;

        }

      temp.Copy(norm);

      norm = temp;

      norm.count = descr.count;

      if(!layers.Add(descr))

        {
```

Otherwise, the script remains unchanged.

Testing of the script operation fully confirmed the earlier conclusions. Initially, when trained on non-normalized data, the model with batch normalization takes a little time to adapt. However, the gap in the accuracy of the models is shrinking dramatically.

Batch normalization before the hidden layer

With a closer look, it becomes clear that the model with three hidden layers and batch normalization layers before each hidden layer even performs better on non-normalized input data. At the same time, its error dynamics graph decreases at a faster rate compared to the rest of the models.

Batch normalization before the hidden layer

Batch normalization before the hidden layer (MSE)

Conducting a similar experiment with models created in Python also confirms that models using batch normalization layers before each hidden layer, under otherwise equal conditions, train faster and are less prone to overfitting.

The dynamics of changes in the Accuracy metric value also confirms the earlier conclusions.

Additionally, we validated the models on a test dataset to evaluate the performance using new data. The results obtained showed a fairly smooth performance of all four models. The divergence of the RMS error of the models did not exceed 5*10-3. Only a slight advantage was shown by models with three hidden layers.

Evaluation of the models using the Accuracy metric showed similar results.

Batch normalization before the hidden layer (Accuracy)

Testing the effectiveness of batch normalization on new data

Testing the effectiveness of batch normalization on new data

To conclude, I decided to perform one more test. The authors of the method claim that the use of a batch normalization layer can increase the learning rate to speed up the process. Let's test this statement. We will run the perceptron_test_norm2.mq5 script again, but this time increase the learning rate by 10 times.

Testing has shown the potential effectiveness of this approach. In addition to a faster learning process, we got a better learning result than the previous ones.

Batch normalization before the hidden layer with increased learning rate

Batch normalization before the hidden layer with increased learning rate

In this section, we conducted a series of training tests for various models using batch normalization layers and without them. The obtained results demonstrated that a batch normalization layer after the input data can replace the normalization process at the data preparation stage for training. This approach allows the data normalization process to be built into the model and tuned during model training. In this way, we can process the initial data in real-time during the operation of the model without complicating the overall decision-making program.

In addition, using a batch normalization layer before the hidden model layers can speed up the learning process, all other things being equal.

## Building a batch normalization class in MQL5

After considering the theoretical aspects of the normalization method, we will move on to its practical implementation within our library. To do this, we will create a new CNeuronBatchNorm class derived from the CNeuronBase base class of the fully connected neural layer.

To ensure the full functionality of our class, we need to add a few things. We will add just one buffer for recording normalization parameters for each element of the sequence and a variable to store the batch size for normalization. For the rest, we will use base class buffers with minor amendments. We will talk about them during the implementation of the methods.

```
class CNeuronBatchNorm    :  public CNeuronBase

  {

protected:

   CBufferType       m_cBatchOptions;

   uint              m_iBatchSize;       // batch size

public:

                     CNeuronBatchNorm(void);

                    ~CNeuronBatchNorm(void);

   //---

   virtual bool      Init(const CLayerDescription* description) override;

   virtual bool      SetOpenCL(CMyOpenCL *opencl) override;

   virtual bool      FeedForward(CNeuronBase* prevLayer) override;

   virtual bool      CalcHiddenGradient(CNeuronBase* prevLayer) override;

   virtual bool      CalcDeltaWeights(CNeuronBase* prevLayer, bool read) override;

   //--- methods for working with files

   virtual bool      Save(const int file_handle) override;

   virtual bool      Load(const int file_handle) override;

   //--- object identification method

   virtual int       Type(void)  override   const { return(defNeuronBatchNorm); }

  };
```

We'll be redefining the same set of basic methods:

- Init — method for initializing a class instance

- FeedForward — feed-forward method

- CalchiddenGradient — method of distributing error gradients through a hidden layer

- CalcDeltaWeights — method for distributing error gradients to the weight matrix

- Save — method for saving neural layer parameters

- Load — method for restoring the neural layer performance from the saved data

Let's start working on the class with its constructor. In this method, we only set an initial value for the normalization batch size. The class destructor remains empty.

```
CNeuronBatchNorm::CNeuronBatchNorm(void)  :  m_iBatchSize(1)

  {

  }
```

After that, we move on to working on the class initialization method. But before we start implementing this method, let's pay attention to the nuances of our implementation.

First of all, the normalization method does not involve changing the number of elements. The output of the neural layer will have the same number of neurons as the input. Therefore, the size of the source data window should be equal to the number of neurons in the layer being created. Of course, we can ignore the source data window size parameter and only use the number of neurons in the layer. However, in this case, we would lose additional control during the neural layer initialization stage and would have to constantly check whether the number of neurons matches during each feed-forward and backpropagation pass.

The second point is related to the lack of a matrix of weights in our usual form. Let's look at mathematical formulas again.

To calculate the normalized value, we use only the mean and standard deviation, which are calculated for the dataset and do not have adjustable parameters. We have only two configurable parameters when we shift and scale the values of γ and β. Both parameters are selected individually for each value from the source data tensor.

Now let's remember the mathematical formula for a displaced neuron.

Don't you think that when N = 1, the formulas will look identical? We will use this similarity.

Now let's get back to our method of initializing an object instance. This method is virtual and inherits from the parent class. According to the rules of inheritance, this method stores the return type and the list of method parameters. The parameters of our method contain only one pointer to the object describing the neural layer being created.

In the body of the method, we immediately check the received pointer to the description object of the created neural layer, while also simultaneously verifying the correspondence between the size of the input data window and the number of neurons in the created layer. We discussed this point a little earlier.

After successfully checking the obtained object, we change the size of the initial data window by one in accordance with the similarity shown above. Now we call the parent class initialization method, remembering to check the results of the operations.

```
bool CNeuronBatchNorm::Init(const CLayerDescription *description)

  {

   if(!description ||

      description.window != description.count)

      return false;

   CLayerDescription *temp = new CLayerDescription();

   if(!temp || !temp.Copy(description))

      return false;

   temp.window = 1;

   if(!CNeuronBase::Init(temp))

      return false;

   delete temp;
```

It should be noted here that during the initialization of the parent class, the weight matrix is initialized with random values. However, for batch normalization, the recommended initial values are 1 for the scaling coefficient γ and 0 for the offset β. As an experiment, we can leave it as it is, or we can fill the weight matrix buffer now.

```
//--- initialize the training parameter buffer

   if(!m_cWeights.m_mMatrix.Fill(0))

      return false;

   if(!m_cWeights.m_mMatrix.Col(VECTOR::Ones(description.count), 0))

      return false;
```

After successfully initializing the objects of the parent class, we proceed to create objects and specify initial values for the variables and constants of the new class.

First, we initialize the normalization parameter buffer. In this buffer, we need three elements for each element in the sequence. There we will save:

- μ — average value from previous iterations of the forward pass.

- σ 2 — dataset variance over previous iterations of the forward pass.

-  — normalized value before scaling and shifting.

I deliberately numbered the values starting from 0. This is exactly the indexing that values in our data buffer will get. At the initial stage, we initialize the entire buffer with zero values and check the results of the operations.

```
//--- initialize the normalization parameter buffer

   if(!m_cBatchOptions.BufferInit(description.count, 3, 0))

      return false;

   if(!m_cBatchOptions.Col(VECTOR::Ones(description.count), 1))

      return false;
```

At the end of the initialization method of our class, we save the batch normalization size into a specially created variable. We then exit the method with a positive result.

```
m_iBatchSize = description.batch;

//---

   return true;

  }
```

At this point, we conclude our work with the auxiliary initialization methods and move on to building the algorithms for the class. As always, we will begin this work by constructing a method for the feed-forward pass.

## Organizing multi-threaded computations in the batch normalization class

We continue working on our batch normalization class CNeuronBatchNorm. In the previous sections, we have already fully implemented the functionality of the class using standard MQL5 tools. In order to complete the work on the class, according to our concept, it remains to supplement its functionality with the ability to perform multi-threaded mathematical operations using OpenCL. Recall, the implementation of this functionality can be roughly divided into two sub-processes:

- Create an OpenCL program.

- Modify the methods of the main program to organize data exchange with the context and call the OpenCL program.

Let's start by creating the OpenCL program. First, we implement the BatchNormFeedForward forwards pass kernel. In the parameters, we pass pointers to four buffers and two constants to the kernel:

- inputs — buffer of raw data (previous layer results)

- options — normalization parameter buffer

- weights — trainable parameter matrix buffer (named after the class buffer)

- output — result buffer

- batch — size of the normalization batch

- total — size of the result buffer

```
__kernel void BatchNormFeedForward(__global TYPE *inputs,

                                   __global TYPE *options,

                                   __global TYPE *weights,

                                   __global TYPE *output,

                                   int batch,

                                   int total)

  {
```

The last parameter is necessary because we use vector variables of TYPE4 type to optimize the computation process. This approach allows parallel computing not at the software level, but at the microprocessor level. The use of a vector of four elements of type double allows you to fully fill a 256-bit microprocessor register and perform calculations on the entire vector in a single clock cycle. Thus, in one clock cycle of the microprocessor, we perform operations on four elements of our data array. OpenCL supports vector variables of 2, 3, 4, 8, and 16 elements. Before choosing a vector dimension, please check the specifications of your hardware.

In the kernel body, we immediately identify the current thread ID. We will need it to determine the offset in the buffers of the tensors before the analyzed variables.

We also check the size of the normalization batch. If it is not greater than one, we simply copy the corresponding elements from the gradient buffer of the current layer to the gradient buffer of the previous layer and terminate further execution of the kernel.

```
int n = get_global_id(0);

   if(batch <= 1)

     {

      D4ToArray(output, ToVect4(inputs, n * 4, 1, total, 0), n * 4, 1, total, 0);

      return;

     }
```

Please note that when calling the function to convert tensor values into vector representation and vice versa for the bias parameter in the tensor, we increase the thread identifier by a factor of four. This is because when using vector operations with TYPE4, each thread simultaneously processes four elements of the tensor. Therefore, the number of launched threads will be four times smaller than the size of the processed tensor.

If the normalization batch size is greater than one, and we continue program execution, we need to determine the offset in the normalization parameter tensor buffers, taking into account the identifier of the current thread and the vector operation size (TYPE4)

```
int shift = n * 4;

   int shift_options = n * 3 * 4;

   int shift_weights = n * 2 * 4;
```

We now move on directly to the execution of our algorithm. First, we create a vector with the analyzed input data and calculate the exponential average. Let's use the previous mean and variance to determine the first iteration. We divide the pre-obtained averaging value by the dataset package size only on the second and subsequent iterations. This is because the average of the first element is the element itself.

After determining the mean, we find the deviation of the current value from the mean and calculate the dataset variance.

```
TYPE4 inp = ToVect4(inputs, shift, 1, total, 0);

   TYPE4 mean = ToVect4(options, shift, 3, total * 3, 0) * ((TYPE)batch - 1) + inp ;

   if(options[shift_options ] != 0 && options[shift_options + 1] > 0)

      mean /= (TYPE4)batch;

   TYPE4 delt = inp - mean;

   TYPE4 variance = ToVect4(options, shift, 3, total * 3, 1) * ((TYPE)batch - 1) + pow(delt, 2);

   if(options[shift_options + 1] > 0)

      variance /= (TYPE4)batch;
```

Having mean and sample variance, we can easily calculate the normalized value of the parameter.

```
TYPE4 nx = delt / sqrt(variance + 1e-37f);
```

Next, according to the batch normalization algorithm, it is necessary to perform the shift and scaling of the normalized value. But before that, I want to remind you that at the initial stage, we initialized the buffer of trainable parameter matrices with zero values. As such, we get 0 for all values regardless of the previously normalized value.

Therefore, we check for a zero value for the scaling factor and replace it with one if necessary.

```
if(weights[shift_weights] == 0)

      D4ToArray(weights, (TYPE4)1, shift, 2, total * 2, 0);
```

Note that we are checking for equality to zero only for the first element of the analyzed value vector. We will replace the entire vector with one. This approach is acceptable because I expect to get null values only on the first pass. At this point, we will have all buffer elements equal to zero and need to replace them. The coefficients will then be determined and optimized and, therefore, it will be different from zero during model training.

After such a simple operation, we can safely scale up and shift.

```
TYPE4 res = ToVect4(weights, shift, 2, total * 2, 0) * nx +

               ToVect4(weights, shift, 2, total * 2, 1);
```

Now we only need to save the received data to the appropriate buffer elements. In doing so, we maintain not only the last result but also the intermediate values we need.

```
D4ToArray(options, mean, shift, 3, total * 3, 0);

   D4ToArray(options, variance, shift, 3, total * 3, 1);

   D4ToArray(options, nx, shift, 3, total * 3, 2);

   D4ToArray(output, res, shift, 1, total, 0);

  }
```

This completes the work on the BatchNormFeedForward feed-forward kernel and we can move on to the work on the backpropagation kernels.

To implement the backpropagation algorithm, we create two kernels, one for the propagation of the error gradient to the level of the previous layer and the other one for the propagation of the error gradient to the level of the matrix of trainable parameters.

We start by creating an error gradient propagation kernel through a hidden layer of the BatchNormCalcHiddenGradient neural network. In the parameters of this method, this time we will pass five data buffers and two constants:

- inputs — buffer of input data (previous layer results)

- options — normalization parameter buffer

- weights — trainable parameter matrix buffer (named after the class buffer)

- gradient — error gradient buffer at the result level of the current layer

- gradient_inputs — error gradient buffer at the level of the previous layer results (in this case the kernel result)

- batch — size of the normalization batch

- total — size of the result buffer

```
__kernel void BatchNormCalcHiddenGradient(__global TYPE *options,

                                          __global TYPE *gradient,

                                          __global TYPE *inputs,

                                          __global TYPE *gradient_inputs,

                                          __global TYPE *weights,

                                          int batch,

                                          int total)

  {
```

At the beginning of the kernel, as in the feed-forward kernel, we determine the current flow identifier and check the normalization batch size. If the normalization batch size is not greater than one, we simply copy the error gradients from the current layer buffer to the previous layer buffer and stop executing the kernel.

```
int n = get_global_id(0);

   int shift = n * 4;

   if(batch <= 1)

     {

      D4ToArray(gradient_inputs, ToVect4(gradient, shift, 1, total, 0),

                                                   shift, 1, total, 0);

      return;

     }
```

If, however, the size of the normalization batch is greater than one, and we continue with the kernel operations, then we have to propagate the error gradient throughout the chain from the results level of the current layer to the results level of the previous layer. Below are the mathematical formulas we have to implement.

```
TYPE4 inp = ToVect4(inputs, shift, 1, total, 0);

   TYPE4 gnx = ToVect4(gradient, shift, 1, total, 0) *

               ToVect4(weights, shift, 2, total * 2, 0);

   TYPE4 temp = 1 / sqrt(ToVect4(options, shift, 3, total * 3, 1) + 1e-37f);

   TYPE4 delt = inp - ToVect4(options, shift, 3, total * 3, 0);

   TYPE4 gvar = delt / (-2 * pow(ToVect4(options, shift, 3, total * 3, 1) +

                                              1.0e-37f, 3.0f / 2.0f)) * gnx;

   TYPE4 gmu = (-temp) * gnx - gvar * 2 * delt / (TYPE4)batch;

   TYPE4 gx = temp * gnx + gmu/(TYPE4)batch + gvar * 2 * delt/(TYPE4)batch;
```

After the calculation, we save the result of the operations and complete the kernel.

```
D4ToArray(gradient_inputs, gx, shift, 1, total, 0);

  }
```

This completes the first kernel in implementing the backpropagation algorithm of our batch normalization class, and we move on to the final phase of the OpenCL program, which is the creation of the second backpropagation kernel in which the error gradient is propagated to the level of the BatchNormCalcDeltaWeights trainable parameter matrix.

We pass three data buffers to this kernel in parameters. These are:

- options — normalization parameter buffer

- delta_weights — error gradient buffer at the trainable parameter matrix level (in this case the result of the kernel)

- gradient — error gradient buffer at the result level of the current layer.

```
__kernel void BatchNormCalcDeltaWeights(__global TYPE *options,

                                        __global TYPE *delta_weights,

                                        __global TYPE *gradients)

  {
```

We need to implement only two mathematical formulas in this kernel:

As you can see, the operations are quite simple and will not require too long code to implement the algorithm. This time we dont even use vector operations.

At the beginning of the kernel, we define the ID of the current thread and the offset in the buffers with the normalization parameter tensors. The offset in the error gradient buffers will match the thread ID.

```
const int n = get_global_id(0);

   int shift_options = n * 3;

   int shift_weights = n * 2;
```

To reduce global memory access, we will first save the gradient error value in a local variable, and then calculate and immediately write the corresponding values for the current step to the gradient error accumulation buffer elements using the formulas mentioned above.

```
TYPE grad = gradients[n];

   delta_weights[shift_weights] += grad * options[shift_options + 2];

   delta_weights[shift_weights + 1] += grad;

  }
```

As you can see, the error gradients are written to the corresponding buffer elements. So, the task assigned to this kernel is complete and we can finish its operation.

We have created all three kernels to implement feed-forward and backpropagation passes in our batch normalization class. We can now proceed to make changes to the main program to organize data exchange with the OpenCL context and call the corresponding program kernel.

Let's start this work as usual by creating constants for OpenCL kernels. Go to [defines.mqh](https://www.mql5.com/en/neurobook/index/realization/basic/constants) and add program kernel identifier constants at the beginning.

```
#define def_k_BatchNormFeedForward        37

#define def_k_BatchNormCalcHiddenGradient 38

#define def_k_BatchNormCalcDeltaWeights   39
```

Then add the kernel parameter identifiers.

```
//--- feed-forward pass of batch normalization

#define def_bnff_inputs                0

#define def_bnff_options               1

#define def_bnff_weights               2

#define def_bnff_outputs               3

#define def_bnff_batch                 4

#define def_bnff_total                 5
```

```
//--- gradient distribution through the batch normalization layer

#define def_bnhgr_options              0

#define def_bnhgr_gradient             1

#define def_bnhgr_inputs               2

#define def_bnhgr_gradient_inputs      3

#define def_bnhgr_weights              4

#define def_bnhgr_batch                5

#define def_bnhgr_total                6
```

```
//---- gradient distribution to optimized batch normalization parameters

#define def_bndelt_options             0

#define def_bndelt_delta_weights       1

#define def_bndelt_gradient            2
```

The next step is to initialize the new kernels in the program. To do this, we switch to the method of initializing the OpenCL program of the main dispatch class of our model [CNet::InitOpenCL](https://www.mql5.com/en/neurobook/index/realization/pr_opencl/opencl_transfer_data#initopemcl). First, we change the total number of kernels used.

```
if(!m_cOpenCL.SetKernelsCount(40))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }

   if(!m_cOpenCL.KernelCreate(def_k_BatchNormFeedForward,

                                   "BatchNormFeedForward"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }

   if(!m_cOpenCL.KernelCreate(def_k_BatchNormCalcHiddenGradient,

                                   "BatchNormCalcHiddenGradient"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }

   if(!m_cOpenCL.KernelCreate(def_k_BatchNormCalcDeltaWeights,

                                   "BatchNormCalcDeltaWeights"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

Now that the kernels have been created, and we can access them, we move on to working with the methods of our batch normalization class.

As is already the tradition, we will start with the feed-forward method. We only make changes to the implementation of the multithread algorithm using OpenCL. All other method code remains unchanged.

According to the algorithm of preparing the kernel to run, we must first pass all the necessary data to the OpenCL context memory. So, we check for created buffers in the context memory.

```
bool CNeuronBatchNorm::FeedForward(CNeuronBase *prevLayer)

  {

   ......

//--- branching of the algorithm by the computing device

   if(!m_cOpenCL)

     {

//--- Implementation using MQL5 tools

   ......

     }

   else  // OpenCL block

     {

 //--- checking data buffers

      CBufferType *inputs = prevLayer.GetOutputs();

      if(inputs.GetIndex() < 0)

         return false;

      if(m_cBatchOptions.GetIndex() < 0)

         return false;

      if(m_cWeights.GetIndex() < 0)

         return false;

      if(m_cOutputs.GetIndex() < 0)

         return false;
```

In the next step, we pass pointers to data buffers and the values of required constants to the kernel parameters.

```
//--- pass parameters to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormFeedForward,

                                         def_bnff_inputs, inputs.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormFeedForward,

                                    def_bnff_weights, m_cWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormFeedForward,

                               def_bnff_options, m_cBatchOptions.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormFeedForward,

                                    def_bnff_outputs, m_cOutputs.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_BatchNormFeedForward,

                                    def_bnff_total, (int)m_cOutputs.Total()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_BatchNormFeedForward,

                                               def_bnff_batch, m_iBatchSize))

         return false;
```

After completing the preparatory work, we proceed to enqueue the kernel for execution. First, we need to fill in two dynamic arrays. In one of them, we fill in the dimension of the task space, and in the other one, we fill in the offset in each dimension of the task space. We will run the kernel in a one-dimensional zero-offset task space. The number of threads to run will be four times smaller than the tensor size of the current layer results. However, since the dimension of the tensor will not always be a multiple of four, and we need to run the computations for all elements of the result tensor, we will provide an additional thread that will compute the "tail" part of the tensor that is not a multiple of four.

After calculating the number of threads and filling the buffers, we call the kernel queuing method.

```
//--- queuing for execution

      uint off_set[] = {0};

      uint NDRange[] = { (int)(m_cOutputs.Total() + 3) / 4 };

      if(!m_cOpenCL.Execute(def_k_BatchNormFeedForward, 1, off_set, NDRange))

         return false;

     }

//---

   if(!m_cActivation.Activation(m_cOutputs))

      return false;

//---

   return true;

  }
```

This completes the work with the feed-forward method, in which we have already implemented full functionality, including the ability to organize parallel computations on GPUs using OpenCL technology.

Let's proceed to backpropagation methods, in which we need to perform similar work. When implementing the backpropagation method in pure MQL5, we have overridden two methods. Consequently, we need to supplement both methods with multi-threaded computing functionality. First, let's add functionality to the method that propagates the error gradient up to the previous neural layer CNeuronBatchNorm::CalcHiddenGradient. As with the feed-forward method, we first create the necessary data buffers in the OpenCL context.

```
bool CNeuronBatchNorm::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

   ......

//--- branching of the algorithm by the computing device

   if(!m_cOpenCL)

     {

//--- Implementation using MQL5 tools

   ......

     }

   else  // OpenCL block

     {

 //--- checking data buffers

      CBufferType* inputs = prevLayer.GetOutputs();

      CBufferType* inputs_grad = prevLayer.GetGradients();

      if(inputs.GetIndex() < 0)

         return false;

      if(m_cBatchOptions.GetIndex() < 0)

         return false;

      if(m_cWeights.GetIndex() < 0)

         return false;

      if(m_cOutputs.GetIndex() < 0)

         return false;

      if(m_cGradients.GetIndex() < 0)

         return false;

      if(inputs_grad.GetIndex() < 0)

         return false;
```

Then, according to our algorithm for implementing multi-threaded computations using OpenCL, we pass the parameters of the induced kernel.

```
//--- pass parameters to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormCalcHiddenGradient,

                                             def_bnhgr_inputs, inputs.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormCalcHiddenGradient,

                                        def_bnhgr_weights, m_cWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormCalcHiddenGradient,

                                   def_bnhgr_options, m_cBatchOptions.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormCalcHiddenGradient,

                                     def_bnhgr_gradient, m_cGradients.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormCalcHiddenGradient,

                               def_bnhgr_gradient_inputs, inputs_grad.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_BatchNormCalcHiddenGradient,

                                        def_bnhgr_total, (int)m_cOutputs.Total()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_BatchNormCalcHiddenGradient,

                                                   def_bnhgr_batch, m_iBatchSize))

         return false;
```

After passing all parameters, we prepare the kernel for the run queue. Recall that when creating the kernel we defined the use of vector operations with type TYPE4. Accordingly, we reduce by four times the number of threads running. Now we call the queuing method of the kernel.

```
//--- queuing

      int off_set[] = {0};

      int NDRange[] = { (int)(m_cOutputs.Total() + 3) / 4 };

      if(!m_cOpenCL.Execute(def_k_BatchNormCalcHiddenGradient, 1, off_set, NDRange))

         return false;

     }

//---

   return true;

  }
```

This concludes the method that propagates the error gradient through the hidden layer CNeuronBatchNorm::CalcHiddenGradient. We need to repeat the operations for the second backpropagation method CNeuronBatchNorm::CalcDeltaWeights.

Again, we repeat the algorithm for queuing the kernel. This time the kernel uses three data buffers.

```
bool CNeuronBatchNorm::CalcDeltaWeights(CNeuronBase *prevLayer, bool read)

  {

   ......

//--- branching of the algorithm by the computing device

   if(!m_cOpenCL)

     {

//--- Implementation using MQL5 tools

   ......

     }

   else

     {

 //--- check data buffers

      if(m_cBatchOptions.GetIndex() < 0)

         return false;

      if(m_cGradients.GetIndex() < 0)

         return false;

      if(m_cDeltaWeights.GetIndex() < 0)

         return false;
```

Then we pass pointers to the created buffers as parameters to the launched kernel.

```
//--- pass parameters to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormCalcDeltaWeights,

                           def_bndelt_delta_weights, m_cDeltaWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormCalcDeltaWeights,

                                 def_bndelt_options, m_cBatchOptions.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormCalcDeltaWeights,

                                   def_bndelt_gradient, m_cGradients.GetIndex()))

         return false;
```

Then we place the kernel in the execution queue. This time the number of threads will be equal to the number of elements in the results tensor of our batch normalization layer.

```
//--- queuing

      int off_set[] = {0};

      int NDRange[] = {(int)m_cOutputs.Total()};

      if(!m_cOpenCL.Execute(def_k_BatchNormCalcDeltaWeights, 1, off_set, NDRange))

         return false;

      if(read && !m_cDeltaWeights.BufferRead())

         return false;

     }

//---

   return true;

  }
```

This concludes our work with CNeuronBatchNorm batch normalization class. It is ready for use as it now fully implements the data normalization algorithm. We have implemented the algorithm in two versions: using standard MQL5 tools and using OpenCL multi-threaded computing technology. This gives the user the opportunity to choose the technology used according to their requirements.

I now propose to look at the implementation of the batch normalization method in Python.

## Dropout

As we continue discussing ways to increase the convergence of models, let's consider the Dropout method.

When training a neural network, a large number of features are fed into each neuron, and it is difficult to assess the influence of each of them. As a result, errors from some neurons are smoothed out by the correct values from others, and errors accumulate at the output of the neural network. As a result, training stops at a certain local minimum with a relatively large error. This effect is known as feature co-adaptation, where the influence of each feature seems to adapt to the surrounding environment. For us, it would be better to achieve the opposite effect, where the environment is decomposed into individual features, and the influence of each feature is evaluated separately.

Dropout

To combat the complex co-adaptation of features, in July 2012, a group of scientists from the University of Toronto in the article [Improving neural networks by preventing co-adaptation of feature detectors](https://arxiv.org/pdf/1207.0580.pdf) proposed randomly excluding some of the neurons in the learning process. Reducing the number of features during training increases the significance of each one, and constant variation in the quantitative and qualitative composition of features reduces the risk of their co-adaptation. This method is called Dropout. Some compare the application of this method to decision trees because, by excluding some neurons, we get a new neural network with its own weights at each training iteration. According to the rules of combinatorics, the variability of such networks is quite high.

During the operation of the neural network, all attributes and neurons are evaluated. Thus, we get the most accurate and independent assessment of the current state of the environment under consideration.

The authors of the method in their paper mention the possibility of using it to improve the quality of pre-trained models as well.

Describing the proposed solution from the mathematics point of view, we can say that each individual neuron is dropped out of the process with a certain given probability p, or the neuron will participate in the process of training a neural network with probability q.

To determine the list of neurons to be dropped out, a pseudo-random number generator with a normal distribution is used. This approach provides the most uniform exclusion of neurons possible. In practice, we will generate a vector with a size equal to the input sequence. For the features used in the vector, we will set 1, and for the excluded elements, we will use 0.

However, excluding analyzed features undoubtedly leads to a reduction in the sum at the input of the neuron activation function. To compensate for this effect, we will multiply the value of each feature by a factor of 1/q. It is obvious that this coefficient will increase the values since the probability of q will always be in the range from 0 to 1.

where:

- di = elements of the Dropout result vector

- q = probability of using a neuron in the learning process

- xi = elements of the masking vector

- ni = elements of the input sequence

During the backpropagation in the training process, the error gradient is multiplied by the derivative of the above-mentioned function. In the case of Dropout, the backpropagation pass will be similar to the feed-forward pass using the masking vector from the feed-forward pass.

During the operation of the neural network, the masking vector is filled with ones, allowing values to be transmitted in both directions without hindrance.

In practice, the coefficient of 1/q is constant throughout the training, so we can easily calculate this coefficient once and write it instead of one in the masking tensor. This way, we combine the coefficient recalculation and multiplication by 1 in each training iteration.

## Comparative testing of models with Dropout

Another stage of work with our library has been completed. We have studied the Dropout method, which combats the issue of feature co-adaptation and have built a class to implement this algorithm in our models. In the previous section, we assembled a Python script for the comparative testing of models using this method and without. Let's look at the results of such testing.

First, we look at the test training schedule for models with one hidden layer. The dynamics of the mean square error of the models using Dropout was worse than that of models without it. This applies to both the model trained on normalized data and the model using batch normalization layers for preprocessing the input data. You can see that both models using the Dropout layer worked synchronously. Their lines on the graph are practically overlapping, both during the training and validation phases.

Similar conclusions can be drawn when analyzing the dynamics of Accuracy metrics. However, unlike the MSE, accuracy values in the validation process are close to those of other models.

The evaluation of models on the test dataset also showed deterioration in model performance when using the Dropout layer, both for mean square error and for Accuracy. The reasons for such a phenomenon can only be speculated upon. One of the possible reasons can be attributed to the use of models that are too simple. The models didn't have too many neurons, and masking some of them reduces the capabilities of the model, which are already limited by the small number of neurons being used.

Comparative model testing with Dropout

Comparative model testing with Dropout

On the other hand, we chose uncorrelated variables at the data selection stage. Probably due to the small number of features being used and the absence of strong correlations between them, co-adaptation might not be highly developed in our models. As a result, the negative impact of using Dropout in terms of degrading the model performance may have outweighed the positive effects of the method.

Comparative model testing with Dropout (test sample)

 

Comparative model testing with Dropout (test sample)

That is just my guess. I do not have enough information to draw certain conclusions. Additional tests will be required. However, it is more the focus of scientific work, while our goal is the practical use of models. We conduct experiments with various architectural solutions and choose the best one for each specific task.

Comparative model testing with Dropout

The second test was performed using a Dropout layer before each fully connected layer in models with three hidden layers. Again, models with the Dropout layer performed worse than other models in the learning process. However, during the validation process, the situation tends to change somewhat. While models without the use of Dropout layers tend to decrease their performance on the validation stage with an increase in the number of training epochs, models using this technology slightly improve their positions or remain at a similar level.

This suggests that the use of a Dropout layer reduces the likelihood of model overfitting.

The graph showing the dynamics of Accuracy values during training confirms the conclusion made earlier. With the increasing number of model training epochs, without the use of the Dropout layer, there is a widening gap between the values in the training and validation phases. This indicates a retraining of the model. For models using Dropout technology, the gap is narrowing. This supports the earlier conclusion that the use of a Dropout layer reduces the tendency of the model to overfit.

On the test dataset, models using the Dropout layer showed worse results in both metrics.

Comparative model testing with Dropout

Comparative model testing with Dropout (test sample)

Comparative model testing with Dropout (test sample)

In this section, we have run comparative model testing with Dropout technology and without it. The following conclusions can be drawn from the tests:

- The use of the Dropout technology helps reduce the risk of model overfitting.

- The effectiveness of the Dropout technology increases as the model size grows.

## Implementing Dropout in Python

To build models in Python, we previously used the Keras library for TensorFlow. This library already has a ready-made implementation of the Dropout layer.

```
tf.keras.layers.Dropout(

    rate, noise_shape=None, seed=None, **kwargs

)
```

The Dropout layer randomly sets the input units to 0 at a certain frequency equal to rate at each iteration during the training process. This helps prevent the model from overfitting. Initial data that is not set to 0 is scaled by 1/(1 - rate). Therefore, the sum of all initial data transmitted remains unchanged.

Note that the Dropout layer is only applied if its training field is set to True. Otherwise, no values are masked. When training the model, the training flag will be automatically set to True. In other cases, the user can explicitly set training to True when calling the layer.

This is different from setting trainable = False for the Dropout layer. In this case, the value of the trainable flag does not affect the behavior of the layer, since Dropout does not have any weights that could be frozen during training.

The Dropout layer constructor has the following arguments:

- rate — a floating point number in the range from 0 to 1, which represents the proportion of elements of the initial data that are masked during the training process.

- noise_shape — a one-dimensional integer tensor representing the shape of a binary exception mask as (batch_size, timesteps, features). The shape will be multiplied by the tensor of the initial data. For example, if the initial data has a shape and you want the exclusion mask to be the same for all time steps, you can use noise_shape=(batch_size, 1, features).

- seed — an integer to use as a random seed.

When calling a layer, two arguments are allowed:

- inputs — a tensor of the source data, it is possible to use a tensor of any rank.

- training — a Boolean flag indicating the operating mode of the layer.

To test the effectiveness of using Dropout technology, we will create a script and train several models using this layer. We will not create overly complex models. Instead, let's take the script [batch_norm.py](https://www.mql5.com/en/neurobook/index/improvement_realization/batch_norm/batch_norm_py/batch_norm_py_sript), which was used when testing batch normalization. We will create a copy of this script in a file dropout.py and add Dropout layers to each model.

First, we add two Dropout layers to the model with one hidden layer without using batch normalization. We will insert new layers before each fully connected layer.

```
# Adding a Dropout to a model with one hidden layer

model1do = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),

                           keras.layers.Dropout(0.3),

                           keras.layers.Dense(40, activation=tf.nn.swish),

                           keras.layers.Dropout(0.3),

                           keras.layers.Dense(targets, activation=tf.nn.tanh)

                         ])

model1do.compile(optimizer='Adam',

               loss='mean_squared_error',

               metrics=['accuracy'])

model1do.summary()
```

Please note that in all Dropout layers, we will be masking 30% of the neurons of the previous layer.

Then, in a similar manner, we will add two Dropout layers to the model with one hidden layer and batch normalization of the initial data. Please note that we are being a little disingenuous here. It is currently not recommended to use batch normalization and Dropout simultaneously within this model, as this will only reduce the overall result of the model. Let's test this statement with practical examples.

```
# Adding Dropout to the model with batch normalization of the initial data

# and one hidden layer

model1bndo = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),

                             keras.layers.BatchNormalization(),

                             keras.layers.Dropout(0.3),

                             keras.layers.Dense(40, activation=tf.nn.swish),

                             keras.layers.Dropout(0.3),

                             keras.layers.Dense(targets, activation=tf.nn.tanh)

                            ])

model1bndo.compile(optimizer='Adam',

               loss='mean_squared_error',

               metrics=['accuracy'])

model1bndo.summary()
```

Similarly, we add Dropout batches to models with three hidden layers.

```
# Adding a Dropout to a model with three hidden layers

model2do = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),

                           keras.layers.Dropout(0.3),

                           keras.layers.Dense(40, activation=tf.nn.swish),

                           keras.layers.Dropout(0.3),

                           keras.layers.Dense(40, activation=tf.nn.swish),

                           keras.layers.Dropout(0.3),

                           keras.layers.Dense(40, activation=tf.nn.swish),

                           keras.layers.Dropout(0.3),

                           keras.layers.Dense(targets, activation=tf.nn.tanh)

                         ])

model2do.compile(optimizer='Adam',

               loss='mean_squared_error',

               metrics=['accuracy'])

model2do.summary()
```

```
# Adding Dropout to the model with batch normalization of the initial data

# and three hidden layers

model2bndo = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),

                             keras.layers.BatchNormalization(),

                             keras.layers.Dropout(0.3),

                             keras.layers.Dense(40, activation=tf.nn.swish),

                             keras.layers.BatchNormalization(),

                             keras.layers.Dropout(0.3),

                             keras.layers.Dense(40, activation=tf.nn.swish),

                             keras.layers.BatchNormalization(),

                             keras.layers.Dropout(0.3),

                             keras.layers.Dense(40, activation=tf.nn.swish),

                             keras.layers.Dropout(0.3),

                             keras.layers.Dense(targets, activation=tf.nn.tanh)

                            ])

model2bndo.compile(optimizer='Adam',

               loss='mean_squared_error',

               metrics=['accuracy'])

model2bndo.summary()
```

After creating the models, we add code to start the new model training process.

```
history1do = model1do.fit(train_data, train_target,

                      epochs=500, batch_size=1000,

                      callbacks=[callback],

                      verbose=2,

                      validation_split=0.1,

                      shuffle=True)

model1do.save(os.path.join(path,'perceptron1do.h5'))
```

```
history1bndo = model1bndo.fit(train_nn_data, train_nn_target,

                      epochs=500, batch_size=1000,

                      callbacks=[callback],

                      verbose=2,

                      validation_split=0.1,

                      shuffle=True)

model1bndo.save(os.path.join(path,'perceptron1bndo.h5'))
```

```
history2do = model2do.fit(train_data, train_target,

                      epochs=500, batch_size=1000,

                      callbacks=[callback],

                      verbose=2,

                      validation_split=0.1,

                      shuffle=True)

model2do.save(os.path.join(path,'perceptron2do.h5'))
```

```
history2bndo = model2bndo.fit(train_nn_data, train_nn_target,

                      epochs=500, batch_size=1000,

                      callbacks=[callback],

                      verbose=2,

                      validation_split=0.1,

                      shuffle=True)

model2bndo.save(os.path.join(path,'perceptron2bndo.h5'))
```

We also add the ability to run models on a test dataset.

```
test_loss1do, test_acc1do = model1do.evaluate(test_data, test_target,

                                                            verbose=2)

test_loss1bndo, test_acc1bndo = model1bndo.evaluate(test_nn_data,

                                                    test_nn_target,

                                                    verbose=2)

test_loss2do, test_acc2do = model2do.evaluate(test_data, test_target,

                                                            verbose=2)

test_loss2bndo, test_acc2bndo = model2bndo.evaluate(test_nn_data,

                                                    test_nn_target,

                                                    verbose=2)
```

In addition to changes in terms of training and testing models, we will also add a block for rendering model results. First, let's change the code that creates dynamics graphs for the mean square error and Accuracy during the training process. The changes here are not global, as we are just adding new variables to the graph.

```
# Rendering the results of training models with one hidden layer

plt.figure()

plt.plot(history1.history['loss'], label='Normalized inputs train')

plt.plot(history1.history['val_loss'], label='Normalized inputs validation')

plt.plot(history1do.history['loss'], label='Normalized inputs\nvs Dropout train')

plt.plot(history1do.history['val_loss'],

                                label='Normalized inputs\nvs Dropout validation')

plt.plot(history1bn.history['loss'],

                        label='Unnormalized inputs\nvs BatchNormalization train')

plt.plot(history1bn.history['val_loss'],

                   label='Unnormalized inputs\nvs BatchNormalization validation')

plt.plot(history1bndo.history['loss'],

            label='Unnormalized inputs\nvs BatchNormalization and Dropout train')

plt.plot(history1bndo.history['val_loss'],

       label='Unnormalized inputs\nvs BatchNormalization and Dropout validation')

plt.ylabel('$MSE$ $loss$')

plt.xlabel('$Epochs$')

plt.title('Model training dynamics\n1 hidden layer')

plt.legend(loc='upper right',ncol=2)
```

```
plt.figure()

plt.plot(history1.history['accuracy'], label='Normalized inputs trin')

plt.plot(history1.history['val_accuracy'], label='Normalized inputs validation')

plt.plot(history1do.history['accuracy'],

                                    label='Normalized inputs\nvs Dropout train')

plt.plot(history1do.history['val_accuracy'],

                               label='Normalized inputs\nvs Dropout validation')

plt.plot(history1bn.history['accuracy'],

                       label='Unnormalized inputs\nvs BatchNormalization train')

plt.plot(history1bn.history['val_accuracy'],

                  label='Unnormalized inputs\nvs BatchNormalization validation')

plt.plot(history1bndo.history['accuracy'],

           label='Unnormalized inputs\nvs BatchNormalization and Dropout train')

plt.plot(history1bndo.history['val_accuracy'],

      label='Unnormalized inputs\nvs BatchNormalization and Dropout validation')

plt.ylabel('$Accuracy$')

plt.xlabel('$Epochs$')

plt.title('Model training dynamics\n1 hidden layer')

plt.legend(loc='lower right',ncol=2)
```

```
# Rendering the results of training models with three hidden layers

plt.figure()

plt.plot(history2.history['loss'], label='Normalized inputs train')

plt.plot(history2.history['val_loss'], label='Normalized inputs validation')

plt.plot(history2do.history['loss'], label='Normalized inputs\nvs Dropout train')

plt.plot(history2do.history['val_loss'],

                                 label='Normalizedinputs\nvs Dropout validation')

plt.plot(history2bn.history['loss'],

                        label='Unnormalized inputs\nvs BatchNormalization train')

plt.plot(history2bn.history['val_loss'],

                   label='Unnormalized inputs\nvs BatchNormalization validation')

plt.plot(history2bndo.history['loss'],

            label='Unnormalized inputs\nvs BatchNormalization and Dropout train')

plt.plot(history2bndo.history['val_loss'],

       label='Unnormalized inputs\nvs BatchNormalization and Dropout validation')

plt.ylabel('$MSE$ $loss$')

plt.xlabel('$Epochs$')

plt.title('Model training dynamics\n3 hidden layers')

plt.legend(loc='upper right',ncol=2)
```

```
plt.figure()

plt.plot(history2.history['accuracy'], label='Normalized inputs train')

plt.plot(history2.history['val_accuracy'], label='Normalized inputs validation')

plt.plot(history2do.history['accuracy'], label='Normalized inputs\nvs Dropout train')

plt.plot(history2do.history['val_accuracy'],

                                    label='Normalized inputs\nvs Dropout validation')

plt.plot(history2bn.history['accuracy'],

                            label='Unnormalized inputs\nvs BatchNormalization train')

plt.plot(history2bn.history['val_accuracy'],

                       label='Unnormalized inputs\nvs BatchNormalization validation')

plt.plot(history2bndo.history['accuracy'],

                label='Unnormalized inputs\nvs BatchNormalization and Dropout train')

plt.plot(history2bndo.history['val_accuracy'],

           label='Unnormalized inputs\nvs BatchNormalization and Dropout validation')

plt.ylabel('$Accuracy$')

plt.xlabel('$Epochs$')

plt.title('Model training dynamics\n3 hidden layers')

plt.legend(loc='lower right',ncol=2)
```

The last changes in the script concern the display of model performance results on the test dataset. Here, in addition to adding new data, we split the graphs: we will separately show the results of models with one hidden layer, and we will place the results of models with three hidden layers on a new graph.

```
plt.figure()

plt.bar(['Normalized inputs','\n\nNormalized inputs\nvs Dropout',

         'Unnormalized inputs\nvs BatchNornalization',

         '\n\nUnnormalized inputs\nvs BatchNornalization and Dropout'],

        [test_loss1,test_loss1do,

         test_loss1bn,test_loss1bndo])

plt.ylabel('$MSE$ $loss$')

plt.title('Test results\n1 hidden layer')
```

```
plt.figure()

plt.bar(['Normalized inputs','\n\nNormalized inputs\nvs Dropout',

         'Unnormalized inputs\nvs BatchNornalization',

         '\n\nUnnormalized inputs\nvs BatchNornalization and Dropout'],

        [test_loss2,test_loss2do,

         test_loss2bn,test_loss2bndo])

plt.ylabel('$MSE$ $loss$')

plt.title('Test results\n3 hidden layers')
```

```
plt.figure()

plt.bar(['Normalized inputs','\n\nNormalized inputs\nvs Dropout',

         'Unnormalized inputs\nvs BatchNornalization',

         '\n\nUnnormalized inputs\nvs BatchNornalization and Dropout'],

        [test_acc1,test_acc1do,

         test_acc1bn,test_acc1bndo])

plt.ylabel('$Accuracy$')

plt.title('Test results\n1 hidden layer')
```

```
plt.figure()

plt.bar(['Normalized inputs','\n\nNormalized inputs\nvs Dropout',

         'Unnormalized inputs\nvs BatchNornalization',

         '\n\nUnnormalized inputs\nvs BatchNornalization and Dropout'],

        [test_acc2,test_acc2do,

         test_acc2bn,test_acc2bndo])

plt.ylabel('$Accuracy$')

plt.title('Test results\n3 hidden layers')

plt.show()
```

The rest of the script code remained unchanged.

We will learn about the results of testing the models in the next section.

## Principles of batch normalization implementation

The authors of the method proposed the following normalization algorithm. First, we calculate the average value from the data sample.

where:

- μB = arithmetic mean of the dataset

- m = dataset size (batch)

Then we calculate the variance of the initial sample.

Next, we will normalize the dataset by making it have a zero mean and a unit variance.

Please note that a small positive number ε is added to the denominator of the dataset variance to avoid division by zero.

However, it has been found that such normalization can distort the impact of the initial data. Therefore, the authors of the method added another step that includes scaling and shifting. They introduced variables γ and β, which are trained along with the neural network using gradient descent.

The application of this method allows obtaining a dataset with the same distribution at each training step, which, in practice, makes neural network training more stable and enables an increase in the learning rate. Overall, this can improve the training quality while reducing the time and computational resources required for neural network training.

However, at the same time, the costs of storing additional coefficients increase. Additionally, the calculation of moving averages and variances requires additional memory allocation to store historical data for each neuron across the entire batch size. Here you can look at the exponential average. To calculate EMA (Exponential Moving Averages), we only need the previous value of the function and the current element of the sequence.

The figure below provides a visual comparison of moving averages and moving variances for 100 elements against exponential moving averages and exponential moving variances for the same 100 elements. The graph was plotted for 1,000 random items in the range from -1.0 to 1.0.

Comparison of moving and exponential average graphs

 

As seen in the graph, the moving average and exponential moving average converge after around 120-130 iterations, and beyond that point, there is minimal deviation that can be disregarded. The exponential moving average chart also looks smoother. To calculate EMA, you only need the previous value of the function and the current element of the sequence. Let me remind you of the exponential moving average formula.

where:

- μi = exponential average of the sample at the ith step

- m = dataset size (batch)

- xi = current value of the indicator

To align the plots of moving variance and exponential moving variance, it took slightly more iterations (around 310-320), but overall the picture is similar. In the case of variance, the use of exponential moving averages not only saves memory but also significantly reduces the number of computations since for moving variance, we would need to recalculate the deviation from the mean for the entire batch of historical data, which can be computationally expensive.

In my opinion, the use of such a solution significantly reduces memory usage and the computational overhead during each iteration of the forward pass.

## Implementing batch normalization in Python

We have already discussed the batch data normalization algorithm and even implemented a batch normalization layer for our library in MQL5. Additionally, we have added the capability to utilize multithreading technology with OpenCL. Now let's see the version of the method implementation offered by the familiar Keras library for TensorFlow.

This library provides the tf.keras.layers.BatchNormalization layer.

```
tf.keras.layers.BatchNormalization(

    axis=-1, momentum=0.99, epsilon=0.001, center=True, scale=True,

    beta_initializer='zeros', gamma_initializer='ones',

    moving_mean_initializer='zeros',

    moving_variance_initializer='ones', beta_regularizer=None,

    gamma_regularizer=None, beta_constraint=None, gamma_constraint=None, **kwargs

)
```

Batch normalization applies a transformation to maintain the mean of the results around zero and the standard deviation around one.

It's important to note that the batch normalization layer operates differently during training and during logical output.

During the training period, the layer normalizes its output data using the mean and standard deviation of the current batch of input data. For each normalized channel, the layer returns:

where:

-  = small constant (configured as part of the constructor arguments) to avoid division by zero error

-  = trainable scale factor (initialized as 1), which can be disabled by setting scale=False in the object constructor

-  = trainable offset factor (initialized as 0), which can be disabled by setting center=False in the object constructor

- X = tensor of the input data batch

-  = average value of the data batch

-  = variance of the data batch

During operation, the layer normalizes its output data using the moving average and standard deviation of the batches it encountered during training.

Thus, the layer will normalize the input data during inference only after being trained on data with similar statistical characteristics.

You can pass the following arguments to the layer constructor:

- axis — integer, the axis to be normalized (usually a feature axis)

- momentum — momentum for the moving average

- epsilon — small constant to avoid division by zero error

- center — if True, adds a beta offset to normalized tensor, if False, beta is ignored

- scale — if True it is multiplied by gamma, if False gamma is not used; when the next layer is a linear layer, it can be turned off because the scaling will be performed by the subsequent layer

- beta_initializer — beta weight initializer type

- gamma_initializer — type of gamma weight initializer

- moving_mean_initializer — type of initializer for moving average

- moving_variance_initializer — type of initializer for moving average variance

- beta_regularizer — additional regularizer for beta weight

- gamma_regularizer — additional regularizer for gamma weight

- beta_constraint — optional constraint for beta weight

- gamma_constraint — optional constraint for gamma weight

The following parameters can be used when accessing a layer:

- inputs — tensor of initial data, it is allowed to use tensor of any rank

- training — logical flag indicating the mode of operation of the layer: training or operation (the difference between the modes of operation is specified above)

- input_shape — used to describe the dimensionality of input data in case the layer is specified first in the model

At the output, the layer produces a tensor of results while preserving the dimensionality of the original data.

In addition, the layer design allows the use of the layer.trainable setting that blocks parameters from being changed during training. This is optional and usually means that the layer operates in output mode. This mode is usually enabled by the "training" parameter, which can be passed when calling the layer. However, please note that "Parameter Freeze" and "Output Mode" are two different concepts.

However, in the case of a BatchNormalization layer, setting trainable = False means that the layer will subsequently run in logical output mode. This means that it will use the moving average and moving variance to normalize the current batch instead of the mean and variance of the current dataset.

This behavior was added in TensorFlow 2.0 to ensure that when layer.trainable = False, you get the most commonly expected behavior in the case of fine-tuning.

Note that setting trainable for a model containing other layers will recursively set the trainable value for all inner layers.

If the trainable value of the attribute changes after a model is compiled, the new value does not take effect for that model until the model is recompiled again.

## 6.Creating a script to test batch normalization

To analyze the effect of batch normalization on the result, let's take the simplest models with a fully connected perceptron. One of our very first tests was to check the influence of preprocessing normalization of input data on the model's performance. In that test, we concluded that it was important to normalize the initial data and used normalized initial data in all subsequent models. However, the preliminary normalization of the initial data always has costs and is not very convenient for working in financial markets, when the initial data goes in a continuous stream. In this case, the normalization of the source data must be written in the program code. When changing the dataset, whether it's due to time-dependent factors or alterations in the analyzed instrument, it may require modifications to the code or external parameters that need to be defined outside the model. This is an additional cost. After that, you would need to retrain the model. Therefore, it would be logical to find a way to incorporate the data normalization process into the model and update its parameters during the model training. Don't you think that the batch normalization model we are looking at is suitable for solving this problem? This will be our first test.

To conduct such an experiment, we will use the script for testing perceptron models [perceptron.py](https://www.mql5.com/en/neurobook/index/realization/pr_py) and create a copy of it named batch_norm.py. Let's make small changes to it.

At the beginning of the script, we import the necessary libraries as usual.

```
# Import libraries

import os

import pandas as pd

import numpy as np

import tensorflow as tf

from tensorflow import keras

import matplotlib.pyplot as plt

import MetaTrader5 as mt5
```

Before training, we need to load training datasets which are available in the sandbox of the MetaTrader 5 terminal. To determine the path to the sandbox, we connect to the terminal and find the path to the terminal data folder. We add MQL5\Files to the resulting path and thus get the path to the terminal sandbox. If you saved the training dataset to a subdirectory, you also need to add it to this sandbox path. Now you can disconnect from the terminal. We will create two local variables with the full path to the files of the training dataset, one with normalized data and the second one with non-normalized data.

```
# Load the training dataset

if not mt5.initialize():

    print("initialize() failed, error code =",mt5.last_error())

    quit()

path=os.path.join(mt5.terminal_info().data_path,r'MQL5\Files')

mt5.shutdown()

filename = os.path.join(path,'study_data.csv')

filename_not_norm = os.path.join(path,'study_data_not_norm.csv')
```

First, we load data from the normalized set.

```
data = np.asarray( pd.read_table(filename,

                   sep=',',

                   header=None,

                   skipinitialspace=True,

                   encoding='utf-8',

                   float_precision='high',

                   dtype=np.float64,

                   low_memory=False))
```

Then we divide the uploaded data into patterns and goals. Let me remind you that when creating the training dataset, we wrote all the information about the pattern to the file in one line. At the same time, each line contains information about only one pattern. The last two elements in the row contain the target values of the pattern. Let's use this property and determine the number of elements in the second dimension of our data array. Subtracting the number of elements from the obtained value by the target values, we get the number of elements of one pattern description. Using this information, we divide the data into two arrays.

```
# Divide the training sample into initial data and goals

targets=2

inputs=data.shape[1]-targets

train_data=data[:,0:inputs]

train_target=data[:,inputs:]
```

After that, we load and divide the data of the non-normalized training dataset in the same way.

```
#load unnormalized training dataset

data = np.asarray( pd.read_table(filename_not_norm,

                   sep=',',

                   header=None,

                   skipinitialspace=True,

                   encoding='utf-8',

                   float_precision='high',

                   dtype=np.float64,

                   low_memory=False))
```

```
# Split the non-normalized training sample into initial data and goals

train_nn_data=data[:,0:inputs]

train_nn_target=data[:,inputs:]

del data
```

After dividing the training dataset into two tensors, we delete the source data object in order to use our resources more efficiently.

The next step after loading the data is to create neural network models for testing.

First, we will create a small fully connected perceptron with one hidden layer of 40 elements and a result layer of 2 elements.

```
# Creating the first model with one hidden layer

model1 = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),

                           keras.layers.Dense(40, activation=tf.nn.swish),

                           keras.layers.Dense(targets, activation=tf.nn.tanh)

                         ])
```

After this, we create a callback object for early termination if the model's error on the training dataset doesn't decrease for more than five epochs. When compiling the model, we specify the Adam parameter optimization method and the standard deviation as a function of the model's training error. In addition to the error function to track the quality of training, we add the Accuracy metric, which shows the proportion of correct responses to the model.

```
callback = tf.keras.callbacks.EarlyStopping(monitor='loss', patience=5)

model1.compile(optimizer='Adam',

               loss='mean_squared_error',

               metrics=['accuracy'])

model1.summary()
```

Next, we create a second model, in which we simply add a batch normalization layer between the source data layer and the hidden model layer.

```
# Add batch normalization to the source data

# to a model with one hidden layer

model1bn = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),

                             keras.layers.BatchNormalization(),

                             keras.layers.Dense(40, activation=tf.nn.swish),

                             keras.layers.Dense(targets, activation=tf.nn.tanh)

                            ])
```

And we compile the model with the same parameters.

```
model1bn.compile(optimizer='Adam',

               loss='mean_squared_error',

               metrics=['accuracy'])

model1bn.summary()
```

The models for our first experiment are ready.

In the second experiment, I would like to evaluate the impact of using batch normalization within the network between hidden layers of the model. To conduct this experiment, we will also create fully connected perceptrons, but with three similar hidden layers. In the first model, we'll create a model without using batch normalization. Let's just take the first model from this script and add two hidden layers to it, similar to the first hidden layer. The source data and results layers remain unchanged.

```
# Create a model with three hidden layers

model2 = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),

                           keras.layers.Dense(40, activation=tf.nn.swish),

                           keras.layers.Dense(40, activation=tf.nn.swish),

                           keras.layers.Dense(40, activation=tf.nn.swish),

                           keras.layers.Dense(targets, activation=tf.nn.tanh)

                         ])
```

For the sake of experiment purity, we will compile the model with the same parameters.

```
model2.compile(optimizer='Adam',

               loss='mean_squared_error',

               metrics=['accuracy'])

model2.summary()
```

Now let's add a batch normalization layer before each hidden layer. Note that we do not add a batch normalization layer before the result layer, because the authors of the method do not recommend it. In their experiments, this worsened the results of the models.

```
# Add batch normalization for the source data and hidden layers of the second model

model2bn = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),

                             keras.layers.BatchNormalization(),

                             keras.layers.Dense(40, activation=tf.nn.swish),

                             keras.layers.BatchNormalization(),

                             keras.layers.Dense(40, activation=tf.nn.swish),

                             keras.layers.BatchNormalization(),

                             keras.layers.Dense(40, activation=tf.nn.swish),

                             keras.layers.Dense(targets, activation=tf.nn.tanh)

                            ])
```

As before, the model is compiled without changing the parameters.

```
model2bn.compile(optimizer='Adam',

               loss='mean_squared_error',

               metrics=['accuracy'])

model2bn.summary()
```

Now that all the models are built, we can start training them. All models will be trained with the same parameters. To train the model, we will use batches of 1000 patterns between weight matrix updates. Training will last for 500 epochs unless early stopping occurs. The last 10% of the training dataset will be used for validation. At the same time, the patterns will be mixed during the learning process.

First, let's train a model with one hidden layer using normalized data.

```
# Train the first model on non-normalized data

history1 = model1.fit(train_data, train_target,

                      epochs=500, batch_size=1000,

                      callbacks=[callback],

                      verbose=2,

                      validation_split=0.1,

                      shuffle=True)

model1.save(os.path.join(path,'perceptron1.h5'))
```

Next, we train the same model using non-normalized data.

```
# Train the first model on non-normalized data

history1nn = model1.fit(train_nn_data, train_nn_target,

                      epochs=500, batch_size=1000,

                      callbacks=[callback],

                      verbose=2,

                      validation_split=0.1,

                      shuffle=True)
```

Now we train a similar model using a batch normalization layer between the source data and the hidden layer. Training will be carried out on a non-normalized training dataset.

```
history1bn = model1bn.fit(train_nn_data, train_nn_target,

                      epochs=500, batch_size=1000,

                      callbacks=[callback],

                      verbose=2,

                      validation_split=0.1,

                      shuffle=True)

model1bn.save(os.path.join(path,'perceptron1bn.h5'))
```

The results of the first two trainings will serve as benchmarks for evaluating the model performance with the batch normalization layer.

At this stage, we gather enough information to draw a conclusion from the first experiment: data normalization during data preprocessing can be replaced with a batch normalization layer between the raw data and the trainable model.

Let's move on to working on the second experiment and determine the impact of the addition of a batch normalization layer before the hidden layer of the model on the training process and the overall performance of the trained model. To do this, we need to train two more models.

First, we train a model with three hidden layers using pre-normalized data. We use the same training parameters to train the model.

```
history2 = model2.fit(train_data, train_target,

                      epochs=500, batch_size=1000,

                      callbacks=[callback],

                      verbose=2,

                      validation_split=0.1,

                      shuffle=True)

model2.save(os.path.join(path,'perceptron2.h5'))
```

Next, we train the model using a non-normalized training dataset, but with a batch normalization layer before of each hidden layer. In particular, the batch normalization layer is also used before the first hidden layer after the source data layer.

```
history2bn = model2bn.fit(train_nn_data, train_nn_target,

                      epochs=500, batch_size=1000,

                      callbacks=[callback],

                      verbose=2,

                      validation_split=0.1,

                      shuffle=True)

model2bn.save(os.path.join(path,'perceptron2bn.h5'))
```

After training these two models, we have enough information to draw conclusions from the results of the second experiment. For clarity, let's create graphs showing the change in training and validation errors as a function of the number of training epochs.

First, let's plot the change in the standard deviation of the data of our models from the target data for the first experiment.

```
# Drawing model training results with one hidden layer

plt.plot(history1.history['loss'], label='Normalized inputs train')

plt.plot(history1.history['val_loss'], label='Normalized inputs validation')

plt.plot(history1nn.history['loss'], label='Unnormalized inputs train')

plt.plot(history1nn.history['val_loss'], label='Unnormalized inputs validation')

plt.plot(history1bn.history['loss'],

                        label='Unnormalized inputs\nvs BatchNormalization train')

plt.plot(history1bn.history['val_loss'],

                   label='Unnormalized inputs\nvs BatchNormalization validation')

plt.ylabel('$MSE$ $loss$')

plt.xlabel('$Epochs$')

plt.title('Model training dynamics\n1 hidden layer')

plt.legend(loc='upper right', ncol=2)
```

In addition to the first graph, let's plot the dynamics of changes in the Accuracy metric.

```
plt.figure()

plt.plot(history1.history['accuracy'], label='Normalized inputs train')

plt.plot(history1.history['val_accuracy'], label='Normalized inputs validation')

plt.plot(history1nn.history['accuracy'], label='Unnormalized inputs train')

plt.plot(history1nn.history['val_accuracy'], label='Unnormalized inputs validation')

plt.plot(history1bn.history['accuracy'],

                           label='Unnormalized inputs\nvs BatchNormalization train')

plt.plot(history1bn.history['val_accuracy'],

                      label='Unnormalized inputs\nvs BatchNormalization validation')

plt.ylabel('$Accuracy$')

plt.xlabel('$Epochs$')

plt.title('Model training dynamics\n1 hidden layer')

plt.legend(loc='lower right', ncol=2)
```

We build similar graphs to display the results of the second experiment.

```
# Drawing the results of training models with three hidden layers

plt.figure()

plt.plot(history2.history['loss'], label='Normalized inputs train')

plt.plot(history2.history['val_loss'], label='Normalized inputs validation')

plt.plot(history2bn.history['loss'],

                   label='Unnormalized inputs\nvs BatchNormalization train')

plt.plot(history2bn.history['val_loss'],

              label='Unnormalized inputs\nvs BatchNormalization validation')

plt.ylabel('$MSE$ $loss$')

plt.xlabel('$Epochs$')

plt.title('Model training dynamics\n3 hidden layers')

plt.legend(loc='upper right', ncol=2)
```

```
plt.figure()

plt.plot(history2.history['accuracy'], label='Normalized inputs train')

plt.plot(history2.history['val_accuracy'], label='Normalized inputs validation')

plt.plot(history2bn.history['accuracy'],

                       label='Unnormalized inputs\nvs BatchNormalization train')

plt.plot(history2bn.history['val_accuracy'],

                  label='Unnormalized inputs\nvs BatchNormalization validation')

plt.ylabel('$Accuracy$')

plt.xlabel('$Epochs$')

plt.title('Model training dynamics\n3 hidden layers')

plt.legend(loc='lower right', ncol=2)
```

So, at this stage, we have trained all the models using data from the training set. For us, the training dataset represents historical data. Of course, the fact that the model can approximate historical data is a good thing. But we would like the model to work well in real-time. To check how the model behaves on unknown data, let's check the operation of the models on a test sample.

We load the test dataset in the same way as we loaded the training datasets. First, let's load the normalized test dataset.

```
# Uploading a test dataset

test_filename = os.path.join(path,'test_data.csv')

test = np.asarray( pd.read_table(test_filename,

                   sep=',',

                   header=None,

                   skipinitialspace=True,

                   encoding='utf-8',

                   float_precision='high',

                   dtype=np.float64,

                   low_memory=False))
```

Now we divide the loaded data into patterns and target values.

```
# Separation of the test sample into initial data and goals

test_data=test[:,0:inputs]

test_target=test[:,inputs:]
```

Then we repeat the algorithm to load the non-normalized test dataset.

```
test_filename = os.path.join(path,'test_data_not_norm.csv')

test = np.asarray( pd.read_table(test_filename,

                   sep=',',

                   header=None,

                   skipinitialspace=True,

                   encoding='utf-8',

                   float_precision='high',

                   dtype=np.float64,

                   low_memory=False))
```

```
# Split the test dataset into initial data and goals

test_nn_data=test[:,0:inputs]

test_nn_target=test[:,inputs:]

del test
```

After copying the data, we delete the array of initial data, which will allow us to manage our resources more efficiently.

Next, we will test the operation of all models on test samples. We check the operation of models without batch normalization layers on normalized data. We will test models using batch normalization layers on non-normalized test sample data.

```
# Checking the results of models on a test sample

test_loss1, test_acc1 = model1.evaluate(test_data, test_target, verbose=2)

test_loss1bn, test_acc1bn = model1bn.evaluate(test_nn_data, test_nn_target,

                                                                verbose=2)

test_loss2, test_acc2 = model2.evaluate(test_data, test_target, verbose=2)

test_loss2bn, test_acc2bn = model2bn.evaluate(test_nn_data, test_nn_target,

                                                                verbose=2)
```

Testing results are output to the log.

```
# Output test results to the journal

print('Model 1 hidden layer')

print('Test accuracy:', test_acc1)

print('Test loss:', test_loss1)
```

```
print('Model 1 hidden layer with BatchNormalization')

print('Test accuracy:', test_acc1bn)

print('Test loss:', test_loss1bn)
```

```
print('Model 3 hidden layers')

print('Test accuracy:', test_acc2)

print('Test loss:', test_loss2)
```

```
print('Model 3 hidden layer with BatchNormalization')

print('Test accuracy:', test_acc2bn)

print('Test loss:', test_loss2bn)
```

For clarity, we make a graphical representation of the results separately for the standard deviation and for the Accuracy metric.

```
plt.figure()

plt.bar(['1 hidden layer','1 hidden layer\nvs BatchNormalization',

         '3 hidden layers','3 hidden layers\nvs BatchNormalization'],

        [test_loss1,test_loss1bn,test_loss2,test_loss2bn])

plt.ylabel('$MSE$ $Loss$')

plt.title('Test results')
```

```
plt.figure()

plt.bar(['1 hidden layer','1 hidden layer\nvs BatchNormalization',

         '3 hidden layers','3 hidden layers\nvs BatchNormalization'],

        [test_acc1,test_acc1bn,test_acc2,test_acc2bn])

plt.ylabel('$Accuracy$')

plt.title('Test results')

plt.show()
```

After creating the graphs, we call the command to render them on the user's screen.

With this, we conclude our work on the script that allows testing of how the use of batch normalization layer affects training results and model performance. We will get familiar with the results in the next section, dedicated to testing models.

## 6.Batch normalization backpropagation methods

In the previous sections, we began studying the algorithm of the batch normalization method. To implement it in our library, we have created a separate neural layer in the form of the CNeuronBatchNorm class and have even built methods for initializing the class of the feed-forward algorithm. Now it's time to move on to building the backpropagation algorithm for our class. Let me remind you that the backpropagation algorithm in all neural layers of our library is represented by four virtual methods:

- The CalcOutputGradient method for calculating the error gradient at the output of the neural network,

- The CalcHiddenGradient method for propagating the gradient through the hidden layer,

- The CalcDeltaWeights method for calculating weight adjustment values, and

- The UpdateWeights method for updating the weight matrix.

All of them were declared in our CNeuronBase neural layer base class. They are overridden in each new class as needed.

In this class, we will override only two methods: error gradient propagation through the hidden layer and the calculation of weight adjusting values.

We will not override the error gradient method at the output of the neural network because I do not know of a scenario where it would be necessary to use batch normalization as the last layer of a neural network. Moreover, experiments show that the use of batch normalization immediately before the neural network result layer can adversely affect the results of the model.

As for the method for updating the weight matrix, we intentionally designed the operation of the buffer for the matrix of trainable parameters in such a way that it became possible to use the method from the parent class to update its parameters.

Now let's move on to the practical part and look at the implementation of the specified CalcHiddenGradient backpropagation methods. This is a virtual method that was defined in the CNeuronBase neural layer base class. The method is overridden in each new class of the neural layer to implement a specific algorithm. In the parameters, the method receives a pointer to the object of the previous neural layer and returns the logical result of the operations.

In the method body, we add a control block in which we check the validity of pointers both to the previous layer object received in the parameters and to the internal objects used in the method operation. We have talked about the importance of such a process on multiple occasions because accessing an object through an invalid pointer leads to a critical error and a complete termination of the program.

```
bool CNeuronBatchNorm::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

//--- control block

   if(!prevLayer || !prevLayer.GetOutputs() || !prevLayer.GetGradients() ||

      !m_cActivation || !m_cWeights)

      return false;
```

Next, we need to adjust the error gradient obtained from the next layer to the derivative of the activation function of our layer. In the base class, we have encapsulated all the work with the activation function into a separate object of the CActivation class. Therefore, now, to adjust the error gradient, we should simply call the appropriate method of this class and provide a pointer to the error gradient buffer of our class as a parameter. As always, do not forget to check the result of the operation.

```
//--- adjust the error gradient to the derivative of the activation function

   if(!m_cActivation.Derivative(m_cGradients))

      return false;
```

After that, we check the size of the specified normalization batch. If it is not more than one, simply copy the gradient buffer data of the current layer to the buffer of the previous layer. Then we exit the method with the result of copying the data.

```
//--- check the size of the normalization batch

   if(m_iBatchSize <= 1)

     {

      prevLayer.GetGradients().m_mMatrix = m_cGradients.m_mMatrix;

      if(m_cOpenCL && !prevLayer.GetGradients().BufferWrite())

         return false;

      return true;

     }
```

Next, we sequentially calculate the gradients for all functions of the algorithm.

I suggest going through the process and looking at the mathematical formulas for the propagation of the error gradient. At the initial stage, we have the error gradient for the results of our normalization layer, which corresponds to the scaling and shifting function values. Let me remind you of the formula:

To adjust the error gradient, we need to multiply it by the derivative of the function. According to the rules for calculating the derivative for , the shift β acts as a constant and its derivative is zero. The derivative of the product is equal to the second factor. Thus, our derivative will be equal to the scaling factor γ.

where Gi is the gradient of the ith element at the output of the scaling and shift function.

In the method code, this operation will be expressed in the following lines.

```
//--- branching of the algorithm by computing device

   if(!m_cOpenCL)

     {

      MATRIX mat_inputs = prevLayer.GetOutputs().m_mMatrix;

      if(!mat_inputs.Reshape(1, prevLayer.Total()))

         return false;

      VECTOR inputs = mat_inputs.Row(0);

      CBufferType *inputs_grad = prevLayer.GetGradients();

      ulong total = m_cOutputs.Total();

      VECTOR gnx = m_cGradients.Row(0) * m_cWeights.Col(0);
```

Let's move on. We determine the normalized value using the formula.

From here, we need to distribute the error gradient to each of the components. I will not show the entire process of deriving partial differential formulas. I will only provide a ready-made formula for calculating the error gradient presented by the authors of the method in the article [Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift](https://arxiv.org/pdf/1502.03167.pdf).

The last two formulas will be needed for the next method, where we will propagate the error gradient to the level of the trainable parameter matrix. Therefore, in the code of this method, we implement only the formulas given above.

```
VECTOR temp = MathPow(MathSqrt(m_cBatchOptions.Col(1) + 1e-32), -1);

      VECTOR gvar = (inputs - m_cBatchOptions.Col(0)) /

                   (-2 * pow(m_cBatchOptions.Col(1) + 1.0e-32, 3.0 / 2.0)) * gnx;

      VECTOR gmu = temp * (-1) * gnx - gvar * 2 *

                          (inputs - m_cBatchOptions.Col(0)) / (TYPE)m_iBatchSize;

      VECTOR gx = temp * gnx + gmu / (TYPE)m_iBatchSize + gvar * 2 *

                          (inputs - m_cBatchOptions.Col(0)) / (TYPE)m_iBatchSize;
```

Note that the formulas are the sums of the values across the entire normalization dataset. We perform calculations only for the current value. Nevertheless, we do not deviate from the above formulas. The reason is that our dataset is stretched over time, and we return the error gradient at each step. During the period between updates of the trainable parameters of our class, we accumulate the error gradient on them, thereby summing it over the entire duration of our normalization dataset stretched along the time scale.

Now we only need to save the obtained error gradient into the corresponding element of the buffer and check the result of the operation.

```
if(!inputs_grad.Row(gx, 0))

         return false;

      if(!inputs_grad.Reshape(prevLayer.Rows(), prevLayer.Cols()))

         return false;

     }

   else  // OpenCL block

     {

      return false;

     }

//---

   return true;

  }
```

As a result of performing these operations, we obtained a filled buffer for the gradient tensor of the previous layer. So, the task set for this method has been completed, and we can conclude the branching of the algorithm depending on the used device. We will set a temporary stub for the block of organizing multi-threaded computing using OpenCL, as in similar cases when working with other methods. Thus, we finish working on our CNeuronBatchNorm::CalcHiddenGradient method at this point.

We will continue to organize the process of the backpropagation pass. Let's move on to the next method CNeuronBatchNorm::CalcDeltaWeights. Usually, this method is responsible for distributing the error gradient to the level of the weight matrix. But in our case, we have slightly different trainable parameters, on which we will distribute the error gradient.

The CalcDeltaWeights method like the previous one, receives a pointer to the object of the previous layer in the parameters. However, in this case, it is more of a fulfillment of the requirement of method inheritance than a functional necessity. The formulas for propagating the error gradient to trainable variables have already been provided above, but I will list them again for reference.

As can be seen from the above formulas, the error gradient of the parameters does not depend on the values of the previous layer. The gradient of the scaling coefficient depends on the normalized value, while the gradient of the bias is equal to the error gradient at the output of the batch normalization layer. Of course, the normalized value itself depends on the values of the previous layer. However, to avoid its recalculation, we simply saved the normalized values in a buffer with a feed-forward pass. Therefore, in the body of this method, we will not refer to the elements of the previous layer. Hence, there is no point in wasting time checking the resulting pointer to the previous layer. At the same time, we will not completely exclude the control block as we check not only external pointers but also pointers to internal objects.

```
bool CNeuronBatchNorm::CalcDeltaWeights(CNeuronBase *prevLayer, bool read)

  {

//--- control block

   if(!m_cGradients || !m_cDeltaWeights)

      return false;
```

After successfully passing the control block, we check the value of the normalization batch. It should be at least greater than one. Otherwise, we exit the method.

```
//--- check the size of the normalization batch

   if(m_iBatchSize <= 1)

      return true;
```

After successfully passing all the controls, we proceed to the direct implementation of the method algorithm. We always implement the algorithm in two versions: using standard MQL5 tools and using multi-threaded computing technology using OpenCL. Therefore, before continuing the operations, we will create a branching of the algorithm depending on the device used for computing operations.

```
//--- branching of the algorithm by the computing device

   if(!m_cOpenCL)

     {
```

In the branch of algorithm implementation using standard MQL5 tools we will use matrix operations. According to the formulas provided above, we determine the error gradient for the scaling coefficient and the bias. We add the obtained values to the previously accumulated error gradients of the corresponding elements and update the values in the error gradient accumulation buffer.

```
VECTOR grad = m_cGradients.Row(0);

      VECTOR delta = m_cBatchOptions.Col(2) * grad + m_cDeltaWeights.Col(0);

      if(!m_cDeltaWeights.Col(delta, 0))

         return false;

      if(!m_cDeltaWeights.Col(grad + m_cDeltaWeights.Col(1), 1))

         return false;
```

After completing all the operations, we will have a fully updated error gradient buffer at the level of the batch normalization layer's trainable parameters. In other words, the task for this method is solved, and we close the branch of the algorithm depending on the computing device, along with the entire method. However, first, we add a stub in the block of the multi-threaded computing algorithm using OpenCL.

```
}

   else  // OpenCL block

     {

      return false;

     }

//---

   return true;

  }
```

Above, we have redefined two methods from the backpropagation algorithm. The method of updating the weights, and in this case the trained parameters, was inherited from the parent class. Thus, the work on the backpropagation methods in terms of the organization of the process using standard MQL5 tools can be considered complete. Let's move on to the file handling methods.

## 6.Batch normalization feed-forward methods

We continue moving forward along the path of building the batch normalization class, and simultaneously, along the path of understanding the structure and methods of organizing neural networks. Earlier, we discussed various architectures for constructing neural layers to solve practical tasks. However, the operation of the batch normalization layer is equally important in organizing the functioning of a neural network, although its task may not be immediately apparent. Rather, it is hidden within the organization of the processes of the neural network itself and serves more for the stability of our model.

We have already built the class initialization methods. Now it's time to build the algorithm of method operation directly. We begin this process with the FeedForward method. This method is declared virtual in the CNeuronBase neural layer base class of our library and is overridden in each new class.

I would like to remind you that this approach allows us to eliminate the use of dispatch methods and functions for reallocating information flows and calling various methods depending on the class of the object being used. In practice, we can simply pass a pointer to any derived object into a local variable of the base class of the neural layer and call the method declared in the base class. At the same time, the system will perform all dispatching functions without our participation. It will call the method related to the actual type of the object.

This property is exactly what we exploit when expecting to receive a pointer to an object of the base class of the neural layer in the method parameters. At the same time, a pointer to any of the neural layer objects in our library can be passed in the parameters. We can work with it through the use of overridden virtual functions.

The operation of the feed-forward method itself starts with a control block for checking pointers to the objects used by the method. Here we check both the pointer to the object of the previous layer obtained in the parameters and pointers to internal objects.

```
bool CNeuronBatchNorm::FeedForward(CNeuronBase *prevLayer)

  {

//--- control block

   if(!prevLayer || !prevLayer.GetOutputs() || !m_cOutputs ||

      !m_cWeights || !m_cActivation)

      return false;
```

Please note that along with other objects, we also check the pointer to the activation function object. Although the batch normalization algorithm does not use an activation function, we will not limit the user's capabilities and will provide them with the option to use an activation function as they see fit. Moreover, there are practical cases where applying an activation function after data normalization is beneficial. For example, the method authors recommend normalizing data immediately before applying the activation function. At first glance, applying such an approach would require modifications to every previously discussed class. However, we can implement the same functionality without modifying the existing classes. We simply need to declare the required neural layer without an activation function, followed by a normalization layer with the desired activation function. Therefore, I believe the use of the activation feature in our class is justified.

Next, we will branch the algorithm for a case when the normalization batch size is equal to 1 or less. It should be understood that when the batch is equal to 1, no normalization is performed, and we simply pass the tensor of the original data to the output of the neural layer. After completing the data copy from the buffer, we call the activation method and exit the method after verifying the results of the operations.

```
//--- check the size of the normalization batch

   if(m_iBatchSize <= 1)

     {

      m_cOutputs.m_mMatrix = prevLayer.GetOutputs().m_mMatrix;

      if(m_cOpenCL && !m_cOutputs.BufferWrite())

         return false;

      if(!m_cActivation.Activation(m_cOutputs))

         return false;

      return true;

     }
```

Next, we need to construct the algorithm of the method. Following the concept we have adopted, we will create two variants of the algorithm implementation: by standard MQL5 tools and in the multi-threaded calculations mode using OpenCL. Therefore, next, we create another branching of the algorithm depending on the user's choice of the computational device. In this section, we will consider the construction of the algorithm using MQL5. In further sections, we will return to the construction of the algorithm using OpenCL.

```
//--- branching of the algorithm over the computing device

   if(!m_cOpenCL)

     {
```

We start the block of operations using MQL5 with a small preparatory work. To simplify the process of accessing the data, we save a sequence of raw data into a local matrix.

```
MATRIX inputs = prevLayer.GetOutputs().m_mMatrix;

      if(!inputs.Reshape(1, prevLayer.Total()))

         return false;
```

According to the data normalization algorithm, we find the mean value. In considering the architecture of our solution, we have decided to use an exponential moving average, which is determined by the formula.

```
VECTOR mean = (m_cBatchOptions.Col(0) * ((TYPE)m_iBatchSize - 1.0) +

                     inputs.Row(0)) / (TYPE)m_iBatchSize;
```

After determining the moving average, we find the average variance.

```
VECTOR delt = inputs.Row(0) - mean;

      VECTOR variance = (m_cBatchOptions.Col(1) * ((TYPE)m_iBatchSize - 1.0) +

                         MathPow(delt, 2)) / (TYPE)m_iBatchSize;
```

Once the mean and variance values are found, we can easily compute the normalized value of the current element in the sequence.

```
VECTOR std = sqrt(variance) + 1e-32;

      VECTOR nx = delt / std;
```

Note that we add a small constant to the variance to eliminate the potential zero division error.

The next step of the batch normalization algorithm is shift and scaling.

```
VECTOR res = m_cWeights.Col(0) * nx + m_cWeights.Col(1);
```

After that, we only need to save the obtained values into the respective elements of the buffers. Please note that we save not only the results of the algorithm operations in the result buffer but also our intermediate values in the normalization parameters buffer. We will need them in subsequent iterations of the algorithm. Do not forget to check the results of the operations.

```
if(!m_cOutputs.Row(res, 0) ||

         !m_cBatchOptions.Col(mean, 0) ||

         !m_cBatchOptions.Col(variance, 1) ||

         !m_cBatchOptions.Col(nx, 2))

         return false;

     }

   else  // OpenCL block

     {

      return false;

     }
```

This completes the algorithm splitting depending on the computing device used. As always, we will set a temporary stub for the OpenCL block in the form of a false value return. We will return to this part later.

Now, before exiting the method, we activate the values in the result buffer of our class. To do this, we call the Activation method of our special object to work with the m_cActivation activation function. After checking the result of the operation, we terminate the method.

```
if(!m_cActivation.Activation(m_cOutputs))

      return false;

//---

   return true;

  }
```

With that, we conclude our work on the feed-forward method of the CNeuronBatchNorm batch normalization class. I hope that understanding the logic behind its construction wasn't difficult for you. Now, let's move on to building the backpropagation methods.

## 6.File operations

We are confidently approaching the completion of work on the methods of the CNeuronBatchNorm batch normalization class. Previously, we have already built methods for initializing the class, as well as built an algorithm for the operation of feed-forward and backpropagation passes using standard MQL5 capabilities. Let's move on to working on file handling methods. We have discussed the importance of having and correctly functioning these methods several times as the performance of these methods determines how quickly we can deploy a trained model into operational use.

We have already done similar work more than once for other classes in our library. Now we will follow the same established algorithm. First, we evaluate the need to write each element of the class to the data file. In the structure of our class, we have created only one new data buffer and one variable. Both of these elements are important for organizing correct object operations in our class. Therefore, we save both elements to a data file.

```
class CNeuronBatchNorm    :  public CNeuronBase

  {

protected:

   CBufferType       m_cBatchOptions;

   uint              m_iBatchSize;       // batch size

public:

                     CNeuronBatchNorm(void);

                    ~CNeuronBatchNorm(void);

   //---

   virtual bool      Init(const CLayerDescription* description) override;

   virtual bool      SetOpenCL(CMyOpenCL *opencl) override;

   virtual bool      FeedForward(CNeuronBase* prevLayer) override;

   virtual bool      CalcHiddenGradient(CNeuronBase* prevLayer) override;

   virtual bool      CalcDeltaWeights(CNeuronBase* prevLayer,bool read)override;

   //--- methods for working with files

   virtual bool      Save(const int file_handle) override;

   virtual bool      Load(const int file_handle) override;

   //--- object identification method

   virtual int       Type(void)  override   const {return defNeuronBatchNorm;}

  };
```

Having determined the scope of our work, we now proceed directly to creating the file handling methods for our class. As always, the first step is to create the CNeuronBatchNorm::Save method for writing data to the file. Like all the methods we have discussed so far, this one is also created as a virtual method in the base neural layer class and is overridden in each new neural layer class to fully save all the necessary information for subsequent restoration of the correct operation of the saved objects. In parameters, the method receives a file handle of to write the data.

```
bool CNeuronBatchNorm::Save(const int file_handle)

  {

//--- call the method of the parent class

   if(!CNeuronBase::Save(file_handle))

      return false;
```

The obtained file handle for writing data is not checked, as this control is already implemented in the same-named method of the parent class, which is called in the body of this method. Thus, we check the result of the operations of the method of the parent class.

```
if(!CNeuronBase::Save(file_handle))

      return false;
```

It is very convenient to use the method of the parent class. This usage serves a dual purpose. The first purpose is a control function because the parent class already implements a set of controls that do not need to be duplicated in the new method. We only need to call the parent class method and check its execution result. The second purpose is functional. The method of the parent class already stores all inherited objects and variables. Here, it's the same situation: we call the parent class method once, thereby saving all inherited objects and variables. Convenient, isn't it? Moreover, we do not need to call the method for each individual functionality. With one call, we accomplish two tasks: control and saving of inherited objects. Checking the result of the function execution confirms the correct execution of both functions of the method.

After successfully executing the parent class method, we understand that the handle to the file provided as a parameter is valid. Now we can proceed with further file operations without the risk of getting a critical error. First, we save the normalization batch size, which is stored in the m_iBatchSize variable. Also, we make sure to check the result of the operation.

```
//--- save the size of the normalization batch

   if(FileWriteInteger(file_handle, m_iBatchSize) <= 0)

      return false;
```

At the end of the method, we save the buffer of m_cBatchOptions normalization parameters. To do this, we just call the corresponding method of the specified object and check its operation result.

```
//--- save normalization settings

   if(!m_cBatchOptions.Save(file_handle))

      return false;

//---

   return true;

  }
```

As you can see, by using parent class methods and internal objects, we have described the method for saving all the necessary information easily and quite concisely. The main data saving controls and operations are hidden in these methods.

Similarly, let's create a method for loading data from the CNeuronBatchNorm::Load file. It should be noted that this method is responsible not only for reading data from a file but also for fully restoring the functionality of the object to the state at the time of data saving. Therefore, this method should include operations for creating instances of objects required for the correct functioning of our batch normalization class. In addition, we must initialize all unsaved objects and variables with initial values.

In the parameters, the CNeuronBatchNorm::Load method, like the previous data saving method, receives the handle of the file with the saved data. We have to organize the reading of data from the file in strict accordance with the sequence of their writing to the file. This time, in the body of the method, we immediately call the method of the parent class. The calculation here is the same: by calling the parent class method once, we immediately execute the entire functionality with inherited objects and variables. At the same time, we only need to check the result of the parent class method once to ensure the correctness of all its operations.

```
bool CNeuronBatchNorm::Load(const int file_handle)

  {

//--- call the method of the parent class

   if(!CNeuronBase::Load(file_handle))

      return false;
```

After the successful execution of the parent class method, we move on to loading the data of the objects of the batch normalization class. According to the sequence in which the data is written to the file, we first read the size of the normalization batch.

```
m_iBatchSize = FileReadInteger(file_handle);
```

Finally, it remains to load the buffer data of the m_cBatchOptions normalization parameters.

```
//--- initialize a dynamic array of optimization parameters

   if(!m_cBatchOptions.Load(file_handle))

      return false;

//---

   return true;

  }
```

After successfully loading all the data, we will conclude the method execution with a positive result.

We have finished creating a batch data normalization layer using standard MQL5 tools. To complete the work on the CNeuronBatchNorm class, we need to supplement its functionality with the ability to perform multi-threaded mathematical operations using OpenCL. We'll do that in the next section. But now we have the opportunity to conduct the first tests.

## Building Dropout in MQL5

After discussing the theoretical aspects, I suggest moving on to studying the implementation of this method in our library.

To implement the Dropout algorithm, we will create a new class called CNeuronDropout, which we will include in our model as a separate layer. The new class will inherit directly from the CNeuronBase neural layer base class.

```
class CNeuronDropout    :  public CNeuronBase

  {

protected:

   TYPE              m_dOutProbability;

   int               m_iOutNumber;

   TYPE              m_dInitValue;

   CBufferType       m_cDropOutMultiplier;

public:

                     CNeuronDropout(void);

                    ~CNeuronDropout(void);

   //---

   virtual bool      Init(const CLayerDescription *desc) override;

   virtual bool      FeedForward(CNeuronBase *prevLayer) override;

   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;

   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer, bool read)

                                                     override { return true; }

   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,

                       VECTOR &Beta, VECTOR &Lambda) override { return true; }

   //--- methods of working with files

   virtual bool      Save(const int file_handle) override;

   virtual bool      Load(const int file_handle) override;

   //--- object identification method

   virtual int       Type(void) override    const { return defNeuronDropout; }

  };
```

The first thing we encounter is the implementation of two different algorithms: one for the training process and another for testing and application. Therefore, we need to explicitly specify to the neural layer which algorithm it should use in each specific case. To do this, we introduce the m_bTrain flag which we will set to true during training and to false during testing.

To control the values of the flag, we will create a helper overload method TrainMode. In one version, when specifying a parameter, it will set a flag, and in the other variant, when called without parameters, it will return the current value of the m_bTrain flag.

```
virtual void      TrainMode(bool flag)       {  m_bTrain = flag; }

   virtual bool      TrainMode(void)      const {  return m_bTrain; }
```

While working with the library, we built a mechanism for overriding the methods of all classes. By doing so, we created a versatile class architecture, allowing the dispatcher class of our model to work uniformly with any neural layer, without spending time on checking the type of the neural layer and branching algorithms based on the type of the neural layer used. To support this concept, we will introduce a flag variable and methods for working with it at the level of the CNeuronBase base neural layer.

In the protected block of our class, we declare the following variables:

- m_dOutProbability — specified probability for dropping out neurons

- m_iOutNumber — number of neurons to be dropped out

- m_dInitValue — value for initializing the masking vector, in the theoretical part of this article we denoted this coefficient as 1/q

Also, we will declare a pointer to the data buffer object for the m_cDropOutMultiplier masking vector.

The list of class methods is quite familiar. They all override the methods of the parent class.

Note that our new layer does not have weight matrices. The override of the CalcDeltaWeights and UpdateWeights methods which are responsible for distributing the error gradient to the weight matrix and updating the model parameters, is designed to maintain the overall architecture of the neural layers and the model as a whole. We cannot use methods from the parent class because the absence of corresponding objects would lead to a critical error. The creation of additional unused objects is an irrational waste of resources. Therefore, we override the methods. However, we create them as empty methods and they will simply always return a positive value.

```
virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer, bool read)

                                                     override { return true; }

   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,

                       VECTOR &Beta, VECTOR &Lambda) override { return true; }
```

Now let's proceed with the class methods. We will start, as always, with the class constructor. In this method, we specify the default value of the variables. Using a static object for the mask vector buffer allows us to skip the operation of creating it in the constructor and deleting it in the destructor.

```
CNeuronDropout::CNeuronDropout(void)   :  m_dInitValue(1.0),

                                          m_dOutProbability(0),

                                          m_iOutNumber(0)

  {

   m_bTrain = false;

  }
```

Note that the values of the m_bTrain class mode flag, unlike other variables, are specified in the body of the method. This is due to the declaration of a variable in the parent class.

The method destructor remains empty.

Next comes the initialization method of the CNeuronDropout::Init class. In the parameters, the method receives a pointer to an object of the class describing the created neural layer. In the body of the method, we immediately check the validity of the received pointer as well as the compatibility of the dimensions of the created neural layer and the previous one. The only role of the Dropout layer is to mask neurons, while the size of the tensor does not change in any way.

```
bool CNeuronDropout::Init(const CLayerDescription *description)

  {

//--- control block

   if(!description || description.count != description.window)

      return false;
```

After successfully passing the control block, we reset the size of the input data window and call the initialization method of the parent class. Resetting the size of the input data window will instruct the parent class method not to create a weight matrix and other objects related to training the neural layer parameters. As always, we remember to check the results of the operations.

```
//--- calling a method of a parent class

   CLayerDescription *temp = new CLayerDescription();

   if(!temp || !temp.Copy(description))

      return false;

   temp.window = 0;

   if(!CNeuronBase::Init(temp))

      return false;

   delete temp;
```

After the successful execution of the parent class method, we save the main parameters of the neural layer operation, including the dropout probability, the number of neurons to exclude, and the initialization value of the masking matrix. We obtain the first parameter from the user, while the other two parameters should be calculated.

```
//--- calculation of coefficients

   m_dOutProbability = (TYPE)MathMin(description.probability, 0.9);

   if(m_dOutProbability < 0)

      return false;

   m_iOutNumber = (int)(m_cOutputs.Total() * m_dOutProbability);

   m_dInitValue = (TYPE)(1.0 / (1.0 - m_dOutProbability));
```

After that, we initialize the masking buffer with the initial values and set the training flag to true.

```
//--- initiate the masking buffer

   if(!m_cDropOutMultiplier.BufferInit(m_cOutputs.Rows(), m_cOutputs.Cols(),

                                                              m_dInitValue))

      return false;

   m_bTrain = true;

//---

   return true;

  }
```

This completes the work with the class initialization methods and proceeds to the actual creation of the algorithm of the Dropout method.

But first, let's recall that we don't have access to the neural layer directly from the main program. Now we have introduced a flag for the neural layer operation mode. Therefore, we need to go back to the dispatcher class of the model and add a method for changing the state of the flag.

```
void CNet::TrainMode(bool mode)

  {

   m_bTrainMode = mode;

   int total = m_cLayers.Total();

   for(int i = 0; i < total; i++)

     {

      if(!m_cLayers.At(i))

         continue;

      CNeuronBase *temp = m_cLayers.At(i);

      temp.TrainMode(mode);

     }

  }
```

In this method, we will save the flag value into a local variable and iterate through all the neural layers of the model in a loop, calling a similar method for each neural layer of the model.

## Organizing multi-threaded operations in Dropout

We continue to implement the Dropout technology. In the previous sections, we have already fully implemented the algorithm for the operation of this technology using standard MQL5 capabilities. Now we move on to implementing the algorithm using the multi-threading capability on the GPU using OpenCL. Within the framework of this book, we performed this operation many times before. However, I would like to repeat that in order to implement it, we need to work in two directions. First, we will create an OpenCL program, and then we need to do the work on the side of the main program to implement data exchange between the main program and the OpenCL context in which the program will run and call the OpenCL program.

As always, this work begins with the creation of the OpenCL program. In this case, we don't have to write much code on the OpenCL side. Moreover, we will use the same kernel to implement both feed-forward and backpropagation passes. How did that happen? Let's recall what operations we need to implement.

In the feed-forward pass, we perform data masking. The vector mask is created using MQL5 on the main program side. Here we need to mask the initial data. To do this, we element-wise multiply the initial data tensor by the vector mask.

Therefore, for the feed-forward pass, we need to create a kernel for element-wise multiplication of two tensors of the same size.

During the backpropagation process, an error gradient must be propagated through the masking operation. Let's take a closer look at the formula for the masking operation. 1/q is a constant that is defined at the class initialization stage and does not change throughout the model training and operation process. xi is a masking vector element that can only take two values: 1 or 0. Therefore, the entire masking process can be represented as multiplying a certain original value by a constant. As you know, the derivative of such an operation is the constant by which multiplication is performed.

In our case, to adjust the error gradient, we need to element-wise multiply the gradient of error of the current layer by the masking vector.

Thus, in the feed-forward and backpropagation passes, we element-wise multiply various tensors by the masking vector. Therefore, to implement both passes on the OpenCL side, it is sufficient to create one kernel of element-wise multiplication of two vectors. This is actually a fairly simple task. Using vector variables to optimize the process does not complicate the task.

To do this, we create the MaskMult masking kernel. In the parameters, this kernel receives pointers to three data buffers, two of which contain the input data, and the third one is used to write the results. Also, since vector operations are implied, the total number of threads will be smaller than the number of operations. So we won't be able to determine the size of the initial data tensors from the number of threads running. Therefore, to determine the dimensions of the tensors, we will transmit the necessary dimension information in kernel parameters.

In the body of the kernel, we define the ID of the current thread and transfer the necessary data from the buffers to local vector variables. Let's multiply two vector variables. The result obtained will be returned from the local vector variable to the scalar data buffer.

```
__kernel void MaskMult(__global TYPE *inputs,

                       __global TYPE *mask,

                       __global TYPE *outputs,

                       int outputs_total)

  {

   const int n = get_global_id(0) * 4;

//---
```

As you can see, the entire kernel code fits into three lines. Of course, this was made possible by using the previously created [functions that translate the data](https://www.mql5.com/en/neurobook/index/realization/pr_opencl/opencl_programm#tovect4) of the scalar buffer to and from a local vector variable.

Once the OpenCL kernel is created, we proceed to implement the functionality on the main program side. First, we need to create constants to refer to OpenCL program elements. To do this, we open the [defines.mqh](https://www.mql5.com/en/neurobook/index/realization/basic/constants) file and specify constants for the kernel and its parameters.

```
#define def_k_MaskMult                40
```

```
//--- data masking

#define def_mask_inputs                0

#define def_mask_mask                  1

#define def_mask_outputs               2

#define def_mask_total                 3
```

Then we move on to the model dispatcher class. In the OpenCL context initialization method, we change the total number of kernels and then create a kernel in the context.

```
bool CNet::InitOpenCL(void)

  {

   ......

   if(!m_cOpenCL.SetKernelsCount(41))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }

   ......
```

```
if(!m_cOpenCL.KernelCreate(def_k_MaskMult, "MaskMult"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }

//---

   return true;

  }
```

Once the preparatory work has been completed, we move on to working directly with the methods of our CNeuronDropout class. As always, let's start with the CNeuronDropout::FeedForward method and implement the following processes in this method:

- Pass information to the OpenCL context.

- Pass parameters to the OpenCL kernel.

- Place the kernel in the run queue.

- Download the kernel results.

- Clear context memory.

Moving on to the forward pass method. Changes will only affect the multi-threaded operation block, and the rest of the method code will remain unchanged.

The Dropout class can operate in two modes: training and production use. We have created a kernel for training mode, but have not prepared a kernel for the second case. For example, the operation of copying data from buffer to buffer is easy, and we can perform it with MQL5 tools. However, we have minimized data exchange between the OpenCL context and the main program. So, on the main program side, the content of the buffers will be irrelevant. To perform a data copy operation, you must first load the data from the OpenCL context into the main program memory and then copy the data from one buffer to another. You then need to return the data to the OpenCL context in another buffer for subsequent operations. This is totally inconsistent with our policy of minimizing data exchange between the OpenCL context and the main program.

We consider the second option: the use of a single kernel in two operation modes. In production use mode, the masking buffer is filled with units. It's also a working method. At the same time, we prepare the masking buffer on the side of the main program. OpenCL does not provide a pseudo-random number generator. So, before executing the kernel, we should pass the contents of the masking buffer from the main program to the OpenCL context. But in training mode, it's a coercive measure. Why waste time on this unnecessary operation in the use mode? Can we take a step back and prepare another kernel?

I found another solution. We already have a kernel to perform a linear activation function. Below is its mathematical representation.

If we consider the special case at a=1 and b=0, we get a simple copy of the data.

You do not need to load additional buffers into the OpenCL context memory. Instead, we will only pass two integer values into the parameters.

The algorithm for working with the kernel remains the same: check the presence of buffers in the context's memory, pass the kernel parameters, and enqueue the kernel.

```
bool CNeuronDropout::FeedForward(CNeuronBase *prevLayer)

  {

   ......

//--- branching of the algorithm depending on the execution device

   if(!m_cOpenCL)

     {

   ......

     }

   else  // OpenCL block

     {

      //--- operation mode flag check

      if(!m_bTrain)

        {

         //--- check data buffers

         CBufferType *inputs = prevLayer.GetOutputs();

         if(inputs.GetIndex() < 0)

            return false;

         if(m_cOutputs.GetIndex() < 0)

            return false;

         //--- pass parameters to the kernel

         if(!m_cOpenCL.SetArgumentBuffer(def_k_LineActivation,

                                             def_activ_inputs, inputs.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_LineActivation,

                                        def_activ_outputs, m_cOutputs.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgument(def_k_LineActivation,

                                                      def_activ_param_a, (TYPE)1))

            return false;

         if(!m_cOpenCL.SetArgument(def_k_LineActivation,

                                                      def_activ_param_b, (TYPE)0))

            return false;

         uint offset[] = {0};

         uint NDRange[] = {(uint)m_cOutputs.Total()};

         if(!m_cOpenCL.Execute(def_k_LineActivation, 1, offset, NDRange))

            return false;

        }
```

To organize work during training, we will repeat the algorithm mentioned above by enqueueing a new kernel.

```
else

        {

         //--- check data buffers

         CBufferType *inputs = prevLayer.GetOutputs();

         if(inputs.GetIndex() < 0)

            return false;

         if(!m_cDropOutMultiplier.BufferCreate(m_cOpenCL))

            return false;

         if(m_cOutputs.GetIndex() < 0)

            return false;

         //--- pass parameters to the kernel

         if(!m_cOpenCL.SetArgumentBuffer(def_k_MaskMult,

                                             def_mask_inputs, inputs.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_MaskMult,

                                 def_mask_mask, m_cDropOutMultiplier.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_MaskMult,

                                        def_mask_outputs, m_cOutputs.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgument(def_k_MaskMult, def_mask_total, total))

            return false;

         //--- enqueuing

         int off_set[] = {0};

         int NDRange[] = { (int)(total + 3) / 4};

         if(!m_cOpenCL.Execute(def_k_MaskMult, 1, off_set, NDRange))

            return false;

        }

     }

//---

   return true;

  }
```

This concludes the feed-forward kernel. Let's proceed to implement similar operations for the CNeuronDropout::CalcHiddenGradient backpropagation method. Let me remind you that we will use the same kernels for the backpropagation pass in this case. The call algorithm does not change. Changes will only affect the specification of buffers used.

```
bool CNeuronDropout::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

   ......

//--- branching of the algorithm depending on the execution device

   ulong total = m_cOutputs.Total();

   if(!m_cOpenCL)

     {

   ......

     }
```

```
else  // OpenCL block

     {

      //--- operation mode flag check

      if(!m_bTrain)

        {

         //--- checking data buffers

         CBufferType *grad = prevLayer.GetGradients();

         if(grad.GetIndex() < 0)

            return false;

         if(m_cGradients.GetIndex() < 0)

            return false;

         //--- passing parameters to the kernel

         if(!m_cOpenCL.SetArgumentBuffer(def_k_LineActivation,

                                def_activ_inputs, m_cGradients.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_LineActivation,

                                       def_activ_outputs, grad.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgument(def_k_LineActivation,

                                               def_activ_param_a, (TYPE)1))

            return false;

         if(!m_cOpenCL.SetArgument(def_k_LineActivation,

                                               def_activ_param_b, (TYPE)0))

            return false;

         uint offset[] = {0};

         uint NDRange[] = {(uint)m_cOutputs.Total()};

         if(!m_cOpenCL.Execute(def_k_LineActivation, 1, offset, NDRange))

            return false;

        }
```

Operation mode during training.

```
else

        {

         //--- check data buffers

         CBufferType* prev = prevLayer.GetGradients();

         if(prev.GetIndex() < 0)

            return false;

         if(m_cDropOutMultiplier.GetIndex() < 0)

            return false;

         if(m_cGradients.GetIndex() < 0)

            return false;

         //--- pass parameters to the kernel

         if(!m_cOpenCL.SetArgumentBuffer(def_k_MaskMult,

                                         def_mask_inputs, m_cGradients.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_MaskMult,

                                   def_mask_mask, m_cDropOutMultiplier.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_MaskMult,

                                                def_mask_outputs, prev.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgument(def_k_MaskMult, def_mask_total, total))

            return false;

         //--- enqueuing

         int off_set[] = {0};

         int NDRange[] = { (int)(total + 3) / 4 };

         if(!m_cOpenCL.Execute(def_k_MaskMult, 1, off_set, NDRange))

            return false;

        }

     }

//---

   return true;

  }
```

Note that in the backpropagation process, we no longer load masking data into the OpenCL context. We expect it to remain in context with the feed-forward method.

Congratulations, we have completed the work on the methods of the Dropout algorithm implementation class. We've done quite a lot of work and implemented the Dropout algorithm with MQL5 and multi-threaded operations using OpenCL. Now we can test the models. But first, I suggest considering the implementation of this approach in Python in the TensorFlow library.

## 6.Backpropagation methods for Dropout

Traditionally, after implementing the feed-forward algorithm, we move on to organizing the backpropagation process. As you know, in the base class of the neural layer, the backpropagation algorithm is implemented by four virtual methods:

- CalcOutputGradient for calculating the error gradient at the output of a neural network

- CalcHiddenGradient for propagating a gradient through a hidden layer

- CalcDeltaWeights for the required calculation of weight correction values

- UpdateWeights for updating the weight matrix

All the above methods are overridden in new classes as needed. As mentioned earlier, our Dropout layer does not contain trainable parameters. As a consequence, it does not contain a weight matrix. Thus, the last two methods are not relevant to our class. At the same time, we will have to override these methods to maintain the integrity of our model architecture because, during training, it will call these methods for all the neural layers used. If we do not override them, then when these methods are called, the operations of the inherited parent method will be performed. In this case, the absence of a buffer of the weight matrix and related objects can lead to critical errors. In the best-case scenario, as a result of our control operation, we will terminate the method with a false result, which will lead to the interruption of the training process. Therefore, we override these methods and replace them with empty methods that will always return a positive result.

```
virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer, bool read)

                                                        override { return true; }

   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,

                          VECTOR &Beta, VECTOR &Lambda) override { return true; }
```

The CalcOutputGradient method is used only for the results layer. Dropout operation principles do not imply its use as a results layer. Therefore, we do not override it.

Thus, we only have one method left to override: the CalcHiddenGradient method that propagates the gradient through the hidden layer. This method, like most of the previous ones, is declared as virtual in the base neural network class and is overridden in all new classes to establish the specific algorithm of the neural layer operation. In the parameters, the method receives a pointer to the object of the previous layer. Right within the method body, we set up a control block to verify the validity of pointers to objects used by the method. As in the feed-forward method, we check pointers to all used objects, both external and internal.

```
bool CNeuronDropout::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

//---control block

   if(!prevLayer || !prevLayer.GetGradients() || !m_cGradients)

      return false;
```

After successfully passing the block of controls, we must create a branching of the algorithm depending on the computing device. As always, in this section, we will consider the implementation of the algorithm using MQL5 tools and will return to the multi-threaded implementation of the algorithm in the next section.

```
//--- branching of the algorithm depending on the execution device

   ulong total = m_cOutputs.Total();

   if(!m_cOpenCL)

     {
```

In the implementation block using MQL5, we check the class operating mode. During operational use mode, we simply copy the data from the error gradient buffer of the current layer into a similar buffer of the previous layer.

```
//--- check the operating mode flag

      if(!m_bTrain)

         prevLayer.GetGradients().m_mMatrix = m_cGradients.m_mMatrix;

      else

         prevLayer.GetGradients().m_mMatrix = m_cGradients.m_mMatrix *

                                              m_cDropOutMultiplier.m_mMatrix;

     }

   else  // OpenCL block

     {

      return false;

     }

//---

   return true;

  }
```

If the method operates in model training mode, according to the Dropout algorithm, we need to multiply the error gradient buffer of the current layer element-by-element by the masking vector buffer. The matrix multiplication operation allows us to do this literally in one line of code.

As you can see, at this stage we have passed the error gradient into the buffer of the previous layer. Therefore, the task set for this method is completed, and we can finish the method execution. Now we add a stub in the block for organizing multi-threaded operations. We will return to it in one of the subsequent sections.

Thus, we have fully implemented the Dropout algorithm using standard MQL5 tools. At this stage, you can already create a model and obtain initial results using this approach. However, as we have discussed before, it is equally important to have the capability to restore the previously trained model functionality at any convenient time for the full functionality of any neural layer within the model. Therefore, in the next section, we will look at methods for saving neural layer data and restoring the functioning of the layer from previously saved data.

## 6.Feed-forward method

The feed-forward pass is traditionally implemented in the FeedForward method. This method is declared virtual in the neural layer base class. It is overridden in each new class to build a specific algorithm for the class. We will do the same for this particular class, that is, we will also override this method.

In the parameters, the CNeuronDropout::FeedForward method receives a pointer to the object of the previous layer of our model. Within the method body, we immediately set up control blocks to check the pointers to objects used in this method. As usual, here we check not only pointers to external objects received in parameters but also to internal objects of the class. In this case, we will check the pointers to the previous layer object and its result buffer. We will also check the validity of the pointer to the result buffer of the current layer.

```
bool CNeuronDropout::FeedForward(CNeuronBase *prevLayer)

  {

//--- control block

   if(!prevLayer || !prevLayer.GetOutputs() || !m_cOutputs)

      return false;
```

After successfully passing the control block, we proceed to execute the algorithm of the Dropout method.

To execute the algorithm in training mode, we prepare a masking buffer. First, we fill the entire buffer with increasing coefficients 1/q, which we stored in the m_dInitValue variable at the class initialization stage.

After that, we create a loop with the number of iterations equal to the number of elements to be dropped out. In the loop body, we generate random values from the range between 0 and the number of elements of the sequence. For randomly selected elements, we replace the multiplier in the masking buffer with 0.

Although lightning never strikes twice in the same place, let's provide an algorithm for the case when the same element falls out twice. Before writing 0 to the masking buffer, we first check the current coefficient for the dropped element. If it is equal to zero, then we decrease the value of the loop iteration counter and move on to selecting the next element. This approach will allow us to exclude the specified number of elements precisely.

```
//--- generate a data masking tensor

   ulong total = m_cOutputs.Total();

   if(!m_cDropOutMultiplier.m_mMatrix.Fill(m_dInitValue))

      return false;

   for(int i = 0; i < m_iOutNumber; i++)

     {

      int pos = (int)(MathRand() * MathRand() / MathPow(32767.0, 2) * total);

      if(m_cDropOutMultiplier.m_mMatrix.Flat(pos) == 0)

        {

         i--;

         continue;

        }

      if(!m_cDropOutMultiplier.m_mMatrix.Flat(pos, 0))

         return false;

     }
```

After generating the masking vector, we only need to apply it to the initial data. To do this, we multiply two buffers, element by element: the initial data and the masking.

According to our library building concept, in each method of the class, we create two execution branches whenever possible: one using standard MQL5 means and the other one using OpenCL for multi-threaded computations. Therefore, next, we create a branching of the algorithm depending on the selected device for computing operations.

As always, now we will look at the implementation of the algorithm using MQL5. We will return to implementing the algorithm in multi-threaded operations using OpenCL a little later. In the block for implementing the algorithm using MQL5, we use matrix operations.

```
//--- branching of the algorithm depending on the execution device

   if(!m_cOpenCL)

     {
```

As you remember, the method has two modes: training and operation. Therefore, before executing the algorithm, we check the current operating mode. If the class runs in operational mode, we simply copy the contents of the result buffer from the previous layer into the result buffer of the current layer. In the case of the training process, we multiply the tensor of the original data by the masking tensor.

```
//--- checking the operating mode flag

      if(!m_bTrain)

         m_cOutputs.m_mMatrix = prevLayer.GetOutputs().m_mMatrix;

      else

         m_cOutputs.m_mMatrix = prevLayer.GetOutputs().m_mMatrix *

                                m_cDropOutMultiplier.m_mMatrix;

     }

   else  // OpenCL block

     {

      return false;

     }

//---

   return true;

  }
```

So, as a result of the operations described above, the result buffer of our layer contains the masked data from the previous layer. The task set for the feed-forward method has been completed, and we can complete the method execution. Let's also add a temporary stub in place of the multi-threaded calculation algorithm.

Next, we move on to organizing the backpropagation process.

## 6.File operations

In the previous sections, we explored the operating algorithm of the Dropout approach and even managed to create the CNeuronDropout class to implement it within our library. Within the framework of this class, we have implemented the Dropout feed-forward and backpropagation algorithms. Now, for the full implementation of this class, we need to add file methods that will allow us to save and restore the operation of a previously trained model at any required time. This provides the opportunity to quickly restore the functionality of the model when needed.

Again, when starting this work, we critically evaluate the variables and objects of our class to decide whether to save them to a file in whole or in part or to restore them according to some parameters.

```
class CNeuronDropout    :  public CNeuronBase

  {

protected:

   TYPE              m_dOutProbability;

   int               m_iOutNumber;

   TYPE              m_dInitValue;

   CBufferType       m_cDropOutMultiplier;

public:

                     CNeuronDropout(void);

                    ~CNeuronDropout(void);

   //---

   virtual bool      Init(const CLayerDescription *desc) override;

   virtual bool      FeedForward(CNeuronBase *prevLayer) override;

   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;

   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer, bool read)

                                                       override { return true; }

   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,

                         VECTOR &Beta, VECTOR &Lambda) override { return true; }

   //--- methods for working with files

   virtual bool      Save(const int file_handle) override;

   virtual bool      Load(const int file_handle) override;

   //--- object identification method

   virtual int       Type(void) override     const { return(defNeuronDropout); }

  };
```

In addition to the objects inherited from the parent class, we create only one data buffer and three variables. These three variables have mathematical relationships between them. The masking vector buffer is redefined on each feed-forward pass. Thus, to restore the functionality of the Dropout layer, it is sufficient to save the objects of the parent class and one variable.

Therefore, the data-saving method will be quite simple and short. In parameters, the method receives a pointer to a file handle for saving. In the method body, we call a similar method from the parent class, in which all the controls and the saving of parent class objects are already implemented. After the successful execution of the parent class method, we will only write the dropout probability to the file, which represents the probability of dropping out neurons from processing. This particular variable was chosen because it is the parameter specified by the user, while the others are secondary and are calculated during class initialization.

```
bool CNeuronDropout::Save(const int file_handle)

  {

//--- call the method of the parent class

   if(!CNeuronBase::Save(file_handle))

      return false;

//--- save the probability constant of dropping out elements

   if(FileWriteDouble(file_handle, m_dOutProbability) <= 0)

      return false;

//---

   return true;

  }
```

The method for restoring the functionality of the CNeuronDropout::Load layer looks a little more complicated than the saving method. Just like the data-saving method, the data-loading method receives a file handle with data to load in its parameters. We remember the fundamental rule of data loading: data is loaded from the file in strict accordance with the sequence in which it was written. Therefore, in the method body, we first call a similar method from the parent class, where all the controls and loading of data inherited from the parent class objects are already implemented.

```
bool CNeuronDropout::Load(const int file_handle)

  {

//--- call the method of the parent class

   if(!CNeuronBase::Load(file_handle))

      return false;
```

We must always check the result of the parent class method execution because it confirms not only the data loading but also the passing of all implemented controls.

After the successful execution of the parent class method, we read the probability of dropping out neurons from the file. Based on the obtained value, we calculate the number of neurons to be dropped out on each feed-forward iteration and initialize the values of the masking buffer elements.

```
//--- read and restore constants

   m_dOutProbability = (TYPE)FileReadDouble(file_handle);

   m_iOutNumber = (int)(m_cOutputs.Total() * m_dOutProbability);

   m_dInitValue = (TYPE)(1.0 / (1.0 - m_dOutProbability));
```

Finally, at the end of the method for restoring the functionality of our layer, we initialize the buffer for recording the masking vector.

```
//--- initializing the data masking buffer

   if(!m_cDropOutMultiplier.BufferInit(m_cOutputs.Rows(), m_cOutputs.Cols(),

                                                              m_dInitValue))

      return false;

//---

   return true;

  }
```

After successfully loading data and initializing objects in our layer, we exit the method with a positive result.

At this stage, we are completing work on the Dropout layer class using standard MQL5 tools. In the next section, we will look at implementing a multi-threaded algorithm using OpenCL.
