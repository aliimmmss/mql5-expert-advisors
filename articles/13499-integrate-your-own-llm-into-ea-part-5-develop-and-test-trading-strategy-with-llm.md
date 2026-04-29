# Integrate Your Own LLM into EA (Part 5): Develop and Test Trading Strategy with LLMs(II)-LoRA-Tuning

**Source:** [https://www.mql5.com/en/articles/13499](https://www.mql5.com/en/articles/13499)

---

Integrate Your Own LLM into EA (Part 5): Develop and Test Trading Strategy with LLMs(II)-LoRA-Tuning
MetaTrader 5
—
Trading
| 15 October 2024, 15:44
1 480
0
Yuqiang Pan
Table of contents
Table of contents
Introduction
Environment Configuration
LoRA Configuration
LoRA-Tuning
Comparison of Different Fine-Tuning Methods
Conclusion
Introduction
In the previous article, we introduced how to fine-tune the GPT-2 pre-trained model using our own financial data with a full-parameter fine-tuning method and evaluated the model's output results. In this article and the following ones, we will further discuss how to implement other fine-tuning methods with code examples (we will only discuss the fine-tuning methods introduced in the previous article, and of course, it is impossible to implement every method. I will only select a few commonly used methods for implementation). This article will take the LoRA-tuning method as an example for discussion.
Additionally, we have a task to try to compare the models trained with these different fine-tuning methods horizontally, and then find the best-performing model under the current currency pair (of course, the model's performance may also vary under different market conditions, such as upward trends, downward trends, or oscillating trends). This can more clearly guide us on which model training method to use in practice to achieve better results. Of course, if we are more rigorous, we should not only compare these different processing methods horizontally, but also compare the performance of the fine-tuned models of different currency pairs under different data processing methods and fine-tuning methods. This seems to be a simple but extremely tedious task. I, personally, believe that if we really want to apply this series of methods in trading, this step is crucial. However, I do not intend to introduce this part in detail in this series of articles because I believe everyone can easily expand based on our examples. Just replace the training data with different currency pairs and then compare the model performance horizontally. Although this is tedious, it is easy to achieve.
Another point to note is that in previous articles, I neglected to introduce the corresponding environment configuration and library dependencies in the example code, which may cause some friends to encounter errors due to missing dependencies when trying to run the examples. In future articles, I will provide detailed explanations of the environment configuration and dependencies used in the current code to help readers easily run the examples.
Now let's officially enter the topic of this article!
Environment Configuration
Below is the running environment for the code examples provided in this article. Of course, this does not mean that your code environment must be the same as mine, but if you encounter problems when running the code, you can refer to my environment configuration.
Operating System: Ubuntu 22.04.5 LTS (or the corresponding version of WSL)
Python Version: 3.10.14
Necessary Python Libraries:
torch-2.4.1
numpy-1.26.3
pandas-2.2.3
transformers-4.45.1
petf-0.13.0
matplotlib-3.9.2
If you are not familiar with how to configure the code running environment, I have detailed introductions in other articles in this series:
AMD graphics card users can refer to the previous article (
Integrate Your Own LLM into EA (Part 4): Training Your Own LLM with GPU
)
NVIDIA graphics card users can refer to the second article in this series (
Integrate Your Own LLM into EA (Part 2): Example of Environment Deployment
)
This article will not provide a detailed introduction to this part.
LoRA Configuration
We have already introduced LoRA in the previous article, so this article will not repeat the description. To make the fine-tuning process simpler and clearer, this article will not reproduce the code example of the original LoRA author but will use the simpler peft library.
This Python library integrates various configurations we need, including the LoRA-tuning parameter configuration class (LoraConfig), the LoRA-tuning initialization model method (get_peft_model), and the LoRA fine-tuned model loading class (PeftModel).
Next, I will introduce them step by step, starting with the LoraConfig class.
1. LoraConfig Class
The LoraConfig class belongs to the peft library and can be directly imported from the peft library. After importing the LoraConfig class, you need to set its configuration parameters.
Next, let's introduce the parameter configuration in the LoraConfig class：
r (`int`):
Lora attention dimension (the "rank").
target_modules (`Optional[Union[List[str], str]]`):
The names of the modules to apply the adapter to. If this is specified, only the modules with the specified names will be replaced. When passing a string, a regex match will be performed. When passing a list of strings, either an exact match will be performed or it is checked if the name of the module ends with any of the passed strings. If this is specified as 'all-linear', then all linear/Conv1D modules are chosen, excluding the output layer. If this is not specified, modules will be chosen according to the model architecture. If the architecture is not known, an error will be raised -- in this case, you should specify the target modules manually.
lora_alpha (`int`):
The alpha parameter for Lora scaling.
lora_dropout (`float`):
The dropout probability for Lora layers.
fan_in_fan_out (`bool`):
Set this to True if the layer to replace stores weight like (fan_in, fan_out). For example, gpt-2 uses `Conv1D` which stores weights like (fan_in, fan_out) and hence this should be set to `True`.
bias (`str`):
Bias type for LoRA. Can be 'none', 'all' or 'lora_only'. If 'all' or 'lora_only', the corresponding biases will be updated during training. Be aware that this means that, even when disabling the adapters, the model will not produce the same output as the base model would have without adaptation.
use_rslora (`bool`):
When set to True, uses <a href='https://doi.org/10.48550/arXiv.2312.03732'>Rank-Stabilized LoRA</a> which sets the adapter scaling factor to `lora_alpha/math.sqrt(r)`, since it was proven to work better. Otherwise, it will use the original default value of `lora_alpha/r`.
modules_to_save (`List[str]`):
List of modules apart from adapter layers to be set as trainable and saved in the final checkpoint.
init_lora_weights (`bool` | `Literal["gaussian", "olora", "pissa", "pissa_niter_[number of iters]", "loftq"]`):
How to initialize the weights of the adapter layers. Passing True (default) results in the default initialization from the reference implementation from Microsoft. Passing 'gaussian' results in Gaussian initialization scaled by the LoRA rank for linear and layers. Setting the initialization to False leads to completely random initialization and is discouraged. Pass `'loftq'` to use LoftQ initialization. Pass `'olora'` to use OLoRA initialization. Passing `'pissa'` results in the initialization of <a
href='https://arxiv.org/abs/2404.02948'>Principal Singular values and Singular vectors Adaptation (PiSSA)</a>, which converges more rapidly than LoRA and ultimately achieves superior performance. Moreover, PiSSA reduces the quantization error compared to QLoRA, leading to further enhancements. Passing
`'pissa_niter_[number of iters]'` initiates Fast-SVD-based PiSSA initialization, where `[number of iters]` indicates the number of subspace iterations to perform FSVD, and must be a nonnegative integer. When`[number of iters]` is set to 16, it can complete the initialization of a 7B model within seconds, and the training effect is approximately equivalent to using SVD.
layers_to_transform (`Union[List[int], int]`):
The layer indices to transform. If a list of ints is passed, it will apply the adapter to the layer indices that are specified in this list. If a single integer is passed, it will apply the transformations on the layer at this index.
layers_pattern (`str`):
The layer pattern name, used only if `layers_to_transform` is different from `None`.
rank_pattern (`dict`):
The mapping from layer names or regexp expression to ranks which are different from the default rank specified by `r`.
alpha_pattern (`dict`):
The mapping from layer names or regexp expression to alphas which are different from the default alpha specified by `lora_alpha`.
megatron_config (`Optional[dict]`):
The TransformerConfig arguments for Megatron. It is used to create LoRA's parallel linear layer. You can get it like this, `core_transformer_config_from_args(get_args())`, these two functions being from Megatron. The arguments will be used to initialize the TransformerConfig of Megatron. You need to specify this parameter when you want to apply LoRA to the ColumnParallelLinear and RowParallelLinear layers of megatron.
megatron_core (`Optional[str]`):
The core module from Megatron to use, defaults to `"megatron.core"`.
loftq_config (`Optional[LoftQConfig]`):
The configuration of LoftQ. If this is not None, then LoftQ will be used to quantize the backbone weights and initialize Lora layers. Also pass `init_lora_weights='loftq'`. Note that you should not pass a quantized model in this case, as LoftQ will quantize the model itself.
use_dora (`bool`):
Enable 'Weight-Decomposed Low-Rank Adaptation' (DoRA). This technique decomposes the updates of the weights into two parts, magnitude and direction. Direction is handled by normal LoRA, whereas the magnitude is handled by a separate learnable parameter. This can improve the performance of LoRA especially at low ranks. Currently, DoRA only supports linear and Conv2D layers. DoRA introduces a bigger overhead than pure LoRA, so it is recommended to merge weights for inference. For more information, see
https://arxiv.org/abs/2402.09353
.
layer_replication (`List[Tuple[int, int]]`):
Build a new stack of layers by stacking the original model layers according to the ranges specified. This allows expanding (or shrinking) the model without duplicating the base model weights. The new layers will all have separate LoRA adapters attached to them.
runtime_config (`LoraRuntimeConfig`):
Runtime configurations (which are not saved or restored).
The above are all the parameters of the LoraConfig class. In actual training, we generally do not set all the values but only set some important parameters we need, and keep the others as default. In the example we use, we only set the following parameters: lora_alpha=32, lora_dropout=0.1, and keep the other parameters as default. Of course, the settings given in this article do not represent the optimal choice. You can always choose some parameter combinations to try different settings to find the optimal parameter combination.
peft_config = LoraConfig(
                         lora_alpha=
32
,
                         lora_dropout=
0.1
)
2. get_peft_model() Function
The get_peft_model() function can also be directly imported from the peft library. We need to use it to load our GPT-2 model as a model that meets the specified configuration before fine-tuning. In the example of this article, we will load GPT-2 as a configured LoRA model.
Similarly, let's first look at the parameter configuration of this function:
model ([`transformers.PreTrainedModel`]):
Model to be wrapped.
peft_config ([`PeftConfig`]):
Configuration object containing the parameters of the Peft model.
adapter_name (`str`, `optional`, defaults to `"default"`):
The name of the adapter to be injected, if not provided, the default adapter name is used ("default").
mixed (`bool`, `optional`, defaults to `False`):
Whether to allow mixing different (compatible) adapter types.
autocast_adapter_dtype (`bool`, *optional*):
Whether to autocast the adapter dtype. Defaults to `True`. Right now, this will only cast adapter weights using float16 or bfloat16 to float32, as this is typically required for stable training, and only affect select PEFT tuners.
revision (`str`, `optional`, defaults to `main`):
The revision of the base model. If this isn't set, the saved peft model will load the `main` revision for the base model.
In the example, we only use the model and peft_config parameters, and keep the others as default. The model is used to pass in the GPT-2 model, and peft_config is used to receive our LoraConfig configuration.
model = get_peft_model(model, peft_config)
3. PeftModel Class
The PeftModel class is the base class of the peft library. It can initialize any model type supported by this library. We need to use the PeftModel class to load the LoRA parameters saved during fine-tuning and the original GPT-2 pre-trained model parameters into one model after completing the training, and then use the loaded model for inference testing. Similarly, let's first look at the parameter configuration of this class.
model ([`~transformers.PreTrainedModel`]): The base transformer model used for Peft.
peft_config ([`PeftConfig`]): The configuration of the Peft model.
adapter_name (`str`,  *optional*): The name of the adapter, defaults to `"default"`.
autocast_adapter_dtype (`bool`, *optional*):
Whether to autocast the adapter dtype. Defaults to `True`. Right now, this will only cast adapter weights using float16 and bfloat16 to float32, as this is typically required for stable training, and only affect select PEFT tuners.
low_cpu_mem_usage (`bool`, `optional`, defaults to `False`):
Create empty adapter weights on meta device. Useful to speed up the loading loading process.
Attributes:
- base_model ([`torch.nn.Module`]) -- The base transformer model used for Peft.
- peft_config ([`PeftConfig`]) -- The configuration of the Peft model.
- modules_to_save (`list` of `str`) -- The list of sub-module names to save when saving the model.
- prompt_encoder ([`PromptEncoder`]) -- The prompt encoder used for Peft if using [`PromptLearningConfig`].
- prompt_tokens (`torch.Tensor`) -- The virtual prompt tokens used for Peft if using [`PromptLearningConfig`].
- transformer_backbone_name (`str`) -- The name of the transformer backbone in the base model if using [`PromptLearningConfig`].
- word_embeddings (`torch.nn.Embedding`) -- The word embeddings of the transformer backbone in the base model if using [`PromptLearningConfig`].
When using the PeftModel class, we directly use its class method PeftModel.from_pretrained(model, peft_model_id) to load the model. The model is our GPT-2 model, and peft_model_id is the LoRA model parameters we fine-tuned.
model = PeftModel.from_pretrained(model, peft_model_id)
Note:
Don't use `low_cpu_mem_usage=True` when creating a new PEFT adapter for training.
LoRA-Tuning
After introducing how to configure LoRA-tuning using the `peft` library, let's complete our code example.
1. Import Necessary Libraries
There's nothing particularly noteworthy here; we directly import the libraries we need in the Python environment:
import pandas
as
pd
from
transformers import GPT2LMHeadModel, GPT2Tokenizer
from
transformers import TextDataset, DataCollatorForLanguageModeling
from
transformers import Trainer, TrainingArguments
import torch
from
peft import get_peft_model, LoraConfig, PeftModel
2. Load Data and Model Configuration
First, we check if GPU acceleration is available in the current code environment to ensure our environment configuration is correct. If you have a GPU available, but it's not being used, you should check your code environment configuration. Although the CPU can complete the task, it will be very slow.
dvc = 'cuda' if torch.cuda.is_available() else 'cpu'
print(dvc)
Next, we configure the LoRA-tuning parameters. These parameters have been introduced earlier, so we will use them directly:
model_name_or_path = 'gpt2'
peft_config = LoraConfig(
    lora_alpha=32,
    lora_dropout=0.1
)
The `model_name_or_path` is our pre-trained model. Next, we define the path to save the fine-tuned LoRA model `peft_model_id`:
peft_model_id = f
"{model_name_or_path}_{peft_config.peft_type}_{peft_config.task_type}"
Now, let's load `llm_data.csv`. We will use the last 20 closing prices of this dataset as input and compare the model's output with the remaining closing prices to validate the model's performance.
df = pd.read_csv('llm_data.csv')
Next, we need to load the preprocessed data `train.txt` (we have removed the part of the code that converts `llm_data.csv` to `train.txt` because we have already converted the data in the previous article, so there's no need to convert it again). Define the tokenizer, `train_dataset`, and `data_collator`. This part is the same as in our previous article, so we won't go into detail here. Interested readers can refer to the previous article.
tokenizer = GPT2Tokenizer.from_pretrained(model_name_or_path)
train_dataset = TextDataset(tokenizer=tokenizer, file_path=
"train.txt"
, block_size=
60
)
data_collator = DataCollatorForLanguageModeling(tokenizer=tokenizer, mlm=False)
We also need to instantiate `TrainingArguments`. Here, we have removed the `save_steps` and `save_total_limit` parameters. These parameters mainly manage the saving of checkpoints during training, but for LoRA-tuning, we only need to save the LoRA parameters, not all parameters. To avoid conflicts, we removed these two parameters and added the `save_strategy='no'` parameter, using the `save_model` method in the `Trainer` class to save the model.
training_args = TrainingArguments(
    output_dir=peft_model_id,    
    overwrite_output_dir=True,    
    num_train_epochs=3,    
    per_device_train_batch_size=32,
    save_strategy='no'
)
3. Load and Fine-Tune the Model
First, we load the pre-trained GPT-2 model as `HeadModel`:
model = GPT2LMHeadModel.from_pretrained(model_name_or_path)
Then, we need to merge the configured LoRA settings with the pre-trained GPT-2 model. This process, which was quite complex, now only requires one line of code using the `get_peft_model()` function from the `peft` library. This library has brought us significant convenience.
model = get_peft_model(model, peft_config)
Next, we instantiate the `Trainer`, perform the fine-tuning training process, and save the model. This part is no different from the code in the previous article, so we won't discuss it in detail. Interested readers can refer to the previous article.
trainer = Trainer(
    model=model,
    args=training_args,
    data_collator=data_collator,
    train_dataset=train_dataset
)
trainer.train()
trainer.save_model(peft_model_id)
One thing to note is that the model saved using `trainer.save_model(peft_model_id)` is no longer the complete model but only contains the LoRA weights. During LoRA-tuning, the pre-trained weights of GPT-2 are frozen, and only the LoRA weights are fine-tuned. Therefore, when loading the fine-tuned model, you need to use the `from_pretrained()` method in the `PeftModel` class to reload these two parts of the weights together for the model to work correctly. You can no longer use `GPT2LMHeadModel.from_pretrained()` to load the model.
After fine-tuning, the model will be saved in the `gpt2_LORA_None` folder under the directory where the training script is located (since we did not set the `task_type` parameter in the `LoraConfig` class, this option defaults to `None`, which is why the folder ends with `None`).
4. Test the Fine-Tuned Model
After fine-tuning, we need to load the fine-tuned model and perform an inference to check if the fine-tuned model works correctly. As mentioned earlier, the model fine-tuned with LoRA does not support loading with `GPT2LMHeadModel.from_pretrained()` and must use the `from_pretrained()` method in the `PeftModel` class to load the pre-trained GPT-2 model and LoRA weights together. The parameters of the `PeftModel.from_pretrained()` method have been introduced earlier, so we won't discuss them here. After loading the model, we need to set it to GPU acceleration and switch the model to inference mode.
model = GPT2LMHeadModel.from_pretrained(model_name_or_path)
model = PeftModel.from_pretrained(model, peft_model_id)
model.to(dvc)
model.eval()
Next is the inference test to see if the model works correctly. This process is the same as in the previous article. For detailed code interpretation, you can refer to the previous article. We won't discuss it here.
prompt = ' '.join(map(str, df.iloc[:, 1:20].values[-1]))
generated = tokenizer.decode(model.generate(tokenizer.encode(prompt, return_tensors='pt').to(dvc),
                                            do_sample=True,
                                            max_length=200)[0],
                                            skip_special_tokens=True)
print(f"test the model: {generated}")
The result is as follows:
test the model: 0.61163 0.61162 0.61191 0.61195 0.61209 0.61231 0.61224 0.61207 0.61187 0.61184
0.6119 0.61169 0.61168 0.61162 0.61181 0.61184 0.61184 0.6118 0.61176 0.61174 0.61175 0.61169
0.6119 0.61174 0.6116 0.61144 0.61155 0.61207 0.61192 0.61203 0.61158 0.61202 0.61158 0.61156
0.61146 0.61196 0.61144 0.656 0.61142 0.61141 0.61137 0.60952 0.611
The complete fine-tuning code script is `lora-tuning.py`.
import pandas
as
pd
from
transformers import GPT2LMHeadModel, GPT2Tokenizer
from
transformers import TextDataset, DataCollatorForLanguageModeling
from
transformers import Trainer, TrainingArguments
import torch
from
peft import get_peft_model, LoraConfig, PeftModel

dvc=
'cuda'
if
torch.cuda.is_available()
else
'cpu'
print(dvc)
model_name_or_path=
'gpt2'
peft_config = LoraConfig(
                        #  task_type=None,
                        #  inference_mode=False,
                        #  r=
8
,
                         lora_alpha=
32
,
                         lora_dropout=
0.1
,
                         )

peft_model_id = f
"{model_name_or_path}_{peft_config.peft_type}_{peft_config.task_type}"
df = pd.read_csv(
'llm_data.csv'
)

# sentences = [
' '
.
join
(map(str, prices))
for
prices
in
df.iloc[:-
10
,
1
:].values]
# with open(
'train.txt'
,
'w'
)
as
f:
#
for
sentence
in
sentences:
#         f.write(sentence +
'\n'
)

tokenizer = GPT2Tokenizer.from_pretrained(model_name_or_path)
train_dataset = TextDataset(tokenizer=tokenizer,
                            file_path=
"train.txt"
,
                            block_size=
60
)

data_collator = DataCollatorForLanguageModeling(tokenizer=tokenizer, mlm=False)
training_args = TrainingArguments(output_dir=peft_model_id,    
                                  overwrite_output_dir=True,    
                                  num_train_epochs=
3
,    
                                  per_device_train_batch_size=
32
,
                                  save_strategy=
'no'
,  
                                #   save_steps=
10
_000,    
                                #   save_total_limit=
2
,
                                #   load_best_model_at_end=True,
                                  )

model = GPT2LMHeadModel.from_pretrained(model_name_or_path)
model = get_peft_model(model, peft_config)

trainer = Trainer(model=model,
                  args=training_args,
                  data_collator=data_collator,
                  train_dataset=train_dataset,)

trainer.train()

# model.save_pretrained(peft_model_id)
trainer.save_model(peft_model_id)

# config = PeftConfig.from_pretrained(peft_model_id)
model = GPT2LMHeadModel.from_pretrained(model_name_or_path)
model = PeftModel.from_pretrained(model, peft_model_id)
model.to(dvc)
model.eval()

prompt =
' '
.
join
(map(str, df.iloc[:,
1
:
20
].values[-
1
]))
generated = tokenizer.decode(model.generate(tokenizer.encode(prompt, return_tensors=
'pt'
).to(dvc),
                                            do_sample=True,
                                            max_length=
200
)[
0
],
                                            skip_special_tokens=True)

print(f
"test the model:{generated}"
)
The data files will be attached at the end, with the original data file being `llm_data.csv` and the preprocessed data file being `train.txt`.
Comparison of Different Fine-Tuning Methods
After experimenting with various fine-tuning methods, we obtained new GPT-2 models with different performances. This necessitates a comparison of the results and training speeds of different methods to scientifically select the most suitable method for our EA strategy. Since the GPT-2 pre-trained model cannot recognize our input, we do not need to include the pre-trained model in the comparison sequence. Therefore, we only introduce full-parameter fine-tuning and LoRA-tuning for comparison. Of course, in subsequent articles, I will continue to introduce several different methods, so we will have more choices.
1. Efficiency Comparison
First, we need to compare the cost of training. We prefer methods with high training efficiency and low cost. Here, we compare training time, memory usage, and inference speed. Although the differences may not be significant in a small-parameter model like GPT-2, they become very noticeable when choosing larger models (e.g., 7B, 13B, 34B, or larger).
Train_runtime(s)
VRAM(GB)
Generate_runtime(s)
LoRA-Tuning Process
69.5605
4.1
1.242877
Full-Parameter Fine-Tuning Process
101.7946
5.67
0.876525
2. Accuracy Comparison
In terms of accuracy, we temporarily compare the models obtained by different fine-tuning methods using MSE (Mean Squared Error), RMSE (Root Mean Squared Error), and NRMSE (Normalized Root Mean Squared Error). Other metrics (such as perplexity, robustness, etc.) are not evaluated for now.
Next, we load the closing prices of the last 20 rows of the original data as input and use the remaining data as the result to evaluate the models obtained by the two training methods.
Input Data: [0.61163, 0.61162, 0.61191, 0.61195, 0.61209, 0.61231, 0.61224, 0.61207, 0.61187, 0.61184, 0.6119, 0.61169, 0.61168, 0.61162, 0.61181, 0.61184, 0.61184, 0.6118, 0.61176]
True Prices: [0.6119, 0.61197, 0.61201, 0.61242, 0.61237, 0.6123, 0.61229, 0.61242, 0.61212, 0.61197, 0.61201, 0.61213, 0.61212, 0.61206, 0.61203, 0.61206, 0.6119, 0.61193, 0.61191, 0.61202, 0.61197, 0.6121, 0.61211, 0.61214, 0.61203, 0.61203, 0.61213, 0.61218, 0.61227, 0.61226]
Next, we load the models (the full-parameter fine-tuned model is saved in the gpt2_stock folder in the current directory, and the LoRA fine-tuned model is saved in the gpt2_LORA_None folder in the current directory) and run inference. We calculate their MSE, RMSE, and NRMSE based on the results. These codes were introduced in the previous article, so they are not described in detail here.
import time
import pandas
as
pd
from
transformers import GPT2LMHeadModel, GPT2Tokenizer, GPT2Config
from
sklearn.metrics import mean_squared_error
import torch
import numpy
as
np
from
peft import PeftModel
import matplotlib.pyplot
as
plt

# Load dataset
df = pd.read_csv(
'llm_data.csv'
)

# Set device (GPU or CPU)
dvc =
'cuda'
if
torch.cuda.is_available()
else
'cpu'
# Define model paths
base_model =
'gpt2'
fine_tuning_path =
'./gpt2_stock'
lora_tuning_path =
'./gpt2_LORA_None'
# Initialize tokenizer and models
tokenizer = GPT2Tokenizer.from_pretrained(base_model)
model_fine_tuning = GPT2LMHeadModel.from_pretrained(fine_tuning_path).to(dvc)
model_lora_tuning = GPT2LMHeadModel.from_pretrained(base_model)
model_lora_tuning = PeftModel.from_pretrained(model_lora_tuning, lora_tuning_path).to(dvc)

# Extract input data and
true
prices
input_data = df.iloc[:,
1
:
20
].values[-
1
]
true_prices = df.iloc[-
1
:,
21
:].values.tolist()[
0
]

# Prepare prompt
prompt =
' '
.
join
(map(str, input_data))
We encapsulate the process of inference and calculation of MSE, RMSE, and NRMSE into a function 'generater(model)', and use the predicted value, MSE, RMSE, and NRMSE as the return values. When we use different models for inference evaluation, we just pass the model in as a parameter. It should be noted here that the true_prices used in our function is a global variable, and we need to modify its value in the function, so we should declare it as a global variable in the function, and otherwise an error will be reported.
def generater(model):
    global true_prices
    
    # Set the model to evaluation mode
    model.eval()
    
    # Tokenization and text generation
using
the model
    token = tokenizer.encode(prompt, return_tensors=
'pt'
).to(dvc)
    start_ = time.time()
    generated = tokenizer.decode(
        model.generate(token, do_sample=True, max_length=
200
)[
0
],
        skip_special_tokens=True
    )
    end_ = time.time()
    
    print(f
'Generate time: {end_ - start_} seconds'
)
    
    # Process the generated data
    generated_prices = generated.split(
'\n'
)[
0
]
    generated_prices = list(map(
float
, generated_prices.split()))
    generated_prices = generated_prices[:len(true_prices)]
    
    # Function to trim both lists to the same length
    def trim_lists(a, b):
        min_len = min(len(a), len(b))
return
a[:min_len], b[:min_len]
    
    # Trim the true_prices and generated_prices lists
    true_prices, generated_prices = trim_lists(true_prices, generated_prices)
    
    print(f
"Input data: {input_data}"
)
    print(f
"True prices: {true_prices}"
)
    print(f
"Generated prices: {generated_prices}"
)
    
    # Calculate MSE, RMSE, NRMSE metrics
    mse = mean_squared_error(true_prices, generated_prices)
    print(
'MSE:'
, mse)
    
    rmse = np.sqrt(mse)
    nrmse = rmse / (np.max(true_prices) - np.min(generated_prices))
    
    print(f
"RMSE: {rmse}, NRMSE: {nrmse}"
)
return
generated_prices, mse, rmse, nrmse
def generater(model):
    global true_prices
    
    # Set the model to evaluation mode
    model.eval()
    
    # Tokenization and text generation
using
the model
    token = tokenizer.encode(prompt, return_tensors=
'pt'
).to(dvc)
    start_ = time.time()
    generated = tokenizer.decode(
        model.generate(token, do_sample=True, max_length=
200
)[
0
],
        skip_special_tokens=True
    )
    end_ = time.time()
    
    print(f
'Generate time: {end_ - start_} seconds'
)
    
    # Process the generated data
    generated_prices = generated.split(
'\n'
)[
0
]
    generated_prices = list(map(
float
, generated_prices.split()))
    generated_prices = generated_prices[:len(true_prices)]
    
    # Function to trim both lists to the same length
    def trim_lists(a, b):
        min_len = min(len(a), len(b))
return
a[:min_len], b[:min_len]
    
    # Trim the true_prices and generated_prices lists
    true_prices, generated_prices = trim_lists(true_prices, generated_prices)
    
    print(f
"Input data: {input_data}"
)
    print(f
"True prices: {true_prices}"
)
    print(f
"Generated prices: {generated_prices}"
)
    
    # Calculate MSE, RMSE, NRMSE metrics
    mse = mean_squared_error(true_prices, generated_prices)
    print(
'MSE:'
, mse)
    
    rmse = np.sqrt(mse)
    nrmse = rmse / (np.max(true_prices) - np.min(generated_prices))
    
    print(f
"RMSE: {rmse}, NRMSE: {nrmse}"
)
return
generated_prices, mse, rmse, nrmse
Let's encapsulate the visualization of the inference result into a function 'plot_(a, b, title)':
def plot_(a, b, title):
    # Set up the figure size
    plt.figure(figsize=(
10
,
6
))
    
    # Plot true_prices only
if
the title
is
'prediction'
if
title ==
'prediction'
:
        plt.plot(true_prices, label=
'True Values'
, marker=
'o'
)
    
    # Plot the fine-tuning and lora-tuning values
    plt.plot(a, label=
'fine_tuning'
, marker=
'x'
)
    plt.plot(b, label=
'lora_tuning'
, marker=
's'
)
    
    # Set the title and labels
for
the axes
    plt.title(title)
    plt.xlabel(
'Index'
)
    plt.ylabel(
'Value'
)
    
    # Display the legend and save the plot to a file
    plt.legend()
    plt.savefig(f
"{title}.png"
)
Encapsulate the efficiency of the model and the evaluation metrics we mentioned earlier into a function 'groups_chart(a, b, models)':
def groups_chart(a, b, models):
    # Define metrics
for
the chart
    metrics = ['Train Time(s)', 'Inference Time (s)', 'Memory Usage (GB)', 'MSE', 'RMSE', 'NRMSE']
    
    # Set figure size
    plt.figure(figsize=(
10
,
6
))
    
    # Update values
for
model a and b
    a = [
101.7946
,
1.243
,
5.67
, a[
1
], a[
2
], a[
3
]]
    b = [
69.5605
,
0.877
,
4.10
, b[
1
], b[
2
], b[
3
]]
    
    # Bar width
for
each group of bars
    bar_width =
0.2
# Set the positions of the bars
    r1 = np.arange(len(metrics))  # Positions
for
model a
    r2 = [x + bar_width
for
x in r1]  # Positions
for
model b
    
    # Plot bars
for
both models
    plt.bar(r1, a,
color
='r', width=bar_width, edgecolor='grey', label=models[
0
])
    plt.bar(r2, b,
color
='b', width=bar_width, edgecolor='grey', label=models[
1
])
    
    # Set
log
scale
for
y-axis
    plt.yscale('
log
')
    
    # Set labels and title
    plt.xlabel('Metrics', fontweight='bold')
    plt.xticks([r + bar_width /
2
for
r in range(len(metrics))], metrics)  # Center the x-axis ticks
    plt.ylabel('Values (
log
scale)', fontweight='bold')
    plt.title('Model Comparison')
    
    # Display legend and save the plot
    plt.legend()
    # plt.show()  # Uncomment to display the plot
    plt.savefig('Comparison.png')
Note:
The problem here is that the magnitude of the metrics we measure is not the same, so here I use a logarithmic scale :plt.yscale('log'). In this way, it is possible to effectively handle situations where the amount of data varies greatly.
Different models run inference separately:
fine_tuning_result = generater(model_fine_tuning)
lora_tuning_result = generater(model_lora_tuning)
The inference results of the full-parameter fine-tuning model:
generated prices:[0.61163, 0.61162, 0.61191, 0.61195, 0.61209, 0.61231, 0.61224, 0.61207, 0.61187, 0.61184, 0.6119, 0.61169, 0.61168, 0.61162, 0.61181, 0.61184, 0.61184, 0.6118, 0.61176, 0.61183, 0.61185, 0.61217, 0.61221, 0.61223, 0.61226, 0.61231, 0.61231, 0.61229, 0.61235, 0.61237, 0.61241, 0.61243, 0.61248, 0.61253, 0.61263, 0.61265, 0.61267, 0.61271, 0.61267, 0.61272]
MSE: 1.0064750000000609e-07
RMSE:0.0003172499014972362
NRMSE:0.3965623768715889
LoRA-tuning model inference results:
generated prices:[0.61163, 0.61162, 0.61191, 0.61195, 0.61209, 0.61231, 0.61224, 0.61207, 0.61187, 0.61184, 0.6119, 0.61169, 0.61168, 0.61162, 0.61181, 0.61184, 0.61184, 0.6118, 0.61176, 0.6116, 0.6116, 0.61194, 0.6118, 0.61195, 0.61197, 0.61196, 0.6123, 0.61181, 0.61172, 0.6119, 0.61155, 0.61149, 0.61197, 0.61198, 0.61192, 0.61136, 0.61092, 0.61091, 0.61098, 0.61099]
MSE: 2.3278249999999242e-07
RMSE:0.00048247538797330626
NRMSE:0.3195201244856309
Visualize the results and save them as images:
plot_(fine_tuning_result[0],lora_tuning_result[0],title='predication')
groups_chart(fine_tuning_result,lora_tuning_result,models=['fine-tuning','lora-tuning'])
Chart visualization for comparison:
Note:
I have run the script many times to test, and the results of each run will be different, so the data and charts I give are for reference only, and it is normal for your running results to be different from mine.
3. Choosing the Right Model
From an efficiency standpoint, it is clear that LoRA-tuning is superior in terms of training speed, inference speed, and memory usage compared to full-parameter fine-tuning. Next, we compare inference accuracy. From our charts, From our chart, it can be intuitively seen that the output of the two models is almost the same in the first 18 predicted values, while the error gradually increases for the remaining values. The full-parameter fine-tuned model's predictions are relatively stable overall, as evidenced by the NRMSE values.
I attempted to run the test.py script multiple times to see if the results were consistent. The results varied, with the NRMSE of the LoRA fine-tuned model sometimes being small (around 0.17, much lower than the full-parameter fine-tuned NRMSE) and sometimes huge (up to 0.76688). The full-parameter fine-tuned NRMSE remained stable around 0.4. It is important to note that these data do not necessarily mean that the full-parameter fine-tuned model performs better than the LoRA fine-tuned model. It is possible that the LoRA-tuning did not converge with the same training settings as the full-parameter fine-tuning. A better solution is to configure an appropriate early stopping logic based on the loss during training to ensure model convergence. This part of the content is not provided in the code example for now, but interested readers can implement it themselves.
Of course, different model parameter settings may also affect model performance. Therefore, a more scientific approach should be to first find the optimal parameter settings for a model or training method on the same dataset and ensure that the model converges under the optimal settings. Then, perform a horizontal comparison of different training methods or models, comprehensively evaluate various metrics, and select the optimal training method or model.
The complete test code script is `test.py`:
import time
import pandas
as
pd
from
transformers import GPT2LMHeadModel, GPT2Tokenizer, GPT2Config
from
sklearn.metrics import mean_squared_error
import torch
import numpy
as
np
from
peft import PeftModel
import matplotlib.pyplot
as
plt

# Load the dataset
df = pd.read_csv(
'llm_data.csv'
)

# Define the device (GPU
if
available)
dvc =
'cuda'
if
torch.cuda.is_available()
else
'cpu'
# Model paths and
base
settings
base_model =
'gpt2'
fine_tuning_path =
'./gpt2_stock'
lora_tuning_path =
'./gpt2_LORA_None'
# Load the tokenizer and models
tokenizer = GPT2Tokenizer.from_pretrained(base_model)
model_fine_tuning = GPT2LMHeadModel.from_pretrained(fine_tuning_path).to(dvc)
model_lora_tuning = GPT2LMHeadModel.from_pretrained(base_model)
model_lora_tuning = PeftModel.from_pretrained(model_lora_tuning, lora_tuning_path).to(dvc)

# Extract the input data and
true
prices
from
the dataset
input_data = df.iloc[:,
1
:
20
].values[-
1
]
true_prices = df.iloc[-
1
:,
21
:].values.tolist()[
0
]
prompt =
' '
.
join
(map(str, input_data))

# Function to generate predictions
def generater(model):
    global true_prices
    model.eval()
    
    # Tokenization and text generation
    token = tokenizer.encode(prompt, return_tensors=
'pt'
).to(dvc)
    start_ = time.time()
    generated = tokenizer.decode(
        model.generate(token, do_sample=True, max_length=
200
)[
0
],
        skip_special_tokens=True
    )
    end_ = time.time()
    
    print(f
'Generate time: {end_ - start_}'
)
    
    # Processing generated prices
    generated_prices = generated.split(
'\n'
)[
0
]
    generated_prices = list(map(
float
, generated_prices.split()))
    generated_prices = generated_prices[:len(true_prices)]
    
    # Function to trim lists to the same length
    def trim_lists(a, b):
        min_len = min(len(a), len(b))
return
a[:min_len], b[:min_len]
    
    # Trim the
true
prices and generated prices
    true_prices, generated_prices = trim_lists(true_prices, generated_prices)
    
    # Output metrics
    print(f
"Input data: {input_data}"
)
    print(f
"True prices: {true_prices}"
)
    print(f
"Generated prices: {generated_prices}"
)
    
    mse = mean_squared_error(true_prices, generated_prices)
    print(
'MSE:'
, mse)
    
    rmse = np.sqrt(mse)
    nrmse = rmse / (np.max(true_prices) - np.min(generated_prices))
    
    print(f
"RMSE: {rmse}, NRMSE: {nrmse}"
)
return
generated_prices, mse, rmse, nrmse

# Function to plot the comparison between
true
prices and predictions
def plot_(a, b, title):
    plt.figure(figsize=(
10
,
6
))
if
title ==
'prediction'
:
        plt.plot(true_prices, label=
'True Values'
, marker=
'o'
)
    
    plt.plot(a, label=
'fine_tuning'
, marker=
'x'
)
    plt.plot(b, label=
'lora_tuning'
, marker=
's'
)
    
    plt.title(title)
    plt.xlabel(
'Index'
)
    plt.ylabel(
'Value'
)
    plt.legend()
    plt.savefig(f
"{title}.png"
)

# Function to generate a bar chart comparing different metrics between models
def groups_chart(a, b, models):
    metrics = [
'Train Time(s)'
,
'Inference Time (s)'
,
'Memory Usage (GB)'
,
'MSE'
,
'RMSE'
,
'NRMSE'
]
    plt.figure(figsize=(
10
,
6
))
    
    # Data
for
the metrics
    a = [
101.7946
,
1.243
,
5.67
, a[
1
], a[
2
], a[
3
]]
    b = [
69.5605
,
0.877
,
4.10
, b[
1
], b[
2
], b[
3
]]
    
    bar_width =
0.2
r1 = np.arange(len(metrics))
    r2 = [x + bar_width
for
x
in
r1]
    
    # Plotting bars
for
both models
    plt.bar(r1, a, color=
'r'
, width=bar_width, edgecolor=
'grey'
, label=models[
0
])
    plt.bar(r2, b, color=
'b'
, width=bar_width, edgecolor=
'grey'
, label=models[
1
])
    
    # Set y-axis to log scale
for
better visibility of differences
    plt.yscale(
'log'
)
    
    plt.xlabel(
'Metrics'
, fontweight=
'bold'
)
    plt.xticks([r + bar_width
for
r
in
range(len(metrics))], metrics)
    plt.ylabel(
'Values (log scale)'
, fontweight=
'bold'
)
    plt.title(
'Model Comparison'
)
    plt.legend()
    plt.savefig(
'Comparison.png'
)

# Generate results
for
both fine-tuned and LORA-tuned models
fine_tuning_result = generater(model_fine_tuning)
lora_tuning_result = generater(model_lora_tuning)

# Plot the prediction comparison
plot_(fine_tuning_result[
0
], lora_tuning_result[
0
], title=
'prediction'
)

# Generate the comparison chart
for
the models
groups_chart(fine_tuning_result, lora_tuning_result, models=[
'fine-tuning'
,
'lora-tuning'
])
Conclusion
In this article, we discussed how to fine-tune the GPT-2 pre-trained model using the LoRA-tuning method and compared the fine-tuning methods we introduced. This allows us to intuitively choose the training method and model that best suits our trading strategy. Of course, we will continue to discuss more fine-tuning methods and use these methods to fine-tune the GPT-2 pre-trained model to seek more accurate fine-tuning methods for our trading strategy. Considering the parameter scale of the GPT-2 pre-trained model, the final result may differ significantly from the ideal result, but the process of seeking the final result is the same. You might wonder why not consider horizontal comparisons of different models? This is a good question, but there are so many models to choose from, and even the same model can have different parameter scales. It is clear that we cannot complete this task with a few simple examples. This is a very tedious but not complex process, so my suggestion is to explore how to seek the best results among different models based on the method examples in the article.
Are you ready to continue exploring? See you in the next article!
Attached files
|
Download ZIP
llm_data.csv
(1139.04 KB)
train.txt
(1123.41 KB)
lora-tuning.py
(2.64 KB)
test.py
(3.23 KB)
Warning:
All rights to these materials are reserved by MetaQuotes Ltd. Copying or reprinting of these materials in whole or in part is prohibited.
Other articles by this author
Integrate Your Own LLM into EA (Part 5): Develop and Test Trading Strategy with LLMs(I)-Fine-tuning
Integrate Your Own LLM into EA (Part 4): Training Your Own LLM with GPU
Integrate Your Own LLM into EA (Part 3): Training Your Own LLM with CPU
Data label for time series mining (Part 6)：Apply and Test in EA Using ONNX
Data label for time series mining (Part 5)：Apply and Test in EA Using Socket
Data label for time series mining (Part 4)：Interpretability Decomposition Using Label Data
Go to discussion
Data Science and ML (Part 31): Using CatBoost AI Models for Trading
CatBoost AI models have gained massive popularity recently among machine learning communities due to their predictive accuracy, efficiency, and robustness to scattered and difficult datasets. In this article, we are going to discuss in detail how to implement these types of models in an attempt to beat the forex market.
Matrix Factorization: A more practical modeling
You might not have noticed that the matrix modeling was a little strange, since only columns were specified, not rows and columns. This looks very strange when reading the code that performs matrix factorizations. If you were expecting to see the rows and columns listed, you might get confused when trying to factorize. Moreover, this matrix modeling method is not the best. This is because when we model matrices in this way, we encounter some limitations that force us to use other methods or functions that would not be necessary if the modeling were done in a more appropriate way.
Developing a Replay System (Part 47): Chart Trade Project (VI)
Finally, our Chart Trade indicator starts interacting with the EA, allowing information to be transferred interactively. Therefore, in this article, we will improve the indicator, making it functional enough to be used together with any EA. This will allow us to access the Chart Trade indicator and work with it as if it were actually connected with an EA. But we will do it in a much more interesting way than before.
MQL5 Wizard Techniques you should know (Part 42): ADX Oscillator
The ADX is another relatively popular technical indicator used by some traders to gauge the strength of a prevalent trend. Acting as a combination of two other indicators, it presents as an oscillator whose patterns we explore in this article with the help of MQL5 wizard assembly and its support classes.
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