# Chapter 02: Basic Principles of Artificial Intelligence

*Source: [https://www.mql5.com/en/neurobook/index/about_ai](https://www.mql5.com/en/neurobook/index/about_ai)*

---

## Basic principles of artificial intelligence construction

Knowledge of the world and oneself in it is an integral part of human existence. Reflections on the nature of consciousness have long been raised by philosophers. Neurophysiologists and psychologists have developed theories about the principles and mechanisms of the human brain operation. As in several other sciences, processes observed in nature laid the foundation for the creation of intelligent machines.

The main structural unit in the human brain is the neuron. The exact number of neurons in the human nervous system is not definitively known, while estimates suggest approximately 100 billion. Neurons, each consisting of a cell body, dendrites and axon, connect with each other forming a complex network. The points at which the connect are called synapses.

The described processes and structures served as the basis for the creation of artificial neural networks. In 1943, Warren McCulloch and Walter Pitts published the article [A logical calculus of the ideas immanent in nervous activity](https://raai.org/library/books/mcculloch/mcculloch.pdf), in which they proposed and described two theories of neural networks: with loops and without them. These theories represented a significant step in understanding the interaction of neurons and later formed the basis for the principles of constructing neuron interactions in artificial neural networks. Donald Hebb's book [The organization of behavior: A neuropsychological theory](https://www.researchgate.net/publication/340474253_Donald_O_Hebb_and_the_Organization_of_Behavior_17_years_in_the_writing)released in 1949 laid the foundation for neural learning.

The works mentioned above explored the processes in the human brain and were further developed in the works of Frank Rosenblatt. His mathematical model of the perceptron developed in 1957 formed the basis of the world's first neurocomputer "Mark-1", which he created in 1960. It should be noted that various versions of the perceptron are successfully used today to solve various tasks.

But let's proceed systematically. In this chapter, we will examine the mathematical models of the neuron and the perceptron:

- [Neuron and principles of neural network construction](https://www.mql5.com/en/neurobook/index/about_ai/neuron). This section elaborates on the structure of the neuron and the fundamental concepts underlying artificial neural networks, as well as their importance in understanding intelligent systems.

- [Activation functions](https://www.mql5.com/en/neurobook/index/about_ai/activation) are an integral part of neural networks, determining how a neuron should respond to incoming signals. This section focuses on the different types of activation functions and their role in the neural network learning process.

- [Weight initialization methods in neural networks](https://www.mql5.com/en/neurobook/index/about_ai/initialization). Weight initialization is a critical step in preparing the network for training, influencing its ability to learn and converge.

- [Neural network training](https://www.mql5.com/en/neurobook/index/about_ai/study) is considered through the key components: loss functions, gradient backpropagation, and optimization methods which together form the basis for efficient network training.

- [Techniques for improving the convergence of neural networks](https://www.mql5.com/en/neurobook/index/about_ai/improvement), such as Dropout and normalization, detail strategies for improving neural network performance and stability during training.

- [Artificial intelligence in trading](https://www.mql5.com/en/neurobook/index/about_ai/ai_in_trading) covers the practical application of the technologies discussed, exploring how artificial intelligence and machine learning can be used to analyze financial markets and make trading decisions.

Thus, the chapter provides a comprehensive overview of artificial intelligence and neural networks, covering their structure, mechanisms, and real-world applications, particularly in algorithmic trading.

## Activation functions

Perhaps one of the most challenging tasks faced by a neural network architect is the choice of the neuron activation function. After all, it is the activation function that creates the nonlinearity in the neural network. To a large extent, the neural network training process and the final result as a whole depend on the choice of the activation function.

There is a whole range of activation functions, and each of them has its advantages and disadvantages. I suggest that we review and discuss some of them in order to learn how to properly utilize their merits and address or accept their shortcomings.

#### Threshold (Step) activation function

The step activation function was probably one of the first to be applied. This is not surprising, as it mimics the action of a biological neuron:

- Only two states are possible (activated or not).

- The neuron is activated when the threshold value θ is reached.

Mathematically, this activation function can be expressed by with the following formula:

If θ=0, the function has the following graph.

Threshold (step) activation function

This activation function is easy to understand, but its main drawback is the complexity or even the impossibility of training the neural network. The fact is that neural network training algorithms use the first-order derivative. However, the derivative of the function under consideration is always zero, except for x=θ (it is not defined at this point).

It is quite easy to implement this function in the form of MQL5 program code. The theta constant defines the level at which the neuron will be activated. When calling the activation function, we pass the pre-calculated weighted sum of the initial data in the parameters. Inside the function, we compare the value obtained in the parameters with theta activation level and return the activation value of the neuron.

```
const double theta = 0;

//–––

double ActStep(double x)

  {

   return (x >= theta ? 1 : 0);

  }
```

The Python implementation is also quite straightforward.

```
theta = 0

def ActStep (x):

  return 1 if x >= theta else 0
```

#### Linear activation function

The linear activation function is defined by a linear function:

Where:

- a defines the angle of inclination of the line.

- b is the vertical displacement of the line.

As a special case of the linear activation function, if a=1 and b=0, the function has the form .

The function can generate values in the range from  to  and is differentiable. The derivative of the function is constant and equal to a, which facilitates the process of training the neural network. The mentioned properties allow for the widespread use of this activation function when solving regression problems.

It should be noted that computing the weighted sum of neuron inputs is a linear function. The application of a linear activation function gives a linear function of the entire neuron and neural network. This property prevents the use of the linear activation function for solving nonlinear problems.

At the same time, by creating nonlinearity in the hidden layers of the neural network by using other activation functions, we can use the linear activation function in the output layer neurons of our model. Such a technique can be used to solve nonlinear regression problems.

Graph of a linear function

The implementation of the linear activation function in the MQL5 program code requires the creation of two constants: a and b. Similarly to the implementation of the previous activation function, when calling the function, we will pass the pre-calculated weighted sum of inputs in the parameters. Inside the function, the implementation of the calculation part fits into one line.

```
const double a = 1.0;

const double b = 0.0;

//–––

double ActLinear(double x)

  {

   return (a * x + b);

  }
```

In Python, the implementation is similar.

```
a = 1.0

b = 0.0

def ActLinear (x):

  return a * x + b
```

#### Logistic activation function (Sigmoid) [#](#sigmoid)

The logistic activation function is probably the most common S-shaped function. The values of the function range from 0 to 1, and they are asymmetrical relative to the point [0, 0.5]. The graph of the function resembles a threshold function, but with a smooth transition between states.

The mathematical formula of the function is as follows:

This function allows the normalization of the output values of the function in the range [0, 1]. Due to this property, the use of the logistic function introduces the concept of probability into the practice of neural networks. This property is widely used in the output layer neurons when solving classification problems, where the number of output layer neurons equals the number of classes, and an object is assigned to a particular class based on the highest probability (maximum value of the output neuron).

The function is differentiable over the entire interval of permitted values. The value of the derivative can be easily calculated through the function value using the formula:

Graph of the logistic function (Sigmoid)

Sometimes a slightly modified logistic function can be used in neural networks:

Where:

- a stretches the range of function values from 0 to a.

- b, similarly to a linear function, shifts the resulting value.

The derivative of such a function is also calculated through the value of the function using the formula:

In practice, the most common applications are , so that the graph of the function is asymmetric with respect to the origin.

All of the above properties add to the popularity to using the logistic function as a neuron activation function.

However, this function also has its flaws. For input values less than −6 and greater than 6, the function value is pressed to the limits of the range of function values, and the derivative tends to zero. As a consequence, the error gradient also tends to zero. This leads to a decrease in the training rate of the neural network, and sometimes even makes the network nearly untrainable.

Below I propose to consider the implementation of the most general version of the logistic function with two constants a and b. Let's calculate the exponent using exp().

```
const double a = 1.0;

const double b = 0.0;

//–––

double ActSigmoid(double x)

  {

   return (a / (1 + exp(-x)) - b);

  }
```

When implementing in Python, before using the exponent function, you must import the math library, which contains the basic math functions. The rest of the algorithm and the function implementation are similar to the implementation in MQL5.

```
import math

a = 1.0

b = 0.0

def ActSigmoid (x):

  return a / (1 + math.exp(-x)) - b
```

#### Hyperbolic tangent (tanh) [#](#tanh)

An alternative to the logistic activation function is the hyperbolic tangent (Tanh). Just like the logistic function, it has an S-shaped graph, and the function values are normalized. But they belong to the range from −1 to 1, and the the neuron state is changed out 2 times faster. The graph of the function is also asymmetric, but unlike the logistic function, the center of asymmetry is at the center of coordinates.

The function is differentiable on the entire interval of permitted values. The derivative value can be easily calculated through the function value using the formula:

The hyperbolic tangent function is an alternative to the logistic function, which quite often converges faster.

Graph of the hyperbolic tangent function (TANH)

 

But it also has the main drawback of the logistic function: during saturation of the function, when the function values approach the boundaries of the value range, the derivative of the function approaches zero. As a result, the gradient of the error tends to zero.

The hyperbolic tangent function is already implemented in the programming languages we use, and it can be called by simply calling the tanh() function.

```
double ActTanh(double x)

  {

   return tanh(x);

  }
```

The implementation in Python is similar.

```
import math

def ActTanh (x):

  return math.tanh(x)
```

#### Rectified line unit (ReLU) [#](#relu)

Another widely used activation function for neurons is ReLU (rectified linear unit). When the input values are greater than zero, the function returns the same value, similar to a linear activation function. For values less than or equal to zero, the function always returns 0. Mathematically, this function is expressed by the following formula:

The graph of the function is something between a threshold function and a linear function.

Graph of the ReLU function

 

ReLU, probably, is one of the most common activation functions at the moment. It has become so popular due to its properties:

- Like the threshold function, it operates based on the principle of a biological neuron, activating only after reaching a threshold value (0). Unlike the threshold function, when activated, the neuron returns a variable value rather than a constant.

- The range of values is from 0 to , which allows us to use the function in solving regression problems.

- When the function value is greater than zero, its derivative is equal to one.

- The function calculation does not require complex computations, which accelerates the training process.

The literature provides examples where neural networks with ReLU are trained up to 6 times faster than networks using TANH.

However, the use of ReLU also has its drawbacks. When the weighted sum of the inputs is less than zero, the derivative of the function is zero. In such a case, the neuron is not trained and does not transmit the error gradient to the preceding layers of the neural network. In the process of training there is a probability to get such a set of weights that the neuron will be deactivated during the whole training cycle. This effect has been called "dead neurons".

Subjectively, the presence of dead neurons can be detected by observing the increase in the learning rate: the more the learning rate accelerates with each iteration, the more dead neurons the network contains.

Several variations of this function have been proposed to minimize the effect of dead neurons when using ReLU, but they all boil down to one thing: applying a certain coefficient a for a weighted sum less than zero.

The classical version of ReLU is conveniently realized using the max() function. Implementing its variations will require the creation of a constant or variable a. The initialization approach will depend on the chosen function (LReLU / PReLU / RReLU). Inside our activation function, we will create logical branching, depending on the value of the received parameter.

```
const double a = 0.01;

//–––

double ActPReLU(double x)

  {

   return (x >= 0 ? x : a * x);

  }
```

In Python, the implementation is similar.

```
a = 0.01

def ActPReLU (x):

  return x if x >= 0 else a * x
```

#### Softmax [#](#softmax)

While the previously mentioned functions were calculated solely for individual neurons, the Softmax function is applied to all neurons of a specific layer in a network, typically the last layer. Similar to sigmoid, this function uses the concept of probability in neural networks. The range of values of the function lies between 0 and 1, and the sum of all output values of neurons of the taken layer is equal to 1.

The mathematical formula of the function is as follows:

The function is differentiable over the entire interval of values, and its derivative can be easily calculated through the value of the function:

The function is widely used in the last layer of the neural network in classification tasks. The output value of the neuron normalized by the Softmax function is said to indicate the probability of assigning the object to the corresponding class of the classifier.

It is worth noting that Softmax is computationally intensive, which is why its application is justified in the last layer of neural networks used for multi-class classification.

The implementation of the Softmax function in MQL5 will be slightly more complicated than the examples discussed above. This is due to the processing of the neurons of the entire layer. Consequently, the function will receive a whole array of data in its parameters rather than a single value.

It should be noted that arrays in MQL5, unlike variables, are passed to function parameters by pointers to memory elements rather than by values.

Our function will take pointers to two data arrays X and Y as parameters and return a logical result at the end of the operations. The actual results of the operations will be in the array Y.

In the function body, we first check the size of the source data array X. The resulting array must be of non-zero length. We then resize the array to record the Y results. If any of the operations fails, we exit the function with the result false.

```
bool SoftMax(double& X[], double& Y[])

  {

   uint total = X.Size();

   if(total == 0)

      return false;

   if(ArrayResize(Y, total) <= 0)

      return false;
```

Next, we organize two loops. In the first one, we calculate exponents for each element of the obtained data set and summarize the obtained values.

```
//--- Calculation of exponent for each element of the array

   double sum = 0;

   for(uint i = 0; i < total; i++)

      sum += Y[i] = exp(X[i]);
```

In the second loop, we normalize the values of the array created in the first loop. Before exiting the function, we return the obtained values.

```
//--- Normalization of data in an array

   for(uint i = 0; i < total; i++)

      Y[i] /= sum;

//---

   return true;

  }
```

In Python, the implementation looks much simpler since the Softmax function is already implemented in the Scipy library.

```
from scipy.special import softmax

def ActSoftMax (X):

  return softmax(X)
```

#### Swish [#](#swish)

In October 2017, a team of researchers from Google Brain worked on the automatic search for activation features. They presented the results in the article "[Searching for Activation Functions](https://arxiv.org/abs/1710.05941)". The article summarizes the results of testing a range of features against ReLU. The best performance was achieved in neural networks with the Swish activation feature. The replacing of ReLU with Swish (without retraining) improved the performance of the neural networks.

Graph of the Swish function

The mathematical formula of the function is as follows:

The parameter β affects the nonlinearity of the function and can be taken as a constant during network design, or can be selected during training. When β=0, the function reduces to a linearly scaled function.

When β=1, the graph of the Swish function approaches ReLU. But unlike the latter, the function is differentiable over the entire range of values.

A function is differentiable and its derivative is calculated through the value of the function. But unlike the sigmoid, it also requires an input value to calculate the derivative. The mathematical formula for the derivative is of the form:

The implementation of the function in the MQL5 program code is similar to the Sigmoid presented above. The parameter a is replaced by the obtained value of the weighted sum and the nonlinearity parameter β is added.  

```
const double b=1.0;

//–––

double ActSwish(double x)

  {

   return (x / (1 + exp(-b * x)));

  }
```

The implementation in Python is similar.

```
import math

b=1.0

def ActSwish (x):

  return x / (1 + math.exp(-b * x))
```

It is worth noting that this is by no means a complete list of possible activation functions. There are different variations to the functions mentioned above, as well as different functions can be utilized altogether. Activation functions and threshold values should be selected by the architect of the neural network. It is not always the case that all neurons in a network have the same activation function. Neural networks in which the activation function varies from layer to layer are widely used in practice. Such networks are called heterogeneous networks.

Later we will see that, for implementing neural networks, it is much more convenient to utilize vector and matrix operations, which are provided in MQL5. This in particular concerns activation functions, because matrix and vector operations provide the Activation function which calculate activation functions for the whole data array with one line of code. In our case, the function would be calculated for the entire neural layer. The implementation of the function is as follows.

```
bool vector::Activation(

  vector&                   vect_out,      // vector to get values

  ENUM_ACTIVATION_FUNCTION  activation     // function type

   );

bool matrix::Activation(

  matrix&                   matrix_out,    // matrix to get values

  ENUM_ACTIVATION_FUNCTION  activation     // function type

   );
```

In its parameters, the function receives a pointer to a vector or matrix (depending on the data source) for storing results, along with the type of activation function used. It should be noted that the range of activation functions in MQL5 vector/matrix operations is much wider than described above. Their complete list is given in the table.

Identifier

Description

AF_ELU

Exponential linear unit

AF_EXP

Exponential

AF_GELU

Linear unit of Gauss error

AF_HARD_SIGMOID

Rigid sigmoid

AF_LINEAR

Linear

AF_LRELU

Leaky linear rectifier (Leaky ReLU)

AF_RELU

Truncated linear transformation ReLU

AF_SELU

Scaled exponential linear function (Scaled ELU)

AF_SIGMOID

Sigmoid

AF_SOFTMAX

Softmax

AF_SOFTPLUS

Softplus

AF_SOFTSIGN

Softsign

AF_SWISH

Swish function

AF_TANH

Hyperbolic tangent

AF_TRELU

Linear rectifier with threshold

## Artificial intelligence in trading

Previous sections introduced the basic principles and algorithms for building neural networks. However, our primary interest lies in the practical application of the presented technologies, and, I am certainly not the first to consider it.

Computer technologies have long been integrated and successfully applied in trading. It's difficult to imagine trading without the use of computer technologies nowadays. Primarily, thanks to the internet and computers, traders no longer need to be physically present on the trading floor. The trading terminal software can be easily installed on any computer and even on mobile devices (smartphones, tablets). This enables traders to analyze the market and execute trading operations from virtually any location on our planet.

The aforementioned trading terminals not only facilitate trade execution but also provide all the necessary tools for detailed real-time market analysis. They include features for constructing graphical objects on price charts and a variety of indicators that can dynamically update values and display them on the chart according to the current market situation.

Another direction of applying computer technologies in trading is algorithmic trading. Algorithmic trading involves creating computer programs (robots) that execute trading operations without human intervention, following a predefined trading strategy. This method has its own advantages and disadvantages compared to manual human trading.

A created program can work tirelessly 24 hours a day, 7 days a week, which is impossible for a human. Accordingly, the program will not miss any signal to enter or exit a position. The robot will strictly follow the specified algorithm. In contrast, a human, while evaluating the market situation, may consider personal past experiences and subjective feelings, which can vary.

First and foremost, deviating from the trading strategy disrupts the balance between profitable and losing trades, and over a long time frame, it's likely to have a negative impact on the trading account balance.

On the other hand, it can be quite challenging to precisely describe all aspects of a trading strategy in mathematical terms. In this case, the trader's personal experience and their personal feeling of the market will play a significant role. The program does not have these features, and the tolerances built in by the programmer may not be ideal.

Among the benefits of algorithmic trading, we can also include the absence of psychological factors in programs. Meanwhile, the psychological barrier often causes traders, especially newcomers, to deviate from their trading strategies.

On the other hand, time series are variable. Therefore, any trading strategy has a limited lifespan. As a consequence, over time, there's a need to adapt trading systems to current market conditions, and a classical robot can't evaluate its performance or make changes to its trading algorithm or parameters without human assistance.

So what do we expect from the application of artificial intelligence and neural networks in particular?

When building a mathematical model using a neural network, we do not prescribe the entire trading algorithm, as in classical algorithmic trading. We simply provide a training dataset and let the neural network itself discover patterns and correlations between the input data and the final outcome. In doing so, we expect the neural network to capture not only the obvious patterns but also the subtle fluctuations that can enhance the effectiveness of the trading system.

When creating a training dataset for the neural network, we should not limit ourselves to the input data of a single strategy. There may be much more input data than a human is capable of processing. However, the final mathematical model might produce signals that don't fit neatly into any of the expected strategies. As a result, we expect to obtain performance higher than that of robots built according to the classical algorithmic trading scheme.

And, of course, the learning ability of neural networks enables the creation of methods for assessing the performance of a strategy and initiating the training process of the neural network in a timely manner for adaptation to current market conditions.

Thus, we anticipate a reduction in the negative aspects of algorithmic trading while retaining its positive aspects.

## Techniques for improving the convergence of neural networks

In the previous chapters of the book, we have learned the basic principles of building and training neural networks. However, we also have identified certain challenges that arise during the training process of neural networks. We have encountered local minimums that can stop training earlier than we achieve the desired results. We also discussed issues of vanishing and exploding gradients and touched upon the problems of co-adaptation of neurons, retraining, and many others which we'll discuss later.

On the path of human progress, we continually strive to refine tools and technologies. This applies to the algorithms of training neural networks as well. Let's discuss methods that, if not completely solve certain issues in neural network training, at least aim to minimize their impact on the final learning outcome.

## Weight initialization methods in neural networks

When creating a neural network, before its first training run, we need to somehow set the initial weight. This seemingly simple task is of great importance for the subsequent training of the neural network and, in general, has a significant impact on the result of the entire work.

The fact is that the gradient descent method, which is most often used for training neural networks, cannot distinguish the local minima of a function from its global minimum. In practice, various solutions are applied to minimize this problem, and we will talk about them a bit later. However, the question remains open.

The second point is that the gradient descent method is an iterative process. Therefore, the total training time for a neural network directly depends on how far from the endpoint we are at the beginning.

Moreover, let's not forget about the laws of mathematics and the peculiarities of the activation functions that we discussed in the previous section of this book.

#### Initializing weights with a single value

Probably the first thing that comes to mind is to take a certain constant (0 or 1) and initialize all weights with a single value. Unfortunately, this is far from the best option, which is related to the laws of mathematics.

Using zero as a synaptic coefficient is often fatal to neural networks. In this case, the weighted sum of the input data would be zero. As we know from the previous section, many versions of the activation function in such a case return 0, and the neuron remains deactivated. Consequently, no signal goes further down the neural network.

The derivative of such a function with respect to x i will be zero. Consequently, during the training of the neural network, the error gradient through such a neuron will also not be passed to the preceding layers, paralyzing the training process.

Using 0 for the initialization of synaptic (weight) coefficients results in an untrainable neural network, which in most cases will generate 0 (depending on the activation function) regardless of the input data received.

Using a constant other than zero as a weighting factor also has disadvantages. The input layer of the neural network is supplied with a set of initial data. All neurons of the subsequent layer work with this dataset in the same way. Within the framework of a single neuron, according to the laws of mathematics, the constant can be factored out in the formula for calculating the weighted sum. As a result, in the first stage, we get a scaling of the sum of the initial values. Changes in weights are possible during training. However, this only applies to the first layer of neurons receiving the initial data.

If you look at the neural layer as a whole. Then all neurons in the same layer receive the same dataset. By using the same coefficient, all neurons generate the same signal. As a consequence, all neurons of one layer work synchronously as one neuron. This, in turn, leads to the same value being present at all inputs of all neurons of the subsequent layer. This happens from layer to layer throughout the neural network.

The applied learning algorithms do not allow the isolation of an individual neuron among a large number of identical values. Therefore, all weights will be changed synchronously during the training process. Each layer, except for the first one after the input, will receive its weights, uniform for the entire layer. This results in the linear scaling of the results obtained on the same neuron.

Initializing the synaptic coefficients with a single number other than zero causes the neural network to degenerate down to one neuron.

#### Initializing weights with random values [#](#random)

Since we cannot initialize a neural network with a single number, lets try initializing with random values. For maximum efficiency, let's not forget about what was mentioned above. We need to make sure that no two synaptic coefficients are the same. This will be facilitated by a continuous uniform distribution.

As practice has shown, such an approach yields results. Unfortunately, this is not always the case. Due to the random selection of weights, it is sometimes necessary to initialize the neural network several times before the desired result is achieved. The range of variation in the weights has a significant impact. If the gap between the minimum and maximum is large enough, some neurons will be isolated and others completely ignored.

Moreover, in deep neural networks, there is a risk of the so-called "gradient explosion" and "gradient vanishing".

The gradient explosion manifests itself when using weights greater than one. In this case, when the initial data is multiplied by factors greater than one, the weighted sum increases continuously and exponentially with each layer. At the same time, generating a large number at the output often leads to a large error.

During the training process, we will use an error gradient to adjust the weights. In order to pass the error gradient from the output layer to each neuron of our network, we need to multiply the obtained error by the weights. As a result, the error gradient, just like the weighted sum, will grow exponentially as it progresses through the layers of the neural network.

As a consequence, at some point, we will get a number that exceeds our technical capabilities for recording values, and we won't be able to further train and use the network.

The opposite situation occurs if we choose weight values close to zero. Constantly multiplying the initial data by weights less than one reduces the weighted sum of weight values. This process progresses exponentially with the increase in the number of layers of the neural network.

As a consequence, during the training process, we may encounter a situation where the gradient of a small error, when passing through layers, becomes smaller than the technically feasible precision. For our neurons, the error gradient will become zero, and they will not learn.

At the time of writing the book, the common practice is to initialize neurons using the Xavier method, proposed in 2010. Xavier Glorot and Yoshua Bengio proposed initializing the neural network with random numbers from a continuous normal distribution centered at point 0 and with a variance (δ2) equal to 1/n.

This approach enables the generating of synaptic coefficients such that the average of the neuron activations will be zero, and their variance will be the same for all layers of the neural network. Xavier initialization is most relevant when using hyperbolic tangent (tanh) as an activation function.

The theoretical justification for this approach was given in the article "[Understanding the difficulty of training deep feedforward neural networks](https://proceedings.mlr.press/v9/glorot10a/glorot10a.pdf?hc_location=ufi)".

Xavier initialization gives good results when using sigmoid activation functions. But when ReLU is used as an activation function, it is not as efficient. This is due to the characteristics of the ReLU itself.

Since ReLU only misses positive weighted sum values, and negative ones are zeroed, the probability theory states that half the neurons will be deactivated most of the time. Consequently, the neurons of the subsequent layer will receive only half of the information, and the weighted sum of their inputs will be less. As the number of layers in the neural network increases, this effect will intensify: fewer and fewer neurons will reach the threshold value, and more and more information will be lost as it passes through the neural network.

A solution was proposed by Kaiming He in February 2015 in the article "[Surpassing Human-Level Performance on ImageNet Classification](https://arxiv.org/pdf/1502.01852.pdf%20Delving%20Deep%20into%20Rectifiers:)". In the article, it's suggested to initialize the weights for neurons with ReLU activation from a continuous normal distribution with a variance (δ2) equal to 2/n. And when using PReLU as activation, the distribution variance should be 2/((1+a2) *n). This method of initializing synaptic scales is called He-initialization.

#### Initializing with a random orthogonal matrix

In December 2013, Andrew M. Saxe presented a three-layer neural network in the form of matrix multiplication in the article "[Exact solutions to the nonlinear dynamics of learning in deep linear neural networks](https://arxiv.org/pdf/1312.6120v3.pdf)", thereby showing the correspondence between the neural network and singular decomposition. The synaptic weight matrix of the first layer is represented by an orthogonal matrix, the vectors of which are the coordinates of the initial data in some n-dimensional space.

Since the vectors of an orthogonal matrix are orthonormalized, the initial data projections they generate are completely independent. This approach allows for the neural network to be pre-prepared in such a way that each neuron will learn to recognize its feature in the input data independently of the training of other neurons located in the same layer.

However, the method is not used widely, primarily due to the complexity of generating orthogonal matrices. The advantages of the method are demonstrated with the growth of the number of layers of the neural network. Therefore, in practice, initialization with orthogonal matrices can be found in deep neural networks when initialization with random values does not yield results.

#### Using pre-trained neural networks

This method can hardly be referred to as initialization, but its practical application is becoming increasingly popular. The essence of the method is as follows: to solve the problem, use a neural network that was trained on the same or similar data but solves different tasks. A series of lower layers are taken from a pre-trained neural network. These layers have already been trained to extract features from the initial data. Then, a few new layers of neurons are added, which will solve the given task based on the already extracted features.

In the first step, pre-trained layers are blocked and new layers are trained. If the training fails to produce the desired result, the learning block is removed from the borrowed neural layers and the neural network is retrained.

A variation of this method is the approach of first creating a multilayer neural network and training it to extract different features from the initial data. These can be unsupervised learning algorithms for dividing data into classes or autoencoder algorithms. In the latter, the neural network first extracts features from the initial data and then tries to return the original data based on the selected features.

After pre-training, the layers of neurons responsible for feature extraction are taken, and additional layers of neurons for solving the given task are added to them.

When constructing deep networks, this approach can help train the neural network faster compared to training a large neural network directly. This is because, during one training pass, a smaller neural network requires fewer operations to be performed compared to training a deep neural network. In addition, smaller neural networks are less prone to the risk of gradient explosion or vanishing.

In the practical part of the book, we will return to the process of initializing neural networks and in practice evaluate the advantages and disadvantages of each method.

## Neuron and principles of building neural networks

In their paper entitled "[A logical calculus of the ideas immanent in nervous activity](https://www.cs.cmu.edu/~./epxing/Class/10715/reading/McCulloch.and.Pitts.pdf)", Warren McCulloch and Walter Pitts proposed a mathematical model of a neuron and described the basic principles of neural network organization. The mathematical model of an artificial neuron involves two computation stages. Similar to a human neuron, in the mathematical model of an artificial neuron, the dendrites are represented by a vector of numerical values X, which is input into the artificial neuron. The dependence of the neuron value on each specific input is determined by the vector of weights, denoted as W. The first computation stage of the artificial neuron model is implemented as the product of the vector of initial signals by the vector of weights, which gives a weighted sum of initial data from the mathematical point of view.

where:

- n = number of elements in the input sequence

- wi = weight of the ith element of the sequence

- xi = the ith element of the input sequence

The weights determine the sensitivity of the neuron to changes in a particular input value and can be either positive or negative. This way, the operation of excitatory and inhibitory signals is simulated. The values of weights satisfying the solution of a particular problem are selected in the process of training the neural network.

As mentioned before, a signal appears on the axon of a neuron only after a critical value has accumulated in the cell body. In the mathematical model of an artificial neuron, this step is implemented by introducing an activation function.

Variations are possible here. The first models used a simple function to compare the weighted sum of input values with a certain threshold value. Such an approach simulated the nature of a biological neuron, which can be excited or at rest. The graph of such a neuron activation function will have a sharp drop in value at the threshold point.

Graph of the threshold function of neuron activation.

In 1960, Bernard Widrow and Marcian Hoff published their work "[Adaptive switching circuits](https://www-isl.stanford.edu/~widrow/papers/c1960adaptiveswitching.pdf)", in which they presented the Adaline adaptive linear classification machine. This work has shown that using continuous neuron activation functions allows solving a wider range of problems with less error. Since then and up to our time, various sigmoid functions have been widely used as neuron activation functions. In this version, a smoother graph of the mathematical model of the neuron is obtained.

Graph of the logistic function (Sigmoid)

We will discuss different versions of activation functions and their advantages and disadvantages in the next chapter of the book. In a general form, the mathematical model of an artificial neuron can be schematically represented as follows.

Scheme of the mathematical model of a neuron

This mathematical model of a neuron allows generating a logical True or False answer based on the analysis of input data. Let's consider the model's operation using the example of searching for the candlestick pattern "Pin Bar".

According to the classic Pin Bar model, the size of the candlestick "Nose" should be at least 2.5 times the size of the body and the second tail. Mathematically, it can be visualized as follows:

or

Pin Bar

According to the mathematical model of the neuron, we will input three values into the neuron: the size of the candlestick nose, body, and tail. The weights will be 1, -2.5, and -2.5, respectively. It should be noted that we will not consider weights when constructing the neural network. They will be selected during the training process.

The activation function will be a logical comparison of the weighted sum with zero. If the weighted sum of input values is greater than zero, the candlestick pattern is found and the neuron is activated. The output of the neuron is 1. If the weighted sum is less than zero, then the pattern is not found. The neuron remains deactivated and the output of the neuron is 0.

Now we have a neuron that will respond to the Pin Bar candlestick pattern. However, note that in a bullish pattern, the nose will be the lower tail, and in a bearish one, it will be the upper tail. That is, if we input a vector of values containing the upper tail, body, and lower tail of a candlestick, we need two neurons to define the pattern: one will define a bullish pattern and the other a bearish pattern.

Does this mean we will need to create a program for each pattern separately? No. We will combine them into a single neural network model.

In a neural network, all neurons are grouped into sequential layers. According to their location and purpose, neural layers are categorized into input, hidden, and output layers. There is always one input and one output layer, but the number of hidden layers can vary, depending on the complexity of the task at hand.

The number of neurons in the input layer corresponds to the number of inputs, which is three in our example: upper tail, body, and lower tail.

The hidden layer in our case consists of two neurons that define a bullish and a bearish pattern. The number of hidden layers and neurons in them is set during the design of the neural network and is determined by its architect depending on the complexity of the problem to be solved.

The number of hidden layers determines how the input data space is divided into subclasses. A neural network with a single hidden layer divides the input data space by a hyperplane. The presence of two hidden layers allows the formation of a convex region in the input data space. The third hidden layer allows the formation of almost any region in space.

The number of neurons in the hidden layer is determined by the number of sought-after features at each level.

The number of neurons in the output layer is determined by the neural network architect depending on the possible solution variants for the given task. For binary and regression problems, a single neuron may be sufficient. For classification tasks, the number of neurons will correspond to a finite number of classes.

An exception is a binary classification, where all objects are divided into two classes. In this case, one neuron is sufficient, since the probability of assigning an object to the second class P2 is equal to the difference between one and the probability of assigning an object to the first class P1.

In our example, the output layer will contain only one neuron, which will give the result: whether to open a trade or not, and in which direction. For this, we will assign a weight of 1 to the bullish pattern, and a weight of -1 to the bearish pattern. As a result, the buy signal will be 1, while the sell signal will be -1. Zero will mean there is no trading signal.

Perceptron model

Such a neural network model was proposed by Frank Rosenblatt in 1957 and was named Perceptron. This model is one of the first artificial neural network models. It is capable of establishing associative connections between input data and the resulting action. In real life, it can be compared to a person's reaction to a traffic light signal.

Of course, the perceptron is not without flaws; there are a number of limitations in its use. However, over the years of research, good results have been achieved in using the perceptron for classification and approximation tasks. Moreover, mechanisms for training the perceptron have been developed, which we will discuss shortly.

## Neural network training

We have already learned about the structure of an artificial neuron, the organization of data exchange between neurons, and the principles of neural network construction. We also learned how to initialize synaptic coefficients. The next step is to train the neural network.

Tom Mitchell proposed the following definition of machine learning:

"A computer program is said to learn from experience E with respect to some class of tasks T and performance measure P, if its performance at tasks T, as measured by P, improves with experience E."

Usually, three main approaches to neural network training are distinguished:

- Supervised learning

- Unsupervised learning

- Reinforcement learning

Algorithms of supervised learning in practice produce the best results, but they require a lot of preparatory work. The very principle of supervised learning implies that there are correct answers. As a supervisor, at each iteration of learning, we will guide the neural network by showing it the correct results, thereby encouraging the neural network to memorize what is true and what is false.

In this approach, correlation links between the raw data and the correct answers are set up within the neural network. Ideally, a neural network should learn to extract essential features from the set of initial data. By generalizing the set of extracted features, it should determine the object's affiliation to a particular class (classification tasks) or indicate the most probable course of events (regression tasks).

The complexity of this approach lies in the need for extensive preparatory work. This approach requires mapping the correct answers to each set of initial data from the training sample. It is not always possible to automate this work, and human resources have to be involved. At the same time, using manpower to prepare the training set and correct answers increases the risk of errors in the sample and, as a result, improper configuration of the neural network.

Another risk of this approach is the overfitting of the neural network. This phenomenon usually occurs when training deep networks on a small set of input data. In such a case, the neural network is able to "memorize" all pairs of initial data sets with correct answers. In doing so, it will lose any ability to generalize the data. As a result, we will get a neural network with excellent results on the training data set and completely random answers on the test sample and when using it on real data.

The risk of neural network overfitting can be reduced by using various regularization, normalization, and dropout methods which we will discuss later.

Also, note that we can encounter a task where there is no clear correct answer for the presented data sets. In such cases, other approaches to training neural networks are used.

Unsupervised learning is used when there are no correct answers for the training sample. Unsupervised learning algorithms allow for the extraction of individual features of the original data objects. Comparing the extracted features, the algorithms cluster the original data, grouping the most similar objects into certain classes. The number of such classes is specified in the hyperparameters of the neural network.

Cost saving during the preparation stage comes at the expense of object recognition quality and a more limited range of solvable tasks.

With the growth of the volume of initial data for training, unsupervised learning algorithms are widely used for the preliminary training of neural networks Initially, a neural network is created and trained unsupervised on a large dataset. This allows us to train the neural network to extract individual features from the initial data set and to partition a large amount of data into separate classes of objects.

Then, decision-making neural layers (most often fully connected perceptron neural layers) are added to the pre-trained network, and the neural network is further trained using supervised learning algorithms.

This approach allows training the neural network on a large volume of initial data, which helps minimize the risk of overfitting the neural network. At the same time, since training on the primary dataset occurs unsupervised, we can further train the deep neural network on a relatively small set of paired original data with correct answers. This reduces the resources required for preparatory work during supervised training.

A separate approach to neural network training can be called reinforcement learning. This approach is used to solve optimization problems that require constructing a strategy. The best results are demonstrated when training neural networks with computer and logic games, for which this method was developed. It is applicable for long finite processes, when throughout the process the neural network needs to make a series of decisions based on the state of the environment, and the cumulative result of the decisions taken will only be clear at the end of the process. For example, winning or losing a game.

The essence of the method is to assign some sort of reward or penalty for each action. During the training process, the strategy with the maximum reward is determined.

In this book, more attention will be given to supervised learning, which in practice shows the best training results and is applicable for solving regression tasks, including time series forecasting.

## Batch normalization

The practical application of neural networks implies the use of various approaches to data normalization. All of these approaches aim to maintain the training data and the output of hidden layers of the neural network within a specified range and with certain statistical characteristics of the dataset, such as variance and median. Why is this so important? We remember that network neurons apply linear transformations which shift the sample towards the anti-gradient in the learning process.

Consider a fully connected perceptron with two hidden layers. In the forward pass, each layer generates a set of data that serves as a training sample for the next layer. The output layer's results are compared with the reference data, and during the backward pass, the error gradient is propagated from the output layer through hidden layers to the input data.

Perceptron with two hidden layers

Having obtained the error gradient for each neuron, we update the weights, tuning our neural network to the training samples from the last forward pass. Here arises a conflict: we are adjusting the second hidden layer (labeled as 'Bull pattern' and 'Bear pattern' in the above diagram) to the output data of the first hidden layer (labeled as 'Hidden pattern' in the diagram). However, by changing the parameters of the first hidden layer, we have already altered the data array. In other words, we are adjusting the second hidden layer to a data sample that no longer exists.

The situation is similar to the output layer, which adjusts to the already modified output of the second hidden layer. If we also consider the distortion between the first and second hidden layers, the scales of error amplification increase. The deeper the neural network, the stronger the manifestation of this effect. This phenomenon is referred to as internal covariate shift.

In classical neural networks, this problem was partially solved by reducing the learning rate. Small changes in the weights do not significantly alter the distribution of the output of the neural layer. However, this approach does not solve the problem of scaling with an increase in the number of layers of the neural network and reduces the learning rate. Another issue with a low learning rate is the potential stop at local minima (we already discussed this issue in the section about[neural network optimization methods](https://www.mql5.com/en/neurobook/index/about_ai/study/optimization)).

Here, it's also worth mentioning the necessity of normalizing the input data. Quite often, when solving various tasks, diverse input data is fed into the input layer of a neural network, which might belong to samples with different distributions. Some inputs can have values that significantly exceed the magnitudes of the others. Such values will have a greater impact on the final result of the neural network. At the same time, the actual impact of the described factor might be significantly lower, while the absolute values of the sample are determined by the nature of the metric.

The below chart shows an example illustrating the reflection of a single price movement using two oscillators (MACD and RSI). When considering the indicator charts, you can notice the correlation of the curves. At the same time, the numerical values of the indicators differ by hundreds of thousands of times. This is because RSI values are normalized on a scale from 0 to 100, while MACD values depend on the accuracy of price representation on the graph, as MACD shows the distance between two moving averages.

When building a trading strategy, we can utilize either of these indicators individually or consider the values of both indicators and execute trading operations only when the signals from the indicators align. In practice, this approach enables the exclusion of some false signals, which eventually can reduce the drawdown of the trading strategy. However, before we input such diverse signals into the neural network, it's advisable to normalize them to a comparable form. This is what the normalization of the initial data will help us to achieve.

Of course, we can perform the normalization of the input data while preparing the training and testing datasets outside the neural network. But this approach increases the preparatory work. Moreover, during practical usage of such a neural network, we will need to consistently prepare the input data using a similar algorithm. It is much more convenient to assign this work to the neural network itself.

In February 2015, Sergey Ioffe and Christian Szegedy proposed the [Batch Normalization](https://arxiv.org/abs/1502.03167) method in their work "Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift". The method was proposed to address the issue of internal covariate shift. This algorithm can also be applied for normalizing input data.

EURUSD H1

The essence of the method was to normalize each individual neuron over a certain time interval by shifting the median of the sample to zero and scaling the sample's variance to one.

The normalization algorithm is as follows. First, the average value is calculated from the data sample.

Where :

- μ B = the arithmetic mean of the feature over the sample

- m = the sample size (batch)

Then we calculate the variance of the original sample.

We normalize the sample data by reducing the sample to zero mean and unit variance.

Note that a small positive constant ε is added to the denominator of the sample variance to prevent division by zero.

As it turned out, such normalization can distort the influence of the input data. This is why the authors of the method added one more step: scaling and offset. They introduced the variables γ and β, which are trained together with the neural network using the gradient descent method.

Applying this method allows obtaining a dataset with a consistent distribution at each training step, which in practice makes the training of the neural network more stable and enables an increase in the learning rate. Overall, this enhances the training quality while reducing the time required for neural network training.

However, at the same time, the cost of storing additional coefficients increases. Furthermore, calculating the moving average and variance requires storing in memory the historical data of each neuron for the entire batch size. An alternative here could be the use of Exponential Moving Average (EMA): calculating the EMA only requires the previous value of the function and the current element of the sequence.

Experiments conducted by the authors of the method demonstrate that the application of Batch Normalization also serves as a form of regularization. This allows for the elimination of other regularization methods, including the previously discussed Dropout. Moreover, there are more recent works showing that the combined use of Dropout and Batch Normalization has a negative effect on the training results of a neural network.

In modern architectures of neural networks, the proposed normalization algorithm can be found in various shapes. The authors suggest using Batch Normalization directly before the non-linearity (activation function). One of the variations of this algorithm is [Layer Normalization](https://arxiv.org/abs/1607.06450), introduced by Jimmy Lei Ba, Jamie Ryan Kiros, and Geoffrey E. Hinton in July 2016 in their work "Layer Normalization."

## Dropout

We continue studying methods for improving the convergence of neural networks. Lets consider the dropout technology.

When training a neural network, a large number of features are fed into each neuron, the influence of each of which is difficult to assess. As a result, errors of some neurons are smoothed out by the correct values of others, and errors accumulate at the output of the neural network. Training stops at a certain local minimum with a sufficiently large error that does not meet our requirements. This effect was called co-adaptation of features, in which the influence of each feature seemingly adjusts to the surrounding environment. It would be better for us to get the opposite effect when the environment is decomposed into individual features and evaluate separately the impact of each of them.

To combat complex co-adaptation of features, in July 2012, a group of scientists from the University of Toronto, in a paper "[Improving neural networks by preventing co-adaptation of feature detectors](https://arxiv.org/abs/1207.0580)", proposed randomly excluding some neurons during the training process. Reducing the number of features during training increases the significance of each one, and the constant change in the quantitative and qualitative composition of features reduces the risk of their co-adaptation. Such a method is called Dropout.

Applying this method can be compared to decision trees because by excluding some neurons at random, we get a new neural network with its own weights at each training iteration. According to the rules of combinatorics, the variability of such networks is quite high.

At the same time, all the features and neurons are evaluated during the operation of the neural network. Thereby, we obtain the most accurate and independent assessment of the current state of the studied environment.

The authors of the solution in their paper point out that the method can also be used to improve the quality of pre-trained models.

Dropout implementation model for a perceptron with two hidden layers

Describing the proposed solution from a mathematical point of view, we can say that each individual neuron is excluded from the process with a certain given probability P. Thus, the the neuron will participate in the neural network training process with a probability of q=1—P.

To determine the list of excluded neurons, the method uses a pseudorandom number generator with a normal distribution. This approach allows for the most uniform possible exclusion of neurons. In practice, we will generate a vector of binary features of size equal to the input sequence. In the vector, we will set 1 for the features that are used and 0 for the excluded elements.

However, the exclusion of the analyzed features undoubtedly leads to a decrease in the sum at the input of the neuron activation function. To compensate for this effect, we multiply the value of each feature by a factor of 1/q. It's easy to notice that this coefficient will increase the values, as the probability q is always in the range from 0 to 1.

Where:

- Di = elements of the Dropout results vector

- q = probability of using a neuron during the learning process

- mi = the element of the masking vector

- xi = the elements of the input sequence vector

During the backward pass in the training process, the error gradient is multiplied by the derivative of the aforementioned function. As can be easily seen, in the case of Dropout, the backward pass will be similar to the forward pass which uses the masking vector from the forward pass.

During the operation of the neural network, the masking vector is filled with units, allowing values to be transmitted seamlessly in both directions.

In practice, the coefficient 1/q is constant throughout training, so we can easily count this coefficient once and write it instead of units in the masking tensor. In this way, we eliminate the operations of recalculating the coefficient and multiplying it by 1 of the mask in each training iteration.

## Regularization

In the pursuit of minimized neural network error, we often complicate our model. What a disappointment it can be when, after prolonged and meticulous work, we achieve an acceptable training set error, only to find the model's error soaring during testing. Such a situation is quite common and is known as 'model overfitting'.

The reasons for this phenomenon are quite mundane and are related to the imperfections, or more precisely, the complexity of our world. Both the raw data and the benchmark results for the training and test datasets were obtained not under controlled laboratory conditions but were taken from real life. Hence, in addition to the analyzed features, they include a number of unaccounted factors, which we attributed to the so-called noise at the design stage for various reasons.

During the training process, we expect that the model will extract significant features from the given volume of raw data and establish relationships between these features and the expected outcome. However, due to the excessive complexity of the model, it can discover relationships between random variables that don't actually exist. It ends up "memorizing" the training dataset. As a result, we get an error close to zero on the training sample. In this process, the test dataset contains its own random noise deviations that don't fit into the concept learned from the training dataset. This confuses our model. As a result, we get a striking difference in the error of the neural network on the training and test samples.

The regularization methods discussed in this section are designed to exclude or minimize the influence of random noise and emphasize the regular features during the model training process. In the practice of training neural networks, you most commonly encounter the use of two methods: L1 and L2 regularizations. Both of them are built on the addition of the sum of weight norms to the loss function.

#### L1-regularization

L1-regularization is often referred to as lasso regression or Manhattan regression. The essence of this method lies in adding the sum of absolute values of weights to the loss function.

Where:

- LL1(Y,Y',W) = loss function with L1-regularization

- L(Y,Y') = one of the [loss functions](https://www.mql5.com/en/neurobook/index/about_ai/study/loss) discussed earlier

- λ = regularization coefficient (penalty)

- wi = ith weighting coefficient

In the process of training the neural network, we will minimize our loss function. In this case, the minimization of the loss function depends directly on the sum of the absolute weight values. Thus, in our model training, we introduce an additional constraint of selecting weights as close to zero as possible.

The partial derivative of such a loss function will take the form:

Here, we don't explicitly calculate the derivative of the loss function itself to isolate the influence of regularization directly.

The function sign(wi) returns the sign of the weight when it is non-zero and 0 when the weight is zero. Since λ is a constant, and we consistently subtract the value of the derivative multiplied by the learning rate and the error gradient when updating the weights, then, when training the neural network, the model will set features that do not have a direct impact on the outcome to zero. This will completely eliminate the influence of random noise on the result.

L1 regularization introduces a penalty for large weights, thus enabling the selection of important features and mitigating the influence of random noise on the final outcome.

L2-regularization

L2, or ridge, regularization, like L1 regularization, introduces a large weighting penalty into the loss function. However, in this case, the L2 norm is used, which is the sum of the squares of the weights. As a result, the loss function will have the following form.

Similar to L1-regularization, we add a constraint to the model training process to use weighting coefficients as close to zero as possible. Let's look at the derivative of our loss function.

In the L2-regularization derivative formula, the penalty λ is multiplied by the weight. This implies that during training, the penalty is not constant but dynamic. It decreases proportionally as the weight decreases. In this process, each weight receives an individual penalty based on its magnitude. Hence, unlike L1 regularization, during the training of the neural network, the weights of the features that do not have a direct impact on the outcome will decrease. However, they will never reach zero, unless calculation precision limits allow for it.

L2 regularization introduces a penalty for large weights, thus enhancing the influence of important features and reducing, though not eliminating, the impact of random noise on the final outcome.

#### Elastic Net

As mentioned above, L1-regularization simplifies the model by zeroing out the weights for parameters that do not directly affect the expected outcome of the model. Applying such an approach is justified when we are reasonably confident about the presence of a small number of redundant features, the exclusion of which can only improve the model performance.

If, however, we understand that the overall result is a combination of small contributions from all the features used and the exclusion of any feature would worsen the model performance, then in such a scenario, using L2 regularization is justified.

But which of the methods to use when our model receives an obviously excessive number of features? Moreover, we do not understand the individual impact of features on the outcome. Perhaps excluding certain features could simplify our model and improve its performance. At the same time, excluding other features would have a negative impact on the model's performance.

At such times, Elastic Net regularization is applied. This model adds penalties based on both the L1 and L2 norms of weights to the loss function, combining the advantages of L1 and L2 regularization.

Please note that in the Elastic Net formula, L1 and L2 regularization each have their own regularization coefficients. Thus, by changing the regularization coefficients λ1 and λ2, the regularization model can be controlled. By setting them both to zero, we achieve model optimization without regularization. When λ1>0 and λ2=0 we have pure L1 regularization, and when λ1=0 and λ2>0 we get L2-regularization.

## Methods for optimizing neural networks

We continue to move forward in studying the basic principles of neural network training. In previous chapters, we have already discussed various [loss functions](https://www.mql5.com/en/neurobook/index/about_ai/study/loss) and the [error gradient backpropagation algorithm](https://www.mql5.com/en/neurobook/index/about_ai/study/back_propagation), which allows us to determine the influence of each neuron on the overall result and the direction of change in the output value of each neuron to minimize the overall error at the output.

Below is the formula of the mathematical model of a neuron.

Where:

- f = activation function

- n = number of elements in the input sequence

- wi = weight of the ith element of the sequence

- xi = ith element of the input sequence

#### Gradient descent and stochastic gradient descent [#](#sgd)

In the above formula, you can see that the output value of the neuron depends on the activation function, the input sequence, and the weight vector. The activation formula is set during the construction of the neural network and remains unchanged. The neuron does not affect the input sequence. Therefore, in the learning process, we can change the value at the output of the neuron only by choosing the optimal values of the weights.

The rate of change of the neuron's output value when changing a particular weight is equal to the partial derivative of the neuron's mathematical model function with respect to that weight. From this, to get the delta change of a particular weight, you need to multiply the error at the neuron's output in the current situation by the partial derivative of the neuron's mathematical model with respect to that weight.

It should be noted that the function of the mathematical model of a neuron most often is non-linear. Therefore, the partial derivative is not constant over the entire permitted range of values. Therefore, the "learning coefficient" parameter is introduced into the formula for updating the weights, which determines the learning rate.

The approach described above is called gradient descent. In general, it can be expressed by the formula:

where:

- wjil = lth weight on the ith neuron of the jth layer

- α = learning coefficient that determines the learning rate

- gradij = gradient at the output of the ith neuron of the jth layer

The training coefficient α is a hyperparameter that is selected during the neural network validation process. It is selected from the range 0 to 1. In this case, the training coefficient cannot be equal to the extreme values.

When α=0, there will be no learning, because by multiplying any gradient by zero, we always get zero for updating the weights.

When α=1 or close to this value, there is another problem. If, when moving towards the error minimum, the value of the partial derivative decreases, then using a sufficiently large step will throw us past the minimum point. In the worst case, the error at the output of the neural network will even increase. Moreover, a large learning coefficient promotes maximum adaptation of the network to the current situation. In this case, the ability to generalize is lost. Such training will not be able to identify key features and adequately work "in the field."

The method works well with small neural networks and datasets. But neural networks are getting bigger, and training sets are growing. To make one training iteration, you need to perform a forward pass through the entire dataset and save information about the state of all neurons for all samples as this information will be needed for the backward pass. Consequently, we will need additional memory allocation in the amount of the number of neurons * the number of data sets.

The solution was found in the use of stochastic gradient descent. The method retains the algorithm of standard gradient descent, but the weights are updated for each randomly selected data set.

On each iteration, we randomly select one data set from the training sample. Then we perform a forward and backward pass and update the weights. After that, we "shuffle" the training sample and select the next data set randomly.

We repeat the iterations until we achieve an acceptable error in the neural network output.

Stochastic gradient descent has lower convergence compared to standard gradient descent. Furthermore, more iterations are usually required to achieve an acceptable error. But in stochastic gradient descent, a single iteration takes less time, since it is carried out on a randomly chosen data set, rather than on the entire sample, as in standard gradient descent. In general, the process of training a neural network is carried out with less time and resource costs.

Below is an example of implementing a function to update weights using the gradient descent method. In parameters, the function receives two pointers to data arrays (current weights and gradients to them) and a training coefficient. First, we check the correspondence of the sizes of the arrays. Then, we organize a loop where for each element of the weight array, we calculate a new value using the formula mentioned above. The obtained value is saved in the corresponding cell of the array.

```
bool SGDUpdate(double &m_cWeights[],

               double &m_cGradients[],

               double learningRate)

  {

   if(m_cWeights.Size() > m_cGradients.Size()  ||

      m_cWeights.Size()<= 0)

      return false;

//---

   for(int i = 0; i < m_cWeights.Size(); i++)

      m_cWeights[i] -= learningRate * m_cGradients[i];

   return true;

  }
```

#### Momentum accumulation method  [#](#momentum)

Probably, the main drawback of gradient descent methods is the inability to distinguish between local and global minima. During the training process, there is always a high risk of stopping at a local minimum without reaching the desired accuracy level of the neural network.

Careful selection of the learning coefficient, experiments with different weight initialization options, and several training iterations do not always yield the desired results.

Local minima on the graph of a complex function

One of the solutions was borrowed from the physics of natural phenomena. If you put the ball in a small depression or hole, then it will lie motionless at its bottom. But as soon as we send the same ball along some inclined surface into this hole, it will easily jump out of it and roll further. This behavior of the ball is explained by the momentum accumulated during the descent along the inclined surface.

Similar to the ball, it was suggested to accumulate momentum during the training of the weights, and then add this momentum to the weight update formula using the gradient descent method.

Momentum accumulates for each individual weight. When updating a specific weight for a prolonged period in one direction, its momentum will accumulate, and as a result, it will move towards the desired goal at a faster pace. Thanks to the accumulated energy, we can overcome local minima, similar to a ball rolled down an inclined surface.

Unfortunately, there is also a flip side to the coin. By accumulating momentum, we will skip not only the local minimum but also the global one. With unlimited momentum accumulation, the value of our error will move like a pendulum on the loss function graph. Let's mimic the force of friction in nature and add the β coefficient in the range from 0 to 1 (excluding the boundary points), which will serve the role of frictional force. This coefficient characterizes the rate of momentum attenuation. The closer β is to 1, the longer the momentum is maintained.

All of the above can be written in the form of two mathematical formulas:

where:

- Δt = change in the weight at the current step

- Δt–1 = change in the weight at the previous training iteration

- β = pulse damping factor

As a result, we got a decent algorithm for dealing with local minima. Unfortunately, it is not a panacea. To overcome the local minimum, you need to accumulate enough momentum. To do this, the initialization must be at a sufficient distance from the local minimum. When solving practical problems, we do not know where the local and global minima actually are. And the initialization of weights in a random way can throw us anywhere.

Moreover, the application of this method requires additional memory to store the last momentum of each neuron and extra computational effort for the added calculations.

Still, the momentum accumulation method is used in practice and demonstrates better convergence compared to stochastic gradient descent.

When implementing the momentum accumulation method, we will need to add a decay coefficient to the function parameters and another array to store the accumulated momentum for each weight. The logic of building the function remains the same: first, we check the correctness of the input data, and then in a loop, we update the weights. When updating the weights, as in the provided formulas, we first calculate the change in the synaptic coefficient taking into account the accumulated momentum, and then its new value. The obtained values are stored in the corresponding cells of the arrays for weights and momentum values.

```
bool MomentumUpdate(double &m_cWeights[],

                    double &m_cGradients[],

                    double &m_cMomentum[],

                    double learningRate,

                    double beta)

  {

   if(m_cWeights.Size() > m_cGradients.Size() ||

      m_cWeights.Size() > m_cMomentum.Size()  ||

      m_cWeights.Size() <= 0)

      return false;
```

```
//---

   for(int i = 0; i < m_cWeights.Size(); i++)

     {

      m_cMomenum[i] = learningRate * m_cGradients[i] +

                     beta * m_cMomenum[i];

      m_cWeights[i] -= m_cMomenum[i];

     }

   return true;

  }
```

#### Adaptive gradient method (AdaGrad) [#](#adagrad)

Both methods discussed above have a learning rate hyperparameter. It is important to understand that the entire process of neural network training largely depends on the choice of this parameter. Setting the learning rate too high can cause the error to continually increase instead of decreasing. Using a low learning rate will lead to an extended duration of the training process and increase the likelihood of getting stuck in a local minimum, even when using the momentum accumulation method.

Therefore, when validating the architecture of a neural network, a lot of time is devoted specifically to selecting the correct learning rate coefficient. Furthermore, it is always difficult to select the right learning rate. Moreover, one always wants to train a neural network with minimal time and resource expenditures.

There is a practice of gradually decreasing the learning rate during the training process. The network training process starts with a relatively high rate, which allows for a rapid descent to a certain error level. After reducing the learning rate, a more refined adjustment of the neural network weights is carried out to reduce the overall error. There can be several iterations with a reduced coefficient, but with each reduction of the weight, the effectiveness of that iteration decreases.

Note that we use one learning rate for all neural layers and neurons. However, not all features and neurons contribute equally to the final result of the neural network, so our learning rate should be quite versatile.

I think it goes without saying that universality is the enemy of the best: to create any universal product or select a value (as in our case), we need to compromise to meet all the requirements as best as possible, while these requirements are often contradictory.

One might think, in such a case, it would be advisable to offer individual learning rates for neurons. But to solve this problem manually is virtually impossible. In 2011, the AdaGrad adaptive gradient method was proposed. The proposed method is a variation of the gradient descent discussed above and does not exclude the use of the learning rate coefficient. At the same time, the authors of the method suggest accumulating the sum of the squares of the gradients for all previous iterations and, when updating the weights, dividing the learning coefficient by the square root of the accumulated sum of the squared gradients.

Where:

- Gt , Gt–1 = sum of the squares of the gradients at the current and previous steps, respectively

- ε = a small positive number to avoid division by zero

In this way, we obtain an individual and constantly decreasing learning rate coefficient for each neuron. However, this requires additional computational resources and extra memory to store the sums of squared gradients.

The implementation function for the AdaGrad method is very similar to the function of updating the weights using the cumulative momentum method. In it, we abandon the use of the decay coefficient but still use the momentum array, in which we will accumulate the sum of squared gradients. The changes also affected the calculation of the new weight value. The complete function code is shown below.

```
bool AdaGradUpdate(double &m_cWeights[],

                   double &m_cGradients[],

                   double &m_cMomentum[],

                   double learningRate)

  {

   if(m_cWeights.Size() > m_cGradients.Size() ||

      m_cWeights.Sizel() > m_cMomentum.Size()  ||

      m_cWeights.Size() <= 0)

      return false;
```

```
//---

   for(int i = 0; i < m_cWeights.Size(); i++)

     {

      double G = m_cMomenum[i] + MathPow(m_cGradients[i], 2);

      m_cWeights[i] -= learningRate / (MathSqrt(G) + 1.0e-10) *

                 m_cGradients[i];

      m_cMomentum[i] = G;

     }

   return true;

  }
```

In the above formula, you can notice the main problem of this method. We continuously accumulate the sum of squared gradients. As a consequence, on a sufficiently long training sample, our learning rates will quickly tend to zero. This will lead to the paralysis of the neural network and the impossibility of further training.

A solution was proposed in the RMSProp method.

#### RMSProp method [#](#rmsprop)

The RMSProp weight update method is a logical extension of the AdaGrad method. It retains the idea of automatically adjusting the learning rate based on the frequency of updates and the magnitude of gradients coming to the neuron. However, it addresses the main issue of the previously discussed method — the paralysis of training on large training datasets.

Like AdaGrad, the RMSProp method exploits the sum of squared gradients, but in RMSProp, an exponentially smoothed average of squared gradients is used.

Where:

- REMS(G)t and REMS(G)t–1 = exponential average of the squares of the gradients at the current and previous iteration

- γ = exponential smoothing factor

The use of an exponentially smoothed average of squared gradients prevents the learning rate of neurons from decreasing to zero. At the same time, each weight will receive an individual learning rate, depending on the incoming gradients. As the gradients increase, the learning rate will gradually decrease, and as the gradients decrease, the learning rate coefficient will increase. This will allow in the first case to limit the maximum learning rate, and in the second case, to update the coefficients even with small error gradients.

It should be noted that the use of the squared gradient allows this method to work even when the neuron receives gradients of different directions. If we skip over the minimum because of the high learning rate during the training process and move in the opposite direction on the next iteration, the accumulated square of gradients will gradually decrease the learning rate, thereby allowing us to descend closer to the minimum error.

The implementation of this approach almost completely repeats the implementation of the adaptive gradient method. We will simply replace the calculation of the sum of squared gradients with their exponential average. To do this, we need an additional parameter γ.

```
bool RMSPropUpdate(double &m_cWeights[],

                   double &m_cGradients[],

                   double &m_cMomentum[],

                   double learningRate,

                   double gamma)

  {

   if(m_cWeights.Size() > m_cGradients.Size() ||

      m_cWeights.Size() > m_cMomentum.Size()  ||

      m_cWeights.Size() <= 0)

      return false;
```

```
//---

   for(int i = 0; i < m_cWeights.Size(); i++)

     {

      double R = (1-gamma) * m_cMomenum[i] +

                 gamma * MathPow(m_cGradients[i], 2);

      m_cWeights[i] -= learningRate / (MathSqrt(R) + 1.0e-10) *

                 m_cGradients[i];

      m_cMomentum[i] = R;

     }

   return true;

  }
```

#### Adadelta method [#](#adadelta)

In the AdaGrad and RMSProp methods, we gave an individual learning rate to each neuron, but still left the learning rate hyperparameter in the numerator of the formula. The creators of the Adadelta method went a little further and proposed to completely abandon this hyperparameter. In the mathematical formula of the Adadelta method, it is replaced by the exponential average of changes in weights over the previous iterations.

Where:

- REMS(δw)t , REMS(δw)t–1 = exponential average of squared changes in weights for the current and previous iterations

In the practical application of this method, you may encounter cases where both the coefficients for the exponential smoothing of squared weight deltas and gradients are the same, as well as cases where they are individual. The decision is made by the neural network architect.

Below is an example of the implementation of the method using MQL5 tools. The logic behind constructing the algorithm fully replicates the functions presented above. The changes only affected the calculations that are peculiar to the method: the abandonment of the learning rate and the introduction of an additional averaging coefficient, along with another array of data.

```
bool AdadeltaUpdate(double &m_cWeights[],

                   double &m_cGradients[],

                   double &m_cMomentumW[],

                   double &m_cMomentumG[],

                   double gammaW, double gammaG)

  {

   if(m_cWeights.Size() > m_cGradients.Size() ||

      m_cWeights.Size() > m_cMomentumW.Size() ||

      m_cWeights.Size() > m_cMomentumG.Size()  ||

      m_cWeights.Size() <= 0)

      return false;
```

```
//---

   for(int i = 0; i < m_cWeights.Size(); i++)

     {

      double W = (1-gammaW) * m_cMomenumW[i] +

                 gammaW * MathPow(m_cWeights[i], 2);

      double G = (1-gammaG) * m_cMomenumG[i] +

                 gammaG * MathPow(m_cGradients[i], 2);

      m_cWeights.At(i) -= MathSqrt(W) / (MathSqrt(G) + 1.0e-10) *

                 m_cGradients[i];

      m_cMomentumW[i] = W;

      m_cMomentumG[i] = G;

     }

   return true;

  }
```

#### Adaptive moment estimation method [#](#adam)

In 2014, Diederik P. Kingma and Jimmy Lei Ba proposed Adam's adaptive moment assessment method. According to the authors, the method combines the advantages of the AdaGrad and RMSProp methods and works well in online learning. This method consistently demonstrates good results on various datasets and is currently recommended as the default choice in various packages.

The method is based on the calculation of the exponential average of the gradient m and the exponential average of the squares of the gradient v. Each exponential average has its own hyperparameter ß, which determines the averaging period.

The authors suggest using the default ß1 at the level of 0.9, and ß2 at the level of 0.999. In this case, m0 and v0 take zero values. With the parameters of the formulas presented above, at the beginning of training, they return values close to zero. As a consequence, we get a low learning rate at the initial stage. To speed up learning, the authors proposed to correct the obtained moments.

The updating of parameters is carried out by adjusting them based on the ratio of the corrected gradient moment m to the square root of the corrected gradient moment v. To eliminate division by zero, the ε constant close to zero is added to the denominator. The resulting ratio is corrected by the learning factor α, which in this case is the upper limit of the learning step. By default, the authors suggest using α at the level of 0.001.

The implementation of the Adam method is a little more complicated than the ones presented above, but in general it follows the same logic. Changes are visible only in the body of the weight update loop.

```
bool AdamUpdate(double &m_cWeights[],

                double &m_cGradients[],

                double &m_cMomentumM[],

                double &m_cMomentumV[],

                double learningRate,

                double beta1, double beta2)

  {

//---

   if(m_cWeights.Size() > m_cGradients.Size() ||

      m_cWeights.Size() > m_cMomentumM.Size() ||

      m_cWeights.Size() > m_cMomentumV.Size()  ||

      m_cWeights.Size() <= 0)

      return false;

//---

   for(int i = 0; i < m_cWeights.Size(); i++)

     {

      double w = m_cWeights[i];

      double delta = m_cGradients[i];

      double M = beta1 * m_cMomenumM[i] + (1 - beta1) * delta;

      double V = beta2 * m_cMomenumV[i] + (1 - beta2) * MathPow(delta, 2);

      double m = M / (1 - beta1);

      double v = V / (1 - beta2);
```

```
w -= learningRate * m / (MathSqrt(v) + 1.0e-10);

      m_cWeights[i] = w;

      m_cMomenumM[i] = M;

      m_cMomenumV[i] = V;

     }

//---

   return true;

  }
```

## Error gradient backpropagation method

Once we have defined the loss function, we can move on to training the neural network. The actual learning process involves iteratively adjusting the neural network parameters (synaptic weights) at which the value of the neural network [loss function](https://www.mql5.com/en/neurobook/index/about_ai/study/loss) will be minimized.

From the previous section, we learned that the loss function is concave downward. Therefore, when starting the training from any point on the loss function graph, we should move in the direction of minimizing the error. For complex functions like a neural network, the most convenient method is the gradient descent algorithm.

The gradient of a multi-variable function (which a neural network is) is defined as a vector composed of the partial derivatives of the function with respect to its arguments. From our mathematics course, we know that the derivative of a function characterizes the rate of change of the function at a given point.

Hence, the gradient indicates the direction of the fastest growth of the function. Moving in the direction of the negative gradient (opposite to the gradient), we will descend at the maximum speed towards the minimum of the function.

The algorithm of action will be as follows:

- Initialize the weights of the neural network using one of the ways described [earlier](https://www.mql5.com/en/neurobook/index/about_ai/initialization).

- Compute the predicted data on the training sample.

- Using the [loss function](https://www.mql5.com/en/neurobook/index/about_ai/study/loss), calculate the computational error of the neural network.

- Determine the gradient of the loss function at the obtained point.

- Adjust the synaptic coefficients of the neural network towards the negative gradient.

Gradient descent

Since a nonlinear loss function is used often, the direction of the anti-gradient vector will change at each point on the loss function graph. Therefore, we will reduce the loss function gradually, getting closer and closer to the minimum with each iteration.

At first glance, the algorithm is quite simple and logical. But how do we technically implement point 5 of our algorithm in the case of a multilayer neural network?

This issue is addressed using the backpropagation algorithm, which consists of two main components:

- Forward pass. Point 2 from our algorithm above. During the forward pass, a set of data from the training sample is fed to the input of the neural network and processed in the neural network sequentially from the input layer to the output layer. The intermediate values on each neuron are preserved.

Forward pass of the neural network

- The backward pass includes steps 3-5 of our algorithm.

At this point, it's worth recalling some mathematics. We talk about partial derivatives of a function, but we also want to train a neural network that consists of a large number of neurons. At the same time, each neuron represents a complex function, and to update the weights of the neural network, we need to calculate the partial derivatives of the composite function of our neural network with respect to each weight.

According to the rules of mathematics, the derivative of a composite function is equal to the product of the derivative of the outer function and the derivative of the inner function.

Let us use this rule and find the partial derivatives of the loss function L by the weight of the output neuron wi and by the ith input value xi.

Where:

- L = loss function

- A = activation function of the neuron

- S = weighted sum of the raw data

- X = vector of initial data

- W = vector of weights

- wi = ith weighting factor for which the derivative is calculated

- xi = ith element of the initial data vector

The first thing to notice in the formulas presented above is the complete coincidence of the first two multipliers. I.e., when calculating partial derivatives on weights and initial data, we only need to calculate the error gradient in front of the activation function once, and using this value, calculate partial derivatives for all elements of the vectors of weights and initial data.

Using a similar method, we can determine the partial derivative with respect to the weight of one of the neurons in the hidden layer that precedes the output neuron layer. For this purpose, in the previous formula we replace the vector of initial data with the function of the hidden layer neuron. The vector of weights will be transformed into a scalar value of the corresponding weight.

Where:

- Ah = activation function of the hidden layer neuron

- Sh = weighted sum of the original data of the hidden layer neuron

- Xh = vector of initial data for the hidden layer neuron

- Wh = vector of weights of the hidden layer neuron

- wh = weight of the hidden layer for which the derivative is calculated

Note that if in the last formula, we return X instead of the function of the hidden layer neuron, we see in the first function multipliers the function of the private derivative of the ith input value presented above.

Hence,

Similar formulas can be provided for each neuron in our network. Thus, we can calculate the derivative and error gradient of the neuron output once, and then propagate the error gradient to all the connected neurons in the previous layer.

Following this logic, we first determine the deviations from the reference value using the loss function. The loss function can be anything that satisfies the requirements described in the previous section.

,

Where:

- Y = vector of reference values

- Y' = vector of values at the output of the neural network

Next, we determine how the states of the neurons in the output layer should change in order for our loss function to reach its minimum value. From a mathematical perspective, we determine the error gradient on each neuron in the output layer by calculating the partial derivative of the loss function with respect to each parameter.

We then "descend" the error gradient from the output neural layer to the input layer by running it sequentially through all the hidden neural layers of our network. In this way, we are effectively bringing the reference value to each neuron at this stage of training.

Where:

-  gradij–1 = gradient at the output of the ith neuron of the j–1 layer

- Akj = the activation function of the kth neuron on the jth layer

- Skj = weighted sum of incoming data of the kth neuron on the jth layer

- Wkj = vector of synaptic coefficients of the kth neuron on the jth layer

After obtaining the error gradients at the output of each neuron, we can proceed to adjust the synaptic coefficients of the neurons. For this purpose, we will go through all layers of the neural network one more time. At each layer, we will search all neurons and for each neuron, we will update all synaptic connections.

Backward pass of the neural network

We will talk about ways to update the weights in the next chapter.

After updating the weights, we return to step 2 of our algorithm. The cycle is repeated until the minimum of the function is found. Determining the achievement of the minimum can be done by observing zero partial derivatives. In general, it will be noticeable by the absence of change of the error at the output of the neural network after the next cycle of updating the weights, because at zero derivatives the process of training of the neural network stops.

## Loss functions

When starting training, it is necessary to choose methods for determining the quality of network training. Training a neural network is an iterative process. At each iteration, we need to determine how accurate the neural network calculations are. In the case of supervised learning, it refers to how much they differ from the reference. By knowing the deviation only can we understand how much and which way we need to adjust the synaptic coefficients.

Therefore, we need a certain metric that will impartially and mathematically accurately indicate the error of the neural network's performance.

At first glance, it is quite a trivial task to compare two numbers (the calculated value of the neural network and the target). But as a rule, at the output of a neural network, we get not one value, but an entire vector. To solve this problem, lets turn to mathematical statistics. Let us introduce a loss function that depends on the calculated value (y') and the reference value (y).

This function should determine the deviation of the calculated value from the reference value (error). If we consider the computed and target values as points in space, then the error can be seen as the distance between these points. Therefore, the loss function should be continuous and non-negative for all permitted values.

In an ideal state the calculated and reference values are the same, and the distance between the points is zero. Therefore, the function must be convex downwards with a minimum at L(y,y')=0.

The book "[Robust and Non-Robust Models in Statistics](https://www.researchgate.net/publication/286926757_Robust_and_Non-Robust_Models_in_Statistics) " by L.B.Klebanov describes four properties that a loss function should have:

- Completeness of information

- The absence of a randomization condition

- Symmetry condition

- Rao-Blackwell state (statistical estimates of parameters can be improved)

The book presents quite a few mathematical theorems and their proofs. It demonstrates the relationship between the choice of loss function and a statistical estimate. As a consequence, certain statistical issues can be resolved through the proper choice of the loss function.

#### Mean Absolute Error (MAE) [#](#mae)

One of the earliest loss functions, the Mean Absolute Error (MAE), was introduced by the 18th-century French mathematician Pierre-Simon Laplace. He proposed using the absolute difference between the reference and computed values as a measure of deviation.

The function has a graph that is symmetric about zero, and linear before and after zero.

Graph of the Mean Absolute Deviation function

The use of Mean Absolute Error provides a linear approximation of the analytical function to the training dataset across the entire range of error.

Let's look at the implementation of this function in MQL5 program code. To calculate deviations, the function must receive two data vectors: calculated and reference values. This data will be passed as parameters to the function.

At the beginning of the method, we compare the size of the resulting arrays. Ideally, array sizes should be at least zero. If the check fails, we exit the function with a result of the maximum possible error, DBL_MAX.

```
double MAE(double &calculated[], double &target[])

  {

   double result = DBL_MAX;

//---

   if(calculated.Sizel() < target.Sizel() || target.Sizel() <= 0)

      return result;
```

After successfully passing the checks, we create a loop to accumulate the absolute values of deviations. In conclusion, we divide the accumulated sum by the number of reference values.

```
//---

   result = 0;

   int total = target.Size();

   for(int i = 0; i < total; i++)

      result += MathAbs(calculated[i] - target[i]);

   result /= total;

//---

   return result;

  }
```

#### Mean Squared Error (MSE) [#](#mse)

The 19th-century German mathematician Carl Friedrich Gauss proposed using the square of the deviation instead of the absolute value in the formula for mean absolute deviation. The function is called the standard deviation.

Thanks to squaring the deviation, the error function takes the form of a parabola.

Graph of the mean squared deviation function

When using mean squared deviation, the speed of error compensation is higher when the error itself is larger. When the error decreases, the speed of its compensation also decreases. In the case of neural networks, this allows for faster convergence of the neural network with large errors and finer tuning with small errors.

But there is a flip side to the coin: the property mentioned above makes the function sensitive to noisy phenomena, as rare, large deviations can lead to a bias in the function.

Currently, the use of mean squared error as a loss function is widely employed in solving regression problems.

The algorithm for implementing MSE in MQL5 is similar to implementing MAE. The only difference is in the body of the loop, where the sum of the squares of the deviations is calculated instead of their absolute values.

```
double MSE(double &calculated[], double &target[])

  {

   double result = DBL_MAX;

//---

   if(calculated.Size() < target.Size() || target.Size() <= 0)

      return result;
```

```
//---

   result = 0;

   int total = target.Size();

   for(int i = 0; i < total; i++)

      result += MathPow(calculated[i] - target[i], 2);

   result /= total;

//---

   return result;

  }
```

#### Cross-entropy [#](#cross-entropi)

For solving classification tasks, the cross-entropy function is most commonly used as the loss function.

Entropy is a measure of uncertainty in distribution.

Applying entropy shifts calculations from the realm of absolute values into the realm of probabilities. Cross-entropy defines the similarity of probabilities of events occurring in two distributions and is calculated using the formula:

where:

- p(yi) = the probability of the ith event occurring in the reference distribution

- p(yi') = the probability of the ith event occurring in the calculated distribution

Since we are examining probabilities of events occurring, the probability values of an event always lie within the range of 0 to 1. The value of the logarithm in this range is negative, so adding a minus sign before the function shifts its value into the positive range and makes the function strictly decreasing. For clarity, the logarithmic function graph is shown below.

During training, for events in the reference distribution, when an event occurs, its probability is equal to one. The probability of a missing event occurring is zero. Based on the graph of the function, the event that occurred in the reference distribution but was not predicted by the analytical function will generate the highest error. Thus, we will stimulate the neural network to predict expected events.

It is the application of the probabilistic model that makes this function most attractive for classification purposes.

Graph of the logarithmic function

An implementation of this feature is presented below. The implementation algorithm is similar to the previous two functions.

```
double LogLoss(double &calculated[], double &target[])

  {

   double result = DBL_MAX;

//---

   if(calculated.Size() < target.Size() || target.Size() <= 0)

      return result;

//---

   result = 0;

   int total = target.Size();

   for(int i = 0; i < total; i++)

      result -= target[i] * MathLog(calculated[i]);

//---

   return result;

  }
```

Only three of the most commonly used loss functions are described above. But in fact, their number is much higher. And here, as in the case of activation functions, we will be assisted by vector and matrix operations implemented in MQL5, among which the Loss function is implemented. This function allows to compute the loss function between two vectors/matrices of the same size in just one line of code. The function is called for a vector or matrix of calculated values. The parameters of the function include a vector/matrix of reference values and the type of loss function.

```
double vector::Loss(

  const vector&       vect_true,    // true value vector

  ENUM_LOSS_FUNCTION  loss          // loss function type

   );
```

```
double matrix::Loss(

  const matrix&       matrix_true,  // true value matrix

  ENUM_LOSS_FUNCTION  loss          // loss function type

   );
```

MetaQuotes provides 14 readily implemented loss functions. These are listed in the table below.

Identifier

Description

LOSS_MSE

Mean squared error

LOSS_MAE

Average absolute error

LOSS_CCE

Categorical cross-entropy

LOSS_BCE

Binary cross-entropy

LOSS_MAPE

Average absolute error in percentages

LOSS_MSLE

Mean-squared logarithmic error

LOSS_KLD

Kulback-Leibler divergence

LOSS_COSINE

Cosine similarity/proximity

LOSS_POISSON

Poisson loss function

LOSS_HINGE

Hinge loss function

LOSS_SQ_HINGE

Quadratic piecewise linear loss function

LOSS_CAT_HINGE

Categorical piecewise linear loss function

LOSS_LOG_COSH

The logarithm of the hyperbolic cosine

LOSS_HUBER

Huber loss function
