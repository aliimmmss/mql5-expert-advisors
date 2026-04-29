# Chapter 05: Basic Types of Neural Layers

*Source: [https://www.mql5.com/en/neurobook/index/main_layer_types](https://www.mql5.com/en/neurobook/index/main_layer_types)*

---

## Basic types of neural layers

In the previous sections, we got acquainted with the architecture of a fully connected perceptron and constructed our first neural network model. We tested it in various modes, received our first results, and gained our first experience. However, the fully connected neural layers used in the perceptron, despite their merits, also possess certain drawbacks. For instance, a fully connected layer analyzes only the current data without any connection to previously processed data. Thus, each packet of information is analyzed in an informational vacuum. To expand the volume of analyzed data, it is necessary to continually increase the size of the model. Consequently, the expenses for training and operation grow exponentially. A fully connected layer analyzes the entire aggregate as a whole and fails to reveal dependencies between individual elements.

In this chapter, we will explore various architectural solutions for constructing neural layers aimed at overcoming the drawbacks of fully connected layers that we studied earlier. Fully connected neural networks analyze data without considering their context and interconnections, which can lead to insufficient efficiency and an increase in model volume. We will consider the following architectural approaches:

- [Convolutional Neural Networks](https://www.mql5.com/en/neurobook/index/main_layer_types/cnn) (CNN): we will delve into their architecture and implementation principles, as well as examine ways to build them using MQL5 and OpenCL. Next, we will explore practical testing of convolutional models aimed at evaluating their performance and efficiency.

- [Recurrent Neural Networks](https://www.mql5.com/en/neurobook/index/main_layer_types/rnn) (RNN): the architecture and implementation principles; ways to build LSTM blocks using MQL5 and organize parallel calculations using OpenCL. From this section, you will also learn how to implement RNNs in Python and test them.

Thus, in this chapter, we will study convolutional and recurrent neural networks, their operation and application in practical problems. We will also examine various methods of their construction and optimization.

## Convolutional neural networks

We continue our exploration of neural network architectures, focusing now on the principles of operation and construction of convolutional neural networks (CNNs). These neural networks are widely used in tasks involving object recognition in photos and videos. It is considered that convolutional neural networks are resistant to changes in scale, shifts in perspective, and other spatial distortions of images. Their architecture enables them to equally effectively detect objects in any part of a scene.

In addition to the architectural differences we will discuss in the next chapter, there is a fundamental distinction in the logical processing of incoming data streams between convolutional and fully connected neural networks. As we have seen earlier, each neuron in a fully connected network is linked to all neurons in the previous layer, responding to distinct patterns in input data. Let's try to translate this to image pattern recognition.

Imagine training a neural network to recognize digits printed on a piece of paper. Each digit is printed on a perfectly clean sheet of paper, and your neural network has learned to recognize them perfectly. But when you input a signal with a slight noise, its output becomes unpredictable, as the noise alters the image, making it deviate from the ideal patterns in the training dataset.

The opposite situation is also possible. When you train a neural network on noisy images, where the object of interest is on some background, a fully connected neural network with a sufficient number of neurons and an adequate training dataset can solve such a task. At the same time, it perceives the picture as a whole. Changing or removing the background can disturb the equilibrium of a fully connected neural network, causing its output to become unpredictable. Once again, it's all about the integrity of the perception of the world. When using supervised learning, if we provided a neural network with a noisy image during training and gave it the correct answer, the neural network associated the image with the answer and memorized it. But it didn't pick out the right image from the picture; instead, it memorized the whole picture. Therefore, the absence of the background is perceived by the neural network as the absence of some component of the image. In such a case, it will be difficult to give the correct result.

Similarly, issues arise with rotations, zooms, or any minor alteration in input data, treating each change as new and unseen by a fully connected network. This demands additional resources for processing and memorization, posing performance challenges as the size of processed images increases.

In addition to the recognition problems mentioned above, there is also a performance problem. As the size of the processed images increases, the size of the incoming data stream also grows. As a consequence, the weight matrices also grow. Therefore, more memory is required to store the weight matrix and more time is required to train the neural network. That said, in many cases, a significant portion of the image does not carry useful information. Consequently, resources are being spent inefficiently.

To address these, convolutional neural networks were designed. Instead of examining the whole image, CNNs divide it into small components, scrutinizing each as if under a microscope. Each convolutional layer contains filters checking individual parts for correspondence to desired patterns, mitigating noise and background influence. The use of small weight matrices reduces memory requirements, and the size remains unchanged with larger processed images.

The use of small weight matrices for each filter allows for a significant reduction in the memory requirement for storing them. Moreover, in this approach, the size of the weight matrix does not depend on the size of the original image, but on the size of the filter image. Therefore, as the size of the processed images increases, the size of the weight matrix remains unchanged.

In addition to the aforementioned benefits, CNNs reduce the processed data with each layer since for each small constituent part of the image, only one value is returned, indicating the degree of similarity between the image and the desired pattern.

In terms of trading, I have tried to translate the advantages of CNNs into a new plane. Instead of searching for small constituents of the desired pattern in an image, we will be looking for small components of patterns from price candles and indicator values in the input data stream. By doing so, we will try to eliminate the influence of noise fluctuations on the overall result.

Furthermore, one of the major advantages of convolutional neural networks lies in the fact that the network learns the filters during the training process.

Let's delve into the architectures of this solution and get to know it more closely.

## Recurrent neural networks

We have already discussed the multilayer perceptron and convolutional neural networks earlier. All of them operate with static data within the framework of Markov processes, where the subsequent state of the system depends only on its current state and is independent of the system's past states. Indeed, to compensate for this limitation, we fed the neural network not only the latest price data and indicator states but also historical data for the past few bars. However, the network itself did not memorize the processed data and the obtained results. During each new forward pass iteration into the neural network, we re-input the complete set of historical data, even if we had previously provided this data to the neural network. Essentially, with each forward pass, the neural network started with a "clean slate." The only memory such a neural network possesses is the weight matrix it learned during the training process.

Another drawback of using such neural networks for time series is that the position of a specific value/pattern in the data array has absolutely no impact on the outcome values. Let me remind you of the mathematical model of a neuron.

Note that the sum of values is at the center of the entire model. Permuting the terms does not change the sum, so from a mathematical perspective, it is absolutely irrelevant whether a value appears at the beginning or at the end of the array. In practical usage of time series, however, it is quite common for the latest values to have a greater impact on the outcome compared to older values.

Now I suggest looking at Recurrent Neural Networks. They represent a special type of neural network designed to work with time sequences. The key feature of recurrent neurons is the transmission of their own state as input to themselves in the next iteration.

With each new input from the external environment, the neuron, along with the new data, essentially evaluates the outcome of its past performance as if reviewing its own history.

## Description of architecture and implementation principles

Convolutional networks, in comparison with a fully connected perceptron, have two new types of layers: convolutional (filter) and pooling (subsampling). Alternating, the specified layers are designed to highlight the main components and filter out noise in the original data while simultaneously reducing the dimensionality (volume) of the data, which is then fed into a fully connected perceptron for decision-making. Depending on the tasks to be solved, it is possible to consistently use several groups of alternating convolutional and subsample layers.

Convolutional neural network

The Convolution layer is responsible for recognizing objects in the source data set. In this layer, sequential operations of mathematical convolution of the original data with a small template (filter) are carried out, acting as the convolution kernel.

Convolution is an operation in functional analysis that, when applied to two functions f and g, returns a third function corresponding to the cross-correlation function of f(x) and g(-x). The operation of convolution can be interpreted as the "similarity" of one function to the mirrored and shifted copy of another.

In other words, the convolutional layer searches for a template element in the entire original sample. At the same time, on each iteration, the template is shifted across the array of original data with a specified step, which can be from 1 to the size of the template. If the magnitude of the shift step is smaller than the size of the template, then such convolution is called overlapping.

As a result of the convolution operation, we obtain a feature array that shows the similarity of the original data to the desired template at each iteration. Activation functions are used for data normalization. The size of the obtained array will be smaller than the array of original data, and the number of such arrays is equal to the number of templates (filters).

It is also important for us to note that the templates themselves are not specified during the design of the neural network but are selected during the training process.

Next subsample layer is used to reduce the size of the feature array and filter noise. The application of this iteration is based on the assumption that the similarity of the original data to the template is primary, and the exact coordinates of the feature in the array of original data are not so important. This allows addressing the scaling issue, as it permits some variability in the distance between the sought-after objects.

At this stage, data is condensed by maintaining the maximum or average value within a specified window. This way, only one value per data window is saved. Operations are carried out iteratively, shifting the window by a specified step with each new iteration. Data compaction is performed separately for each array of features.

Pooling layers with a window and a step of two are often used, which makes it possible to halve the size of the feature array. However, in practice, it is also possible to use a larger window. Furthermore, consolidation iterations can be carried out both with overlapping (when the step size is smaller than the window size) and without.

At the output of the pooling layer, we obtain arrays of features of smaller dimensions.

Depending on the complexity of the tasks being solved, after the pooling layer, it is possible to use one or several groups of convolutional and pooling layers. The principles of their construction and functionality comply with the principles described above.

In the general case, after one or several groups of "convolution + compaction", arrays of features obtained from all filters are gathered into a single vector and fed into a multilayer perceptron for the neural network's decision-making.

Convolutional neural networks are trained by the well-known method of error backpropagation. This method belongs to the unsupervised learning methods and imply propagating the error gradient from the output layer of neurons through hidden layers to the input layer of neurons with adjustment of weights towards the anti-gradient.

Convolutional neural networks are trained by the well-known method of error backpropagation.

In the pooling layer, the error gradient is calculated for each element in the feature array, analogous to the gradients of neurons in a fully connected perceptron. The algorithm for transferring the gradient to the previous layer depends on the compaction operation used. If only the maximum value is taken, then the entire gradient is passed to the neuron with the maximum value. For the other elements within the consolidation window, a zero gradient is set, as during the forward pass they did not influence the final result. If the operation of averaging is used within the window, then the gradient is evenly distributed to all elements within the window.

Weights are not used in the compaction operation, therefore, nothing is adjusted during the training process.

Operations are somewhat more complicated when training the neurons of the convolutional layer. The error gradient is calculated for each element of the feature array and descends to the corresponding neurons of the previous layer. The process of training the convolutional layer is based on convolution and reverse convolution operations.

To propagate the error gradient from the pooling layer to the convolutional layer, first, the edges of the error gradient array, obtained from the pooling layer, are padded with zero elements, and then a convolution of the resulting array is performed with the convolution kernel rotated by 180°. The output is an array of error gradients equal to the input data array, in which the gradient indices will correspond to the index of the corresponding neuron of the previous layer.

To obtain the weight deltas, convolution is performed between the matrix of input values and the matrix of error gradients of this layer, rotated by 180°. The output is an array of deltas with a size equal to the convolution core. The resulting deltas should be adjusted for the derivative of the activation function of the convolutional layer and the learning coefficient. After that, the weights of the convolution core change by the value of the corrected deltas.

It probably sounds rather hard to understand. Let's try to clarify these points while considering the code in detail.

## Construction using MQL5

As we have already seen in the description of the convolutional network architecture. To construct it, we need to create two new types of neural layers: convolutional and pooling. The first is responsible for data filtering and extracting the desired data, while the second is for pinpointing the points of maximum correspondence to the filter and reducing the data array's dimensionality. The convolutional layer has a weight matrix, but it is much smaller than the weight matrix of a fully connected layer due to the fact that it is searching for a small pattern. As for the pooling layer, it has no weighting coefficients at all. This reduction in the dimension of the weight matrix makes it possible to reduce the number of mathematical calculations and thereby increase the speed of information processing. At the same time, the number of operations decreases both during the forward and backward passes. Therefore, the time required to train the neural network is significantly reduced. The ability of the algorithm to filter out noise allows you to improve the quality of the neural network.

#### Pooling layer

We begin the implementation of the algorithm by constructing a pooling layer. To do this, we will create a class CNeuronProof. We have previously voiced the idea that for the continuity of neural layers, they will all inherit from one base class. Adhering to this concept, we will inherit the new neural layer from the previously created CNeuronBase class. The inheritance will be public. Therefore, all methods not overridden within the CNeuronProof class will be accessible from the parent class.

To cover additional requirements due to the peculiarities of the convolutional network algorithm, we will add variables to the new class to store additional information:

- m_iWindow — window size at the input of the neural layer

- m_iStep — step size of the input window

- m_iNeurons — output size of one filter

- m_iWindowOut — number of filters

- m_eActivation — activation function

Note that, unlike the base class CNeuronBase, we did not use a separate activation function class CActivation but introduced a new variable m_eActivation. The reason is that the pooling layer does not use the activation function in the previously considered form. Its functionality is slightly different here. Usually, the result of the pooling layer is the maximum or the arithmetic mean value of the analyzed window. Therefore, we implement new functionality within the methods of this class and will create a new enumeration with two elements:

- AF_AVERAGE_POOLING — the arithmetic mean of the input data window

- Af_MAX_POOLING — the maximum value of the input data window

At the same time, we deliberately will not make changes to the code of the base class regarding new activation functions, as they will not be used in other neural layer architectures.

```
//--- activation functions of the pooling layer

enum ENUM_PROOF

  {

   AF_MAX_POOLING,

   AF_AVERAGE_POOLING

  };
```

Another feature of the pooling layer is the absence of a weight matrix. Therefore, the layer will not participate in the process of training and updating the weights. In this case, we can even delete some objects to free up memory. At the same time, the pooling layer cannot be completely excluded from the backward pass, as it will be involved in the propagation of the error gradient. To avoid cluttering the dispatcher class methods with excessive checks and at the same time to exclude the invocation of unnecessary parent class methods, we will replace a number of methods with "stubs" that will return the value required for the normal operation of the integrated neural network algorithm.

- CalcOutputGradient always returns false because it is not intended to use the layer as an output layer for the neural network.

- CalcDeltaWeights and UpdateWeights always return true. The absence of a weight matrix makes these methods redundant, but for the correct operation of the entire model, it is necessary to return a positive result from the methods.

- GetWeights and GetDeltaWeights always return NULL. Methods have been overridden to prevent errors due to accessing a non-existent object.

Let's add another method to return the number of elements in the output of one filter and we will get the following class structure.

```
class CNeuronProof    :  public CNeuronBase

  {

protected:

   uint              m_iWindow;             //Window size at the input of the neural layer

   uint              m_iStep;               //Input window step size

   uint              m_iNeurons;            //Output size of one filter

   uint              m_iWindowOut;          //Number of filters

   ENUM_PROOF        m_eActivation;         //Activation function

public:

                     CNeuronProof(void);

                    ~CNeuronProof(void) {};

   //---

   virtual bool      Init(const CLayerDescription *desc) override;

   virtual bool      FeedForward(CNeuronBase *prevLayer) override;

   virtual bool      CalcOutputGradient(CBufferType *target) override;

                                                               { return false;}

   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;

   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer) { return true; }

   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,

                                         VECTOR &Beta, VECTOR &Lambda) override

                                                               { return true; }

   //---

   virtual CBufferType     *GetWeights(void)       const {  return(NULL);     }

   virtual CBufferType     *GetDeltaWeights(void)  const {  return(NULL);     }

   virtual uint      GetNeurons(void)              const {  return m_iNeurons;}

   //--- Methods for working with files

   virtual bool      Save(const int file_handle) override;

   virtual bool      Load(const int file_handle) override;

   //--- Object identification method

   virtual int       Type(void) override      const { return(defNeuronProof); }

  };
```

In the class constructor, we only initialize the added variables using initial values.

```
CNeuronProof::CNeuronProof(void) :  m_eActivation(AF_MAX_POOLING),

                                    m_iWindow(2),

                                    m_iStep(1),

                                    m_iWindowOut(1),

                                    m_iNeurons(0)

  {

  }
```

We did not add any new objects, and the destructor of the base class is responsible for deleting those created in the base class. Therefore, the destructor of our class will remain empty.

Let's look further at the methods of the new class of pooling layer CNeuronProof. Let's examine the Init method that initializes the neural layer. In the parameters, the method, similar to the method of the parent class, receives a layer description object. At the beginning of the method, we check the validity of the received object as well as the match between the required layer and the current neural network class.

```
bool CNeuronProof::Init(const CLayerDescription *description)

  {

//--- control block

   if(!description || description.type != Type() ||

      description.count <= 0)

      return false;
```

After successfully passing the initial check, we will save and verify the parameters of the created layer:

- input window size

- input window step

- the number of filters

- the number of elements at the output of one filter

All specified parameters must be non-zero positive values.

```
//--- Save constants

   m_iWindow = description.window;

   m_iStep = description.step;

   m_iWindowOut = description.window_out;

   m_iNeurons = description.count;

   if(m_iWindow <= 0 || m_iStep <= 0 || m_iWindowOut <= 0 || m_iNeurons <= 0)

      return false;
```

Let's also check the specified activation function. For the pooling layer, we can only use two variants of the activation function, AF_AVERAGE_POOLING and AF_MAX_POOLING. In other cases, we will exit the method with the result false.

```
//--- Checking the activation function

   switch((ENUM_PROOF)description.activation)

     {

      case AF_AVERAGE_POOLING:

      case AF_MAX_POOLING:

         m_eActivation = (ENUM_PROOF)description.activation;

         break;

      default:

         return false;

         break;

     }
```

After successfully passing all the control blocks, we proceed directly to the initialization of the neural layer. First, we initialize the results vector m_cOutputs with zero values. We will create this buffer in the form of a rectangular matrix, with its rows representing individual filters.

```
//--- Initializing the results buffer

   if(!m_cOutputs)

      if(!(m_cOutputs = new CBufferType()))

         return false;

   if(!m_cOutputs.BufferInit(m_iWindowOut, m_iNeurons, 0))

      return false;
```

The use of matrices allows us to distribute data across filters within the scope of a single object. This gives us the opportunity to use a transparent data structure and exchange data between CPU and OpenCL context. This will allow us to gain a little time when transferring data and organize parallel processing of data by all filters at once.

A similar approach is used for the m_cGradients error gradient buffer.

```
//--- Initialize the error gradient buffer

   if(!m_cGradients)

      if(!(m_cGradients = new CBufferType()))

         return false;

   if(!m_cGradients.BufferInit(m_iWindowOut, m_iNeurons, 0))

      return false;
```

After completing the initialization of the result and gradient buffers, we will remove unused objects and exit the method with a positive result.

```
//---

   m_eOptimization = None;

//--- Deleting unused objects

   if(!!m_cActivation)

      delete m_cActivation;

   if(!!m_cWeights)

      delete m_cWeights;

   if(!!m_cDeltaWeights)

      delete m_cDeltaWeights;

   for(int i = 0; i < 2; i++)

      if(!!m_cMomenum[i])

         delete m_cMomenum[i];

//---

   return true;

  }
```

Now that we have completed the initialization of the neural layer, let's move on to implementing the feed-forward pass in the FeedForward method. Similar to the previous method, the forward pass method is constructed following the concept of inheritance and overriding virtual methods of the base class while adding new functionality. In its parameters, the method receives a pointer to an object of the previous neural layer. As always, at the beginning of the method, we will set up a validation block to check the input data. Here, we are checking the validity of pointers to the previous neural layer and the result buffers of both the previous and current neural layers.

```
bool CNeuronProof::FeedForward(CNeuronBase *prevLayer)

  {

//--- Control block

   if(!prevLayer || !m_cOutputs ||

      !prevLayer.GetOutputs())

      return false;

   CBufferType *input_data = prevLayer.GetOutputs();
```

After successfully passing the control block, we will save a pointer to the result buffer of the previous layer and create a branching algorithm in the method based on the computational device in use: CPU or OpenCL context. We will return to the multi-threaded calculation algorithm a little later. Now, let's consider the implementation in MQL5.

Once again, we emphasize that the subsample layer does not have a weight matrix. And just like all other neural layers, it uses the same activation function for all neurons and filters. So, the difference between the filter outputs can only occur when different input data is used. In other words, the number of filters in the pooling layer must match the number of filters in the preceding convolutional layer. So, we will first copy the original data matrix and reformat it if necessary.

```
//--- Branching of the algorithm depending on the execution device

   if(!m_cOpenCL)

     {

      MATRIX inputs = input_data.m_mMatrix;

      if(inputs.Rows() != m_iWindowOut)

        {

         ulong cols = (input_data.Total() + m_iWindowOut - 1) / m_iWindowOut;

         if(!inputs.Reshape(m_iWindowOut, cols))

            return false;

        }
```

It should be noted that despite the assumption of using a pooling layer after convolutional layers, our method allows for its use after the base class of a fully connected neural layer. That is why we copy the initial data matrix. This allows us to seamlessly reformat it into the desired format without the fear of disrupting the structure of the preceding layer.

It must be noted that MQL5 does not support three-dimensional matrices. Therefore, from this point on, we will need to work separately for each filter. First, we will create a local matrix with the number of rows and columns equal to the dimensions of the results of one filter and the input window, respectively. We organize two nested loops: an outer loop with a number of iterations equal to the number of filters, and an inner loop with a number of iterations equal to the number of elements in one filter of the current layer.

```
//--- Create a local matrix to collect data from one filter

      MATRIX array = MATRIX::Zeros(m_iNeurons, m_iWindow);

      m_cOutputs.m_mMatrix.Fill(0);

//--- Filter iteration cycle

      for(uint f = 0; f < m_iWindowOut; f++)

        {

//--- Loop through the elements of the results buffer

         for(uint o = 0; o < m_iNeurons; o++)

           {

            uint shift = o * m_iStep;

            for(uint i = 0; i < m_iWindow; i++)

               array[o, i] = ((shift + i) >= inputs.Cols() ? 0 :

                              inputs[f, shift + i]);

           }
```

In the inner loop, we implement another nested loop. In its body, we will distribute the input data of one filter into the previously created matrix according to the size of the data window and its step. The use of a loop is driven by the need for a unified approach in cases where the size and stride are not equal.

After distributing the initial data, we will use matrix operations according to the given activation function. The resulting vector is stored in the results matrix. The row of the results matrix corresponds to the number of the analyzed filter.

```
//--- Saving the current result in accordance with the activation function

         switch(m_eActivation)

           {

            case AF_MAX_POOLING:

               if(!m_cOutputs.Row(array.Max(1), f))

                  return false;;

               break;

            case AF_AVERAGE_POOLING:

               if(!m_cOutputs.Row(array.Mean(1), f))

                  return false;

               break;

            default:

               return false;

           }

        }

     }
```

I use the term 'filter' to maintain a clear chain in your understanding: the filter from the convolutional layer transitions to the filter in the pooling layer. Iterations of the pooling layer can hardly be called a filter. At the same time, I want it to be clear in your understanding that the convolutional and pooling layers, while organized into two objects of neural layers, form a single integrated structure. Therefore the same terminology is used.

After successfully completing all iterations of the loop system, we exit the method with the result true.

```
else

     {

//--- The multi-threaded calculation block will be added in the next chapter

      return false;

     }

//--- Successful completion of the method

   return true;

  }
```

The feed-forward pass is followed by the backpropagation pass. The absence of a weight matrix in the pooling layer allows the backpropagation pass to be organized in a single method, unlike the base class of the neural network CNeuronBase, in which the backpropagation pass is divided into several functional methods.

Essentially, for the pooling layer, the backpropagation pass is the CalcHiddenGradient method that propagates the error gradient to the hidden layer. We have replaced the remaining methods with placeholders, as mentioned earlier.

The CalcHiddenGradient method itself is built within the framework of our concept of using a single format of virtual methods for all classes of neural networks with common inheritance from a single base class of the neural layer. Therefore, similar to the method of the base class of the neural layer CNeuronBase::CalcHiddenGradient, the method receives a pointer to the object of the previous neural layer in its parameters. At the beginning of the method, a control block for checking incoming data is organized. Here, we are checking the correctness of the pointer received as a parameter, which points to the object of the previous neural layer, and the presence of active result buffers and error gradients in the previous layer. We also check the correctness of the result buffers and error gradients of the current layer.

```
bool CNeuronProof::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

//--- Control block

   if(!prevLayer || !m_cOutputs ||

      !m_cGradients || !prevLayer.GetOutputs() ||

      !prevLayer.GetGradients())

      return false;

   CBufferType *input_data = prevLayer.GetOutputs();

   CBufferType *input_gradient = prevLayer.GetGradients();

   if(!input_gradient.BufferInit(input_data.Rows(), input_data.Cols(), 0))

      return false;
```

After successfully passing the control block, similar to the forward pass method, we will copy and reformat the matrix of input data. We will also create a zero local matrix of similar size, to accumulate error gradients.

Note that in the base neural layer class, we did not pre-zero the gradient buffer. The difference lies in the approach to passing the error gradients to the previous layer. The base class algorithm includes recalculation and saving of the gradient value for each element. With this approach, pre-clearing the buffer doesn't make sense because any value will be overwritten with a new one. In the pooling layer algorithm, recording the error gradient into each buffer element of the previous layer is only envisaged when using Average Pooling (arithmetic mean value). In the case of Max Pooling (maximum value), the error gradient is transferred only to the element with the maximum value, because only it affects the subsequent result of the neural network. The remaining elements receive a zero error gradient. Therefore, we immediately clear the entire buffer and only insert the gradient value for elements that affect the result.

Next, we divide the algorithm depending on the computational device. We will not now discuss the implementation of multi-threaded calculations in OpenCL but will focus on implementation using MQL5.

Here, just like in the forward pass, we organize a system of nested loops to iterate through filters and their elements. Inside the loops, the error gradient is distributed to the elements of the previous layer depending on the activation function.

```
//--- Branching of the algorithm depending on the execution device

   if(!m_cOpenCL)

     {

      MATRIX inputs = input_data.m_mMatrix;

      ulong cols = (input_data.Total() + m_iWindowOut - 1) / m_iWindowOut;

      if(inputs.Rows() != m_iWindowOut)

        {

         if(!inputs.Reshape(m_iWindowOut, cols))

            return false;

        }

//--- Create a local matrix to collect data from one filter

      MATRIX inputs_grad = MATRIX::Zeros(m_iWindowOut, cols);
```

```
//--- Filter iteration cycle

      for(uint f = 0; f < m_iWindowOut; f++)

        {

//--- Loop through the elements of the results buffer

         for(uint o = 0; o < m_iNeurons; o++)

           {

            uint shift = o * m_iStep;

            TYPE out = m_cOutputs.m_mMatrix[f, o];

            TYPE gradient = m_cGradients.m_mMatrix[f, o];

 //--- Propagate the gradient in accordance with the activation function

            switch(m_eActivation)

              {

               case AF_MAX_POOLING:

                  for(uint i = 0; i < m_iWindow; i++)

                    {

                     if((shift + i) >= cols)

                        break;

                     if(inputs[f, shift + i] == out)

              {

                        inputs_grad[f, shift + i] += gradient;

                        break;

                       }

                    }

                  break;

               case AF_AVERAGE_POOLING:

                  gradient /= (TYPE)m_iWindow;

                  for(uint i = 0; i < m_iWindow; i++)

                    {

                     if((shift + i) >= cols)

                        break;

                     inputs_grad[f, shift + i] += gradient;

                    }

                  break;

               default:

                  return false;

              }

           }

        }

//--- copy the gradient matrix to the buffer of the previous neural layer

      if(!inputs_grad.Reshape(input_gradient.Rows(), input_gradient.Cols()))

         return false;

      input_gradient.m_mMatrix = inputs_grad;

     }
```

When using the arithmetic average (AF_AVERAGE_POOLING), the error gradient is equally distributed to all elements in the input data window corresponding to the result element.

When using the maximum value (AF_MAX_POOLING), the entire error gradient is passed on to the element with the maximum value. Moreover, when there are multiple elements with the same maximum value, the error gradient is passed to the element with the minimum index in the result buffer of the previous layer. This choice was made deliberately to enhance the overall efficiency of the neural network. The reason for this is that when passing the same gradient to elements with the same value, we risk getting into a situation where two or more neurons will work synchronously, producing identical results. Duplicating the signal with different neurons doesn't increase the significance of the signal; it only reduces the efficiency of the neural network's operation. After all, when working synchronously, the efficiency of such neurons becomes equal to the work of one neuron. Therefore, by passing the error gradient to only one neuron, we hope that the next time, another element will receive a different gradient value and disrupt the synchronization of neurons' operation.

After filling the local gradient matrix, we transfer the obtained result to the gradient buffer of the previous layer and exit the method with the result of the operations.

```
else

     {

//--- The multi-threaded calculation block will be added in the next chapter

      return false;

     }

//--- Successful completion of the method

   return true;

  }
```

The methods discussed above describe the main functionality of the pooling layer. For the completeness of the class functionality, it's necessary to add methods for working with files to save information about the trained neural network to a file. The main characteristic of the pooling layer is the absence of a weight matrix. Hence, there are no trainable elements and no need to store any data buffers. To fully restore the functionality of the layer, it's sufficient to save the values of its variables that define the operational parameters of the class.

- m_iWindow — window size at the input of the neural layer

- m_iStep — step size of the input window

- m_iNeurons — output size of one filter

- m_iWindowOut — number of filters

- m_eActivation — activation function

```
bool CNeuronProof::Save(const int file_handle)

  {

//--- Control block

   if(file_handle == INVALID_HANDLE)

      return false;

//--- Save constants

   if(FileWriteInteger(file_handle, Type()) <= 0)

      return false;

   if(FileWriteInteger(file_handle, (int)m_iWindow) <= 0)

      return false;

   if(FileWriteInteger(file_handle, (int)m_iStep) <= 0)

      return false;

   if(FileWriteInteger(file_handle, (int)m_iWindowOut) <= 0)

      return false;

   if(FileWriteInteger(file_handle, (int)m_iNeurons) <= 0)

      return false;

   if(FileWriteInteger(file_handle, (int)m_eActivation) <= 0)

      return false;

//--- Successful completion of the method

   return true;

  }
```

The method for restoring the layer from a file is slightly more complex than the method for saving it. In this case, I think the term 'recovery' is more appropriate than 'loading'. This is due to the fact that we will not read any information about training and development of the method from the file. From the file, we first read the layer parameters, which contain roughly the same amount of information as we pass in the initialization method in the layer description object. Then we initialize the result and error gradient buffers.

```
bool CNeuronProof::Load(const int file_handle)

  {

//--- Control block

   if(file_handle == INVALID_HANDLE)

      return false;

//--- Load constants

   m_iWindow = (uint)FileReadInteger(file_handle);

   m_iStep = (uint)FileReadInteger(file_handle);

   m_iWindowOut = (uint)FileReadInteger(file_handle);

   m_iNeurons = (uint)FileReadInteger(file_handle);

   m_eActivation = (ENUM_PROOF)FileReadInteger(file_handle);

//--- Initialize the results buffer

   if(!m_cOutputs)

     {

      m_cOutputs = new CBufferType();

      if(!m_cOutputs)

         return false;

     }

   if(!m_cOutputs.BufferInit(m_iWindowOut, m_iNeurons, 0))

      return false;

//--- Initialize the error gradient buffer

   if(!m_cGradients)

     {

      m_cGradients = new CBufferType();

      if(!m_cGradients)

         return false;

     }

   if(!m_cGradients.BufferInit(m_iWindowOut, m_iNeurons, 0))

      return false;

//---

   return true;

  }
```

At this stage, we can say that we have completed the first part of the work on constructing convolutional neural network objects. Now we will move on to the second stage, building a convolutional layer class.

#### Convolutional layer

The construction of the convolutional layer is carried out in the CNeuronConv class, which we will inherit from the CNeuronProof pooling layer class created above. Inheriting from the pooling layer class does not violate our concept of having all classes in our neural network inherit from a common base class. The pooling layer class is a direct descendant of the base class, and all its descendants will also be descendants of the base class.

At the same time, by inheriting from the pooling layer class, we immediately gain access to all the added and overridden functionality, including variables for working with data windows. Moreover, inheriting objects and variables reinforces the connection between classes and underscores the unity of approaches in data processing.

Thus, thanks to inheritance, in the convolutional layer class CNeuronConv, we will use objects and variables declared in the parent classes. We don't need to declare any new objects and variables. As a consequence, the constructor and destructor of our class remain empty methods. At the same time, the convolutional layer class uses the weight matrix. In this case, we will need to override some previously set stubs.

- UpdateWeights completely satisfies the algorithm of the method of the base class CNeuronBase, so let's call its execution.

- GetWeights and GetDeltaWeights return pointers to the corresponding data buffers.

As a result, the class structure will take the following form.

```
class CNeuronConv    :  public CNeuronProof

  {

public:

                     CNeuronConv(void) {};

                    ~CNeuronConv(void) {};

   //---

   virtual bool      Init(const CLayerDescription *desc) override;

   virtual bool      FeedForward(CNeuronBase *prevLayer);

   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer);

   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer);

   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,

                                   VECTOR &Beta, VECTOR &Lambda)

     {

      return CNeuronBase::UpdateWeights(batch_size, learningRate,

                                        Beta, Lambda);

     }

   //---

   virtual CBufferType*  GetWeights(void)      const { return(m_cWeights);     }

   virtual CBufferType*  GetDeltaWeights(void) const { return(m_cDeltaWeights);}

   bool              SetTransposedOutput(const bool value);

   //--- methods for working with files

   virtual bool      Save(const int file_handle);

   virtual bool      Load(const int file_handle);

   //--- object identification method

   virtual int       Type(void)       const { return(defNeuronConv); }

  };
```

Let's examine the implementation of the Init method that initializes the convolutional layer. It partially combines the initialization methods of both parent classes. Unfortunately, we cannot use any of them: in the initialization method of the base class, buffers of incorrect sizes will be created and will still need to be overridden, and in the initialization method of the pooling layer, objects that will need to be recreated later are deleted. Therefore, we will write the entire algorithm into the method.

Like similar methods in the parent classes, the initialization method receives a pointer to an object describing the created neural layer in its parameters. As before, the method starts with a control block in which we validate the received pointer, the specified type of the layer being created, and the layer parameters.

```
bool CNeuronConv::Init(const CLayerDescription *desc)

  {

//--- control block

   if(!desc || desc.type != Type() || desc.count <= 0 || desc.window <= 0)

      return false;
```

After executing the control block, we save the layer parameters into special variables and initialize the necessary buffers.

```
//--- save constants

   m_iWindow = desc.window;

   m_iStep = desc.step;

   m_iWindowOut = desc.window_out;

   m_iNeurons = desc.count;

//--- save parameter optimization method

   m_eOptimization = desc.optimization;
```

First, we initialize the results buffer m_cOutputs. Similar to the pooling layer, we set the number of rows and columns of the buffer matrix equal to the number of filters and the number of elements in one filter, respectively. The buffer is initialized with zero values.

Next, we initialize the m_cGradients error gradient buffer with zero values. We set its size equal to the size of the m_cOutputs results buffer.

```
//--- initialize the results buffer

   if(!m_cOutputs)

      if(!(m_cOutputs = new CBufferType()))

         return false;

//--- initialize the error gradient buffer

   if(!m_cGradients)

      if(!(m_cGradients = new CBufferType()))

         return false;

   if(!m_cOutputs.BufferInit(m_iWindowOut, m_iNeurons, 0))

      return false;

   if(!m_cGradients.BufferInit(m_iWindowOut, m_iNeurons, 0))

      return false;
```

Next, we will need to initialize an instance of the activation function object. As you may recall, during the development of the base neural layer class, we decided to separate all the work related to initializing the activation function instance into a separate method called SetActivation. Here we just call this method of the parent class, and check the result of the operations.

```
//--- initialize the activation function class

   VECTOR params=desc.activation_params;

   if(!SetActivation(desc.activation, params))

      return false;
```

Then we initialize the weight matrix with random values. The number of rows in the weight matrix is equal to the number of filters being used, and the number of columns in the matrix is one greater than the size of the analyzed window. The added element is used for bias. The matrix is initialized with random values.

```
//--- initialize the weight matrix buffer

   if(!m_cWeights)

      if(!(m_cWeights = new CBufferType()))

         return false;

   if(!m_cWeights.BufferInit(desc.window_out, desc.window + 1))

      return false;

   double weights[];

   double sigma = desc.activation == AF_LRELU ?

                  2.0 / (double)(MathPow(1 + desc.activation_params[0], 2) *

                                                                 desc.window) :

                  1.0 / (double)desc.window;

   if(!MathRandomNormal(0, MathSqrt(sigma), m_cWeights.Total(), weights))

      return false;

   for(uint i = 0; i < m_cWeights.Total(); i++)

      if(!m_cWeights.m_mMatrix.Flat(i, (TYPE)weights[i]))

         return false;
```

At the end of the method, we initialize the buffers involved in the learning process. These are: a buffer of weight deltas (also known as a buffer of accumulated gradients) and moment buffers. Recall that the number of moment buffers used depends on the user-specified method for optimizing model parameters. The sizes of the specified buffers will correspond to the size of the weights matrix.

```
//--- initialize the gradient buffer at the weight matrix level

   if(!m_cDeltaWeights)

      if(!(m_cDeltaWeights = new CBufferType()))

         return false;

   if(!m_cDeltaWeights.BufferInit(desc.window_out, desc.window + 1, 0))

      return false;

//--- initialize moment buffers

   switch(desc.optimization)

     {

      case None:

      case SGD:

         for(int i = 0; i < 2; i++)

            if(m_cMomenum[i])

               delete m_cMomenum[i];

         break;

      case MOMENTUM:

      case AdaGrad:

      case RMSProp:

         if(!m_cMomenum[0])

            if(!(m_cMomenum[0] = new CBufferType()))

               return false;

         if(!m_cMomenum[0].BufferInit(desc.window_out, desc.window + 1, 0))

            return false;

         if(m_cMomenum[1])

            delete m_cMomenum[1];

         break;

      case AdaDelta:

      case Adam:

         for(int i = 0; i < 2; i++)

           {

            if(!m_cMomenum[i])

               if(!(m_cMomenum[i] = new CBufferType()))

                  return false;

            if(!m_cMomenum[i].BufferInit(desc.window_out, desc.window + 1, 0))

               return false;

           }

         break;

      default:

         return false;

         break;

     }

   return true;

  }
```

After initializing the class, we will move on to the forward pass method, which we will create in the overridden virtual method FeedForward. This way, we continue to exploit the concepts of inheritance and virtualization of class methods. In its parameters, the feed-forward pass method receives a pointer to the object of the previous layer, just like all the similar methods in the parent classes.

At the beginning of the method, as usual, we will insert a control block for checking the source data. In this method, we validate the received pointer to the object of the preceding neural layer and check for the presence of an 'active' result buffer in it. We also check whether the result buffer and weight matrix of the current layer have been created. To simplify the data access procedure for the result buffer of the preceding layer, we will store a pointer to this object in a local variable.

```
bool CNeuronConv::FeedForward(CNeuronBase *prevLayer)

  {

//--- control block

   if(!prevLayer || !m_cOutputs || !m_cWeights || !prevLayer.GetOutputs())

      return false;

   CBufferType *input_data = prevLayer.GetOutputs();

   ulong total = input_data.Total();
```

Next, we divide the algorithm into two threads depending on the execution device. We will discuss the algorithm for constructing multi-threaded calculations using OpenCL technology in the next chapter. Now let's look at the algorithm for arranging operations using MQL5.

The forward pass convolutional layer algorithm will somewhat resemble the similar pooling layer method. This is quite understandable: both layers work with a data window, which moves through the initial data array with a given step. Differences exist in the methods for processing the set of values that fall into the window.

Another difference lies in the approach to the perception of the array of initial data. The pooling layer in the convolutional neural network algorithm is placed after the convolutional layer, which can contain multiple filters. Consequently, the result buffer will contain the results of processing the data by multiple filters. The pooling layer is supposed to separate the results of one filter from another. In the convolutional layer, I chose to simplify this aspect, so I treat the entire input array as a single vector of input data. This approach allows us to simplify the method algorithm without losing the quality of the neural network in general.

Let's return to the algorithm. Before using matrix operations, we need to transform the vector of input data into a matrix with a number of rows equal to the number of elements in one filter. The number of columns should correspond to the size of the analyzed window of input data. Here, there are two possible scenarios: whether the size of the analyzed window is equal to its step or not.

In the first case, we can simply reformat the vector into a matrix. In the second case, we need to create a loop system for copying data.

```
//--- branching of the algorithm depending on the execution device

   if(!m_cOpenCL)

     {

      MATRIX m;

      if(m_iWindow == m_iStep && total == (m_iNeurons * m_iWindow))

        {

         m = input_data.m_mMatrix;

         if(!m.Reshape(m_iNeurons, m_iWindow))

            return false;

        }

      else

        {

         if(!m.Init(m_iNeurons, m_iWindow))

            return false;

         for(ulong r = 0; r < m_iNeurons; r++)

           {

            ulong shift = r * m_iStep;

            for(ulong c = 0; c < m_iWindow; c++)

              {

               ulong k = shift + c;

               m[r, c] = (k < total ? input_data.At((uint)k) : 0);

              }

           }

        }
```

Then, we will add the bias vector, which includes a single column of ones, to the resulting matrix. We multiply the resulting matrix by the transposed weight matrix.

```
//--- add a bias column

      if(!m.Resize(m.Rows(), m_iWindow + 1) ||

         !m.Col(VECTOR::Ones(m_iNeurons), m_iWindow))

         return false;

//--- Calculate the weighted sum of elements of the input window

      m_cOutputs.m_mMatrix = m_cWeights.m_mMatrix.MatMul(m.Transpose());

     }
```

Finally, we call the Activation method of the class of the activation function and terminate the method.

```
else

     {

//--- The multi-threaded calculation block will be added in the next chapter

      return false;

     }

   if(!m_cActivation.Activation(m_cOutputs))

      return false;

//--- Successful completion of the method

   return true;

  }
```

After completing work on the feed-forward pass, we will move on to working on the backpropagation pass. Unlike the pooling layer, the convolutional layer contains a weight matrix. Therefore, to organize the pass, we need a full set of methods.

A little ahead, I will say that the weight matrix update method from the base class is perfectly suitable. However, since we inherited not directly from the CNeuronBaseclass but from a pooling layer CNeuronProof, in which the method was replaced by a stub, we will have to forcefully turn to the base class method.

```
bool CNeuronConv::UpdateWeights(int batch_size, TYPE learningRate,

                                   VECTOR &Beta, VECTOR &Lambda)

     {

      return CNeuronBase::UpdateWeights(batch_size, learningRate, Beta, Lambda);

     }
```

But let's return to the logical chain of the backpropagation algorithm and take a look at the method for distributing the gradient through the hidden layer, CNeuronConv::CalcHiddenGradient.

If you look at the influence of the elements of the initial data on the elements of the results, you will notice a dependence. Each element of the resulting vector analyzes a block of data from the initial data vector in the size of the specified window. Similarly, each element of the initial data affects the value of elements in the result vector within a certain influence window. The size of this window depends on the step with which the input window moves across the source data array. With a step equal to one, both windows are equal. However, as the step increases, the size of the influence window decreases. Consequently, to propagate the error gradient, we need to collect error gradients from elements of the subsequent layer within the influence window.

I propose to look at the practical implementation of this method. We continue working with the virtual methods of the parent classes. In the parameters, the method receives a pointer to the object of the previous layer. Following the same pattern as with other methods, we start with a data validation block at the beginning of the method. Here, we validate the received pointer in the parameters and check for the presence of valid objects for output value buffers and error gradients of the previous layer. We also check for the presence of the error gradient buffer and weight matrix of the current layer.

```
bool CNeuronConv::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

//--- control block

   if(!prevLayer || !prevLayer.GetOutputs() || !prevLayer.GetGradients() ||

      !m_cGradients || !m_cWeights)

      return false;
```

After successfully passing the control block, we will adjust the error gradient by the derivative of the activation function of the current layer.

```
//--- adjusting error gradients to the derivative of the activation function

   if(m_cActivation)

     {

      if(!m_cActivation.Derivative(m_cGradients))

         return false;

     }
```

Next comes the branching of the algorithm depending on the computing device used. We are currently looking at the MQL5 branch.

The backpropagation method is the mirror of the forward pass method. During the feed-forward pass, we first transfer the input data to a local matrix and then multiply it by the weight matrix. During the backpropagation pass, we will first reformat the error gradient matrix received from the previous layer into the required format and then multiply it by the weight matrix.

```
//--- branching of the algorithm depending on the execution device

   CBufferType* input_gradient = prevLayer.GetGradients();

   if(!m_cOpenCL)

     {

      MATRIX g = m_cGradients.m_mMatrix;

      if(!g.Reshape(m_iWindowOut, m_iNeurons))

         return false;

      g = g.Transpose();

      g = g.MatMul(m_cWeights.m_mMatrix);

      if(!g.Resize(m_iNeurons, m_iWindow))

         return false;
```

As a result of matrix multiplication, we obtain a matrix of gradients for the previous layer. However, the process becomes more complex due to the presence of the analyzed window and its step. If they are equal, we just need to reformat the matrix and copy its value to the buffer of the previous layer. But if the size of the analyzed window of the source data is not equal to its step, then we will need to organize a loop system for copying and summing gradients. Indeed, in this case, one neuron of the source data influences several neurons of the results of each filter.

```
if(m_iWindow == m_iStep && input_gradient.Total() == (m_iNeurons * m_iWindow))

        {

         if(!g.Reshape(input_gradient.Rows(), input_gradient.Cols()))

            return false;

         input_gradient.m_mMatrix = g;

        }

      else

        {

         input_gradient.m_mMatrix.Fill(0);

         ulong total = input_gradient.Total();

         for(ulong r = 0; r < m_iNeurons; r++)

           {

            ulong shift = r * m_iStep;

            for(ulong c = 0; c < m_iWindow; c++)

              {

               ulong k = shift + c;

               if(k >= total)

                  break;

               if(!input_gradient.m_mMatrix.Flat(k,

                                  input_gradient.m_mMatrix.Flat(k) + g[r, c]))

                  return false;

              }

           }

        }

     }
```

After completing the loop iterations, we exit the method with a positive result.

```
else

     {

//--- The multi-threaded calculation block will be added in the next chapter

      return false;

     }

//--- Successful completion of the method

   return true;

  }
```

After distributing the gradient through the hidden layer, it's time to calculate the error gradient on the elements of the weight matrix. After all, it is the weights that we will select for optimal operation of the neural network. All the work on propagating the error gradient is necessary only to determine the direction and magnitude of the weight adjustments. This approach makes selecting the optimal weight matrix directed and controllable.

Work on distributing the error gradient over the elements of the weight matrix is implemented in the CalcDeltaWeights method. This method is also virtual and is overridden in each class. In the parameters, the method receives a pointer to the object of the previous layer. At the beginning of the method, we immediately check the correctness of the received pointer and the presence of operational data buffers in the current and previous neural layers. To calculate the gradient on the weight matrix, we will need a buffer for incoming gradients, a buffer for input data (results from the previous layer), and a buffer to store the obtained results (m_cDeltaWeights). Let me remind you that our algorithm includes gradient distribution at each iteration of the backward pass, and the weight matrix update is triggered by a request from an external program. Therefore, in the m_cDeltaWeights buffer, we will accumulate the error gradient value. During the update, we will divide the accumulated value by the number of completed iterations. Thus, we obtain the average error for each weight.

```
bool CNeuronConv::CalcDeltaWeights(CNeuronBase *prevLayer)

  {

//--- control block

   if(!prevLayer || !prevLayer.GetOutputs() || !m_cGradients || !m_cDeltaWeights)

      return false;
```

To simplify access to the data buffer of the previous layer, we will save the pointer to the object in a local variable.

Next, we divide the algorithm into two logical threads of operations depending on the computational device in use.

```
//--- branching of the algorithm depending on the execution device

   CBufferType *input_data = prevLayer.GetOutputs();

   if(!m_cOpenCL)

     {
```

We will discuss the implementation of the OpenCL algorithm in the next chapter. Now we will focus on the implementation using MQL5.

We have a two-dimensional weight matrix, in which one dimension represents the filters of our layer. Each row in the weight matrix is a separate filter. Therefore, the number of rows in the weight matrix is equal to the number of filters used. The second dimension (columns) of the matrix represents the elements of our filter, and their number is equal to the size of the input window plus bias.

However, since the filter window moves across the input data array, each element of the filter affects the result of all elements in the vector of the current layer results. Therefore, for each filter element, we need to collect error gradients from all elements of the result vector, which are stored in the m_cGradientsbuffer. Vector operations will help us with this. But first, let me remind you that during the forward pass, we transformed the vector of the original data. Let's repeat this process.

```
MATRIX inp;

      uint input_total = input_data.Total();

      if(m_iWindow == m_iStep && input_total == (m_iNeurons * m_iWindow))

        {

         inp = input_data.m_mMatrix;

         if(!inp.Reshape(m_iNeurons, m_iWindow))

            return false;

        }

      else

        {

         if(!inp.Init(m_iNeurons, m_iWindow))

            return false;

         for(ulong r = 0; r < m_iNeurons; r++)

           {

            ulong shift = r * m_iStep;

            for(ulong c = 0; c < m_iWindow; c++)

              {

               ulong k = shift + c;

               inp[r, c] = (k < input_total ? input_data.At((uint)k) : 0);

              }

           }

        }

      //--- add a bias column

      if(!inp.Resize(inp.Rows(), m_iWindow + 1) ||

         !inp.Col(VECTOR::Ones(m_iNeurons), m_iWindow))

         return false;
```

Next, we will directly collect error gradients for filter elements. Similar to the fully connected layer, the weight gradient in the convolutional layer is equal to the product of the neuron error gradient and the value of the corresponding element of the input data. In terms of matrix operations, all we need to do is multiply the gradient matrix before the activation function by the reformatted matrix of input data.

```
MATRIX g = m_cGradients.m_mMatrix;

      if(!g.Reshape(m_iWindowOut, m_iNeurons))

         return false;

i      m_cDeltaWeights.m_mMatrix += g.MatMul(inp);

     }
```

We will add the obtained result to the previously accumulated error gradients in the m_cDeltaWeights matrix.

```
else

     {

//--- The multi-threaded calculation block will be added in the next chapter

      return false;

     }

//--- Successful completion of the method

   return true;

  }
```

We will become familiar with the algorithm for implementing multi-threaded computations in the next chapter, and at this stage, we exit the method with a positive result.

We've already discussed the weight update method earlier. We still need to create methods for working with files because we should have the ability to load and use a previously trained neural network. And here, we will also use the previously created groundwork. We have already created similar methods for two parent classes: the base class of the neural layer CNeuronBase, and the pooling layer CNeuronProof. Pooling layer methods are greatly simplified since it does not contain a matrix of weights and objects for its training. Therefore, we will use the base class method and force it to be called from the CNeuronConv::Save method. This approach will help us eliminate unnecessary controls since they are already implemented in the parent class method. We just have to check the result of the method. But we need more than that because the pooling layer introduces new variables. Therefore, after executing the parent class method, we will add the missing parameters to the file.

```
bool CNeuronConv::Save(const int file_handle)

  {

//--- call the method of the parent class

   if(!CNeuronBase::Save(file_handle))

      return false;

//--- save constant values

   if(FileWriteInteger(file_handle, (int)m_iWindow) <= 0)

      return false;

   if(FileWriteInteger(file_handle, (int)m_iStep) <= 0)

      return false;

   if(FileWriteInteger(file_handle, (int)m_iWindowOut) <= 0)

      return false;

   if(FileWriteInteger(file_handle, (int)m_iNeurons) <= 0)

      return false;

   if(FileWriteInteger(file_handle, (int)m_bTransposedOutput) <= 0)

      return false;

//---

   return true;

  }
```

The data loading is organized on the same principle. First, we need to read the data from the file in the same order in which it was written there. Hence, we will first call the method of the parent class. In it, all the controls are already implemented, and the sequence of data loading is observed. We only need to check the result returned by the parent class method, and after successful execution, read additional parameters from the file in the same sequence in which they were saved.

```
bool CNeuronConv::Load(const int file_handle)

  {

//--- calling the method of the parent class

   if(!CNeuronBase::Load(file_handle))

      return false;

//--- reading the values ​​of constants

   m_iWindow = (uint)FileReadInteger(file_handle);

   m_iStep = (uint)FileReadInteger(file_handle);

   m_iWindowOut = (uint)FileReadInteger(file_handle);

   m_iNeurons = (uint)FileReadInteger(file_handle);

   m_eActivation = -1;

//---

   if(!m_cOutputs.Reshape(m_iWindowOut, m_iNeurons))

      return false;

   if(!m_cGradients.Reshape(m_iWindowOut, m_iNeurons))

      return false;

//---

   return true;

  }
```

In this section, we created two new types of neural layers: pooling and convolutional. In the next section, we will further enhance their functionality with the ability to use the OpenCL for organizing parallel computations using multi-threading technologies. Then, in the comparative testing block, we will assemble a small neural network and compare the performance of the new architectural solution with the previously obtained testing results of fully connected neural networks.

## Organizing parallel computing in convolutional networks using OpenCL

In the previous section, we already created classes for two new types of neural layers. These are the convolutional and pooling layers. These types of layers are key in the architecture of convolutional neural networks. By alternating convolutional and pooling layers, we can create a model that searches for the key components of the desired object in the array of source data while simultaneously reducing the size of the processed information without sacrificing the overall performance of the model. This approach also helps filter out noise from the source data.

Reducing the information volume leads to a reduction in the cost of processing it. Furthermore, we can also parallelize computations in the convolutional and pooling layers using the technology of multi-threaded calculations in OpenCL. This will help reduce the time required for calculations while maintaining the overall operation volume, making the training and operation of the neural network much faster.

To organize multi-threaded operations using OpenCL, we need to perform two blocks of operations:

- Write additional kernels in the previously created OpenCL program ([opencl_program.cl](https://www.mql5.com/en/neurobook/index/realization/pr_opencl/opencl_programm)).

- Organize the process of interaction with the OpenCL context on the side of the main program.

Before organizing the transfer of data from the main program to the OpenCL context, it is necessary to understand when and what data will be needed. Therefore, we will begin our work by making changes to the OpenCL program.

#### Pooling layer

The creation of kernels in the OpenCL program and the construction of classes in the main program will start with the implementation of methods for the pooling layer. Feed-forward operations will be implemented in the ProofFeedForward kernel. We will transfer two data buffers from the main program to the kernel:

- inputs: a vector of input data

- outputs: a vector for writing results

To prevent an array out-of-bounds error, we will pass the size of the inputs_total initial data vector to the kernel in the parameters.

Let me remind you that in the convolutional neural networks algorithm, the pooling layer follows the convolutional layer of neurons. In turn, the convolutional layer includes several filters. Therefore, when receiving the results of the work of multiple filters from the convolutional layer in a single buffer, the pooling layer should process each filter separately. Therefore, to logically divide the common buffer of results of the convolutional layer by filters, the kernel will be given the size of the output vector of one filter input_neurons.

In the kernel parameters, we specify the window size for analyzing the initial data (window), the step for moving the window (step), the number of filters (window_out), and the activation function (activation).

```
__kernel void ProofFeedForward(__global double *inputs,

                               __global double *outputs,

                               int inputs_total,

                               int input_neurons,

                               int window,

                               int step,

                               int activation)
```

We will run this kernel in a two-dimensional task space. Thus, in each kernel, we will process one element of the results array in one filter. The number of the processed element will be determined by the thread identifier in dimension with index 0. Therefore, the total number of threads will tell us the number of elements in the output of one filter (neurons). Using this data, we will determine the offsets to the beginning of the window of analyzed data within the filter array of the initial data (shift).

```
{

   const int n = get_global_id(0);

   const int w = get_global_id(1);

   const int neurons = get_global_size(0);

   const int window_out = get_global_size(1);

   int shift = n * step;
```

The second dimension with index 1 will indicate the index of the analyzed filter. Accordingly, we will determine the shift in the arrays of initial data (shift_inp) and results (out) before the beginning of the processed filter. Don't forget to check for any out-of-range errors within the result array.

Let's prepare a variable to store intermediate values of the current element of the result vector (s).

```
int out = w * neurons + n;

   int shift_inp = w * input_neurons;

   TYPE s = 0;

   TYPE k = (TYPE)1 / (TYPE)window;

   TYPE4 k4 = (TYPE4)(k);
```

The values in the pooling layer will be computed in a nested array. In it, we will iterate through the elements of the input data that fall within the analyzed window and assemble the resulting value according to the activation formula.

Let me remind you that in our implementation, the pooling layer can receive one of two activation functions:

- Average pooling which involves taking the arithmetic mean of the elements within the input data window.

- Max pooling which involves selecting the maximum element within the input data window.

When calculating the arithmetic mean, we will not collect the sum of all elements and then divide by the size of the analyzed window. On the contrary, each element is first divided by the size of the window, and then the resulting quotients are summed up. This will allow us to get the final result in the body of the loop, eliminating the division operation behind the loop. The implementation of the division operation behind the loop is not critical, but only if it concerns any variants of operations in the loop. In our case, division is necessary only in the case of the arithmetic mean. When using Max pooling, the division is redundant, and for correct operation, we would need an additional check of the activation function. By moving the division inside the loop, we eliminate the need for an additional check for the activation function and only apply it when calculating the actual value.

Please note that we use vector operations with TYPE4 data type to speed up the process. Consequently, the step of the loop through the elements of the window is equal to four.

```
for(int i = 0; i < window; i += 4)

      switch(activation)

        {

         case 0:

            s += dot(ToVect4(inputs, i, 1, min(shift_inp+input_neurons,inputs_total),

                             shift_inp + shift), k4);

            break;

         case 1:

            s = Max4(ToVect4(inputs, i, 1, min(shift_inp+input_neurons,inputs_total),

                             shift_inp + shift), s);

            break;

         default:

            break;

        }

   outputs[out] = s;

  }
```

After exiting the loop that iterates over the elements of the analyzed window, we will save the obtained value into the corresponding element of the result vector and exit the kernel.

We have examined the feed-forward kernel and can now proceed to build the algorithm for the backpropagation pass. As discussed earlier in the context of building the algorithm using MQL5, in the pooling layer, the backpropagation pass algorithm involves simply propagating the error gradient through the hidden layer. Therefore, the process of constructing the backpropagation pass will consist of writing the ProofCalcHiddenGradient gradient propagation kernel algorithm.

The new kernel will communicate with the external program through four data buffers:

- inputs: buffer for the results of the preceding layer

- gradient_inputs: buffer for the gradients of the preceding layer (in this case, it is used to record the results of the kernel operation)

- outputs: buffer for the results of the forward pass of the current layer

- gradients: buffer for the gradients at the results level of the current layer

Buffer size control will be organized using the inputs_total and outputs_total parameters. The names of the parameters correspond to the buffers whose sizes they store.

It is important to note that, unlike a fully connected layer, neurons in the pooling layer have limited connections to neurons in the previous layer. We will define connection zones using the window and step parameters. You can see that parameters of the same name were declared in the forward pass kernel. We have also retained their functional significance.

Let's add parameters for the number of elements per filter output and the activation function being used.

```
__kernel void ProofCalcHiddenGradient(__global TYPE *inputs,

                                      __global TYPE *gradient_inputs,

                                      __global TYPE *outputs,

                                      __global TYPE *gradients,

                                      int inputs_total,

                                      int outputs_total,

                                      int window,

                                      int step,

                                      int neurons,

                                      int activation)
```

When organizing multi-threaded computations, it's important to consider the issue of concurrent attempts to write to the same buffer elements from different threads. Therefore, the most suitable algorithms are those in which each thread is provided with its own objects for writing data, and these objects do not intersect with objects being written to by other threads.

Following the logic mentioned above, we will create an algorithm in which each thread will collect gradients and write them to a separate element of the gradient buffer of the previous layer. It should be noted that one difference in this approach compared to the one we adopted in the MQL5 implementation is as follows. When using the Max pooling activation function, if there are two or more elements with values equal to the maximum, the gradient will be fully transferred to all such elements. In contrast, in the implementation of the main program, we passed the gradient to only one element. Considering the use of variables and their precision, we assess the risk of encountering such a situation as minimal and accept it.

At the beginning of the kernel body, let's determine the ordinal number of the required element and the filter by stream identifiers. The total number of threads will give us the number of elements of one filter in the input data buffer (input_neurons) and the number of filters (window_out). Based on this data, we determine the first (start) and last (stop) elements of the resulting vector, which are affected by the processed element. When defining the influence zone, we need to keep in mind the limitations of the data buffer dimension for each filter. Therefore, the first element cannot be less than 0, and the last element cannot be greater than the number of elements in one filter (neurons).

```
{

   const int n = get_global_id(0);

   const int w = get_global_id(1);

   const int input_neurons = get_global_size(0);

   const int window_out = get_global_size(1);

//---

   int start = n - window + step;

   start = max((start - start % step) / step, 0);

   int stop = min((n - n % step) / step + 1, neurons);
```

Next, we determine the offset of the analyzed element in the common initial data buffer. At the same time, do not forget to check for going beyond the array of initial data.

After that, we will prepare the necessary internal variables. First of all, this is a variable for collecting intermediate values of the gradient (grad) and the value of the current element in the source data buffer (inp).

The creation of the last condition is because when using Max pooling, we will need to constantly compare the value of an element in the source data with the value from the results buffer. For technical reasons, accessing internal variables is much faster than accessing elements of the global array buffer. This is related to the storage location of the data. Internal variables are stored in private memory, while buffers are stored in global memory. The size of the private memory is small, and we cannot copy the entire array there, but accessing it takes minimal time. The size of the global memory is much larger, but the access time to it is significantly longer. To reduce the overall running time of the program, we will move a frequently used value from the global to the private memory of the OpenCL context.

```
TYPE grad = 0;

   int shift_inp = w * input_neurons + n;

   if(shift_inp >= inputs_total)

      return;

   TYPE inp = inputs[shift_inp];
```

Next, we will organize a nested loop in which we will iterate over the elements that fall within the influence zone of the analyzed element of the input data. Inside the loop, we will first determine the offset of the processed element in the gradient error buffer. We will immediately check if the error gradients array falls within the boundaries. Then we will transfer the gradient in accordance with the activation function used.

For Average pooling, we simply divide the value of the error gradient by the size of the input data window and add the resulting value to the accumulated error gradient of the analyzed source data element. Please note that we will divide the error gradient by the size of the input data window, and not by the zone of influence. Indeed, the error obtained during the feed-forward pass is influenced by all the elements of the input data that affect the specific value.

In the case of Max pooling, we will first compare the value of the corresponding elements at the output and input of the neural layer. Only if they match will we transmit the error gradient in full.

After exiting the loop, we will save the computed gradient value in the gradient error buffer of the previous layer and conclude the execution of the kernel.

```
for(int o = start; o < stop; o ++)

     {

      int shift_g = w * neurons + o;

      if(shift_g >= outputs_total)

         break;

      switch(activation)

        {

         case 0:

            grad += gradients[shift_g] / (TYPE)window;

            break;

         case 1:

            grad += (outputs[shift_g] == inp ? gradients[shift_g] : 0);

            break;

         default:

            break;

        }

     }

   gradient_inputs[shift_inp] = grad;

  }
```

The above two kernels cover the forward and backward pass processes in the pooling layer. Now we can move on to working with the convolutional layer.

#### Convolutional layer

Convolutional layer For the convolutional layer, we also have to implement forward and backward pass algorithms. Similarly to the kernels discussed earlier, the forward pass algorithm will be described in the ConvolutionFeedForward kernel. A convolutional layer, like a fully connected one, has a weight matrix and an activation function. Therefore, to communicate with the main program, we need four data buffers:

- inputs: input data buffer

- weights: matrix of weights

- sums: vector of weighted sums of the original data before the activation function

- outputs: vector of results

In addition to buffers, for the proper functioning of the new kernel, the following parameters will be required:

- inputs_total: size of the input data array

- window: size of the analyzed window of the source data

- step: step of the source data window

- window_out: number of filters in the layer

```
__kernel void ConvolutionFeedForward(__global TYPE *inputs,

                                     __global TYPE *weights,

                                     __global TYPE *outputs,

                                     int inputs_total,

                                     int window,

                                     int step,

                                     int window_out)
```

Building the algorithm of the kernel itself is similar to constructing a similar kernel for a fully connected neuron. Just like in the fully connected layer, the number of threads will be tied to the number of elements in the output buffer. However, considering the specific nature of the convolutional layer's operation, we will not be guided by the total number of elements in the buffer, but by the number of elements in the results buffer of a single filter. In this case, the results of the n-th element of all filters will be calculated in one thread.

At the beginning of the kernel, we will carry out preparatory work. We will determine the index of the processed element in the filter results buffer based on the thread number. The total number of threads will give us the number of elements in the output of each filter. From the obtained data and information from the kernel parameters, we will calculate the offset to the beginning of the analyzed window in the source data buffer and the size of the weight matrix being used.

```
{

   const int n = get_global_id(0);

   const int neurons = get_global_size(0);

   const int weights_total = (window + 1) * window_out;

   int shift = n * step;
```

Since we decided to process all the filters sequentially in one thread, the next thing we do is organize a filter iteration loop. Inside the loop, we determine the offset to the processed element in the general result buffer and the offset in the weight matrix. At this point, we will also check for any out-of-bounds access to the weight matrix and prepare an internal variable for collecting the resulting value. We will initialize the variable with the bias element.

```
for(int w = 0; w < window_out; w++)

     {

      int out = (transposed_out == 1 ? w + n * window_out : w * neurons + n);

      int shift_weights = w * (window + 1) ;

      if((shift_weights + window) >= weights_total)

         break;

      TYPE s = weights[shift_weights + window];
```

We will directly calculate the weighted sum of the analyzed input data window in a nested loop. Inside this loop, we will iterate through the elements of the analyzed window of input data and multiply them by the corresponding weight. To reduce the time spent on execution, we use vector operations. At the same time, do not forget to increase the size of the cycle step to the size of the used vector variables.

```
for(int i = 0; i < window; i += 4)

         s += dot(ToVect4(inputs, i, 1, inputs_total, shift),

                  ToVect4(weights, i, 1, shift_weights + window, shift_weights));

      outputs[out] = s;

     }

  }
```

After collecting the weighted sum, we write the resulting value to the result buffer.

Next, we move on to creating kernels for the backward pass process. Unlike the pooling layer, the convolutional layer contains a weight matrix. Therefore, we will need to create more than one kernel, as in a similar process of a fully connected layer.

We will start building the process as before, following the algorithm of the backpropagation pass. We will fully apply the adjustments of the gradient based on the derivative of the activation function, just as we did for the fully connected layer. Let's start working on the convolutional layer by creating a gradient propagation kernel through the ConvolutionCalcHiddenGradient layer.

In this case, propagating the gradient to the lower layer does not depend on the input data and the results of the forward pass. Therefore, for our kernel to work, we will give it three data buffers:

- gradient_inputs: buffer for the error gradients of the preceding layer (in this case, the result buffer)

- weights: weight matrix

- gradients: buffer for the error gradients at the input of the current layer

In addition to data buffers, a number of parameters are required for the correct operation of the kernel:

- outputs_total: total number of elements in the result buffer (gradients at the output of the current neural layer);

- window: size of the input data window (the number of input data elements analyzed by one neuron of the current layer);

- step: step of moving the window along the array of initial data;

- window_out: number of filters in the current convolutional layer;

- neurons: number of elements at the output of one filter.

```
__kernel void ConvolutionCalcHiddenGradient(__global TYPE *gradient_inputs,

                                            __global TYPE *weights,

                                            __global TYPE *gradients,

                                            int window,

                                            int step,

                                            int window_out,

                                            int neurons)
```

The kernel will be launched in a multi-threaded mode with the number of threads equal to the number of elements in the gradient error buffer of the previous layer, which is also equal to the number of elements in the input data buffer.

As usual, at the beginning of the kernel, we determine the ordinal number of the element being processed by the number of the current thread and the number of elements in the gradient buffer of the previous layer by the total number of running threads. Additionally, we calculate the size of the weight matrix based on the size of the input data window and the number of filters in the current convolutional layer.

```
{

   const int n = get_global_id(0);

   const int inputs_total = get_global_size(0);

   int weights_total = (window + 1) * window_out;
```

Continuing the preparatory work, let's determine the zone of influence of the current element in the result buffer of one filter and prepare an internal variable to record the intermediate results of the accumulation of the error gradient for the processed element.

```
TYPE grad = 0;

   int w_start = n % step;

   int r_start = max((n - window + step) / step, 0);

   int total = (window - w_start + step - 1) / step;

   total = min((n + step) / step, total);
```

Let me remind you that when creating the convolution layer class in the main program, we decided to consider the array of initial data as a single whole and apply all filters to the total amount of data. Therefore, each element of the input data affects the results of all filters. This means that we have to collect the error gradient on each element of the initial data from all filters. Therefore, to collect error gradients, we need a system of nested loops with iteration of filters and elements of each filter.

The outer loop iterates over the elements of the error gradient vector at the output of the current neural layer. In it, we will determine the offset to a specific element in the gradient vector and immediately check for going beyond the filter size.

```
for(int i = 0; i < total; i ++)

     {

      int row = r_start + i;

      if(row >= neurons)

         break;
```

In the body of the nested loop, we will first determine the offset in the gradient buffer of the error at the output of the current layer and the weight matrix. Then, we will add the product of the values of these elements to the previously accumulated error gradient for the analyzed element of the original data.

```
for(int wo = 0; wo < window_out; wo++)

        {

         int shift_g = (transposed_out == 1 ? row * window_out + wo :

                                                        row + wo * neurons);

         int shift_w = w_start + (total - i - 1) * step + wo * (window + 1);

         grad += gradients[shift_g] * weights[shift_w];

        }

     }

   gradient_inputs[n] = grad;

  }
```

After completion of all iterations and exiting from the block of two nested loops, the value of the accumulated gradient is stored in the error gradient buffer of the previous layer.

The distribution of the error gradient through the hidden layers of the neural network, in accordance with the algorithm of the error backward pass method, is followed by the transfer of the error gradient to weights. To perform this functionality, we create the ConcolutionCalcDeltaWeights kernel.

For the correct operation of the kernel, the use of 3 data buffers will be required:

- inputs: input data buffer

- delta_weights: buffer for the accumulated error gradients of the weight matrix (in this case, the results buffer)

- gradients: buffer for the error gradients of the current layer (at the results level)

The gradient buffer contains the values of the error gradients already corrected for the derivative of the activation function. This procedure is performed before passing the error gradient to the previous layer. Therefore, adjusting for the derivative of the activation function at this stage will be unnecessary.

In addition to the data buffers, we need to introduce a few parameters in order to build the algorithm correctly:

- inputs_total: total number of elements in the result buffer and, respectively, the error gradient buffer

- step: step of moving the analyzed data window along the source data array

- neurons: number of elements at the output of one filter

```
__kernel void ConvolutionCalcDeltaWeights(__global TYPE *inputs,

                                          __global TYPE *delta_weights,

                                          __global TYPE *gradients,

                                          int inputs_total,

                                          int step,

                                          int neurons)
```

It can be noticed that among the parameters, there are no variables to indicate the size of the window for the analyzed data and the number of filters in the current convolutional layer. This is due to a change in the approach to creating threads for operations. This kernel will collect error gradients at the level of the weight matrix, so it is quite logical to run the kernel for each weight. Furthermore, the weight matrix is represented as a two-dimensional table, where each row corresponds to a separate filter, and the elements within each row are the weights of the corresponding filter.

The OpenCL technology allows threads to be launched in two-dimensional space, with two indices for each thread. Let's use this property and create threads for this kernel in two dimensions. In the first dimension, the number of threads will be equal to the number of weights in one filter. In the second dimension, the number of threads will correspond to the number of filters used.

In the body of the kernel, we will determine the position of the analyzed element in the weight matrix and its dimensions. It should be recalled here that each filter has a bias weight, so the size of the analyzed data window will be one element less than the number of threads in the first dimension (the dimension with index 0).

Right there, we will determine the position of the analyzed element in the one-dimensional buffer of the weight matrix and the offset to the beginning of the corresponding filter in the error gradient buffer. And of course, let's prepare a variable to store intermediate values of the accumulated error gradient.

```
{

   const int inp_w = get_global_id(0);

   const int w = get_global_id(1);

   const int window = get_global_size(0) - 1;

   const int window_out = get_global_size(1);

//---

   int shift_delt = w * (window + 1) + inp_w;

   TYPE value = 0;
```

Next comes the process of directly calculating the error gradient. Here we must remember that for the bias element, there are no corresponding elements in the source data buffer. Therefore, the gradient will be transferred to this element in full. In order not to check at each iteration of the loop, we will do it once before starting the loop. In the loop, we will iterate through the elements of the error gradient buffer and the original data, while the element of the weight matrix remains unchanged.

Thus, first, we check whether the current element of the weight matrix is a bias, and then we organize a loop to iterate through all the error gradient elements of the corresponding filter. Inside the loop, we will sum up the error gradient adjusted for the corresponding value of the initial data buffer.

After exiting the loop, add the obtained value to the previously accumulated error gradient for the analyzed element of the weight matrix. Let me remind you that we will not update the weight matrix at each iteration of the backward pass. We only accumulate the error gradient. The weight matrix is updated by a command from the main program after processing the data package installed by the user.

```
if(inp_w == window)

     {

      for(int n = 0; n < neurons; n ++)

         value += gradients[w * neurons + n];

     }

   else

      for(int n = 0; n < neurons; n ++)

        {

         int shift_inp = n * step + inp_w;

         if(shift_inp >= inputs_total)

            break;

         value += inputs[shift_inp] * gradients[w * neurons + n];

        }

   delta_weights[shift_delt] += value;

  }
```

After distributing the error gradient to the weight matrix through the backpropagation algorithm, its update is provided. The weights are adjusted towards the anti-gradient. As mentioned before while creating the convolutional layer using MQL5, the previously established process for the fully connected layer fully meets the requirements for working with convolutional layers as well. Therefore, we will not create separate kernels and blocks of the main program but will use the previously created solution.

#### Implementing functionality on the side of the main program

After supplementing the OpenCL program with new kernels, we have to embed code blocks into the main program to organize the process of data exchange and launch kernels for execution at the right time and with the right amount of information. Let's take a closer look at how this can be implemented.

As a reminder, when building a fully connected neural layer, we started [similar work](https://www.mql5.com/en/neurobook/index/realization/pr_opencl) by declaring constants. Now we will do the same: we will declare constants for calling each kernel.

```
#define def_k_ProofFeedForward            21

#define def_k_ProofHiddenGradients        22

#define def_k_ConvolutionFeedForward      23

#define def_k_ConvolutionHiddenGradients  24

#define def_k_ConvolutionDeltaWeights     25
```

We will also declare parameter constants for each kernel. The constants of the parameters must strictly correspond to the ordinal number of the parameter in the OpenCL program kernel. Parameter numbering starts from zero.

```
//--- feed-forward pass of the pooling layer

#define def_prff_inputs                   0

#define def_prff_outputs                  1

#define def_prff_inputs_total             2

#define def_prff_input_neurons            3

#define def_prff_window                   4

#define def_prff_step                     5

#define def_prff_activation               6
```

```
//--- gradient distribution through the pooling layer

#define def_prhgr_inputs                  0

#define def_prhgr_gradient_inputs         1

#define def_prhgr_outputs                 2

#define def_prhgr_gradients               3

#define def_prhgr_inputs_total            4

#define def_prhgr_outputs_total           5

#define def_prhgr_window                  6

#define def_prhgr_step                    7

#define def_prhgr_neurons                 8

#define def_prff_activation               9
```

```
//--- feed-forward pass of the convolutional layer

#define def_cff_inputs                    0

#define def_cff_weights                   1

#define def_cff_outputs                   2

#define def_cff_inputs_total              3

#define def_cff_window                    4

#define def_cff_step                      5

#define def_cff_window_out                6
```

```
//--- gradient distribution through the convolutional layer

#define def_convhgr_gradient_inputs       0

#define def_convhgr_weights               1

#define def_convhgr_gradients             2

#define def_convhgr_window                3

#define def_convhgr_step                  4

#define def_convhgr_window_out            5

#define def_convhgr_neurons               6
```

```
//--- distribution of the gradient to the weight matrix of the convolutional layer

#define def_convdelt_inputs               0

#define def_convdelt_delta_weights        1

#define def_convdelt_gradients            2

#define def_convdelt_inputs_total         3

#define def_convdelt_step                 4

#define def_convdelt_neurons              5
```

After declaring the constants, we need to update the list of used kernels from the OpenCL program. Let me remind you that this work is carried out in the [CNet: :InitOpenCL](https://www.mql5.com/en/neurobook/index/realization/pr_opencl/opencl_transfer_data#initopemcl) method. Here we need to change the number of used kernels to 26.

```
if(!m_cOpenCL.SetKernelsCount(26))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

Let's create entry points for new kernels.

```
if(!m_cOpenCL.KernelCreate(def_k_ProofFeedForward, "ProofFeedForward"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

```
if(!m_cOpenCL.KernelCreate(def_k_ProofHiddenGradients,

                                               "ProofCalcHiddenGradient"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

```
if(!m_cOpenCL.KernelCreate(def_k_ConvolutionFeedForward,

                                                "ConvolutionFeedForward"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

```
if(!m_cOpenCL.KernelCreate(def_k_ConvolutionHiddenGradients,

                                         "ConvolutionCalcHiddenGradient"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

```
if(!m_cOpenCL.KernelCreate(def_k_ConvolutionDeltaWeights,

                                            "ConcolutionCalcDeltaWeights"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

Further work will continue directly in the relevant methods. Remember that during the construction of classes, we implemented branching in many methods depending on the device used for executing operations. We have already written the MQL5 part. Now we will describe the algorithm for working with the OpenCL context.

We will supplement the methods in the same sequence in which we created them earlier. Let's start this work with the feed-forward method of the pooling layer CNeuronProof::FeedForward. To work correctly, this method uses two data buffers: initial data and results. At the beginning of the block, check for the presence of the specified buffers in the OpenCL context. The presence of a buffer handle will indicate a previously passed buffer to the OpenCL context.

```
bool CNeuronProof::FeedForward(CNeuronBase *prevLayer)

  {

//--- Control block

   if(!prevLayer || !m_cOutputs ||

      !prevLayer.GetOutputs())

      return false;

   CBufferType *input_data = prevLayer.GetOutputs();

//--- Algorithm branching depending on the operating device

   if(!m_cOpenCL)

     {

     // The MQL5 block is missing here

     }

   else // Block of operations with OpenCL

     {

      //--- check the availability of buffers in the OpenCL context

      if(input_data.GetIndex() < 0)

         return false;

      if(m_cOutputs.GetIndex() < 0)

         return false;
```

If there is data in the OpenCL context, we will pass pointers to the data buffers and parameters necessary for its operation to the kernel. At each step, we also check the result of the operations. This is crucial because launching a kernel with incomplete information can lead to a critical error and the halt of the entire program.

```
//--- Send parameters to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_ProofFeedForward, def_prff_inputs,

                                                         input_data.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_ProofFeedForward, def_prff_outputs,

                                                         m_cOutputs.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ProofFeedForward, def_prff_inputs_total,

                                                            input_data.Total()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ProofFeedForward, def_prff_window,

                                                                     m_iWindow))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ProofFeedForward, def_prff_step, m_iStep))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ProofFeedForward, def_prff_activation,

                                                            (int)m_eActivation))

         return false;

      uint input_neurons = (input_data.Total()+m_iWindowOut-1) / m_iWindowOut;

      if(!m_cOpenCL.SetArgument(def_k_ProofFeedForward, def_prff_input_neurons,

                                                                 input_neurons))

         return false;
```

Once all the necessary information is passed to the kernel, we then need to specify the number of threads for kernel execution and the initial offset in the task space. After that, we initiate the execution of the kernel and complete the method.

```
//--- Queuing up the kernel for execution

      uint off_set[] = {0, 0};

      uint NDRange[] = {m_iNeurons, m_iWindowOut};

      if(!m_cOpenCL.Execute(def_k_ProofFeedForward, 2, off_set, NDRange))

         return false;

     }

//---

   return true;

  }
```

After adding the code for the CNeuronProof::FeedForward forward pass method of the pooling layer, let's do the same work in the CNeuronProof::CalcHiddenGradient backward pass method. Unlike the forward pass, the error gradient distribution kernel through the pooling layer uses four data buffers:

- initial data

- feed-forward results

- error gradients at the output of the neural layer

- error gradients at the source data level (the result buffer in this case).

The first two buffers are used to determine which elements to employ when using Max pooling.

Therefore, we have to load all four buffers into the memory of the OpenCL context.

```
bool CNeuronProof::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

//--- Control block

   if(!prevLayer || !m_cOutputs ||

      !m_cGradients || !prevLayer.GetOutputs() ||

      !prevLayer.GetGradients())

      return false;

   CBufferType *input_data = prevLayer.GetOutputs();

   CBufferType *input_gradient = prevLayer.GetGradients();

   if(!input_gradient.BufferInit(input_data.Rows(), input_data.Cols(), 0))

      return false;

//--- Algorithm branching depending on the operating device

   if(!m_cOpenCL)

     {

     // The MQL5 block is missing here

     }

   else    // Block of operations with OpenCL

     {

      //--- check for buffers in the OpenCL context

      if(input_data.GetIndex() < 0)

         return false;

      if(m_cOutputs.GetIndex() < 0)

         return false;

      if(input_gradient.GetIndex() < 0)

         return false;

      if(m_cGradients.GetIndex() < 0)

         return false;
```

If there is data in the memory of the OpenCL context, we will pass pointers to buffers and necessary constants to the kernel parameters. At the same time, do not forget to control the results of the operations.

```
//--- Send parameters to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_ProofHiddenGradients,

                                         def_prhgr_inputs, input_data.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_ProofHiddenGradients,

                                        def_prhgr_outputs, m_cOutputs.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_ProofHiddenGradients,

                                    def_prhgr_gradients, m_cGradients.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_ProofHiddenGradients,

                            def_prhgr_gradient_inputs, input_gradient.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ProofHiddenGradients,

                                      def_prhgr_inputs_total, input_data.Total()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ProofHiddenGradients,

                                                     def_prhgr_window, m_iWindow))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ProofHiddenGradients,

                                                         def_prhgr_step, m_iStep))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ProofHiddenGradients,

                                        def_prhgr_activation, (int)m_eActivation))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ProofHiddenGradients,

                                                   def_prhgr_neurons, m_iNeurons))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ProofHiddenGradients,

                                     def_prhgr_outputs_total, m_cOutputs.Total()))

         return false;
```

Then we specify the number of threads to run the kernel and the offset in the task area. After that, we will put the kernel in the execution queue.

Please note that when launching the forward pass kernel, the number of threads is equal to the number of elements at the output of one filter in the pooling layer. When running a backward pass kernel, the number of threads is equal to the number of elements in one filter of the previous neural layer.

```
//--- Queuing up the kernel for execution

      uint input_neurons = (input_data.Total() + m_iWindowOut - 1) / m_iWindowOut;

      uint off_set[] = {0, 0};

      uint NDRange[] = {input_neurons, m_iWindowOut};

      if(!m_cOpenCL.Execute(def_k_ProofHiddenGradients, 2, off_set, NDRange))

         return false;

     }

//---

   return true;

  }
```

This completes the work with the pooling layer class. We move on to do a similar job with the CNeuronConv convolutional layer class.

The convolutional neural layer, unlike the pooling layer, has a weight matrix and an activation function. Therefore, it will require the use of more buffers for its operation. The CNeuronConv::FeedForward forward pass method of the convolutional layer requires transferring 4 buffers to the OpenCL context memory:

- initial data

- weight matrix

- additional activation function buffer (used for Swish activation function)

- results buffer

Let's start working in the CNeuronConv::FeedForward forward pass method by checking the availability of buffers in use in the context of OpenCL.

```
bool CNeuronConv::FeedForward(CNeuronBase *prevLayer)

  {

//--- control block

   if(!prevLayer || !m_cOutputs || !m_cWeights || !prevLayer.GetOutputs())

      return false;

   CBufferType *input_data = prevLayer.GetOutputs();

   ulong total = input_data.Total();

//--- algorithm branching depending on the operating device

   if(!m_cOpenCL)

     {

     // The MQL5 block is missing here

     }

   else

     {

      //--- checking data buffers

      if(input_data.GetIndex() < 0)

         return false;

      if(m_cWeights.GetIndex() < 0)

         return false;

      if(m_cOutputs.GetIndex() < 0)

         return false;
```

Then we need to pass buffer pointers to the corresponding kernel. In addition, in the kernel parameters, we will pass some constants necessary for the correct operation of the algorithm. Among the passed parameters will be the size of the analyzed window, the window step and the number of filters. At each step, we control the process of performing operations.

```
//--- pass arguments to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionFeedForward,

                                          def_cff_inputs, input_data.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionFeedForward,

                                         def_cff_weights, m_cWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionFeedForward,

                                         def_cff_outputs, m_cOutputs.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ConvolutionFeedForward,

                                       def_cff_inputs_total, input_data.Total()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ConvolutionFeedForward,

                                                      def_cff_window, m_iWindow))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ConvolutionFeedForward,

                                                           def_cff_step, m_iStep))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ConvolutionFeedForward,

                                                 def_cff_window_out, m_iWindowOut))

         return false;
```

After passing all the necessary data to the kernel, we specify the number of threads to start and initiate its queuing.

```
//--- put the kernel in the execution queue

      int off_set[] = {0};

      int NDRange[] = {(int)m_iNeurons};

      if(!m_cOpenCL.Execute(def_k_ConvolutionFeedForward, 1, off_set, NDRange))

         return false;

     }

   if(!m_cActivation.Activation(m_cOutputs))

      return false;

//---

   return true;

  }
```

Finally, we call the activation function and exit the method.

That's all for the feed-forward pass. Let's proceed to the backpropagation pass in the convolutional neural layer. As you remember, the backpropagation pass includes three sub-processes:

- Distributing the error gradient over the neural network from the result to the initial data.

- Distributing the error gradient to the weight matrix of each neural layer.

- Adjusting the weight matrix towards the anti-gradient.

From the methods already implemented using MQL5, we know that no new method was created for the last sub-process. Instead, it is suggested to use the ready-made method of the fully connected neural layer, where we have already implemented multi-threaded computations using OpenCL tools. Therefore, at this stage, we have to refine only the methods of the first two sub-processes.

The CNeuronConv::CalcHiddenGradient method is responsible for distributing the error gradient across the convolutional layer. Correct execution of the algorithm of this method requires the presence of three data buffers:

- Buffer for error gradients at the output of the neural layer (obtained from the next layer in the process of executing a similar method).

- Weight matrix.

- Buffer for error gradients at the input data level (in this case, it acts as a buffer for the results of the method).

Therefore, at the beginning of the block of work with the OpenCL technology, we check the presence of the necessary buffers in the context memory.

```
bool CNeuronConv::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

//--- control block

   if(!prevLayer || !prevLayer.GetOutputs() || !prevLayer.GetGradients() ||

      !m_cGradients || !m_cWeights)

      return false;

//--- adjust error gradients to the derivative of the activation function

   if(m_cActivation)

     {

      if(!m_cActivation.Derivative(m_cGradients))

         return false;

     }

//--- algorithm branching depending on the operating device

   CBufferType* input_gradient = prevLayer.GetGradients();

   if(!m_cOpenCL)

     {

     //The MQL5 block is missing here

     }
```

```
else // Block for working with OpenCL

     {

      //--- checking data buffers

      if(m_cWeights.GetIndex() < 0)

         return false;

      if(input_gradient.GetIndex() < 0)

         return false;

      if(m_cGradients.GetIndex() < 0)

         return false;
```

The next step is to pass the necessary data to the kernel parameters. Among them are pointers to the data buffers used.

```
//--- pass arguments to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionHiddenGradients,

                        def_convhgr_gradient_inputs, input_gradient.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionHiddenGradients,

                                    def_convhgr_weights, m_cWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionHiddenGradients,

                                def_convhgr_gradients, m_cGradients.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ConvolutionHiddenGradients,

                                               def_convhgr_neurons, m_iNeurons))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ConvolutionHiddenGradients,

                                                 def_convhgr_window, m_iWindow))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ConvolutionHiddenGradients,

                                                     def_convhgr_step, m_iStep))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ConvolutionHiddenGradients,

                                          def_convhgr_window_out, m_iWindowOut))

         return false;
```

Next, we will specify the number of threads equal to the number of elements in the source data buffer and enqueue the kernel for execution.

```
//--- put the kernel in the execution queue

      int NDRange[] = {(int)input_gradient.Total()};

      int off_set[] = {0};

      if(!m_cOpenCL.Execute(def_k_ConvolutionHiddenGradients, 1, off_set, NDRange))

         return false;

     }

//---

   return true;

  }
```

To complete the work on the backpropagation pass methods in the convolutional network, we need to make similar changes to the method for distributing the error gradient to the weight matrix CNeuronConv::CalcDeltaWeights , taking into account the specifics of this method.

The algorithm of the error gradient distribution method to the weight matrix requires the presence of three buffers:

- Error gradient at the output level of the neural layer.

- Initial data buffer.

- Buffer for accumulating error gradients at the weight matrix level.

Let's check the presence of the specified buffers in the memory of the OpenCL context. Let me remind you that we proceed from the assumption that there is enough video memory to store the entire model. If the model does not completely fit in the memory of your OpenCL device, then you will need to load the necessary data into the context memory before launching each kernel. After the completion of the kernel, free up memory to load the next batch of data.

```
bool CNeuronConv::CalcDeltaWeights(CNeuronBase *prevLayer)

  {

//--- control block

   if(!prevLayer || !prevLayer.GetOutputs() || !m_cGradients || !m_cDeltaWeights)

      return false;

//--- algorithm branching depending on the operating device

   CBufferType *input_data = prevLayer.GetOutputs();

   if(!m_cOpenCL)

     {

     // The MQL5 block is missing here

     }

   else // Block for working with OpenCL

     {

      //--- checking data buffers

      if(m_cGradients.GetIndex() < 0)

         return false;

      if(m_cDeltaWeights.GetIndex() < 0)

         return false;

      if(input_data.GetIndex() < 0)

         return false;
```

Then we pass the necessary parameters to the kernel corresponding to our sub-process. Let me remind you that it is very important to observe the correspondence of the specified kernel ID, parameter ID and the specified value, and we also control the process of performing operations at each step.

```
//--- pass arguments to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionDeltaWeights,

                        def_convdelt_delta_weights, m_cDeltaWeights.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionDeltaWeights,

                                    def_convdelt_inputs, input_data.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionDeltaWeights,

                               def_convdelt_gradients, m_cGradients.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ConvolutionDeltaWeights,

                                 def_convdelt_inputs_total, input_data.Total()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ConvolutionDeltaWeights,

                                              def_convdelt_neurons, m_iNeurons))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_ConvolutionDeltaWeights,

                                                    def_convdelt_step, m_iStep))

         return false;
```

When all the necessary information is transferred to the kernel, we specify the number of threads. In this case, we decided to use a two-dimensional thread distribution:

- by the number of filters

- by the number of weights in one filter

To do this, we specify two parameters in the NDRange array. Each parameter specifies the size of the corresponding task area. We send the kernel to the execution queue.

```
//--- put the kernel in the execution queue

      uint NDRange[] = {m_iWindow + 1, m_iWindowOut};

      uint off_set[] = {0, 0};

      if(!m_cOpenCL.Execute(def_k_ConvolutionDeltaWeights, 2, off_set, NDRange))

         return false;

     }

//---

   return true;

  }
```

Now we have already created three types of fully functional neural layers for our neural network builder and can compare their effectiveness in solving a practical problem. I suggest doing some experiments in the next chapter. But before proceeding to the "field tests", we still have to check the correctness of the methods for transferring gradients.

## Implementing a convolutional model in Python

We will implement the convolutional models in the Python language using the tools provided by the Keras library from TensorFlow. This library offers several options for convolutional layers. First of all, these are the basic versions of convolutional layers:

- Conv1D

- Conv2D

- Conv3D

From the names of the objects representing convolutional layers, it can be inferred that they are intended for processing input data of various dimensions.

The Conv1D class objects create the core of the convolution that collapses with the original data in one dimension to create an output tensor. It is important to understand and not to get confused. The initial data is convoluted in one dimension, but the initial data supplied to the neural layer input must be in the form of a three-dimensional tensor. The first dimension determines the size of the package of the data (batch size) being processed. The second is measuring convolution. The third dimension contains the initial data for convolution.

As a result of data processing, the layer also returns a 3D tensor. The first dimension remains the same; it is equal to the size of the data package being processed. The second dimension varies depending on the specified convolution parameters. The third dimension will be equal to the specified number of filters used.

It should be understood that each filter applies to all initial data. At one time, the initial data is processed in the size of the third dimension multiplied by the size of the convolution window. This is a slight difference from our implementation of the convolutional layer in MQL5. There, we defined the convolution window as the number of elements, while here, the convolution window determines the number of elements in the second dimension of the three-dimensional tensor of input data.

One filter returns one value for each convolution window. Since the entire third dimension is involved in the convolution process, we get one element from each filter. As a result, the size of the third dimension of the output tensor changes by the number of filters used.

Like a fully connected layer, the convolutional layer class offers a fairly wide range of parameters for fine-tuning the operation. Let's take a look at them.

- filters — the number of filters used in the bundle.

- kernel_size — one-dimensional convolution window size.

- strides — the size of the convolution step.

- padding — one of the following values is allowed: "valid", "same" or "causal" (case-insensitive); "valid" means no indentation; "same" causes the input data to be evenly filled with zeros to obtain an output size equal to the input size; "causal" leads to the emergence of causal (extended) changes, for example, output [t] does not depend from input [t+1:]. It's useful when modeling temporal data, where the model must not violate the temporal order.

- data_format — one of the following values is allowed: channels_last or channels_first; determines which dimension of the input tensor contains data for convolution; the default is channels_last.

- dilation_rate — used for advanced convolution and determines the expansion rate.

- groups — the number of groups into which the input is divided along the channel axis; each group is collapsed separately using filters, and the output is a combination of all results along the channel axis.

- activation — activation function.

- use_bias — indicates whether to use a bias vector.

- kernel_initializer — sets a method for initializing the weight matrix.

- bias_initializer — sets the method for initializing the displacement vector.

- kernel_regularizer — indicates a method for regularizing the weight matrix.

- bias_regularizer — indicates a method for regularizing the displacement vector.

- activity_regularizer — indicates a method for regularizing results.

- kernel_constraint — specifies the restriction function for the weight matrix.

- bias_constraint — specifies the constraint function for the displacement vector.

For timeseries, it is usually suggested to use a one-dimensional Conv1D convolution. Convolution is carried out by time intervals. At the same time, each filter checks for its own pattern in a specific time interval. In relation to solving our problem, filters will assess the status of all indicators used within the number of candles specified by the strides parameter. The process of convolution, like the neurons of a fully connected layer, does not assess the mutual influence of individual components of the initial data. It only assesses the similarity of the initial data with a given pattern. Of course, we don't explicitly define these patterns when constructing the neural network. We select them during the training process. However, it is assumed that during practical application, these patterns will remain static between retraining periods.

True, convolutional layers are more resistant to various distortions of the initial data due to the fact that small individual blocks are studied meticulously. However, it may be necessary to study the patterns of individual indicators. To solve this problem, we may need to use convolutional layers of a different dimension.

For example, Conv2D objects operate with convolutions with input data in two dimensions. At the same time, it should be understood that the difference between one-dimensional and two-dimensional convolutional layers goes beyond just their names. Objects in a two-dimensional convolutional layer expect a four-dimensional tensor at the input. By analogy with the Conv1D tensor, the first dimension determines the batch size, the second and third dimensions determine the convolution dimensions and the fourth dimension contains the initial data for convolution. Here arises a valid question: where do we obtain the data for another dimension? How do we divide our initial data set into four dimensions? We need to translate our raw data from a flat table to a voluminous table. The simplest solution is on the surface. We say that the depth of the table of the initial data is 1. Before declaring the two-dimensional neural layer, let's change the dimensionality of the tensor input to the Conv2D convolutional layer to a four-dimensional one by specifying a size of 1 for the fourth dimension.

Note that since the fourth dimension is 1, the length of the input data vector for convolution is 1. Therefore, for the convolution process to be effective, the convolution window needs to be greater than 1 in at least one dimension.

We will not dwell too much on the parameters of the Conv2D convolutional layer, since they are identical to the parameters of a one-dimensional array. The only differences are in the kernel_size, strides and dilation_rate parameters, which, in addition to a scalar value, can take a vector of two elements. Each element of such a vector contains parameter values for the corresponding dimension. At the same time, these parameters can take scalar values. In this case, the specified value will be used for both dimensions.

For more complex architectural solutions for neural networks, it may be necessary to use Conv3D 3D convolutional layers. Their usage can be justified, for example, in building arbitrage trading systems, where a separate dimension might be needed to segregate input data by instruments.

Just like in the case of a two-dimensional convolutional layer, using three-dimensional space requires increasing the dimensionality of the input data. A five-dimensional tensor is expected at the Conv3D input.

The parameters of the Conv3D class, however, are inherited from the aforementioned classes with minimal changes. The only difference is in the size of the vectors of the convolution window and its pitch.

Attention should be paid to another feature of the convolution process. When performing operations, it is possible to both reduce the size of the data tensor (data compression) and increase it. The first approach is useful when dealing with large datasets, where it's necessary to extract a specific component from the overall volume of input information. This is frequently employed in computer vision tasks, where in high-resolution images, each pixel represents an individual value within the overall tensor of input data.

The second approach, increasing the dimensionality, can be beneficial when there's an insufficient amount of input data. In such cases, a small volume of input data needs to be split into separate components while searching for non-obvious dependencies.

It should be noted that this is not a complete list of convolutional layers offered by the Keras library. But it is beyond the scope of this book to describe all the library's features. You can always check them out on the library [website](https://www.tensorflow.org/api_docs/python/tf/keras/layers). There you can also find the latest version of the library and instructions for installing and using it.

Just like convolutional layers, the Keras library offers several class options for a pooling layer. Among them are:

- AvgPool1D — one-dimensional data averaging.

- AvgPool2D — two-dimensional data averaging.

- AvgPool3D — three-dimensional data averaging.

- MaxPool1D — one-dimensional extraction of the maximum value.

- MaxPool2D — two-dimensional extraction of the maximum value.

- MaxPool3D — three-dimensional extraction of the maximum value.

All of these pooling layers have the same set of parameters:

- pool_size — an integer number or vector of integers, determines the window size.

- strides — an integer number or vector of integers, determines the window pitch.

- padding — means one of the following values is allowed: "valid", "same" or "causal" (case-insensitive); "valid" means no indentation; "same" — causes the source data to be evenly filled with zeros to obtain an output size equal to the input size.

- data_format — one of the following values is allowed: "channels_last" or "channels_first"; determines which dimension of the input tensor contains data for convolution; the default is "channels_last".

We will also implement convolutional neural network models in our [template](https://www.mql5.com/en/neurobook/index/realization/py_struct). Just like when testing perceptron models, we will create three neural network models with different architectures and compare the results of their training. Therefore, for implementation, we will take the previously created file [perceptron.py](https://www.mql5.com/en/neurobook/index/realization/pr_py) and create a copy of it called convolution.py. In this created file, we will replace the model declaration blocks.

First, we will create a perceptron with three hidden layers and weight matrix regularization. It will serve as a basis for comparing the performance of convolutional neural networks to the results of training a fully connected perceptron.

```
# Create a perceptron model with three hidden layers and regularization

model1 = keras.Sequential([keras.Input(shape=inputs),

                           keras.layers.Dense(40, activation=tf.nn.swish,

                   kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(40, activation=tf.nn.swish,

                   kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(40, activation=tf.nn.swish,

                   kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(targerts, activation=tf.nn.tanh)

                         ])
```

This model has 9802 parameters. The screenshot below shows the structure of the neural network we created. In the first column of the table, the name and type of the neural layer are indicated, while in the second column, the tensor dimensionality of the results for each layer is specified. Note that the first dimension is not set; None is specified instead of the size. This means that this dimension is not strictly defined and can be of variable length. This dimension is set by the batch size of the data patch. The third column shows the number of parameters in the weight matrix for each layer.

In the second model, we will insert a one-dimensional Conv1D convolution layer with 8 filters immediately after the initial data, and specify the convolution window and step as 1. Such a layer will roll up all specified indicators within a single candlestick. In doing so, let's not forget to change the dimensionality of the input data tensor from two-dimensional to three-dimensional.

Note that although we're transferring data to a 3D tensor, we specify two dimensions in the Reshape layer parameters. This is due to the fact that the first dimension of the tensor is variable and is set by the batch size of the input data batch.

Perceptron structure

And one more thing. The dimensional vector passed in the parameters of the Reshape class contains −1 in the first dimension. This tells the class to independently calculate the size of this dimension based on the size of the original data tensor and the specified dimensions of other dimensions.

```
# Add a 1D convolutional layer to the model

model2 = keras.Sequential([keras.Input(shape=inputs),

                           # Reformat the tensor into three-dimensional.

    # We indicate 2 dimensions, because The 3rd dimension is determined by the packet size

                           keras.layers.Reshape((-1,4)),

                           # Convolutional layer with 8 filters

                           keras.layers.Conv1D(8,1,1,activation=tf.nn.swish,

             kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),
```

Behind the convolutional layer, we will place a one-dimensional subsample layer with a choice of the maximum MaxPool1D value. As mentioned above, the convolutional layer operates with three-dimensional tensors. At the same time, the subsequent fully connected layers work with two-dimensional tensors. Therefore, for the proper functioning of fully connected layers, we need to return the data to a two-dimensional dimensionality. To do this, we will use the neural layer of the Flatten class.

```
# Pooling layer

                           keras.layers.MaxPooling1D(2,strides=1),

                  # Reformat the tensor into a two-dimensional one for fully connected layers

                           keras.layers.Flatten(),

                           keras.layers.Dense(40, activation=tf.nn.swish,

               kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(40, activation=tf.nn.swish,

               kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(40, activation=tf.nn.swish,

               kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(targerts, activation=tf.nn.tanh)

                         ])
```

Note: In the initial data, each candlestick is described by four values. The use of eight filters increases the dimensionality of the processed tensor. As a result, the model with a one-dimensional convolutional layer already contains 15,922 parameters.

In the third model, we will replace a 1 one-dimensional convolution layer with a two-dimensional one. As a result, we will change the pooling layer and the data dimension. As mentioned above, we will set the fourth dimension to 1. We can now control the size of the convolution window in two dimensions: time and indicator. Since we would like to assess different patterns in the readings of each individual indicator, we will specify the size of the convolution window in the first temporal dimension as 3 (evaluating patterns from 3 consecutive candlesticks), and the size of the window in the second dimension of indicators as 1. This will allow us to identify patterns in the movement of each indicator separately. The pitch of the convolution window in both directions will be set to 1.

Neural network structure with a one-dimensional convolutional layer

With these parameters, the first dimension (time dimension) will decrease by two elements as a result of the convolution operations. The second dimension (dimension of indicators) will remain unchanged since the convolution window and its pitch in this dimension are 1. At the same time, we will increase the third dimension, and it will become equal to the number of filters. Let me remind you that before the convolution operation, the third dimension was equal to 1. As a result of all iterations, the number of network parameters increased to 50,794. The structure of the new neural network is presented below. As you can see, the convolution layer has only 32 parameters. Such an increase in the number of network parameters is due to the enlargement of the tensor size after the convolution operation for the reasons mentioned above. This can be seen from the number of parameters in the first fully connected layer after convolution.

```
# Replace the convolutional layer in the model with a two-dimensional one

model3 = keras.Sequential([keras.Input(shape=inputs),

                           # Reformat the tensor into a four-dimensional one.

         #We indicate 3 dimensions, because... The 4th dimension is determined by the packet size

                           keras.layers.Reshape((-1,4,1)),

                           # Convolutional layer with 8 filters

                           keras.layers.Conv2D(8,(3,1),1,activation=tf.nn.swish,

                 kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           # Pooling layer

                           keras.layers.MaxPooling2D((2,1),strides=1),

                    # Reformat the tensor into a two-dimensional one for fully connected layers

                           keras.layers.Flatten(),

                           keras.layers.Dense(40, activation=tf.nn.swish,

                 kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(40, activation=tf.nn.swish,

                 kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(40, activation=tf.nn.swish,

                 kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(targerts, activation=tf.nn.tanh)

                         ])
```

Neural network structure with a two-dimensional convolutional layer

The rest of our script will remain unchanged. We will learn more about the script results in the next section.

## Practical testing of convolutional models

Look at the amount of work we have already completed. This is something to be proud of. We have implemented three types of neural layers, which already allow us to solve some practical problems. Using those, we can create fully connected perceptrons of different complexity. Or we can create convolutional neural network models and compare the performance of the two models on the same set of source data.

Before assessing the practical capabilities of different neural network models, you should verify the correctness of the methods for error gradient propagation through the convolutional neural network. We have already performed such a procedure for fully connected neural layers in the section [Checking the correctness of the gradient distribution](https://www.mql5.com/en/neurobook/index/realization/check_gradient).

Let me remind you of the essence of the procedure. The error gradient is a number that determines the slope of the tangent line to the function graph at the current point. It demonstrates how the value of a function will change when the parameter changes.

In geometry terms, the gradient is the slope of the tangent to the graph of the function at the current point

Of course, we are dealing with non-linear functions, and analytically computed error gradients provide only an approximate value. But when using a sufficiently small parameter change step, such an error becomes minimal.

Moreover, we can always determine how the function value changes when we experimentally alter a single parameter: we can take our function, change only one parameter, and calculate the new value. The difference between the two values of the function will show the influence of the analyzed parameter on the overall result at the current point.

Certainly, as the number of parameters increases, so do the costs of evaluating the influence of each parameter on the overall result. Therefore, neglecting a small error, everyone uses the analytical method to determine the error gradient. At the same time, by using the experimental method, we can assess the accuracy of our implemented analytical algorithm and adjust its operation if necessary.

When comparing the results of analytical and experimental methods for determining the error gradients, one point should be taken into account. To draw a straight line in a plane, two points are required. But if we draw a straight line through the current and new point, then such a straight line will not be tangent to the graph of the function at the current point. Most likely it will be tangent at some point between the current and future position. Therefore, to construct a tangent to the graph of a function at the current point, you will need to increase and decrease the current value of the indicator by the same small amount and calculate the function's value at both points. Then the line will touch the function at the point we need, and the effect of the parameter on the value of the function will be its average between two deviations.

When analyzing error gradient deviations between methods in a fully connected layer, we created the script [check_gradient_percp.mq5](https://www.mql5.com/en/neurobook/index/realization/check_gradient). Let's make a copy of the script named check_gradient_conv.mq5. In the resulting copy, we will only change the CreateNet function. In it, after the input data layer, we will add one convolutional layer and one pooling layer.

```
bool CreateNet(CNet &net)

  {

   CArrayObj *layers = new CArrayObj();

   if(!layers)

     {

      PrintFormat("Error creating CArrayObj: %d", GetLastError());

      return false;

     }

//--- The layer of source data

   CLayerDescription *descr = new CLayerDescription();

   if(!descr)

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      delete layers;

      return false;

     }

   descr.type = defNeuronBase;

   int prev_count = descr.count = BarsToLine;

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

The convolutional layer will consist of two filters. The size of the convolution window is equal to two, its step is set to one. The activation function is Swish. The optimization method doesn't matter, as at this stage we won't be training the neural network. The size of one filter is recalculated based on the size of the previous layer and the convolution parameters.

```
//--- Convolutional layer

   descr = new CLayerDescription();

   if(!descr)

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      delete layers;

      return false;

     }

   descr.type = defNeuronConv;

   int m_iWindow = descr.window = 2;

   int prev_wind_out = descr.window_out = 2;

   int m_iStep = descr.step = 1;

   prev_count=descr.count=(prev_count-descr.window+2*descr.step-1)/descr.step;

   descr.activation = AF_SWISH;

   descr.optimization = Adam;

   descr.activation_params[0] = 1;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete layers;

      delete descr;

      return false;

     }
```

After the convolutional neural layer, we place the pooling layer. For it, we will specify the windows equal to two and the step of one. We will specify the activation function AF_AVERAGE_POOLING, which corresponds to the calculation of the average value for each source data window.

```
//--- Pooling layer

   descr = new CLayerDescription();

   if(!descr)

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      delete layers;

      return false;

     }

   descr.type = defNeuronProof;

   descr.window = 2;

   descr.window_out = prev_wind_out;

   descr.step = 1;

   descr.count = (prev_count - descr.window + 2 * descr.step - 1) / descr.step;

   descr.activation = (ENUM_ACTIVATION_FUNCTION)AF_AVERAGE_POOLING;

   descr.optimization = None;

   descr.activation_params[0] = 1;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete layers;

      delete descr;

      return false;

     }
```

Further, the script code remains unchanged.

We launch the prepared script in two modes: using OpenCL technology and without it. As a result of testing, we obtained quite decent results. In both cases, we received deviations in the 11th decimal place.

The results of checking deviations of the error gradient between the analytical and experimental methods of determination

Now that we are confident in the correctness of our neural layer classes, we can proceed to the construction and training of convolutional neural networks. First, we need to decide how we want to use convolution.

In our dataset, each candlestick is represented by several indicators. In particular, when creating a [training sample](https://www.mql5.com/en/neurobook/index/realization/create_data) for each candlestick, we identified four indicators:

- RSI

- MACD histogram

- MACD signal line

- Deviation between the signal line and MACD histogram

Each of you can conduct a series of tests yourselves and determine your approach to using convolutional models. To me, the most obvious are two use cases.

- We can use convolution to determine certain patterns from indicator values at the level of each candlestick. In this version, we define the number of patterns to be searched for as the number of convolution filters. At the output of the convolutional layer, we get the degree of similarity of each candlestick with the desired patterns.

- It should be remembered that a fully connected neural layer is a linear function. Only the activation feature adds non-linearity. Therefore, in general, neurons do not evaluate dependencies between elements of the source data, but instead learn to recognize patterns from the set of source data. Hence, each neuron evaluates the current pattern independently of past data.

But when analyzing time series, sometimes the dynamics of the change in an indicator is more important than its absolute value. We can use convolution to determine patterns in the dynamics of indicators. To do this, we need to slightly rearrange the indicators, lining up the values ​​​​of each indicator in a row. For example, we can start by arranging all the RSI indicator values in the source data buffer. Then, we can place all the elements of the MACD histogram sequence, followed by the data of the signal line. We will complete the buffer with deviation data between the signal line and the MACD histogram. Of course, it would be more visual to arrange the data in a tabular form, where each row would represent the values of a separate indicator. But, unfortunately, only one-dimensional buffers are used in the OpenCL context. Therefore, we will use virtual partitioning of the buffer into blocks.

After arranging each indicator into a separate row, we can use convolution to identify patterns in sequential values of a single indicator. By doing so, we are essentially identifying trends within the analyzed data window. The number of convolutional layer filters will determine the number of trends to be recognized by the model.

#### Testing convolution within a single candlestick

To test the operation of convolutional neural network models, let's create a copy of the perceptron_test.mq5 script [perceptron_test.mq5](https://www.mql5.com/en/neurobook/index/realization/realizations_comparison) with the name convolution_test.mq5. At the beginning of the script, as before, we specify the parameters for script operation.

As with checking the correctness of the gradient distribution, we only need to change the function for describing the architecture of the CreateLayersDesc model. In it, after the layer of initial data, we add convolutional and pooling neural layers.

```
bool CreateLayersDesc(CArrayObj &layers)

  {

   CLayerDescription *descr;

//--- create source data layer

   if(!(descr = new CLayerDescription()))

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

Please note that for the convolutional layer, in the count field of the layer description object, we indicate not the total number of neurons, but the number of elements in one filter. In the window_out field, we will specify the number of filters to use. In the window and step fields, we will specify the number of elements per bar. With these parameters, we will obtain non-overlapping convolution, and each filter will compare the state of indicators at each bar with a certain pattern. The activation function is set to Swish, and the optimization method is set to Adam. We will use this optimization method for all subsequent layers. Except, of course, the pooling, which does not contain a weight matrix.

```
//--- Convolutional layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }

   descr.type = defNeuronConv;

   descr.count = BarsToLine;

   descr.window = NeuronsToBar;

   descr.window_out = 8;

   descr.step = NeuronsToBar;

   descr.activation = AF_SWISH;

   descr.optimization = Adam;

   descr.activation_params[0] = 1;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }
```

The convolutional layer is followed by the pooling layer. In this implementation, I used Max Pooling, i.e., selecting the maximum element within the input window. We are using a sliding window of two elements with a step of one element. With this set of parameters, the number of elements in one filter will decrease by one. We do not use the activation function for this layer. The number of filters is equal to the same parameter of the previous layer.

```
//--- Sub-sample layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }

   descr.type = defNeuronProof;

   descr.count = BarsToLine - 1;

   descr.window = 2;

   descr.window_out = 8;

   descr.step = 1;

   descr.activation = (ENUM_ACTIVATION_FUNCTION)AF_MAX_POOLING;

   descr.optimization = None;

   descr.activation_params[0] = 0;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }
```

Next comes an array of hidden fully connected layers. We will create them in a loop with the same parameters. The number of hidden layers to be created is specified in the script parameters. All hidden layers will have the same number of elements, which is specified in the script parameters. We will use the activation function Swish, and the weight matrix parameter optimization method, Adam, as we did for the convolutional layer.

```
//--- Block of hidden fully connected layers

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

At the end of the neural network initialization function, we will specify the parameters of the output layer. It will, just like in the previously created perceptron models, contain two elements with a linear activation function. We will use the Adam optimization method which is used by all other neural layers.

```
//--- Results Layer

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

The rest of the script code remains unchanged.

According to the testing results, the convolutional neural network model exhibited a less smooth graph. On it, we observe a wave-like decrease in the value of the error function. But at the same time, after 1000 iterations of updating the weight matrix, we got a lower value of the loss function.

A comparative graph of the training progress of the perceptron and the convolutional neural network.

As the scale increases, we can also notice a tendency for the value of the loss function to potentially decrease with continued learning.

A comparative graph of the training progress of the perceptron and the convolutional neural network.

 

#### Testing of sliding window convolution by indicator values

Testing convolution with a sliding window on indicator values To experiment with finding patterns in the dynamics of indicator values, we need to make some modifications to the previously created script convolution_test.mq5. Let's create its copy with the name convolution_test2.mq5. We will make the first changes to the declaration of the convolutional layer. This time, we are creating a layer with a convolution window of three elements and a step of one element. With these parameters, the number of elements in one filter will be two less than the previous layer, but the total number of elements in the output buffer will increase by a factor equal to the number of filters used. The activation function and the optimization method remain unchanged.

```
//--- Convolutional layer

   int prev_count = descr.count;

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }

   descr.type = defNeuronConv;
```

In the pooling layer, the changes affected only the number of elements in one filter.

```
//--- Pooling layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }

   descr.type = defNeuronProof;

   descr.count = prev_count - 1;

   descr.window = 2;

   descr.window_out = 8;

   descr.step = 1;

   descr.activation = (ENUM_ACTIVATION_FUNCTION)AF_MAX_POOLING;

   descr.optimization = None;

   descr.activation_params[0] = 0;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }
```

As mentioned before, for this test, we need to modify the sequence of source data being fed into the neural network. Therefore, we needed to make changes to the function of loading the training sample from the LoadTrainingData file.

As before, at the beginning of the function, we perform preparatory work. We declare instances of the necessary local objects and open the training dataset file for reading. The file name and path are specified in the function parameters. Let me remind you that the file with the training sample must be located within the sandbox of your terminal.

The result of the file opening procedure is checked by the received handle.

```
bool LoadTrainingData(string path, CArrayObj &data, CArrayObj &result)

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

//--- display the progress of training data loading in the chart comment

   uint next_comment_time = 0;

   uint OutputTimeout = 250; // no more than once in 250 milliseconds
```

After successfully opening the training sample file for reading, we start the loop of direct data loading. We will repeat the loop iterations until the file is finished. During each iteration, we will check if a command to close the program has been received before proceeding.

Inside the loop body, we will first prepare new instances of objects for loading patterns and target results.

```
//--- organize the loop to load training sample

   while(!FileIsEnding(handle) && !IsStopped())

     {

      if(!(pattern = new CBufferType()))

        {

         PrintFormat("Error creating Pattern data array: %d", GetLastError());

         return false;

        }

      if(!pattern.BufferInit(NeuronsToBar, BarsToLine))

        {

         delete pattern;

         return false;

        }

      if(!(target = new CBufferType()))

        {

         PrintFormat("Error creating Pattern Target array: %d", GetLastError());

         delete pattern;

         return false;

        }

      if(!target.BufferInit(1, 2))

        {

         delete pattern;

         delete target;

         return false;

        }
```

We still use dynamic arrays to load data:

- data: array of source data patterns

- result: an array of patterns of target values for each pattern

- pattern: a buffer of elements of one pattern

- target: a buffer of target values of one pattern

However, to change the sequence of loaded data, we will first adjust the size of the pattern buffer matrix so that the first columns of the matrix correspond to the number of used indicators, and the rows correspond to the number of analyzed historical bars.

We create a system of nested loops. The outer loop has the number of iterations equal to the number of analyzed candles. The number of iterations in the inner loop is equal to the number of elements per candlestick. In the body of this looping system, we will write the initial data to the buffer matrix pattern. Since the data in the training sample file is in chronological order, we will write them in the same order. But as we read, we will distribute the information in the corresponding rows and columns of the matrix.

```
for(int i = 0; i < BarsToLine; i++)

         for(int y = 0; y < NeuronsToBar; y++)

            pattern.m_mMatrix[y, i] = (TYPE)FileReadNumber(handle);
```

After completing the iterations of the loop system, we only need to reformat the resulting matrix.

```
if(!pattern.Reshape(1, BarsToLine * NeuronsToBar))

        {

         delete pattern;

         delete target;

         return false;

        }
```

The further process of loading the training sample has been moved without changes.

```
for(int i = 0; i < 2; i++)

         target.m_mMatrix[0, i] = (TYPE)FileReadNumber(handle);

      if(!data.Add(pattern))

        {

         PrintFormat("Error adding study data to array: %d", GetLastError());

         delete pattern;

         delete target;

         return false;

        }

      if(!result.Add(target))

        {

         PrintFormat("Error adding study data to array: %d", GetLastError());

         delete target;

         return false;

        }

      //--- display loading progress in a comment on the chart (no more than 1 time in 250 milliseconds)

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

As a result of training, such a neural network demonstrated an even greater amplitude of waves in the dynamics of loss function values. During the learning process, the amplitude of the waves was reduced. Such behavior could indicate the use of an elevated learning rate, the effect of which was mitigated by the Adam training method. I'd like to remind you that this training method utilizes an algorithm of individualized adaptation of the learning rate for each element of the weight matrix.

Comparative training graph of a perceptron and two convolutional neural network models

But back to the results of our test. Unfortunately, in this case, our model changes did not produce the desired reduction in model error. On the contrary, it has even increased. Nevertheless, there is hope for improved results when the learning rate is reduced.

Increasing the scale of the graph confirms the above conclusions.

Comparative training graph of a perceptron and two convolutional neural network models

#### Combined model

We have examined the performance of two convolutional neural network models. In the first model, we carried out the convolution of indicator values within one candlestick. In the second model, we transposed (flipped) the original data and conducted a convolution in terms of indicator values. At the same time, in the first case, we carried out convolution of all indicators at once within one bar. I'd like to remind you that for each bar, we take four values from two indicators. In the second model, we used a convolution with a sliding window of three bars and a convolution window step of one bar. And here arises an obvious question: what results can be achieved if we combine both approaches? One more experiment will give us the answer to this question.

To conduct this test, we need to build another model. In practice, the creation of such a model did not take me much time. Let's discuss. In the first case, we took indicator values for each candlestick, while in the second case, we used three consecutive values (three consecutive bars) of each individual indicator. If we want to combine two approaches, then it would probably be logical to take all the values for three consecutive bars for convolution. In both approaches, we used a step of one bar. Therefore, we will keep this step.

To build such a model, we do not need to transpose the data. Therefore, we will build a new model based on the convolution_test.mq5 script. First, we will create a copy of it called convolution_test3.mq5. In it, we will change the parameters of the convolutional layer. In the training sample, the data is in chronological order, so the convolution window of the full three bars will be equal to 3 * NeuronsToBar. Then the step of the convolution window with the size of one bar will be equal to NeuronsToBar. With these parameters, the number of elements in one filter will be BarsToLine - 2. We leave the activation function and the parameter optimization method unchanged.

```
//--- Convolutional layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }

   descr.type = defNeuronConv;

   descr.count = BarsToLine - 2;

   descr.window = 3 * NeuronsToBar;

   descr.window_out = 8;

   descr.step = NeuronsToBar;

   descr.activation = AF_SWISH;

   descr.optimization = Adam;

   descr.activation_params[0] = 1;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }
```

The changes made to the parameters of the convolutional layer required a slight adjustment of the parameters of the pooling layer. Here we have only made changes to the number of elements in one filter.

```
//--- Pooling layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }

   descr.type = defNeuronProof;

   descr.count = BarsToLine - 3;

   descr.window = 2;

   descr.window_out = 8;

   descr.step = 1;

   descr.activation = (ENUM_ACTIVATION_FUNCTION)AF_MAX_POOLING;

   descr.optimization = None;

   descr.activation_params[0] = 0;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }
```

The rest of the script code remains unchanged.

The training results of the new model turned out to be better than all the previous ones. The graph of loss function dynamics without amplitude waves lies slightly below the graphs of all previously conducted tests.

Comparative training graph of a perceptron and three models of convolutional neural networks

Increasing the scale of the graph confirms the above conclusions.

Comparative training graph of a perceptron and three models of convolutional neural networks

#### Testing Python models

In the previous section, we created a script with three neural network models in Python. The first perceptron model has three hidden layers, the second one has an additional Conv1D convolutional neural layer before the perceptron model, and in the third model, the Conv1D convolutional layer is replaced with Conv2D. At the same time, the number of parameters increased in each subsequent model. Based on the logic of our work, the models we created in Python should replicate the experiments conducted earlier with the neural network models built using MQL5. Therefore, the test results were fully expected and fully confirmed the earlier conclusions. For us, this is an additional confirmation of the correct operation of our library written in the MQL5 language. So, we can use it in our future work. Moreover, obtaining similar results when testing models that were entirely created using different tools eliminates the randomness of the results and minimizes the likelihood of making errors in the model creation process.

Let's get back to the test results. During the training process, the model with the Conv2D convolution layer showed the best results in reducing the error, which fully confirms the results obtained above. A significant gap between the error dynamics graphs of the training and validation sets in the case of the perceptron could indicate the underfitting of the neural network.

Comparative training graph of a perceptron and 2 models of convolutional neural networks (Python)

The error dynamics of the convolutional models are very close to each other. Their graphs are almost parallel. However, the model with the Conv2D convolutional layer shows less error throughout the training.

Comparative training graph of a perceptron and two convolutional neural network models (Python zoom)

On the validation set, the error graph of the Conv2D convolutional model first decreases, but after 100 epochs of training, there is an increase in the error. Along with a decrease in the error on the training set, this may indicate a tendency for models to overfit.

The graph of the Accuracy learning metric shows similar results.

Comparative training graph of a perceptron and two convolutional neural network models (Python)

On the validation set, the graphs of all three models are closely intertwined in the range of 0.71—0.73. The graph shows the intersection of the training and validation sample graphs after 400.

I would like to remind you that the validation dataset is significantly smaller than the training dataset; it consists of the last patterns without shuffling the overall dataset. Hence, there's a high likelihood that not all possible patterns will be included in the validation dataset. In addition, the validation set can be influenced by local trends.

Checking the performance of all three trained models on the test set showed quite similar, albeit slightly contradictory, results.

Testing the mean squared error of the models revealed that the convolutional model with the Conv2D convolution layer achieved the best results. This model analyzes patterns within a single indicator using a sliding window convolution. During training, it performed the best among the tested models. Certainly, the differences in the performance metrics are not very significant, and it can be considered that all models showed similar results.

Comparison of model errors on a test set

Comparison of the model accuracies on a test set

Comparison of the results by the Accuracy metric, in contrast to the just considered MSE graph, shows the best results for the Conv1D model. The model analyzes the patterns of each individual candlestick; the lowest result is for the perceptron. However, as with MSE, the gap between the results is small.

I suggest considering that all three models showed approximately equal results on the training dataset. The exact values of the metrics on the test sample are shown in the screenshot below.

The exact values ​​of model validation on the test set

#### Conclusions

According to the results of the tests, we can say:

- The models built using MQL5 during training demonstrate results similar to models built using the Keras library in Python. This fact confirms the correctness of the library we are creating. We can confidently continue our work.

- In general, convolutional models contribute to improving the performance of the model on the same training dataset.

- Approaches to convolution of the initial data may be different, and the results of the model may depend on the chosen approach.

- Combining different approaches within one model does not always improve the results of the model.

- Don't be afraid to experiment. When creating your own model, try different architectures and various data processing approaches.

In our tests, we used only one convolutional and one pooling layer. This can be referred to as an approach to building simple models. The most successful convolutional models used for practical tasks often employ multiple sets of convolutional and pooling layers. At the same time, the dimension of the convolution window and the number of filters change in each set. Like I said, don't be afraid to experiment. Only by comparing the performance of different models will you be able to choose the best architecture for solving your task.

## Comparative testing of recurrent models

Finally we have reached the testing phase of recurrent models. Previously, we have already tested various fully connected perceptron models and several convolutional models. You may notice that in both sections devoted to testing models, there is a certain sequence of actions, that is, a specific testing algorithm. In this section, we will follow this sequence.

As with the testing of previous models, we will start by checking the correctness of the gradient distribution through our recurrent layer built in MQL5. To do this, we will create the check_gradient_lstm.mq5 script based on previously created similar scripts for testing the correctness of the performance of previous models. Basically, we will make a copy of the script [check_gradient_conv.mq5](https://www.mql5.com/en/neurobook/index/main_layer_types/cnn/cnn_realizations_comparison) from the convolutional model testing section and make changes to match the new model.

The change we will make in the script is the block defining the model structure for testing. We will remove the convolutional and pooling layers from the model. Instead, our model will feature one recurrent layer.

```
//--- recurrent layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      delete layers;

      return false;

     }

   descr.type = defNeuronLSTM;

   descr.count = BarsToLine;

   descr.window_out = 2;

   descr.activation = AF_NONE;

   descr.optimization = Adam;

   descr.activation_params[0] = 1;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete layers;

      delete descr;

      return false;

     }
```

The rest of the neural network building block remains unchanged.

When testing other architectural solutions of neural layer configurations, the modifications to the script provided above in terms of defining the neural network structure would be sufficient for conducting the test. But the LSTM recurrent block has its own peculiarities. First, it lacks a weight matrix in the conventional sense. Instead, its functionality is assigned to the weight matrices of the inner layers. It will be a little more difficult to organize access to them, but I do not see the point in doing this. For inner layers, we utilize a previously validated fully connected layer class, the proper functioning of which we are confident in. Therefore, there is no need for us to retest the functioning of the already validated algorithm for gradient error distribution to the weight matrix. At the same time, we have a question about the correctness of the new functionality for the distribution of the error gradient inside the LSTM block. I believe that to answer this question, it is sufficient to verify the propagation of the error gradient back to the level of the original data (input of the neural network). Hence, we are removing the gradient error correctness checking block at the weight matrix level from the script.

The second feature of the recurrent layer is the use of its results as input for the new iteration, which is the desired feature. We wanted the neural network to consider not only the current state of the external environment but also its previous states, which we pass as hidden states to the new iteration. While this approach yields a positive impact on the neural network performance, it does distort the data for testing the correctness of gradient error distribution. The reason is that our entire algorithm for testing the correctness of gradient error distribution is built on the principle of changing only one tested parameter while keeping other values of the external environment constant. However, with a recurrent layer, even when all parameters of the input data remain constant, we can obtain a different result due to changes in the hidden state. To exclude this influence, we temporarily need to add a memory buffer and hidden state clearing within the forward pass method of our recurrent LSTM block class CNeuronLSTM::FeedForward.

```
bool CNeuronLSTM::FeedForward(CNeuronBase *prevLayer)

  {

//--- Check the relevance of all objects

    ....

//--- Prepare blanks for new memory and hidden state buffers

   CBufferDouble *memory = CreateBuffer(m_cMemorys);

   if(!memory)

      return false;

   CBufferDouble *hidden = CreateBuffer(m_cHiddenStates);

   if(!hidden)

     {

      delete memory;

      return false;

     }

//--- Gradient check only

   memory.BufferInit(m_cOutputs.Total(), 0);

   hidden.BufferInit(m_cOutputs.Total(), 0);

//--- The following is the code of the method without changes
```

Don't forget to remove or comment out these lines after running the gradient propagation test.

After making all the necessary adjustments, we will compile and initiate the test execution using the OpenCL multi-threaded computation technology and without it. The results obtained fully satisfy our requirements and we can continue testing the models further.

Correctness Test of Error Gradient Distribution via LSTM Block

We have obtained confirmations of the correctness of the algorithm we built for propagating gradient error through the recurrent LSTM block. Now we can proceed to the next stage of our tests. But once again, before starting work on conducting tests, we need to remove the above code for resetting memory buffers and hidden state from the code of the direct CNeuronLSTM::FeedForward method.

 

#### Script for testing recurrent models

Let's create the script lstm_test.mq5 to test train the recurrent model. This script is created following the template of scripts used for similar testing of previous models.

At the beginning of the script, we declare external parameters to control the process of creating and training the neural network model. Almost all external parameters migrated from the script for testing convolutional models without changes.

```
//+------------------------------------------------------------------+

//| External parameters for script operation                         |

//+------------------------------------------------------------------+

// Name of the file with the training sample

input string   StudyFileName = "study_data.csv";

// Name of file for recording the error dynamics

input string   OutputFileName = "loss_study_lstm.csv";

// Number of historical bars in one pattern

input int      BarsToLine     = 40;

// Number of input layer neurons per 1 bar

input int      NeuronsToBar   = 4;

// Use OpenCL

input bool     UseOpenCL      = false;

// Packet size for updating the weights matrix

input int      BatchSize      = 10000;

// Learning rate

input double   LearningRate   = 0.00003;

// Number of hidden layers

input int      HiddenLayers   =  3;

// Number of neurons in one hidden layer

input int      HiddenLayer    =  40;

// Number of cycles of updating the weights matrix

input int      Epochs         =  1000;
```

In the CreateLayersDesc model architecture description function, we insert one LSTM block between the source data layer and the block of hidden layers. The size of the result buffer for this recurrent block will be equal to the number of analyzed neural layers. The depth of the analyzed history will be set to five iterations. The architecture of the LSTM block defines the activation functions for all its components, and the block itself does not have a top-level activation function. Consequently, in the description of the block architecture, we will specify the absence of an activation function. We will use Adam as a method of parameter optimization.

```
//--- recurrent layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }

   descr.type = defNeuronLSTM;

   descr.count = BarsToLine;

   descr.window_out = 5;

   descr.activation = AF_NONE;

   descr.optimization = Adam;

   descr.activation_params[0] = 1;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }
```

The process of creating a recurrent neural network model can be considered completed, since the rest of the function code has remained unchanged.

At this stage of script execution, we already have a constructed recurrent neural network model and the training dataset loaded into memory. Now we can say that we are ready to train the model. And here we will have a slight departure from the previously used template. The reason is that for training the fully connected perceptron and the convolutional neural network, we used random patterns from the overall training dataset. At the same time, we've mentioned multiple times that recurrent neural networks require strict adherence to the chronological sequence of inputted raw data. Therefore, we have to make small changes to the training function of the NetworkFit model.

We need a strict sequence of patterns when training a model. Therefore, we remove the generation of a random pattern for each iteration. Instead, we will randomly determine the start of the next data batch from the training dataset.

```
bool NetworkFit(CNet &net, const CArrayObj &data, const CArrayObj &target,

                                                               VECTOR &loss_history)

  {

//--- training

   int patterns = data.Total();

//--- loop through the eras

   for(int epoch = 0; epoch < Epochs; epoch++)

     {

      ulong ticks = GetTickCount64();

      //--- train in batches

      //--- select a random pattern

      int k = (int)((double)(MathRand() * MathRand()) / MathPow(32767.0, 2) *

                                                                  (patterns - 10));

      k = fmax(k, 0);
```

But there is a nuance here as well. During the feed-forward pass, the recurrent block takes into account the results of previous iterations to the depth of the analyzed history. For the sake of data comparability, we should fill the buffer with sequential data before training the model. Therefore, we extend the loop of each batch before updating the parameters by the number of iterations required to fill the buffer with the depth of the analyzed history. In this case, we will not call the backpropagation method until the buffer is full.

```
for(int i = 0; (i < (BatchSize + 10) && (k + i) < patterns); i++)

        {

         //--- check to see if the training has stopped

         if(IsStopped())

           {

            Print("Network fitting stopped by user");

            return true;

           }

         if(!net.FeedForward(data.At(k + i)))

           {

            PrintFormat("Error in FeedForward: %d", GetLastError());

            return false;

           }

         if(i < 10)

            continue;

         if(!net.Backpropagation(target.At(k + i)))

           {

            PrintFormat("Error in Backpropagation: %d", GetLastError());

            return false;

           }

        }

      //--- reconfigure the network weights

      net.UpdateWeights(BatchSize);

      printf("Use OpenCL %s, epoch %d, time %.5f sec", (string)UseOpenCL, epoch,

                                               (GetTickCount64() - ticks) / 1000.0);

      //--- report on a bygone era

      TYPE loss = net.GetRecentAverageLoss();

      Comment(StringFormat("Epoch %d, error %.5f", epoch, loss));

      //--- remember the epoch error to save to file

      loss_history[epoch] = loss;

     }

   return true;

  }
```

The rest of the script code remained unchanged.

I hope that everything is clear with the algorithm and the principle of constructing the script, and we can proceed to the analysis of the results.

 

#### Testing the LSTM for the first time

First, I created a model similar to the convolutional models I tested: one recurrent layer, three hidden fully connected layers, and one fully connected layer to display the results.

Based on the test results, it can be observed that using a recurrent layer alongside a convolutional layer for data preprocessing significantly improves the performance quality of the fully connected perceptron.

Let me remind you that in the perceptron model we used three hidden fully connected layers and one fully connected results layer. In the convolutional network model, we employed one convolutional layer, one pooling layer, three hidden fully connected layers, and one fully connected layer for output results. In the recurrent neural network model, we utilized one recurrent LSTM block, three hidden fully connected layers, and one fully connected layer for output results.

Essentially, in the convolutional and recurrent models, we introduced a convolutional or recurrent block before the previously tested perceptron for data preprocessing. The type of block used depends on the model.

As a result, we see an improvement in neural performance due to an additional layer of preliminary data processing.

Testing a Recurrent Neural Network Model

Comparing the convolutional and recurrent models, it can be observed that the error graph of the recurrent model exhibits larger noisy fluctuations. This may be due to the peculiarities of model training. To train the convolutional model, we used patterns randomly selected from the entire training set. This approach provides the most representative sample for each gradient error accumulation batch before updating the weights. At the same time, for training the recurrent model, we took patterns in chronological order. Consequently, the updating of weights and the recording of the model average error were done at different time intervals. This could not have gone unnoticed in the results, as each local time interval is subject to its own local trends.

Testing a Recurrent Neural Network Model

Despite the large graph noise, the overall trend of the recursive model has a large tendency to reduce the error. True, throughout the training process, the model error value is slightly better for the convolutional model. But after 700 iterations of updating the weight matrix of the model, there is a noticeable trend towards a slowdown in the error reduction rate. This may indicate an approach to a minimum. At the same time, the recurrent model does not have such a trend. The recurrent model has a large number of parameters, and it takes more time to train. Potentially, it can improve the results in further training.

 

#### Second test of the LSTM mode

In the previous testing of the recurrent model, we used an LSTM layer to preprocess the initial data before a block of fully connected neural layers. But in practice, there is the possibility of using recurrent layers without additional preprocessing. To assess the impact of the fully connected layer block on the performance quality of the recurrent neural network, we conducted a second experiment using the same script. However, now we have specified 0 in the number of hidden layers parameter. Thus, we aim to compare the performance of two recurrent models and evaluate the necessity of using a block of fully connected neural layers for further data processing after the recurrent layer.

The test results show a very interesting trend. At the beginning of training, the recurrent model without hidden fully connected layers demonstrates a sharper drop in model error, surpassing all other models depicted on the graph. When you zoom in on the graph, you can see a clear advantage of the model without a block of hidden fully connected layers.

Testing a Recurrent Neural Network Model

Testing a Recurrent Neural Network Model

The results of the tests show the advantage of the operation of recurrent networks over the previously considered models. In this case, the use of recurrent layers yields results even without the additional processing of results by fully connected layers.

Here it must be noted that the evaluation of models was carried out only to solve a specific problem of working with time series. When solving other problems, it is possible to obtain absolutely opposite results. Therefore, when tackling your tasks, it is recommended to experiment with various architectural solutions for neural networks.

 

#### Results of testing recurrent models in Python

Earlier, we considered the implementation of a script with the construction of three recurrent models in Python. Now I propose to consider the results of test training of the constructed models.

The obtained testing results confirm the conclusions we made earlier based on the testing of models created using MQL5 tools. All three recurrent models are significantly superior to other models in terms of the quality of the neural network. In the graph depicting the change in error during the neural network training process, we can observe that the recurrent models already demonstrate lower error after 50 epochs of training compared to the fully connected perceptron and the convolutional model. With further training, superiority only grows. At the same time, one can also notice an increase in the error on the validation set, which indicates the tendency of the model to overfit.

Test training results for Python models

Test training results for Python models

Comparing the recurrent models with each other, you can see that the recurrent model in which the first recurrent layer returns values on each cycle is more prone to overfitting. It shows the smallest error of all models on the training set and the maximum error on the validation set. At the same time, the intersection of error curves on the testing and validation datasets for the mentioned model occurs around 130 epochs with an error value of approximately 0.385. The intersection of the graphs of the other two models is observed with an error level of about 0.395.

The graph of the dynamics of learning by the Accuracy metric fully confirms our conclusions made on the error graph.

On the test set, all trained models showed fairly close results. The deviation in both the root-mean-square error and the accuracy metric is minimal.

Testing Trained Python Models on a Test Set

While the picture is quite mixed in terms of MSE values, a clear superiority of the recurrent models is evident on the Accuracy metric graph.

Testing Trained Python Models on a Test Set

Based on the conducted tests, it can be concluded that when dealing with time series tasks, recurrent networks are capable of producing better results than the previously examined architectural solutions. At the same time, to solve such problems, we can consider various architectural solutions. Among these solutions, there could be neural networks consisting solely of recurrent layers, or mixed models that combine layers of different types.

Despite the fact that our Python language model test resulted in the victory of a recurrent model containing only recurrent neural layers, I recommend that when tackling your practical tasks, you always experiment with different models. Often, the best results come from the most unconventional architectural solutions.

## Description of architecture and implementation principles

Previously discussed types of neural networks operate with a predetermined volume of data. However, when working with price charts, it is difficult to determine the ideal size of the analyzed data. Different patterns may manifest over various time intervals, and these intervals are not always static, varying depending on the current market situation. Some events may be infrequent in the market but are likely to have a significant impact. Ideally, such an event should stay within the analyzed window. However, once it falls outside of it, the neural network no longer considers this event, even though the market may be reacting to it at that moment. Increasing the analyzed window leads to increased consumption of computational resources, requiring more time for training such a neural network. In practical real-world applications, more time will be needed for decision-making.

The use of recurrent neurons in neural networks has been proposed to address this issue in working with time series data. This involves attempting to implement short-term memory in neural networks, where the neuron input includes information about the current state of the system and its previous state. This approach is based on the assumption that the neuron output considers the influence of all factors, including its previous state, and passes all its knowledge to its future state on the next step. This is similar to human experience, where new actions are based on actions performed earlier. The duration of such memory and its impact on the current state of the neuron will depend on the weights.

Any architectural solution for neurons can be used here, including the fully connected and convolutional layers we discussed earlier. We simply concatenate two tensors: one for the input data and one for the results of the previous iteration, and feed the resulting tensor into the neural layer. At the beginning of the neural network operation, when there is no tensor of results from the previous iteration yet, the missing elements are filled with zeros.

Recurrent neuron pattern

Training recurrent neural networks is done using the well-known method of backpropagation of errors. Similar to convolutional neural network training, the temporal nature of the process is unfolded into a multilayer perceptron. In such a perceptron, each time segment plays the role of a hidden layer. However, all layers of this perceptron use a single matrix of weights. Therefore, to adjust the weights, we take the sum of the gradients for all layers and count the delta of the weights once for the sum of all gradient layers.

Training algorithm of recurrent neural network

Unfortunately, such a simple solution is not free from drawbacks. This approach saves "memory" for a short time. The cyclical multiplication of the signal by a coefficient less than one, combined with the application of the neuron activation function, leads to a gradual attenuation of the signal as the number of such cycles increases. To solve this problem, Sepp Hochreiter and Jürgen Schmidhuber proposed the use of the Long short-term memory [LSTM architecture in 1997](%E2%80%94https://www.bioinf.jku.at/publications/older/2604.pdf)). Today, the LTSM algorithm is considered one of the best for solving classification and time series prediction problems, where significant events are separated over time and stretched over time intervals.

LSTM can hardly be called a neuron. Rather, it is already a neural network with three input data channels and three output data channels. Out of them, only two channels are used for data exchange with the surrounding world (one for input and one for output). The other four channels are locked in pairs for looping (Memory for memory and Hidden state for hidden state).

Within the LSTM block, there are two main information threads that are interconnected by four fully connected neural layers. All neural layers contain the same number of neurons, which is equal to the size of the output thread and the memory thread. Let's take a closer look at the algorithm.

The Memory data thread serves to store and transmit important information over time. Initially, it is initialized with zero values and filled during the neural network operation. One can compare it to a living person who is born without knowledge and learns throughout life.

The Hidden state thread is designed to transmit the system output state over time. The size of the data channel is equal to the data channel of the memory.

The Input data and Output state channels are designed to exchange information with the outside world.

LSTM Module Diagram

Three threads of data enter the algorithm:

- Input data describes the current state of the system.

- Memory and Hidden state are obtained from the previous state.

At the beginning of the algorithm, information from Input data and Hidden state are combined into a single data set, which is then fed to all four latent LSTM neural layers.

The first neural layer, the Forget gate, determines which information stored in memory can be forgotten and which should be remembered. It is organized as a fully connected neural layer with a sigmoid activation function. The number of neurons in the layer corresponds to the number of memory cells in the Memory thread. Each neuron in the layer receives a total array of Input data and Hidden state data at the input and outputs a number between 0 (completely forget) and 1 (save in memory). The element-wise product of the output from the neural layer with memory flow returns the corrected memory.

where:

- σ = activation logistic function

- WFG = weights matrix for the input vector

- INPt = input vector for the current iteration

- UFG = hidden state weight matrix

- HSt-1 = hidden state vector from the previous iteration

In the next step, the algorithm determines which of the newly acquired information at this stage needs to be stored in memory. Two neural layers are used:

- New Content: a fully connected neural layer with hyperbolic tangent as an activation function normalizes the received information between −1 and 1.

- Input gate: a fully connected neural layer with a sigmoid as an activation function. It is similar to the Forget gate and determines what new information to remember.

The use of the hyperbolic tangent as an activation function for the neural layer of new content allows the separation of the received information into positive and negative. The element-wise work of New Content and Input gate determines the importance of the information received and the extent to which it needs to be stored in memory.

The vector of values obtained as a result of operations is element-wise added to the current memory vector. This results in an updated memory state, which is subsequently transmitted to the input of the next iteration cycle.

After updating the memory, we generate output thread values. To do this, normalize the current memory value using hyperbolic tangent. Similar to Forget gate and Input gate, lets compute Output gate (the output signal gate), which is also activated by the sigmoid function.

The element product of the two received data vectors gives an array of output that is produced from the LSTM to the outside world. The same data set will be passed to the next iteration cycle as a hidden state thread.

Since the introduction of the LSTM unit, there have appeared many different modifications to it. Some tried to make it "lighter" for faster information processing and training. Others, on the contrary, made it harder to try to get better results. The [GRU](https://arxiv.org/pdf/1406.1078v3.pdf) (Gated Recurrent Unit) model introduced by Kyunghyun Cho and his team in September 2014 is considered to be one of the most successful variations. This solution can be considered a simplified version of the standard LSTM unit. In it, the Forget gate and the Input gate are combined into a single update gate. This eliminates the use of a separate memory thread. Only the Hidden state is used to transmit information through time.

At the beginning of the GRU algorithm, as in LSTM, the refresh and reset gates are defined. The mathematical formula for calculating values is similar to the definition of the gate values in LSTM.

Then the current memory state is updated. In this process, the hidden state from the previous iteration is first multiplied by the corresponding weight matrix and then element-wise multiplied by the value of the reset gate. The resulting vector is added from the product of the raw data to its weight matrix. The total vector is activated by a hyperbolic tangent.

In conclusion of the algorithm, the hidden state from the previous iteration is element-wise multiplied by the value of the update gate, while the current memory state is multiplied by the difference between one and the value of the update gate. The sum of these products is passed as the output from the block and as the hidden state for the next iteration.

Thus, in the GRU model, the reset gate controls the rate of data forgetting. The update gate determines how much information to take from the previous state and how much of the new data.

## Building an LSTM block in MQL5

To implement in our library, among all the options for architectural solutions of recurrent neurons, I have chosen the classical LSTM block. In my opinion, the presence of filters for new information and memory content in the form of gates will help minimize the influence of the noisy component of the signal. And a separate memory channel will help retain information for a longer period.

As before, to create a new type of neural layer, we will create a new class CNeuronLSTM. To maintain inheritance, the new class will be created based on our CNeuronBase neural layer base class.

```
class CNeuronLSTM    :  public CNeuronBase

  {

public:

                     CNeuronLSTM(void);

                    ~CNeuronLSTM(void);

   //--- method of identifying the object

   virtual int       Type(void)               const { return(defNeuronLSTM); }

  };
```

Since we apply the inheritance mechanism, our new class immediately possesses the basic functionality that was previously implemented in the parent class. Now we need to refine this functionality for the correct operation of our recurrent block. First, let's rewrite the virtual identification method.

As you know from the description of the LSTM block architecture presented in the previous chapter, we will need four fully connected layers for its proper operation. We'll declare them in the protected block of our class. And to maintain code readability, we will name them in accordance with the functionality laid out in the algorithm.

```
class CNeuronLSTM    :  public CNeuronBase

  {

protected:

   CNeuronBase*       m_cForgetGate;

   CNeuronBase*       m_cInputGate;

   CNeuronBase*       m_cNewContent;

   CNeuronBase*       m_cOutputGate;
```

In addition to the created neural layers, the block algorithm uses memory streams and a hidden state. We will need separate buffers to store them. We will also need to use the chronology of internal neurons in our training. Therefore, to store such information, we will create dynamic arrays, which we will also declare in the protected block:

- m_cMemorys — memory state;

- m_cHiddenStates — hidden state;

- m_cInputs — concatenated array of raw data and hidden state;

- m_cForgetGateOuts — state of the forget gate;

- m_cInputGateOuts — state of the input gate;

- m_cNewContentOuts — new content;

- m_cOutputGateOuts — output gate state.

```
class CNeuronLSTM    :  public CNeuronBase

  {

protected:

   ....

   CArrayObj*       m_cMemorys;

   CArrayObj*       m_cHiddenStates;

   CArrayObj*       m_cInputs;

   CArrayObj*       m_cForgetGateOuts;

   CArrayObj*       m_cInputGateOuts;

   CArrayObj*       m_cNewContentOuts;

   CArrayObj*       m_cOutputGateOuts;
```

Of course, in the process of operating a neural network, we cannot indefinitely accumulate a history of states, because our resources are finite. Therefore, we will need some kind of reference for understanding the buffer filling. If the buffer overflows above this limit, we will remove the oldest data and replace it with new. The depth of history for training the recurrent block will serve as such a reference for us. This parameter will be user-defined and stored in the m_iDepth variable.

```
class CNeuronLSTM    :  public CNeuronBase

  {

protected:

   ....

   int               m_iDepth;
```

Continuing the discussion about declaring auxiliary variables for the class, there is another point to pay attention to. All four internal neural layers use the same input data which includes the concatenated tensor of the original data and the hidden state. The CalcHiddenGradient method of passing the gradient through the hidden layer of our base class is constructed so that it replaces the error gradient values in the buffer of the previous layer. However, we need to sum up the error gradient from all internal flows. Therefore, to accumulate the sum of the gradients, we will add another buffer m_cInputGradient.

```
class CNeuronLSTM    :  public CNeuronBase

  {

protected:

   ....

   CBufferDouble*       m_cInputGradient;
```

It seems we've sorted out the variables. Now let's start building the class methods. The first thing that the class starts with is the constructor CNeuronLSTM::CNeuronLSTM. In this method, we create instances of the objects used and set initial values for the internal variables.

```
CNeuronLSTM::CNeuronLSTM(void)   : m_iDepth(2)

  {

   m_cForgetGate = new CNeuronBase();

   m_cInputGate = new CNeuronBase();

   m_cNewContent = new CNeuronBase();

   m_cOutputGate = new CNeuronBase();

   m_cMemorys = new CArrayObj();

   m_cHiddenStates = new CArrayObj();

   m_cInputs = new CArrayObj();

   m_cForgetGateOuts = new CArrayObj();

   m_cInputGateOuts = new CArrayObj();

   m_cNewContentOuts = new CArrayObj();

   m_cOutputGateOuts = new CArrayObj();

   m_cInputGradient = new CBufferType();

  }
```

We immediately create the destructor of the class CNeuronLSTM::~CNeuronLSTM, in which the reverse operation takes place, that is, memory is released after the class has finished its work. Here it's important to ensure complete memory cleanup so that nothing is missed.

```
CNeuronLSTM::~CNeuronLSTM(void)

  {

   if(m_cForgetGate)

      delete m_cForgetGate;

   if(m_cInputGate)

      delete m_cInputGate;

   if(m_cNewContent)

      delete m_cNewContent;

   if(m_cOutputGate)

      delete m_cOutputGate;

   if(m_cMemorys)

      delete m_cMemorys;

   if(m_cHiddenStates)

      delete m_cHiddenStates;

   if(m_cInputs)

      delete m_cInputs;

   if(m_cForgetGateOuts)

      delete m_cForgetGateOuts;

   if(m_cInputGateOuts)

      delete m_cInputGateOuts;

   if(m_cNewContentOuts)

      delete m_cNewContentOuts;

   if(m_cOutputGateOuts)

      delete m_cOutputGateOuts;

   if(m_cInputGradient)

      delete m_cInputGradient;

  }
```

 

#### Object initialization

Next, let's take a look at the method of initializing an instance of the CNeuronLSTM::Init class. It is in this method that all internal objects and variables are created and initialized, as well as the necessary foundation for the normal operation of the neural layer is prepared in accordance with the user-defined requirements. We created a similar virtual method in our base class for neural layers and constantly override it in each of our new classes.

```
class CNeuronLSTM    :  public CNeuronBase

  {

protected:

   ....

public:

                     CNeuronLSTM(void);

                    ~CNeuronLSTM(void);

   //---

   virtual bool      Init(const CLayerDescription *desc) override;
```

As you know, a similar method of the base class receives the description of the neural layer being created as parameters. So, our method in the parameters will get a pointer to an instance of the CLayerDescription class. Therefore, at the beginning of the method, we perform a check for the validity of the received pointer and the parameters set in it. First of all, the type of neural layer it specifies must match our class. Also, our LSTM block cannot be used as an input layer and must contain at least one neuron at the output.

```
bool CNeuronLSTM::Init(const CLayerDescription *desc)

  {

//--- Control block

   if(!desc || desc.type != Type() || desc.count <= 0 || desc.window == 0)

      return false;
```

The use of the LSTM block as a source data layer is simply a waste of resources. We create a large number of additional objects that will never be used since we write the information directly into the output buffer in the input layer.

Next, we have to initialize our internal neural layers. To do this, we will call the sameInit method of our objects. Therefore, we need to pass them the corresponding instance of the CLayerDescription class. We can't simply pass the object describing the recurrent block received from the user, as we need to create other objects. So, first, we will prepare a description of the objects to be created:

- All internal neural layers are fully connected. Hence, we create base class objects. Therefore, we will specify the defNeuronBase type in the type parameter.

- All of them take as input a single tensor, which is a combination of the original data vector and the hidden state. We get the size of the source data vector in the method parameters (CLayerDescription.window parameter). The size of the hidden state vector is equal to the size of the output buffer of the current layer. We also get this value in method parameters (CLayerDescription.count parameter). The sum of the two values will be written in the window parameter.

- If you look carefully at the LSTM block diagram in the previous section, you will be able to see that all internal information flows have the same size. The forget gate output vector is element-wise multiplied by the memory flow. This means their sizes are equal. Similarly, the input gate result vector is elementally multiplied by the new content layer result. Then this product is element-wise summed with the memory flow. Finally, everything is atomically multiplied by the output control gate. It becomes clear that all flows are equal to the size of the output buffer of the current block. So, to the count parameter, we will move the value of a similar element from the external parameters of the method.

- The activation function is defined by the architecture of the LSTM block. All gates are activated by a sigmoid and the new content layer by a hyperbolic tangent. Along with the activation function, we will specify its corresponding parameters.

- We will transfer the optimization method specified by the user.

```
//--- create a description for the inner neural layers

   CLayerDescription *temp = new CLayerDescription();

   if(!temp)

      return false;

   temp.type = defNeuronBase;

   temp.window = desc.window + desc.count;

   temp.count = desc.count;

   temp.activation = AF_SIGMOID;

   temp.activation_params[0] = 1;

   temp.activation_params[1] = 0;

   temp.optimization = desc.optimization;
```

After preparing the description for the internal neural layers, we will return to our inheritance from the parent class. All the block parameters are hidden within the internal neural layers, so there is no need for us to keep an additional weight matrix in memory, nor the associated delta and momentum buffers. In addition, we do not plan to use the CActivation activation class object. Essentially, the functionality of the input layer from the base class is sufficient for us. To initialize the necessary objects and remove the excess ones, we will zero out the size of the input data in the description of the recurrent block and call the initialization method of the parent class.

```
//--- call the parent class initialization method

   CLayerDescription *temp2=new CLayerDescription();

   if(!temp2 || !temp2.Copy(desc))

     return false;

   temp2.window = 0;

   if(!CNeuronBase::Init(temp2))

      return false;

   delete temp2;
```

To obtain information from the user about the history depth for training the recurrent block, we will use the window_out element. We will save the received value in a specially prepared variable. We did not check this value at the beginning of the method in order not to block the operation of the neural network. Instead, we simply limited the lower bound of the stored value. Therefore, if the user forgets to specify a value or indicates an intentionally low value, the neural network will use the value that we have set.

```
if(!InsertBuffer(m_cHiddenStates, m_cOutputs, false))

      return false;

   m_iDepth = (int)fmax(desc.window_out, 2);
```

Next, we move on to initializing our gate. The forget gate will be initialized first. Before calling the gate object initialization method, we need to verify the validity of the pointer to the object. If necessary, we will create a new instance of the object. If the attempt to create a new instance of the object is unsuccessful, we exit the method with the false result. If there is an actual object instance, we initialize the gate.

```
//--- initialize ForgetGate

   if(!m_cForgetGate)

     {

      if(!(m_cForgetGate = new CNeuronBase()))

         return false;

     }

   if(!m_cForgetGate.Init(temp))

      return false;

   if(!InsertBuffer(m_cForgetGateOuts, m_cForgetGate.GetOutputs(), false))

      return false;
```

Similar iterations are performed for the other two gates.

```
//--- initialize InputGate

   if(!m_cInputGate)

     {

      if(!(m_cInputGate = new CNeuronBase()))

         return false;

     }

   if(!m_cInputGate.Init(temp))

      return false;

   if(!InsertBuffer(m_cInputGateOuts, m_cInputGate.GetOutputs(), false))

      return false;
```

```
//--- initialize OutputGate

   if(!m_cOutputGate)

     {

      if(!(m_cOutputGate = new CNeuronBase()))

         return false;

     }

   if(!m_cOutputGate.Init(temp))

      return false;

   if(!InsertBuffer(m_cOutputGateOuts, m_cOutputGate.GetOutputs(), false))

      return false;
```

The new content layer will be initialized in the same way. We will only preliminarily change the type of the activation function in the layer description.

```
//--- initialize NewContent

   if(!m_cNewContent)

     {

      if(!(m_cNewContent = new CNeuronBase()))

         return false;

     }

   temp.activation = AF_TANH;

   if(!m_cNewContent.Init(temp))

      return false;

   if(!InsertBuffer(m_cNewContentOuts, m_cNewContent.GetOutputs(), false))

      return false;
```

After initializing the internal layers, we will move on to the other objects of our LSTM recurrent block. We initialize the gradient accumulation buffer. As in the case of neural layers, we first verify the validity of the object pointer. If necessary, we create a new instance of the class. Then we fill the entire buffer with zero values. We take the buffer size from the previously prepared description of the internal neural layers.

```
//--- initialize the InputGradient buffer

   if(!m_cInputGradient)

     {

      if(!(m_cInputGradient = new CBufferType()))

         return false;

     }

   if(!m_cInputGradient.BufferInit(1, temp.window, 0))

      return false;

   delete temp;
```

It should be noted that after initializing the buffer for accumulating gradient values, we will no longer use the object describing the internal neural layers. Therefore, we can delete the unnecessary object.

In conclusion, all that remains is to create and fill with zero values the buffers for the memory flow and hidden state. Note that both buffers will be used on the first direct pass, and their absence will paralyze the entire neural network. A separate method CreateBuffer has been added to create these buffers, which we will consider later.

So, first, we create a memory buffer. We declare a temporary variable and call the CreateBuffer method. As a result of the method, we expect a pointer to the buffer object. Certainly, after obtaining a pointer, we check its validity. If an error occurs, we exit the method with the result of false.

Next, we check for the presence of existing objects in the memory stack. We are discussing the method of initializing a class instance, so we expect an empty stack to be present. If the stack, however, contains any information, we clear the stack and fill the created buffer with null values. After this, we place our buffer into the memory stack.

```
//--- initialize Memory

   CBufferType *buffer =  CreateBuffer(m_cMemorys);

   if(!buffer)

      return false;

   if(!InsertBuffer(m_cMemorys, buffer, false))

     {

      delete buffer;

      return false;

     }
```

As a result of executing this code block within the method, we expect to obtain a memory stack containing a single null memory buffer. Please note that at the end of the block execution, we do not delete the buffer object, even though the variable scope does not extend beyond this method. The reason is, we operate object pointers here. By putting a pointer on the stack, we can always get it from there. Conversely, if we delete the object pointed to by the variable pointer in the stack, we will also end up with a pointer to a deleted object, along with all the resulting consequences. The object will actually be deleted either upon stack overflow or when attempting to close the entire instance of the class.

Repeat all iterations for the hidden state buffer.

```
//--- initialize HiddenStates

   if(!(buffer =  CreateBuffer(m_cHiddenStates)))

      return false;

   if(!InsertBuffer(m_cHiddenStates, buffer, false))

     {

      delete buffer;

      return false;

     }
```

Lastly, we pass the current pointer to the OpenCL object to all internal objects and exit the method.

```
//---

   SetOpenCL(m_cOpenCL);

//---

   return true;

  }
```

We have considered the algorithm of the class initialization method. However, as you may have noticed, during the execution of the algorithm, we used two methods of the class: SetOpenCL and CreateBuffer. The first method exists in the parent class, but for proper functionality, we will need to override it. The second method is new.

The CreateBuffer method in the initialization method was used to create a new buffer. Looking a bit ahead, we will use it in a broader context. As you know from the architecture of the LSTM recursive block we are building, we will need to extract the last hidden state and memory vectors from the stack on each feed-forward pass. We will also transfer this functionality to the CreateBuffer method.

Since we anticipate the method working with multiple stacks, we will pass a pointer to a specific stack as a parameter to the method. The result of the method execution will be a pointer to the desired buffer. We declare the method in the protected block of our class.

```
class CNeuronLSTM    :  public CNeuronBase

  {

protected:

   ....

   CBufferDouble*     CreateBuffer(CArrayObj *&array);
```

At the beginning of the method body, as usual, we check the received stack pointer. However, in case we receive an invalid pointer, we don't rush to exit the method with an error message. Instead, we try to create a new stack. Only if we can't create a new stack, we exit the method.

Remember, the code that invokes the method expects to receive not just the logical state of the method execution but a pointer to the buffer. Therefore, in case of an error, we return NULL instead of the expected pointer.

```
CBufferType *CNeuronLSTM::CreateBuffer(CArrayObj *&array)

  {

   if(!array)

     {

      array = new CArrayObj();

      if(!array)

         return NULL;

     }
```

Next, we create a new buffer and immediately check the result.

```
CBufferType *buffer = new CBufferType();

   if(!buffer)

      return NULL;
```

After successfully creating the buffer, we split the algorithm into two threads. In one case when there are no buffers on the stack, we fill the buffer we created with zero values. If there is already information on the stack, we copy the latest states to the buffer. Then we return a pointer to the buffer of the calling program.

```
if(array.Total() <= 0)

     {

      if(!buffer.BufferInit(m_cOutputs.Rows(), m_cOutputs.Cols(), 0))

        {

         delete buffer;

         return NULL;

        }

     }
```

```
else

     {

      CBufferType *temp = array.At(0);

      if(!temp)

        {

         delete buffer;

         return NULL;

        }

      buffer.m_mMatrix = temp.m_mMatrix;

     }

//---

   if(m_cOpenCL)

     {

      if(!buffer.BufferCreate(m_cOpenCL))

         delete buffer;

     }

//---

   return buffer;

  }
```

Note that I'm referring to the latest data and, in doing so, I'm copying the buffer with index 0. This class implements reverse stack logic. For each new buffer, we will insert it at the beginning of the stack, pushing the older ones down, and when the stack is full, we will remove the last ones.

And second point: we don't take a pointer to an existing buffer, instead we create a new one. This is because we will change the contents of the buffer during the forward pass. In doing so, it's important for us to preserve the previous state. In the case of using a pointer to an old buffer, we will simply overwrite its values, effectively discarding the desired previous states.

The second method, SetOpenCL, is an overriding method of the parent class and has the same functionality of passing a pointer to the OpenCL context to all internal objects involved in the computation process. Similar to the method in the parent class, our method will receive a pointer to the OpenCL context as a parameter and will return a logical result indicating the readiness of the class to operate within the specified context.

```
class CNeuronLSTM    :  public CNeuronBase

  {

protected:

   ....

public:

   ....

   virtual bool      SetOpenCL(CMyOpenCL *opencl) override;
```

The algorithm of the method is quite simple. First, we call the method of the parent class and pass the resulting pointer to it. The validation of the received pointer correctness is already implemented in the parent class method. Therefore, we need not repeat it here.

Then, we pass the OpenCL context pointer stored in our class variable to all internal objects. The key point here is that the method of the parent class has verified the received pointer and has saved the corresponding pointer in a variable. To ensure that all objects operate within the same context, we propagate the processed pointer.

```
bool CNeuronLSTM::SetOpenCL(CMyOpenCL *opencl)

  {

//--- call the parent class method

   CNeuronBase::SetOpenCL(opencl);

//--- call the relevant method for all internal layers

   m_cForgetGate.SetOpenCL(m_cOpenCL);

   m_cInputGate.SetOpenCL(m_cOpenCL);

   m_cOutputGate.SetOpenCL(m_cOpenCL);

   m_cNewContent.SetOpenCL(m_cOpenCL);

   m_cInputGradient.BufferCreate(m_cOpenCL);

   for(int i = 0; i < m_cMemorys.Total(); i++)

     {

      CBufferType *temp = m_cMemorys.At(i);

      temp.BufferCreate(m_cOpenCL);

     }

   for(int i = 0; i < m_cHiddenStates.Total(); i++)

     {

      CBufferType *temp = m_cHiddenStates.At(i);

      temp.BufferCreate(m_cOpenCL);

     }

//---

   return(!!m_cOpenCL);

  }
```

At this point, we can say that we have completed the work on the class initialization algorithm. We can now move on to the next phase, which is to create a feed-forward algorithm.

## Organizing parallel computing in the LSTM block

In previous chapters, we looked at the implementation of an LSTM block using MQL5. However, a new stage in the development of neural networks came precisely with the development of parallel computing technologies. This is especially important for resource-intensive tasks such as recurrent neural networks. Therefore, it is especially important for us to add the ability to use multi-threaded parallel computing tools in the LSTM block class.

As mentioned when creating a block algorithm using MQL5, our class already has an implementation of multi-threaded calculations of individual blocks thanks to the use of objects of the previously discussed class of the base neural layer as gates in the LSTM block algorithm. Therefore, within the framework of this chapter, we only have to implement the missing part:

- Thread consolidating and processing data from internal neural layers within the forward pass.

- Propagating the error gradient from the output of the LSTM block to the internal neural layers within the backpropagation pass.

This gives us an understanding of the task. We already have an MQL5 implementation of the process. This gives an understanding of the process and the algorithm for executing operations.

Therefore, we can proceed with the work. Let me remind you of the architecture for constructing a multi-threaded computing process. The actual execution of the computation process in parallel threads is carried out in an environment different from the main program — in the OpenCL context. To perform operations, three main components are required:

- Program of performed operations.

- Initial data for performing operations.

- Process control commands (moment of program launch, number of threads created, etc.)

Let's look at the implementation of these points.

 

#### 4.Making additions to the OpenCL program

The first item we indicate is the program of the operations being performed. This means that we need to augment our OpenCL program with new kernels to perform the additional operations we require. We collected all the code of the OpenCL program in the file [opencl_program.cl](https://www.mql5.com/en/neurobook/index/realization/pr_opencl/opencl_programm). Open this file and add two new kernels to it: LSTMFeedForward and LSTMCalcHiddenGradient. The names of the kernels correspond to the names of the methods of our classes. Therefore, it is easy to guess that the first will complement the feed-forward pass method, and the second will complement the error gradient backpropagation method.

Recurrent LSTM block diagram

We start with the feed-forward pass kernel LSTMFeedForward. In the parameters, this buffer will receive pointers to six data buffers (four source data buffers and two result buffers) and one constant:

- forgetgate: pointer to the forget gate buffer (source data)

- inputgate: pointer to the input gate buffer (source data)

- outputgate: pointer to the result gate buffer (source data)

- newcontent: pointer to the new content buffer (source data)

- memory: pointer to a memory stream (result buffer)

- hiddenstate: pointer to the hidden state stream (result buffer)

- outputs_total: number of elements in the data stream (constant)

```
__kernel void LSTMFeedForward(__global TYPE *forgetgate,

                              __global TYPE *inputgate,

                              __global TYPE *outputgate,

                              __global TYPE *newcontent,

                              __global TYPE *memory,

                              __global TYPE *hiddenstate,

                              int outputs_total)
```

At the beginning of the method, as before, we receive the thread index, which serves as a pointer to the data being processed. Also, we immediately determine the shift in the data buffers to access the data we need.

```
{

   const int n = get_global_id(0);

   const int shift = n * 4;
```

To improve the performance of our program, we will use vector arithmetic. Let's use vector variables of type TYPE4. Let me remind you that we use the TYPE macro substitution to quickly switch the double or float data type used, depending on the requirements for calculation accuracy and the OpenCL device used. But before we begin performing operations, we will transfer the data from our global data buffers to local vector variables.

```
TYPE4 fg = ToVect4(forgetgate, shift, 1, outputs_total, 0);

   TYPE4 ig = ToVect4(inputgate, shift, 1, outputs_total, 0);

   TYPE4 og = ToVect4(outputgate, shift, 1, outputs_total, 0);

   TYPE4 nc = ToVect4(newcontent, shift, 1, outputs_total, 0);

   TYPE4 mem = ToVect4(memory, shift, 1, outputs_total, 0);
```

Now, by analogy with the MQL5 program code, we will perform arithmetic operations to update the state of the memory stream. According to the algorithm of the LSTM block, we must first adjust the incoming memory stream to the value of the oblivion gate, and then add a new context, adjusted by the value of the input gate, to the resulting value. After completing the operations, we return the value of the updated memory stream back to the buffer.

```
TYPE4 temp = mem * fg;

   temp += ig * nc;

   D4ToArray(memory, temp, shift, 1, outputs_total, 0);
```

Next, we need to define a new hidden state flow value. It will also be supplied to the output of the LSTM block for transmission to the next neural layer. Here we need to first normalize the current memory state using the hyperbolic tangent function and then adjust the resulting value by the result gate value. The result of the operations is written to the data buffer.

```
temp = tanh(temp) * og;

   D4ToArray(hiddenstate, temp, shift, 1, outputs_total, 0);

  }
```

The operations of the feed-forward kernel are now completed. From the results of the work of the internal layers of our recurrent LSTM block, we updated the state of the memory stream and obtained values that will be provided at the output of the recurrent block.

In the second kernel LSTMCalcHiddenGradient, we need to perform the reverse operation, that is, carry out the error gradient in the opposite direction, from the output of the recurrent block to the output of each internal neural layer. The specific operation of the backpropagation kernel requires an increase in the number of used data buffers to 10:

- outputs: pointer to the result vector buffer (source data)

- gradients: pointer to the gradient vector buffer of the current layer (source data)

- inputgate: pointer to the input gate buffer (source data)

- outputgate: pointer to the result gate buffer (source data)

- newcontent: pointer to the new content buffer (source data)

- memory: pointer to a memory stream (source data)

- fg_gradients: pointer to the oblivion gate gradient buffer (result buffer)

- ig_gradients: pointer to the input gate gradient buffer (result buffer)

- og_gradients: pointer to the result gate gradient buffer (result buffer)

- nc_gradients: pointer to the new content gradient buffer (result buffer)

- outputs_total: number of elements in the data stream (constant)

```
__kernel void LSTMCalcHiddenGradient(__global TYPE *outputs_

                                     __global TYPE *gradients,

                                     __global TYPE *inputgate,

                                     __global TYPE *outputgate,

                                     __global TYPE *newcontent,

                                     __global TYPE *memory,

                                     __global TYPE *fg_gradients,

                                     __global TYPE *ig_gradients,

                                     __global TYPE *og_gradients,

                                     __global TYPE *nc_gradients,

                                     int outputs_total)
```

At the beginning of the kernel, we determine the thread ID and the offset in the data buffers to the values being processed.

```
{

   const int n = get_global_id(0);

   int shift = n * 4;
```

As in the forward pass kernel, we will use operations with vector variables of type TYPE4. Therefore, in the next step, we transfer the original data from global buffers to local vector variables.

```
TYPE4 out = ToVect4(outputs, shift, 1, outputs_total, 0);

   TYPE4 grad = ToVect4(gradients, shift, 1, outputs_total, 0);

   TYPE4 ig = ToVect4(inputgate, shift, 1, outputs_total, 0);

   TYPE4 og = ToVect4(outputgate, shift, 1, outputs_total, 0);

   TYPE4 nc = ToVect4(newcontent, shift, 1, outputs_total, 0);

   TYPE4 mem = ToVect4(memory, shift, 1, outputs_total, 0);
```

After completing the preparatory operations, we proceed to execute the mathematical part of the kernel. [Formulas](https://www.mql5.com/en/neurobook/index/main_layer_types/rnn/rnn_mql5/rnn_mqlbackprop) for carrying out operations and their explanation are presented when describing the construction of a process using MQL5. Therefore, in this section, only the implementation of the process in OpenCL will be given.

When implementing this part in MQL5, we decided that it was inappropriate to create an additional data buffer to store the normalized value of the memory stream. In the kernel parameters, we received a pointer to a stream not of the current memory state, but of a recurrent block arriving at the input from the previous iteration of the forward pass. Therefore, before proceeding with the error gradient distribution operations, we need to find the value of the normalized state of the memory stream. We define it as the ratio of the result buffer value to the result gate value. To eliminate division by zero, we add a small constant in the denominator.

```
TYPE4 m = out / (og + 1.0e-37f);
```

Following the logic of the error gradient backpropagation algorithm, we first determine the error gradient at the output of the oblivion gate neural layer. To do this, we need to multiply the error gradient at the output of our LSTM block by the derivative of the product. In this case, it is equal to the value of the normalized memory state. We will immediately write the resulting value into the corresponding data buffer.

```
//--- OutputGate gradient

   TYPE4 temp = grad * m;

   D4ToArray(og_gradients, temp, shift, 1, outputs_total, 0);
```

Next, we must similarly determine the error gradient with another multiplier, which is the normalized memory state. That is, we multiply the error gradient at the output of our recurrent block by the state of the results gate.

Before continuing to propagate the gradient to the remaining neural layers, we need to pass it through the [hyperbolic tangent](https://www.mql5.com/en/neurobook/index/about_ai/activation#tanh) function. In other words, we multiply the previously obtained value by the derivative of the hyperbolic tangent.

```
//--- Adjust the memory gradient to the derivative TANH

   grad = grad * og * (1 - pow(m, 2));
```

Now we only need to propagate the error gradient across the remaining internal layers. The algorithm will be the same for all neural layers. The only difference is in the buffer used as a derivative of the multiplication function. After determining the error gradient, we immediately write its value into the appropriate buffer.

```
//--- InputGate gradient

   temp = grad * nc;

   D4ToArray(ig_gradients, temp, shift, 1, outputs_total, 0);

//--- NewContent gradient

   temp = grad * ig;

   D4ToArray(nc_gradients, temp, shift, 1, outputs_total, 0);

//--- ForgetGates gradient

   temp = grad * mem;

   D4ToArray(fg_gradients, temp, shift, 1, outputs_total, 0);

  }
```

After completing the operations, we exit the kernel.

Thus, we implemented the missing kernels to organize forward and backward passes as part of performing operations for a recurrent LSTM block. This completes the modification of the OpenCL program, and we move on to performing operations on the side of the main program.

 

#### 4.Implementing functionality on the side of the main program

After making changes to the OpenCL program, we must do the second part of the work and organize the process on the side of the main program. The first thing we will do is create constants for working with kernels. Here we need to create constants to identify kernels and their parameters. We will add the specified constants to those previously created in the file [defines.mqh](https://www.mql5.com/en/neurobook/index/realization/basic/constants#mql5includeneuronetworksbookrealizationdefines.mqh).

```
#define def_k_LSTMFeedForward          26

#define def_k_LSTMHiddenGradients      27
```

```
//--- LSTM Feed Forward

#define def_lstmff_forgetgate          0

#define def_lstmff_inputgate           1

#define def_lstmff_outputgate          2

#define def_lstmff_newcontent          3

#define def_lstmff_memory              4

#define def_lstmff_hiddenstate         5

#define def_lstmff_outputs_total       6
```

When adding constants, we follow the previously defined naming rules. All kernel constants begin with the prefix def_k_, and parameter constants contain the kernel abbreviation: def_lstmff_ for feed-forward kernel parameters and def_lstmhgr_ for gradient backpropagation kernel parameters.

```
//--- LSTM Hidden Gradients

#define def_lstmhgr_outputs            0

#define def_lstmhgr_gradients          1

#define def_lstmhgr_inputgate          2

#define def_lstmhgr_outputgate         3

#define def_lstmhgr_newcontent         4

#define def_lstmhgr_memory             5

#define def_lstmhgr_fg_gradients       6

#define def_lstmhgr_ig_gradients       7

#define def_lstmhgr_og_gradients       8

#define def_lstmhgr_nc_gradients       9

#define def_lstmhgr_outputs_total      10
```

We then go to the [neuronnet.mqh](https://www.mql5.com/en/neurobook/index/realization/basic/neuron_base) file, which contains the code for our neural network class. In the CNet::InitOpenCL method, we need to change the number of used kernels and simultaneously open buffers.

```
if(!m_cOpenCL.SetKernelsCount(28))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }

   if(!m_cOpenCL.SetBuffersCount(10))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

Changing the last parameter is not critical since in our buffer creation method, we, if necessary, change the size of the array for storing buffer handles. However, using the standard OpenCL.mqh library, there is no such functionality. This may result in a runtime error.

Next, we declare the kernels for use within our program, while always controlling the process of operations.

```
if(!m_cOpenCL.KernelCreate(def_k_LSTMFeedForward, "LSTMFeedForward"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

```
if(!m_cOpenCL.KernelCreate(def_k_LSTMHiddenGradients, "LSTMCalcHiddenGradient"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

This completes the preparatory work, and we move on to making changes directly to the code of the executable methods of our recurrent LSTM block class.

According to the chronology of the execution of the algorithm of our neural network, we will be the first to make changes to the feed-forward method. In it, we first organize a check for the presence of data in the memory of the OpenCL context.

```
bool CNeuronLSTM::FeedForward(CNeuronBase *prevLayer)

  {

   ....

//--- Branching of the algorithm by the computing device

   CBufferType *fg = m_cForgetGate.GetOutputs();

   CBufferType *ig = m_cInputGate.GetOutputs();

   CBufferType *og = m_cOutputGate.GetOutputs();

   CBufferType *nc = m_cNewContent.GetOutputs();

   if(!m_cOpenCL)

     {

     // MQL5 Block is missing here

     }

   else // Block for working with OpenCL

     {

      //--- check buffers

      if(fg.GetIndex() < 0 || ig.GetIndex() < 0 || og.GetIndex() < 0 ||

         nc.GetIndex() < 0 || memory.GetIndex() < 0 || hidden.GetIndex() < 0)

         return false;
```

We then pass pointers to the created buffers to our kernel parameters. Here we indicate the constants necessary for the correct execution of the program code. Again, we check the results of the operations.

```
//--- pass parameters to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMFeedForward, def_lstmff_forgetgate,

 fg.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMFeedForward, def_lstmff_inputgate,

 ig.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMFeedForward, def_lstmff_newcontent,

                                                                      nc.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMFeedForward, def_lstmff_outputgate,

 og.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMFeedForward, def_lstmff_memory,

 memory.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMFeedForward, def_lstmff_hiddenstate,

 hidden.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_LSTMFeedForward, def_lstmff_outputs_total,

 m_cOutputs.Total()))

         return false;
```

This completes the preparatory work stage. Let's move on to launching the kernel to perform operations. First, let's determine the number of required threads. In the kernel body, we use vector operations and therefore the number of threads will be four times less than the size of the buffers.

We write the calculated number of threads into the NDRangearray and indicate the zero offset in the data buffers in the off_set array. The kernel is added in the execution queue. If an error occurs when queuing the kernel, the m_cOpenCL.Execute function will return a false result, which we must check and process.

```
//--- launch the kernel

      int NDRange[] = {(int)(m_cOutputs.Total() + 3) / 4};

      int off_set[] = {0};

      if(!m_cOpenCL.Execute(def_k_LSTMFeedForward, 1, off_set, NDRange))

         return false;

     }
```

This completes the work on the LSTM feed-forward method. Let's move on to making additions to the backpropagation method.

As in the case of the feed-forward pass, we will begin work in the error gradient distribution method CNeuronLSTM::CalcHiddenGradient by checking the presence of source data in the OpenCL context memory.

```
bool CNeuronLSTM::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

   ....

      //--- Branching the algorithm by the computing device

      if(!m_cOpenCL)

        {

         // MQL5 Block is missing here

        }
```

```
else // Block for working with OpenCL

        {

         //--- check buffers

         if(hidden.GetIndex() < 0)

            return false;

         if(m_cGradients.GetIndex() < 0)

            return false;

         if(ig.GetIndex() < 0)

            return false;

         if(og.GetIndex() < 0)

            return false;

         if(nc.GetIndex() < 0)

            return false;

         if(memory.GetIndex() < 0)

            return false;

         if(fg_grad.GetIndex() < 0)

            return false;

         if(ig_grad.GetIndex() < 0)

            return false;

         if(og_grad.GetIndex() < 0)

            return false;

         if(nc_grad.GetIndex() < 0)

            return false;
```

Next, we completely repeat the algorithm for working with OpenCL kernels on the side of the main program. After creating the necessary buffers in the OpenCL context memory, we pass the data buffer handles and variable values to the kernel parameters. And it is very important to monitor the execution of all process operations.

```
//--- pass parameters to the kernel

         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients,

                                    def_lstmhgr_fg_gradients, fg_grad.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients,

                                  def_lstmhgr_gradients, m_cGradients.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients,

                                    def_lstmhgr_ig_gradients, ig_grad.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients,

                                            def_lstmhgr_inputgate, ig.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients,

                                           def_lstmhgr_memory, memory.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients,

                                    def_lstmhgr_nc_gradients, nc_grad.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients,

                                           def_lstmhgr_newcontent, nc.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients,

                                    def_lstmhgr_og_gradients, og_grad.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients,

                                           def_lstmhgr_outputgate, og.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients,

                                          def_lstmhgr_outputs, hidden.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgument(def_k_LSTMHiddenGradients,

                                   def_lstmhgr_outputs_total, m_cOutputs.Total()))

            return false;
```

This concludes the stage of preparatory work. We move on to the procedure for launching the kernel. First of all, here we write the number of threads to start in the NDRange array and the zero offset in the off_set array.

Thanks to the use of vector operations in the kernel body, we need four times fewer threads for the full cycle of operations. Therefore, before we write the value to the NDRangearray, we need to calculate it.

After this, we will send our kernel to the execution queue.

```
//--- launch the kernel

         int NDRange[] = { (int)(m_cOutputs.Total() + 3) / 4 };

         int off_set[] = {0};

         if(!m_cOpenCL.Execute(def_k_LSTMHiddenGradients, 1, off_set, NDRange))

            return false;

        }
```

I might sound repetitive, but I want to stress the importance of checking the result of each operation. This is a crucial point since any error in performing the operation can both distort the entire result of our neural network and cause a critical error, resulting in the termination of the entire program.

With this, we have completed the work on the recurrent LSTM block class. We have organized the class to work in two environments:

- Implemented operation on the CPU using standard MQL5 tools.

- Created the ability to implement multi-threaded parallel calculations using OpenCL.

Now, we can evaluate the results of our work by creating and testing a recurrent neural network model.

## Implementing recurrent models in Python

In the previous sections, we reviewed the principles of organizing a recurrent model architecture, and even built a recurrent neural layer using the LSTM block algorithm. Earlier, we used the Keras library for TensorFlow to build previous neural network models in Python. The same library offers a number of options for building recurrent neural layers. These include classes of basic recurrent neural layers as well as more complex models.

- AbstractRNNCell — abstract object representing an RNN cell

- Bidirectional — bidirectional shell for RNN

- ConvLSTM1D — 1D convolutional LSTM block

- ConvLSTM2D — 2D convolutional LSTM block

- ConvLSTM3D — 3D convolutional LSTM block

- GRU — recurrent block by Cho et al. (2014)

- LSTM — layer of long-term short-term memory by Hochreiter (1997)

- RNN — base class for the recurrent layer

- SimpleRNN — fully connected recurrent layer in which the output must be returned to the input

In the presented list, in addition to the basic recurrence layer class, you can find already familiar LSTM and GRU models. It is also possible to create bidirectional recurrent layers, which are most often used in text translation tasks. The ConvLSTM model is built based on the architecture of the LSTM block but uses convolutional layers instead of fully connected layers as gates and a new content layer.

Additionally, there is an abstract recurrent cell class for creating custom architectural solutions for recurrent models.

We won't go deep into the Keras library API right now. We will use the LSTM block to create our test recurrent models. Exactly this kind of model we recreated using MQL5 and will be able to compare the performance of our models created in different programming languages.

The LSTM block class is designed to automatically choose between CuDNN or pure TensorFlow implementations based on available hardware and environment constraints, ensuring optimal performance.

Users have access to an excessive range of parameters for fine-tuning the recurrent block:

- units — dimensionality of the output space

- activation — activation function

- recurrent_activation — activation function for the recurrent step (gate)

- use_bias — flag of using an offset vector

- kernel_initializer — method to initialize the weights matrix for the new context layer

- recurrent_initializer — method to initialize the weight matrix for gates

- bias_initializer — initialization method for bias vector

- kernel_regularizer — function to regularize the weight matrix for the new content layer

- recurrent_regularizer — function to regularize the weight matrix for gates

- bias_regularizer — bias vector regularization function

- activity_regularizer — output layer regularization function

- kernel_constraint — function of constraints for the weight matrix of the new content layer

- recurrent_constraint — function of constraints for the weight matrix of gates

- bias_constraint — function of vector constraints

- dropout — floating-point number from 0 to 1, defining the share of elements to be dropped out during linear transformation of input data

- recurrent_dropout — floating-point number from 0 to 1, determining the share of elements to be dropped out during linear transformation of memory state

- return_sequences — boolean flag to specify whether to return the last result in the output sequence or the results of the whole sequence

- return_state — boolean flag to indicate whether to return the last state in addition to the output

- go_backwards — boolean flag to instruct the processing of the input sequence in the backward order and return the reverse sequence

- stateful — boolean flag to indicate the use of the last state for each sample with the i index in the batch as the initial state for the sample with the i index in the next batch

- time_major — the format of the input and output sequence tensor shapes

- unroll — boolean flag used to indicate whether to unroll the recurrent network or use a simple loop; unrolling can accelerate the training of the recurrent network, but it requires more memory

After acquainting ourselves with the control parameters of the LSTM layer class, we will proceed to the practical implementation of various models using the recurrence layer.

## 4.Building a test recurrent model in Python

To build test recurrent models in Python, we will use the previously developed template. Moreover, we will take the script file [convolution.py](https://www.mql5.com/en/neurobook/index/main_layer_types/cnn/cnn_py), which we used when testing convolutional models. Let's make a copy of it with the file name lstm.py. In the created copy, we leave the perceptron model and the best convolutional model, deleting the rest. This approach will allow us to compare the performance of the new models with the architectural solutions discussed earlier.

```
# Creating a perceptron model with three hidden layers and regularization

model1 = keras.Sequential([keras.Input(shape=inputs),

                           keras.layers.Dense(40, activation=tf.nn.swish,

                 kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(40, activation=tf.nn.swish,

                 kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(40, activation=tf.nn.swish,

                 kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(targerts, activation=tf.nn.tanh)

                         ])
```

```
# Model with 2-dimensional convolutional layer

model3 = keras.Sequential([keras.Input(shape=inputs),

                           # Reformat the tensor to 4-dimensional.

   # Specify 3 dimensions, because the 4th dimension is determined by the size of the packet

                           keras.layers.Reshape((-1,4,1)),

                           # Convolutional layer with 8 filters

                           keras.layers.Conv2D(8,(3,1),1,activation=tf.nn.swish,

                 kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           # Pooling layer

                           keras.layers.MaxPooling2D((2,1),strides=1),

                 # Reformat the tensor to 2-dimensional for fully connected layers

                           keras.layers.Flatten(),

                           keras.layers.Dense(40, activation=tf.nn.swish,

                 kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(40, activation=tf.nn.swish,

                 kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(40, activation=tf.nn.swish,

                 kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(targerts, activation=tf.nn.tanh)

                         ])
```

After that, we will create three new models using the recurrent LSTM block. Initially, we will take the convolutional neural network model and replace the convolutional and pooling layers with a single recurrent layer with 40 neurons at the output. Note that the input to the recurrent LSTM block should be a three-dimensional tensor of the format [batch, timesteps, feature]. Just like in the case of a convolutional layer, when specifying the dimensionality of a layer in the model, we don't explicitly mention the batch dimension, as its value is determined by the batch size of the input data.

```
# Add an LSTM block to the model

model2 = keras.Sequential([keras.Input(shape=inputs),

# Reformat the tensor to 3-dimensional.

# Specify 2 dimensions, because. The 3rd dimension is determined by the size of the packet

                           keras.layers.Reshape((-1,4)),

# The LSTM block contains 40 elements and returns the result at each step

                           keras.layers.LSTM(40, return_sequences=False,

                 kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),
```

In this model, we specified parameter return_sequences=False which instructs the recurrent layer to produce the result only after processing the full batch. In this version, our LSTM layer returns a two-dimensional tensor in the format [batch, feature]. In this case, the dimension of the feature measurement will be equal to the number of neurons that we specified during the creation of the recurrent layer. A tensor of the same dimension is required for the input of a fully connected neural layer. Therefore, we do not need additional reformatting of the data, and we can use a fully connected neural layer.

```
keras.layers.Dense(40, activation=tf.nn.swish,

                 kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(40, activation=tf.nn.swish,

                 kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(40, activation=tf.nn.swish,

                 kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           keras.layers.Dense(targerts, activation=tf.nn.tanh)

                         ])
```

Structure of a recurrent model with four fully connected layers

In this implementation, we use the recurrent layer for preliminary data processing, while decision-making in the model is carried out by several fully connected perceptron layers that follow the recurrent layer. As a result, we got a model with 12,202 parameters.

We will compile all neural models with the same parameters. We use the Adam method for optimization and the standard deviation for the network error. We also add an additional metric accuracy.

```
model2.compile(optimizer='Adam',

               loss='mean_squared_error',

               metrics=['accuracy'])
```

We compiled earlier neural network models with the same parameters.

One more point should be noted. Recurrent models are sensitive to the sequence of the input signal being fed. Therefore, when training a neural network, unlike the previously discussed models, we cannot shuffle the input data. For this purpose, when we start training the model, we will specify the False for the shuffle parameter. The rest of the training parameters of the model remain unchanged.

```
history2 = model2.fit(train_data, train_target,

                      epochs=500, batch_size=1000,

                      callbacks=[callback],

                      verbose=2,

                      validation_split=0.01,

                      shuffle=False)
```

In the first model, we used a recurrent layer for preliminary data processing before using a fully connected perceptron for decision-making. However, it is also possible to use recurrent neural layers in their pure form, without subsequent utilization of fully connected layers. It is this implementation that I propose to consider as the second model. In this case, we simply replace all the fully connected layers with a single recurrent layer, and we set the size of the layer to match the desired output size of the neural network.

It's important to note that the recurrent neural layer requires a three-dimensional tensor as input, whereas we obtained a two-dimensional tensor at the output of the previous recurrent layer. Therefore, before passing information to the input of the next recurrent layer, we need to reshape the data. In this implementation, we set the last adjustment to be equal to two, while leaving the size of the temporal labels dimension for the model's calculation. We don't expect any data distortion from such reshaping, as we're grouping sequential data, essentially just enlarging the time interval. At the same time, the time interval between any two subsequent elements in the new time series remains constant.

```
# LSTM block model without fully connected layers

model4 = keras.Sequential([keras.Input(shape=inputs),

# Reformat the tensor to 3-dimensional.

# Specify 2 dimensions, because. The 3rd dimension is determined by the size of the packet

                           keras.layers.Reshape((-1,4)),

#2 Serial LSTM Units

#1st contains 40 elements

                           keras.layers.LSTM(40,

             kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5),

                           return_sequences=False),

# 2nd produces the result instead of a fully connected layer

                           keras.layers.Reshape((-1,2)),

                           keras.layers.LSTM(targerts)

                         ])
```

Now we have a neural network where the first recurrent layer performs preliminary data processing, and the second recurrent layer generates the output of the neural network. By eliminating the use of a perceptron, we've reduced the number of neural layers in the network and, consequently, the total number of parameters, which in the new model amounts to 7,240 parameters.

The structure of a recurrent neural network without the use of fully connected layers

We compile and train the model with the same parameters as all previous models.

```
model4.compile(optimizer='Adam',

               loss='mean_squared_error',

               metrics=['accuracy'])
```

```
history4 = model4.fit(train_data, train_target,

                      epochs=500, batch_size=1000,

                      callbacks=[callback],

                      verbose=2,

                      validation_split=0.01,

                      shuffle=False)
```

In the second recurrent model, to create the input tensor for the second LSTM layer, we reshaped the tensor of results from the previous layer. The Keras library gives us another option. In the first LSTM layer, we can specify the parameter return_sequences=True, which switches the recurrent layer to a mode that outputs results at each iteration. As a result of this action, at the output of the recurrent layer, we immediately obtain a three-dimensional tensor of the format [batch, timesteps, feature]. This will allow us to avoid reformatting the data before the second recurrent layer.

```
# LSTM model block without fully connected layers

model5 = keras.Sequential([keras.Input(shape=inputs),

# Reformat the tensor to 3-dimensional.

# Specify 2 dimensions, because. The 3rd dimension is determined by the size of the packet

                           keras.layers.Reshape((-1,4)),

# 2 Serial LSTM Units

#1st contains 40 items and returns the result at each step

                           keras.layers.LSTM(40,

               kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5),

                           return_sequences=True),

# 2nd produces the result instead of a fully connected layer

                           keras.layers.LSTM(targerts)

                         ])
```

The structure of a recurrent neural network without the use of fully connected layers

As you can see, with this model construction, the dimensionality of the tensor at the output of the first recurrent layer has changed. As a result, the number of parameters in the second recurrent layer has slightly increased. This resulted in a total increase in parameters throughout the model, reaching 7,544 parameters. Nevertheless, this is still fewer parameters than the total number of parameters in the first recurrent model that used a perceptron for decision-making.

Let's supplement the plotting block with new models.

```
# Rendering model training results

plt.figure()

plt.plot(history1.history['loss'], label='Perceptron train')

plt.plot(history1.history['val_loss'], label='Perceptron validation')

plt.plot(history3.history['loss'], label='Conv2D train')

plt.plot(history3.history['val_loss'], label='Conv2D validation')

plt.plot(history2.history['loss'], label='LSTM train')

plt.plot(history2.history['val_loss'], label='LSTM validation')

plt.plot(history4.history['loss'], label='LSTM only train')

plt.plot(history4.history['val_loss'], label='LSTM only validation')

plt.plot(history5.history['loss'], label='LSTM sequences train')

plt.plot(history5.history['val_loss'], label='LSTM sequences validation')

plt.ylabel('$MSE$ $loss$')

plt.xlabel('$Epochs$')

plt.title('Model training dynamics')

plt.legend(loc='upper right', ncol=2)
```

```
plt.figure()

plt.plot(history1.history['accuracy'], label='Perceptron train')

plt.plot(history1.history['val_accuracy'], label='Perceptron validation')

plt.plot(history3.history['accuracy'], label='Conv2D train')

plt.plot(history3.history['val_accuracy'], label='Conv2D validation')

plt.plot(history2.history['accuracy'], label='LSTM train')

plt.plot(history2.history['val_accuracy'], label='LSTM validation')

plt.plot(history4.history['accuracy'], label='LSTM only train')

plt.plot(history4.history['val_accuracy'], label='LSTM only validation')

plt.plot(history5.history['accuracy'], label='LSTM sequences train')

plt.plot(history5.history['val_accuracy'], label='LSTM sequences validation')

plt.ylabel('$Accuracy$')

plt.xlabel('$Epochs$')

plt.title('Model training dynamics')

plt.legend(loc='lower right', ncol=2)
```

Additionally, let's add the new models to the testing block to evaluate their performance on the test dataset and display the results.

```
# Check the results of models on a test sample

test_loss1, test_acc1 = model1.evaluate(test_data, test_target, verbose=2)

test_loss2, test_acc2 = model2.evaluate(test_data, test_target, verbose=2)

test_loss3, test_acc3 = model3.evaluate(test_data, test_target, verbose=2)

test_loss4, test_acc4 = model4.evaluate(test_data, test_target, verbose=2)

test_loss5, test_acc5 = model5.evaluate(test_data, test_target, verbose=2)
```

```
print('LSTM model')

print('Test accuracy:', test_acc2)

print('Test loss:', test_loss2)
```

```
print('LSTM only model')

print('Test accuracy:', test_acc4)

print('Test loss:', test_loss4)
```

```
print('LSTM sequences model')

print('Test accuracy:', test_acc5)

print('Test loss:', test_loss5)
```

In this section, we have prepared a Python script that creates a total of 5 neural network models:

- Fully connected perceptron

- Convolutional model

- 3 models of recurrent neural networks

Upon executing the script, we will conduct a brief training of all five models using a single dataset and then compare the performance of the trained models on a shared set of test data. This will give us the opportunity to compare the performance of various architectural solutions on real data. The test results will be provided in the next chapter.

## 4.Backpropagation methods for LSTM block

The feed-forward pass represents the standard mode of operation of a neural network. However, before it can be used in real-life operations, we need to train our model. Recurrent neural networks are trained using the familiar backpropagation method with a slight addition. The reason is that, unlike the neural layer types we've discussed before, only recurrent layers use their own output as their input on future iterations. Also, they all have their own weights that need to be learned as well. In the learning process, we have to unfold the recurrent layers chronologically as a multilayer perceptron. The only difference is that all layers will use the same weight matrix. Precisely for this purpose, during the feed-forward pass, we kept a record of the state history of all objects. Now it's time to put them to good use.

We have three methods responsible for the backward pass in the base class of the neural layer:

- CalcHiddenGradient — a gradient distribution through a hidden layer.

- CalcDeltaWeights — a distribution of the gradient to the weighting matrix.

- UpdateWeights — the method of updating the weights.

```
class CNeuronLSTM    :  public CNeuronBase

  {

protected:

   ....

public:

   ....

   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer)  override;

   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer)    override

                                                          { return true; }

   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,

                                   VECTOR &Beta, VECTOR &Lambda) override;
```

We have to redefine them.

First, we will override the CalcHiddenGradient method for distributing the gradient through the hidden layer. Here we will need to unwrap the entire historical chain and run the error gradient through all states. Additionally, let's not forget that besides distributing gradients within the LSTM block, we must also perform the second function of this method: propagating the gradient of the error back to the previous layer.

The method receives a pointer to the object of the previous layer and returns a boolean result indicating the success of the operations.

At the beginning of the method, we check all the objects used. We check both pointers to objects of the previous layer and internal objects received in the parameters.

```
bool CNeuronLSTM::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

//--- check the relevance of all objects

   if(!prevLayer || !prevLayer.GetGradients() ||

      !m_cGradients || !m_cForgetGate || !m_cForgetGateOuts ||

      !m_cInputGate || !m_cInputGateOuts || !m_cOutputGate ||

      !m_cOutputGateOuts || !m_cNewContent || !m_cNewContentOuts)

      return false;
```

Let's not forget that a backpropagation pass is only possible after a feed-forward pass. The foundation of source data for the backpropagation pass is established exactly during the feed-forward pass. Therefore, the next step is to check for the presence of information in the memory stacks and hidden states. In addition, the stack filling indicates the depth of gradient propagation in the story.

```
//--- check the presence of forward pass data

   int total = (int)fmin(m_cMemorys.Total(), m_cHiddenStates.Total()) - 1;

   if(total <= 0)

      return false;
```

Continuing the preparatory work, let's create pointers to the result and gradient buffers of the internal layers. I think the need for pointers to gradient buffers is obvious. We will need to write error gradients to them, propagating them through the LSTM block. The need for result buffers, on the other hand, is not so obvious. As you know, every neuron has an activation function. Our inner layers are activated by the [logistic](https://www.mql5.com/en/neurobook/index/about_ai/activation#sigmoid) function and by the [hyperbolic tangent](https://www.mql5.com/en/neurobook/index/about_ai/activation#tanh). The error gradient obtained at the input of the neural layer must be adjusted to the derivative of the activation function. The derivative of the above activation functions can be easily recalculated based on the result of the function itself. Thus, we need the appropriate input data to perform a correct backpropagation pass. For the previously considered neural layers, such an issue was not raised because the correct data were written to the result buffer in a forward pass. In the case of a recurrent block, only the result of the last forward pass will be stored in the result buffer. To work out the depth of the history, we will have to overwrite the values of the result buffer with the values of the corresponding time step.

```
//--- make pointers to buffers of gradients and results of internal layers

   CBufferType *fg_grad = m_cForgetGate.GetGradients();

   if(!fg_grad)

      return false;

   CBufferType *fg_out = m_cForgetGate.GetOutputs();

   if(!fg_out)

      return false;
```

```
CBufferType *ig_grad = m_cInputGate.GetGradients();

   if(!ig_grad)

      return false;

   CBufferType *ig_out = m_cInputGate.GetOutputs();

   if(!ig_out)

      return false;
```

```
CBufferType *og_grad = m_cOutputGate.GetGradients();

   if(!og_grad)

      return false;

   CBufferType *og_out = m_cOutputGate.GetOutputs();

   if(!og_out)

      return false;
```

```
CBufferType *nc_grad = m_cNewContent.GetGradients();

   if(!nc_grad)

      return false;

   CBufferType *nc_out = m_cNewContent.GetOutputs();

   if(!nc_out)

      return false;
```

At the end of the preparatory process, we will store the size of the internal thread buffers into a local variable.

```
uint out_total = m_cOutputs.Total();
```

Next, we create a loop through historical data. The main operations of our method will be performed in the body of this loop. At the beginning of the loop, we will load information from the corresponding historical step in our stacks. Note that all buffers are loaded for the analyzed chronological step, while the memory buffer is taken from the preceding step. I will explain the reasons for this below.

```
//--- loop through the accumulated history

   for(int i = 0; i < total; i++)

     {

      //--- get pointers to buffers from the stack

      CBufferType *fg = m_cForgetGateOuts.At(i);

      if(!fg)

         return false;

      CBufferType *ig = m_cInputGateOuts.At(i);

      if(!ig)

         return false;

      CBufferType *og = m_cOutputGateOuts.At(i);

      if(!og)

         return false;

      CBufferType *nc = m_cNewContentOuts.At(i);

      if(!nc)

         return false;

      CBufferType *memory = m_cMemorys.At(i + 1);

      if(!memory)

         return false;

      CBufferType *hidden = m_cHiddenStates.At(i);

      if(!hidden)

         return false;

      CNeuronBase *inputs = m_cInputs.At(i);

      if(!inputs)

         return false;
```

Next, we have to distribute the error gradient received at the input of the LSTM block between the internal neural layers. This is where we build a new process. Following our class construction concept, we create a branching of the algorithm based on the execution device for mathematical operations.

The error gradient distribution is performed in reverse order of the forward flow of information. Hence, we will construct its propagation algorithm from output to input. Let's look at the result node of our LSTM block. During the feed-forward pass, the updated memory state is activated by the hyperbolic tangent and multiplied by the output gate state. Thus, we have two components affecting the result of the block: the memory value and the gate.

LSTM block result node

In order to reduce the error at the block output, we need to adjust the values of both components. To do this, we need to distribute the overall error gradient through a multiplication function that combines the two threads of information. That is, multiply the error gradient we know by the derivative of the function along each direction. We know from our high school math course that the derivative of the product of a constant over a variable is a constant. We apply the following approach: when determining the influence of one of the factors, we assume that all other components have constant values. Hence, we can write the following mathematical formulas.

Then we can easily distribute the derivative in both directions using the following mathematical formulas.

We haven't created a separate buffer for the activated memory state. However, we can easily count it by re-activating the corresponding state or by dividing the hidden state by the output gate value. I chose the second path, and the entire algorithm for distributing the error gradient at this site is expressed in the following code.

```
//--- branching of the algorithm across the computing device

      if(!m_cOpenCL)

        {

         //--- calculate the gradient at the output of each internal layer

         MATRIX m = hidden.m_mMatrix / (og.m_mMatrix + 1e-8);

         //--- OutputGate gradient

         MATRIX grad = m_cGradients.m_mMatrix;

         og_grad.m_mMatrix = grad * m;

         //--- memory gradient

         grad *= og.m_mMatrix;
```

Before distributing the memory gradient to the rest of the internal layers, we must correct the resulting gradient by the derivative of the activation function.

```
//--- adjust the gradient to the derivative

         grad *= MathPow(m, 2) * (-1) + 1;
```

We continue to distribute the error gradient between the internal layers. We need to distribute the error gradient from the memory flow to three more internal layers. Moving along the information flow inside the LSTM block in reverse, the first function we encounter is summation. The derivative of the sum is 1. Therefore, we pass the error gradient in both directions unchanged.

Error gradient distribution inside the LSTM block

Next, in both directions, we encounter the product. The principles of propagating the gradient through the multiplication of two numbers have been explained in detail above, so there is no need to repeat them. I just want to remind you that, unlike all buffers from the stack, only the memory buffer was taken one step further back in history. I promised to clarify this point, and now is the most suitable time to do so. Take a look at the LSTM block diagram. To refresh memory, we multiply the output of the Forget gate by the memory state transferred from the previous iteration. Hence, to determine the error gradient at the output of the Forget gate, we need to multiply the error gradient in the memory thread by the memory state of the previous iteration. It is the buffer of this state that we loaded at the start of the loop

The MQL5 code of the described operations is presented below.

```
//--- InputGate gradient

         ig_grad.m_mMatrix = grad * nc.m_mMatrix;

         //--- NewContent gradient

         nc_grad.m_mMatrix = grad * ig.m_mMatrix;

         //--- ForgetGates gradient

         fg_grad.m_mMatrix = grad * memory.m_mMatrix;

        }
```

This completes the thread separation block by computational operation unit, and we merge the threads of the algorithm. We set a stub for the OpenCL branch and move on.

```
else

        {

         return false;

        }
```

We have already discussed the need to use the historical states of the inner layer result buffers. Now we need to put this into practice and fill the result buffers with relevant historical data.

```
//--- copy the corresponding historical data to the buffers of the internal layers

      if(!m_cForgetGate.SetOutputs(fg, false))

         return false;

      if(!m_cInputGate.SetOutputs(ig, false))

         return false;

      if(!m_cOutputGate.SetOutputs(og, false))

         return false;

      if(!m_cNewContent.SetOutputs(nc, false))

         return false;
```

Next, we need to propagate the gradient from the output to the input of the internal neural layers. This functionality is easily implemented by the base class method. However, please note the following. All four internal neural layers use the same input data. We also need to put the error gradient together in the same buffer. The neural layer base class methods we developed earlier are constructed in such a way that they overwrite values. Therefore, we need to organize the process of summing the error gradients from each internal neural layer.

First, we'll run a gradient through the Forget gate. Recall that in order to transfer the source data to the internal neural layers, we created a base layer of source data and after performing forward pass operations, we stored a pointer to it in the source data stack. This type of object already contains buffers for writing data and error gradients. So, now we just take this pointer and pass it in the parameters of the CNeuronBase::CalcHiddenGradient method. After this, our base class method will execute and fill the error gradient buffer at the source data level for the forget gates. But it's only one gate, and we need to gather information from all of them. To avoid losing the computed error gradient when calling a similar method for other internal layers, we will copy the data into the m_cInputGradient buffer which we created in advance for accumulating error gradients.

```
//--- propagate a gradient through the inner layers

      if(!m_cForgetGate.CalcHiddenGradient(inputs))

         return false;

      if(!m_cInputGradient)

        {

         m_cInputGradient = new CBufferType();

         if(!m_cInputGradient)

            return false;

         m_cInputGradient.m_mMatrix = inputs.GetGradients().m_mMatrix;

         m_cInputGradient.BufferCreate(m_cOpenCL);

        }

      else

        {

         m_cInputGradient.Scaling(0);

         if(!m_cInputGradient.SumArray(inputs.GetGradients()))

            return false;

        }
```

We repeat the operations for the remaining internal layers. However, now we add the new values of the error gradient to the previously obtained values.

```
if(!m_cInputGate.CalcHiddenGradient(inputs))

         return false;

      if(!m_cInputGradient.SumArray(inputs.GetGradients()))

         return false;

      if(!m_cOutputGate.CalcHiddenGradient(inputs))

         return false;

      if(!m_cInputGradient.SumArray(inputs.GetGradients()))

         return false;

      if(!m_cNewContent.CalcHiddenGradient(inputs))

         return false;

      if(!inputs.GetGradients().SumArray(m_cInputGradient))

         return false;
```

Please note the following. While processing the first three internal layers we move values into the temporary buffer m_cInputGradient. However, while processing the last layer, we transfer the previously accumulated error gradient into the source data layer buffer. Thus, we keep the overall error gradient at the initial data layer along with the initial data itself in the same initial data layer. It will also be automatically saved in our stack. Recall what I wrote about objects and pointers to them.

Here comes an interesting moment. Remember, why we did all this? Propagation of the error gradient across all elements of the neural network is necessary to have a reference for determining the direction and extent of weight matrix element adjustments to reduce the overall error of our neural network performance. Consequently, as a result of the operations of this method, we must:

- Bring the error gradient to the previous layer, and

- Bring the error gradient to the weight matrices of the internal neural layers.

If we run the next iteration cycle in this state with new data for recalculating the error gradients of internal layers, we will simply replace the just-calculated values. However, we need to propagate the error gradients all the way to the weight matrices of the internal neural layers. Therefore, without waiting for a call from an external program, we call the CNeuronBase::CalcDeltaWeights method for all internal layers, which will recalculate the gradient at the weight matrix level.

```
//--- project the gradient onto the weight matrices of the internal layers

      if(!m_cForgetGate.CalcDeltaWeights(inputs))

         return false;

      if(!m_cInputGate.CalcDeltaWeights(inputs))

         return false;

      if(!m_cOutputGate.CalcDeltaWeights(inputs))

         return false;

      if(!m_cNewContent.CalcDeltaWeights(inputs))

         return false;
```

We pass the error gradient only from the current state to the previous neural layer. Historical data remains only for the internal user of the LSTM block. Therefore, we check the iteration index and only then pass the error gradient to the buffer of the previous layer. Do not forget that our error gradient buffer at the source data level contains more data than the buffer of the previous layer. This is because it also contains the error gradient of the hidden state. Hence, we will transfer only the necessary part of the data to the previous layer.

We transfer the remainder to the error gradient buffer of our LSTM block. Remember, at the beginning of the loop, it was from this buffer that we took the error gradient to propagate throughout the LSTM block? It's time to prepare the initial data for the next iteration of our loop through the chronological iterations of the feed-forward pass and error gradient propagation.

```
//--- if the gradient of the current state is calculated, then transfer it to the previous layer

   //--- and write the hidden state gradient to the gradient buffer for a new iteration

      if(!inputs.GetGradients().Split((i == 0 ? prevLayer.GetGradients() :

                                                inputs.GetGradients()), m_cGradients,

                                                prevLayer.GetOutputs().Total()))

         return false;

     }

//---

   return true;

  }
```

After the successful execution of all iterations, we exit the method with a positive result.

We have gone through two of the most complex and intricate methods for constructing a recurrent LSTM block algorithm. The rest of it will be much easier. For example, the CalcDeltaWeights method. The functionality of this method involves passing the error gradient to the level of the weight matrix. The LSTM block does not have any separate weight matrix. All parameters are located within the nested neural layers, and we have already brought the error gradient to the level of their weight matrices in the previous method. Therefore, we rewrite the method with an empty stub with a positive result.

```
virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer) { return true; }
```

Another backward pass method, UpdateWeights, is a method for updating the weights matrix. The method is also inherited from the neural layer base class and overridden as needed. LSTM block unlike the previously discussed types of neural layers does not have a single weight matrix. Instead, internal neural layers with their own weight matrices are used. So we can't just use the method of the parent class and have to override it.

The CNeuronLSTM::UpdateWeights method from an external program receives the parameters required to execute the algorithm for updating the weight matrix and returns the logical value of the result of the method operations.

Even though the method parameters do not include any object pointers, we still set up control structures at the beginning of the method. Here, we check the validity of pointers to internal neural layers and the value of the parameter indicating the depth of history analysis, which should be greater than 0.

```
bool CNeuronLSTM::UpdateWeights(int batch_size, TYPE learningRate, VECTOR &Beta,

                                                                   VECTOR &Lambda)

  {

//--- check the state of objects

   if(!m_cForgetGate || !m_cInputGate || !m_cOutputGate ||

      !m_cNewContent || m_iDepth <= 0)

      return false;
```

Please note the batch_size parameter. This parameter indicates the number of backpropagation iterations between weight updates. It is tracked by an external program and passed to the method in parameters. For an external program and for the neural network types considered earlier, the number of feed-forward and backpropagation passes is equal, as each feed-forward pass is followed by a backpropagation pass, in which the deviation of the estimated neural network result from the expected result is determined and the error gradient is propagated throughout the neural network. In the case of a recurrent block, the situation is slightly different: for each feed-forward pass, a recurrent block undergoes multiple iterations of backward passes, determined by the depth of the analyzed history. Consequently, we must adjust the batch size received from the external program to the depth of the historical data.

```
int batch = batch_size * m_iDepth;
```

We can then use the methods to update the weight matrix by passing them the correct data in the parameters.

```
//--- update the weight matrices of the internal layers

   if(!m_cForgetGate.UpdateWeights(batch, learningRate, Beta, Lambda))

      return false;

   if(!m_cInputGate.UpdateWeights(batch, learningRate, Beta, Lambda))

      return false;

   if(!m_cOutputGate.UpdateWeights(batch, learningRate, Beta, Lambda))

      return false;

   if(!m_cNewContent.UpdateWeights(batch, learningRate, Beta, Lambda))

      return false;

//---

   return true;

  }
```

After successfully updating the weight matrices of all internal neural layers, we exit the method with a positive result.

This concludes our review of LSTM block backpropagation methods. We can move forward in building our system.

## 4.Feed-forward method for LSTM block

As always, we will create the feed-forward algorithm in the FeedForward method. The feed-forward pass method is one of the basic methods that is defined by a virtual method in the base class and is overridden in all inherited methods.

```
class CNeuronLSTM    :  public CNeuronBase

  {

protected:

   ....

public:

   ....

   virtual bool      FeedForward(CNeuronBase *prevLayer) override;
```

The FeedForward method receives a pointer to the previous neural layer as a parameter, which contains the initial data for the method operation. It returns a logical value indicating the execution status of the method operations.

At the beginning of the method, we check the validity of pointers to all objects that are critical for the method operations. If there is at least one invalid pointer, we exit the method with the result of false.

```
bool CNeuronLSTM::FeedForward(CNeuronBase *prevLayer)

  {

--- check the relevance of all objects

   if(!prevLayer || !prevLayer.GetOutputs() || !m_cOutputs ||

      !m_cForgetGate || !m_cInputGate || !m_cOutputGate ||

      !m_cNewContent)

      return false;
```

After successfully passing through the control block, we create stubs for new memory buffers and hidden states. To do this, we use the CreateBuffer method discussed above, remembering to control the result of the operations.

```
--- prepare blanks for new buffers

   if(!m_cForgetGate.SetOutputs(CreateBuffer(m_cForgetGateOuts), false))

      return false;

   if(!m_cInputGate.SetOutputs(CreateBuffer(m_cInputGateOuts), false))

      return false;

   if(!m_cOutputGate.SetOutputs(CreateBuffer(m_cOutputGateOuts), false))

      return false;

   if(!m_cNewContent.SetOutputs(CreateBuffer(m_cNewContentOuts), false))

      return false;

   CBufferType *memory = CreateBuffer(m_cMemorys);

   if(!memory)

      return false;

   CBufferType *hidden = CreateBuffer(m_cHiddenStates);

   if(!hidden)

     {

      delete memory;

      return false;

     }
```

Next, we have to prepare the initial data for the correct operation of the internal layers. This procedure is not as simple as it may seem at first glance. The reason is that to call the feed-forward methods of our gates, we require not just a buffer but a neural layer. We cannot put a pointer to the previous layer obtained in the parameters, because it does not contain all the necessary information. It lacks the hidden state data necessary for the algorithm to function correctly. Therefore, we will need to create an empty neural layer and fill its output buffer with the necessary data.

But before creating a new neural layer, we verify the validity of the pointer to the stack storing the source data neural layers. If needed, we create a new one, as after conducting the feed-forward pass, we will need to store the created neural layer for subsequent neural network training. The check for the stack presence is performed before completing the entire loop of feed-forward operations, in order to save resources by avoiding unnecessary operations.

```
--- create a buffer for the source data

   if(!m_cInputs)

     {

      m_cInputs = new CArrayObj();

      if(!m_cInputs)

        {

         delete memory;

         delete hidden;

         return false;

        }

     }
```

Please note that before exiting the method after an unsuccessful attempt to create a new stack, we will need to delete the objects created within the method, for which pointers are not passed to the global variables of the class.

Next, we create a new instance of the base neural layer object. And, as always, we check the result of the operation.

```
CNeuronBase *inputs = new CNeuronBase();

   if(!inputs)

     {

      delete memory;

      delete hidden;

      return false;

     }
```

After successfully creating an instance of the base neural layer object, we need to create an object describing the structure of the neural layer for its initialization. That's what we'll proceed to do. We will create an instance of the CLayerDescription object and populate it with the necessary data. We will specify the type of neuron layer as defNeuronBase. The number of elements in the neural layer will be equal to the sum of the elements in the result buffers of the previous and current layers. Since we will directly populate the result buffer of the created layer from other sources, we set the window size for source data to 0.

```
CLayerDescription *desc = new CLayerDescription();

   if(!desc)

     {

      delete inputs;

      delete memory;

      delete hidden;

      return false;

     }

   desc.type = defNeuronBase;

   desc.count = (int)(prevLayer.GetOutputs().Total() + m_cOutputs.Total());

   desc.window = 0;
```

After creating the description of the neural layer, we proceed to its initialization. Upon successful completion of the operation, we delete the no-longer-needed layer description object.

```
if(!inputs.Init(desc))

     {

      delete inputs;

      delete memory;

      delete hidden;

      delete desc;

      return false;

     }

   delete desc;

   inputs.SetOpenCL(m_cOpenCL);
```

After this, we only need to fill the result buffer of the new layer with the necessary source data. To begin with, we get a pointer to the required buffer and verify its validity.

```
CBufferType *inputs_buffer = inputs.GetOutputs();

   if(!inputs_buffer)

     {

      delete inputs;

      delete memory;

      delete hidden;

      return false;

     }
```

After that, we populate the buffer with the contents of the result buffers from the previous layer and the hidden state. We have moved the functionality of data transfer to a separate Concatenate method, which we will consider later.

```
if(!inputs_buffer.Concatenate(prevLayer.GetOutputs(), hidden,

                                 prevLayer.Total(), hidden.Total()))

     {

      delete inputs;

      delete memory;

      delete hidden;

      return false;

     }
```

Now that we have completed the preparatory work, we can proceed directly to the feed-forward pass operations. We will start this process by calling the feed-forward pass methods of the internal neural layers. First, we will perform the forward pass for the forget gates. We simply call the method with the same name on the corresponding object. We will pass a pointer to the newly created instance of the neural layer for the source data as parameters to the method, and then we check the result of the operation execution.

```
--- perform a feed-forward pass of the internal neural layers

   if(!m_cForgetGate.FeedForward(inputs))

     {

      delete inputs;

      delete memory;

      delete hidden;

      return false;

     }
```

We will repeat the operation for all internal layers.

```
if(!m_cInputGate.FeedForward(inputs))

     {

      delete inputs;

      delete memory;

      delete hidden;

      return false;

     }
```

```
if(!m_cOutputGate.FeedForward(inputs))

     {

      delete inputs;

      delete memory;

      delete hidden;

      return false;

     }
```

```
if(!m_cNewContent.FeedForward(inputs))

     {

      delete inputs;

      delete memory;

      delete hidden;

      return false;

     }
```

After successfully completing the feed-forward pass of all internal neural layers, the buffer of results for each object will store prepared information about the state of all gates and the normalized data of the new content. Now all we have to do is to combine all information flows according to the algorithm of the LSTM block. Before constructing this process, we need to organize the branching of the algorithm depending on the utilized device for computational operations: CPU using standard MQL5 tools or OpenCL context.

A reasonable question may arise: why are we separating transaction threads only now? Why didn't we utilize the power of multi-threaded operations when calculating gate state and new context? But believe me, these operations also utilized the technology of multi-threaded computations offered by OpenCL, although not as explicitly. For example, in the CNeuronLSTM::SetOpenCL method, we passed a pointer to the OpenCL context to all the internal neural layers, and just a few lines above, we called the feed-forward pass methods for each internal layer. And now take a look at the forward pass method of the parent class [CNeuronBase::FeedForward](https://www.mql5.com/en/neurobook/index/realization/perceptron/pr_mql5#feedforward), there is also thread division present there.

```
bool CNeuronBase::FeedForward(CNeuronBase *prevLayer)

  {

   ....

--- Branching the algorithm by the computing device

   if(!m_cOpenCL)

     {

   ....

     }

   else

     {

   ....

     }

//---

   return false;

  }
```

In other words, we have previously used ready-made methods of the base class of neural layers with ready-made functionality in both directions. We will now introduce additional operations that are unique to the LSTM block. Therefore, we need to split the thread of operations and organize the process for both technologies. Just as when building the previous classes, we will now go through the process of constructing the algorithm in MQL5. We will delve into the actual process organization within the context of OpenCL in the next chapter.

When performing operations using MQL5, we will first obtain pointers to the data buffers with the results of internal neural layers in local variables for ease of access. Then we will use the matrix operations of MQL5.

First, we multiply element-wise the Memory state by the Forget Gate values. We then multiply the normalized matrix of new content (New Content) by the Input Gate, step by step. The result is added to the updated memory state (Memory). In conclusion, we normalize the results of the operations performed above using the hyperbolic tangent function and then element-wise multiply them with the matrix of gate results (Output Gate). The result is written to the hidden state buffer (Hidden).

```
--- branching of the algorithm by the computing device

   CBufferType *fg = m_cForgetGate.GetOutputs();

   CBufferType *ig = m_cInputGate.GetOutputs();

   CBufferType *og = m_cOutputGate.GetOutputs();

   CBufferType *nc = m_cNewContent.GetOutputs();

   if(!m_cOpenCL)

     {

      memory.m_mMatrix *= fg.m_mMatrix;

      memory.m_mMatrix += ig.m_mMatrix * nc.m_mMatrix;

      hidden.m_mMatrix = MathTanh(memory.m_mMatrix) * og.m_mMatrix;

     }
```

For the OpenCL context algorithm, we temporarily set an exit with a negative result, which will later be replaced by the correct code. This option will allow us to test the ready code and warn us about choosing an incorrect parameter.

```
else

     {

      delete inputs;

      delete memory;

      delete hidden;

      return false;

     }
```

After completing the loop that updates the full memory and hidden state of our LSTM block, we transfer the hidden state values to the result buffer.

```
--- copy the hidden state to the neural layer results buffer

   m_cOutputs = hidden;
```

This could be the end of the feed-forward pass. However, we still need to save the current state for the subsequent training of our recurrent block. First, we save the initial data to the stack. As mentioned above, we insert new objects into the stack with an index of 0.

```
--- save the current state

   if(!m_cInputs.Insert(inputs, 0))

     {

      delete inputs;

      delete memory;

      delete hidden;

      return false;

     }
```

After adding a new element, check the stack for overflow and remove excessive historical data. To perform this functionality, we create the ClearBuffer method. We will look at the algorithm of this method a little later.

```
ClearBuffer(m_cInputs);
```

Here it should be mentioned that we store the source data in the form of a neural layer. This allows us to solve two problems at once:

- The feed-forward and backpropagation methods for the base neural layer require a pointer to the previous neural layer as input. Consequently, a single object can be used for both the feed-forward and backpropagation passes without any modifications to the base neural layer.

- In one object, we store both the raw data buffer and the gradient buffer. We do not need to configure synchronization for buffer utilization.

In the remaining stacks, we will store buffers. Therefore, we will create an additional InsertBuffer method for the repetitive work of saving data to the stacks. We will take a look at the algorithm of the method a bit later, and for now, we will use it to copy information into the stacks. We will repeat the call of the specified method for each stack and the corresponding buffer.

```
if(!InsertBuffer(m_cForgetGateOuts, m_cForgetGate.GetOutputs(), false))

     {

      delete memory;

      delete hidden;

      return false;

     }
```

```
if(!InsertBuffer(m_cInputGateOuts, m_cInputGate.GetOutputs(), false))

     {

      delete memory;

      delete hidden;

      return false;

     }
```

```
if(!InsertBuffer(m_cOutputGateOuts, m_cOutputGate.GetOutputs(), false))

     {

      delete memory;

      delete hidden;

      return false;

     }
```

```
if(!InsertBuffer(m_cNewContentOuts, m_cNewContent.GetOutputs(), false))

     {

      delete memory;

      delete hidden;

      return false;

     }
```

Note that above, we saved the buffers of results from internal layers. These objects belong to the neural layer structure and will be deleted from memory together when the corresponding neural layer is deleted. Therefore, in the InsertBuffer method, we will not create a new instance of the buffer object and copy the data.

Here, it's crucial to have a clear understanding of the differences between a pointer to an object and the object itself. Every time we create an object, a certain amount of memory is allocated for it. The necessary information is recorded there. This is our object. A pointer to the object is saved to access it. It contains a reference to the memory area where the object is stored. Consequently, when accessing the object, we take the pointer, navigate to the desired memory location, and read the necessary information.

When we copy a pointer to an object, we don't create a new object, we just make a copy of the reference. Therefore, when someone makes changes to the content of the object, we will also see these changes by accessing the object through our pointer. Whether this is good or bad depends on the method of using the object. When we need synchronization of operations with an object from different sources, that's a good thing. Everyone will refer to the same object. This means there is no need to synchronize data in different storages. Moreover, a pointer requires fewer resources than creating a new object. But when we need to protect some data against changes, it is better to create a new object and copy the necessary information.

```
if(!InsertBuffer(m_cMemorys, memory, false))

     {

      delete hidden;

      return false;

     }
```

```
if(!InsertBuffer(m_cHiddenStates, hidden, false))

      return false;

//---

   return true;

  }
```

After successfully saving all the necessary information in the stack, we exit the method with a positive result.

Congratulations! We've reached the end of the forward pass method. It may not be the simplest, but I hope my comments have helped you understand its algorithm and the idea behind the process. However, we still have some open questions in the form of auxiliary methods.

As we considered the algorithm of the feed-forward pass method, we mentioned the ClearBuffer method. Here, everything is quite simple and straightforward. The method receives a pointer to the stack in the parameters. As always, at the beginning of the method, we check the validity of the received pointer. After successfully passing the pointer check, we verify the buffer size. If the size of the buffer exceeds the user-specified size, we delete the last elements. By doing so, we ensure that the buffer size fits within the specified limits. As you can see, the whole code of the method fits literally into five lines.

```
void CNeuronLSTM::ClearBuffer(CArrayObj *buffer)

  {

   if(!buffer)

      return;

   int total = buffer.Total();

   if(total > m_iDepth + 1)

      buffer.DeleteRange(m_iDepth + 1, total);

  }
```

Then we discussed the InsertBuffer method that adds a buffer to the stack. This method has three parameters, the last of which has a default value and is not mandatory to specify when calling the method:

- CArrayObj *array — a pointer to the stack for adding a buffer.

- CBufferType *element — a pointer to the buffer to be added.

- bool create_new — a logical variable indicating the need to create a duplicate buffer. By default, a duplicate buffer is created.

As a result of the operations, the method returns a boolean value indicating the status of the operations.

As always, at the beginning of the method, we check if the obtained pointers are valid. Here, there is one nuance. First, we check the pointer to the buffer to be added to the stack. With an invalid pointer, we have nothing to add to the stack. Naturally, in such a situation, we exit the method with a negative result.

However, if the pointer to the stack turns out to be invalid, we will first attempt to create a new stack. Only after an unsuccessful attempt, we will exit the method with a negative result. But if we manage to create a new stack, we will continue working in the standard mode.

```
bool CNeuronLSTM::InsertBuffer(CArrayObj *&array,

                               CBufferType *element,

                               bool create_new = true)

  {

//--- control block

   if(!element)

      return false;

   if(!array)

     {

      array = new CArrayObj();

      if(!array)

         return false;

     }
```

Next, we split the algorithm into two separate branches depending on whether a duplicate buffer needs to be created. If a duplicate buffer is needed, we first create a new instance of the buffer object and immediately check the result of the operation using the obtained pointer to the object.

```
if(create_new)

     {

      CBufferType *buffer = new CBufferType();

      if(!buffer)

         return false;
```

Then we transfer the contents of the source buffer to the new buffer. Only after that, we will add the pointer to the new buffer to the stack. Again, we add new elements to the stack with an index of 0.

```
buffer.m_mMatrix = element.m_mMatrix;

      if(!array.Insert(buffer, 0))

        {

         delete buffer;

         return false;

        }

     }
```

If we don't need to create a new instance of the buffer, then things are much simpler here. We simply add the pointer to the buffer received as a parameter to the stack.

```
else

     {

      if(!array.Insert(element, 0))

        {

         delete element;

         return false;

        }

     }
```

After adding a new element to the stack, we will check its size and remove excessive history. For this, we will use the ClearBuffer method.

```
--- remove unnecessary history from the buffer

   ClearBuffer(array);

//---

   return true;

  }
```

After the operations are complete, we exit the method with a positive result.

We have thoroughly covered the feed-forward pass algorithm and the methods involved in it. Next, let's consider the backpropagation pass.

## 4.Saving and restoring the LSTM block

We have already looked at the methods for initializing the feed-forward and backpropagation passes of an LSTM block. This is enough for small-scale experiments but not enough for industrial use. One of the key requirements of practical application is the reusability of a once-trained neural network. We learned how to build and train our neural network. We can even get the results of applying it to real data. But we cannot yet save a trained LSTM block to restore it later from previously saved data. Two methods are provided in our neural layer classes to accomplish this functionality:

- Save saves the class.

- Load restores the class functions by previously saved data.

Before we start creating methods, let's look at the class structure of our LSTM block and determine which data we need to store and which we can simply initialize with initial values.

```
class CNeuronLSTM    :  public CNeuronBase

  {

protected:

   CNeuronBase*      m_cForgetGate;

   CNeuronBase*      m_cInputGate;

   CNeuronBase*      m_cNewContent;

   CNeuronBase*      m_cOutputGate;

   CArrayObj*        m_cMemorys;

   CArrayObj*        m_cHiddenStates;

   CArrayObj*        m_cInputs;

   CArrayObj*        m_cForgetGateOuts;

   CArrayObj*        m_cInputGateOuts;

   CArrayObj*        m_cNewContentOuts;

   CArrayObj*        m_cOutputGateOuts;

   CBufferType*      m_cInputGradient;

   int               m_iDepth;

   void              ClearBuffer(CArrayObj *buffer);

   bool              InsertBuffer(CArrayObj *&array, CBufferType *element,

                                                   bool create_new = true);

   CBufferType*      CreateBuffer(CArrayObj *&array);
```

```
public:

                     CNeuronLSTM(void);

                    ~CNeuronLSTM(void);

   //---

   virtual bool      Init(const CLayerDescription *desc) override;

   virtual bool      SetOpenCL(CMyOpenCL *opencl) override;

   virtual bool      FeedForward(CNeuronBase *prevLayer) override;

   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;

   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer) override

                                                              { return true; }

   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,

                                   VECTOR &Beta, VECTOR &Lambda) override;

   //---

   virtual int       GetDepth(void)                 const { return m_iDepth; }

   //--- methods for working with files

   virtual bool      Save(const int file_handle) override;

   virtual bool      Load(const int file_handle) override;

   //--- method of object identification

   virtual int       Type(void)  override     const { return(defNeuronLSTM); }

  };
```

First of all, we understand that no constants or methods change during the class operation. Therefore, we will only store variables.

When declaring the class variables, the first variables we declared were those for storing pointers to the internal neural layers. Of course, it makes absolutely no sense to save pointers to class objects. However, we must save the contents of these objects because the trained weight matrices are stored in them.

Next, we declared pointers to stacks of chronological data. The stacks themselves, as well as their contents, are of no value to us when saving the data. Stacks are dynamic array objects that will be effortlessly recreated. Regarding their contents, the situation is as follows. For recurrent networks, the sequence of data and the absence of gaps are crucial. At the time when the data is saved, we do not understand when the data will be reused. Consequently, at the time of data loading, it is very likely that there are gaps between the current state of the analyzed system and the data at the time of saving. In such a situation, their use will not only be unhelpful but on the contrary will distort the results. Therefore, saving this data would only increase the amount of stored information without providing any benefit for later use.

The error gradient accumulation buffer m_cInputGradient is an auxiliary object for accumulating data and is overwritten with new data during each backpropagation pass. It does not contain information important for subsequent iterations and is not appropriate for saving.

The last global variable we declared is the depth of the analyzed chronological iterations: m_iDept. It is a component of the architectural block design and is to be preserved.

After defining the scale of the work, we can proceed to its execution. First, we create the CNeuronLSTM::Save method to save the data. In the parameters, the method gets the handle of the file for saving the data. However, we will not organize a control unit to check the incoming parameters as usual. Instead of that, we will pass the received parameter to a similar method in the base class, where all the necessary controls are already implemented. Besides, earlier we analyzed only the variables declared in the class of the LSTM block but did not evaluate the need to preserve the contents of the parent class. However, we did this work when creating the method of saving data of the base class. Therefore, by calling the method of the parent class, we perform both functionalities in one line of code.

```
bool CNeuronLSTM::Save(const int file_handle)

  {

//--- calling a method of the parent class

   if(!CNeuronBase::Save(file_handle))

      return false;
```

After the successful execution of the parent class method, we save the value of the depth of the analyzed chronological iterations.

```
//--- saving the constants

   if(FileWriteInteger(file_handle, m_iDepth) <= 0)

      return false;
```

After this, we only need to save the contents of the internal neural layers. For this purpose, we will also utilize the functionality of the underlying neural layer. We just need to call the save method for each of our internal layers, providing the file handle for writing data that we received as a parameter from the external program. At the same time, we will not forget to control the process of operations at each step.

```
//--- call the same method for all inner layers

   if(!m_cForgetGate.Save(file_handle))

      return false;

   if(!m_cInputGate.Save(file_handle))

      return false;

   if(!m_cOutputGate.Save(file_handle))

      return false;

   if(!m_cNewContent.Save(file_handle))

      return false;

//---

   return true;

  }
```

After successful completion of all operations, we will exit the method with a positive result.

Now I suggest looking at the whole code of the data-saving method again and evaluating how concise and readable it is. This effect is achieved through the use of object-oriented programming (OOP). Creating classes significantly reduces code and speeds up the work of the programmer, while using ready-made and tested libraries helps avoid many errors. Believe me, no matter how complex creating our library might seem, using it will make it easy and without significant effort for the programmer to create their own neural networks. Moreover, you don't need to be a highly qualified programmer to do it.

But I digress. We have created a method to save the data. Now, we need to build the process of restoring the functionality of our recurrent block from the saved data.

The data loading method CNeuronLSTM::Load is constructed in clear correspondence with the data saving method. The saved data must be loaded from the file in the same sequence, otherwise, we could encounter distorted data or loading errors.

In the parameters, the method gets the handle of the data file to load. Just like when saving data, instead of setting up a control block, we call the method of the parent class. It already implements all the necessary controls and data loading of the parent class.

```
bool CNeuronLSTM::Load(const int file_handle)

  {

//--- call a method of the parent class

   if(!CNeuronBase::Load(file_handle))

      return false;
```

Next, we load the depth of the analyzed chronological iterations and the contents of the internal neural layers from the file. We will also use the methods of the neural layer base class to perform the latter operations. And, as always, we will check the results of the operations.

But here, we need to pay attention to one significant detail. The method for saving the base neural layer [CNeuronBase::Save](https://www.mql5.com/en/neurobook/index/realization/perceptron/pr_mql5#save) begins with writing the type of object to be saved. We read its value in the neural network loading dispatcher method to determine the type of object to be created. Hence, in the neural layer loading method, we start reading the file from the next element. In this case, to maintain the sequence of loading data from the file, we must first read the type of the next neural layer and only then call the loading method of the corresponding internal neural layer. Besides, this can be an additional point of control for loading the correct type of internal neural layer.

```
//--- read the constants

   m_iDepth = FileReadInteger(file_handle);

//--- call the same method for all inner layers

   if(FileReadInteger(file_handle) != defNeuronBase ||

      !m_cForgetGate.Load(file_handle))

      return false;

   if(FileReadInteger(file_handle) != defNeuronBase ||

      !m_cInputGate.Load(file_handle))

      return false;

   if(FileReadInteger(file_handle) != defNeuronBase ||

      !m_cOutputGate.Load(file_handle))

      return false;

   if(FileReadInteger(file_handle) != defNeuronBase ||

      !m_cNewContent.Load(file_handle))

      return false;
```

After loading the data from the file, we need to initialize the remaining objects with the initial values. First, we initialize the memory stack and add a buffer with initial values to it. To do this, we will use the CreateBuffer method we already know. I'd like to remind you that this method only creates a buffer with zero values for an empty stack. Otherwise, the method will return the last buffer written. Therefore, before calling the method, we check the size of the stack: if the stack contains data, we clear the stack and set all buffer values to zero.

```
//--- initialize Memory

   if(m_cMemorys.Total() > 0)

      m_cMemorys.Clear();

   CBufferType *buffer =  CreateBuffer(m_cMemorys);

   if(!buffer)

      return false;

   if(!m_cMemorys.Add(buffer))

      return false;
```

After all operations are completed, we will add the newly created buffer to the stack. Then we will repeat the same operations for the stack and the hidden state buffer.

```
//--- initialize HiddenStates

   if(m_cHiddenStates.Total() > 0)

      m_cHiddenStates.Clear();

   buffer =  CreateBuffer(m_cHiddenStates);

   if(!buffer)

      return false;

   if(!m_cHiddenStates.Add(buffer))

      return false;
```

We built the forward pass method in such a way that it is not critical for us to create and initialize the other stacks now. However, we acknowledge that the data loading operation might be performed on a working neural network, where the stacks already hold some information. In such cases, using data from stacks created with different weights would be incorrect. Therefore, we will clear all previously created stacks.

```
//--- clear the rest of the stacks

   if(!m_cInputs)

      m_cInputs.Clear();

   if(!m_cForgetGateOuts)

      m_cForgetGateOuts.Clear();

   if(!m_cInputGateOuts)

      m_cInputGateOuts.Clear();

   if(!m_cNewContentOuts)

      m_cNewContentOuts.Clear();

   if(!m_cOutputGateOuts)

      m_cOutputGateOuts.Clear();

//---

   return true;

  }
```

Once all operations of the method have been successfully executed, we terminate the method with a positive result.

At this point, we complete the construction of recurrent LSTM block by means of MQL5 and move on to complementing the methods of our class with the ability to perform multi-threaded operations.
