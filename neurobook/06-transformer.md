# Chapter 06: Attention Mechanisms

*Source: [https://www.mql5.com/en/neurobook/index/transformer](https://www.mql5.com/en/neurobook/index/transformer)*

---

## Attention mechanisms

In the previous sections of the book, we have explored various architectures for organizing neural networks, including convolutional networks borrowed from image processing algorithms. We also learned about recurrent neural networks used to work with sequences where both the values themselves and their place in the original data set are important.

Fully connected and convolutional neural networks have a fixed input sequence size. Recurrent neural networks allow a slight extension of the analyzed sequence by transmitting hidden states from previous iterations. Nevertheless, their effectiveness also declines as consistency increases.

All the models discussed so far spend the same amount of resources analyzing the entire sequence. However, consider your behavior in a given situation. For example, even as you read this book, your gaze moves across letters, words, and lines, turning the pages in sequence. At the same time, you focus your attention on some specific component. Gradually reading the words written in the book, in your mind you assemble a mosaic of the logical chain embedded in the written words. And again, in your consciousness, there is always only a certain part of the overall content of the book.

Looking at a photograph of your loved ones, you first and foremost focus your attention on their portraits. Only then might you shift your gaze to the background elements of the photograph. At the same time, you focus your attention on photography. And the entire external environment surrounding you remains outside of your cognitive activity at that moment.

I want to show you that human consciousness does not evaluate the entire environment. It constantly picks out some details from it and shifts its attention to them. However, the neural network models we have discussed do not possess such capability.

Therefore, in 2014, in the field of machine translation, the first attention mechanism was proposed, which was designed to programmatically identify and highlight blocks of the source sentence (context) most relevant to the target translation word. This intuitive approach has greatly improved the quality of text translation by neural networks.

Analyzing the financial symbol candlestick chart, we identify trends and determine trading zones. That is, from the overall picture, we single out certain objects, focusing our attention specifically on them. It is intuitive to us that objects influence future price behavior to different degrees. To implement exactly this approach, the first proposed algorithm analyzed and identified dependencies between elements of the input and output sequences. The proposed algorithm was called a generalized attention mechanism. Initially, it was proposed for use in machine translation models using recurrent networks to address the long-term memory challenges in translating long sentences. This approach significantly outperformed the results of the previously considered recurrent neural networks based on LSTM blocks.

The classic machine translation model using recursive networks consists of two units, the Encoder and the Decoder. The first one encodes the input sequence in the source language into a context vector, and the second decodes the obtained context into a sequence of words in the target language. As the length of the input sequence increases, the influence of the first words on the final context of the sentence decreases, and as a result, the quality of the translation deteriorates. The use of LSTM blocks slightly enhanced the capabilities of the model, but they still remained limited.

Encoder-Decoder without the attention mechanism

Authors of the basic attention mechanism proposed using an additional layer that would accumulate the hidden states of all recurrent blocks of the input sequence and then, during the decoding process, evaluate the influence of each element of the input sequence on the current word of the output sequence and suggest to the decoder the most relevant part of the context.

The algorithm for such a mechanism included the following iterations:

- Creation of hidden states in the Encoder and their accumulation in the attention block.

- Evaluation of pairwise dependencies between the hidden states of each element of the Encoder and the last hidden state of the Decoder.

- The resulting estimates are combined into a single vector and normalized using the Softmax function.

- Calculation of the context vector by multiplying all the hidden states of the Encoder by their corresponding alignment scores.

- Decoding of the context vector and merging the resulting value with the previous Decoder state.

All iterations are repeated until the signal of the sentence end is received.

 

Encoder-Decoder with the attention mechanism

The proposed mechanism addressed the issue of the input sequence length limitation and enhanced the quality of machine translation using the recurrent neural network. As a result, it gained widespread popularity and various implementation variations. In particular, in August 2015, in their article [Effective Approaches to Attention-based Neural Machine Translation](https://arxiv.org/abs/1508.04025), Minh-Thang Luong presented their variation on the method of attention. The main differences of the new approach were the use of three functions to calculate the degree of dependencies and the point of using the attention mechanism in the Decoder.

## GPT architecture

In June 2018, OpenAI introduced GPT, the neural network model, which immediately showed the best results in a number of language tests. In February 2019, they released GPT-2, and in May 2020, everyone learned about GPT-3. These models demonstrated the possibility of a neural network to generate texts. Experiments were also conducted on the generation of music and images. The main disadvantage of the models is the requirements for computing resources. It took a month to train the first GPT on a machine with 8 GPUs. This disadvantage is partially compensated by the ability to use pre-trained models to solve new problems. However, the size of the model requires resources for its functioning.

Conceptually, GPT models are built on the basis of the transformer we have already looked at. The main idea is to pre-train a model without a teacher on a large volume of data and then fine-tune it on a relatively small amount of labeled data.

The reason for the two-step training is the size of the model. Modern deep machine learning models, such as GPT, have a large number of parameters, numbering in the hundreds of millions or more. Therefore, training of such neural networks requires a huge training dataset. When using supervised learning, creating a labeled training dataset can require significant effort. At the same time, there are numerous digitized texts available on the internet which are not unlabeled, making them suitable for unsupervised learning models. However, the results of unsupervised learning are statistically inferior to supervised learning. Therefore, after unsupervised learning, the model undergoes fine-tuning on a relatively small labeled dataset.

Unsupervised learning allows GPT to learn a language model, while fine-tuning using labeled data tailors the model for specific tasks. In this way, a single pre-trained model can be replicated and configured to perform different language tasks. The limitation lies in the language of the source dataset for unsupervised learning.

As practical experience has shown, such an approach yields good results across a wide range of language tasks. For example, the GPT-3 model is able to generate related texts on a given topic. But it's worth noting that the mentioned model contains 175 billion parameters and was pre-trained on a dataset of 570 GB.

Despite the fact that GPT models were designed for natural language processing, they also showed impressive results in music and image generation tasks.

Theoretically, it is possible to use GPT models with any sequences of digitized data. The question lies in having sufficient data and resources for unsupervised pre-training.

## Multi-Head attention

In the previous section, we got acquainted with the mechanism of Self-Attention mechanism, which was introduced in June 2017 in the article [Attention Is All You Need](https://arxiv.org/abs/1706.03762). The key feature of this mechanism is its ability to capture dependencies between individual elements in a sequence. We even implemented it and managed to test it on real data. The model demonstrated its effectiveness.

Recall that the Self-Attention algorithm uses three trainable matrices of weights (WQ, WK, and WV). The matrix data is used to obtain 3 three entities: Query, Key, and Value. The first two determine the pairwise relationship between elements of the sequence, while the last one represents the context of the analyzed element.

It's not a secret that situations are not always straightforward. The same situation can often be interpreted from various perspectives. With different points of view, the conclusions can be completely opposite. In such situations, it's important to consider all possible options and only draw a conclusion after a comprehensive analysis. That's why in the same paper, the authors of the method proposed using Multi-Head Attention to address such problems. This is the launch of several parallel Self-Attention threads, with different weights. Here, each 'head' has its own opinion, and the decision is made by a balanced vote. A solution like this should better identify connections between different elements of the sequence.

Multi-Headed Attention architecture diagram

In the Multi-Head Attention architecture, several Self-Attention threads with different weights are used in parallel, which simulates a versatile analysis of the situation. The results of the threads are concatenated into a single tensor. The final result of the algorithm is determined by multiplying the tensor by W0 matrix, the parameters of which are selected in the process of training the neural network. This whole architecture replaces the Self-Attention block in the encoder and decoder of the transformer architecture.

It is the Multi-Head Attention architecture that is most often used to solve practical problems.

## Self-Attention

The models described above utilize recurrent blocks, the training of which incurs significant costs. In June 2017, in the article [Attention Is All You Need](https://arxiv.org/abs/1706.03762) the authors proposed a new neural network architecture called the Transformer, which eliminated the use of recurrent blocks and proposed a new Self-Attention algorithm. In contrast to the algorithm described above, the Self-Attention algorithm analyzes pairwise dependencies within the same sequence. The Transformer performed better on the tests, and today the model and its derivatives are used in many models, including GPT-2 and GPT-3. We will consider the Self-Attention algorithm in more detail.

## Description of the architecture and implementation principles

Let's consider the differences between GPT models and the previously considered Transformer. First, GPT models do not use the encoder while only using the decoder. This has led to the disappearance of the inner layer of Encoder-Decoder Self-Attention. The figure below shows the transformer block in GPT.

GPT Block

As in the classic Transformer, these blocks in GPT models are lined up on top of each other. Each block has its own weigh matrices for the attention engine and fully connected Feed Forward layers. The number of such blocks determines the size of the model. As it turns out, the stack of blocks can be quite large. There are 12 of them in GPT-1 and the smallest of GPT-2 (GPT-2 Small), 48 in GPT-2 Extra Large, and 96 in GPT-3.

Like traditional language models, GPT allows you to find relationships only with the previous elements of the sequence, not allowing you to look into the future. However, unlike the Transformer, it doesn't use masking of elements but rather introduces changes to the computation process. In GPT, the attention coefficients in the Score matrix for subsequent elements are zeroed.

At the same time, GPT can be attributed to autoregressive models. Generating one token of the sequence at a time, the generated token is added to the input sequence and fed into the model for the next iteration.

As in the classic transformer, three vectors are generated inside the Self-Attention mechanism for each token: Query, Key, and Value. In an autoregressive model, when the input sequence changes by only 1 token on each new iteration, there is no need to recalculate the vectors for each token from scratch. That's why in GPT, each layer calculates vectors only for the new elements in the sequence and stores them for each element in the sequence. Each transformer block saves its vectors for later use.

This approach allows the model to generate text word by word until it reaches the end token.

And of course, GPT models use the Multi-Head Self-Attention mechanism.

## Building a GPT model using MQL5

Before you start working on a GPT model, don't expect to get some kind of a beast at the end of the section that can solve any problems. We only build the model algorithms. The operation of these algorithms will be comparable to the computational resources involved. Of course, we will get and evaluate the results of these algorithms. But first things first.

Let's briefly recap the algorithm:

- The Multi-Head Self-Attention block received, as input, a tensor of initial data where each element of the sequence is represented by a token (a vector of values).

One sequence for all heads (threads). The actions in steps 2-5 are identical for each attention head.

- For each token, three vectors (Query, Key, Value) are calculated by multiplying the token vector by the corresponding trainable matrix of weights W.

- By multiplying the Query and Key vectors, we determine the pairwise dependencies between the elements of the sequence. At this step, the Query vector of each element of the sequence is multiplied by the Key vectors of the current and all previous elements of the sequence.

- The matrix of the obtained dependence coefficients is normalized using the Softmax function in the context of each query (Query). In this case, a zero attention coefficient is set for subsequent elements of the sequence.

- As a result of steps 3 and 4, we get a square Score matrix with a dimension equal to the number of elements in the sequence, where the sum of all elements in the context of each Query is equal to one.

- Then we multiply the normalized attention coefficients by the Value vectors of the corresponding elements of the sequence, add the resulting vectors, and get the attention-adjusted value for each element of the sequence.

- Next, we determine the weighted attention result. To do this, we multiply the concatenated tensor of the results of all attention heads by the trained matrix W0.

- The resulting tensor is added to the input sequence and normalized.

- The Multi-Heads Self-Attention mechanism is followed by two fully connected layers of the Feed Forward block. The first (hidden) layer contains four times as many neurons as the input sequence with the ReLU activation function (we used the Swish function instead). The dimension of the second layer is equal to the dimension of the input sequence, and neurons do not use the activation function.

- The result of the fully connected layers is summed up with the tensor input to the Feed Forward block and the resulting tensor is normalized.

Now that we have refreshed the basic steps of the process, let's proceed with the implementation. To implement the new type of neural layer, let's create a new class CNeuronGPT, inheriting from the CNeuronBase neural layer base class of our model. Despite using the Self-Attention algorithm in the model, I chose not to inherit from our existing classes of neural layers using attention mechanisms. This is due to some peculiarities in the model implementation, which we will become familiar with during the process.

Perhaps one of the main differences is the ability to build multiple homogeneous layers within one class. Previously we used separate layers to implement parts of the model functionality, while now we are talking about the full-fledged creation of several copies of the layer being created, each with its own weights. To achieve this, in the body of the method, we declare not individual neural layers but entire collections of layers. Among them, you will see familiar variable names from working with previous classes, but they will now contain pointers to collections of neural layers. At the same time, we have preserved the functionality hidden behind the object names. Additionally, we have added two new variables:

- m_iLayers — number of neural layers in the block

- m_iCurrentPosition — number of the current element in the sequence

```
class CNeuronGPT    :  public CNeuronBase

  {

protected:

   CArrayLayers      m_cQuerys;

   CArrayLayers      m_cKeys;

   CArrayLayers      m_cValues;

   CArrayLayers      m_cScores;

   CArrayLayers      m_cAttentionOut;

   CArrayLayers      m_cW0;

   CArrayLayers      m_cFF1;

   CArrayLayers      m_cFF2;

   //---

   int               m_iLayers;

   int               m_iWindow;

   int               m_iUnits;

   int               m_iKeysSize;

   int               m_iHeads;

   CBufferType       m_dStd[];

   int               m_iCurrentPosition;

   int               m_iScoreTemp;

   virtual bool      NormlizeBuffer(CBufferType *buffer, CBufferType *std,

                                                              uint std_shift);

   virtual bool      NormlizeBufferGradient(CBufferType *output,

                     CBufferType *gradient, CBufferType *std, uint std_shift);

public:

                     CNeuronGPT(void);

                    ~CNeuronGPT(void);

   //---

   virtual bool      Init(const CLayerDescription *desc) override;

   virtual bool      SetOpenCL(CMyOpenCL *opencl) override;

   virtual bool      FeedForward(CNeuronBase *prevLayer) override;

   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;

   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer, bool read) override;

   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,

                                   VECTOR &Beta, VECTOR &Lambda) override;

   //---

   virtual int       GetUnits(void) const { return m_iUnits;   }

   virtual int       GetLayers(void) const { return m_iLayers; }

   //--- methods for operations with files

   virtual bool      Save(const int file_handle) override;

   virtual bool      Load(const int file_handle) override;

   //--- object identification methods

   virtual int       Type(void) override  const { return(defNeuronGPT);  }

  };
```

The addition of the m_iCurrentPosition variable is the second architectural feature of this model. We have already said that GPT refers to autoregressive models. At each step, it returns one element of the sequence and feeds it as input at a new iteration. We mentioned something similar about recurrent models. However, in recurrent models, the hidden state was added to the current state of the environment, while in the case of GPT, generating the language model involves creating a new state. Of course, concerning financial markets, we deviate slightly from this feedback and input the actual new state, but we will preserve the signal processing principles.

The logic is as follows: if only one element of the sequence is updated at each new iteration, there is no need to recalculate the same values every time. It's not efficient. Let's recalculate only the new element of the sequence, and for the previous elements of the sequence, let's use the values from previous iterations. This is why we introduce the m_iCurrentPosition variable to store the index of the current element in the sequence. We will get acquainted with its usage principles as we proceed with the implementation.

Let's take things step by step. As usual, we will start working on the methods of the class with the class constructor. In it, we initialize variables with initial values. Similar to the attention mechanism classes discussed earlier, we use static objects that do not instantiate in the class constructor. The class destructor remains empty.

```
CNeuronGPT::CNeuronGPT(void) :   m_iHeads(8),

                                 m_iWindow(0),

                                 m_iKeysSize(0),

                                 m_iUnits(0),

                                 m_iLayers(0),

                                 m_iCurrentPosition(0)

  {

  }
```

Following our previously used pattern of working with classes, next, we will construct the initialization method of the class. This method is inherited from the parent class CNeuronBase and is overridden in each new class.

In the parameters, the method receives a pointer to an object describing the created neural layer, and we immediately perform a validity check on the received pointer, as well as verify the presence of the specified minimum necessary parameters for the correct initialization of the class instance.

```
bool CNeuronGPT::Init(const CLayerDescription *desc)

  {

//--- checking the initial data

   if(!desc || desc.type != Type() || desc.count <= 0 || desc.window <= 0 ||

      desc.window_out <= 0 || desc.step <= 0 || desc.layers <= 0)

      return false;
```

After successfully passing the control block, we save the received parameters to the appropriate variables of our class.

```
//--- save the constants

   m_iWindow   = desc.window;

   m_iUnits    = desc.count;

   m_iKeysSize = desc.window_out;

   m_iHeads    = desc.step;

   m_iLayers   = desc.layers;

   if(!ArrayResize(m_dStd, m_iLayers))

      return false;

   for(int l = 0; l < m_iLayers; l++)

      if(!m_dStd[l].BufferInit(1, 2, 1))

         return false;
```

Then, similar to the previously created classes using the attention mechanism, we will slightly adjust the description of the created neural layer and call the initialization method of the parent class. I would like to remind you that in the description of the created neural layer, we set the window size parameter of the input data to zero before calling the method of the parent class. This allows us to remove unused buffer objects from the parent class.

```
//--- call the initialization method of the parent class

   CLayerDescription *temp = new CLayerDescription();

   if(!temp || !temp.Copy(desc))

      return false;

   temp.window_out = 1;

   temp.window     = 0;

   temp.activation = AF_NONE;

   if(!CNeuronBase::Init(desc))

      return false;

   delete temp;
```

After that, we create a loop with the number of iterations equal to the number of homogeneous neural layers created. All other objects will be created in the body of this loop.

```
//--- run a loop to create objects of internal layers

   for(int layer = 0; layer < m_iLayers; layer++)

     {
```

The operations in the loop body are very similar to the operations performed in the class initialization methods using the Self-Attention mechanism, but there are still differences.

Firstly, within the loop body, we create an instance of the CLayerDescription object to describe the neural layers being created and fill it with the necessary data. Since we have decided to input only the state update to the neural network, rather than the entire pattern information, I chose to forgo using convolutional neural layers and opted for a basic fully connected neural layer. Therefore, in the type field of the layer description object, we set the constant defNeuronBase. In this case, the window size of the input data will be equal to the size of the vector describing one element of the sequence. In this case, the entire volume of input data is perceived as the description of one element of the sequence.  

Next, we recall that the model uses the Multi-Head Self-Attention mechanism, so we need to create three vectors (Query, Key, Value) for each attention head from one vector of the initial data. I would like to remind you of another detail: when implementing the Multi-Head Self-Attention mechanism, we used concatenated vectors. Now we are going further: we will no only create a single tensor for all attention heads but we also combine all three entities mentioned above at once (Query, Key, Value). However, since it will contain only one element of the sequence, its size will not be so large. In the count field specify a size equal to the three vectors of one element of the key tensor sequence for each attention head. The newly created layer will not have an activation function, just like before. We will use the parameter optimization method specified by the user in the neural layer description from the method parameters.

```
temp = new CLayerDescription();

      if(!temp)

         return false;

      temp.type = defNeuronBase;

      temp.window = m_iWindow;

      temp.count = (int)(3 * m_iKeysSize * m_iHeads);

      temp.activation = AF_NONE;

      temp.optimization = desc.optimization;
```

After creating the neural layer description object and specifying all the necessary parameters, we create the first internal neural layer Queries. We initialize it using a pre-created neural layer description object. It is essential to monitor the process of performing operations. After successfully completing the first two operations, we add the layer to the corresponding collection.

```
//--- initialize Querys

      CNeuronBase *Querys = new CNeuronBase();

      if(!Querys)

        {

         delete temp;

         return false;

        }

      if(!Querys.Init(temp))

        {

         delete Querys;

         delete temp;

         return false;

        }

      if(!m_cQuerys.Add(Querys))

        {

         delete Querys;

         delete temp;

         return false;

        }
```

Despite creating a concatenated tensor, we have kept the name Querys for the neural layer, maintaining continuity with the previously created attention mechanism classes. However, we will also create internal neural layers for Keys and Values, although with different parameters.

We will use the internal neural layers Keys and Values to accumulate historical data on the received current states. It is, so to speak, the memory of our neural layer, and it should be sufficient to store the entire pattern being analyzed. However, since we have already calculated the state of these vectors in the fully connected neural layer Querys, we do not need matrices of weights in them. Therefore, before initializing the mentioned internal neural layers, we will make a change to the description object of the neural layer: we will set the size of the input data window to zero and ensure that the neural layer has enough elements to store the entire pattern description tensor.

```
//--- initialize Keys

      CNeuronBase *Keys = new CNeuronBase();

      if(!Keys)

        {

         delete temp;

         return false;

        }

      temp.window = 0;

      temp.count = (int)(m_iUnits * m_iKeysSize * m_iHeads);

      if(!Keys.Init(temp))

        {

         delete Keys;

         delete temp;

         return false;

        }

      if(!Keys.GetOutputs().Reshape(m_iUnits, m_iKeysSize * m_iHeads))

         return false;

      if(!m_cKeys.Add(Keys))

        {

         delete Keys;

         delete temp;

         return false;

        }
```

The rest of the algorithm for creating an internal neural layer is similar to creating the Querys layer:

- Create a new instance of the neural layer object.

- Initialize the neural layer.

- Add the neural layer to the corresponding collection.

```
//--- initialize Values

      CNeuronBase *Values = new CNeuronBase();

      if(!Values)

        {

         delete temp;

         return false;

        }

      if(!Values.Init(temp))

        {

         delete Values;

         delete temp;

         return false;

        }

      if(!Values.GetOutputs().Reshape(m_iUnits, m_iKeysSize * m_iHeads))

         return false;

      if(!m_cValues.Add(Values))

        {

         delete Values;

         delete temp;

         return false;

        }
```

After creating the neural layers Query, Keys, and Values, we proceed to create the dependency coefficient matrix Score. There are implementation nuances here as well. This matrix in the Self-Attention implementation algorithm has a square size with each side of the square equal to the number of elements of the sequence. Each element of the matrix represents the coefficient of the pairwise relationship between the elements of the sequence, where the rows of the matrix correspond to the vectors of the tensor of the Query queries and the columns of the matrix correspond to the vectors of the Key tensor.

Now, let's think about how we can implement such a matrix if we have one Query vector that describes only the last state. Therefore, the Score matrix in this case degenerates into a vector. Of course, for each attention head. Certainly, the neural layer of the Score dependency coefficient vector does not contain a matrix of weights. Therefore, we adjust the number of elements in the neural layer and create a new internal neural layer using the algorithm mentioned above. Let's take advantage of the opportunity and make the matrix rectangular. The rows of the matrix will correspond to the attention heads.

```
//--- initialize Scores

      CNeuronBase *Scores = new CNeuronBase();

      if(!Scores)

        {

         delete temp;

         return false;

        }

      temp.count = (int)(m_iUnits * m_iHeads);

      if(!Scores.Init(temp))

        {

         delete Scores;

         delete temp;

         return false;

        }

      if(!Scores.GetOutputs().Reshape(m_iHeads, m_iUnits))

         return false;

      if(!m_cScores.Add(Scores))

        {

         delete Scores;

         delete temp;

         return false;

        }
```

The next object we will create is a neural layer for the concatenated output of the AttentionOut attention heads. Here, the situation is similar to the dependency coefficient matrix. We have already discussed the reasons for the degeneration of the matrix of dependence coefficients into a vector, and to obtain the result of the work of the attention head according to the Self-Attention algorithm, we need to multiply the matrix of dependence coefficients by the Value tensor.

But in our case, with one Query vector at the output, we also get one vector for each attention head. Therefore, we will specify the correct layer size and execute the algorithm for its initialization.

```
//--- initialize AttentionOut

      CNeuronBase *AttentionOut = new CNeuronBase();

      if(!AttentionOut)

        {

         delete temp;

         return false;

        }

      temp.count = (int)(m_iKeysSize * m_iHeads);

      if(!AttentionOut.Init(temp))

        {

         delete AttentionOut;

         delete temp;

         return false;

        }

      if(!AttentionOut.GetOutputs().Reshape(m_iHeads, m_iKeysSize))

         return false;

      if(!m_cAttentionOut.Add(AttentionOut))

        {

         delete AttentionOut;

         delete temp;

         return false;

        }
```

Following the multi-head attention algorithm, our next step will be to organize the results of all attention heads into a unified vector and adjust its size to match the size of the input data vector. In the algorithm of the Multi-Head Self-Attention mechanism, this operation is performed using the W0 matrix. However, we will perform this operation using a basic fully connected neural layer without an activation function.

Again, we will create a new instance of the neural layer object. Do not forget to check the result of the operation.

```
//--- initialize W0

      CNeuronBase *W0 = new CNeuronBase();

      if(!W0)

        {

         delete temp;

         return false;

        }
```

In the neural layer description object, we enter the necessary parameters:

- The size of the input data window is equal to the size of the previously created layer for the concatenated results of attention heads.

- The number of elements at the output of the neural layer is equal to the size of the source data vector.

- The activation function is not used.

We initialize the neural layer using the neural layer description object.

```
temp.window = temp.count;

      temp.count = m_iWindow;

      temp.activation = AF_NONE;

      if(!W0.Init(temp))

        {

         delete W0;

         delete temp;

         return false;

        }

      if(!m_cW0.Add(W0))

        {

         delete W0;

         delete temp;

         return false;

        }
```

After the successful initialization of the neural layer object, we add it to the appropriate collection.

This concludes the work on initializing the objects of the Multi-Head Self-Attention mechanism, and we just have to create two neural layers of the Feed Forward block. The first neural layer has four times as many neurons in its output as the tensor received as input, and it is activated using the Swish function.

```
//--- initialize FF1

      CNeuronBase *FF1 = new CNeuronBase();

      if(!FF1)

        {

         delete temp;

         return false;

        }

      temp.window = m_iWindow;

      temp.count = temp.window * 4;

      temp.activation = AF_SWISH;

      temp.activation_params[0] = 1;

      temp.activation_params[1] = 0;

      if(!FF1.Init(temp))

        {

         delete FF1;

         delete temp;

         return false;

        }

      if(!m_cFF1.Add(FF1))

        {

         delete FF1;

         delete temp;

         return false;

        }
```

The second neural layer of the Feed Forward block does not have the activation function. It returns the size of the tensor to the size of the initial data. Here we also use a basic fully connected neural layer. We will make the necessary adjustments to the description object of the neural layer and initialize the neural layer.

```
//--- initialize FF2

      CNeuronBase *FF2 = new CNeuronBase();

      if(!FF2)

        {

         delete temp;

         return false;

        }

      temp.window = temp.count;

      temp.count = m_iWindow;

      temp.activation = AF_NONE;

      if(!FF2.Init(temp))

        {

         delete FF2;

         delete temp;

         return false;

        }

      if(!m_cFF2.Add(FF2))

        {

         delete FF2;

         delete temp;

         return false;

        }

      delete temp;

     }
```

We check the results of the operations at each step and add the created neural layer to the appropriate collection.

At this stage, we have created all the objects necessary for the operation of a single neural layer. We remove the description object of the neural layer and proceed to the next iteration of our loop, where we will create objects for the operation of the next layer.

Thus, upon completing all iterations of the loop, we will obtain objects for the operation of as many neural layers as the user specified when calling the initialization method of this neural layer.

Furthermore, to avoid copying data between the buffers of internal neural layers and the current layer, we will replace the pointers to the result and gradient buffers of the current layer.

```
//--- to avoid copying buffers, we will replace them

   if(m_cFF2.Total() < m_iLayers)

      return false;

   if(!!m_cOutputs)

      delete m_cOutputs;

   CNeuronBase *neuron = m_cFF2.At(m_iLayers - 1);

   if(!neuron)

      return false;

   m_cOutputs = neuron.GetOutputs();

   if(!!m_cGradients)

      delete m_cGradients;

   m_cGradients = neuron.GetGradients();
```

In conclusion, we call the method for distributing pointers to the OpenCL context among the class object and exit the initialization method.

```
SetOpenCL(m_cOpenCL);

//---

   return true;

  }
```

To fully address the issue of class initialization, I suggest considering a method for distributing the OpenCL context object pointer among the internal layer objects.

Despite the change in the type of internal objects, from a neural layer to a collection of neural layers, the structure and algorithm of the pointer propagation method to the OpenCL context have not changed much. This became possible thanks to the similar method we previously wrote in the neural layer collection class.

In the parameters, our SetOpenCL method gets a pointer to the OpenCL context object. In the body of the method, we first call the relevant method of the parent class, where all the necessary controls are already implemented, and the pointer is saved in the corresponding class variable. After that, we alternately check the pointers of all the internal objects of the neural layer and call a similar method for them.

```
bool CNeuronGPT::SetOpenCL(CMyOpenCL *opencl)

  {

   CNeuronBase::SetOpenCL(opencl);

   m_cQuerys.SetOpencl(m_cOpenCL);

   m_cKeys.SetOpencl(m_cOpenCL);

   m_cValues.SetOpencl(m_cOpenCL);

   m_cScores.SetOpencl(m_cOpenCL);

   m_cAttentionOut.SetOpencl(m_cOpenCL);

   m_cW0.SetOpencl(m_cOpenCL);

   m_cFF1.SetOpencl(m_cOpenCL);

   m_cFF2.SetOpencl(m_cOpenCL);

   if(m_cOpenCL)

     {

      uint size = sizeof(TYPE) * m_iUnits * m_iHeads;

      m_iScoreTemp = m_cOpenCL.AddBuffer(size, CL_MEM_READ_WRITE);

      for(int l = 0; l < m_iLayers; l++)

         m_dStd[l].BufferCreate(m_cOpenCL);

     }

   else

     {

      for(int l = 0; l < m_iLayers; l++)

         m_dStd[l].BufferFree();

     }

//---

   return(!!m_cOpenCL);

  }
```

Thus, we conclude the class initialization and proceed directly to implementing the neural layer operational algorithm. As always, we will start with the implementation of the feed-forward method.

## Organizing parallel computing in the GPT model

We continue to work on our model class, GPT CNeuronGPT. In the previous sections, we have already recreated the model algorithm using standard MQL5 tools. Now it's time to supplement the model with the ability to perform mathematical operations in multi-threaded mode using the computing power of the GPU. This is the opportunity provided by OpenCL.

To organize this process, we have to perform two subtasks:

- Create an OpenCL program.

- Organize the call of the OpenCL program from the main program.

Let's start by creating an executable program on the OpenCL side. In this program, we need to implement that part of the algorithm that is not covered by the use of internal object methods. We have two such blocks: one in the feed-forward part, and the second, mirrored to the first, included in the error gradient propagation method when performing the backpropagation pass.

To execute the feed-forward algorithm, we will create the GPTFeedForward kernel. In part, the kernel algorithm will resemble a similar kernel for classes using attention mechanisms. This is not surprising since they all use the Self-Attention mechanism. However, each implementation has its nuances. Last time, instead of creating a new kernel for organizing multi-head attention, we were able to quickly modify the existing kernel of the Self-Attention algorithm. Now, creating a new kernel seems less costly compared to trying to create a universal kernel for all tasks.

Unlike the implementation of the Multi-Heads Self-Attention mechanism in which we translated the kernel into a two-dimensional task space, in this implementation we return to a one-dimensional space. This is due to the lack of the possibility of splitting the task into parallel threads in the context of the elements of the Query tensor sequence since the GPT model implementation only allows processing one query per iteration. In this case, we are left with a division by threads only in the context of attention heads.

In the parameters of the GPTFeedForward kernel, we will continue to pass pointers to five data buffers. However, the number of variables increases: earlier we obtained the size of the sequence from the dimension of the task space, but now we have to explicitly specify it in the kernel parameters. Here, an additional parameter is used to specify the current element in the sequences of keys and values.

```
__kernel void GPTFeedForward(__global TYPE *querys,

                             __global TYPE *keys,

                             __global TYPE *scores,

                             __global TYPE *values,

                             __global TYPE *outputs,

                             int key_size,

                             int units,

                             int current)

  {
```

As mentioned earlier, the created kernel will operate in a one-dimensional space, focusing on the attention heads. Therefore, the first thing we do in the body of the kernel is determine the active attention head based on the identifier of the executing thread and the total number of attention heads, considering the total number of running threads.

```
const int h = get_global_id(0);

   const int heads = get_global_size(0);

   int shift_query = key_size * h;

   int shift_scores = units * h;
```

We immediately determine the offset in the Query and Score (dependency coefficient matrix) tensors.

Next, according to the Self-Attention algorithm that is being built, we determine the dependency coefficients between the elements of the sequence. To do this, we multiply the Query vector by the Key tensor. To implement these operations, we will create a system of two nested loops. The outer loop will iterate over the elements of the Key tensor sequence and, accordingly, the elements of the Score vector with dependency coefficients. In the body of the loop, we will define the offset in the Key tensor and prepare a local variable to count the intermediate values.

After that, we organize a nested loop with the number of iterations equal to the size of the description vector of one element of the sequence. In the body of this cycle, we perform the operation of multiplying a pair of vectors. The resulting value is divided by the square root of the dimension of the vector, and we take the exponent from it. We write the result of the operation into the corresponding element of the dependency coefficient vector and add it to the cumulative sum of all elements in the dependency coefficient vectors for subsequent data normalization.

We should consider the issue of the concatenated buffer of the results of the Query layer. The values of the key and query vectors of the current element in the sequence have not yet been transferred to the corresponding buffers. Therefore, we check the element that we are accessing in the key tensor. Before accessing the current element, we first copy the data to the buffer. Of course, for current operations, we could take data from the querys buffer. But we will need this data in subsequent iterations. Therefore, transferring them to the buffer is inevitable.

```
TYPE summ = 0;

   for(int s = 0; s < units; s++)

     {

      TYPE score = 0;

      int shift_key = key_size * (s * heads + h);

      for(int k = 0; k < key_size; k ++)

        {

         if(s == current)

            keys[shift_key + k] = querys[shift_query + k + heads * key_size];

         score += querys[shift_query + k] * keys[shift_key + k];

        }

      score = exp(score / sqrt((TYPE)key_size));

      summ += score;

      scores[shift_scores + s] = score;

     }
```

As a result of performing a full cycle of iterations of the system created above from two loops, we get a vector of dependency coefficients. According to the Self-Attention algorithm, before further use of the obtained coefficients, they will have to be normalized by the Softmax function. When obtaining the exponent from the products of vectors, we have already executed part of the algorithm of the specified function. To complete the normalization operation, we just need to divide the values stored in the vector by their total sum, which we prudently collected in the local variable summ. Therefore, we organize another loop with the number of iterations equal to the size of the vector of dependency coefficients. In the body of this loop, we will divide all the values of the vector by the value of the local variable summ.

```
for(int s = 0; s < units; s++)

      scores[shift_scores + s] /= summ;
```

Thus, after completing the iterations of the loop in the Score vector, we get the normalized values of the dependency coefficients with the total sum of all elements in the block. In fact, the obtained coefficients give us an idea of the proportion of influence of each element of the sequence from the Value tensor on the final value of the analyzed element of the sequence in the tensor of the results of the current attention head.

This means that in order to obtain the final values, we need to multiply the Score vector with normalized dependency coefficients by the Value tensor. To perform this operation, we need another system of two nested loops. But before running it, we will determine the offset in the tensor of the results before the beginning of the vector of the analyzed element of the sequence.

The outer loop, with the number of iterations equal to the size of the vector describing one element of the sequence, indicates the ordinal number of the collected element in the result vector. The nested loop, with the number of iterations equal to the number of elements in the sequence, helps correlate the vectors of the Value tensor with the dependency coefficients from the Score vector. In the body of the nested loop, we multiply the vector from the Value tensor by the corresponding element dependency coefficient. The resulting values of the products will be accumulated in a local variable. After completing the iterations of the inner loop, we save the obtained value in the buffer of the Self-Attention block results.

```
shift_query = key_size * h;

   for(int i = 0; i < key_size; i++)

        {

      TYPE query = 0;

      for(int v = 0; v < units; v++)

        {

         if(v == current)

            values[key_size * (v * heads + h) + i] =

                                      querys[(2 * heads + h) * key_size + i];

         query += values[key_size * (v * heads + h) + i] *

                                                    scores[shift_scores + v];

        }

      outputs[shift_query + i] = query;

     }

  }
```

As a result of completing the full cycle of iterations within the loop system, we obtain the vector describing one element of the sequence in the tensor of results for one attention head. The task assigned to this kernel has been completed, and we can exit it.

This concludes the work with the feed-forward kernel, and we move further along. Now we need to organize the backpropagation process. The implementation of this task will be split into two kernels. In the GPTCalcScoreGradient kernel, we will propagate the error gradient to the vector of the dependency coefficients. In the GPTCalcHiddenGradient kernel, we will continue the propagation of the error gradient up to the level of the Query and Key tensors.

Let's take it step by step. The GPTCalcScoreGradient kernel in the parameters receives pointers to six data buffers and three parameters:

- scores — buffer for the vector of dependency coefficients

- scores_grad — buffer for the error gradient vector at the level of dependency coefficients

- values — buffer for the Value tensor

- values_grad — buffer for the error gradient tensor at the Value level

- outputs_grad — error gradient tensor buffer at the result level of the Self-Attention block

- scores_temp — buffer for writing intermediate values

- window — size of the vector describing one element of the sequence in the Value tensor

- units — number of elements in the sequence

- current — ordinal number of the current item in the Value stack

```
__kernel void GPTCalcScoreGradient(__global TYPE *scores,

                                   __global TYPE *scores_grad,

                                   __global TYPE *values,

                                   __global TYPE *values_grad,

                                   __global TYPE *outputs_grad,

                                   __global TYPE *scores_temp,

                                   int window,

                                   int units,

                                   int current)

  {
```

As with the feed-forward pass, we run the kernel in one-dimensional space by the number of attention heads used. In the body of the kernel, we immediately determine the active attention head based on the thread identifier and the total number of attention heads considering the total number of launched threads.

```
const int h = get_global_id(0);

   const int heads = get_global_size(0);

   int shift_value = window * (2 * heads + h);

   int shift_score = units * h;
```

We also determine the offset in the tensors of the error gradients at the level of Value and in the vector of the dependency coefficients. Note that the offset in the tensor of error gradients for Value and in the Value tensor itself will be different in this case.

In this implementation of the GPT model, we used one internal neural layer to generate a concatenated tensor containing the values of Query, Key, and Value for all attention heads. Accordingly, we assemble the error gradient into a similar concatenated tensor of the error gradients for the specified neural layer. However, this tensor contains only the current element of the sequence. At the same time, the Value stack tensor contains complete information about the entire sequence but only for the Value tensor.

After the preparatory work, we distribute the error gradient to the Value tensor. As mentioned above, we distribute the error gradient only for the current element of the sequence. To do this, we organize a loop with the number of iterations equal to the size of the description vector of one element of the sequence in the Value tensor. In the body of the loop, will multiply the error gradient vector at the result level of the Self-Attention block by the corresponding dependency coefficient from the Score vector. The obtained values are saved in the buffer of the concatenated tensor of error gradients.

```
//--- Gradient distribution to Values

   for(int i = 0; i < window; i ++)

      values_grad[shift_value + i] = scores[units * h + current] *

                                                   outputs_grad[window * h + i];
```

After calculating the error gradient on the Value tensor, we will determine the value of the error gradient at the level of the dependency coefficient vector. To perform this operation, we will need a system of two loops: an outer loop with the number of iterations equal to the number of elements in the sequence and a nested loop with the number of iterations equal to the size of the description vector for one element in the Value tensor. In the body of the nested loop, we will multiply 2 vectors (Value and error gradient). The resulting value is stored in the temporary data buffer.

```
//--- Gradient distribution to Score

   for(int k = 0; k < units; k++)

        {

      TYPE grad = 0;

      for(int i = 0; i < window; i++)

         grad += outputs_grad[shift_value + i] *

                                        values[window * (k * heads + h) + i];

      scores_temp[shift_score + k] = grad;

     }
```

After completing the full cycle of iterations within the loop system, in the temporary buffer, we will obtain a fully populated gradient vector of error for the dependency coefficient vector. But to distribute the error gradient further, we first need to correct it to the derivative of the Softmax function.

Let's organize another system of two nested cycles. Both loops will contain the number of iterations equal to the number of elements in the sequence. In the body of the nested loop, we will calculate the derivative of the function using the formula.

```
//--- Adjust to the Softmax derivative

   for(int k = 0; k < units; k++)

        {

      TYPE grad = 0;

      TYPE score = scores[shift_score + k];

      for(int i = 0; i < units; i++)

         grad += scores[shift_score + i] * ((int)(i == k) - score) *

                                                scores_temp[shift_score + i];

      scores_grad[shift_score + k] = grad;

     }

  }
```

We will save the obtained values in the error gradient buffer at the level of the dependency coefficient vector. At this stage, we complete the work of the first kernel and move on to the second one.

In the second kernel of the GPTCalcHiddenGradient backpropagation process, we have to propagate the error gradient further and bring it to the level of Query and Key tensors.

In parameters, the GPTCalcHiddenGradient kernel receives pointers to 4 data buffers and 3 parameters.

```
__kernel void GPTCalcHiddenGradient(__global TYPE *querys,

                                    __global TYPE *querys_grad,

                                    __global TYPE *keys,

                                    __global TYPE *scores_grad,

                                    int key_size,

                                    int units,

                                    int current)

  {
```

Note that we talked about distributing the gradient into the Query and Key tensors. In the kernel parameters, there is a pointer only to the Query error gradient buffer. This situation is made possible by the use of a concatenated buffer, in which we have already saved the error gradient at the level of the Value tensor. Now we add error gradients at the level of the Query and Key tensors to the same buffer.

In the kernel body, we determine the ordinal number of the analyzed attention head based on the thread identifier and the number of used attention heads considering the total number of tasks launched.

```
const int h = get_global_id(0);

   const int heads = get_global_size(0);

   int shift_query = key_size * h;

   int shift_key = key_size * (heads + h);

   int shift_score = units * h;
```

Here we also define the offsets in the data buffers before the beginning of the analyzed vectors.

Next, we organize a system of two nested loops, in the body of which we will determine the error gradients at the level of the tensors we are looking for. To do this, multiply the error gradient at the level of the dependency coefficient vector by the opposite tensor.

```
//--- Gradient distribution on Querys and Keys

   const TYPE k = 1 / sqrt((TYPE)key_size);

//---

   for(int i = 0; i < key_size; i++)

        {

      TYPE grad_q = 0;

      TYPE grad_k = 0;

      for(int s = 0; s < units; s++)

        {

         grad_q += keys[key_size * (s * heads + h) + i] *

                                               scores_grad[shift_score + s];

         if(s == current)

            grad_k += querys[key_size * h + i] *

                                           scores_grad[units * h + current];

        }

      querys_grad[shift_query + i] = grad_q * k;

      querys_grad[shift_key + i] = grad_k * k;

     }

  }
```

Note that we calculate the error gradient only for the current element of the sequence and save the obtained values in the corresponding elements of the error gradient buffer.

As a result of all iterations of our loop system, we get a fully filled concatenated tensor of error gradients of all three entities (Query, Key, and Value). We complete the work on building the OpenCL program and move on to building the functionality on the side of the main program.

To make it more convenient to manage the constructed kernels in the main program, let's create named constants for calling kernels and accessing their elements. To do this, we open our constants file [defines.mqh](https://www.mql5.com/en/neurobook/index/realization/basic/constants) and create kernel access constants in it.

```
#define def_k_GPTFeedForward           34

#define def_k_GPTScoreGradients        35

#define def_k_GPTHiddenGradients       36
```

Then we add access constants to kernel parameters.

```
//--- GPT feed-forward pass

#define def_gptff_querys               0

#define def_gptff_keys                 1

#define def_gptff_scores               2

#define def_gptff_values               3

#define def_gptff_outputs              4

#define def_gptff_key_size             5

#define def_gptff_units                6

#define def_gptff_current              7
```

```
//--- determine the gradient at the matrix of GPT dependency coefficients

#define def_gptscr_scores              0

#define def_gptscr_scores_grad         1

#define def_gptscr_values              2

#define def_gptscr_values_grad         3

#define def_gptscr_outputs_grad        4

#define def_gptscr_scores_temp         5

#define def_gptscr_window              6

#define def_gptscr_units               7

#define def_gptscr_current             8
```

```
//--- gradient distribution via GPT

#define def_gpthgr_querys              0

#define def_gpthgr_querys_grad         1

#define def_gpthgr_keys                2

#define def_gpthgr_scores_grad         3

#define def_gpthgr_key_size            4

#define def_gpthgr_units               5

#define def_gpthgr_current             6
```

After that, we go to the dispatch service class of the CNet neural network model and, in the OpenCL initialization method InitOpenCL, we change the total number of kernels in our program. Next, we initialize the creation of new kernels in the OpenCL context.

```
bool CNet::InitOpenCL(void)

  {

   ......

   if(!m_cOpenCL.SetKernelsCount(37))

        {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }

   ......

   if(!m_cOpenCL.KernelCreate(def_k_GPTFeedForward, "GPTFeedForward"))

        {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }

   if(!m_cOpenCL.KernelCreate(def_k_GPTScoreGradients, "GPTCalcScoreGradient"))

        {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }

   if(!m_cOpenCL.KernelCreate(def_k_GPTHiddenGradients, "GPTCalcHiddenGradient"))

        {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }

//---

   return true;

  }
```

This concludes the preparatory work and goes directly to the methods of our CNeuronGPT class. In them, we have to perform three stages of work to call each kernel:

- Preparing the input data and transferring it to the memory of the OpenCL context.

- Placing the kernel in the execution queue.

- Loading the results of program execution into the memory of the main program.

First, we modify the CNeuronGPT::FeedForward method. In the block for organizing multi-threaded computing using OpenCL, we first check for the presence of an already created buffer in the memory of the OpenCL context.

```
bool CNeuronGPT::FeedForward(CNeuronBase *prevLayer)

  {

   ......

   for(int layer = 0; layer < m_iLayers; layer++)

        {

   ......

      //--- branching of the algorithm by the computing device

      if(!m_cOpenCL)

        {

         // Program block using standard MQL5 tools

   ......

        }

      else // OpenCL block

        {

         //--- checking data buffers

         if(Querys.GetOutputs().GetIndex() < 0)

            return false;

         if(Keys.GetOutputs().GetIndex() < 0)

            return false;

         if(Values.GetOutputs().GetIndex() < 0)

            return false;

         if(Scores.GetOutputs().GetIndex() < 0)

            return false;

         if(AttentionOut.GetOutputs().GetIndex() < 0)

            return false;
```

When all buffers have been created, and those that are necessary for kernel operation have been passed to the OpenCL context memory, we pass pointers to the used data buffers and the necessary constants to the kernel parameters.

```
//--- pass parameters to the kernel

         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTFeedForward,

                                def_gptff_keys, Keys.GetOutputs().GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTFeedForward,

                     def_gptff_outputs, AttentionOut.GetOutputs().GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTFeedForward,

                            def_gptff_querys, Querys.GetOutputs().GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTFeedForward,

                            def_gptff_scores, Scores.GetOutputs().GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTFeedForward,

                            def_gptff_values, Values.GetOutputs().GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgument(def_k_GPTFeedForward,

                                             def_gptff_key_size, m_iKeysSize))

            return false;

         if(!m_cOpenCL.SetArgument(def_k_GPTFeedForward,

                                                   def_gptff_units, m_iUnits))

            return false;

         if(!m_cOpenCL.SetArgument(def_k_GPTFeedForward,

                                       def_gptff_current, m_iCurrentPosition))

            return false;
```

At this stage, the preparatory work is completed. Let's move on to the stage of placing the kernel in the execution queue. Here, we first create two dynamic arrays in which we specify the offset and the number of running threads in each task subspace. Then call the m_cOpenCL.Execute method that places the kernel in the queue.

```
//--- Place a kernel in the queue

         int off_set[] = {0};

         int NDRange[] = {m_iHeads};

         if(!m_cOpenCL.Execute(def_k_GPTFeedForward, 1, off_set, NDRange))

            return false;

        }
```

This concludes the CNeuronGPT::FeedForward method. But we still have to do similar work in the CNeuronGPT::CalcHiddenGradient method of the backpropagation algorithm.

Let me remind you that in order to implement the backpropagation method, we have created two kernels that will be called sequentially one after the other. Therefore, the kernel maintenance work must be repeated for each of them.

First, let's create data buffers for the first kernel.

```
bool CNeuronGPT::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

   ......

   for(int layer = m_iLayers - 1; layer >= 0; layer--)

        {

   ......

      //--- branching of the algorithm by the computing device

      attention_grad = AttentionOut.GetGradients();

      if(!m_cOpenCL)

        {

         // Program block using standard MQL5 tools

   ......

        }

      else // OpenCL block

        {

         //--- checking data buffers

         if(Values.GetOutputs().GetIndex() < 0)

            return false;

         if(Querys.GetGradients().GetIndex() < 0)

            return false;

         if(Scores.GetOutputs().GetIndex() < 0)

            return false;

         if(attention_grad.GetIndex() < 0)

            return false;

         if(Scores.GetGradients().GetIndex() < 0)

            return false;

         if(m_iScoreTemp < 0)

            return false;
```

Following our algorithm for working with the OpenCL context, after creating data buffers and passing all the necessary information to the context memory, we pass pointers to the used data buffers and constants for executing the program algorithm to the parameters of the kernel being launched.

```
//--- pass parameters to the kernel

         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTScoreGradients,

                           def_gptscr_outputs_grad, attention_grad.GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTScoreGradients,

                            def_gptscr_scores, Scores.GetOutputs().GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTScoreGradients,

                     def_gptscr_scores_grad, Scores.GetGradients().GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTScoreGradients,

                                         def_gptscr_scores_temp, m_iScoreTemp))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTScoreGradients,

                            def_gptscr_values, Values.GetOutputs().GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTScoreGradients,

                     def_gptscr_values_grad, Querys.GetGradients().GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgument(def_k_GPTScoreGradients,

                                               def_gptscr_window, m_iKeysSize))

            return false;

         if(!m_cOpenCL.SetArgument(def_k_GPTScoreGradients,

                                                    def_gptscr_units, m_iUnits))

            return false;

         if(!m_cOpenCL.SetArgument(def_k_GPTScoreGradients,

                                         def_gptscr_current, m_iCurrentPosition))

            return false;
```

Note that instead of the Value tensor error gradient buffer, we pass a pointer to the gradient buffer of the inner neural layer Querys. This is because we used a concatenated error gradient buffer for all three tensors. To eliminate the subsequent data copy operation, we will immediately write the data to the concatenated buffer.

After that, we perform the operation of placing the kernel in the queue. Let me remind you that we are launching a kernel to perform tasks in one-dimensional space in the context of attention heads.

Let's specify the offset in the task space and the number of threads to be started in the corresponding dynamic arrays. After that, we call the method of queuing our kernel.

```
//--- Place the kernel in queue

         int off_set[] = {0};

         int NDRange[] = {m_iHeads};

         if(!m_cOpenCL.Execute(def_k_GPTScoreGradients, 1, off_set, NDRange))

            return false;
```

This concludes the work on the first kernel, and we move on to building a similar algorithm for the second kernel of the backpropagation pass.

Now we will check the additional buffers in the memory of the OpenCL context.

```
if(Querys.GetOutputs().GetIndex() < 0)

            return false;

         if(Keys.GetOutputs().GetIndex() < 0)

            return false;
```

We pass the parameters to the kernel.

```
if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTHiddenGradients,

                                 def_gpthgr_keys, Keys.GetOutputs().GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTHiddenGradients,

                             def_gpthgr_querys, Querys.GetOutputs().GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTHiddenGradients,

                      def_gpthgr_querys_grad, Querys.GetGradients().GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTHiddenGradients,

                      def_gpthgr_scores_grad, Scores.GetGradients().GetIndex()))

            return false;

         if(!m_cOpenCL.SetArgument(def_k_GPTHiddenGradients,

                                              def_gpthgr_key_size, m_iKeysSize))

            return false;

         if(!m_cOpenCL.SetArgument(def_k_GPTHiddenGradients,

                                                    def_gpthgr_units, m_iUnits))

            return false;

         if(!m_cOpenCL.SetArgument(def_k_GPTHiddenGradients,

                                        def_gpthgr_current, m_iCurrentPosition))

            return false;
```

After that, we will put the kernel in the execution queue. Note that this time we do not create arrays of offset and dimensionality of the task space. We simply use the arrays created during the execution of the previous kernel without modification.

```
if(!m_cOpenCL.Execute(def_k_GPTHiddenGradients, 1, off_set, NDRange))

            return false;

        }
```

This completes the work on building a GPT model class, and we can proceed to evaluate the results of the work done.

## Comparative testing of implementations

We have completed the CNeuronGPT neural layer class using the attention mechanisms. In this class, we attempted to recreate the GPT (Generative Pre-trained Transformer) model proposed by the OpenAI team in 2018. This model was developed for language tasks but later showed quite good results for other tasks as well. The third generation of this model (GPT-3) is the most advanced language model at the time of writing this book.

The distinguishing feature of this model from other variations of the Transformer model is its autoregressive algorithm. In this case, the model is not fed with the entire volume of data describing the current state but only the changes in the state. In language problem solving examples, we can input into the model not the whole text at once, but one word at a time. Furthermore, the output generated by the model represents a continuation of the sentence. We input this word again into the model without repeating the previous phrase. The model maps it to the stored previous states and generates a new word. In practice, such an autoregressive model allows the generating of coherent texts. By avoiding the reprocessing of previous states, the model's computational workload is significantly reduced without sacrificing its performance quality.

We will not set the task of generating a new chart candlestick. For a comparative analysis of the model performance with previously discussed architectural solutions, we will keep the same task and the previously used training dataset. However, we will make the task more challenging for this model. Instead of providing the entire pattern as before, we will only input a small part of it consisting of the last five candles. To do this, let's modify our test script a bit.

We will write the script for this test to the file gpt_test.mq5. As a template, we take one of the previous attention model testing scripts: [attention_test.mq5](https://www.mql5.com/en/neurobook/index/transformer/self-attention/tr_comparison). At the beginning of the script, we define a constant for specifying the size of the pattern in the training dataset file and external parameters for configuring the script.

```
#define GPT_InputBars         5

#define HistoryBars           40

//+------------------------------------------------------------------+

//| External parameters for script operation                         |

//+------------------------------------------------------------------+

// Name of the file with the training sample

input string   StudyFileName = "study_data.csv";

// File name for recording the error dynamics

input string   OutputFileName = "loss_study_gpt.csv";

// Number of historical bars in one pattern

input int      BarsToLine     = 40;

// Number of input layer neurons per 1 bar

input int      NeuronsToBar   = 4;

// Use OpenCL

input bool     UseOpenCL      = false;

// Batch size for updating the weights matrix

input int      BatchSize      = 10000;

// Learning rate

input double   LearningRate   = 0.00003;

// Number of hidden layers

input int      HiddenLayers   =  3;

// Number of neurons in one hidden layer

input int      HiddenLayer    =  40;

// Number of loops of updating the weights matrix

input int      Epochs         =  1000;
```

As you can see, all the external parameters of the script have been inherited from the test script of the previous model. The constant for the size of the pattern in the training dataset is necessary for organizing the correct loading of data because, in this implementation, the size of the data passed to the model will be significantly different from the size of the pattern in the training dataset. I didn't make this constant an external parameter because we are using a single training dataset, so there's no need to change this parameter during testing. At the same time, the introduction of an additional external parameter can potentially add confusion for the user.

After declaring the external parameters of the test script we are creating, we include our library for creating neural network models.

```
//+------------------------------------------------------------------+

//| Connecting the neural network library                            |

//+------------------------------------------------------------------+

#include "..\..\..\Include\NeuroNetworksBook\realization\neuronnet.mqh"
```

Here we finish creating global variables and can proceed with the script.

In the body of the script, we need to make changes to two functions. The first changes will be made to the CreateLayersDesc function that describes the architecture of the model. As mentioned above, we will only feed information about the last five candlesticks to the model input. So, we reduce the size of the raw data layer to 20 neurons. But we will make the script architecture flexible and specify the size of the source data layer as the product of the external parameter of the number of neurons per description of one candlestick in NeuronsToBar and the constant of the number of candlesticks to load in GPT_InputBars.

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

   int prev_count = descr.count = NeuronsToBar * GPT_InputBars;

   descr.window       = 0;

   descr.activation   = AF_NONE;

   descr.optimization = None;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }
```

Note that in case of an error occurring while adding an object to the dynamic array, we output a message to the log for the user and make sure to delete the objects we created before the script finishes. It should become a good practice for you to always clean up memory before the program terminates, whether it's normal termination or due to an error.

After adding a neural layer to the dynamic array of descriptions, we proceed to the next neural layer. We create a new instance of an object to describe the neural layer. We cannot use the previously created instance because the variable only holds a pointer to the object. This same pointer was passed to the dynamic array of pointers to objects describing neural layers. Therefore, when making changes to the object through the pointer in the local variable, all new data will be reflected when accessing the object through the pointer in the dynamic array. Thus, by using one pointer, we will only have copies of the same pointer in the dynamic array, and the program will create a model consisting of identical neural layers instead of the desired architecture.

```
//--- GPT block

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      delete descr;

      return false;

     }
```

As the second layer, we will create a GPT block. The model will know about this from the defNeuronGPT constant in the type field of the created neural layer.

In the count field, we will specify the stack size to store the pattern information. Its value will determine the size of the buffers for the Key and Value tensors, and will also affect the size of the vector of dependency coefficients Score.

We will set the size of the input window equal to the number of elements in the previous layer, which we have saved in a local variable.

The size of the description vector of one element in the Key tensor will be equal to the number of description elements of one candlestick. This is the value we used when performing previous tests with attention models. This approach will help us to put more emphasis on the impact of the solution architecture itself, rather than the parameters used.

We also transfer the rest of the parameters unchanged from the scripts of previous tests with attention models. Among them are the number of attention heads used and the parameter optimization function. I'll remind you that the activation functions for all internal neural layers are defined by the Transformer architecture, so there's no need for an additional activation function for the neural layer here.

```
descr.type = defNeuronGPT;

   descr.count = BarsToLine;

   descr.window = prev_count;

   descr.window_out = NeuronsToBar; // Size of Key vector

   descr.step = 8;                  // Attention heads

   descr.layers = 4;

   descr.activation = AF_NONE;

   descr.optimization = Adam;
```

Besides, when testing the Multi-Head Self-Attention architecture, we created four identical neural layers. Now, to create such an architecture, we only need to create one description of a neural layer and specify the number of identical neural layers in the layers parameter.

We add the created description of the neural layer to our collection of descriptions of the architecture of the created model.

```
if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }
```

Next comes a block of hidden fully connected neural layers, transferred in an unchanged form from the scripts of the previous tests, as well as the results layer. At the output of our model, there will be a results layer represented by a fully connected neural layer with two elements and a linear activation function.

The next block we will modify is the LoadTrainingData function for loading the training sample.

First, we create two dynamic data buffer objects. One will be used for loading pattern descriptions, and the other for target values.

```
bool LoadTrainingData(string path, CArrayObj &data, CArrayObj &result)

  {

   CBufferType *pattern;

   CBufferType *target;
```

After that, we open the training dataset file for reading. When opening the file, we use the FILE_SHARE_READ flag, which allows other programs to read this file without blocking it.

```
//--- open the file with the training dataset

   int handle = FileOpen(path, FILE_READ | FILE_CSV | FILE_ANSI |

                               FILE_SHARE_READ, ",", CP_UTF8);

   if(handle == INVALID_HANDLE)

     {

      PrintFormat("Error opening study data file: %d", GetLastError());

      return false;

     }
```

Now we check the resulting file handle.

After successfully opening the training dataset file, we create a loop to read the data up to the end of the file. To enabel the script to be forcibly stopped, we will add the IsStopped function to check the interruption of the program closure.

```
//--- display the progress of training data loading in the chart comment

   uint next_comment_time = 0;

   uint OutputTimeout = 250; // not more than once every 250 milliseconds

//--- organize a loop to load the training sample

   while(!FileIsEnding(handle) && !IsStopped())

     {

      if(!(pattern = new CBufferType()))

        {

         PrintFormat("Error creating Pattern data array: %d", GetLastError());

         return false;

        }

      if(!pattern.BufferInit(1, NeuronsToBar * GPT_InputBars))

         return false;

      if(!(target = new CBufferType()))

        {

         PrintFormat("Error creating Pattern Target array: %d", GetLastError());

         return false;

        }

      if(!target.BufferInit(1, 2))

         return false;
```

In the body of the loop, we create new instances of data buffers for writing individual patterns and their target values, for which we have already declared local variable pointers earlier. As always, we control the process of object creation. Otherwise, there is an increased risk of encountering a critical error when subsequently accessing the created object.

Its worth pointing out that we will create new objects at each iteration of the loop. This is due to the principles of working with pointers to object instances which were described a bit above when creating the model description.

After successful creation of objects, we proceed directly to reading the data. When creating a training dataset, we first recorded descriptions of 40 candlestick patterns followed by 2 target value elements. We will read the data in the same sequence. First, we organize a loop to read the pattern description vector. We will read from the file one value at a time into a local variable, while simultaneously checking the position of the loaded element. We will only save those elements in the data buffer that fall within the size of our analysis window.

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

We read the target values in the same way, only here we leave both values.

```
for(int i = 0; i < 2; i++)

         target.m_mMatrix[0, i] = (TYPE)FileReadNumber(handle);
```

After successfully reading information about one pattern from the file, we save the loaded information into dynamic arrays of our database. We save the pattern information in the dynamic data array and the target values in the result array.

```
if(!data.Add(pattern))

        {

         PrintFormat("Error adding study data to array: %d", GetLastError());

         return false;

        }
```

```
if(!result.Add(target))

        {

         PrintFormat("Error adding study data to array: %d", GetLastError());

         return false;

        }
```

Meanwhile, we monitor the process of operations.

At this point, we have fully loaded and saved information about one pattern. Before moving on to loading information about the next pattern, let's display on the chart of the instrument the number of loaded patterns for visual control by the user.

Lets move on to the next iteration of the loop.

```
//--- output download progress in chart comment

      //--- (not more than once every 250 milliseconds)

      if(next_comment_time < GetTickCount())

        {

         Comment(StringFormat("Patterns loaded: %d", data.Total()));

         next_comment_time = GetTickCount() + OutputTimeout;

        }

     }

   FileClose(handle);

   return(true);

  }
```

When all iterations of the loop are complete, the two dynamic arrays (data and result) will contain all the information about the training dataset. We can close the file and at the same time terminate the data loading block. This completes the function.

GPT is a regression model. This means it is sensitive to the sequence of input elements. To meet such a requirement of the model for the training loop, let's apply the developments of a recurrent algorithm. We randomly select only the first element of the training batch and, in the interval between model parameter updates, we input consecutive patterns.

```
bool NetworkFit(CNet &net, const CArrayObj &data, const CArrayObj &target,

                                                     VECTOR &loss_history)

  {

//--- training

   int patterns = data.Total();

//--- loop through epochs

   for(int epoch = 0; epoch < Epochs; epoch++)

     {

      ulong ticks = GetTickCount64();

      //--- training by batches

      //--- select a random pattern

      int k = (int)((double)(MathRand() * MathRand()) / MathPow(32767.0, 2) *

                                                   (patterns - BarsToLine-1));

      k = fmax(k, 0);

      for(int i = 0; (i < (BatchSize + BarsToLine) && (k + i) < patterns); i++)

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

         if(i < BarsToLine)

            continue;

         if(!net.Backpropagation(target.At(k + i)))

        {

            PrintFormat("Error in Backpropagation: %d", GetLastError());

            return false;

           }

        }

      //--- reconfigur the network weights

      net.UpdateWeights(BatchSize);

      printf("Use OpenCL %s, epoch %d, time %.5f sec",

                (string)UseOpenCL, epoch, (GetTickCount64() - ticks) / 1000.0);

      //--- report on a bygone epoch

      TYPE loss = net.GetRecentAverageLoss();

      Comment(StringFormat("Epoch %d, error %.5f", epoch, loss));

      //--- remember the epoch error to save to file

      loss_history[epoch] = loss;

     }

   return true;

  }
```

Meanwhile, we monitor the process of operations.

Further script code is transferred in an unchanged form.

Now we will run the script and compare the results with those obtained earlier when testing the previous models.

We performed the first test with all training parameters intact and a single layer in the GPT block. The graph of the model error in the learning dynamics has relatively large fluctuations. This can be caused by the unevenness of the data distribution between weight matrix updates due to a lack of data shuffling and a reduction in the amount of data fed into the model, which results in a decreased gradient error propagation to the weight matrix at each feed-forward iteration. I would like to remind you that during the implementation of the model, we discussed the issue of gradient error propagation only within the scope of the current state.

At the same time, despite the significant noise, the proposed architecture raises the quality bar for the model performance. It demonstrates the highest performance among all the models considered.

Testing the GPT model

Zooming up the graph demonstrates how well the model lowers the minimum error threshold.

Here it should be added that during testing, we trained our model "from scratch". The authors of the architecture suggest unsupervised pre-training of the GPT block on a large dataset and then fine-tuning the pre-trained model for specific tasks during supervised learning.

Testing the GPT model

Let's continue testing our implementation. All known implementations of the GPT architecture use multiple blocks of this architecture. For the next test, we increased the number of layers in the GPT block to four. The rest of the script parameters are left unchanged.

The testing results were as expected. Increasing the number of neural layers invariably leads to an increase in the total number of model parameters. A larger number of parameters requires a greater number of update iterations to achieve optimal results. In doing so, the model learns better to separate patterns and is more prone to overlearning. This is what the results of the model training demonstrated. We see the same noise in the error plot. In addition, we observe an even greater reduction in the minimum error metrics of the model.  

Testing the GPT 4 layer model

Testing the GPT 4 layer model

We would like to add that, from the practice of using attention models, their benefits are most clearly demonstrated when long sequences are used. GPT is no exception. It's more like the other way around. Since the model recalculates only the current state and uses archived copies of previous states, this significantly reduces the number of operations when analyzing large sequences. As the number of iterations decreases, the speed of the whole model increases.

For the next test, we increase the stack size to 60 candles. Thanks to the architectural design of GPT, we can increase the length of the analyzed sequence by simply increasing one external parameter without changing the program code. Among other things, we do not need to change the amount of data fed to the model input. It should be noted that changing the stack size does not change the number of model parameters. Yes, increasing the stack of Key and Value tensors leads to an increase in the Score vector of dependency coefficients. But there is absolutely no change in any of the weight matrices of the internal neural layers.

The test results demonstrated a reduction in the model's performance error. Moreover, the overall trend suggests that there is a high likelihood of seeing improved results from the model as we continue with further training.

Testing the GPT model with an enlarged stack

Testing the GPT model with an enlarged stack

We have constructed yet another architectural model of a neural layer. The testing results of the model using this new architectural solution demonstrate significant potential in its utilization. At the same time, we employed small models with rather short training periods. This is sufficient for demonstrating the functionality of architectural solutions but not adequate for real-world data usage. As practice shows, achieving optimal results requires various experiments and unconventional approaches. In most cases, the best results are achieved through a blend of different architectural solutions.

## Comparative testing of Attention models

We have done a lot of work while studying and implementing the Multi-Head Self-Attention algorithm. We even managed to implement it on several platforms. Earlier we created new classes only for our library in MQL5. This time we got acquainted with the possibility of creating custom neural layers in Python using the TensorFlow library. Now it's time to look at the results of our labor and evaluate the opportunities offered to us by the new technology.

As usual, we start testing with models created using standard MQL5 tools. We have already started this work when testing the operation of the Self-Attention algorithm. To run the new test, we will take [attention_test.mq5](https://www.mql5.com/en/neurobook/index/transformer/self-attention/tr_comparison) from the previous test and create a copy of it named attention_test2.mq5.

When creating a new class for multi-head attention, we largely inherited processes from the Self-Attention algorithm. In some cases, methods were inherited entirely, while in others they used the Self-Attention methods as a foundation and created new functionality through minor adjustments. So here, the testing script will not require major changes, and all changes will affect only the block for declaring a new layer.

Our first change is, of course, the type of neural layer we are creating. In the type parameter, we will specify the defNeuronMHAttention constant, which corresponds to the multi-head attention class.

We also need to indicate the number of attention heads used. We will specify this value in the step parameter. I agree that the name of the parameter is not at all consonant. However, I decided not to create an additional parameter but to use the available free fields instead.

After that, we will once again go through the script code and carefully examine the key checkpoints for executing operations.

That's it. Such changes are sufficient for the first test to evaluate the net impact of the solution architecture on the model results.

```
//--- Attention layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }

   descr.type = defNeuronMHAttention;

   descr.count = BarsToLine;

   descr.window = NeuronsToBar;

   descr.window_out = 8;

   descr.step = 8;                // Number of attention heads

   descr.optimization = Adam;

   descr.activation_params[0] = 1;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }
```

We conducted the testing directly on the same training dataset, keeping all other model parameters unchanged. Their results are shown in the graph below.

We have seen that even the use of Self-Attention gives us superiority over the previously considered architectural solutions of convolutional and recurrent models. Increasing the attention heads also yields a positive result.

The presented graphs depicting the neural network error dynamics on the training dataset clearly show that models using the attention mechanism train much faster than other models. Increasing the number of parameters when adding attention heads requires slightly more training time. However, this increase is not critical. At the same time, additional attention heads can reduce the error in the model operation.

Comparative Testing of Attention Models

If we zoom in we can clearly see that the error of models using the attention mechanism remains lower throughout the entire training. At the same time, the use of additional attention heads further improves the performance.

Comparative Testing of Attention Models

Note that the model using the convolutional layer has the highest number of trainable parameters. This provides an additional reason to reconsider the rationality of resource usage and start exploring new technologies that emerge every day.

When talking about the rational use of resources, I also want to caution against an inadequate increase in the number of attention heads being used. Each attention head means the consumption of additional resources. Find a balance between the amount of resources consumed, and the benefits that they give to the overall result. There is no universal answer. Such a decision should be made on a case-by-case basis.

The results of test training of models written in Python also confirm the above conclusions. Models that employ attention mechanisms train faster and are also less susceptible to model overfitting. This is confirmed by a smaller gap between the error graphs for training and validation. Increasing the number of used attention layers allows the reduction of the overall model error under otherwise equal conditions.

As you zoom in, you'll notice that models using attention mechanisms have straighter lines and fewer breaks. This indicates a clearer identification of dependencies and a progressive movement towards minimizing error. Partly, this can be explained by the normalization of results within the Self-Attention block which allows you to have a result with the same statistical indicators at the output.

The graph of the test results for the Accuracy metric also confirms our conclusions.

Results of test training of Python attention models

Results of test training of Python attention models

Results of test training of Python attention models

Results of test training of Python attention models

## Description of the Multi-Head Self-Attention architecture

The Self-Attention technology discussed earlier identifies dependencies between sequence objects in a certain context and then ranks them using the Softmax function. However, when solving practical problems, it is not always possible to give such an assessment unambiguously. Typically, dependency coefficients between objects change greatly when the point of view or context of the element being analyzed, changes. The final decision on element dependencies is always a compromise. The use of Multi-Head Self-Attention is specifically designed to help discover dependencies between elements by comprehensively considering the input data. The additional input trainable matrix of weights will help the model learn to find this compromise.

Perhaps the simplest solution to such a problem would be to expand our CNeuronAttention attention by adding an array of Self-Attention blocks to it. This approach is possible, but it is irrational. It leads to an increase in the number of objects proportionally to the increase in the number of attention heads. Furthermore, the sequential execution of operations for each attention head does not allow the organization of simultaneous parallel computation of attention for all heads. Additionally, the subsequent operation related to the concatenation of results of attention heads will also require resource and time overhead.

There is a solution, which lies in the realm of matrix operations in mathematics. Having knowledge and understanding of matrix operations in mathematics greatly aids in comprehending the mathematics of neural networks and provides a clear picture of the potential for dividing operations into parallel threads.

Let's go through the Self-Attention algorithm and think about transforming operations to implement Multi-Head Self-Attention.

- First, we calculate vectors Query, Key, and Value. These vectors are calculated by multiplying each element of the original sequence by the corresponding matrix WQ, WK, and WV.

To organize Multi-Head Self-Attention, we need to repeat this operation based on the number of attention heads. Let's start with a simple example using three attention heads.

I think everything is clear here.

Now let's look at the dimensions of tensors. Remember that the architecture of the model provides for the same number of sequence elements at all stages. Each element of the sequence is described by a certain vector of values. Since the Self-Attention mechanism is applied in the same way to each element of the sequence, we can analyze operations only with the description vector of one element, as an example. Moreover, the size of this vector is the same for the tensors of the original data and values. However, it may differ from the dimension of the description vector of one element of the sequence in the query and key tensors. Let's use nI for the size of the source data vector and nK for the size of the key vector. Then the tensors will have the following dimensions.

The specified tensor sizes are applicable to all attention heads. Let's try to combine the corresponding weight matrices into one large one.

Such weight matrices will have size nI*3nK for query matrices WQC and WKC. The matrix WVC will have the size nI*3nI, where 3 is the number of attention heads.

Let's substitute the concatenated matrices into the formulas for determining vectors.

According to the rules of matrix multiplication, we obtain the following tensor sizes.

Compare the tensor sizes in the two tables: they are very similar. The only difference is that they are multiplied by the number of attention heads. What practical value does it have for us? It's all very straightforward. Instead of creating multiple instances of objects for each attention head, we can create just one object for computing each entity. As when organizing a similar process in the Self-Attention mechanism, we can use our convolutional layers, but we will need to increase the window size of the results proportionally to the number of attention heads.

 

- Next, we define pairwise dependencies between the elements of the sequence. To do this, we will multiply the Query vector with the Key vectors of all elements of the sequence. This iteration is repeated for the Query vector of each element of the sequence. As a result of this iteration, we obtain a Score matrix of size N*N, where N is the size of the sequence.

As a result of this operation, we expect to obtain one coefficient of dependency between a pair of sequence elements for each attention head. However, the operation of multiplying two concatenated vectors will return only one value. As in the case of single-headed Self-Attention.

We can change the dimensionality of vectors and convert them into two-dimensional matrices. This makes sense, as we can allocate the data for each attention head into a separate row vector. However, by adding them to the formula above, we will get a square matrix with a side length equal to the number of attention heads, whereas we expected to obtain a vector with a size equal to the number of heads.

There is still a way out. Let's remember the matrix multiplication rule.

We will substitute here our two-dimensional matrices of multi-head attention. Don't forget that the second matrix is transposed before multiplication.

As you can see, the vector we expected to obtain forms the diagonal of the matrix of results. And all other operations are just a waste of resources for us. But we can split this procedure into operations. For example, we will not transpose the key matrix and use the Hadamard product of matrices (element-wise matrix multiplication).

After this, to obtain the expected result, all we need to do is add the elements of the matrix row by row.

In the end, we got the result in two operations instead of one. However, it's important to note two things:

- We use a transposed matrix In the Self-Attention formula, which is also an operation on a matrix, although it is not highlighted separately. And its implementation also requires resources. When splitting into operations, we abandoned this procedure.

- The vector of coefficients is determined in two operations, regardless of the number of attention heads.

- The next step is to divide the resulting values by the square root of the dimension of the Key vector and normalize it with the Softmax function in the context of each Query. In this way, we obtain the coefficients of pairwise interdependence between sequence elements.

At this point, we will not complicate or simplify anything. Matrix division by a constant is always performed element-wise regardless of the matrix size, but we will need to normalize the data on a per-attention-head basis.

- We multiply each Value vector by the corresponding interdependence coefficient and obtain the adjusted value of the element. The goal of this iteration is to focus on relevant elements and reduce the influence of irrelevant values.

To solve this problem, we will use the techniques applied in paragraph 2. First, let's change the dimension of the vector of values and reduce it to a two-dimensional matrix. In it, the rows will correspond to each individual head of attention.

After this, we can use element-wise multiplication of the dependency coefficient vector by the matrix of values.

- Then we summarize all the adjusted Value vectors for each element. The result of this operation will indeed be the vector of output values of the Self-Attention layer.

In the last point, there is nothing more to add. We will summarize the value of vector elements separately in the context of Query queries and attention heads. We can easily parallelize the execution of this task by creating a separate thread for finding each individual vector.

After completing all the points of the Self-Attention mechanism in the mode with multiple attention heads, we receive a vector of results for each attention head. Consequently, the overall size of the tensor of results will exceed the size of the original data tensor proportionally to the number of heads. To reduce the dimensionality, the Multi-Head Self-Attention algorithm provides for multiplying the concatenated tensor of results by an additional weight matrix W0. As you can imagine, this procedure is very similar to the operation of a fully connected neural layer without an activation function. We performed similar operations in step 1 to determine Query, Key, and Values ​​vectors. This means that we can use the same solution and use the previously created convolutional layers.

Here, we can also note another point. When describing the operation of the Self-Attention block, we paid attention to the moment when the size of the vectors describing one element of the sequence of Value tensors and the source data are equal. This requirement was based on the need for subsequent addition of tensors of Self-Attention results and initial data. In the case of multi-head attention, we always end up with a concatenated tensor of results that is larger than the tensor of the original data. To align them, multiplication of the result tensor by the matrix W0 is used. Therefore, in order to save resources, we can reduce the dimensionality of the description vector of a single sequence element in the Value tensor without risking errors in subsequent data processing.

The rest of the algorithm of the transformer encoder remains unchanged, and we can leverage the developments from the previous section.

Now that we have a complete understanding of the principles behind the algorithm, we can proceed to its implementation.

## Building Multi-Head Self-Attention in MQL5

When implementing the Multi-Head Self-Attention block, we can note its strong similarity with the previously considered Self-Attention block. This is not surprising, because Multi-Head Self-Attention is a logical development of Self-Attention technology. Therefore, when creating a new class, it would be quite logical to inherit not from the neural layer base class CNeuronBase but from the attention block class CNeuronAttention.

With this inheritance option, we inherit from the parent class, in addition to the methods and objects of the base class, also objects of the CNeuronAttention class, including:

- m_cQuerys — convolutional layer for the formation of the query tensor Query

- m_cKeys — convolutional layer for the formation of the key tensor Key

- m_cValues — convolutional layer for the formation of the value tensor Value

- m_cScoresis — buffer of the matrix of dependency coefficients

- m_cAttentionOut — base layer of the source data for recording the results of the Self-Attention block operation

- m_cFF1 and m_cFF2 — convolutional layers of the Feed Forward block

As we defined in the section describing the architectural solution, all objects will be used for their intended purpose. We will only increase their size in proportion to the number of attention heads. Thus, to implement the Multi-Head Self-Attention algorithm, we just need to add the internal layer of the W0 matrix and a variable for recording the number of attention heads.

```
class CNeuronMHAttention    :  public CNeuronAttention

  {

protected:

   CNeuronConv       m_cW0;

   int               m_iHeads;

public:

                     CNeuronMHAttention(void);

                    ~CNeuronMHAttention(void);

   //---

   virtual bool      Init(const CLayerDescription *desc) override;

   virtual bool      SetOpenCL(CMyOpenCL *opencl) override;

   virtual bool      FeedForward(CNeuronBase *prevLayer) override;

   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;

   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer, bool read) override;

   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,

                                   VECTOR &Beta, VECTOR &Lambda) override;

   //--- file operation methods

   virtual bool      Save(const int file_handle) override;

   virtual bool      Load(const int file_handle) override;

   //--- object identification method

   virtual int       Type(void) override const { return(defNeuronMHAttention);  }

  };
```

Regarding the class methods, we will override the standard set of methods:

- Init — class initialization method

- SetOpenCL — method for specifying the handle of the OpenCL context to be used

- FeedForward — forward pass method

- CalcHiddenGradient — method of distributing the gradient error through the hidden layer

- CalcDeltaWeights — method of distributing the error gradient to the level of the matrix of weights of the current neural layer

- UpdateWeights — method for updating the matrix of weights of the coefficients of the current neural layer

- Save — method of saving neural layer data to a file

- Load — method of loading neural layer data from a file

- Type — method for identifying the type of neural layer

Well, let's start with the class constructor. In it, we create instances of objects necessary for the full functioning of the class and initialize internal variables with default values. Above, we defined only one new object, the convolutional layer m_cW0. We will use static objects, just like in the parent class. So, in the class constructor, we just have to specify the initial value for the number of attention heads. The class destructor remains empty.

```
CNeuronMHAttention::CNeuronMHAttention(void) :  m_iHeads(8)

  {

  }
```

In the next step, we will deal with the method of initializing the class. Despite the fact that most of the objects were inherited from the parent class, we cannot use its initialization method, since using them in the Multi-Head Self-Attention algorithm will require different tensor sizes. Therefore, we will have to rewrite the initialization method completely. At the same time, to construct the initialization method, we will use an algorithm similar to the corresponding method of the parent class.

Like the similar methods of all previously discussed classes, in the method parameters, we receive a pointer to the object describing the configuration of the neural layer being created. We immediately organize a block for checking the received data. First of all, we check the validity of the received pointer. Only after confirming the validity of its relevance do we check its contents:

- The type of the neural layer to be created in the configuration description must match the type of the class (the type parameter).

- The layer you create must have at least one element of the sequence to be analyzed (the count parameter).

- The size of the description vector of one source data element must be greater than zero (the window parameter).

- The size of the key vector of one element of the sequence must be greater than zero (the window_out parameter).

- There must be at least one attention head (the step parameter).

```
bool CNeuronMHAttention::Init(const CLayerDescription *desc)

  {

//--- check the initial data

   if(!desc || desc.type != Type() ||

      desc.count <= 0 || desc.window <= 0 || desc.window_out <= 0 ||

      desc.step <= 0)

      return false;
```

It probably looks strange to use the step parameter to specify the number of attention heads. But, as you may recall, within the implementation of attention mechanisms, the step size of the input data window is always equal to the size of the window itself. Therefore, this parameter is free. To avoid an unnecessary increase in the size of the neural layer description object, we decided to make the most efficient use of the existing class variables. However, if code readability is a higher priority for you, you can always define the necessary number of variables to describe the architecture of the neural layer being created and name them accordingly.

After successfully passing through the control block, we will save the key parameters of the description of the neural layer being created into local variables.

```
//--- saving the constants

   m_iWindow = desc.window;

   m_iUnits = desc.count;

   m_iKeysSize = desc.window_out;

   m_iHeads = desc.step;
```

Like in similar methods of all previously discussed classes, the next step is to call the method of the base neural layer, in which inherited objects will be initialized. We cannot call the method of the parent class because it would create objects of different sizes, and we would need to modify those objects. And we don't want to do the same job twice. Therefore, we "jump over the head" and directly access the method of the base class.

Please note that before calling the method of the base class, we need to make some adjustments to the description of the architecture of the neural layer being created. At the same time, we do not know what plans the user has for the description object of the layer obtained in the parameters. Remember what we talked about objects and pointers to them. In the parameters, we got a pointer to the object. When we make changes to the object, they will be reflected on the side of the main program by the user. If the user applies a single object to describe multiple neural layers, there is a high probability that they will encounter an error when creating subsequent neural layers. Also, layers can be created with incorrect architecture. Therefore, we will create a new object to describe the architecture of the neural layer and populate it with the necessary parameters.

In the parent class, we have worked out a technology with the substitution of pointers to the object, result buffers and error gradients. Therefore, it doesn't matter how these objects are created in the base class method; you can specify any values for the layer size and result window in the parameters. To avoid performing unnecessary operations, we will specify them at least greater than zero.

To eliminate the creation of unnecessary objects, set the size of the source data window to zero and disable the activation function.

We leave the type of neural layer that we received in the description from the user.

Next, we call the method of the base neural layer, passing it the correct description.

```
//--- call the initialization method of the parent class

   CLayerDescription* temp = new CLayerDescription();

   if(!temp)

      return false;

   temp.type = desc.type;

   temp.optimization = desc.optimization;

   temp.activation = AF_NONE;

   temp.count = desc.count;

   temp.window_out = 1;

   temp.window = 0;

   if(!CNeuronBase::Init(temp))

     {

      delete temp;

      return false;

     }
```

In the above description of the neural layer architecture, we will change the type of the created object and its size. This is enough to create an object of concatenated results of the work of attention heads.

```
//--- initialize AttentionOut

   temp.type = defNeuronBase;

   temp.count = (int)(m_iUnits * m_iKeysSize * m_iHeads);

   if(!m_cAttentionOut.Init(temp))

     {

      delete temp;

      return false;

     }

   if(!m_cAttentionOut.GetOutputs().m_mMatrix.Reshape(m_iUnits, m_iKeysSize * m_iHeads) ||

      !m_cAttentionOut.GetGradients().m_mMatrix.Reshape(m_iUnits, m_iKeysSize * m_iHeads))

      return false;
```

After initializing the object, we will slightly change the format of the result buffers and error gradients.

Next, we have to create internal convolutional neural layers. First, we will create internal neural layers to form the Query, Key, and Value tensors. All of them receive a sequence of initial data as input. Therefore, in the window and step parameters, we will specify the size of the vector describing one element of the source data sequence.

The number of filters of the used convolutional layer, specified in the window_out parameter, should correspond to the size of the key vector of one element of the sequence. However, when discussing the architectural solution of this class, we determined the use of concatenated tensors. Therefore, we will increase the number of filters in proportion to the number of attention heads created.

The number of elements in the sequence at all stages remains constant. Therefore, we can write to the count parameter the number of elements of the original sequence received from an external program.

The Multi-Head Self-Attention architecture does not provide an activation function for the neural layers that are created. Therefore, in the activation parameter, we leave the constant AF_NONE.

The optimization method for the parameters of all neural layers is the same, and we leave this parameter unchanged.

```
//--- create a description for the inner neural layers

   if(!temp)

      return false;

   temp.type = defNeuronConv;

   temp.window = m_iWindow;

   temp.window_out = (int)(m_iKeysSize * m_iHeads);

   temp.step = m_iWindow;

   temp.count = m_iUnits;
```

First, we initialize the inner layer to create the query tensor Query. We check the result of the operation in order to exclude possible critical errors in the further execution of the method code.

```
//--- initializing Querys

   if(!m_cQuerys.Init(temp))

     {

      delete temp;

      return false;

     }

   m_cQuerys.SetTransposedOutput(true);
```

After successful initialization of the convolutional neural layer, we set the flag to transpose the result tensor. I'd like to remind you that we introduced this flag to enable the retrieval of a result tensor in which each row contains elements not from a single filter but from all filters for one sequence element.

Similarly, we initialize convolutional neural layer objects to create Key and Value tensors.

```
//--- initialize Keys

   if(!m_cKeys.Init(temp))

     {

      delete temp;

      return false;

     }

   m_cKeys.SetTransposedOutput(true);
```

Please note that during the initialization of the convolutional neural layer object to form the Value tensor, we do not align the number of used filters with the size of the input data window, as was done in the single-attention head class CNeuronAttention. The use of the W0 matrix allows us to avoid this rule. Reducing the dimensionality of the vector can indeed help save resources and reduce the execution time of operations. In turn, after recreating the complete algorithm of the Multi-Head Self-Attention method, you will be able to assess the advantages and disadvantages of such an implementation through practical examples.

```
//--- initialize Values

   if(!m_cValues.Init(temp))

     {

      delete temp;

      return false;

     }

   m_cValues.SetTransposedOutput(true);
```

After initializing the first group of internal convolutional layers, following the algorithm of the Multi-Head Self-Attention mechanism, we initialize the buffer for the dependency coefficient matrix m_cScores. Fill it with zero values, specifying the required buffer size. Again, let's draw a parallel with the CNeuronAttention class. If previously we created a square matrix with a side length equal to the number of elements in the sequence, now we need as many of these matrices as there are attention heads. At the same time, we have agreed to use a concatenated matrix. Therefore, we will increase the buffer size in proportion to the number of attention heads used. Unfortunately, MQL5 does not support three-dimensional matrices. Within the two-dimensional matrix, we will use rows to distribute the buffer across attention heads.

```
//--- initialize Scores

   if(!m_cScores.BufferInit(m_iHeads, m_iUnits * m_iUnits))

     {

      delete temp;

      return false;

     }
```

Now it's time to initialize the additional convolutional layer that performs the functionality of matrix W0 in the Multi-Head Self-Attention algorithm. Let's adjust the description of the architecture of the neural layer being created.

The type of neural layer to be created has already been specified, so we don't need to specify it again.

We determine the size of the input data window as the product of the size of the description vector of one sequence element in the Values tensor and the number of attention heads. In this implementation, we changed the size of the specified vector to the same one in the Key tensor. So, the size of the input data window is determined as the product of the size of the key vector of one sequence element and the number of attention heads (m_iKeysSize * m_iHeads).

We will equate the size of the step of the source data window to the size of the window itself.

According to the Multi-Head Self-Attention algorithm, matrix W0 is used to align the sizes of the tensor of results from the multi-head attention block with the tensor of input data. Therefore, we will specify the number of filters in this convolutional layer equal to the size of the description vector of one element of the sequence of initial data fed to the input of the Multi-Head Self-Attention block.

The Multi-Head Self-Attention algorithm does not provide an activation function for this matrix. Therefore, in the appropriate field, we leave the AF_NONE constant.

The optimization method for the weight matrices of all layers in the neural network, including the internal layers of individual blocks, is the same. Therefore, we leave the parameters indicating the optimization method used unchanged.

```
//--- initialize W0

   temp.window = (int)(m_iKeysSize * m_iHeads);

   temp.step = temp.window;

   temp.window_out = m_iWindow;

   if(!m_cW0.Init(temp))

     {

      delete temp;

      return false;

     }

   m_cW0.SetTransposedOutput(true);
```

After specifying all the necessary parameters for describing the created neural layer, we call the initialization method of our convolutional neural layer m_cW0.Init and check the results of the operations.

At the end of the initialization block of the convolutional layer m_cW0 we set the flag for transposing the result tensor.

This concludes the work on initializing the objects of the Multi-Head Self-Attention block. Next, let's move on to work on the Feed Forward block. The functionality and architecture of this block are completely transferred from the CNeuronAttention class. However, since we had to completely redefine the initialization method of the class, we will repeat the actions for initializing the internal layers m_cFF1 and m_cFF2.

The algorithm for initializing the neural layer remains the same. We will prepare a description of the neural layer to be created and call the method of its initialization. To describe the convolutional neural layer m_cFF1, we will use the description object of the convolutional neural layer which has already been used more than once in this method. Therefore, we will only specify the parameters that are being changed, as the rest are already contained in the neural layer description object.

- The size of the source data window (window) is equal to the size of the description vector of one element of the source data tensor sequence fed to the input of our Multi-Head Self-Attention block. We receive this parameter from an external program and save it in the m_iWindow variable. Consequently, we can pass the value of the specified variable as a parameter.

- We will set the step size of the input data window (step) equal to the size of the input data window itself.

- Number of filters used (window_out): according to the transformer architecture proposed by the authors, the output size of the first layer of the Feed Forward block is four times larger than the size of the original data. Let's use this coefficient. However, during the implementation of your practical tasks, you can always modify this coefficient or even add it to the configuration description of the created neural layer and conduct practical tests to determine the most suitable coefficient for your specific tasks.

- The activation function (activation): for this layer, the authors suggest using ReLU as an activation function. We replaced it with the close Swish function. The graph of this function is very close to the graph of the function proposed by the authors. At the same time, it does not contain kinks and is differentiated throughout the values.

- The optimization parameters of the balance matrix remain unchanged.

```
//--- initialize FF1

   temp.window = m_iWindow;

   temp.step = temp.window;

   temp.window_out = temp.window * 4;

   temp.activation = AF_SWISH;

   temp.activation_params[0] = 1;

   temp.activation_params[1] = 0;

   if(!m_cFF1.Init(temp))

     {

      delete temp;

      return false;

     }

   m_cFF1.SetTransposedOutput(true);
```

After we have specified all the parameters in the configuration description of the created convolutional neural layer, we will call its initialization method and check the result of the operations.

Only upon successful initialization of the convolutional neural layer object, we will set the flag for transposing the result tensor.

Now we can proceed to initialize the last object used in the class — the second convolutional layer of the Feed Forward block m_cFF2. As a result of this neural layer operation, we again return to the dimension of the tensor of the original data. Therefore, in the description object of the structure of the created neural layer, we will need to swap the values of the input data window and the number of used filters. Typically, such an operation requires a local variable to temporarily store one of the values. But in our case, the parameters of the source data window size and its pitch are equal. Hence, we will first write the number of filters of the previous layer to the size parameter of the source data window. Next, in the parameter of the number of filters, specify the value of the window step of the previous convolutional layer. And finally, let's equate the size of the step of the source data window to its size.

The architecture of the transformer does not provide an activation function for this layer. But we will provide an opportunity for the user to experiment. To do this, let's transfer the activation function and its parameters from the architecture description provided by the user to the parameters of this method.

```
//--- initialize FF2

   temp.window = temp.window_out;

   temp.window_out = temp.step;

   temp.step = temp.window;

   temp.activation = desc.activation;

   temp.activation_params = desc.activation_params;

   if(!m_cFF2.Init(temp))

     {

      delete temp;

      return false;

     }

   m_cFF2.SetTransposedOutput(true);

   delete temp;
```

Once all the necessary parameters for describing the structure of the created neural layer are specified, we call its initialization method and set the flag for transposing the result tensor. At the same time, do not forget to check the results of the operations.

Now that all the necessary objects are initialized, we can safely delete the local neural layer description object without any risk of error.

Next, we will apply the technique refined in the CNeuronAttention class and substitute pointers to result and error gradient buffers of our multi-head attention class with similar buffers from the internal convolutional neural layer,m_cFF2. This will allow us to eliminate unnecessary costs for copying data between buffers. Also, we do not need additional memory to store duplicate data. To do this, we first check the pointers and, if necessary, delete previously created objects that are not needed. Then, we pass pointers to the objects of the convolutional layer m_cFF2 into the variables.

```
//--- to avoid copying buffers, replace them

   if(!SetOutputs(m_cFF2.GetOutputs()))

      return false;

   if(m_cGradients)

      delete m_cGradients;

   m_cGradients = m_cFF2.GetGradients();

//---

   SetOpenCL(m_cOpenCL);

//---

   return true;

  }
```

In conclusion, to all objects in the method, we will pass a pointer to the used OpenCL context. After that, we exit the method with a positive result.

This concludes our work on the class initialization method. However, we have an open question. At the end of the initialization method, we called the method for passing the OpenCL context pointer. We haven't overridden it yet, and a similar method of the parent class will be called as such. It is functional enough but does not apply to objects declared in the body of this class. Among them, there is only one object: the convolutional layer of m_cW0. Therefore, the method will be relatively short.

Like the similar methods of all the previously discussed classes, the CNeuronMHAttention::SetOpenCL method in the parameters receives a pointer to the object of working with the OpenCL context. We will have to distribute it to all internal objects. First, it would be necessary to check the validity of the received pointer. Instead, we'll call a similar method of the parent class, which already has all the controls and pointer passing to inherited objects. Thus, after the completion of the parent class method, we just have to pass the pointer to the new objects that were declared in the body of this class. However, in this case, we will pass not the pointer received in the parameters but the pointer from the local variable of the class inherited from the parent object. The reason is that the method of the parent class checked the received pointer and saved it to a local variable. It also passed it to all the objects that we inherited from the parent class. Therefore, in order for all objects to work in the same context, we pass an already validated pointer to the internal objects.

```
bool CNeuronMHAttention::SetOpenCL(CMyOpenCL *opencl)

  {

//--- call a method of a parent class

   CNeuronAttention::SetOpenCL(opencl);

//--- call a similar method for the internal layer

   m_cW0.SetOpenCL(m_cOpenCL);

//---

   return(!!m_cOpenCL);

  }
```

After passing the pointer to all internal objects, in this case, it's a single convolutional layer, we exit the method and return a result indicating the validity of the used context pointer.

With that, we conclude the process of creating and initializing our multi-head attention class object and move on to the next stage, which is setting up the feed-forward pass.

## Organizing parallel computing for Multi-Head Self-Attention

We continue our steady progress on the path of knowledge and building a library for creating machine learning models within the MQL5 environment. In this section, we are planning to complete work on CNeuronMHAttention which is another class of neural layers. This class implements the Multi-Head Self-Attention algorithm. In the previous sections, we have already fully implemented the algorithm using standard MQL5 tools. Now let's supplement its functionality with the ability to use OpenCL technology to organize the computation process in multi-threaded mode using GPU resources.

We have already implemented similar work for each of the previously discussed neural layers. Let me remind you of the general algorithm for constructing this process. First, we create an OpenCL program. Next, we enhance the main program code with the functionality for calling this program and passing the necessary data in both directions. We will need to send the input data to the program before its execution and calculate the results after its execution.

As usual, we start by creating an OpenCL program. Do we really need to create a new program? Why do we need to create new kernels? The answer is obvious: we need to implement functionality. But let's recall that we inherited our class from a similar class implementing the Self-Attention algorithm. We have repeatedly talked about the continuity of these algorithms. Can we use the kernels created earlier to implement processes in this class?

Considering the similarity of processes, it would be more advantageous for us to use the same kernels for both implementations. Firstly, this reduces the number of OpenCL objects, and the system can only handle a limited number of them. Secondly, it's always more convenient to maintain and optimize one object rather than duplicating shared blocks across multiple similar objects, be it kernels or classes.

So, how can we implement this? The previously created kernels work within the same head of attention. Of course, on the main program side, we can copy data into separate buffers and sequentially invoke kernels for each attention head. This approach is possible, but it is irrational. Excessive copying of data in itself is not the best solution. Moreover, calling kernels sequentially for each attention head doesn't allow for the simultaneous calculation of all attention heads in parallel threads.

In fact, we can use the previously created kernels without unnecessary copying, by implementing some minor modifications.

One thing we have already done from the very beginning when creating the class is fully utilizing concatenated data buffers. That is, all our data buffers contain data from all attention heads at once. By transferring data to context memory, we transfer data from all attention heads. This means that on the OpenCL side, we can work with all attention heads in parallel. We just need to correctly determine the offset in the data buffer to the required values. These are the changes that we must make to the kernel.

To determine this bias, we need to understand the total number of attention heads used and the ordinal number of the working attention head. We can pass the total quantity in parameters but can't do the same for the serial number of the current one. To implement the transfer of such data, we would need to create a loop with a sequential kernel call for each attention head, which we try to avoid.

Let's remember how the function of queuing the kernel is organized. The CLExecute function has a work_dim parameter, which is responsible for the dimension of the task space. The function also receives in parameters a dynamic array global_work_size[], which indicates the total number of tasks being performed in each dimension.

```
bool  CLExecute(

// handle to the OpenCL program kernel

   int          kernel,

// dimension of the problem space

   uint         work_dim,

// initial offset in task space

   const uint&  global_work_offset[],

// total number of tasks

   const uint&  global_work_size[]

   );
```

Earlier we used only one dimension, and now we can use two. We will continue to use one dimension for iterating over the elements of the sequence and the other dimension for iterating over the attention heads.

Well, a solution has been found and we can begin implementation. But there is one more question: to create a new kernel or not. Everything points towards modifying the previously created one. But in this case, after finishing the work, we will have to take a step back and adjust the methods of the CNeuronAttention class. Otherwise, we will get a critical error when trying to launch the kernel.

For my part, I decided to make changes to the previously created kernel and the methods of the main program. You can choose your preferred options.

Now, let's look at the changes made to the feed-forward kernel.

In the kernel body, we request the identifiers of the launched thread and the total number of threads in two dimensions. The first dimension will specify the index of the processed request and the length of the sequence. The second dimension will indicate the number of the active attention head.

We also determine the offset to the beginning of the vector being analyzed in the query tensor and the attention coefficient matrix.

```
const int q = get_global_id(0);

   const int units = get_global_size(0);

   const int h = get_global_id(1);

   const int heads = get_global_size(1);

   int shift_query = key_size * (q * heads + h);

   int shift_scores = units * (q * heads + h);
```

As you can see, compared to the previous version, the kernel differs by having a second dimension that accounts for attention heads. Accordingly, the calculation of offsets is also adjusted to account for multi-head attention.

Next, we create a system of two nested loops to calculate one vector of the matrix of dependence coefficients. This is due to the fact that to calculate one element of the sequence at the output of the attention block, we need a whole vector of the matrix of dependence coefficients. Such calculation applies to one attention head.

Also, before starting the loop system, we will prepare a local variable summ to sum all the values of the vector. We will need this sum later to normalize the vector values.

The outer loop has a number of iterations equal to the number of sequence elements. It will immediately indicate the analyzed element in the key tensor Key and the column number in the attention coefficient matrix. In the body of the loop, we will determine the offset in the key tensor to the beginning of the vector of the analyzed element in the sequence and prepare a variable for calculating the result of multiplying two vectors.

In the nested loop with a number of iterations equal to the size of the key vector, we will perform the operation of multiplying the query vector by the key vector.

After completing the iterations in the nested loop, we will take the exponential of the obtained result from the vector multiplication, record the resulting value in the tensor of attention coefficient matrices, and add it to our sum of vector values.

```
TYPE summ = 0;

   for(int s = 0; s < units; s++)

     {

      TYPE score = 0;

      int shift_key = key_size * (s * heads + h);

      for(int k = 0; k < key_size; k ++)

         score += querys[shift_query + k] * keys[shift_key + k];

      score = exp(score / sqrt((TYPE)key_size));

      summ += score;

      scores[shift_scores + s] = score;

     }
```

After completing all iterations of the loop system, we will have a vector with computed but unnormalized attention coefficients for one query vector with respect to all key vectors. To complete the vector normalization process, we need to divide the contents of the vector by the sum of all its values, which we have collected in the summ variable.

To perform this operation, we will create another loop with the number of iterations equal to the number of elements in the sequence.

```
for(int s = 0; s < units; s++)

      scores[shift_scores + s] /= summ;
```

As you can see, this block differs from the previous implementation only in terms of calculating the offsets of elements in tensors. Now that we have the normalized attention vector for one query with respect to all elements in the key tensor sequence, we can calculate the weighted vector for one element of the sequence at the output of one attention head. To do this, we will create a system of two nested loops.

First, we will determine the offset in the result tensor to the beginning of the vector for the analyzed element.

Then we will create an outer loop based on the number of elements in the result vector. In the body of the loop, we will first prepare a variable for accumulating the value of one element of the vector. We will create a nested loop with the number of iterations equal to the number of sequence elements, in which we will iterate through all the elements of the tensor of values. In each element of the description vector of an element, we will take one value corresponding to the counter of the outer loop iteration and multiply it by the element of the normalized attention coefficient vector according to the counter of the nested loop iteration. After completing the full cycle of iterations in the nested loop, the query variable will contain one value of the description vector for the analyzed element of the attention block sequence. We will write it to the corresponding element of the kernel work results buffer.

```
shift_query = window * (q * heads + h);

   for(int i = 0; i < window; i++)

     {

      TYPE query = 0;

      for(int v = 0; v < units; v++)

         query += values[window * (v * heads + h) + i] * scores[shift_scores + v];

      outputs[shift_query + i] = query;

     }

  }
```

After completing the iterations of the outer loop, we will obtain a complete description vector for one element of the sequence in the result tensor buffer.

As you can see, the operations of one kernel result in one description vector for an element of the sequence in the result tensor of one attention head. To calculate the complete tensor, we need to launch a task pool with a size equal to the product of the number of elements in the sequence and the number of attention heads. This is what we do when running the kernel in a two-dimensional task space.

To transform the kernel from the single-head attention plane to multi-head attention, we simply needed to organize the kernel launch in a two-dimensional space and adjust the offset calculations in the data buffers.

Let's do a similar job with backpropagation kernels. As you may recall, in the Self-Attention block, in contrast to the implementation of other neural layers, we implemented the propagation of the error gradient through the internal space of the hidden neural layer using two consecutive kernels. So, we need to transfer both kernels into the area of multi-head attention. However, let's consider things in order.

First, we will look at the AttentionCalcScoreGradient kernel. The kernel parameters remain unchanged. Here we have the same data buffers and one constant size of the description vector of one element.

```
__kernel void AttentionCalcScoreGradient(__global TYPE *scores,

                                         __global TYPE *scores_grad,

                                         __global TYPE *values,

                                         __global TYPE *values_grad,

                                         __global TYPE *outputs_grad,

                                         __global TYPE *scores_temp,

                                         int window)

  {
```

In the kernel body, similar to the feed-forward kernel, we add the retrieval of thread identification in the second dimension and adjust the calculation of offsets in data buffers accordingly.

```
const int q = get_global_id(0);

   const int units = get_global_size(0);

   const int h = get_global_id(1);

   const int heads = get_global_size(1);

   int shift_value = window * (q * heads + h);

   int shift_score = units * (q * heads + h);
```

We do not change the kernel algorithm. As with the implementation of the Self-Attention algorithm, the kernel can be logically divided into two blocks.

In the first algorithm, we distribute the error gradient to the tensor of values Values​​. Here we create a system of two nested loops. The outer loop will have a number of iterations equal to the size of the description vector of one sequence element in the value tensor. In the loop body, we create a local variable to collect the error gradient of the analyzed element.

It should be understood that during the feed-forward pass, each element in the sequence of the value tensor has a significant influence on the value of each element in the sequence of the result tensor. The strength of this influence is determined by the corresponding column of the attention coefficient matrix, where each row corresponds to one element in the sequence tensor of results. Therefore, to obtain the error gradient vector for one element in the sequence tensor of values, we need to multiply the corresponding column of the attention coefficient matrix by the error gradient tensor at the level of the attention block results.

To perform this operation, we organize a nested loop with the number of iterations equal to the number of elements in the sequence. In the body of this loop, we will multiply two vectors and write the result to the corresponding element of the error gradient buffer of the value tensor.

```
//--- Distributing the gradient on Values

   for(int i = 0; i < window; i ++)

     {

      TYPE grad = 0;

      for(int g = 0; g < units; g++)

         grad += scores[units * (g * heads + h) + q] *

                 outputs_grad[window * (g * heads + h) + i];

      values_grad[shift_value + i] = grad;

     }
```

Here, we made changes only in terms of determining the offsets to the analyzed elements in the data buffers.

The second block of this kernel is responsible for propagating the gradient to the level of the dependency coefficient matrix. First, we create a system of two nested loops and calculate the error gradient for one row of the dependency coefficient matrix. There is a very important moment here. We calculate the error gradient specifically for a matrix row, not a column. The normalization of the matrix with the Softmax function was performed row-wise, so we should also adjust it row-wise with respect to the Softmax derivative. To determine the error gradient for one row of the matrix, we need to take the corresponding vector from the error gradient tensor at the level of attention block results and multiply it by the key tensor of the corresponding attention head.

To perform the multiplication operation, we organize a nested loop.

```
//--- Gradient distribution on Score

   for(int k = 0; k < units; k++)

     {

      TYPE grad = 0;

      for(int i = 0; i < window; i++)

         grad += outputs_grad[shift_value + i] *

                 values[window * (k * heads + h) + i];

      scores_temp[shift_score + k] = grad;

     }
```

After running a full cycle of iterations of our tensor loop system, we will obtain a single row of error gradients for the dependency coefficient matrix. Before passing the error gradient further, it is necessary to correct it by the derivative of the Softmax function.

```
//--- Adjust for the Softmax derivative

   for(int k = 0; k < units; k++)

     {

      TYPE grad = 0;

      TYPE score = scores[shift_score + k];

      for(int i = 0; i < units; i++)

         grad += scores[shift_score + i] *

                 ((int)(i == k) - score) * scores_temp[shift_score + i];

      scores_grad[shift_score + k] = grad;

     }

  }
```

The operation results are written into the corresponding elements of the error gradient tensor.

This completes the work with the first kernel of the backpropagation algorithm. As you may have noticed, the changes affected only the definition of the offset in the data buffers and the additional dimension of the task space.

Let's move on to the second kernel of the AttentionCalcHiddenGradient error backpropagation algorithm. In this kernel, we need to propagate the error gradient from the dependency coefficient matrix to the buffers of the m_cQuerys and m_cKeys internal neural layers.

This operation is not difficult from a mathematical point of view. We have already determined the error gradient at the level of the dependency coefficient matrix in the previous kernel. Now we need to multiply the dependency coefficient matrix by the opposite tensor.

As in the previous kernel, the kernel header and parameters have not changed at all. Here we see the same set of buffers and parameters.

```
__kernel void AttentionCalcHiddenGradient(__global TYPE *querys,

                                          __global TYPE *querys_grad,

                                          __global TYPE *keys,

                                          __global TYPE *keys_grad,

                                          __global TYPE *scores_grad,

                                          int key_size)

  {
```

In the kernel body, we identify the thread in two dimensions of tasks. The second dimension has been added for the identification of the active attention head. We adjust the offsets in the gradient buffers accordingly, ensuring they are aligned with the elements of the sequence being analyzed.

```
const int q = get_global_id(0);

   const int units = get_global_size(0);

   const int h = get_global_id(1);

   const int heads = get_global_size(1);

   int shift_query = key_size * (q * heads + h);

   int shift_score = units * (q * heads + h);
```

As mentioned earlier, in the kernel body, we need to distribute the error gradient to two internal neural layers from a single source. The same algorithm is used for gradient error distribution in both directions. And both recipient vectors have the same size. All of this allows us to calculate the error gradient for both tensors in parallel within the body of a single loop system. The number of iterations in the outer loop is equal to the size of the vector for which we are calculating the error gradient. In its body, we prepare variables for accumulating the error gradients and create a nested loop with a number of iterations equal to the number of elements in the sequence. In the body of the nested loop, we simultaneously calculate values from the product of two pairs of vectors.

```
//--- Propagate the gradient on Querys and Keys

   const TYPE k = 1 / sqrt((TYPE)key_size);

//---

   for(int i = 0; i < key_size; i++)

     {

      TYPE grad_q = 0;

      TYPE grad_k = 0;

      for(int s = 0; s < units; s++)

        {

         grad_q += keys[key_size * (s * heads + h) + i] *

                   scores_grad[shift_score + s];

         grad_k += querys[key_size * (s * heads + h) + i] *

                   scores_grad[units * (s * heads + h) + q];

        }

      querys_grad[shift_query + i] = grad_q * k;

      keys_grad[shift_query + i] = grad_k * k;

     }

  }
```

After exiting the nested loop, each variable has one value for the error gradient vectors of the required tensors. We write them into the corresponding elements of the tensors. After completing the full number of iterations of the loop system, we obtain the two desired vectors of error gradients.

We finish working with OpenCL program kernels. Here, we have only made slight changes to the kernels of the Self-Attention algorithm to transfer them to the area of ​​multi-headed attention.

Now we have to supplement the main program with the functionality of calling kernel data from methods of both the CNeuronAttention class and the CNeuronMHAttention class. We usually start this work by creating constants for working with kernels. But in this case, the constants have already been created.

Next, we created kernels in the OpenCL context. But this time we did not create new kernels. The ones that we slightly adjusted are already declared in the body of the main program. Therefore, we skip this step too.

Let's move on to making changes directly to class methods. For new kernels to work in the CNeuronAttention class, we add a second element to the offset and task space arrays. For offset, we specify 0 in both dimensions. For the task space, we leave the first value unchanged, and in the second element of the array, we introduce 1 (indicating the use of a single attention head). Additionally, when enqueueing the kernel for execution, we specify the two-dimensionality of the task space.

```
int off_set[] = {0, 0};

      int NDRange[] = {m_iUnits, 1};

      if(!m_cOpenCL.Execute(def_k_AttentionFeedForward, 2, off_set, NDRange))

         return false;
```

After this, we can fully use the updated feed-forward kernel.

We do such simple manipulations to call all three kernels in the methods of the CNeuronAttention class.

So, we have restored the functionality of the methods of the CNeuronAttention class, which implements the Self-Attention algorithm. There are also some changes on the main program side.

Let's move on to working on our CNeuronMHAttention class with the implementation of the Multi-Head Self-Attention algorithm. As usual, we'll start with the feed-forward method. Before we queue the kernel for operations, we need to do some preparatory work. First of all, we check the presence of the necessary buffers in the OpenCL context memory.

```
bool CNeuronMHAttention::FeedForward(CNeuronBase *prevLayer)

  {

   ......

//--- branching of the algorithm across the computing device

   MATRIX out;

   if(!m_cOpenCL)

     {

   ......

     }

   else // OpenCL block

     {

      //--- check data buffers

      if(m_cQuerys.GetOutputs().GetIndex() < 0)

         return false;

      if(m_cKeys.GetOutputs().GetIndex() < 0)

         return false;

      if(m_cValues.GetOutputs().GetIndex() < 0)

         return false;

      if(m_cScores.GetIndex() < 0)

         return false;

      if(m_cAttentionOut.GetOutputs().GetIndex() < 0)

         return false;
```

After checking all the necessary buffers, we pass pointers to the buffers to the kernel parameters. There we also pass the constants necessary for the operation of the kernel.

Please note that when passing parameters to the kernel, we specified the m_iKeysSize variable, which contains the size of the key vector for one element of the sequence, twice. We specified it for both the key vector size parameter and the value vector size parameter. Two parameters in the kernel are a necessary measure. When using a single attention head, for the size of the value vector, we would need to specify the size of the input data vector. This is a requirement of the Self-Attention algorithm. However, when using multi-head attention, the W0 matrix allows us to use different sizes for the value vector.

```
//--- pass parameters to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionFeedForward,

                                 def_attff_keys, m_cKeys.GetOutputs().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionFeedForward,

                      def_attff_outputs, m_cAttentionOut.GetOutputs().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionFeedForward,

                             def_attff_querys, m_cQuerys.GetOutputs().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionFeedForward,

                                          def_attff_scores, m_cScores.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionFeedForward,

                             def_attff_values, m_cValues.GetOutputs().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AttentionFeedForward,

                                                 def_attff_key_size, m_iKeysSize))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AttentionFeedForward,

                                                   def_attff_window, m_iKeysSize))

         return false;
```

This concludes the preparatory work, and we can move on to organizing the kernel launch procedure. To do this, we indicate the size of the problem space in two dimensions. In the first dimension, we indicate the size of the sequence; in the second one, we indicate the number of attention heads. Let's call the method for adding the kernel to the execution queue.

```
//--- putting the kernel into the execution queue

      int off_set[] = {0, 0};

      int NDRange[] = {m_iUnits, m_iHeads};

      if(!m_cOpenCL.Execute(def_k_AttentionFeedForward, 2, off_set, NDRange))

         return false;

     }
```

Here, we conclude our work on the feed-forward method and transition to the CalcHiddenGradient method that propagates the error gradient through the hidden layer. To implement the process of this method, we have prepared two kernels, which we need to launch sequentially. First, we will run the error gradient propagation kernel up to the AttentionCalcScoreGradient dependency coefficient matrix.

The algorithm for carrying out the preparatory work and launching the kernel is similar to what we used above when launching the forward pass kernel.

```
bool CNeuronMHAttention::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

//--- branching of the algorithm across the computing device

   if(!m_cOpenCL)

     {

   ......

   // MQL5 block

     }

   else // OpenCL block

     {

      //--- check data buffers

      if(m_cValues.GetOutputs().GetIndex() < 0)

         return false;

      if(m_cValues.GetGradients().GetIndex() < 0)

         return false;

      if(m_cScores.GetIndex() < 0)

         return false;

      if(m_cAttentionOut.GetGradients().GetIndex() < 0)

         return false;

      if(m_cScoreGrad < 0)

         return false;

      if(m_cScoreTemp < 0)

         return false;
```

After checking the buffers, we pass pointers to them and the necessary constants as parameters to the kernel.

```
//--- passing parameters to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients,

               def_attscr_outputs_grad, m_cAttentionOut.GetGradients().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients,

                                          def_attscr_scores, m_cScores.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients,

                                             def_attscr_scores_grad, m_cScoreGrad))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients,

                                             def_attscr_scores_temp, m_cScoreTemp))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients,

                             def_attscr_values, m_cValues.GetOutputs().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients,

                      def_attscr_values_grad, m_cValues.GetGradients().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AttentionScoreGradients,

                                                   def_attscr_window, m_iKeysSize))

         return false;
```

We place the kernel in the queue for performing operations. As with the feed-forward pass, we create a two-dimensional task space. In the first dimension, we specify the number of elements being analyzed in the sequence, and in the second dimension, we specify the number of attention heads.

```
//--- place the kernel into the execution queue

      int off_set[] = {0, 0};

      int NDRange[] = {m_iUnits, m_iHeads};

      if(!m_cOpenCL.Execute(def_k_AttentionScoreGradients, 2, off_set, NDRange))

         return false;
```

We immediately begin the preparatory work before launching the second kernel. Checking the data buffers in the OpenCL context memory. Only those buffers that we did not check when launching the first kernel are subject to verification.

```
//--- check data buffers

      if(m_cQuerys.GetOutputs().GetIndex() < 0)

         return false;

      if(m_cQuerys.GetGradients().GetIndex() < 0)

         return false;

      if(m_cKeys.GetOutputs().GetIndex() < 0)

         return false;

      if(m_cKeys.GetGradients().GetIndex() < 0)

         return false;
```

We pass pointers to data buffers to the parameters of the second kernel. We also add the necessary constants there.

```
//--- pass arguments to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionHiddenGradients,

                                def_atthgr_keys, m_cKeys.GetOutputs().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionHiddenGradients,

                         def_atthgr_keys_grad, m_cKeys.GetGradients().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionHiddenGradients,

                            def_atthgr_querys, m_cQuerys.GetOutputs().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionHiddenGradients,

                     def_atthgr_querys_grad, m_cQuerys.GetGradients().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionHiddenGradients,

                                            def_atthgr_scores_grad, m_cScoreGrad))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AttentionHiddenGradients,

                                                def_atthgr_key_size, m_iKeysSize))

         return false;
```

After completing the preparatory work, we call the method for placing the kernel in the tasks execution queue. Please note that this time we are not creating new arrays specifying the task space because it has not changed, and we can use the existing arrays from the previous kernel launch.

```
//--- place the kernel into the execution queue

      if(!m_cOpenCL.Execute(def_k_AttentionHiddenGradients, 2, off_set, NDRange))

         return false;

     }
```

This concludes our work on the implementation of the Multi-Head Self-Attention algorithm, including general and multi-threaded calculations. We have implemented all the functionality of the CNeuronMHAttention class. Now we can proceed with comprehensive testing of its performance using training and testing datasets.

## Building Multi-Head Self-Attention in Python

We have already implemented the Multi-Head Self-Attention algorithm using MQL5 and have even added the ability to perform multi-threaded calculations using OpenCL. Now let's look at an option for implementing such an algorithm in Python using the Keras library for TensorFlow. We had to deal with this library when creating previous models. Indeed, up to this point, we have been using only pre-built neural layers offered by the library, and with their help, we constructed linear models.

The Multi-Head Self-Attention model cannot be called linear. The parallel work of several heads of attention in itself is a rejection of the linearity of the model. In the Self-Attention algorithm itself, the source data simultaneously goes in four directions.

Therefore, to build a Multi-Head Self-Attention model, we will consider another functionality offered by this library, which is creating custom neural layers.

A layer is a callable object that takes one or more tensors as input and outputs one or more tensors. It includes computation and status.

All neural layers in the Keras library represent classes inherited from the tf.keras.layers.Layer base class. Therefore, when creating a new custom neural layer, we will also inherit from the specified base class.

The base class provides the following parameters:

- trainable — flag that indicates the need to train the parameters of the neural layer

- name — layer name

- dtype — type of layer results and weighting factors

- dynamic — flag that indicates that the layer cannot be used to create a graph of static calculations

```
tf.keras.layers.Layer(

    trainable=True, name=None, dtype=None, dynamic=False, **kwargs

)
```

Also, the library architecture defines a minimum set of methods for each layer:

- __init__ — layer initialization method

- call — calculation method (feed-forward pass)

In the initialization method, we define the custom attributes of the layer and create weight matrices, the structure of which does not depend on the format and structure of the input data. However, when solving practical problems, we often do not know the structure of the input data, and as a result, we cannot create weight matrices without understanding the dimensionality of the input data. In such cases, the initialization of weight matrices and other objects is transferred to the build(self, input_shape) method. This method is called once, during the first call of the call method.

The call method describes the forward-pass operations that must be performed with the initial data. The results of the operations are returned as one or more tensors. For layers used in linear models, there is a restriction on the result in the form of a single tensor.

Each neural layer has the following attributes (a list of the most commonly used attributes is provided):

- name — layer name

- dtype — type of weighting factors

- trainable_weights — list of variables to be trained

- non_trainable_weights — list of non-trainable variables

- weights — combines lists of trainable and non-trainable variables

- trainable — logical flag that indicates the need to train layer parameters

- activity_regularizer — additional regularization function for the output of the neural layer.

The advantages of this implementation are obvious: we are not creating backpropagation methods. All functionality is implemented by the library. We just need to correctly describe the logic of the feed-forward pass in the call method.

This approach makes it possible to create rather complex architectural solutions. Moreover, the created layer may contain other nested neural layers. At the same time, the parameters of the internal neural layers are included in the list of parameters of the external neural layer.

## Testing the attention mechanism

Unlike the LSTM recurrent block discussed earlier, the attention block works only with current data. Therefore, to create a more representative sample between weight updates during the training of a neural network, we will use random patterns from the general training dataset. We used this approach when testing the fully connected perceptron and the convolutional model. In such a situation, it will be quite logical to take the [convolution_test.mq5](https://www.mql5.com/en/neurobook/index/main_layer_types/cnn/cnn_realizations_comparison) script we used for testing the convolutional mode, re-save it with a new name attention_test.mq5, and make changes to the description of the created model accordingly.

Note that many changes were required to create the test script. We have removed the description blocks of the convolutional and pooling layers from the script. Instead of them, right after the input data, we will add a description of our attention block. To do this, as with any other neural layer, we will create a new instance of the CLayerDescription neural layer description class and immediately check the result of the operation based on the obtained pointer to the object. Next, we need to provide descriptions for the created neural layer.

In the type field, we will pass the defNeuronAttention constant, which corresponds to the attention block to be created.

In the count field, we must specify the number of elements of the sequence to be analyzed. We request it from the user when running the script and save it to the BarsToLine variable. Therefore, in the description of the neural layer, we can pass the value of the variable.

The window parameter was used to specify the size of the source data window when describing the convolutional layer. Here we will use it to specify the size of the description vector for one element of the input data sequence. Even though the descriptions are slightly different, the functions are similar. However, unlike the convolutional layer, we will not specify the step of the window, since in this case, it will be equal to the window itself. The number of neurons used to describe one candlestick is also requested from the user in the script parameters. This value is stored in the NeuronsToBar variable. As in the previous field case, we simply pass the value from the variable to the specified field.

The Self-Attention algorithm does not provide data resizing. At the output of the block, we obtain a tensor of the same size as the original data. It turns out that the window_out field in the description of the neural layer will remain unclaimed. But we'll use it to specify the size of the key vector of a single element in the Key tensor. In practice, the size of the key is not always different from the size of the vector describing one element. Dimensionality reduction is employed when the size of the description vector for a single element is large to conserve computational resources during the calculation of the dependency coefficient matrix. In our case, when the description vector of one candlestick is only four elements, we will not lower the dimension and pass to the window_out field the value of the NeuronsToBar variable.

Additionally, we will specify the optimization method and its parameters. In the test case, I used the Adam method, as I did in all previous tests.

```
bool CreateLayersDesc(CArrayObj &layers)

  {

   CLayerDescription *descr;

//--- create a source data layer

   .....

//--- attention layer

   if(!(descr = new CLayerDescription()))

     {

      PrintFormat("Error creating CLayerDescription: %d", GetLastError());

      return false;

     }

   descr.type = defNeuronAttention;

   descr.count = BarsToLine;

   descr.window = NeuronsToBar;

   descr.window_out = NeuronsToBar;

   descr.optimization = Adam;

   descr.activation_params[0] = 1;

   if(!layers.Add(descr))

     {

      PrintFormat("Error adding layer: %d", GetLastError());

      delete descr;

      return false;

     }

//---hidden layer

   .....

//--- Results layer

   .....

//---

   return true;

  }
```

After specifying all the parameters, we add the object to the dynamic array of neural layer descriptions. And, of course, we check the results of the operations. The rest of the script code remained unchanged.

As you can see, when using our library, changing the model configuration is not a very complex procedure. Thus, you will always be able to configure and test various architectural solutions to solve a specific task without making changes to the logic of the main program.

Testing the new model using the attention block was carried out while preserving all the other conditions used to test the previous models. This approach allows the accurate evaluation of how changes in the model architecture affect the training result.

The very first testing showed the superiority of the model with the attention mechanism over the previously considered models. On the training graph, the model using a single attention layer shows faster convergence compared to models using a convolutional layer and a recurrent LSTM block.  

Testing the model using the attention block

 

Testing the model using the attention block

 

When we scale up the learning curve graph, we can see that the model using the attention method demonstrates lower error throughout the entire training process.

At the same time, it should be noted that using an attention block in this form is rarely encountered in practice. The architecture that has gained the most widespread use is the multi-head attention, which we will explore in the next section.

## Description of architecture and implementation principles

The Transformer architecture is based on sequential Encoder and Decoder blocks with similar architectures. Each of the blocks includes several identical layers with different weight matrices.

Transformer architecture

Each Encoder layer contains two internal layers: Self-Attention and Feed Forward. The Feed Forward layer includes two fully connected layers of neurons with a ReLU activation function on the internal layer. Each layer is applied to all elements of the sequence with the same weights, enabling simultaneous independent calculations for all sequence elements in parallel threads.

Encoder

The Decoder layer has a similar structure with an additional layer called Self-Attention which analyzes dependencies between the input and output sequences.

Decoder

The Self-Attention mechanism includes several iterative actions applied to each element of the sequence.

- First, we compute the Query, Key, and Value vectors. The mentioned vectors are obtained by multiplying each element of the sequence by the corresponding matrix, WQ, WK and WV.

- Next, we determine pairwise dependencies between elements of the sequence. To do this, we multiply the Query vector with the Key vectors of all elements of the sequence. This iteration is repeated for the Query vector of each element in the sequence. As a result of this iteration, we obtain a matrix called Score with a size of N*N, where N is the sequence length.

- The next step involves dividing the obtained values by the square root of the dimension of the Key vector and normalizing using the Softmax function with respect to each Query. Thus, we obtain coefficients representing the pairwise dependencies between the elements of the sequence.

- By multiplying each Value vector by the corresponding attention coefficient, we obtain the adjusted value of the element. The goal of this iteration is to focus attention on relevant elements and reduce the influence of irrelevant values.

- Next, we summarize all the adjusted Value vectors for each element. The result of this operation will be the vector of output values for the Self-Attention layer.

The results of iterations for each layer are added to the input sequence and normalized.

For data normalization, we first determine the mean value of the entire sequence. Then, for each element, we calculate the quotient of its deviation from the mean divided by the standard deviation of the sequence.

## Building Self-Attention with MQL5 tools

The presented Self-Attention architecture may seem rather difficult to understand and to implement after the first acquaintance. Let's not be pessimistic. We will try to break down the whole algorithm into small components. Then, with the implementation of each individual block, we will assemble the overall picture, and it will no longer be so complex to understand. At the same time, you will be amazed at how we manage the work and build a functional mechanism for our library.

Now let's get to work. To implement our Self-Attention layer, let's create a new CNeuronAttention class. As always, we will inherit from our base class of the neural layer, CNeuronBase.

```
class CNeuronAttention    :  public CNeuronBase

  {

public:

                     CNeuronAttention(void);

                    ~CNeuronAttention(void);

   //---

   virtual bool      Init(const CLayerDescription *desc) override;

   virtual bool      SetOpenCL(CMyOpenCL *opencl) override;

   virtual bool      FeedForward(CNeuronBase *prevLayer) override;

   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;

   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer) override;

   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,

                                   VECTOR &Beta, VECTOR &Lambda) override;

   //--- methods of working with files

   virtual bool      Save(const int file_handle) override;

   virtual bool      Load(const int file_handle) override;

   //---object identification method

   virtual int       Type(void) override  const { return(defNeuronAttention); }

  };
```

Let's consider the first action of the Self-Attention algorithm which is the computation of the Query, Key, and Value vectors. At the input, we get a tensor of raw data containing features for each bar of the analyzed sequence. Sequentially, we take the features of one candlestick and, by multiplying them with a weight matrix, obtain a vector. Then we take the features of the second candlestick and multiply them by the same weight matrix so we get the second vector similar to the first one. Does this look similar to the convolution layer created earlier? Here, the length of the result vector is equal to the number of filters used in the convolution layer. Hence, to organize the above process, we declare three nested convolutional layers CNeuronConv. We use the appropriate layer names to make the code easier to read.

```
class CNeuronAttention    :  public CNeuronBase

  {

protected:

   CNeuronConv       m_cQuerys;

   CNeuronConv       m_cKeys;

   CNeuronConv       m_cValues;

   .....

  };
```

According to this algorithm, in the next step, we determine the Score matrix by multiplying the Query and Key matrices. To write the matrix data, we will create a data buffer as an object of the CBufferType class.

```
class CNeuronAttention    :  public CNeuronBase

  {

protected:

   .....

   CBufferType       m_cScores;

   .....

  };
```

After determining the Score dependency coefficient matrix, we will need to find the weighted values. To do this, we multiply the Values vectors by the corresponding values of the Score matrix. After additional processing, we obtain a tensor equal to the size of the initial data. We will talk about the reasons for the same size during the implementation process. Right now, let's just note for ourselves the need for a data warehouse. To collect data in the storage, we will need to set up a new process, so we require an object with easy access for writing data. In the future, we plan to pass data as input to the internal neural layer. So, the neural layer template of the raw data will be the most suitable for us. We use a basic neural layer with zero input window as the input data layer.

```
class CNeuronAttention    :  public CNeuronBase

  {

protected:

   .....

   CNeuronBase       m_cAttentionOut;

   .....

  };
```

Here, it's important to note the difference between the output of the Self-Attention algorithm and the output of the entire CNeuronAttention class. The first one is obtained after execution of the Self-Attention algorithm by adjusting the values of Value vectors. We save it to the instance of the object of the basic neural layer m_cAttentionOut. The second one is obtained after processing in the Feed Forward block. This one is saved to the result buffer of our class.

So, next, we need to organize the Feed Forward block. We will create it from two consecutive convolution layers. It may seem unusual to use a convolutional layer when the solution architecture is described as having fully connected layers. The situation here is similar to the first point of the algorithm when we determined the value of Query, Key, and Value vectors. Looking at the block within the context of one element of the sequence, we can see two fully connected neural layers. However, when considering the entire time series, it becomes evident that the same weight matrix is applied sequentially to each element of the sequence. Furthermore, as the input data progresses sequentially, the results are laid out in the same order. Doesn't this resemble the operation of a convolutional layer? We just need to take the convolution layer and set the width of the source data window equal to the vector size of one sequence element. The step of the initial data window is set equal to the window width, and the number of filters used is determined by the size of the fully connected layer for one element of the sequence.

Thus, we add two convolution layers to organize the Feed Forward block.

```
class CNeuronAttention    :  public CNeuronBase

  {

protected:

   .....

   CNeuronConv       m_cFF1;

   CNeuronConv       m_cFF2;

   .....

  };
```

We identified the objects we need to organize the Self-Attention mechanism in our class. To complete the picture, let's add a few more variables:

- m_iWindow — width of the initial data window (size of one sequence element vector)

- m_iUnits — the number of units in the sequence

- m_iKeysSize — width of the result vector size for Query and Key

- m_dStd — during normalization of the layer, we will divide the value by the standard deviation and will save the result to determine the derivative

Taking into account the standard set of functions for overriding, the class structure will have the following form.

```
class CNeuronAttention    :  public CNeuronBase

  {

protected:

   CNeuronConv       m_cQuerys;

   CNeuronConv       m_cKeys;

   CNeuronConv       m_cValues;

   CBufferType       m_cScores;

   int               m_cScoreGrad;

   int               m_cScoreTemp;

   CNeuronBase       m_cAttentionOut;

   CNeuronConv       m_cFF1;

   CNeuronConv       m_cFF2;

   //---

   int               m_iWindow;

   int               m_iUnits;

   int               m_iKeysSize;

   CBufferType       m_cStd;
```

```
public:

                     CNeuronAttention(void);

                    ~CNeuronAttention(void);

   //---

   virtual bool      Init(const CLayerDescription *desc) override;

   virtual bool      SetOpenCL(CMyOpenCL *opencl) override;

   virtual bool      FeedForward(CNeuronBase *prevLayer) override;

   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;

   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer) override;

   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,

                                   VECTOR &Beta, VECTOR &Lambda) override;

   //--- methods for operations with files

   virtual bool      Save(const int file_handle) override;

   virtual bool      Load(const int file_handle) override;

   //--- object identification method

   virtual int       Type(void) override  const { return(defNeuronAttention); }

  };
```

In the class constructor, we only set the initial values of the variables.

Please note that in this class, we are using static objects rather than pointers to objects as we did previously. The lifetime of static objects, like variables, is equal to the lifetime of the object containing them. By using such objects, we avoid the need to create object instances during class initialization and to clean up memory when the class operation is completed. Also, we don't need to check the validity of the object pointer every time. This saves some time in performing each method. However, in this case, we cannot replace objects by copying only the object's pointer, which this property is actively used in our activation class and in recurrent networks (using the same object pointers when analyzing the entire depth of the history).

```
CNeuronAttention::CNeuronAttention(void) :   m_iWindow(1),

                                             m_iUnits(0),

                                             m_iKeysSize(1)

  {

   m_cStd.BufferInit(1, 2, 1);

  }
```

Since we use static objects, we leave the class destructor empty.

```
CNeuronAttention::~CNeuronAttention(void)

  {

  }
```

 

#### Method of class initialization

After creating the class constructor and destructor, we move on to overriding the main methods of the class. First, we will override the class initialization method CNeuronAttention::Init. The main task of this method is to prepare the class to perform its functionality with user-defined parameters. Like similar methods in other previously discussed classes, the method receives an instance of the CLayerDescription object as a parameter, in which the parameters of the initialized neural layer are specified. Therefore, in order to eliminate possible errors in future work, we organize the block of initial data verification. In this method, we will check for the presence of the minimum required parameters in the received data.

```
bool CNeuronAttention::Init(const CLayerDescription *desc)

  {

//--- check the initial data

   if(!desc || desc.type != Type() || desc.count <= 0 ||

       desc.window <= 0 || desc.window_out <= 0)

      return false;
```

After that, we will save the main parameters into specially prepared variables. Note the correlation between the parameters of the neural layer description class and their functional purpose:

- CLayerDescription.window — the size of the source data window, a vector of source data of one element of the sequence (in our case description of one bar)

- CLayerDescription.count — the number of elements in the sequence (the number of analyzed bars)

- CLayerDescription.window_out — size of the result vector for Query and Key

```
m_iWindow   = desc.window;

   m_iUnits    = desc.count;

   m_iKeysSize = desc.window_out;
```

As before, we start initializing the object by calling a similar initialization method of the parent class. But there's a nuance here. We cannot simply transfer the resulting description of the neural layer. We will create a new instance of the neural layer description object and CLayerDescription and enter the corrected data into it.

In the count field, we specify the total number at the output of the layer, which is obtained by multiplying the count and window fields of this object.

Note that to obtain the total number of elements in the output of the neural layer, we multiply the number of elements in the sequence (number of bars analyzed) by the size of the source window (elements describing 1 bar), not the size of the results window. The reason is that we will use the results window size only for Query and Key tensors. The size of the result vector for the Value tensors and the second layer of the Feed Forward block will be equal to the size of the initial data window. This is done to align the dimensionality of the initial data and the results. The algorithm involves adding the tensors of the original data to the results of the Self-Attention block and then adding the tensors of the results of the Feed Forward and Self-Attention blocks, as well. Thus, as a result of tensor addition, the sequence at the output of our neural layer cannot be shorter than the initial data. And it doesn't make any sense to increase it. Therefore, we align the dimensions of the vectors.

In addition to changing the number of elements, we will also change the size of the output window, setting it to one. The size of the initial data window will be equal to zero. After that, we will call the parent class initialization method.

```
//--- calling the parent class initialization method

   CLayerDescription *temp = new CLayerDescription();

   if(!temp)

      return false;

   temp.count = desc.count * desc.window;

   temp.window_out = 1;

   temp.window     = 0;

   temp.optimization = desc.optimization;

   temp.activation = desc.activation;

   temp.activation_params = desc.activation_params;

   temp.type = desc.type;

   if(!CNeuronBase::Init(temp))

     {

      delete temp;

      return false;

     }
```

Such a parameter substitution will allow the running of the parent class initialization method in the neural layer mode of the source data. At the same time, no additional buffers will be created for the weight matrix, as well as the corresponding optimization method buffers. As with the LSTM block, this neural layer will not have a separate weight matrix. All weight factors will be stored in the inner neural layers.

We specify a similar architecture for the inner data collection layer of the AttentionOut attention block. We will simply change the type of neural layer and explicitly disable the activation function.

```
//--- initialize AttentionOut

   temp.type = defNeuronBase;

   temp.activation=AF_NONE;

   if(!m_cAttentionOut.Init(temp))

     {

      delete temp;

      return false;

     }
```

Next, to initialize our internal neural layers, we need to create a description for them. We fill the previously created instance of the CLayerDescription class with the necessary data. Almost all of our internal neural layers are convolutional, so in the type parameter, we will specify defNeuronConv. The rest of the parameters are transferred without changes from the obtained external description.

```
//--- create a description for the internal neural layers

   temp.type = defNeuronConv;

   temp.window = desc.window;

   temp.window_out = m_iKeysSize;

   temp.step = desc.window;

   temp.count = desc.count;
```

Next, we proceed to initialize the internal neural layers. We first initialize the convolution layer to define Query vectors using a pre-built description. Don't forget to check the results of the operations.

```
//--- initialize Querys

   if(!m_cQuerys.Init(temp) || !m_cQuerys.SetTransposedOutput(true))

     {

      delete temp;

      return false;

     }
```

Note that we use the new CNeuronConv::SetTransposedOutput method after initializing the convolutional neural layer. The reasons for its appearance and its functionality will be discussed a bit later.

We initialize the Keys layer using a similar algorithm.

```
//--- initializing Keys

   if(!m_cKeys.Init(temp) || !m_cKeys.SetTransposedOutput(true))

     {

      delete temp;

      return false;

     }
```

Next, initialize the Values layer. We use the above algorithm with a small addition. As mentioned earlier, when initializing this object, the result window is set equal to the input data window. Therefore, we make changes to the neural layer description object and call the initialization method. Let's check the result of the operations.

```
//--- initialize Values

   temp.window_out = m_iWindow;

   if(!m_cValues.Init(temp) || !m_cValues.SetTransposedOutput(true))

     {

      delete temp;

      return false;

     }
```

Next, we initialize the Scores coefficient matrix. According to the Self-Attention mechanism algorithm, this is a square matrix with a side length equal to the number of elements in the sequence. For us, it is the number of bars analyzed.

In the discussion of this algorithm, it's important to understand the difference between the number of elements in the sequence and the total number of elements at the output of the neural layer. If you translate this to analyzing a candlestick chart of a change in a stock instrument, then:

- The number of elements in a sequence is the number of bars to be analyzed.

- The length of a vector of one sequence element (input / output window) is the number of elements describing 1 bar.

- The total number of elements at the input/output of the neural layer is the product of the first two quantities.

Let's return to the initialization of the coefficient matrix buffer. For it, we have declared a data buffer. We will initialize it with zero values by setting the buffer size as a square matrix.

```
//--- initialize Scores

   if(!m_cScores.BufferInit(temp.count, temp.count, 0))

     {

      delete temp;

      return false;

     }
```

The Self-Attention algorithm is followed by the base neural layer object for recording attention results, which we have already initialized above.

All we have to do is initialize the Feed Forward block. As mentioned, it will consist of two convolutional neural layers. According to the architecture proposed by the authors, in the first neural layer, the tensor of results is four times larger than the input data. In addition, the authors used the ReLU activation function in the first neuron layer. We'll replace it with Swish. We will make the specified changes to the description of the neural layer and proceed with its initialization.

```
//--- initialize FF1

   temp.window_out *= 4;

   temp.activation = AF_SWISH;

   temp.activation_params[0] = 1;

   temp.activation_params[1] = 0;

   if(!m_cFF1.Init(temp) || !m_cFF1.SetTransposedOutput(true))

     {

      delete temp;

      return false;

     }
```

To initialize the second neural layer in the Feed Forward block, we need to increase the size of the input data window and its stride. The size of the results window should be resized to match the size of the attention block results tensor. It will also correspond to the tensor size of the previous layer.

For the second neural layer in the Feed Forward, we will use the activation function specified by the user during the initialization of our class.

After making the necessary changes to the description object of the neural layer, we will use the algorithm discussed earlier to initialize the last internal neural layer.

```
//--- initialize FF2

   temp.window = temp.window_out;

   temp.window_out = temp.step;

   temp.step = temp.window;

   temp.activation = desc.activation;

   temp.activation_params = desc.activation_params;

   if(!m_cFF2.Init(temp) || !m_cFF2.SetTransposedOutput(true))

     {

      delete temp;

      return false;

     }

   delete temp;
```

After initializing all internal neural layers, we delete the temporary neural layer description object. We don't need it anymore.

Now let's use a little trick. According to the algorithm, we obtain the result of the second neural layer operation in the result buffer of the Feed Forward block's second layer. To transfer the data to the subsequent neural layer, we need to transfer the data to the result buffer of our class. We will need additional time and resources at each iteration for the data copy operation. To avoid this, we can substitute pointers to objects. Remember that we discussed objects and pointers to them?

Initially, we delete the result buffer object of our class to avoid leaving unaccounted objects in memory. Then, in the variable used to store the pointer to the buffer object, we assign the pointer to a similar buffer in the second neural layer of the Feed Forward block. The same operation is performed for the gradient buffer.

```
//--- to avoid copying the buffers we swap them

   if(m_cOutputs)

      delete m_cOutputs;

   m_cOutputs = m_cFF2.GetOutputs();

   if(m_cGradients)

      delete m_cGradients;

   m_cGradients = m_cFF2.GetGradients();
```

Thanks to this simple trick, we have been able to avoid constant data copying between buffers and reduce the time required to perform operations within the class.

In conclusion, at the end of the initialization method, we call the SetOpenCL method to ensure that all our internal objects work in the same context. Now we exit the method with a positive result.

```
//--- pass a pointer to the object of work with OpenCL before all internal objects

   SetOpenCL(m_cOpenCL);

//---

   return true;

  }
```

The SetOpenCL method, called at the end of the initialization method, is designed to distribute the pointer to the OpenCL context work object among all internal objects. This is necessary to ensure that all objects work in the same space. This method was created as virtual in the base class of the neural layer. It is redefined in each new class as needed.

The algorithm of the method is quite simple, and we have already discussed it in all the previous classes. In the parameters, the method receives a pointer of the object of work with OpenCL context from an external program. We simply start by calling the method of the parent class and pass it the obtained pointer. The validation of the obtained pointer is already implemented in the parent class's method, so there is no need to repeat it here.

Then we pass the pointer to the OpenCL context to all internal objects stored in the variable of our class. The trick is that the method of the parent class checks the obtained pointer and stores the appropriate pointer in the variable. To ensure that all objects work in the same context, we propagate the already processed pointer.

```
bool CNeuronAttention::SetOpenCL(CMyOpenCL *opencl)

  {

   CNeuronBase::SetOpenCL(opencl);

   m_cQuerys.SetOpenCL(m_cOpenCL);

   m_cKeys.SetOpenCL(m_cOpenCL);

   m_cValues.SetOpenCL(m_cOpenCL);

   m_cAttentionOut.SetOpenCL(m_cOpenCL);

   m_cFF1.SetOpenCL(m_cOpenCL);

   m_cFF2.SetOpenCL(m_cOpenCL);

   if(m_cOpenCL)

     {

      m_cScores.BufferCreate(m_cOpenCL);

      ulong size = sizeof(TYPE) * m_cScores.Total();

      m_cScoreGrad = m_cOpenCL.AddBuffer((uint)size, CL_MEM_READ_WRITE);

      m_cScoreTemp = m_cOpenCL.AddBuffer((uint)size, CL_MEM_READ_WRITE);

      m_cStd.BufferCreate(m_cOpenCL);

     }

   else

     {

      m_cScores.BufferFree();

      m_cStd.BufferFree();

     }

//---

   return(!!m_cOpenCL);

  }
```

Going a bit ahead, I want to draw attention to the creation of the m_cScoreGrad and m_cScoreTemp buffers. They are used only in the OpenCL context for temporary data storage, so we did not create mirror objects for them in the main memory. Also, we will not use them to exchange data between the main program and the OpenCL context. In this case, we will create buffers in the OpenCL context, while on the side of the main program, we use only pointers to work with them. When disabling multi-threading technology, we immediately delete the mentioned buffers.

After completing the initialization method of the class, we can proceed to override the functional methods of our class.

## Organizing parallel computing in the attention block

In the previous sections, we built a working attention block algorithm using standard MQL5 language capabilities. Now you can add an attention block to your model and test the quality of the Self-Attention mechanism. However, look at the block structure. In its operation, we used five internal layers and created an algorithm for transferring data between them in both the forward and backward directions. It's also important to note that each element of the sequence, described by a value vector, is processed using shared weight matrices, but independently of each other. This allows us to easily distribute operations across parallel threads, enabling us to perform a full set of operations in shorter time intervals. And yes, from the beginning, we decided to create a library with the capability to use two technologies. By doing so, we provide users with the opportunity to independently test and choose the most suitable technology for their specific use case.

As before, we organize the parallel computing unit using OpenCL. To use this technology, we will need to complete two stages of work:

- Create an OpenCL program

- Make changes to the main program

We will add the OpenCL program code to the previously created file [opencl_program.cl](https://www.mql5.com/en/neurobook/index/realization/pr_opencl/opencl_programm). It is in this file that we collected all the kernels of the OpenCL program used in the work of the previous classes. To organize the operation of our attention class, we will need to create six kernels. In these kernels, we will need to organize the flow of information between the internal neural layers used in both the forward and backward directions.

First, we'll create the AttentionFeedForward kernel. Below is a brief recap on the sequence of operations during the feed-forward pass through the Self-Attention block:

- The source data is fed into three internal convolutional neural layers: m_cQuery, m_cKeys, m_cValues.

- The m_cQuery and m_cKeys result tensors are multiplied to obtain the m_cScores dependency matrix.

- The values of the m_cScores matrix are divided by the square root of the size of the description vector of one element of the m_cKeys sequence and normalized by the Softmax function in terms of rows (m_cQuery queries).

- The normalized matrix m_cScores is multiplied by the neural layer results tensor m_cValues to obtain the Self-Attention results.

- The results of the Self-Attention block are added to the original data and normalized.

- The obtained tensor serves as the input data for a block of two convolutional layers: m_cFF1 and m_cFF2.

Points 1 and 6 are covered by using the previously discussed convolutional layer class, which already implements a multi-threaded computation block. So, we will need to implement the remaining points in a new kernel.

To organize the specified operations, we will need to pass six data buffers and two parameters to the kernel. To make the program code more readable, the names of buffers and variables will be aligned with the names of the corresponding matrices in the algorithm description.

```
__kernel void AttentionFeedForward(__global TYPE *querys,

                                   __global TYPE *keys,

                                   __global TYPE *scores,

                                   __global TYPE *values,

                                   __global TYPE *outputs,

                                   int window,

                                   int key_size)

  {
```

As you may have noticed from the description of the Self-Attention algorithm, the primary analytical unit in this method is an element of the sequence, described by a value vector. For language models, this is usually a word. In the case of financial market analysis, we use a bar. It is precisely between these elements of the sequence that the coefficients of mutual dependencies are determined. Taking into account these coefficients, the values of the element description vectors are adjusted. Therefore, it is quite logical to divide the operations into threads based on the elements of the sequence.

Therefore, in the body of the kernel, the first thing we will do is determine the element of the sequence being analyzed based on the identifier of our thread. At the same time, the total number of running threads will indicate the number of elements in the sequence. Here, we will also immediately determine the offset in the query tensor and the dependency coefficient matrix to the first analyzed value.

```
const int q = get_global_id(0);

   const int units = get_global_size(0);

   int shift_query = key_size * q;

   int shift_scores = units * q;

   TYPE summ = 0;
```

To normalize data with the Softmax function, we need the sum of the exponents of all normalized values. To calculate it, we add a variable with an initial zero value.

After completing the preparatory work, we will determine the values of one vector from the dependency coefficient matrix, which is related to the calculations for the dependencies of the analyzed element of the sequence. For this, we create a loop with the number of iterations equal to the number of elements in the sequence. In the body of the loop, we will alternately multiply the Query vector of the analyzed sequence element with all vectors of the Key tensor. For each vector multiplication result, we will take an exponential value and write it into the corresponding element of the Score matrix. Of course, we will add the values of the vector to our accumulator sum of all vector values for subsequent normalization.

```
for(int s = 0; s < units; s++)

     {

      TYPE score = 0;

      int shift_key = key_size * s;

      for(int k = 0; k < key_size; k ++)

         score += querys[shift_query + k] * keys[shift_key + k];

      score = exp(score / sqrt((TYPE)key_size));

      summ += score;

      scores[shift_scores + s] = score;

     }
```

After the loop completes, our variable summ will accumulate the sum of all elements of our vector from the dependency coefficients tensor. To complete the normalization of the given vector values, all we have to do is divide the value of each of its elements by the total sum of all the values of the vector.

```
for(int s = 0; s < units; s++)

      scores[shift_scores + s] /= summ;
```

In the analyzed vector, we obtained the coefficients of dependencies of the analyzed element of the sequence on the rest of its elements. The sum of all coefficients will be equal to one.

Next, according to the algorithm, we need to multiply each vector of the Value tensor by the corresponding element of the resulting vector of dependency coefficients. The resulting vectors need to be added up. The final vector of values will be the result of the Self-Attention block.

Before passing the data further, we need to add the obtained data to the tensor of input data and normalize them. In the body of the kernel, I propose focusing on determining the results of the Self-Attention block. It will be more efficient to perform matrix addition and data normalization separately across the entire neural layer.

Let's look at the implementation of such a solution. To avoid recalculating at each iteration, we first determine the offset in the tensors of the initial data and results. The tensors have the same dimension, so the offset will be the same for both cases. Then, we will set up a system of two nested loops: in the outer loop, we will iterate over the elements of the vector of the analyzed element of the sequence, and in the inner loop, we will perform the actual computation of the values for each element of the result vector. For this purpose, the number of iterations in the inner loop will be equal to the number of elements in the sequence. In the body of this loop, we will multiply the values of the Value tensor elements by the corresponding dependency coefficients from the Score matrix. We will accumulate the resulting products in the local variable query. After completing the iterations of the inner loop, we will write the result into the corresponding element of the result tensor.

```
shift_query = window * q;

   for(int i = 0; i < window; i++)

     {

      TYPE query = 0;

      for(int v = 0; v < units; v++)

         query += values[window * v + i] * scores[shift_scores + v];

      outputs[shift_query + i] = query;

     }

  }
```

With this, we will complete work on the first feed-forward kernel. The next step is to create a kernel for adding up two tensors. It is sometimes more economical to do such work using matrix operations on the side of the main program. The operation is straightforward, and the overhead of data transfer is unlikely to be justified. We now have the opposite situation. We organize the entire process on the OpenCL context side. All the information is already in the context memory, and to perform the operation on the main program side, we will need to copy the data. We do not need to transfer data if computations are performed within the context. Therefore, we have created a kernel called Sum, in which we simply add elements from two buffers with the same index and store the result in an element of the third buffer with the same index.

```
__kernel void Sum(__global TYPE *inputs1,

                  __global TYPE *inputs2,

                  __global TYPE *outputs)

  {

   const int n = get_global_id(0);

//---

   outputs[n] = inputs1[n] + inputs2[n];

  }
```

The data normalization process has a more complex architecture. As you know, its process is expressed by the following mathematical formulas:

As you can notice, to calculate the normalized value of each element in the sequence, you need the arithmetic mean and the root mean square deviation of the entire sequence. To calculate them, we need to organize data transfer between individual threads. We will solve this problem in a way similar to the multi-threaded implementation of the [Softmax](https://www.mql5.com/en/neurobook/index/realization/pr_opencl/opencl_programm#softmax_opencl) activation function, that is, via an array in local memory. We will need to organize two summation blocks for values across the entire vector because before calculating the arithmetic mean, we cannot compute the variance. Furthermore, we cannot calculate the normalized value until we determine the variance.

The normalization process is organized in the LayerNormalize kernel. In the parameters, the kernel receives pointers to 3 buffers:

- Source data buffer

- Results buffer

- Buffer for recording standard deviation parameters

We needed the last standard deviation buffer to save and transmit data to the backpropagation kernel.

Additionally, we will pass two parameters to the kernel: the total number of elements in the buffer being normalized and the offset in the buffer for root mean square deviations. I would like to remind you that within one attention neural layer, we perform data normalization twice. Let's normalize the results of the Self-Attention and FeedForward blocks.

```
__kernel void LayerNormalize(__global TYPE* inputs,

                             __global TYPE* outputs,

                             __global TYPE* stds,

                             const int total,

                             const int std_shift)

  {
```

In the kernel body, we define thread identifiers and initialize a local data array.

```
uint i = (uint)get_global_id(0);

   uint l = (uint)get_local_id(0);

   uint ls = min((uint)get_local_size(0), (uint)LOCAL_SIZE);

   __local TYPE temp[LOCAL_SIZE];
```

First, we will determine the arithmetic mean of the buffer elements. To do this, we organize a loop in which each thread sums its values and stores the result in its own element of the local array. Since we are calculating the arithmetic mean of the entire buffer, we will divide the obtained value by the number of elements in the buffer.

```
uint count = 0;

   do

     {

      uint shift = count * ls + l;

      temp[l] = (count > 0 ? temp[l] : 0) + (shift < total ? inputs[shift] : 0);

      count++;

     }

   while((count * ls + l) < total);

   temp[l] /= (TYPE)total;

   barrier(CLK_LOCAL_MEM_FENCE);
```

We will synchronize the work of threads using the barrier function. Since the calculations of the threads do not overlap, we only need one barrier at the end of the block.

Next, we need to collect parts of the total amount into a single whole. We will organize another loop in which we will collect the arithmetic mean of the buffer into one element of the local array with index 0. The result will be saved in a local variable.

```
count = ls;

   do

     {

      count = (count + 1) / 2;

      temp[l] += (l < count ? temp[l + count] : 0);

      barrier(CLK_LOCAL_MEM_FENCE);

     }

   while(count > 1);

//---

   TYPE mean = (TYPE) temp[0];
```

I would like to draw your attention once again to the arrangement of barriers. Here you need to pay special attention to the operation of the algorithm because all threads must reach each barrier. Moreover, the sequence of their visits must also be observed.

After determining the arithmetic mean, we repeat the loops and calculate the standard deviation.

```
count = 0;

   do

     {

      uint shift = count * ls + l;

      temp[l] = (count > 0 ? temp[l] : 0) + (shift < total ? (TYPE)pow(inputs[shift] - mean, 2) : 0);

      count++;

     }

   while((count * ls + l) < total);

   temp[l] /= (TYPE)total;

   barrier(CLK_LOCAL_MEM_FENCE);
```

```
count = ls;

   do

     {

      count = (count + 1) / 2;

      temp[l] += (l < count ? temp[l + count] : 0);

      barrier(CLK_LOCAL_MEM_FENCE);

     }

   while(count > 1);

//---

   TYPE std = (TYPE)sqrt(temp[0]);

   if(l == 0)

      stds[std_shift] = std;
```

We save the obtained standard deviation into a buffer. To avoid simultaneous writes by all threads, we will save the value in only one thread. To achieve this, we will perform a thread index check before the operation of writing a value to the buffer.

Now that we have calculated the averages, we can normalize the original data. It's important to note that the limitation of the workgroup size may not allow us to allocate a separate thread for each element of the input data buffer. Therefore, we will also implement data normalization in a loop.

```
count = 0;

   while((count * ls + l) < total)

     {

      uint shift = count * ls + l;

      outputs[shift] = (inputs[shift] - mean) / (std + 1e-37f);

      count++;

     }

  }
```

This concludes our work with feed-forward kernels. Continuing our work on making additions to the OpenCL program, we move on to building a reverse pass. Its algorithm completely mirrors the path taken above but in the reverse direction. In it, we have to propagate the error gradient from the output of the Self-Attention block to the internal neural layers m_cQuery, m_cKeys, m_cValues.

The simplest seems to be the calculation of the error gradient for the internal neural layer, m_cValues. Let me remind you that to obtain the result of the Self-Attention block, we multiplied the matrix of dependence coefficients m_cScores by the tensor of the results of the neural layer m_cValues​​. Therefore, to obtain the error gradient at the output level of the specified neural layer, we need to multiply the gradient obtained from previous operations by the derivative of the last operation. In this case, we have to multiply the matrix of dependency coefficients by the tensor of error gradients from previous operations.

After determining the error gradient on the internal neural layer m_cValues, we need to distribute the error gradient to two more internal neural layers, m_cQuerys and m_cKeys. However, in order to bring the error gradient to the level of the specified neural layers, it is necessary to pass it through the matrix of dependency coefficients.

However, when implementing in MQL5, we do not create an additional buffer for error gradients at the level of the dependency coefficient matrix. But in OpenCL there is difficulty in allocating a dynamic array for recording intermediate data about the error gradient values at the dependency coefficient matrix level. Therefore, here we will create two temporary data buffers: the first for the error gradient of the normalized data, and the second for the error gradients corrected by the derivative of the Softmax function.

Note that when we recalculate the error gradient to the level of the m_cQuerys and m_cKeys neural layers, the same elements of the dependency coefficient error gradient matrix are used in different operation threads. Therefore, we will divide the entire backpropagation algorithm within the attention layer into two blocks. In the first block, we will propagate the error gradient to the level of the internal neural layer of m_cValues value and the m_cScores coefficient matrix. In the second block, we will propagate the error gradient to two other neural layers: m_cQuerys and m_cKeys.

We implement the first block of operations in the AttentionCalcScoreGradient kernel. In the parameters of this kernel, we pass pointers to five data buffers and one parameter:

- scores — dependency coefficient matrix buffer

- scores_temp — buffer of error gradients at the level of the normalized dependency coefficient matrix

- scores_grad — buffer of error gradients at the level of the dependency coefficient matrix, adjusted to the derivative of the normalization function

- values — tensor buffer Values ​​(buffer of neural layer results m_cValues​​)

- values_grad — error gradient tensor buffer at the level of results of the m_cValues ​​neural layer

- outputs_grad is the buffer of error gradients at the output level of the Self-Attentionblock;

- window is the size of the description vector of one element of the sequence in the Values​​ tensor.

Please note that the scores_temp and scores_grad buffers have no counterparts on the main program side. The reason is that we only need error gradients at the level of the dependency coefficient matrix to perform the operations of the current backward pass. However, OpenCL does not have the ability to create dynamic arrays. We created the specified buffers instead.

```
__kernel void AttentionCalcScoreGradient(__global TYPE *scores,

                                         __global TYPE *scores_grad,

                                         __global TYPE *values,

                                         __global TYPE *values_grad,

                                         __global TYPE *outputs_grad,

                                         __global TYPE *scores_temp,

                                         int window)

  {
```

The feed-forward algorithm involves normalizing the dependency coefficient matrix Score with the Softmax function in the context of Query requests. So, after determining the error gradients at the coefficient matrix level, it is necessary to adjust these values based on the derivative of the data normalization operation. Therefore, it would be logical to divide the operations into threads in the same manner. Moreover, such a distribution of operations into threads would be entirely appropriate for propagating the error gradient to the level of values within the internal neural layer.

At the beginning of the kernel, we do a little preparatory work. We determine the serial number of the analyzed vector of values and rows of the matrix of dependency coefficients by the identification number of the thread. The total number of running threads will tell us the dimensions of the tensors. Let's immediately determine the offset in the data buffers to the first element of the analyzed vectors of values.

```
const int q = get_global_id(0);

   const int units = get_global_size(0);

   int shift_value = window * q;

   int shift_score = units * q;
```

Next, we will propagate the error gradient to the level of the internal neural layer m_cValues. As mentioned above, to determine the error gradient, we need to multiply the transposed matrix of dependency coefficients by the gradient tensor at the output of the Self-Attention block.

Within the kernel, we will define the error gradient for only one vector of element description. As you know, with a feed-forward pass, each element of the sequence in the Value tensor leaves its mark in the formation of all elements of the sequence of results of the Self-Attention block. Consequently, each element of the Value tensor must receive its share of the error gradient from all elements of the results tensor of the Self-Attention block. The measure of influence will be the corresponding dependence coefficient from the Score matrix. Thus, each element of the sequence of the Value tensor corresponds to one column in the dependency coefficient matrix Score. This explains the use of the transposed Score matrix in the formula above.

To organize this process, we will create a system of two nested loops. The number of iterations in the first loop is equal to the size of the vector describing one element of the sequence in the Value tensor. It should be noted that the error gradient tensor at the output of the Self-Attention block has the same dimensions. In the nested loop with a number of iterations equal to the number of elements in the sequence, we will iterate over the values of the corresponding column of the dependency coefficient matrix Score and the gradient vector of errors at the level of the Self-Attention block results. In this case, we will multiply the corresponding elements and sum the resulting products into a private variable. After completing the iterations of the inner loop, copy the accumulated sum of products to the error gradient buffer of the internal convolutional layer m_cValues.

```
//--- Distributing the gradient on Values

   for(int i = 0; i < window; i ++)

     {

      TYPE grad = 0;

      for(int g = 0; g < units; g++)

         grad += scores[units * g + q] * outputs_grad[window * g + i];

      values_grad[shift_value + i] = grad;

     }
```

After the execution of the loop system the first part of our task, in which we propagate the error gradients to the internal neural layer m_cValues, can be considered complete.

The second part of our kernel is devoted to determining the error gradient at the level of the dependency coefficient matrix.

In the feed-forward pass, each element of the Query sequence is multiplied with all the elements of the Key sequence to form a single dependency coefficient matrix vector Score. Each such vector is normalized by the function Softmax. After that, we multiply it by the Value tensor. As a result of these operations, we obtain the corrected vector representation of one element of the sequence in the tensor of the Self-Attention block results. Thus, one element of the Query sequence interacts with all elements of the Key and Value tensors to form a vector describing one element of the result sequence. Therefore, to distribute the error gradient to a specific vector from the Query tensor, we need to take one corresponding error gradient vector of one element of the sequence at the level of the Self-Attention block and first multiply it by the transposed tensor of Value. Thus, we obtain an error vector at the level of the dependency coefficient matrix Score. Next, we need to adjust the resulting vector to the derivative of the Softmax function. It is this part of the error gradient distribution that we implement in this kernel. To further propagate the error gradient to the level of the internal neural layers m_cQuerys and m_cKeys, we will create another kernel a little later.

The error gradient distribution algorithm described above in matrix form can be represented as follows:

- Error gradient at the Score matrix level.

- Adjusting the error gradient to the derivative of the Softmax function.

Let's summarize the entire calculation into one formula:

First, let's propagate the error gradient to the level of the dependency coefficient matrix Score. Since, thanks to the division of operations into parallel threads within the kernel, we will be determining the error gradient for only one row, to calculate this error gradient vector, we need to take the error gradient vector for one element of the sequence at the level of the Self-Attention block results and multiply it by the transposed tensor of the internal layer's results, m_cValues. In practice, we will use the algorithm described above when calculating error gradients for the m_cValues layer. We will create a system of two nested loops. But this time, the number of iterations of the outer loop will be equal to the number of elements in the sequence. The nested loop will repeat its operations for the number of elements in the vector describing one element of the sequence. This difference is explained by the magnitude of the vector of results and is confirmed by the logic of the operations performed. Remember, with a forward pass, each element in the row of the dependency coefficient matrix corresponds to one vector describing the sequence element in the Values tensor.

```
//--- Gradient distribution on Score

   for(int k = 0; k < units; k++)

     {

      TYPE grad = 0;

      for(int i = 0; i < window; i++)

         grad += outputs_grad[shift_value + i] * values[window * k + i];

      scores_temp[shift_score + k] = grad;

     }
```

After transferring the error gradient to the level of the dependency coefficient matrix, we need to adjust the obtained values using the derivative of the Softmax normalization function. Just like with the forward pass, when in order to obtain one normalized value it was necessary to process the entire vector of normalized values, to calculate one adjusted value we need to use all the elements of both vectors (error gradients at the level of the matrix of dependence coefficients and the normalized vector of coefficients itself).

The matrix expression of the process of adjusting for the derivative of the Softmax function is given above. For practical implementation, we will create a system of two nested loops. Both loops have the same number of iterations, which is equal to the size of the vector being normalized. In this case, it is equal to the number of elements in the sequence. When performing operations, it will be necessary to accumulate the sum of error gradients from each element of the normalized vector. To do this, we will create a private variable in the body of the outer loop grad. Besides, to reduce the number of accesses to global memory, we will store the repeated element in the private variable score. Let me remind you that accessing global memory is more time-consuming. So, by reducing the number of accesses to global memory buffers, we reduce the overall time spent on operations. In the body of the nested loop, we will perform operations of multiplying elements and adding the resulting products into a previously created private variable grad.

Please note that we have replaced the identity matrix with the expression (int)(i==k). The logical expression will give us the true value only on the diagonal of the matrix. Translating a boolean value into an integer will substitute 1 for true values and 0 for false values. Thus, such a short notation allows us to obtain the values of the identity matrix directly in the operation thread, without the need to first generate and save it.

```
//--- Adjust for the Softmax derivative

   for(int k = 0; k < units; k++)

     {

      TYPE grad = 0;

      TYPE score = scores[shift_score + k];

      for(int i = 0; i < units; i++)

         grad += scores[shift_score + i] *

                     ((int)(i == k) - score) * scores_temp[shift_score + i];

      scores_grad[shift_score + k] = grad;

     }

  }
```

After completing the iterations of the loop system, we will obtain the error gradients at the level of the dependency coefficient matrix, adjusted for the derivative of the Softmax function.

With that, we conclude the first backpropagation kernel and move on to creating the second kernel AttentionCalcHiddenGradient, in which we will propagate the error gradient to the internal neural layers m_cQuerys and m_cKeys. To do this, in the kernel parameters we need to pass pointers to five data buffers and one constant:

- querys — buffer of results of the internal neural layer m_cQuerys

- queries_grad — buffer of error gradients of the internal neural layer m_cQuerys

- keys — buffer of results of the internal neural layer m_cKeys

- keys_grad — buffer of error gradients of the internal neural layer m_cKeys

- scores_grad — buffer of error gradients of dependency coefficient matrix m_cScores

- key_size — size of the key vector of one element

```
__kernel void AttentionCalcHiddenGradient(__global TYPE *querys,

                                          __global TYPE *querys_grad,

                                          __global TYPE *keys,

                                          __global TYPE *keys_grad,

                                          __global TYPE *scores_grad,

                                          int key_size)

  {
```

Following the analogy with all the kernels discussed earlier, we will distribute the operations into threads in the context of a single element of the sequence. At the beginning of the kernel, we will perform preparatory work and determine the offsets in the data buffers to the first element of the vector of the analyzed element.

```
const int q = get_global_id(0);

   const int units = get_global_size(0);

   int shift_query = key_size * q;

   int shift_score = units * q;
```

In the AttentionCalcScoreGradient kernel discussed above, we have already adjusted the error gradient of the dependency coefficient matrix to the derivative of the Softmax normalization function. However, during the feed-forward pass, before normalizing the matrix, we divided all its elements by the square root of the dimension of the key vector. Now we need to adjust the error gradient for the derivative of the mentioned operation. Similar to the multiplication operation, we will need to divide all the values of the error gradient buffer of the dependency coefficient matrix by the same constant.

Let's determine the value of the constant and store it in a private variable.

```
//--- Distribute the gradient on Querys and Keys

   const TYPE k = 1 / sqrt((TYPE)key_size);
```

This concludes the preparatory work. Now we can proceed directly to recalculating the error gradients. To obtain dependency coefficients, we multiplied two tensors (Query  and Keys). We have already encountered derivatives of multiplication operations more than once. To obtain error gradients for one of the tensors, we need to multiply the error gradient tensor at the level of the dependency coefficient matrix by the second tensor. Since the Query and Key tensors have the same dimensions, we can calculate the error gradients for both tensors in the same loop system.

Let's create a system of two nested loops. The outer loop has a number of iterations equal to the size of the key vector of one sequence element. In the nested loop, we iterate through the vectors of the opposite tensor and the corresponding error gradients of the dependency coefficient matrix. Therefore, the number of its iterations will be equal to the number of elements in the analyzed sequence.

As a result, the number of iterations in the nested loop will be equal to the number of elements in the analyzed sequence. The results of these products will need to be summarized. To accumulate this amount, we will create two private variables grad_q and grad_k before declaring the nested loop.

Also, please note the following. To reduce the number of calculation operations, we will not add our previously calculated coefficient to adjust the error gradient to the products of the nested loop. We will use the mathematical properties of functions and take the constant factor out of brackets.

Thus, there is no need to multiply the value each time by a correction factor in the body of the nested loop. Instead, we can simply multiply the total amount once by the correction factor before writing it to the data buffer.

```
for(int i = 0; i < key_size; i++)

     {

      TYPE grad_q = 0;

      TYPE grad_k = 0;

      for(int s = 0; s < units; s++)

        {

         grad_q += keys[key_size * s + i] * scores_grad[shift_score + s];

         grad_k += querys[key_size * s + i] * scores_grad[units * s + q];

        }

      querys_grad[shift_query + i] = grad_q * k;

      keys_grad[shift_query + i] = grad_k * k;

     }

  }
```

At the output of the loop system, we get error gradients for two nested internal neural layers m_cQuerys and m_cKeys. That is, the task of this kernel is solved. Considering the previously discussed AttentionCalcScoreGradient kernel, we have distributed the error gradient to all internal neural layers, and further distribution of the error gradient to the previous layer will be carried out using the well-tested methods of internal neural layers, as implemented by standard MQL5 means.

The backpropagation kernels discussed above bypassed the processes of adding result buffers and data normalization that we carried out during the feed-forward pass. The derivative of two functions is equal to the sum of the derivatives of these functions. So, for the operation of adding gradients, we can use a similar feed-forward kernel. We just need to specify the correct data buffers.

In the case of adjusting the error gradient to the data normalization function, we will have to create an additional kernel. Below is the error gradient correction formulas.

As you can see, in the formulas provided above, when calculating derivatives with respect to the means, the sum of values across the entire value buffer is used. However, unlike the forward pass, we have the ability to calculate all three sums in parallel.

In the kernel parameters, we pass pointers to four data buffers:

- outputs — buffer of forward pass normalization results

- out_gradient — buffer of gradients at the output of the normalization block

- inp_gradient — buffer for writing adjusted gradients

- stds — buffer of standard deviations calculated during the feed-forward pass

Also, in the parameters we will indicate the size of the buffers and the offset in the standard deviation buffer.

```
__kernel void LayerNormalizeGradient(__global TYPE* outputs,

                                     __global TYPE* out_gradient,

                                     __global TYPE* inp_gradient,

                                     __global TYPE* stds,

                                     const int total,

                                     const int std_shift)

  {

   uint i = (uint)get_global_id(0);

   uint l = (uint)get_local_id(0);
```

In the kernel body we define thread identifiers and at the same time declare local data arrays. There will be three of them. In one, we will collect the derivative of the root mean square deviation, and the other two are intended for the terms in the derivative formula of the arithmetic mean.

```
uint ls = min((uint)get_local_size(0), (uint)LOCAL_SIZE);

   __local TYPE dSTD[LOCAL_SIZE];

   __local TYPE dMean1[LOCAL_SIZE];

   __local TYPE dMean2[LOCAL_SIZE];
```

As with the feed-forward pass, each thread will first collect its share of the total.

```
uint count = 0;

   do

     {

      uint shift = count * ls + l;

      dSTD[l] = (count > 0 ? dSTD[l] : 0) -

                (shift < total ? out_gradient[shift] * outputs[shift] /

                (2 * (pow(stds[std_shift], (TYPE)2) + 1e-37f)) : 0);

      dMean1[l] = (count > 0 ? dMean1[l] : 0) -

                (shift < total ? out_gradient[shift] /

                (stds[std_shift] + 1e-37f) : 0);

      dMean2[l] = (count > 0 ? dMean2[l] : 0) -

                  (shift < total ? 2 * outputs[shift] * stds[std_shift] /

                  (TYPE)total : 0);

      count++;

     }

   while((count * ls + l) < total);

   barrier(CLK_LOCAL_MEM_FENCE);
```

In the next loop, we will collect the sum in the first elements of the array.

```
count = ls;

   do

     {

      count = (count + 1) / 2;

      dSTD[l] += (l < count ? dSTD[l + count] : 0);

      dMean1[l] += (l < count ? dMean1[l + count] : 0);

      dMean2[l] += (l < count ? dMean2[l + count] : 0);

      barrier(CLK_LOCAL_MEM_FENCE);

     }

   while(count > 1);

//---

   TYPE dstd = dSTD[0];

   TYPE dmean = dMean1[0] + dstd * dMean2[0];
```

We will transfer the resulting values to private variables. When calculating the derivative of the arithmetic mean deviation, we multiply the value of the right term by the derivative of the standard deviation and add it to the left term.

At this stage, we have enough data to adjust the error gradient for each buffer element. Let's organize another loop, in the body of which this work will be performed.

```
//---

   count = 0;

   while((count * ls + l) < total)

     {

      uint shift = count * ls + l;

      inp_gradient[shift] = out_gradient[shift] / (stds[std_shift] + 1e-32f) +

                (2 * dstd * outputs[shift] * stds[std_shift]  + dmean) / total;

      count++;

     }

  }
```

This concludes our work with the OpenCL program. Now we need to proceed with the second part and set up the preparatory work for launching multi-threaded computations on the main program side.

First, let's add constants for working with kernels to the defines.mqh file. We need to add constants for identifying the kernels themselves and their variables. To name the constants, we use the previously agreed rules that apply to all constants within our project:

- All constants begin with the prefix def.

- Kernels begin with the prefix def_k.

- Parameter constants after the def prefix contain a pointer to the kernel.

```
#define def_k_AttentionFeedForward     28

#define def_k_AttentionScoreGradients  29

#define def_k_AttentionHiddenGradients 30

#define def_k_Sum                      31

#define def_k_LayerNormalize           32

#define def_k_LayerNormalizeGradient   33
```

```
//--- feed-forward pass of the attention block

#define def_attff_querys               0

#define def_attff_keys                 1

#define def_attff_scores               2

#define def_attff_values               3

#define def_attff_outputs              4

#define def_attff_window               5

#define def_attff_key_size             6
```

```
//--- determine the gradient on the matrix of dependence coefficients of the attention block

#define def_attscr_scores              0

#define def_attscr_scores_grad         1

#define def_attscr_values              2

#define def_attscr_values_grad         3

#define def_attscr_outputs_grad        4

#define def_attscr_scores_temp         5

#define def_attscr_window              6
```

```
//--- gradient distribution through the attention block

#define def_atthgr_querys              0

#define def_atthgr_querys_grad         1

#define def_atthgr_keys                2

#define def_atthgr_keys_grad           3

#define def_atthgr_scores_grad         4

#define def_atthgr_key_size            5
```

```
//--- sum of vectors

#define def_sum_inputs1                0

#define def_sum_inputs2                1

#define def_sum_outputs                2
```

```
//--- vector normalization

#define def_layernorm_inputs           0

#define def_layernorm_outputs          1

#define def_layernorm_std              2

#define def_layernorm_vector_size      3

#define def_layernorm_std_shift        4
```

```
//--- vector normalization gradient

#define def_layernormgr_outputs        0

#define def_layernormgr_out_grad       1

#define def_layernormgr_inp_grad       2

#define def_layernormgr_std            3

#define def_layernormgr_vector_size    4

#define def_layernormgr_std_shift      5
```

After that, we will need to add the declaration of the new kernels to the code of the main neural network dispatcher class. Like all previously created kernels, we will add the declaration of new kernels to the CNet::InitOpenCL method. In it, we will first update the total number of kernels used in the program.

```
if(!m_cOpenCL.SetKernelsCount(34))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

After this, we will declare the kernels themselves.

```
if(!m_cOpenCL.KernelCreate(def_k_AttentionFeedForward,

                                        "AttentionFeedForward"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

```
if(!m_cOpenCL.KernelCreate(def_k_AttentionScoreGradients,

                                        "AttentionCalcScoreGradient"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

```
if(!m_cOpenCL.KernelCreate(def_k_AttentionHiddenGradients,

                                        "AttentionCalcHiddenGradient"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

```
if(!m_cOpenCL.KernelCreate(def_k_Sum, "Sum"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

```
if(!m_cOpenCL.KernelCreate(def_k_LayerNormalize, "LayerNormalize"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

```
if(!m_cOpenCL.KernelCreate(def_k_LayerNormalizeGradient

                                             "LayerNormalizeGradient"))

     {

      m_cOpenCL.Shutdown();

      delete m_cOpenCL;

      return false;

     }
```

Then we move on to the attention mechanism class CNeuronAttention and make changes to its methods in terms of working with OpenCL technology.

Let's first add the feed-forward pass method CNeuronAttention::FeedForward. In this method, we need to organize a procedure for calling the feed-forward kernel AttentionFeedForward. We have created similar processes multiple times. So, its algorithm is as follows:

- Check the presence of data buffers in the OpenCL context.

- Pass parameters to the kernel, including pointers to data buffers.

- Queue the kernel to perform operations.

While doing so, we must ensure proper control of the operations to avoid potential critical errors during the program execution.

```
bool CNeuronAttention::FeedForward(CNeuronBase *prevLayer)

  {

//--- calculation of vectors Query, Key, Value

   .....

//--- Branching the algorithm on the computing device

   MATRIX out;

   if(!m_cOpenCL)

     {

   // MQL5 block

   .....

     }

   else // OpenCL block

     {

      //--- checking data buffers

      if(m_cQuerys.GetOutputs().GetIndex() < 0)

         return false;

      if(m_cKeys.GetOutputs().GetIndex() < 0)

         return false;

      if(m_cValues.GetOutputs().GetIndex() < 0)

         return false;

      if(m_cScores.GetIndex() < 0)

         return false;

      if(m_cAttentionOut.GetOutputs().GetIndex() < 0)

         return false;
```

With all the necessary buffers in the OpenCL context, we will set up the transfer of pointers to them as kernel parameters.

```
//--- pass parameters to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionFeedForward, def_attff_keys,

                                                   m_cKeys.GetOutputs().GetIndex()))

         return false;
```

```
if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionFeedForward, def_attff_outputs,

                                            m_cAttentionOut.GetOutputs().GetIndex()))

         return false;
```

```
if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionFeedForward, def_attff_querys,

                                                  m_cQuerys.GetOutputs().GetIndex()))

         return false;
```

```
if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionFeedForward, def_attff_scores,

                                                               m_cScores.GetIndex()))

         return false;
```

```
if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionFeedForward, def_attff_values,

                                                  m_cValues.GetOutputs().GetIndex()))

         return false;
```

```
if(!m_cOpenCL.SetArgument(def_k_AttentionFeedForward, def_attff_key_size,

                                                                        m_iKeysSize))

         return false;
```

```
if(!m_cOpenCL.SetArgument(def_k_AttentionFeedForward, def_attff_window,

                                                                          m_iWindow))

         return false;
```

Next comes the procedure for placing the kernel in the execution queue. First, let's indicate the number of required threads to launch and the offset. Only after that, we will call the kernel launch function, providing it with information about the number of instances to be launched.

```
//--- put the kernel into the execution queue

      int off_set[] = {0};

      int NDRange[] = {m_iUnits};

      if(!m_cOpenCL.Execute(def_k_AttentionFeedForward, 1, off_set, NDRange))

         return false;

     }
```

This concludes the algorithm for launching the kernel of the Self-Attention block. However, we still need to add the contents of two buffers and normalize the data in the result buffer. Following the algorithm, first, we find the sum of two vectors (initial data and Self-Attention results). This operation is quite general and can be widely used outside of our neural attention layer class CNeuronAttention. Therefore, I decided to add it as a separate method to the data buffer class CBufferType::SumArray.

In the parameters to the SumArray method, we will pass a pointer to the buffer to be added. Immediately in the body of the method, we check the received pointer and the size of the received buffer. To successfully complete the operation, the size of the current buffer, which will be the first addend, and the resulting buffer (the second addend) must be equal.

```
bool CBufferType::SumArray(CBufferType *src)

  {

//--- check the source data array

   if(!src || src.Total() != Total())

      return false;
```

Like all the methods discussed earlier, the algorithm of this method is split into two threads depending on the execution device. In the block of performing operations using means MQL5 we will first match the matrix formats of both buffers. Then we perform the matrix addition operation. The result of the operation will be saved in the current buffer matrix.

```
if(!m_cOpenCL)

     {

      //--- change the matrix size

      MATRIX temp = src.m_mMatrix;

      if(!temp.Reshape(Rows(), Cols()))

         return false;

      //--- add matrices

      m_mMatrix += temp;

     }
```

The algorithm for the block of multi-threaded operations is similar to that discussed above. First, we check for the presence of data in the context of OpenCL and, if necessary, load the data from the resulting buffer. Please note that we only check the received buffer. Earlier, when dividing the algorithm depending on the computing device, we already checked the pointer to the current OpenCL context of the buffer. Therefore, we consider the data of the current buffer to have already been transferred to the OpenCL context.

The control block is followed by passing parameters to the kernel and placing it in the execution queue.

```
else

     {

      if(src.GetIndex() < 0 && !BufferCreate(m_cOpenCL))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_Sum, def_sum_inputs1, m_myIndex))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_Sum, def_sum_inputs2, src.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_Sum, def_sum_outputs, m_myIndex))

         return false;

      uint off_set[] = {0};

      uint NDRange[] = {(uint)Total()};

      if(!m_cOpenCL.Execute(def_k_Sum, 1, off_set, NDRange))

         return false;

     }

//---

   return true;

  }
```

The data normalization process is organized in the CNeuronAttention::NormlizeBuffer method. However, while following the general rules for constructing the algorithm, there are two exceptions in this method. First, we eliminated the block for checking the presence of buffers in the OpenCL context. In this case, the risk of using unloaded buffers is minimal. The reason is that before calling this method, the used buffers have already been checked multiple times, and rechecking them would be unnecessary.

```
bool CNeuronAttention::NormlizeBuffer(CBufferType *buffer,

                                      CBufferType *std,

                                      uint std_shift)

  {

   if(!m_cOpenCL)

     {

    // MQL5 block

   .....

     }

   else

     {

      if(!m_cOpenCL.SetArgumentBuffer(def_k_LayerNormalize,

                                     def_layernorm_inputs, buffer.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_LayerNormalize,

                                    def_layernorm_outputs, buffer.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_LayerNormalize,

                                           def_layernorm_std, std.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_LayerNormalize,

                              def_layernorm_vector_size, (int)buffer.Total()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_LayerNormalize,

                                          def_layernorm_std_shift, std_shift))

         return false;
```

The second point is related to the use of a local data array and thread synchronization. The reason is that thread synchronization is only available within a work group. We need to explicitly specify its size. The normalization algorithm in the kernel is structured in such a way that the workgroup size cannot be greater than the size of the local array. Let me remind you that the size of the local array is determined by the LOCAL_SIZE constant. At the same time, the number of threads cannot be greater than the size of the normalized buffer. Therefore, in the array indicating the dimension of the task space, we will indicate the smaller of the two values. Since we normalize the values of the entire buffer in one batch, the dimensions of the global and local task space will be the same.

Once we have determined the problem dimensions, we enqueue the kernel for execution.

```
int NDRange[] = {(int)MathMin(buffer.Total(), LOCAL_SIZE)};

      int off_set[] = {0};

      if(!m_cOpenCL.Execute(def_k_LayerNormalize, 1, off_set, NDRange, NDRange))

         return false;

     }

//---

   return true;

  }
```

This concludes the block of using OpenCL technology in the feed-forward method of our attention engine class, and we are finished working on this method. Further along, its code remains unchanged. The complete code is given in the description section of [constructing a method](https://www.mql5.com/en/neurobook/index/transformer/self-attention/tr_mql5/tr_feedforward) using standard MQL5 tools.

We are now moving on to working on one of the backpropagation methods — the method of distributing the error gradient through a hidden layer CNeuronAttention::CalcHiddenGradient. The algorithm of our actions remains the same. We will only make an adjustment for the use of two kernels sequentially.

I would like to remind you that when creating backpropagation kernels, we determined the need to use two additional buffers for storing intermediate values of error gradients of the dependency coefficient matrix. So let's take a step back and declare additional buffers: m_cScoreGrad and m_cScoreTemp.

```
class CNeuronAttention    :  public CNeuronBase

  {

protected:

   .....

   int               m_cScoreGrad;

   int               m_cScoreTemp;

   .....

  };
```

However, in this case, we will not declare instances of buffer objects in main memory. We will not use these buffers to exchange data between the OpenCL context and the main program. They are needed only for temporary storage of data transferred between kernels. This means that their presence in the OpenCL context memory is enough for us. In the main program, we will only declare variables to store pointers to buffers.

Let's get back to working on the CNeuronAttention::CalcHiddenGradient method. First, we check the availability and, if necessary, create new data buffers in the OpenCL context, used in the first kernel. We intentionally do not create data buffers for the second kernel right away to ensure more efficient memory usage. This will allow us to use larger data buffers when OpenCL context memory resources are limited.

```
bool CNeuronAttention::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

   .....

//--- branching the algorithm across the computing device

   if(!m_cOpenCL)

     {

   // MQL5 block

   .....

     }

   else // OpenCL block

     {

      //--- check data buffers

      if(m_cValues.GetOutputs().GetIndex() < 0)

         return false;

      if(m_cValues.GetGradients().GetIndex() < 0)

         return false;

      if(m_cScores.GetIndex() < 0)

         return false;

      if(m_cAttentionOut.GetGradients().GetIndex() < 0)

         return false;

      if(m_cScoreGrad < 0)

         return false;

      if(m_cScoreTemp < 0)

         return false;
```

After checking all the necessary buffers, we will pass pointers to them to the kernel.

```
//--- pass parameters to the kernel

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients,

              def_attscr_outputs_grad, m_cAttentionOut.GetGradients().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients,

                                         def_attscr_scores, m_cScores.GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients,

                                            def_attscr_scores_grad, m_cScoreGrad))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients,

                                            def_attscr_scores_temp, m_cScoreTemp))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients,

                            def_attscr_values, m_cValues.GetOutputs().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients,

                     def_attscr_values_grad, m_cValues.GetGradients().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AttentionScoreGradients,

                                                    def_attscr_window, m_iWindow))

         return false;
```

In addition to the pointers to data buffers, we pass the size of the vector describing one element of the sequence to the kernel.

After passing all the parameters, specify the number of required parallel threads and invoke the function to enqueue the kernel.

```
//--- Place the kernel in the execution queue

      int off_set[] = {0};

      int NDRange[] = {m_iUnits};

      if(!m_cOpenCL.Execute(def_k_AttentionScoreGradients, 1, off_set, NDRange))

         return false;
```

Now we move on to working on the next kernel. Let's check the availability of buffers required for the new kernel.

```
if(m_cQuerys.GetOutputs().GetIndex() < 0)

         return false;

      if(m_cQuerys.GetGradients().GetIndex() < 0)

         return false;

      if(m_cKeys.GetOutputs().GetIndex() < 0)

         return false;

      if(m_cKeys.GetGradients().GetIndex() < 0)

         return false;
```

After checking all the necessary data buffers, we will pass pointers to them to the kernel.

```
if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionHiddenGradients,

                                 def_atthgr_keys, m_cKeys.GetOutputs().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionHiddenGradients,

                          def_atthgr_keys_grad, m_cKeys.GetGradients().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionHiddenGradients,

                             def_atthgr_querys, m_cQuerys.GetOutputs().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionHiddenGradients,

                      def_atthgr_querys_grad, m_cQuerys.GetGradients().GetIndex()))

         return false;

      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionHiddenGradients,

                                             def_atthgr_scores_grad, m_cScoreGrad))

         return false;

      if(!m_cOpenCL.SetArgument(def_k_AttentionHiddenGradients,

                                                 def_atthgr_key_size, m_iKeysSize))

         return false;
```

In addition to the pointers to data buffers, we pass the size of the key vector for one element of the sequence to the kernel parameters.

After finishing the transfer of all the necessary data to the kernel, we initialize the enqueuing of its execution. The arrays with the specified offset and the number of required kernel instances for execution are already prepared after launching the previous kernel, and we don't need to set them again. Therefore, we simply invoke the function to enqueue the kernel.

```
if(!m_cOpenCL.Execute(def_k_AttentionHiddenGradients, 1, off_set, NDRange))

         return false;
```

At this point, we conclude our work on building the methods of our attention class and can proceed to test its functionality.

## 5.GPT backpropagation methods

In the previous sections, we looked at the architecture of the GPT model and even implemented methods to initialize our new class and implement the feed-forward pass through the model algorithm. Now let's look at a possible implementation of the backpropagation pass for this algorithm.

To implement the backpropagation pass in each new class we override three methods:

- CalcHiddenGradient — method for calculating the error gradient through the hidden layer

- CalcDeltaWeights — method for calculating the error gradient to the level of the weight matrix

- UpdateWeights — method for updating weights

This class will not be an exception, and we will redefine all three methods. Let's start with the first backpropagation and, probably, the most complex method: error gradient propagation through the hidden layer. It is in this method that we have to repeat the entire feed-forward algorithm in reverse order.

In the parameters, the method receives a pointer to the object of the previous layer, to which we have to pass the error gradient. Again, in the body of the method, we implement a block of checks. In it, according to the already established good tradition, we check the validity of pointers to all objects used in the method. This approach helps eliminate many critical errors during the execution of the method code.

```
bool CNeuronGPT::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

//--- check the relevance of all objects

   if(!m_cOutputs || !m_cGradients ||

      m_cOutputs.Total() != m_cGradients.Total())

      return false;
```

Next, by analogy with the forward pass method, we organize a loop for searching through the internal neural layers. But this time, in accordance with the principles of backward pass, we also organize the cycle with a countdown of iterations. All further iterations will be performed in the body of the loop and repeated for all nested layers of our model.

```
//--- run a loop through all internal layers in reverse order

   for(int layer = m_iLayers - 1; layer >= 0; layer--)

     {

      CNeuronBase *FF2 = m_cFF2.At(layer);

      if(!FF2)

         return false;

      CBufferType *Gradients = FF2.GetGradients();

      //--- scale the gradient for normalization

      if(!NormlizeBufferGradient(FF2.GetOutputs(), Gradients,

                                               GetPointer(m_dStd[layer]), 1))

         return false;
```

In the body of the loop, we first retrieve a pointer to the corresponding neural layer of the output of the Feed Forward FF2 block and adjust its error gradient buffer to the derivative of the normalization function. We discussed the reasons for this operation in detail when constructing a similar method for the [Self-Attention](https://www.mql5.com/en/neurobook/index/transformer/self-attention/tr_mql5/tr_backprop#normalization) algorithm.

After this, we sequentially call the error gradient distribution methods for the internal layers of the Feed Forward block. We also call the methods in the reverse order: first for the second layer, and then for the first one.

```
//--- propagate a gradient through the Feed Forward block

      CNeuronBase *FF1 = m_cFF1.At(layer);

      if(!FF2.CalcHiddenGradient(FF1))

         return false;

      CNeuronBase *W0 = m_cW0.At(layer);

      if(!FF1.CalcHiddenGradient(W0))

         return false;
```

During the feed-forward pass, we added up the results of the Multi-Heads Self-Attention and Feed Forward blocks. Also, now we need to draw an error gradient in two directions. We add the error gradients at the output level of the specified blocks. Then we adjust the total tensor by the derivative of the layer normalization function.

```
CBufferType *attention_grad = W0.GetGradients();

      if(!attention_grad.SumArray(Gradients))

         return false;

      //--- scale the gradient for normalization

      if(!NormlizeBufferGradient(W0.GetOutputs(), attention_grad,

                                            GetPointer(m_dStd[layer]), 0))

         return false;
```

Next, we distribute the error gradient across the attention heads by calling the error gradient distribution method of the internal neural layer W0.

```
//--- initialize Scores

      CNeuronBase *Scores = m_cScores.At(layer);

      if(!Scores)

         return false;

      //--- distribute the error gradient across the heads of attention

      CNeuronBase *AttentionOut = m_cAttentionOut.At(layer);

      if(!W0.CalcHiddenGradient(AttentionOut))

         return false;
```

Until now, everything was simple and transparent. We simply called the corresponding methods of our internal neural layers in reverse order. But then comes the algorithm block that is not covered by the methods of internal neural layers. It was implemented inside the feed-forward method. Therefore, we also have to completely recreate the error gradient backpropagation functionality.

First, let's do the preparatory work and create local pointers to Querys, Keys, and Values objects. At this point, dont forget to check the validity of the received object pointers.

```
//--- get pointers to Querys, Keys, Values objects

      CNeuronBase *Querys = m_cQuerys.At(layer);

      if(!Querys)

         return false;

      CNeuronBase *Keys = m_cKeys.At(layer);

      if(!Keys)

         return false;

      CNeuronBase *Values = m_cValues.At(layer);

      if(!Values)

         return false;
```

Next, we need to create two options for implementing the algorithm: using standard MQL5 tools and in multi-threaded operations mode using OpenCL technology. We create a branching of the algorithm depending on the selected device for performing mathematical operations. As usual, in this section, we will look at the implementation of the algorithm using standard MQL5 tools and will return to the implementation of the multi-threaded operations block in other sections.

To organize calculations using standard MQL5 tools, we prepare dynamic arrays. In one array, we load error gradient data from the buffer. Some arrays are filled with the results of the feed-forward pass and others are initialized with zero values for subsequent gradient error accumulation operations.

```
//--- branching of the algorithm across the computing device

      attention_grad = AttentionOut.GetGradients();

      if(!m_cOpenCL)

        {

         MATRIX gradients[];

         if(!attention_grad.m_mMatrix.Vsplit(m_iHeads, gradients))

            return false;

         if(!Querys.GetGradients().m_mMatrix.Reshape(3, m_iHeads * m_iKeysSize))

            return false;

         MATRIX values[];

         if(!Values.GetOutputs().m_mMatrix.Vsplit(m_iHeads, values))

            return false;

         MATRIX keys[];

         if(!Keys.GetOutputs().m_mMatrix.Vsplit(m_iHeads, keys))

            return false;

         MATRIX querys[];

         MATRIX query = Querys.GetOutputs().m_mMatrix;

         if(!query.Reshape(3, m_iHeads * m_iKeysSize) ||

            !query.Resize(1, query.Cols()))

            return false;

         if(!query.Vsplit(m_iHeads, querys))

            return false;

         MATRIX querys_grad = MATRIX::Zeros(m_iHeads, m_iKeysSize);

         MATRIX keys_grad = querys_grad;

         MATRIX values_grad = querys_grad;
```

First, we will distribute the error gradient to the Value tensor. It's important to note that we'll be distributing the error gradient not across the entire tensor but only for the current element. This is reasonable when we consider the purpose of error gradient distribution. We aim to optimize the model parameters throughout the training process, and distributing the error gradient helps us obtain guidelines for this optimization.

When distributing the error gradient to the Value tensor, we need to pass it in two directions: to the previous layer and to the weight matrix responsible for forming the current layer's tensor.

We can only transfer the error gradient for the current state to the previous layer. The buffer of the previous layer is unable to accept more because, during the feed-forward pass, it only provides the current state for which it expects the error gradient.

Also, only the current state error gradient can be propagated to the weight matrix. To distribute the error from previous states, we would need the input data from those previous states. However, the previous layer does not provide this information, and we did not save it in the buffers of our layer.

Therefore, distributing the gradient to the elements of the value tensor, except for the current state, is a dead-end task and does not make sense.

The general approach is as follows: during the feed-forward pass, we calculate only the current state and additionally retrieve from memory those already calculated in previous iterations. A similar situation applies during the backpropagation pass: it is assumed that the error gradient from previous states has already been considered in the backpropagation methods in previous iterations. This significantly reduces the number of operations for each iteration of the feed-forward and backpropagation passes.

I hope the logic is clear. Let's return to our backpropagation method. We paused at passing the error gradient to the Value tensor. To execute this iteration, we will first create a local pointer to the attention coefficient vector and then organize a loop.

Our loop will iterate through the active attention heads. Here, we immediately save the attention coefficient vector corresponding to the analyzed attention head in a local matrix. We multiply the gradient vector obtained from previous iterations by the attention coefficient for the current element of the sequence. The resulting values are saved in the error gradient matrix in the Values buffer.

```
for(int head = 0; head < m_iHeads; head++)

           {

            MATRIX score = MATRIX::Zeros(1, m_iUnits);

            if(!score.Row(Scores.GetOutputs().m_mMatrix.Row(head), 0))

               return false;

         //--- distribution of the gradient on Values

            if(!values_grad.Row((gradients[head] *

                                     score[0, m_iCurrentPosition]).Row(0), head))

               return false;
```

Next, we need to distribute the gradient in the second direction: through the matrix of dependency coefficients on the Query and Key tensors. But first, we need to propagate the gradient through the vector of dependence coefficients. We multiply the error gradient matrices at the output of the attention block and the Values ​​matrix and obtain a gradient at the level of the vector of dependence coefficients.

So, we have a vector of error gradients for one attention head. But I would like to remind you that during the feed-forward pass, we normalized the vector of dependence coefficients with the Softmax function. Therefore, the obtained error gradients are valid for normalized data. To further distribute the error gradients, we need to adjust the error gradients to the derivative of the specified function.

A special feature of the Softmax function is the requirement for a complete set of tensor values to compute the value of each element. Similarly, to compute the derivative of one element, we need a complete set of values for the function results. In our case, the results of the function are the normalized vector of dependency coefficients, which we obtained during the forward pass. We have also already obtained the vector of error gradients. Thus, we have all the necessary initial data to perform the operations of finding the derivative of a function and adjusting the error gradient. The formula for the derivative of the Softmax  function is as follows:

The practical part of the error gradient adjustment operations is implemented using MQL5 matrix operations. After adjusting the error gradients, we divide the resulting vector by the square root of the dimension of the Key vector of one element of the sequence. We performed the same operation during the feed-forward pass to prevent uncontrolled growth of non-normalized dependency coefficients.

```
//--- gradient distribution to Querys and Keys

            MATRIX score_grad = gradients[head].MatMul(values[head].Transpose());

            //---

            MATRIX ident = MATRIX::Identity(m_iUnits, m_iUnits);

            MATRIX ones = MATRIX::Ones(m_iUnits, 1);

            score = ones.MatMul(score);

            score = score.Transpose() * (ident - score);

            score_grad = score_grad.MatMul(score.Transpose()) /

                                                           sqrt(m_iKeysSize);

            MATRIX temp = score_grad.MatMul(keys[head]);

            if(!querys_grad.Row(temp.Row(0), head))

               return false;

            temp = querys[head] * score_grad[0, m_iCurrentPosition];

            if(!keys_grad.Row(temp.Row(0), head))

               return false;

           }
```

As a result of these operations, we obtain the adjusted error gradient for one element of the dependency coefficient vector. But we will not save it to the next data buffer. Instead, we will immediately distribute it to the corresponding elements of the Query and Key tensors. To do this, we need to multiply this value by the vector of the opposite tensor. To determine the error gradient on the Qwery vector, we have a complete set of sequence elements in the Key tensor. However, in the Qwery tensor, we only have one sequence element. Therefore, the error gradient on the Key tensor will be propagated only for the current element of the sequence. We save the obtained error gradient values into the matrices we prepared earlier.

By obtaining error gradients at the levels of Query and Keys tensors, we complete the operations of the loop through attention heads.

As soon as the full loop of iterations is completed, our querys_grad, keys_grad, and values_grad matrices will contain the accumulated error gradients for the current sequence element across all attention heads. All we have to do is transfer its values to the error gradient buffer of our internal Querys layer.

```
if(!querys_grad.Reshape(1, m_iHeads * m_iKeysSize) ||

            !keys_grad.Reshape(1, m_iHeads * m_iKeysSize) ||

            !values_grad.Reshape(1, m_iHeads * m_iKeysSize))

            return false;

         if(!Querys.GetGradients().Row(querys_grad.Row(0), 0) ||

            !Querys.GetGradients().Row(keys_grad.Row(0), 1) ||

            !Querys.GetGradients().Row(values_grad.Row(0), 2))

            return false;

         if(!Querys.GetGradients().Reshape(1, Querys.GetGradients().Total()))

            return false;

        }

      else // OpenCL block

        {

         return false;

        }
```

This concludes the block for separating the operations of the algorithm depending on the device for performing the operations. Next, we will continue executing the algorithm using the methods of our internal neural layers.

Previously, we obtained a concatenated tensor of error gradients that includes data from all attention heads and from all three entities (Query, Key, Value). Now, using the method that propagates the gradient through the hidden layer of our internal neural layer Querys.CalcHiddenGradient, we can transfer the error gradient to the previous layer buffer. Before performing this operation, we need to decide in which objects buffer we will write the error gradients. We created this class as a multi-layer block, and all operations of the method are performed in a loop iterating through the active layer of our block. Therefore, to the object of the previous neural layer, whose pointer we received in the parameters of this method, we transfer data only from the first neural layer of our block. It will have index 0 in the collection of nested neural layers of our GPT block. All other nested neural layers must pass the error gradient to the internal neural layer buffer FF2 of the previous nested neural layer. Let me remind you that FF2 is the internal neural layer with the results of the Feed Forward block.

Therefore, we will create a local pointer to the object of the previous neural layer and assign it a pointer to the required object depending on the index of the active nested neural layer in our GPT block. Only after obtaining the correct pointer to the object of the correct previous layer, we transfer the error gradient to its buffer.

```
//--- transfer the error gradient to the previous layer

      CNeuronBase *prevL = (layer == 0 ? prevLayer : m_cFF2.At(layer - 1));

      if(!Querys.CalcHiddenGradient(prevL))

         return false;

      if(!prevL.GetGradients().SumArray(W0.GetGradients()))

         return false;

     }

//---

   return true;

  }
```

Please note that when constructing similar methods in the implementation classes of attention mechanisms, at this point, we created a complete procedure for summing error gradients from four directions. Now, thanks to the use of the concatenated error gradient buffer, we obtain the total error gradient from three directions by executing the method of only one neural layer. We still have to add gradients, but only once. To the obtained error gradient, we will add the error gradient at the level of the outputs of the multi-head attention block. You remember that during the feed-forward pass, we also added the original data with the tensor of the multi-head attention block's outputs. Therefore, the error gradient must go through all the steps that the signal goes through during the feed-forward pass, but in reverse order.

This concludes the operations in the body of the loop iterating through the nested neural layers of our GPT block, as well as the overall operations of our method. We close the loop and exit the method.

And once again, I want to emphasize: do not forget to monitor every step of the operation execution. This helps minimize the risk of critical errors and makes the program operation more controlled and reliable.

We have discussed the organization of the error gradient propagation method to the previous layer. But this is only one of the three backpropagation methods that we must override for this class. Therefore, after propagating the error gradient to the previous neural layer, we need to propagate the error gradient to the internal weight matrices contained within the depths of a considerable number of internal objects of the neural layers. In accordance with the structure of our class methods, this functionality is performed in the CalcDeltaWeights method.

To propagate the error gradient to the weight matrix of any of the previously discussed neural layers, two things are necessary:

- The error gradient at the output level of a given neural layer to the activation function.

- The initial data provided by the previous neural layer.

To organize this process, we already have all the necessary data. In the previous method, we distributed the error gradient to each neural layer. We will get a pointer to the previous neural layer in the parameters of the CNeuronGPT::CalcDeltaWeights method.

As usual, in the body of the method, we organize a control block to check the pointers of all used internal objects. The control block should be minimal and sufficient. Eliminate redundant and explicitly repetitive controls, as they do not add value to the program operation and can slow it down. Moreover, each operation, including control, requires resources and time. Let's think about the objects for which we should update weight matrices. These include:

- The Query neural layer, which returns a concatenated tensor of three entities (Query, Key, Value).

- The W0 matrix neural layer.

- Two neural layers of the Feed Forward block.

All the mentioned objects are declared static. Therefore, there is no need to check their pointers since their presence is controlled by the system. This allows us to exclude the control block from this method.

Everything else is straightforward and simple. Let's organize a loop through all the nested neural layers of our GPT block. In the body of the block, we extract all the objects of the above collections, one by one. First, we check the pointer to the object, and then we call its method to propagate the error gradient to the level of the weight matrix.

```
bool CNeuronGPT::CalcDeltaWeights(CNeuronBase *prevLayer, bool read)

  {

//--- in a loop, we call the method for each internal object

   for(int layer = 0; layer < m_iLayers; layer++)

     {

      if(!m_cFF2.At(layer))

         return false;

      CNeuronBase *temp = m_cFF2.At(layer);

      if(!temp.CalcDeltaWeights(m_cFF1.At(layer), false))

         return false;

      temp = m_cFF1.At(layer);

      if(!temp.CalcDeltaWeights(m_cW0.At(layer), false))

         return false;

      temp = m_cW0.At(layer);

      if(!temp.CalcDeltaWeights(m_cAttentionOut.At(layer), false))

         return false;

      temp = m_cQuerys.At(layer);

      if(!temp)

         return false;

      CNeuronBase *prevL = (layer == 0 ? prevLayer : m_cFF2.At(layer - 1));

      if(!temp.CalcDeltaWeights(prevL, (read && layer == m_iLayers - 1)))

         return false;

     }

//---

   return true;

  }
```

It is worth mentioning a few words about the order in which methods of internal objects are called. From the perspective of mathematical operations, the order of method calls does not affect the final result. However, the order of method calls used in the loop body is not random. Note that in the loop body, we explicitly check the pointers for only two objects that do not serve as the input data for other internal layers. The reason is that the called methods of neural layers also have a control block that checks the incoming data, including the received pointers. To eliminate repeated checks of object pointers, we first pass a pointer to the object as input to another object, check the result of the operations of the called method, which, among other things, confirms the validity of the passed pointer, and then confidently access the object because its pointer was checked during the execution of the previous object method. In this way, we organize a comprehensive check of all object pointers without explicit control within the method body and eliminate redundant pointer checks that could slow down the program execution.

Next, we will consider the method for updating model parameters. This function does not require external object data. There is not a single object pointer in the method parameters, as there are only parameter values for executing the specified parameter optimization algorithm.

In the method body, we also organize a loop to iterate through the nested neural layers of our GPT block. In the loop body, we extract one object from each collection, check the validity of the pointer, and call the method to update the weight matrix of each object.

```
bool CNeuronGPT::UpdateWeights(int batch_size, TYPE learningRate,

                               VECTOR &Beta, VECTOR &Lambda)

  {

//--- in a loop we call the method for each internal object

   for(int layer = 0; layer < m_iLayers; layer++)

     {

      CNeuronBase *temp = m_cFF2.At(layer);

      if(!temp || !temp.UpdateWeights(batch_size, learningRate, Beta, Lambda))

         return false;

      temp = m_cFF1.At(layer);

      if(!temp || !temp.UpdateWeights(batch_size, learningRate, Beta, Lambda))

         return false;

      temp = m_cW0.At(layer);

      if(!temp || !temp.UpdateWeights(batch_size, learningRate, Beta, Lambda))

         return false;

      temp = m_cQuerys.At(layer);

      if(!temp || !temp.UpdateWeights(batch_size, learningRate, Beta, Lambda))

         return false;

     }

//---

   return true;

  }
```

Since the called methods do not access external objects, our control optimization approach will not work here due to the absence of explicitly repetitive controls. Therefore, we need to explicitly check each object pointer before calling its method.

We have discussed the implementation of three backpropagation methods and with that, we conclude our work on implementing the GPT model algorithm in our CNeuronGPT class. For the complete implementation of functionality using standard MQL5 tools, we need to override the methods for working with files. We've already discussed the importance of these methods for the operation of neural network models.

## 5.GPT feed-forward method

We continue our work on implementing the GPT algorithm proposed by the OpenAI team. We have already created the basic skeleton of the class with objects to implement the algorithm. Now we are proceeding directly to its implementation. Yes, the class will utilize the familiar Self-Attention algorithm, but with some implementation specifics.

As in all the previously discussed classes, all the feed-forward functionality is implemented in the CNeuronGPT::FeedForward method. As you know, this method is virtual, is inherited from the base neural network class, and is overridden in each class to implement a specific algorithm. In the method parameters, it receives a pointer to the object of the previous neural layer, which contains the initial data in its buffer for executing the algorithm.

As in all previous implementations, we start the method with the control block. In this block, we check the validity of pointers to the objects involved in the method. This operation allows us to prevent many critical errors when accessing invalid objects.

```
bool CNeuronGPT::FeedForward(CNeuronBase *prevLayer)

  {

//--- check the relevance of all objects

   if(!prevLayer || !prevLayer.GetOutputs())

      return false;
```

Next, we increment the m_iCurrentPosition index of the current object in the Key and Value buffers. We need this pointer for organizing the stack in these buffers. In fact, the Self-Attention algorithm performs a weighted summation of different contexts into a single vector. According to the mathematical rules, rearranging the places of the summands does not change the sum. That is, it is absolutely irrelevant at which position of the data buffer the element is located. What's important is its presence. This is the disadvantage of this algorithm for handling timeseries, but also a plus for our implementation. When organizing the data stack in the Key and Value buffers, we will not perform a costly full data shift. Instead, we will move the pointer along the stack and overwrite the data in the corresponding data buffer elements.

```
//--- increment the pointer to the current object in the data stack

   m_iCurrentPosition++;

   if(m_iCurrentPosition >= m_iUnits)

      m_iCurrentPosition = 0;
```

The next straightforward step is taken to organize the correct functioning of our internal multi-layered architecture. The pointer to the previous neuron layer obtained in the parameters is needed only for the first internal layer. Further internal neural layers will use the output from the preceding internal neural layer as their input data. Therefore, for internal use, we introduce a local variable to store a pointer to the previous neural layer. Now we will assign it the pointer obtained from the method parameters, but after the iterations of each internal neural layer, we will write a new pointer into it. So, we can organize the loop operation through all internal neural layers. In this case, we will work with one object pointer variable in the loop body. In reality, each neural layer will access a buffer of its own input data.

```
CNeuronBase *prevL = prevLayer;
```

As mentioned before, the main functionality of our feed-forward method will be implemented within the body of the loop iterating through the internal neural layers. Therefore, the next step is to create such a loop. Right within the loop, we extract from the collection the pointer to the Querys object corresponding to the current internal neural layer. We check the validity of the extracted pointer and then execute the feed-forward method of the corresponding object.

```
//--- run the loop through all internal layers

   for(int layer = 0; layer < m_iLayers; layer++)

     {

      CNeuronBase *Querys = m_cQuerys.At(layer);

      if(!Querys || !Querys.FeedForward(prevL))

         return false;
```

Further functionality is not covered by the methods of internal objects. Therefore, as in previous Self-Attention implementations, we will implement it within the body of the method. Here, it is important to remember that in all implementations of our library, we provided the user with the option to choose the device and the technology for performing mathematical operations. In this class, we will not deviate from our principles and will also implement algorithm separation based on the chosen computational device. But first, let's perform some preparatory work and extract pointers to the objects of the analyzed internal layer from the collections. Do not forget to validate the obtained pointers.

```
CNeuronBase *Querys = m_cQuerys.At(layer);

      if(!Querys || !Querys.FeedForward(prevL))

         return false;

      CNeuronBase *Keys = m_cKeys.At(layer);

      if(!Keys)

         return false;

      CNeuronBase *Values = m_cValues.At(layer);

      if(!Values)

         return false;

      //--- initializing Scores

      CNeuronBase *Scores = m_cScores.At(layer);

      if(!Scores)

         return false;

      //--- initializing AttentionOut

      CNeuronBase *AttentionOut = m_cAttentionOut.At(layer);

      if(!AttentionOut)

         return false;
```

Next, we split the algorithm based on the chosen computational device. In this chapter, we will discuss the organization of the process using standard MQL5 tools, and we will revisit the implementation of multi-threaded computations using the OpenCL technology in the following sections.

```
//--- branching of the algorithm by the computing device

      if(!m_cOpenCL)

        {

         MATRIX array[];

         if(!Querys.GetOutputs().m_mMatrix.Vsplit(3, array))

            return false;

         if(!Keys.GetOutputs().Row(array[1].Row(0), m_iCurrentPosition))

            return false;

         if(!Values.GetOutputs().Row(array[2].Row(0), m_iCurrentPosition))

            return false;
```

As you may recall, during the execution of the feed-forward pass of the specified object, we simultaneously construct all the vectors for the Query, Key, and Value tensors for all attention heads. In the next step, we move the vectors of the last two tensors to the corresponding stacks. For this purpose, we will divide the result buffer of the Querys layer into 3 equal parts: query, key, and value. First, we copy the data into the appropriate data buffers. When copying data, we will use the m_iCurrentPosition variable to determine the offset in the buffers.

Then we will do a bit of preparatory work. To facilitate access to the elements of the objects, we will create local pointers to the result buffers of the internal neural layers for Query and Key. We will also prepare dynamic arrays to perform the computational part.

```
MATRIX out;

         if(!out.Init(m_iHeads, m_iKeysSize))

            return false;

         MATRIX array_keys[], array_values[];

         MATRIX array_querys[];

         MATRIX keys = Keys.GetOutputs().m_mMatrix;

         MATRIX values = Values.GetOutputs().m_mMatrix;
```

Similarly to the construction of the feed-forward algorithm in the previously discussed implementation of multi-head attention, we will split the data matrices according to the attention heads.

```
if(!array[0].Vsplit(m_iHeads, array_querys))

            return false;

         if(!keys.Reshape(m_iUnits, m_iHeads * m_iKeysSize))

            return false;

         if(!keys.Vsplit(m_iHeads, array_keys))

            return false;

         if(!values.Reshape(m_iUnits, m_iHeads * m_iKeysSize))

            return false;

         if(!values.Vsplit(m_iHeads, array_values))

            return false;
```

After that, we create a nested loop for computations. In it, we iterate through the attention heads used. Right here in the body, we extract the Query vector and the Keys matrix of the analyzed attention head. We multiply them and divide the resulting vector by the square root of the dimension of the description vector for one element in the Keys matrix. We normalize it using the Softmax function.

```
//--- define Scores

         for(int head = 0; head < m_iHeads; head++)

           {

            MATRIX score=array_querys[head].MatMul(array_keys[head].Transpose())/

                                                               sqrt(m_iKeysSize);

            //--- normalize Scores

            if(!score.Activation(score,AF_SOFTMAX))

               return false;

            if(!Scores.GetOutputs().Row(score.Row(0), head))

               return false;
```

Thus, after normalizing the data, the sum of all dependency coefficients will be equal to one. This gives us reason to expect a vector with appropriate characteristics at the output of the Self-Attention block. We save the normalized data in a buffer for later use during the backpropagation pass.

After calculating and normalizing the dependency coefficient vector, we have all the necessary data to calculate the output values of the Self-Attention block. We multiply the normalized Score vector by the Value tensor. Then we copy the resulting vector into the local result matrix.

```
//--- attention block output

            MATRIX o = score.MatMul(array_values[head]);

            if(!out.Row(o.Row(0), head))

               return false;

           }
```

As a result of performing all iterations of the loop system in our out matrix, the concatenated output of the Multi-Heads Self-Attention block will be collected. We transfer them to the result buffer of the AttentionOut neural layer to use in our algorithm later.

```
if(!out.Reshape(1, m_iHeads * m_iKeysSize))

            return false;

         AttentionOut.GetOutputs().m_mMatrix = out;

        }

      else // OpenCL block

        {

         return false;

        }
```

This completes the operation separation block depending on the computing device. Next, we will use the methods of our internal objects.

According to the Multi-Heads Self-Attention algorithm, the next step is to create a single ordered weighted vector of results for the entire multi-head attention block from the concatenated output of all attention heads. For this purpose, the matrix W0 is provided in the method algorithm. In contrast, we have assigned this functionality to the internal fully connected neural layer W0. We extract the pointer to the object of the corresponding neural layer and call its feed-forward method. To prevent critical errors, we must validate the pointer to the object before calling its method.

```
//--- weighted output of all heads of attention

      CNeuronBase *W0 = m_cW0.At(layer);

      if(!W0 || !W0.FeedForward(AttentionOut))

         return false;
```

We are nearing the completion of the implementation of the Multi-Heads Self-Attention block algorithm. According to the GPT model algorithm, we need to add the obtained result to the original data and normalize the result using the formulas.

First, we call the CBufferType::SumArray method of summarizing two buffers. Then we normalize the data using the CNeuronGPT::NormlizeBuffer method. Its algorithm completely repeats the relevant method of the CNeuronAttention class.

```
//--- add to the input data and normalize

      if(!W0.GetOutputs().SumArray(prevL.GetOutputs()))

         return false;

      if(!NormlizeBuffer(W0.GetOutputs(), GetPointer(m_dStd[layer]), 0))

         return false;
```

After successfully normalizing all the data, we will pass the signal through two internal neural layers of the Feed Forward block. This operation is straightforward: we sequentially extract pointers to the respective neural layer objects, validate the pointers, and call the feed-forward method for each internal layer.

```
//--- forward pass of Feed Forward block

      CNeuronBase *FF1 = m_cFF1.At(layer);

      if(!FF1 || !FF1.FeedForward(W0))

         return false;

      CNeuronBase *FF2 = m_cFF2.At(layer);

      if(!FF2 || !FF2.FeedForward(FF1))

         return false;
```

Finally, we add the result of the Feed Forward block to the result of the Multi-Heads Self-Attention block. Then we normalize the obtained values.

```
//--- perform summation with the attention output and normalizing

      CBufferType *prev = FF2.GetOutputs();

      if(!prev.SumArray(W0.GetOutputs()))

         return false;

      if(!NormlizeBuffer(prev, GetPointer(m_dStd[layer]), 1))

         return false;
```

This completes the feed-forward pass for one internal layer. We can proceed to the next iteration of the loop and the next internal neural layer. But first, we need to change the pointer to the neural layer of the initial data, as we discussed at the beginning of the method. The results of the forward pass are contained in the buffer of the internal neural layer FF2. We write the pointer to it into the local variable prevL, with which we work at the next iteration of the loop.

```
prevL = FF2;

     }

//---

   return true;

  }
```

So, upon completing all iterations of the nested neural layer enumeration loop, we obtain a complete recalculation of the feed-forward pass for our block. To change the number of such neural layers, we only need to modify one parameter when calling the initialization method of the CNeuronGPT class in the GPT model.

With this, we conclude the work on the feed-forward pass method and move on to organizing the backpropagation process.

5.3.2.3 File operations

We continue working on our GPT model implementation class. We have already implemented the functionality of this model in the methods of our CNeuronGPT class. In the previous sections, we discussed object initialization methods and created the processes of feed-forward and backpropagation passes. The specified functionality is sufficient for creating a test model, and it is even possible to conduct a series of tests to assess the model functionality.

However, we have already discussed the importance of file handling methods for the practical operation of any neural network model. The main significance of this process is attributed to the cost of the model training process because it requires both time and resources. Often such costs are quite high. Therefore, there is a strong desire to train the model once and then use it with maximum workload in the shortest possible time.

The unpredictable and highly volatile nature of financial markets does not leave us with hope for an indefinitely prolonged usage of a model trained once. However, even in this case, with the volatility of the environment, retraining the model in new conditions will require fewer resources and time compared to training the model from scratch with random weights.

Therefore, let's continue our work and implement methods for working with files. As always, let's start with the CNeuronGPT::Save method that saves data to a file.

When starting to work on the data saving method, as usual, we take a critical look at the structure of our class and evaluate the necessity of saving the data for each object.

```
class CNeuronGPT    :  public CNeuronBase

  {

protected:

   CArrayLayers      m_cQuerys;

   CArrayLayers      m_cKeys;

   CArrayLayers      m_cValues;

   CArrayLayers      m_cScores;

   CArrayLayers      m_cAttentionOut;

   CArrayLayers      m_cW0;

   CArrayLayers      m_cFF1;

   CArrayLayers      m_cFF2;

   //---

   int               m_iLayers;

   int               m_iWindow;

   int               m_iUnits;

   int               m_iKeysSize;

   int               m_iHeads;

   CBufferType       m_dStd[];

   int               m_iCurrentPosition;

   int               m_iScoreTemp;

   virtual bool      NormlizeBuffer(CBufferType *buffer, CBufferType *std,

                                                               uint std_shift);

   virtual bool      NormlizeBufferGradient(CBufferType *output,

                      CBufferType *gradient, CBufferType *std, uint std_shift);

public:

                     CNeuronGPT(void);

                    ~CNeuronGPT(void);

   //---

   virtual bool      Init(const CLayerDescription *desc) override;

   virtual bool      SetOpenCL(CMyOpenCL *opencl) override;

   virtual bool      FeedForward(CNeuronBase *prevLayer) override;

   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;

   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer, bool read) override;

   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,

                                           VECTOR &Beta, VECTOR &Lambda) override;

   //---

   virtual int       GetUnits(void) const { return m_iUnits;   }

   virtual int       GetLayers(void) const { return m_iLayers; }

   //--- methods for working with files

   virtual bool      Save(const int file_handle) override;

   virtual bool      Load(const int file_handle) override;

   //--- object identification method

   virtual int       Type(void) override  const { return(defNeuronGPT);  }

  };
```

At this point, we realize that besides constants, our class contains only collections of objects. The resources required to recreate the collection objects with a complete description of their structure will be much higher than the potential savings in disk space resources. Therefore, we organize the saving of all collections in a data file for model recovery.

In the parameters, this method receives a file handle to save the data. To avoid duplicate controls and reduce the total amount of program code, we do not check the received handle. Instead, we call the similar method of the parent class, to which we pass the received handle. The advantages of this approach are obvious. With a single command, we check the received handle and save the data of objects inherited from the parent class. By checking the result of the parent class method, we control the entire specified process.

```
bool CNeuronGPT::Save(const int file_handle)

  {

//--- calling a method of a parent class

   if(!CNeuronBase::Save(file_handle))

      return false;
```

After the successful execution of the method of the parent class, we save the following constants of our method to the file:

- m_iLayers — the number of nested neural layers of the GPT block

- m_iWindow — the size of the source data window (the size of the description vector of one element of the source data sequence)

- m_iKeysSize — the size of the description vector of one element of the Keys key tensor

- m_iHeads — the number of attention heads used

- m_iUnits — the number of elements in the sequence

- m_iCurrentPosition — the position of the currently analyzed element

```
//--- save the constants

   if(FileWriteInteger(file_handle, m_iLayers) <= 0)

      return false;

   if(FileWriteInteger(file_handle, m_iWindow) <= 0)

      return false;

   if(FileWriteInteger(file_handle, m_iKeysSize) <= 0)

      return false;

   if(FileWriteInteger(file_handle, m_iHeads) <= 0)

      return false;

   if(FileWriteInteger(file_handle, m_iUnits) <= 0)

      return false;

   if(FileWriteInteger(file_handle, m_iCurrentPosition) <= 0)

      return false;
```

Saving the position of the current analyzed element is necessary for the proper functioning of the Key and Value stacks. However, in real usage conditions, I would recommend that before using the model, you sequentially input data into it in a volume sufficient to fully fill the stacks. This approach will allow you to control the process of data loading into the model and eliminate the risk of possible omissions, which could potentially impact the accuracy of the model performance in the initial stages after data loading. Of course, the model will level out after the stack is completely filled. But the risk of losses up to this point increases.

Next, we sequentially check the pointers to objects in all our collections and call their data-saving methods.

```
//--- call the method for all collections of inner layers

   if(!m_cQuerys.Save(file_handle))

      return false;

   if(!m_cKeys.Save(file_handle))

      return false;

   if(!m_cValues.Save(file_handle))

      return false;

   if(!m_cScores.Save(file_handle))

      return false;

   if(!m_cAttentionOut.Save(file_handle))

      return false;

   if(!m_cW0.Save(file_handle))

      return false;

   if(!m_cFF1.Save(file_handle))

      return false;

   if(!m_cFF2.Save(file_handle))

      return false;

//---

   return true;

  }
```

Then we exit the data saving method.

We have created a method for saving an object of our class. Now we can move on to work on the method of recovering an object from the data written to the file. As a reminder, the primary requirement for methods restoring the functionality of objects from saved data is to read the data in strict accordance with the sequence of their recording.

Similar to the file-writing method, our data-loading method CNeuronGPT::Load receives in parameters the handle of the file containing the data to be read. Just like when writing data, we first call the analogous method of the parent class. First, we read the data in strict accordance with the writing sequence. Second, we use the idea voiced when studying the method of writing data, that is, we use the controls implemented in the method of the parent class and exclude their duplication. Of course, before proceeding further, we check the result of the parent method operations.

```
bool CNeuronGPT::Load(const int file_handle)

  {

//--- call the method of a parent class

   if(!CNeuronBase::Load(file_handle))

      return false;
```

After the successful execution of the parent class method, we read the constants of our block operating parameters. Their values are read in the order in which they are written. After reading the constant values, we should adjust the size of the dynamic array for writing standard deviations used in normalizing the results of our block operation. The size of the array must be sufficient to store data from all nested neural layers. Otherwise, we run the risk of encountering a critical error due to exceeding array dimensions during program execution.

```
//--- read constants from a file

   m_iLayers = FileReadInteger(file_handle);

   m_iWindow = FileReadInteger(file_handle);

   m_iKeysSize = FileReadInteger(file_handle);

   m_iHeads = FileReadInteger(file_handle);

   m_iUnits = FileReadInteger(file_handle);

   m_iCurrentPosition = FileReadInteger(file_handle);

   if(ArrayResize(m_dStd, m_iLayers) <= 0)

      return false;

   for(int i = 0; i < m_iLayers; i++)

      if(!m_dStd[i].BufferInit(1, 2, 1))

         return false;;
```

Then all we have to do is load the data from our object collections. However, before calling the method to load collection object data, we need to ensure the relevance of the collection object pointer and, if necessary, create a new instance of the collection object. Only then we can call the data loading method. Of course, do not forget that the order of loading objects is in strict accordance with the order of their writing. We also control the data loading process at each iteration.

```
//--- call the method for all collections of inner layers

   if(!m_cQuerys.Load(file_handle))

      return false;

   if(!m_cKeys.Load(file_handle))

      return false;

   if(!m_cValues.Load(file_handle))

      return false;

   if(!m_cScores.Load(file_handle))

      return false;

   if(!m_cAttentionOut.Load(file_handle))

      return false;

   if(!m_cW0.Load(file_handle))

      return false;

   if(!m_cFF1.Load(file_handle))

      return false;

   if(!m_cFF2.Load(file_handle))

      return false;
```

After loading all objects, we create another loop and reformat the result buffers of all created objects. In this case, we do not perform a validity check on the object pointers as in the previous iterations, all these objects loaded data from the file, which means they were created and verified.

```
//--- reformat the result matrices

   for(int i = 0; i < m_iLayers; i++)

     {

      CNeuronBase* temp = m_cKeys.At(i);

      if(!temp.GetOutputs().Reshape(m_iUnits, m_iKeysSize * m_iHeads))

         return false;

      temp = m_cValues.At(i);

      if(!temp.GetOutputs().Reshape(m_iUnits, m_iKeysSize * m_iHeads))

         return false;

      temp = m_cScores.At(i);

      if(!temp.GetOutputs().Reshape(m_iHeads, m_iUnits))

         return false;

      temp = m_cAttentionOut.At(i);

      if(!temp.GetOutputs().Reshape(m_iHeads, m_iKeysSize))

         return false;

     }
```

At the end of the method, we replace the buffers and terminate its work.

```
//--- replace data buffers to avoid excessive copying

   CNeuronBase *last = m_cFF2.At(m_cFF2.Total() - 1);

   if(!!m_cOutputs)

      delete m_cOutputs;

   m_cOutputs = last.GetOutputs();

   if(!!m_cGradients)

      delete m_cGradients;

   m_cGradients = last.GetGradients();

//---

   return true;

  }
```

Now that the file handling methods have been created, we can proceed further. Next, our plan involves creating the capability to perform parallel mathematical operations using OpenCL.

## 5.Creating a script to test Multi-Head Self-Attention

To test the operation of our new class of the Multi-Head Self-Attention neural layer, we will create a script with the implementation of the neural network model, in which we will use the new type of neural layer. We will create our script based on the [lstm.py](https://www.mql5.com/en/neurobook/index/main_layer_types/rnn/rnn_py) script, which we used earlier to test recurrent models. Before we start, let's create a copy of the specified script with the file name attention.py. In the new copy of the script, we will delete the previously created models, leaving only the convolution model and the best recurrent model. They will serve as a basis for comparing new models.

```
# A model with a 2-dimensional convolutional layer

model3 = keras.Sequential([keras.Input(shape=inputs),

                           # Reformat the tensor into a 4-dimensional one.

        # Specify 3 dimensions, as the 4th dimension is determined by the size of the packet

                           keras.layers.Reshape((-1,4,1)),

                           # A convolution layer with 8 filters

                           keras.layers.Conv2D(8,(3,1),1,activation=tf.nn.swish,

        kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),

                           # Subsample layer

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

```
# LSTM block model with no fully connected layers

model4 = keras.Sequential([keras.Input(shape=inputs),

        # Reformat the tensor into 3-dimensional.

        # Specify 2 dimensions, as the 3rd dimension is determined by the size of the batch

                           keras.layers.Reshape((-1,4)),

        # 2 consecutive LSTM blocks

        # 1 contains 40 elements

                           keras.layers.LSTM(40,

        kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5),

                           return_sequences=False),

        # 2nd gives the result instead of a fully connected layer

                           keras.layers.Reshape((-1,2)),

                           keras.layers.LSTM(targerts)

                         ])
```

To build the initial model, we created a fairly simple architecture consisting of one attention layer, three fully connected hidden layers, and one fully connected output layer. We used almost the same model architecture above to build the convolutional model. The use of similar models enables the accurate evaluation of the impact of new solutions on the overall performance of the model.

```
heads=8

key_dimension=4

model5 = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),

        # Reformat the tensor into 3-dimensional. Specify 2 dimensions,

        # as the 3rd dimension is determined by the size of the batch

        # first dimension is for sequence elements

        # second dimension is for the vector describing of one element

                           keras.layers.Reshape((-1,4)),

                           MHAttention(key_dimension,heads),
```

Since our attention layer returns a tensor of the same size as its input, we need to reshape the data into a two-dimensional space before using the block of fully connected layers.

```
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

It should be noted that despite the external similarity of the models, the model utilizing the attention mechanism layer uses five times fewer parameters.

However, using a single attention layer is a simplified model and is employed solely for comparative experimentation purposes. In practice, it's more common to use multiple consecutive attention layers. I suggest evaluating the impact of multiple attention layers used in the model on real-world data. To conduct such an experiment, we will sequentially add three more attention layers with the same parameters to our previous model.

Model using the Multi-Heads Self-Attention layer

```
model6 = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),

        # Reformat the tensor into 3-dimensional. Specify 2 dimensions,

        # as the 3rd dimension is determined by the size of the package

        # first dimension is for sequence elements

        # second dimension is for the vector describing one element

                           keras.layers.Reshape((-1,4)),

                           MHAttention(key_dimension,heads),

                           MHAttention(key_dimension,heads),

                           MHAttention(key_dimension,heads),

                           MHAttention(key_dimension,heads),

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

We will compile all neural models with the same parameters: the Adam optimization method, standard deviation as the network error, and an additional accuracy metric.

```
model3.compile(optimizer='Adam',

               loss='mean_squared_error',

               metrics=['accuracy'])
```

We compiled neural network models with the same parameters as before.

Recurrent models are sensitive to the sequence of input signals provided. Therefore, when training a recurrent neural network, unlike the other models, you cannot shuffle the input data. Exactly for this purpose, when launching a recurrent model, we set the shuffle parameter to False. The convolution model and models using the attention layer have this parameter set to True. The remaining training parameters for the models remain unchanged, including the early stopping criterion when reaching a minimum error on the training dataset.

```
callback = tf.keras.callbacks.EarlyStopping(monitor='loss', patience=20)

history3 = model3.fit(train_data, train_target,

                      epochs=500, batch_size=1000,

                      callbacks=[callback],

                      verbose=2,

                      validation_split=0.01,

                      shuffle=True)
```

After slightly training the models, we visualize the results. We plot two graphs. On one of them, we will display the dynamics of error changes during the training and validation process.

```
# Plot the results of model training

plt.figure()

plt.plot(history3.history['loss'], label='Conv2D train')

plt.plot(history3.history['val_loss'], label='Conv2D validation')

plt.plot(history4.history['loss'], label='LSTM only train')

plt.plot(history4.history['val_loss'], label='LSTM only validation')

plt.plot(history5.history['loss'], label='MH Attention train')

plt.plot(history5.history['val_loss'], label='MH Attention validation')

plt.plot(history6.history['loss'], label='MH Attention 4 layers train')

plt.plot(history6.history['val_loss'], label='MH Attention 4 layers validation')

plt.ylabel('$MSE$ $loss$')

plt.xlabel('$Epochs$')

plt.title('Model training dynamics')

plt.legend(loc='upper right', ncol=2)
```

In the second graph, we plot similar results for Accuracy.

```
plt.figure()

plt.plot(history3.history['accuracy'], label='Conv2D train')

plt.plot(history3.history['val_accuracy'], label='Conv2D validation')

plt.plot(history4.history['accuracy'], label='LSTM only train')

plt.plot(history4.history['val_accuracy'], label='LSTM only validation')

plt.plot(history5.history['accuracy'], label='MH Attention train')

plt.plot(history5.history['val_accuracy'], label='MH Attention validation')

plt.plot(history6.history['accuracy'], label='MH Attention 4 layers train')

plt.plot(history6.history['val_accuracy'], label='MH Attention 4 layers validation')

plt.ylabel('$Accuracy$')

plt.xlabel('$Epochs$')

plt.title('Model training dynamics')

plt.legend(loc='lower right', ncol=2)
```

Then we will load the test dataset and evaluate the performance of the pretrained models on it.

```
# Load testing dataset

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

```
# Split the test sample into input data and targets

test_data=test[:,0:inputs]

test_target=test[:,inputs:]
```

```
# Validation of model results on a test sample

test_loss3, test_acc3 = model3.evaluate(test_data, test_target, verbose=2)

test_loss4, test_acc4 = model4.evaluate(test_data, test_target, verbose=2)

test_loss5, test_acc5 = model5.evaluate(test_data, test_target, verbose=2)

test_loss6, test_acc6 = model6.evaluate(test_data, test_target, verbose=2)
```

The results of the model's performance on the test sample will be numerically logged and visualized on the graph.

```
# Output test results to the log

print('Conv2D model')

print('Test accuracy:', test_acc3)

print('Test loss:', test_loss3)
```

```
print('LSTM only model')

print('Test accuracy:', test_acc4)

print('Test loss:', test_loss4)
```

```
print('MH Attention model')

print('Test accuracy:', test_acc5)

print('Test loss:', test_loss5)
```

```
print('MH Attention 4l Model')

print('Test accuracy:', test_acc5)

print('Test loss:', test_loss5)
```

```
plt.figure()

plt.bar(['Conv2D','LSTM', 'MH Attention','MH Attention\n4 layers'],

        [test_loss3,test_loss4,test_loss5,test_loss6])

plt.ylabel('$MSE$ $loss$')

plt.title('Test results')
```

```
plt.figure()

plt.bar(['Conv2D','LSTM', 'MH Attention','MH Attention\n4 layers'],

        [test_acc3,test_acc4,test_acc5,test_acc6])

plt.ylabel('$Accuracy$')

plt.title('Test results')

plt.show()
```

We finalize our work on the Multi-Head Self-Attention mechanism. We have recreated this mechanism by means of MQL5 and in Python. In this section, we have prepared a Python script that creates a total of four neural network models:

- Convolution model

- Recurrent neural network

- Two models using Multi-Head Self-Attention technology

While running the script, we will conduct a brief training session for all four models using the same dataset. We will compare the performance of the trained models on the test dataset and analyze the results. This will allow us to compare the performance of various architectural solutions on real-world data. The test results will be provided in the next chapter.

## 5.Multi-Head Self-Attention backpropagation methods

We are confidently moving forward in our learning path. Let's proceed with the implementation of our Multi-Head Self-Attention class. In the previous sections, we have already implemented initialization methods and feed-forward methods. However, the neural layer training algorithm is based on the error gradient backpropagation algorithm. We now proceed to implement backpropagation methods.

We have already mentioned that the Multi-Head Self-Attention algorithm is a logical extension of Self-Attention. That's why we created our class based on the CNeuronAttention class. And yes, the processes are all very similar. However, there are still some minor differences in the implementation of multi-head attention. To implement these differences, we created a new class CNeuronMHAttention.

As we progress in creating the methods of the class, let's take a look at the implementation of these differences in the methods of the backpropagation algorithm.

In the parent class, we have overridden three virtual methods to implement the backpropagation algorithm:

- CNeuronAttention::CalcHiddenGradient — method for calculating the error gradient through the hidden layer

- CNeuronAttention::CalcDeltaWeights — method for calculating the error gradient to the level of the weights matrix

- CNeuronAttention::UpdateWeights  — method for updating the weights

So, we will also need to override the corresponding methods to organize the multi-head attention backpropagation pass. Let's start with the method of distributing the error gradient through the hidden layer of the CalcHiddenGradient neural network.

As in the parent class method, in the parameters of the method, we receive a pointer to the object of the previous neural layer. It is in its error gradient buffer that we are going to record the result of the work being done.

At the beginning of the CNeuronMHAttention::CalcHiddenGradient method body, there is the customary and essential attribute of any method: a check of pointers to the objects used in the method. Here, as in the similar method of the parent class, we will perform control checks only for pointers to objects that will be directly accessed from this method without using the methods of internal neural layers. The reason is that all inner neural layer methods have a similar block of controls. By calling them, we again validate the passed pointers to objects. This is an additional cost in resources and time. We can't disable the checks in the methods of the nested neural layers, so we will eliminate explicit duplication of controls in the current method.

We should immediately point out that we only exclude explicit duplication, but not possible. It's a fine line, but behind it lie great risks.

Explicit is the duplication that will happen anyway. If we see such duplication, we try to keep only one control point before the first use of the object whenever possible.

Note, that there must be at least one control point before the object is accessed for the first time.

I call duplication possible when it can occur under certain circumstances. In some cases, it may not happen. We do not eliminate such duplication because the risk of a critical error in the absence of control outweighs the potential benefits of improving program performance.

```
bool CNeuronMHAttention::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

//--- check the relevance of all objects

   if(!m_cOutputs || !m_cGradients ||

      m_cOutputs.Total() != m_cGradients.Total())

      return false;
```

After successfully passing the control block, we proceed directly to the error gradient distribution procedure. As you may recall, in the feed-forward pass, the data is normalized at the output of the neural layer. Also, we need to adjust the error gradient by the derivative of the normalization function. In the parent class, we derived this procedure in a separate method entitled CNeuronAttention::NormlizeBufferGradient. Now we just need to call it with the appropriate parameters.

```
//--- scale the gradient to normalization

   if(!NormlizeBufferGradient(m_cOutputs, m_cGradients, GetPointer(m_cStd), 1))

      return false;
```

Next, we run the error gradient through the inner neural layers of the Feed Forward block. These are the two convolutional layers: m_cFF2 and m_cFF1. To propagate the gradient through these neural layers, we sequentially call the analogous methods of the mentioned neural layers. Don't forget to check the results of the operations.

```
//--- propagate the error gradient through the Feed Forward block

   if(!m_cFF2.CalcHiddenGradient(GetPointer(m_cFF1)))

      return false;

   if(!m_cFF1.CalcHiddenGradient(GetPointer(m_cW0)))

      return false;
```

After passing the error gradient via the Feed Forward block, we recall that before normalizing the data at the output of the neural layer, we added up the tensors of the results of the Multi-Head Self-Attention and Feed Forward blocks. Hence, we must also propagate the error gradient along both directions. For this purpose, after obtaining the error gradient from the Feed Forward block in the buffer of the inner neural layer m_cW0, we add up the two tensors.

```
if(!m_cW0.GetGradients().SumArray(m_cGradients))

      return false;
```

Let's adjust it for the derivative of the data normalization process.

```
//--- adjust the gradient for normalization

   if(!NormlizeBufferGradient(m_cW0.GetOutputs(), m_cW0.GetGradients(),

                                                          GetPointer(m_cStd), 0))

      return false;
```

We continue utilizing internal neural layer methods. We will call the convolution layer gradient distribution method m_cW0 and check the result of the operations.

```
//--- distribution of the error gradient by attention heads

   if(!m_cW0.CalcHiddenGradient(GetPointer(m_cAttentionOut)))

      return false;
```

Next, we need to propagate the error gradient from the concatenated result of the Multi-Head Self-Attention block to the internal neural layers m_cQuerys, m_cKeys, and m_cValues. As you may recall, in the feed-forward pass, the path to m_cAttentionOut from the specified inner neural layers was completely recreated inside the method. Similarly, we will have to recreate the progression of the reverse signal.

Since we are creating a new thread of operations, according to our concept, it is necessary to organize two parallel threads of operations: using standard MQL5 tools and in the paradigm of multi-threaded operations using OpenCL.

```
//--- branching of the algorithm by computing device

   if(!m_cOpenCL)

     {

      MATRIX gradients[];

      MATRIX querys[], querys_grad = MATRIX::Zeros(m_iHeads, m_iUnits * m_iKeysSize);

      MATRIX keys[], keys_grad = MATRIX::Zeros(m_iHeads, m_iUnits * m_iKeysSize);

      MATRIX values[], values_grad = MATRIX::Zeros(m_iHeads, m_iUnits * m_iKeysSize);

      MATRIX attention_grad = m_cAttentionOut.GetGradients().m_mMatrix;
```

As always, in this section, we will consider the implementation using MQL5. We will proceed to the organization of multi-threaded operations later.

So, first, we're going to do some preparatory work. As in the forward pass, in this block, we organize the work separately for individual attention heads. As all the data is stored in concatenated buffers, we will prepare local matrices and split the buffers into individual matrices according to the attention heads.

```
if(!m_cQuerys.GetOutputs().m_mMatrix.Vsplit(m_iHeads, querys) ||

         !m_cKeys.GetOutputs().m_mMatrix.Vsplit(m_iHeads, keys) ||

         !m_cValues.GetOutputs().m_mMatrix.Vsplit(m_iHeads, values) ||

         !attention_grad.Reshape(m_iUnits, m_iHeads * m_iKeysSize) ||

         !attention_grad.Vsplit(m_iHeads, gradients))

         return false;
```

Next, we will create a loop with the number of iterations equal to the number of attention heads used.

```
for(int head = 0; head < m_iHeads; head++)

        {
```

During the feed-forward pass, the values of the concatenated buffer of results are assembled by multiplying the values of the m_cValues neural layer's tensor results with the corresponding elements of the dependency coefficient matrix, followed by vector addition. Now we need to organize the reverse process: propagating the error gradient along these two directions.

First, we transfer the error gradient to the inner neural layer m_cValues. Before that, let's do some preparatory work.

To propagate the gradient to the m_cValues neural layer, it is necessary to multiply the error gradient matrix by the dependency coefficient matrix. Hence, we first need to extract such a matrix for the attention head we analyze.

We then multiply the matrices and add the result to a local copy of the concatenated gradient matrix of the m_cValues layer.

```
//--- gradient propagation to Values

         MATRIX score = MATRIX::Zeros(1, m_iUnits * m_iUnits);

         if(!score.Row(m_cScores.m_mMatrix.Row(head), 0) ||

            !score.Reshape(m_iUnits, m_iUnits))

            return false;

         MATRIX temp = (score.Transpose().MatMul(gradients[head])).Transpose();

         if(!temp.Reshape(1, m_iUnits * m_iKeysSize) ||

            !values_grad.Row(temp.Row(0), head))

            return false;
```

After that, we will propagate the gradient along the second path of the algorithm, through the dependency coefficient matrix to the neural layers m_cQuerys and m_cKeys. In essence, we first need to determine the error gradient at the level of the dependency coefficient matrix and then propagate the error gradient from there to the specified internal neural layers.

Here we should recall that the dependency coefficient matrix is normalized by the Softmax function in the Query section. To properly adjust the error gradient for the derivative of the Softmax function, we need at least the full vector of error gradients for the values involved in a single normalization operation. We can write it into a local matrix.

The task is clear, and we can proceed to implementation. To propagate the error gradient to the dependency coefficient matrix, it is sufficient to multiply the obtained gradient by the matrix of the results from the last feed-forward pass of the m_cValues neural layer.

After obtaining the error gradient vector at the dependency coefficient matrix level, we should adjust it using the derivative of the Softmax function.

We will organize a loop in which we adjust the error gradient using the derivative of the Softmax normalization function.

```
//--- gradient distribution up to Score

         gradients[head] = gradients[head].MatMul(values[head].Transpose());

         //--- gradient correction by Softmax derivative

         for(int r = 0; r < m_iUnits; r++)

           {

            MATRIX ident = MATRIX::Identity(m_iUnits, m_iUnits);

            MATRIX ones = MATRIX::Ones(m_iUnits, 1);

            MATRIX result = MATRIX::Zeros(1, m_iUnits);

            if(!result.Row(score.Row(r), 0))

               return false;

            result = ones.MatMul(result);

            result = result.Transpose() * (ident - result);

            if(!gradients[head].Row(result.MatMul(gradients[head].Row(r)) /

                                                          sqrt(m_iKeysSize), r))

               return false;

           }
```

In the next step, we distribute the error gradient to the result values of the m_cQuerys and m_cKeys neural layers. However, we will not immediately write the values into the data buffers of the specified neural layers. We will only accumulate the sums of the error gradients into the pre-prepared matrices querys_grad and keys_grad.

Technically, we multiply the adjusted error gradient by the opposite matrix. Multiplying it by the Keys matrix, we get the error gradient for Querys, and vice versa. We reformat the obtained matrices and add them to the corresponding local matrices.

```
//--- gradient propagation to Querys and Keys

         temp = (gradients[head].MatMul(keys[head])).Transpose();

         if(! temp.Reshape(1, m_iUnits * m_iKeysSize) ||

            !querys_grad.Row(temp.Row(0), head))

            return false;

         temp = (gradients[head].Transpose().MatMul(querys[head])).Transpose();

         if(! temp.Reshape(1, m_iUnits * m_iKeysSize) ||

            !keys_grad.Row(temp.Row(0), head))

            return false;

        }
```

After completing the iterations of the loop, we obtain concatenated matrices of error gradients for all internal layers. Finally, we need to format the matrices as required and copy the values into the respective data buffers.

```
if(!querys_grad.Reshape(m_iHeads * m_iKeysSize, m_iUnits) ||

         !keys_grad.Reshape(m_iHeads * m_iKeysSize, m_iUnits) ||

         !values_grad.Reshape(m_iHeads * m_iKeysSize, m_iUnits))

         return false;

      m_cQuerys.GetGradients().m_mMatrix = querys_grad.Transpose();

      m_cKeys.GetGradients().m_mMatrix = keys_grad.Transpose();

      m_cValues.GetGradients().m_mMatrix = values_grad.Transpose();

     }

   else // OpenCL block

     {

      return false;

     }
```

As a result, we have propagated the error gradient to the level of internal neural layers. We have successfully addressed the previously set task and are concluding the section on algorithm partitioning based on the computational device. In the multi-threaded operations branch, we will temporarily set the method exit with a false result. We will complete this part later.

We haven't propagated the error gradient to the previous layer yet. We will further propagate the error gradient using internal neural layer methods.

We've already filled the error gradient buffers of all the inner layers. We only need to call the method for error gradient propagation through the layer to obtain the error gradient at the level of the original data. However, one question remains open: all three internal neural layers (m_cQuerys, m_cKeys, m_cValues) use the same tensor from the previous layer as their input data. This means that all three layers must pass the error gradient to the previous layer's buffer. In addition, the result of the Multi-Head Self-Attention block was added to the tensor of the original data before normalization. Hence, this is the fourth thread of the error gradient that we need to pass to the previous layer level.

However, our gradient propagation methods are constructed in a way that when the error gradient is saved in the buffer of the previous layer, it overwrites the previous values, erasing the prior information. This is done intentionally to avoid unnecessary buffer-clearing operations before starting each iteration of the backpropagation pass. To address this issue, after running the CalcHiddenGradient method for each internal neural layer, we will copy the error gradient data to a separate buffer, where we will accumulate it with the previously stored values At this point we should recall that the error gradient at the output of the Multi-Head Self-Attention block is already contained in the error gradient buffer of the neural layer m_cW0. It might seem that this buffer would be suitable for accumulating the error gradient for the previous layer. But that's a misconception. If we were to accumulate the error gradient in the mentioned buffer right now, it would distort the data during the subsequent error gradient propagation to the weight matrix of that layer. At the same time, we can implement the error gradient propagation to the matrix of the m_cW0 layer right now. There's all the data you need to do that. We call the CalcDeltaWeights method of the specified neural layer and then use its buffer to accumulate the total error gradient.

```
//--- propagate the error gradient to the previous layer

   if(!m_cW0.CalcDeltaWeights(GetPointer(m_cAttentionOut), false))

      return false;

   CBufferType* attention_grad = m_cW0.GetGradients();

   if(!m_cValues.CalcHiddenGradient(prevLayer))

      return false;

   if(!attention_grad.SumArray(prevLayer.GetGradients()))

      return false;

   if(!m_cQuerys.CalcHiddenGradient(prevLayer))

      return false;

   if(!attention_grad.SumArray(prevLayer.GetGradients()))

      return false;

   if(!m_cKeys.CalcHiddenGradient(prevLayer))

      return false;

   if(!prevLayer.GetGradients().SumArray(attention_grad))

      return false;

//---

   return true;

  }
```

Attention should be paid to the last group of commands. During the previous operations, we copied data from the gradient buffer of the previous layer, but at the end of the method, we reversed the process by taking the cumulative error gradient from the internal neural layer's buffer and adding it to the values of the buffer of the previous layer. It is in the buffer of the previous layer where we need to obtain the result. From it, the methods of the previous layer will take the error gradient and distribute it further through the neural network.

This completes the task set for this method. We complete the method with a positive result.

Next, we will work on two more methods that will continue the execution of the error backpropagation algorithm in this class.

After propagating the error through all the neural layers of our network, we need to propagate the error gradient to the level of each weight. Our CNeuronMHAttention class does not contain a separate buffer for the weight matrix. All trained parameters are encapsulated in internal neural layers. Therefore, the only thing we need to do in the method for propagating the error gradient to the CalcDeltaWeights weight matrix is to consistently call the same method for all inner layers. At the same time, we should check the results of the operations.

Recall that in the previous method, we have already passed the error gradient to the weight matrix of the m_cW0 inner layer. It is necessary to exclude it from this iteration.

```
bool CNeuronMHAttention::CalcDeltaWeights(CNeuronBase *prevLayer, bool read)

  {

//--- call the same method for all inner layers

   if(!m_cFF2.CalcDeltaWeights(GetPointer(m_cFF1), false))

      return false;

   if(!m_cFF1.CalcDeltaWeights(GetPointer(m_cW0), false))

      return false;

   if(!m_cQuerys.CalcDeltaWeights(prevLayer, false))

      return false;

   if(!m_cKeys.CalcDeltaWeights(prevLayer, false))

      return false;

   if(!m_cValues.CalcDeltaWeights(prevLayer, read))

      return false;

//---

   return true;

  }
```

After propagating the error gradients to the weight matrices, the only remaining step is to update the weights of our internal neural layers. This functionality is assigned to the UpdateWeights method. Despite the complexity of the class itself, the method for updating the weight matrices turns out to be very concise and straightforward. It was object inheritance that helped us with this.

We created our CNeuronMHAttention class as a descendant of the CNeuronAttention class. We added only one object of the inner m_cW0 neural layer. During the operations of the UpdateWeights method of the convolutional neural layers used, all operations are performed only on elements within the object, without accessing data from other objects. That's why we can call a similar method from the parent class, where this process is already implemented for inherited objects. After successfully executing the method of the parent class, we only need to update the coefficient matrix of the m_cW0 internal neural layer.

```
bool CNeuronMHAttention::UpdateWeights(int batch_size, TYPE learningRate,

                                            VECTOR &Beta, VECTOR &Lambda)

  {

//--- call the method of the parent class

   if(!CNeuronAttention::UpdateWeights(batch_size, learningRate, Beta, Lambda))

      return false;

//--- call the same method for all inner layers

   if(!m_cW0.UpdateWeights(batch_size, learningRate, Beta, Lambda))

      return false;

//---

   return true;

  }
```

Of course, we verify the result of all operations and return a boolean value indicating their execution to the caller.

Thus, we are nearing the completion of the Multi-Head Self-Attention technology implementation class. We have already implemented the whole algorithm using standard MQL5 tools. You can even create a script and test how it works. However, we still need to supplement our class with file handling methods.

## 5.Multi-Head Self-Attention feed-forward method

We have already organized the process of creating and initializing the CNeuronMHAttention Multi-Head attention class. And now, when we already have all the internal objects of our class, we can move on to the organization of the forward pass.

The virtual method FeedForward is responsible for the implementation of the feed-forward pass in all classes of our library. Adhering to the general system of organization of classes and their methods, as well as the principles of inheritance, in this class we will retain the previously defined structure of methods and override the FeedForward method. Like the similar method of the parent class, in the parameters, the fed-forward method receives a pointer to the object of the previous neural layer. According to the framework that has been tested more than once, at the beginning of the method we organize a block of controls. In it, we check the relevance of pointers to all dynamic objects used in the method. In this case, we check the pointer to the neural layer received in the parameters, its result buffer, and the buffer of results from the internal layer of the concatenated output of the attention block.

```
bool CNeuronMHAttention::FeedForward(CNeuronBase *prevLayer)

  {

--- check the relevance of all objects

   if(!prevLayer || !prevLayer.GetOutputs() ||

      !m_cAttentionOut.GetOutputs())

      return false;
```

After successfully passing the control block, we generate concatenated tensors of queries, keys, and values: Query, Key, and Value. To do this, we call the methods of forward pass of the internal convolutional layers m_cQuerys, m_cKeys, and m_cValues. The correspondence of tensors in the Multi-Head Self-Attention architecture and the invoke objects is not accidental: it makes the code more readable and allows you to track the algorithm being built.

```
if(!m_cQuerys.FeedForward(prevLayer))

      return false;

   if(!m_cKeys.FeedForward(prevLayer))

      return false;

   if(!m_cValues.FeedForward(prevLayer))

      return false;
```

Be sure to control the process of performing operations.

Next, according to the Multi-Head Self-Attention algorithm, we have to determine the coefficients of dependence between the elements of the sequence and display the concatenated result of the work of all attention heads. This functionality is the link between the internal neural layers. It does not cover the use of other objects and will be built entirely within this method.

As you remember, when building all processes in the methods of our library classes, we create two branches of the algorithm: standard MQL5 tools and multi-threaded calculations on the GPU using OpenCL. As always, in this section, we will consider the implementation of the algorithm using standard MQL5 tools. And we will return to the implementation of multi-threaded computing using OpenCL later.

Now we need to determine how to organize the work. We have three dimensions:

- Attention heads

- Sequence elements

- Vector with the description of one element of the sequence

Matrix operations allow us to operate only with two-dimensional matrices. One of the dimensions used will be a vector describing one element of the sequence. It's not hard to guess that in most cases, the size of the sequence will be tens of times larger than the number of attention heads. Therefore, we will create a loop for iterating through the attention heads, and within the loop, we will analyze the sequences of each attention head.

Before organizing the loop, we need to do a little preparatory work. Let's divide the concatenated results of the previous stage of the implemented algorithm into several attention heads matrices. For this, we will use dynamic arrays of matrices, which will give us a semblance of three-dimensional matrices. The index of an element in the array will indicate the attention head index. Each element in the array will be represented as a tabular matrix, where rows represent individual elements of the sequence. For the convenience of working with arrays, let's give them names that correspond to their content.

```
--- branching of the algorithm by the computing device

   MATRIX out;

   if(!m_cOpenCL)

     {

      if(!out.Init(m_iHeads, m_iUnits * m_iKeysSize))

         return false;

      MATRIX querys[], keys[], values[];

      if(!m_cQuerys.GetOutputs().m_mMatrix.Vsplit(m_iHeads, querys))

         return false;

      if(!m_cKeys.GetOutputs().m_mMatrix.Vsplit(m_iHeads, keys))

         return false;

      if(!m_cValues.GetOutputs().m_mMatrix.Vsplit(m_iHeads, values))

         return false;
```

After completing the preparatory work, we can proceed directly to the operations of calculating dependency coefficients. When solving such a problem, we used matrix operations in the forward pass method of the parent class CNeuronAttention. Now we will use the same algorithm, but we need to repeat it in a loop with the number of iterations equal to the number of attention heads.

According to the Multi-Head Self-Attention algorithm, the dependence coefficients are divided by the square root of the dimension of the Key vector, and the obtained values are then normalized with the Softmax function in the context of elements of Query queries.

Following the algorithm, we multiply the querys and transposed keys matrices, divide them by the square root of their dimension, and immediately calculate the exponential value. In the resulting matrix, we take line-by-line sums of values and organize a nested loop for data normalization.

```
for(int head = 0; head < m_iHeads; head++)

        {

         //--- define Scores

         MATRIX sc = exp(querys[head].MatMul(keys[head].Transpose()) /

                                                                sqrt(m_iKeysSize));

         VECTOR sum = sc.Sum(1);

         for(uint r = 0; r < sc.Rows(); r++)

            if(!sc.Row(sc.Row(r) / sum[r], r))

               return false;
```

As you can see, the algorithm completely repeats similar operations of the parent class.

Now that we already have a calculated matrix of coefficients of dependencies between elements, we can move on using the Multi-Head Self-Attention algorithm and determine the values of the concatenated tensor of the results in terms of the analyzed attention head. To do this, we just need to calculate the products of two matrices containing the coefficients of dependence and the values of Values.

```
//--- output of the attention block

         MATRIX temp = sc.MatMul(values[head]).Transpose();
```

Special attention should be paid to gathering results into a single concatenated tensor. The entire logic of constructing the algorithm assumes that the tensor of the concatenated result will be a tabular matrix. Each row of the matrix will contain a vector of the concatenated result of a single element of the sequence. I solved this problem as follows.

As a result of the multiplication operation, we obtained a tabular matrix where the number of rows equals the number of elements in the sequence, and the number of columns equals the size of the vector describing one element of the sequence. We transpose the matrix, reshape it into a row matrix, and add this resulting row to the concatenated matrix. At this stage, in the concatenated matrix, each attention head will have its own row.

We do the same with the matrix of dependency coefficients.

```
if(!temp.Reshape(1, m_iUnits * m_iKeysSize))

            return false;

         if(!sc.Reshape(1, m_iUnits * m_iUnits))

            return false;

         if(!m_cScores.m_mMatrix.Row(sc.Row(0), head))

            return false;

         if(!out.Row(temp.Row(0), head))

            return false;

        }
```

Once the iterations of the loop are completed and the results of all the attention heads are obtained, we will reformat the concatenated matrix. We will make the number of columns equal to the number of elements of the sequence and transpose the matrix. As a result, we will have a number of rows equal to the number of elements in the analyzed sequence. This is the format we need to pass to the next convolutional layer of our multi-head attention block. We will save the matrix to the results buffer of the inner layer m_cAttentionOut.

```
if(!out.Reshape(m_iHeads * m_iKeysSize, m_iUnits))

         return false;

      m_cAttentionOut.GetOutputs().m_mMatrix = out.Transpose();

     }

   else // OpenCL block

     {

      return false;

     }
```

This concludes the section on splitting the algorithm depending on the device for executing operations. Let's go back to using the methods of our internal neural layers. For a block of multi-threaded operations using OpenCL, we will set a temporary stub in the form of a return of a false value for the execution of method operations. We will return to it in the following sections.

We continue to move according to the Multi-Head Self-Attention algorithm. At the next stage, we will need to reduce the dimensionality of the concatenated tensor of results from all attention heads to the size of the original data tensor. For these purposes, the algorithm provides for the use of a trained matrix W0. This matrix has a dual purpose. First, it serves to change the dimension of the tensor. Second, it performs a weighted summation of all attention heads into a unified entity, thus determining the influence of each attention head on the final result.

To accomplish this task, we will use the object of the convolutional layer. We have already created a convolutional neural layer m_cW0, and now we have to call its forward pass method. In the parameters, we pass to the method a pointer to the object of the m_cAttentionOut neural layer. Do not forget to check the result of the operation.

```
if(!m_cW0.FeedForward(GetPointer(m_cAttentionOut)))

      return false;
```

After the successful completion of the method operations, the result buffer of our neural layer will be the result of the Multi-Head Self-Attention block. According to the Transformer algorithm, we will need to add the obtained result to the original data into a single tensor and normalize the result using the following formulas:

When working on the parent class CNeuronAttention we created separate methods for these operations. Now let's make use of the results of the work done earlier.

```
//--- add to the initial data and normalize

   if(!m_cW0.GetOutputs().SumArray(prevLayer.GetOutputs()))

      return false;

   if(!NormlizeBuffer(m_cW0.GetOutputs(), GetPointer(m_cStd), 0))

      return false;
```

And, of course, don't forget to monitor the process of executing operations at every step.

Monitoring the process of executing operations is very important and should become a good habit, especially when dealing with such a large number of operations.

This concludes the Multi-Head Self-Attention block in the transformer encoder algorithm. Next comes its second block — Feed Forward. Within this block, we need to propagate the signal through two neural layers. We will do so by sequentially calling the feed-forward methods of each neural layer.

```
//--- FeedForward

   if(!m_cFF1.FeedForward(GetPointer(m_cW0)))

      return false;

   if(!m_cFF2.FeedForward(GetPointer(m_cFF1)))

      return false;
```

At the end of the forward pass algorithm, we will need to repeat the data normalization procedure. This time we add the result buffers of the Multi-Head Self-Attention and Feed Forward blocks.

```
//--- add to the output of attention and normalize

   if(!m_cOutputs.SumArray(m_cW0.GetOutputs()))

      return false;

   if(!NormlizeBuffer(m_cOutputs, GetPointer(m_cStd), 1))

      return false;

//---

   return true;

  }
```

The normalization procedure completes the feed-forward method. After the specified process completes successfully, we exit the method with a result of true. Let's move on to the implementation of the backpropagation method.

## 5.File operations

We already had good progress with our work on the implementation of the Multi-Head Self-Attention algorithm. In the previous sections, we implemented the feed-forward and backpropagation operations of our CNeuronMHAttention class using standard MQL5 tools. Now, in order to fully utilize it in our models, we need to complement it with file methods. The proper functioning of these methods is just as important for industrial use as the correct functioning of the feed-forward and backpropagation methods.

True, we can create a model and test its performance without saving the training results. However, to conduct a repeated test, we will have to retrain our model from scratch. In real-life operations, we wouldn't want to repeat the training process each time. On the contrary, quite often significant efforts are invested in developing and training a model on large datasets, which enables the creation of a truly functional model. At the same time, it is expected that during practical application, it will be sufficient to start the model, and it will be fully ready to operate on real data. Therefore, when approaching the development of file handling methods, we must design their functionality in such a way that we can fully restore the model's state with minimal effort. Well, we have done this work several times already, so let's use the established algorithm once again.

First, let's look at the structure of our multi-head attention class CNeuronMHAttention.

```
class CNeuronMHAttention    :  public CNeuronAttention

  {

protected:

   CNeuronConv       m_cW0;

   int               m_iHeads;

public:

                     CNeuronMHAttention(void);

                    ~CNeuronMHAttention(void);

   //---

   virtual bool      Init(const CLayerDescription *desc) override;

   virtual bool      SetOpenCL(CMyOpenCL *opencl) override;

   virtual bool      FeedForward(CNeuronBase *prevLayer) override;

   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;

   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer, bool read) override;

   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,

                                   VECTOR &Beta, VECTOR &Lambda) override;

   //--- methods of working with files

   virtual bool      Save(const int file_handle) override;

   virtual bool      Load(const int file_handle) override;

   //--- object identification method

   virtual int       Type(void) override const { return(defNeuronMHAttention);  }

  };
```

Seemingly, there's nothing complicated here. In the class body, we declare only one convolution layer m_cW0 and one variable m_iHeads indicating the number of attention heads used. Most of the objects are inherited from the parent class CNeuronAttention. We already created a similar method when working on the parent class, and now we can use it. I suggest looking again at the CNeuronAttention::Save parent class method and making sure it has a save of all the data we need. After that, we can start working on the method for saving the current class data. This time, everything here is indeed very simple.

In the parameters, the CNeuronMHAttention::Save method gets the handle of the file to which it will write the data. In the body of the method, we immediately pass the obtained handle to a similar method of the parent class, where all the control logic is already implemented. In addition to controls, the parent class method also implements the saving of inherited objects and their data. Therefore, by checking the result of the parent class method, we immediately get a consolidated result of passing through the control block and saving inherited objects. We only need to save the number of attention heads used and the m_cW0 convolutional layer data.

```
bool CNeuronMHAttention::Save(const int file_handle)

  {

//--- call the method of the parent class

   if(!CNeuronAttention::Save(file_handle))

      return false;

//--- save constants

   if(FileWriteInteger(file_handle, m_iHeads) <= 0)

      return false;

//--- call the same method for all inner layers

   if(!m_cW0.Save(file_handle))

      return false;

//---

   return true;

  }
```

The CNeuronMHAttention::Load method loads data from a file in accordance with the sequence of their recording. Therefore, in the body of the method, we immediately pass the received file handle as a parameter to the corresponding method of the parent class and check the result.

```
bool CNeuronMHAttention::Load(const int file_handle)

  {

//--- call the method of the parent class

   if(!CNeuronAttention::Load(file_handle))

      return false;
```

After executing the operations of the parent class method, we read the number of attention heads used and the data of the m_cW0 internal convolution layer from the file. Loading a constant is very simple: we just read the value from the file and save it to our m_iHeads variable. But before calling the load method, we must check the type of the object to be loaded. Only if the object types match, we call the data loading method and check the result.

```
m_iHeads = FileReadInteger(file_handle);

   if(CheckPointer(m_cW0) == POINTER_INVALID)

     {

      m_cW0 = new CNeuronConv();

      if(CheckPointer(m_cW0) == POINTER_INVALID)

         return false;

     }

   if(FileReadInteger(file_handle)!=defNeuronConv ||

      !m_cW0.Load(file_handle))

      return false;
```

It is expected that after the successful execution of the parent class operations, we will have fully restored inherited objects. However, we inherited the objects but initialized them in the corresponding method of this class with parameters different from the parent class. In this class, we adjusted almost all objects for the number of attention heads used. In the data loading method of the parent class, we not only load data from the file but also initialize unsaved objects. These are objects whose data are only used within a single iteration of feed-forward and backpropagation passes.

So, let's return to the parent class method and critically evaluate all the operations once again. Pay attention to the following lines of code.

```
bool CNeuronAttention::Load(const int file_handle)

  {

  ......

   m_iUnits = FileReadInteger(file_handle);

  ......

   if(!m_cScores.BufferInit(m_iUnits, m_iUnits, 0))

      return false;

  ......

//---

   return true;

  }
```

They initialize the m_cScores dependency coefficient matrix buffer. As you can see, the initialization is done with zero values with the size sufficient for only one attention head. However, this does not satisfy the requirements of our Multi-Head Self-Attention algorithm. It would make sense to add a reinitialization of the buffer in our class loading method, giving it the necessary size.

```
//--- initialize Scores

   if(!m_cScores.BufferInit(m_iHeads, m_iUnits * m_iUnits))

      return false;

//---

   return true;

  }
```

After completing all the operations, we exit the method with a positive result.

This completes the implementation of the CNeuronMHAttention class using standard MQL5 tools. We have implemented the Multi-Head Self-Attention algorithm. In the next section, we will add the ability to perform multi-threaded operations using OpenCL.

## 5.Creating a new neural layer class

Let's get to the practical part and look at the implementation of our multi-head attention neural layer. To implement it, we create a new MHAttention class that inherits from the base class of all neural layers tf.keras.layers.Layer.

```
# Multi-Head Self-Attention Model

class MHAttention(tf.keras.layers.Layer):
```

First, we'll override the layer initialization method __init__. In the parameters of the initialization method, we will specify two constants:

- key_size — size of the vector describing one element of the sequence in the tensor of Keys

- heads — number of attention heads

In the body of the method, we will save the parameters in local variables for future use and immediately calculate the size of the concatenated output of attention heads into the variable m_iDimension.

For your convenience, I made an effort to repeat the names of variables from the MQL5 implementation as much as possible.

Next, we declare the internal objects of our neural layer. However, note that in this case, we do not specify the vector size of one element of the source data sequence. This is made possible by the use of multidimensional tensors.

The TensorFlow library works with multidimensional arrays or tensors represented as objects. This approach makes understanding the model more convenient and visual. To be able to implement the task in OpenCL, we were forced to use one-dimensional data buffers. To gain access to the required element, we calculated the offset in the one-dimensional buffer. Now, when using multidimensional arrays, to access the matrix element, we just need to specify the row and column of the element. It is convenient and clear.

Another advantage of this approach is that we do not need to specify the dimension of the source data. We can get it from the tensor itself. We will take advantage of this. We won't ask the user for the size of the description vector for one element of the input data sequence. Instead, we will receive the input data tensor as a matrix. Each line of such a matrix is a vector description of one element of the sequence. We can operate with the size of this vector. That is, the first dimension indicates the number of elements of the sequence, and the second means the length of the description vector of one element of the sequence.

However, there is also the other side of the coin. At the time of class initialization, we have not yet received the initial data. So, we do not know its size, as the user did not specify them in the parameters. Therefore, we cannot create all objects in the initialization method. But it doesn't matter. We will do what we can.

In the initialization method, we will declare objects that can be created without understanding the dimension of the source data:

- m_cQuerys — neural layer for the formation of the concatenated tensor of queries Query

- m_cKeys — neural layer for the formation of the concatenated tensor of keys Key

- m_cValues — neural layer for the formation of the concatenated tensor of values Values

- m_cNormAttention — data normalization layer for the Multi-Head Self-Attention block

- m_cNormOutput — normalization layer for the results of the neural layer

```
def __init__(self,key_size, heads, **kwargs):

    super(MHAttention, self).__init__(**kwargs)

    self.m_iHeads = heads

    self.m_iKeysSize = key_size

    self.m_iDimension=self.m_iHeads*self.m_iKeysSize;

    self.m_cQuerys = tf.keras.layers.Dense(self.m_iDimension)

    self.m_cKeys = tf.keras.layers.Dense(self.m_iDimension)

    self.m_cValues = tf.keras.layers.Dense(self.m_iDimension)

    self.m_cNormAttention=tf.keras.layers.LayerNormalization(epsilon=1e-6)

    self.m_cNormOutput=tf.keras.layers.LayerNormalization(epsilon=1e-6)
```

After creating the initialization method, we proceed to the build method. This method will allow us to initialize the missing objects. This method is run only once before the first call of the call method. It receives the source data size in the parameters. Knowing this size, we can initialize objects, structures, and/or parameters that depend on the size of the source data.

In the method body, we save the last dimension of the source data tensor as the size of the description vector of one element of the source data sequence to the m_iWindow local variable. After that, we will create three more internal neural layers:

- m_cW0 — fully connected layer of the reduction matrix W0

- m_cFF1 — the first fully connected layer of the Feed Forward block

- m_cFF2 — the second fully connected layer of the Feed Forward block

```
def build(self, input_shape):

    self.m_iWindow=input_shape[-1]

    self.m_cW0 = tf.keras.layers.Dense(self.m_iWindow)

    self.m_cFF1=tf.keras.layers.Dense(4*self.m_iWindow,

                                      activation=tf.nn.swish)

    self.m_cFF2=tf.keras.layers.Dense(self.m_iWindow)
```

So, we have defined all the internal objects necessary to implement the Multi-Head Self-Attention algorithm inside our new layer. Before proceeding with the implementation, let's once again look at how we can write the algorithm of multi-head attention using matrix mathematics since when working with multidimensional tensors, we must operate with matrix operations.

The first step is to define the Query, Key, and Value tensors. To obtain query data, we need to multiply the tensor of the source data by the corresponding matrix of weights. This operation is performed in three internal neural layers.

```
def call(self, data):

    batch_size = tf.shape(data)[0]

    query = self.m_cQuerys(data)

    key = self.m_cKeys(data)

    value = self.m_cValues(data)
```

The second step is to determine the matrix of dependency coefficients. According to the Self-Attention algorithm, we first need to multiply the query tensor by the transposed key tensor.

Everything is simple for just one attention head. But we have concatenated tensors, which in the last dimension contain the data of all attention heads. Multiplying them in this form will give us a result comparable to one-headed attention. As an option, we can transform the two-dimensional tensor into a three-dimensional one, separating the attention head into a distinct dimension.

Multiplying the last two dimensions in this form is also not quite what we would like to get. However, if we swap the first and second dimensions, then we can multiply the last two dimensions to get the result we are looking for.

The described procedure will be placed in a separate function split_heads.

```
def split_heads(self, x, batch_size):

    x = tf.reshape(x, (batch_size, -1,

                                self.m_iHeads,

                                self.m_iKeysSize))

    return tf.transpose(x, perm=[0, 2, 1, 3])
```

Inside the call method, we transform tensors and multiply them according to the Self-Attention algorithm.

```
query = self.split_heads(query, batch_size)

    key = self.split_heads(key, batch_size)

    value = self.split_heads(value, batch_size)

    score = tf.matmul(query, key, transpose_b=True)
```

Next, we need to divide the obtained dependence coefficients by the square root of the dimension of the key vector and normalize it with the Softmax function according to the last dimension of the tensor.

```
score = score / tf.math.sqrt(tf.cast(self.m_iKeysSize, tf.float32))

    score = tf.nn.softmax(score, axis=-1)
```

Now we only need to multiply the normalized dependency coefficients by the Value tensor.

```
attention = tf.matmul(score, value)
```

As a result of this operation, we will get the attention block result for each attention head. To continue the algorithm, we need a concatenated tensor of all attention heads. Therefore, we need to carry out the reverse procedure of the tensor transformation. Once again, we rearrange the first and second dimensions and change the dimension of the tensor from three-dimensional to two-dimensional.

```
attention = tf.transpose(attention, perm=[0, 2, 1, 3])

    attention = tf.reshape(attention,(batch_size, -1, self.m_iDimension))
```

After that, using the W0 matrix, we convert the concatenated tensor of the results to the size of the tensor of the initial data. Add the two tensors and normalize the result.

```
attention = self.m_cW0(attention)

    attention=self.m_cNormAttention(data + attention)
```

This concludes the first block of the Multi-Head Self-Attention algorithm, followed by two consecutive fully connected layers of the Feed Forward block. The first neural layer will be with the Swish activation function, and the second one will have no activation function.

```
output=self.m_cFF1(attention)

    output=self.m_cFF2(output)
```

At the end of the method, we add the result tensors of the Multi-Head Self-Attention and Feed Forward blocks and normalize the layer. The result of the operations is returned in the form of a tensor.

```
output=self.m_cNormOutput(attention+output)

    return output
```

We have implemented a minimal set of methods of the class, sufficient to test its functionality. However, we will not be able to save the model with this class in this form. This is not good because our goal is to build and train a model with the subsequent possibility of practical use. Therefore, the ability to save the model and then restore it is one of the key requirements.

First, to enable the saving of the new object, which is our neural layer, it is necessary to add it to the list of custom objects and provide serialization capabilities for the object. This allows us to make a directive register_keras_serializable, which we will add before declaring the class of our neural layer.

```
# Multi-Head Self-Attention model

@tf.keras.utils.register_keras_serializable(package="Custom", name='MHAttention')

class MHAttention(tf.keras.layers.Layer):
```

But that's not all. We still need to add the get_config method, which will return the contents of variables to save to a file. Note that among the variables there are both those specified by the user when initializing the class object and those saved from the size of the initial data. Our weights are tuned to these dimensions.

```
def get_config(self):

    config={'key_size': self.m_iKeysSize,

            'heads': self.m_iHeads,

            'dimension': self.m_iDimension,

            'window': self.m_iWindow

            }

    base_config = super(MHAttention, self).get_config()

    return dict(list(base_config.items()) + list(config.items()))
```

The from_config method is responsible for restoring data from the configuration list. However, please note the following. In the usual logic, the parameters from the class initialization method are specified in the configuration dictionary. But we also saved data that depends on the size of the initial data. And, as you remember, they are not included in the parameters of the initialization method. In its pure form, we will get an error about the presence of unknown parameters. Therefore, at the beginning of the method, we remove them from the configuration directory, but at the same time save the values to local variables. And only after that, we restore the layer.

```
@classmethod

  def from_config(cls, config):

    dimension=config.pop('dimension')

    window=config.pop('window')

    layer = cls(**config)

    layer._build_from_signature(dimension, window)

    return layer
```

After initializing our neural layer from the configuration dictionary, we need to pass the values we previously extracted about the configuration of the input data into the respective variables. To perform this functionality, we will call the _build_from_signature method, which we will also have to override.

```
def _build_from_signature(self, dimension, window):

    self.m_iDimension=dimension

    self.m_iWindow=window
```

With that, we conclude our work on the class of our neural layer and can move on to creating a model to test the newly created Multi-Head Self-Attention neural layer.

## 5.Self-Attention backpropagation methods

In the previous section, we discussed the feed-forward method in the Encoder block of the Transformer architectural solution. This block includes a Self-Attention mechanism, followed by processing by two fully connected neural layers. The peculiarity of the Self-Attention mechanism lies in determining the dependencies between elements of the sequence. Moreover, each element of the sequence is represented as a vector of properties of a fixed length. Each sequence element within one neural layer is processed by an Encoder block with one set of weighting factors. This allowed us to use previously developed convolutional layers to solve a number of problems. The organization of a forward pass is a very important part of the algorithm for the operation of neural networks. We use it both when training our neural network models, and during practical application. But neural network training is impossible without going back. So now we'll look at organizing the backward pass in our attention mechanism class.

Just to remind you, we have created our own class as a successor to the neural layer base class. Several methods are responsible for organizing the backward pass:

- CNeuronBase::CalcOutputGradient: method for calculating the error gradient of the result layer.

- CNeuronBase::CalcHiddenGradient: method for calculating the error gradient through a hidden layer.

- CNeuronBase::CalcDeltaWeights: method for calculating the error gradient to the level of the weight matrix.

- CNeuronBase::UpdateWeights: method for updating weights.

All methods were made virtual to allow overriding in descendant classes. In our class, we're not going to override only the first method.

We will work on the methods in accordance with the logic of the backward propagation of error gradient method. We will be the first to redefine the error gradient calculation method via the hidden CNeuronAttention::CalcHiddenGradient layer. Of the three redefined methods, this one is probably the most difficult to understand and organize. After all, it is in this method that we will need to repeat the entire path of the feed-forward pass, but in reverse order. At the same time, we will have to find derivatives of all operations used in the feed-forward pass.

In the method parameters, we get a pointer to an object in the previous layer, in whose buffer we will save the result of operations. Next, in the body of the method, we organize a block of checks on the relevance of pointers to objects. Here, I decided not to dwell on checking all objects but only checked those objects that are not verified when calling methods of internal classes. This decision was made in an attempt to avoid redundant validity checks of objects during the execution of method operations.

```
bool CNeuronAttention::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

//--- checking the relevance of all objects

   if(!m_cOutputs || !m_cGradients ||

      m_cOutputs.Total() != m_cGradients.Total())

      return false;
```

This is followed by the most interesting part in which the error gradient is propagated in the reverse order of the feed-forward algorithm. Let's look at the forward pass algorithm. It ends with the normalization of results, which is carried out using formulas.

What is the normalization process? This is the process of changing the statistical variables in a sampling and bringing it closer to some specified parameters. Most often this is the mean and standard deviation, as in our case. We equate the mean value to zero and reduce the standard deviation to one. As a result of this operation, the function graph is shifted and scaled, as shown in the figure.

Effect of normalization on the function graph

In essence, as part of the Self-Attention algorithm, the process of data normalization is used as a function of activating the neural layer. However, unlike the latter, it does not change the data structure.

But we are not going to dig into the details of calculating the derivative of the complex data normalization function now. We have implemented the process of correcting the error gradient as a separate method.

```
//--- adjust the gradient for normalization

   if(!NormlizeBufferGradient(m_cOutputs, m_cGradients, GetPointer(m_cStd), 1))

      return false;
```

Next, we can use the FeedForward methods of our internal block layers and draw an error gradient to the internal layer for storing the results of the attention block.

```
//--- propagate a gradient through the layers of the Feed Forward block

   if(!m_cFF2.CalcHiddenGradient(GetPointer(m_cFF1)))

      return false;

   if(!m_cFF1.CalcHiddenGradient(GetPointer(m_cAttentionOut)))

      return false;
```

In the feed-forward method, before normalizing the results layer, we added the values of two buffers (the results of the FeedForward and Self-Attention blocks). Therefore, the error gradient should also be propagated along both branches of the algorithm. So, let's add the two gradient buffers together. To facilitate access to the buffer of the internal Self-Attention results storage layer, we create a local pointer to objects.

```
CBufferType *attention_grad = m_cAttentionOut.GetGradients();

   if(!attention_grad.SumArray(m_cGradients))

      return false;
```

Let's adjust the error gradient by the standard deviation.

```
//--- adjust the gradient for normalization

   if(!NormlizeBufferGradient(m_cAttentionOut.GetOutputs(), attention_grad,

                                                     GetPointer(m_cStd), 0))

      return false;
```

After adding the two error gradient tensors, we need to distribute the error gradient between the internal layers m_cQuerys, m_cKeys, and m_cValues. When we passed forward, we fully recreated the data flow algorithm block from the specified neural layers to the Self-Attention results buffer. Therefore, we will also have to create a backpropagation process. As always, here we will create a branching of the algorithm depending on the computing device. We start with considering the process of algorithm creation using standard MQL5 tools and will get back to the implementation of the multi-threaded computing mechanism using OpenCL a little later.

```
//--- branching the algorithm by the computing device

   if(!m_cOpenCL)

     {

      MATRIX values, gradients;
```

At the beginning of the MQL5 block, we will create two matrices for storing intermediate data: values and gradients.

We will be the first to transfer the error gradient to the neural layer of m_CValues values. It was the values of the results buffer of this neural layer that we multiplied by the dependency coefficients of the Score matrix to determine the results of the Self-Attention block during a direct pass. Now we are performing the reverse operation. As we have already said, the derivative of the multiplication operation is equal to the second factor. In our case, these are the Score matrix coefficients.

The data tensors have the following dimensions:

- The Score matrix is square with a side equal to the number of elements in the sequence.

- The m_CValues and m_CattentionOut buffers of neural layers have the number of rows equal to the number of sequence elements and the number of elements in each row equal to the size of the vector describing one element of the sequence.

To prevent potential mismatches in matrix sizes, we will reshape the error gradient matrix to the required format.

```
if(attention_grad.GetData(gradients, false) < (int)m_cOutputs.Total())

         return false;

      if(!gradients.Reshape(m_iUnits, m_iWindow))

         return false;
```

Each sequence element from m_CValues affects all elements of the m_CattentionOut sequence with the corresponding coefficient from the m_cScores matrix.

To organize the process of propagating the error gradient to the m_CValues neural layer buffer, we need to multiply the transposed m_cScores matrix of dependence coefficients by the gradients error matrix.

```
//--- gradient propagation to Values

      m_cValues.GetGradients().m_mMatrix =

                                  m_cScores.m_mMatrix.Transpose().MatMul(gradients);
```

Next, we'll propagate the error gradients to m_cQuerys and m_cKeys. Both neural layers participated in creating the m_cScores matrix of dependence coefficients. Therefore, we first need to determine the error gradient on the matrix of dependence coefficients.

During the feed-forward pass, to obtain the Self-Attention result, we multiplied the m_cScores  matrix by the results tensor of the neural layer m_CValues. We have already determined the error gradient for the neural layer. Now we need to propagate the error gradient along the second branch of the algorithm and distribute it to the values of the dependency coefficient matrix. Therefore, we will need to multiply the error gradient by the transposed results buffer of the m_cValues neural layer.

```
gradients = gradients.MatMul(values.Transpose());
```

Let me remind you that during a direct pass, the matrix values were normalized by the Softmax function as part of Query queries. The complexity of calculating this function and its derivative lies in the need to compute the entire normalization array at once. Unlike other functions, the derivative of a vector of values will be a matrix. This is due to the nature of the Softmax feature itself. A change in one element of the source data vector leads to a change in the entire sequence of the normalized result because the sum of all elements of the result vector is always equal to one. Therefore, in order to distribute the error gradient correctly, we need to work in the context of queries Query.

The mathematical formula for the derivative of the Softmax function is:

We'll use its matrix representation:

where E is a single square matrix with a size equal to the number of elements in the sequence.

The implementation of this approach is described below. In a loop, we determine the derivative of each individual row of the dependency coefficient matrix. After multiplying the resulting matrix by the gradient vector of the corresponding row, we get a vector of corrected error gradients. Let's not forget that before normalizing the dependency coefficient matrix Score, we divided its values by the square root of the dimension of the vector describing one element in the Key tensor. Accordingly, we will repeat this procedure for the error gradient as well. The logic of this operation is simple: dividing by a constant is equivalent to multiplying by the reciprocal of that constant, and the derivative of a multiplication operation is equal to its second multiplier.

The result of the above operations will replace the analyzed row of the gradient matrix.

```
for(int r = 0; r < m_iUnits; r++)

        {

         MATRIX ident = MATRIX::Identity(m_iUnits, m_iUnits);

         MATRIX ones = MATRIX::Ones(m_iUnits, 1);

         MATRIX result = MATRIX::Zeros(1, m_iUnits);

         if(!result.Row(m_cScores.m_mMatrix.Row(r), 0))

            return false;

         result = ones.MatMul(result);

         result = result.Transpose() * (ident - result);

         VECTOR temp = result.MatMul(gradients.Row(r));

         if(!gradients.Row(temp / sqrt(m_iKeysSize), r))

            return false;

        }
```

After obtaining an adjusted error gradient for each individual dependency coefficient, we distribute it to the corresponding Query and Key tensor vectors. To this end, we will multiply the matrix of adjusted gradients of dependence coefficients by the opposite matrix.

```
m_cQuerys.GetGradients().m_mMatrix =

                                      gradients.MatMul(m_cKeys.GetOutputs().m_mMatrix);

      m_cKeys.GetGradients().m_mMatrix =

                        gradients.Transpose().MatMul(m_cQuerys.GetOutputs().m_mMatrix);

     }
```

```
else // OpenCL block

     {

      return false;

     }
```

This completes the block for branching the algorithm by the computing device. In the OpenCL block, we will leave the return of a negative result for now and will come back to it a little later. Now let's move on with our error backpropagation algorithm. After obtaining the error gradient at the output of the internal neural layers, we need to propagate it back to the previous layer.

As you remember, in the feed-forward pass, the source data is used in four branches of the algorithm:

- At the input of the internal m_Cquerys layer

- At the input of the internal m_CKeys layer

- At the input of the internal m_CValues layer

- Added to the output of the Self-Attention block before the layer is normalized

Therefore, in the buffer for the error gradients of the previous layer, we should accumulate the error gradient from all 4 directions. The operating algorithm is similar to the previously constructed process of adding buffers in a recurrent LSTM block. However, we will not create a separate buffer to accumulate data; we will use the existing one instead. The error gradient at the output of the Self-Attention block has already been calculated in the neural layer buffer m_CattentionOut. This is where we will accumulate intermediate error gradients.

We will alternately call the method of transferring the gradient to the previous  CalcHiddenGradient layer for each inner layer, giving it a pointer to the previous neural layer. After successfully executing the method, we will add the obtained result to the previously accumulated error gradient in the gradient buffer of the m_CattentionOut neural layer.

```
//--- transfer the error gradient to the previous layer

   if(!m_cValues.CalcHiddenGradient(prevLayer))

      return false;

   if(!attention_grad.SumArray(prevLayer.GetGradients()))

      return false;

   if(!m_cQuerys.CalcHiddenGradient(prevLayer))

      return false;

   if(!attention_grad.SumArray(prevLayer.GetGradients()))

      return false;

   if(!m_cKeys.CalcHiddenGradient(prevLayer))

      return false;

   if(!prevLayer.GetGradients().SumArray(attention_grad))

      return false;

//---

   return true;

  }
```

Note that in the first two cases, we recorded the sum of two error gradient buffers into the internal neural layer buffer. In the last case, we saved the sum of the two buffers into the buffer for the error gradients of the previous neural layer. The reason is that the CalcHiddenGradient method of the internal neural layer overwrites the values in the gradient buffer of the neural layer specified in the parameters. So, we needed to accumulate intermediate gradients in a different buffer. However, at the end of the method, we need to propagate the error gradient to the previous layer. Therefore, during the last summation of the buffers, we immediately write the sum to the buffer of the previous neural layer, thereby avoiding unnecessary copying of data.

A method for correcting the error gradient for the NormlizeBufferGradient data normalization process was announced above. What is the normalization process and why is it difficult to determine the derivative of a function? At first glance, we subtract the arithmetic mean from each element of the normalized array and divide the resulting difference by the standard deviation.

If we were subtracting and dividing by constants, there would be no difficulties. When a constant is subtracted, the derivative does not change.

The derivative of dividing by a constant is equal to the ratio of 1 to the constant.

But the problem is that both the average ones are functions. When changing any single value in the input tensor, the values of the means change, and consequently, all the values in the output tensor of the normalization block are affected. This makes it much more difficult to calculate the derivative of the entire function. We will not present them now and will instead use the ready-made result.

Let's implement the above formulas in code using MQL5 matrix operations. In parameters, the method receives pointers to 3 data buffers:

- output — buffer with the results of normalizing feed-forward data

- gradient — error gradient buffer. It is used both for obtaining initial data and for recording results

- std — standard deviation buffer calculated during a forward pass.

As you can see, the parameters do not include the data buffer before normalization and the value of the arithmetic mean calculated during the forward pass. We simply replaced the difference between the non-normalized data and the arithmetic mean with the product of the normalized data and the standard deviation.

Of course, we don't expect zero standard deviation. Let's add a check to prevent a critical error of division by zero.

```
bool CNeuronAttention::NormlizeBufferGradient(CBufferType *output,

                                              CBufferType *gradient,

                                              CBufferType *std,

                                              uint std_shift)

  {

//---

   if(!m_cOpenCL)

     {

      if(std.At(std_shift) <= 0)

         return true;

      MATRIX ScG = gradient.m_mMatrix / std.m_mMatrix[0, std_shift];

      MATRIX ScOut = output.m_mMatrix * std.m_mMatrix[0, std_shift];

      TYPE dSTD = (gradient.m_mMatrix * output.m_mMatrix / (-2 * MathPow(std.m_mMatrix[0, std_shift], 2))).Sum();

      TYPE dMean = -1 * ScG.Sum() - 2 * dSTD / (TYPE)output.Total() * ScOut.Sum();

      gradient.m_mMatrix = ScG + (ScOut * dSTD * 2 + dMean) / (TYPE)output.Total();

     }

    else // OpenCL block

     {

      return false;

     }

//---

   return true;

  }
```

In addition to the method of distributing the gradient through a hidden layer, the algorithm for the backward distribution of the error gradient in all previously considered neural layers is usually represented by two more methods:

- CalcDeltaWeights — method for calculating the error gradient to the level of the weight matrix

- UpdateWeights — method for updating weights

The CNeuronAttention class under consideration will be no exception. We will also use it to redefine these two methods. Their algorithm is straightforward: we will simply call the methods of all internal neural layers of the same name one by one, while constantly checking the results of the operations.

```
bool CNeuronAttention::CalcDeltaWeights(CNeuronBase *prevLayer)

  {

   if(!m_cFF2.CalcDeltaWeights(GetPointer(m_cFF1)))

      return false;

   if(!m_cFF1.CalcDeltaWeights(GetPointer(m_cAttentionOut)))

      return false;

   if(!m_cQuerys.CalcDeltaWeights(prevLayer))

      return false;

   if(!m_cKeys.CalcDeltaWeights(prevLayer))

      return false;

   if(!m_cValues.CalcDeltaWeights(prevLayer))

      return false;

//---

   return true;

  }
```

```
bool CNeuronAttention::UpdateWeights(int batch_size, TYPE learningRate,

                                     VECTOR &Beta, VECTOR &Lambda)

  {

   if(!m_cQuerys.UpdateWeights(batch_size, learningRate, Beta, Lambda))

      return false;

   if(!m_cKeys.UpdateWeights(batch_size, learningRate, Beta, Lambda))

      return false;

   if(!m_cValues.UpdateWeights(batch_size, learningRate, Beta, Lambda))

      return false;

   if(!m_cFF1.UpdateWeights(batch_size, learningRate, Beta, Lambda))

      return false;

   if(!m_cFF2.UpdateWeights(batch_size, learningRate, Beta, Lambda))

      return false;

//---

   return true;

  }
```

In this way, we have implemented three methods that make up the backpropagation algorithm for our attention block.

## 5.Self-Attention feed-forward method

We have already created the structure of a class organization for implementing the attention mechanism and even created an object initialization method. In this section, we will organize the forward pass process.

As you know, in the base class of the neural network, we have created a virtual method [CNeuronBase::FeedForward](https://www.mql5.com/en/neurobook/index/realization/perceptron/pr_mql5#feedforward) which is responsible for organizing the feed-forward pass. In each new class, we override this method to organize the relevant process according to the algorithm of the implemented architectural solution. By doing so, we kind of personalize the method for each class. At the same time, the external program does not need to know anything about the organization of the process within the class. It doesn't even need to know the type of neural layer. It simply calls the FeedForward method of the next object and passes it a pointer to the previous layer of the neural network. In this way, we have shifted the functionality of dispatching and checking the required object type from our program to the system.

Let's go back to our CNeuronAttention::FeedForward method. Just like the method of the parent class, in parameters it receives a pointer to the object of the previous layer. This is consistent with the principles of method inheritance and overriding. Since we receive a pointer to an object, it is customary to begin the method with a block to check the validity of the received pointer. However, in this case, we will omit it. The reason is that the use of static internal objects allows us to refuse to check their pointers. Regarding the pointer to the previous neural layer, we will use it for the feed-forward pass of the internal convolutional neural layers m_cQuerys, m_cKeys and m_cValues. They already have the relevant controls and thus we do not need to duplicate them.

In accordance with the Self-Attention algorithm, we need to define the Query, Key, and Value vectors for each element of the sequence. As you remember, it was for this functionality that we created the first three convolutional layers. Therefore, to solve this problem, we just need to call the FeedForward methods for the named internal layers. With each call in the parameters, we pass a pointer to the previous neural layer obtained in the parameters of our CNeuronAttention::FeedForward method.

```
if(!m_cQuerys.FeedForward(prevLayer))

      return false;

   if(!m_cKeys.FeedForward(prevLayer))

      return false;

   if(!m_cValues.FeedForward(prevLayer))

      return false;
```

Next in the Self-Attention algorithm, we need to determine the dependency coefficients and fill in the Score matrix. At this point, it's essential to recall our paradigm of creating classes capable of running both on the CPU and using the GPU tools. Each time we build a new process, we create a branching of the algorithm depending on the computing device in use. This method will not be an exception, and we will continue to work in the same direction. Right now, we will create a similar branching of the process. We will start with the process using MQL5 tools and will return to the OpenCL branch a little later.

For convenience, we copy the m_cQuerys and m_cKeys matrices which contain the results of the convolutional layers.

```
//--- branching of the algorithm by the computing device

   MATRIX out;

   if(!m_cOpenCL)

     {

      MATRIX querys = m_cQuerys.GetOutputs().m_mMatrix;

      MATRIX keys = m_cKeys.GetOutputs().m_mMatrix;
```

After completing the preparatory work, we need to "roll up our sleeves" and build a new process. The Self-Attention method involves line-wise normalization of the dependency matrix using the Softmax function.

The main feature of such normalization lies in obtaining a series of positive values that sum up to 1. Thus, by multiplying the normalized dependency coefficients with the values of Value vectors of the corresponding sequence elements and then summing up these vectors within one Query, we expect to obtain new vectors within the same range of values.

Let's look at the implementation of this process. First, we organize the process of calculating the dependency coefficients into the Score matrix. According to the Self-Attention algorithm, each element of the matrix represents the product of the Query and Key vectors. In this case, the matrix row indicates the position of the vector in the Queries matrix and its column indicates the position in the Keys matrix.

Here, it is important to carefully consider the choice of elements to be multiplied. Let's recall how we organized the output of the results to the buffer of the convolutional layer. To enable the operation of the pooling layer in the context of filters, we have organized the sequential output of filters. First, in the first row of the result buffer matrix, we output all the elements of the result of one filter. Then, in the next row, we write the elements of the next filter, and so on. This organization of the buffer is convenient for the transparent operation of the pooling layer within the filters. In this case, within the vector of one element of the sequence, we need to use one value from each filter. In other words, we need a transposed matrix.

Reorganizing the buffer data in such a way that the first elements of all filters come first, then the second elements of all filters, and so on, would require additional resources on each feed-forward pass. It would be much easier to organize a convenient record directly in the convolutional layer. However, this would disrupt the operation of both the pooling layer and subsequent convolutional layers when building convolutional models. Therefore, it was decided to introduce a flag into the operation of the convolutional layer to determine whether the values should be arranged in the result buffer. You may have already guessed this when I talked about the new SetTransposedOutput convolutional layer method when describing the initialization method. I promised to return to the description of the functionality of this method. Such a solution has helped us keep the structure of the feed-forward pass method transparent and avoid additional time and resource costs for data reorganization. Let's finish working with the feed-forward pass method, and then we can revisit the changes in the convolutional layer.

Taking into account the transposition of the convolutional layer results, to obtain the values of the matrix of dependency coefficients, we need to multiply the Querys matrix by the transposed matrix Keys. It sounds a little strange to transpose the work of the convolutional layer method and then transpose the Keys matrix. However, we will use the result of transposing the work of the convolutional layer more than once. Of course, with the help of the entered flag, we could transpose the work of the convolutional layer m_cQuerys, and leave the m_cKeys layer unchanged. But in this case, there is a possibility of confusion with the matrix dimensions. This will make the code more difficult to read and understand. Therefore, I decided to unify the dimensions of the matrices used.

Please note that simultaneously with the calculation of the vector product, we will prepare data for normalization according to the Softmax formula above. For this purpose, we will immediately divide the obtained matrix by the square root of the Key vector size and take the exponent of the resulting value.

Then we will take the row-wise sum of the matrix values and divide the values by the resulting vector of the matrix Scores. MQL5 matrix operations do not allow you to divide a matrix by a vector. Therefore, we will organize a loop in which we will sequentially divide each row by the sum of its values.

```
//--- define Scores

      MATRIX scores = MathExp(querys.MatMul(keys.Transpose()) / sqrt(m_iKeysSize));

      //--- normalize Scores

      VECTOR summs = scores.Sum(1);

      for(int r = 0; r < m_iUnits; r++)

         if(!scores.Row(scores.Row(r) / summs[r], r))

            return false;

      m_cScores.m_mMatrix = scores;
```

After normalizing the data in the matrix containing the dependencies coefficients of the elements in the sequence, we will transfer these values to our data buffer buffer m_cScores.

At this stage, we have computed and normalized the dependency coefficients between all elements of the sequence. Now, according to the algorithm of the Self-Attention method, we need to calculate the weighted sum of the Values vectors in terms of each Query. To do this, we just need to multiply the matrix of dependency coefficients by the matrix of results of the convolutional layer m_cValues. Again, it is precisely because of the transposition of the work of the convolutional layer that we do not transpose the matrix of the results of the m_cValues layer.

```
//--- the output of the attention block

      MATRIX values = m_cValues.GetOutputs().m_mMatrix;

      out = scores.MatMul(values);
```

The product of the matrices will give us the result of the Self-Attention mechanism. But we will go a little further and build the entire Encoder block of the transformer. According to his algorithm, the results of Self-Attention are added to the buffer of the original data. The obtained values are normalized within the neural layer. The following formulas are used to normalize the data.

To perform this operation, we will first bring the format of the results matrix of the Self-Attention block in accordance with the format of the matrix of the initial data and add the two matrices. The result is normalized in a specially selected NormlizeBuffer method.

```
//--- add to initial data and normalize

      if(!out.Reshape(prevLayer.Rows(), prevLayer.Cols()))

         return false;

      m_cAttentionOut.GetOutputs().m_mMatrix = out +

                                             prevLayer.GetOutputs().m_mMatrix;

      if(!NormlizeBuffer(m_cAttentionOut.GetOutputs(), GetPointer(m_cStd), 0))

         return false;

     }
```

With this, the first block of operations is completed. This concludes the section on dividing the algorithm based on the execution of mathematical operations. For the block of operations using OpenCL, we will temporarily set the return of an error value and come back to it later.

```
else // OpenCL block

     {

      return false;

     }
```

Let's continue working with the encoder algorithm and move on to the second block of operations. Here it is necessary to conduct the signal of each element of the sequence through two fully connected layers. As you remember, we decided to organize this work through two convolutional layers. At first glance, there is nothing complicated about it - we simply call the forward pass methods for each convolutional layer sequentially.

```
--- call the feed-forward methods of the Feed Forward block layers

   if(!m_cFF1.FeedForward(GetPointer(m_cAttentionOut)))

      return false;

   if(!m_cFF2.FeedForward(GetPointer(m_cFF1)))

      return false;
```

Here, correct operation is possible only due to the transposition of the buffer of the convolutional neural layers results. Only this approach allows the aligned operation on each individual element of the sequence.

After conducting a forward pass through two convolutional layers, just as after determining the attention results, it is necessary to propagate the obtained results to the data input into the first convolutional layer and normalize the resulting sums. We have already considered such a task above. Here we use the same algorithm, only the data buffers are different.

```
//--- add to the output of attention and normalize

   if(!m_cOutputs.SumArray(m_cAttentionOut.GetOutputs()))

      return false;

//--- normalize

   if(!NormlizeBuffer(m_cOutputs, GetPointer(m_cStd), 1))

      return false;

//---

   return true;

  }
```

It should be noted that thanks to the buffer substitution organized in the initialization method, we obtain the results of the second convolutional layer from the result buffer of the current layer. In the same buffer, we will save the results of data normalization.

After the completion of the operations, we exit the feed-forward method with a positive result.

Now let's take a look at the changes made to the convolutional layer class. First, we'll add a variable to store the flag of the m_bTransposedOutput output structure. This will be a Boolean flag indicating the need to transpose the result matrix for output to the buffer. By default, we will set the value to false, which means working in normal mode.

```
class CNeuronConv    :  public CNeuronProof

  {

protected:

   bool              m_bTransposedOutput;

public:

   bool              SetTransposedOutput(const bool value);

   ....

  }
```

To control the value of the flag, let's create the SetTransposedOutput method. The functionality of the method is quite simple. We resize the result matrices and error gradients.

```
bool CNeuronConv::SetTransposedOutput(const bool value)

  {

   m_bTransposedOutput = value;

   if(value)

     {

      if(!m_cOutputs.BufferInit(m_iNeurons, m_iWindowOut, 0))

         return false;

      if(!m_cGradients.BufferInit(m_iNeurons, m_iWindowOut, 0))

         return false;

     }

   else

     {

      if(!m_cOutputs.BufferInit(m_iWindowOut, m_iNeurons, 0))

         return false;

      if(!m_cGradients.BufferInit(m_iWindowOut, m_iNeurons, 0))

         return false;

     }

//---

   return true;

  }
```

However, as you understand, the presence of a flag and even a method that changes it will not affect the results of data output to the buffer. To do this, we have to make some changes to the forward pass method. We are not changing the algorithm or the calculation logic at all; our changes will only involve rearranging matrices when multiplying the input data by the weight matrix, depending on the state of the m_bTransposedOutput flag.

```
bool CNeuronConv::FeedForward(CNeuronBase *prevLayer)

  {

//--- control block

    ....

//--- branching the algorithm depending on the execution device

   if(!m_cOpenCL)

     {

    ....

      //--- Calculating the weighted sum of the elements of the input window

      if(m_bTransposedOutput)

         m = m.MatMul(m_cWeights.m_mMatrix.Transpose());

      else

         m = m_cWeights.m_mMatrix.MatMul(m.Transpose());

      m_cOutputs.m_mMatrix = m;

     }

   else  // OpenCL block

     {

    ....

     }

//---

   if(!m_cActivation.Activation(m_cOutputs))

      return false;

//---

   return true;

  }
```

After making changes to the feed-forward method, we need to make similar adjustments to the backpropagation methods because the error gradient should be propagated back to the point of error occurrence. Otherwise, the results of training the neural network will be unpredictable. First, we make changes to the gradient distribution method in the hidden layer CNeuronConv::CalcHiddenGradient.

```
bool CNeuronConv::CalcHiddenGradient(CNeuronBase *prevLayer)

  {

//--- control block

    ....

//--- correction of error gradients to the derivative of the activation function

    ....

//--- branching the algorithm depending on the execution device

   CBufferType* input_gradient = prevLayer.GetGradients();

   if(!m_cOpenCL)

     {

      MATRIX g = m_cGradients.m_mMatrix;

      if(m_bTransposedOutput)

        {

         if(!g.Reshape(m_iNeurons, m_iWindowOut))

            return false;

        }

      else

        {

         if(!g.Reshape(m_iWindowOut, m_iNeurons))

            return false;

         g = g.Transpose();

        }

    ....

     }

   else  // OpenCL block

     {

    ....

     }

//---

   return true;

  }
```

Then we make the relevant changes in the CNeuronConv::CalcDeltaWeights method for distributing the gradient to the weight matrix level.

```
bool CNeuronConv::CalcDeltaWeights(CNeuronBase *prevLayer)

  {

//--- control block

    ....

//--- branching the algorithm depending on the execution device

   CBufferType *input_data = prevLayer.GetOutputs();

   if(!m_cOpenCL)

     {

    ....

      //---

      MATRIX g = m_cGradients.m_mMatrix;

      if(m_bTransposedOutput)

        {

         if(!g.Reshape(m_iNeurons, m_iWindowOut))

            return false;

         g = g.Transpose();

        }

      else

        {

         if(!g.Reshape(m_iWindowOut, m_iNeurons))

            return false;

        }

      m_cDeltaWeights.m_mMatrix += g.MatMul(inp);

     }

   else  // OpenCL block

     {

    ....

     }

//---

   return true;

  }
```

As you can see, the changes are not so crucial, but they provide enhanced flexibility in settings.

## 5.File operations

We have already built the feed-forward and backpropagation methods for our attention layer. We can add the layer to our model and train it, but we don't really want to retrain our model from scratch every time we want to use it. We need to be able to save a once-trained model to a file and, if necessary, load a ready-to-use neural network from the file. Two methods are responsible for working with files in our basic neural layer: Save and Load. To ensure the proper functioning of your new layer, you need to override the specified methods.

We perform a similar iteration when creating each new type of neural layer. Now we will follow the known path: we will focus on the structure of our class and determine what needs to be saved to a file, and which variables and objects we will simply create and initialize with initial values.

First of all, it is necessary to save the internal neural layers containing the weight matrices m_cQuerys, m_cKeys, m_cValues, m_cFF1, and m_cFF2. In addition, we need to save the values of the variables that define the architecture of the neural layer: m_iWindow, m_iUnits, and m_iKeysSize.

We do not need to save any information from the m_cScores buffer to the file, since it contains only intermediate data that is overwritten on each forward pass. Its size is easy to determine based on the number of elements in the sequence recorded in the variable m_iUnits.

The m_cAttentionOut inner layer does not contain the matrix weights, while its data, similarly to the data of the m_cScores buffer, are overwritten at each iteration of the forward and reverse passes. However, let's look at the situation from the other side. Recall the procedure for initializing the neural layer:

- Create a neural layer description object

- Fill in the neural layer description object with the necessary information

- Call the method that initializes the neural layer with the transfer of a description

- Delete the neural layer description object

At the same time, calling the save method for the base neural layer without weight matrices will write only 3 integers to the file, with a total size of 12 bytes. So, by sacrificing 12 bytes of disk space, we reduce our efforts in writing the initialization code for the neural layer in the data loading method.

```
class CNeuronAttention    :  public CNeuronBase

  {

protected:

   CNeuronConv       m_cQuerys;

   CNeuronConv       m_cKeys;

   CNeuronConv       m_cValues;

   CBufferType       m_cScores;

   int               m_cScoreGrad;

   int               m_cScoreTemp;

   CNeuronBase       m_cAttentionOut;

   CNeuronConv       m_cFF1;

   CNeuronConv       m_cFF2;

   //---

   int               m_iWindow;

   int               m_iUnits;

   int               m_iKeysSize;

   CBufferType       m_cStd;

   //---

   virtual bool      NormlizeBuffer(CBufferType *buffer, CBufferType *std,

                                                                uint std_shift);

   virtual bool      NormlizeBufferGradient(CBufferType *output,

                       CBufferType *gradient, CBufferType *std, uint std_shift);

public:

                     CNeuronAttention(void);

                    ~CNeuronAttention(void);

   //---

   virtual bool      Init(const CLayerDescription *desc) override;

   virtual bool      SetOpenCL(CMyOpenCL *opencl) override;

   virtual bool      FeedForward(CNeuronBase *prevLayer) override;

   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;

   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer) override;

   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,

                                   VECTOR &Beta, VECTOR &Lambda) override;

   //--- methods for working with files

   virtual bool      Save(const int file_handle) override;

   virtual bool      Load(const int file_handle) override;

   //--- object identification method

   virtual int       Type(void) override  const { return(defNeuronAttention); }

  };
```

Once we have decided on the objects to write data to the file, we can start working on our methods. Let's start with the Save method that writes data to the file. In the parameters, the method receives the handle of the file to write the data. However, we will not immediately check the received handle. Instead, we will call the analogous method of the parent class, where all checkpoints and the saving of inherited objects are already implemented. The result of the parent class method will indicate the result of the control block execution.

```
bool CNeuronAttention::Save(const int file_handle)

  {

   if(!CNeuronBase::Save(file_handle))

      return false;
```

After executing the parent class method, we call the save method for internal objects one by one. At the same time, we check the results of the operations.

```
if(!m_cQuerys.Save(file_handle))

      return false;

   if(!m_cKeys.Save(file_handle))

      return false;

   if(!m_cValues.Save(file_handle))

      return false;

   if(!m_cAttentionOut.Save(file_handle))

      return false;

   if(!m_cFF1.Save(file_handle))

      return false;

   if(!m_cFF2.Save(file_handle))

      return false;
```

After saving the data of internal objects, we'll save the values of variables that define the architecture of the neural layer. Quite obviously, we check the result of the operations.

```
if(FileWriteInteger(file_handle, m_iUnits) <= 0)

      return false;

   if(FileWriteInteger(file_handle, m_iWindow) <= 0)

      return false;

   if(FileWriteInteger(file_handle, m_iKeysSize) <= 0)

      return false;

//---

   return true;

  }
```

After successfully saving all the necessary data, we complete the method with a positive result.

After creating a data writing method, we move on to work on the Load data reading method. In the parameters, the method receives the file handle to read the data. Just like in the case of writing data, we do not create a new control block in our method. Instead, we call the method of the parent class where all controls, reading of inherited objects, and variables are already implemented. Checking the result of the parent class method immediately informs us about both the completion of the control block and the loading of data from inherited objects and variables.

```
bool CNeuronAttention::Load(const int file_handle)

  {

   if(!CNeuronBase::Load(file_handle))

      return false;
```

After successfully executing the data loading method of the parent class, we will sequentially read the data of internal objects. Recall that reading data from a file is carried out in strict accordance with the sequence of writing data. When writing data to a file, we first saved information from the m_cQuerys internal neural layer. Therefore, we will be loading data into this object first. However, don't forget about the nuance of loading internal neural layers: we first check the type of the loaded object and only then call the loading method for the corresponding object.

```
if(FileReadInteger(file_handle) != defNeuronConv || !m_cQuerys.Load(file_handle))

      return false;
```

We repeat the same algorithm for all previously saved objects.

```
if(FileReadInteger(file_handle) != defNeuronConv || !m_cKeys.Load(file_handle))

      return false;

   if(FileReadInteger(file_handle) != defNeuronConv || !m_cValues.Load(file_handle))

      return false;

   if(FileReadInteger(file_handle) != defNeuronBase ||

      !m_cAttentionOut.Load(file_handle))

      return false;

   if(FileReadInteger(file_handle) != defNeuronConv || !m_cFF1.Load(file_handle))

      return false;

   if(FileReadInteger(file_handle) != defNeuronConv || !m_cFF2.Load(file_handle))

      return false;
```

After loading the data of the internal neural layer objects, we read the values of the variables that determine the architecture of our attention neural layer from the file.

```
m_iUnits = FileReadInteger(file_handle);

   m_iWindow = FileReadInteger(file_handle);

   m_iKeysSize = FileReadInteger(file_handle);
```

Then we need to initialize the m_cScores buffer of dependency coefficients with zero values. We do not change the size of the buffer beforehand, since the buffer initialization method provides for changing its size to the required level.

```
if(!m_cScores.BufferInit(m_iUnits, m_iUnits, 0))

      return false;
```

We have loaded all the data and initialized the objects. It is worth remembering that to avoid unnecessary data copying, we replaced the pointers to the result and gradient buffers of the internal layer m_cFF2 and the attention layer itself. Without this substitution of pointers, all the work of our neural layer will be incorrect. But if for some reason we re-create the object of the m_cFF2 inner layer, then new objects of buffers of the specified inner neural layer will be created. In this case, we need to perform such a substitution of pointers again. At the same time, if both variables contain pointers to the same object, then by deleting the object through one pointer, we will end up with an invalid pointer in the second variable. This is a tricky moment that you need to be careful with.

We will, of course, add buffer replacement, but we will first check the correspondence of the pointers.

```
if(m_cFF2.GetOutputs() != m_cOutputs)

     {

      if(m_cOutputs)

         delete m_cOutputs;

      m_cOutputs = m_cFF2.GetOutputs();

     }
```

```
if(m_cFF2.GetGradients() != m_cGradients)

     {

      if(m_cGradients)

         delete m_cGradients;

      m_cGradients = m_cFF2.GetGradients();

     }

//---

   SetOpenCL(m_cOpenCL);

//---

   return true;

  }
```

After the successful completion of all operations, we exit the method with a positive result.

At this point, we can consider working on creating a neural layer of attention using the standard tools of the MQL5 language to be completed. In this version, we can insert a neural layer of attention into our model and check its performance. To make the most efficient use of the created class, we need to enhance its methods with multithreading capabilities.
