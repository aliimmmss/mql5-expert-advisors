# Integrate Your Own LLM into EA (Part 5): Develop and Test Trading Strategy with LLMs(IV) — Test Trading Strategy

**Source:** [https://www.mql5.com/en/articles/13506](https://www.mql5.com/en/articles/13506)

---

Integrate Your Own LLM into EA (Part 5): Develop and Test Trading Strategy with LLMs(IV) — Test Trading Strategy
MetaTrader 5
—
Trading
| 29 January 2025, 13:33
832
1
Yuqiang Pan
Table of contents
Table of contents
Introduction
Development Environment for the Example in This Article
Methods for Loading LLMs in MQL5
Converting the GPT-2 Model to ONNX Model
Formulating EA Strategy and Server Functionality
Creating the Inference Service
EA Client
Backtesting
Conclusion
Introduction
In previous articles, we introduced how to fine-tune pre-trained GPT-2 models using different methods to make GPT-2 perform tasks according to our wishes, and we compared these methods across several dimensions. Of course, we only introduced several commonly used methods, which does not mean that only these methods can be used to fine-tune GPT-2 models. You can try to fine-tune GPT-2 using other methods based on our example implementation process, compare them, and choose a better model. If you encounter any issues during this process, you can leave a comment at the end of the article.
Now, our fine-tuned GPT-2 model has the initial capability to execute simple quantitative trading strategies. Therefore, this article will introduce how to integrate our fine-tuned model into our quantitative trading strategy. The model used in the example is the GPT-2 model fine-tuned with Adapter-tuning (specific article link:
Integrate Your Own LLM into EA (Part 5): Develop and Test Trading Strategy with LLMs (III) – Adapter-Tuning
). So, unless otherwise specified, all references to GPT-2 in this article refer to this model.
However, it should be noted that the model we fine-tuned is based on limited data for demonstration purposes and cannot handle real trading environments. Without testing and optimization, do not use them directly in real trading, which is of utmost importance. Our previous prediction code was completed in the Python environment, but MQL5, as a highly integrated programming language for the MetaTrader 5 platform, provides powerful tools to develop Expert Advisors (EAs). Therefore, to implement automated quantitative trading strategies, we need to return to the MQL5 environment. This article will step-by-step achieve this process.
Let's see how to migrate this trained model from the Python environment to the MQL5 EA, making it run directly on the MetaTrader 5 platform to support real-time trading decisions.
Development Environment for the Example in This Article
Let's introduce the running environment for the code examples provided in this article. Of course, this does not mean that your code environment must be the same as mine, but if you encounter issues while running the code, you can refer to my environment configuration.
Operating System
: Ubuntu 22.04.5 LTS (or the corresponding version of WSL)
Python Version
: 3.10.14
Required Python Libraries
:
torch-2.4.1
numpy-1.26.3
pandas-2.2.3
transformers-4.45.1
petf-0.13.0
matplotlib-3.9.2
onnx-1.17.0
onnxconverter-common-1.14.0
onnxruntime-1.20.1
onnxruntime-tools-1.7.0
Please note that before proceeding to the next step, ensure that you have trained a model using Adapter-tuning as described in the previous article (because the size of the model exceeds the platform limit, the weights that I have already trained cannot be uploaded).
Methods for Loading LLMs in MQL5
To integrate the trained GPT-2 model into the MQL5 EA, the first problem we need to solve is how to load and run this model, which is essentially a Python-trained model, in the MQL5 environment. Here are several feasible methods:
1. Convert the model to ONNX and add it to the EA
ONNX (Open Neural Network Exchange) is an open format for representing neural networks, allowing interoperability between different deep learning frameworks. In my previous article, I introduced how to integrate simple models into EAs using ONNX (
Data label for time series mining (Part 6): Apply and Test in EA Using ONNX
). We can also convert the GPT-2 model to ONNX format, import it into the EA, and use the built-in ONNX runtime library in MQL5 to execute model inference. For MQL5 support of ONNX, refer to the help file "MQL5 Reference / ONNX models" or the MQL5 official documentation (
https://www.mql5.com/en/docs/onnx
).
Advantages:
High performance: ONNX runtime is usually optimized for performance, enabling relatively efficient inference in the EA.
High integration: MQL5 has built-in support for ONNX, eliminating the need for external programs or libraries.
Independence: The converted ONNX model can run independently of the Python environment.
Disadvantages:
Complexity of conversion: Converting complex language models to ONNX format can be challenging, requiring handling of operator compatibility issues.
Debugging difficulty: Debugging ONNX models is less convenient than debugging Python models.
2. Directly run Python inference scripts using Winapi
MQL5 provides access to Winapi, allowing us to call the `WinExec()` function from "kernel32.dll" to execute external programs. This way, we can use existing Python scripts to load the GPT-2 model and perform inference, and then call the script in the EA using `WinExec()` and parse its output results (alternatively, the `ShellExecuteW()` function from `shell32.dll` can also achieve this functionality). This method requires some development experience and familiarity with Windows development to implement.
Advantages:
Simple and direct: No need to convert the model, directly utilizing existing Python code.
Flexibility: Can easily use the rich libraries and tools in the Python ecosystem.
Disadvantages:
Performance overhead: Each inference requires starting a new Python process, resulting in significant performance overhead and inefficiency.
Dependency: The EA depends on the external Python environment and scripts.
Data exchange: Requires handling data exchange between MQL5 and Python, increasing complexity.
Security: Various unexpected situations may occur, potentially causing uncontrollable crashes.
Note:
This method is extremely not recommended! I provide this solution only to indicate that it is feasible and can be used in testing or under controlled conditions. Do not use it without sufficient confidence.
3. Obtain Python inference results through Socket communication
Similar to the second method, but using Socket communication instead of Winapi (actually, HTTP protocol can also be used, similar to the HTTP services provided by mainstream inference frameworks, which are essentially the same as Socket, and this article will not discuss it further). The specific implementation method is to run a Socket server in Python to load the model and perform inference, with the EA acting as the client connecting to the server, sending input data, and receiving inference results.
Advantages:
Better performance: Socket communication can reduce the overhead of process startup and is much safer.
Flexibility: Still can leverage the advantages of Python.
Disadvantages:
Complexity: Need to implement the communication logic between the Socket server and client.
Dependency: The EA depends on the external Python environment and Socket server, requiring some knowledge to set up the service.
Stability: The stability of Socket connections may affect the operation of the EA.
Note:
This method has a specific implementation in my previous article. If you are interested, you can refer to the article:
Data label for time series mining (Part 5): Apply and Test in EA Using Socket
.
We have discussed several different conversion methods. Currently, I still tend to choose to convert the GPT-2 model to ONNX format and integrate it into the EA because this can also solve cross-platform issues and the EA has higher integration and stability. However, if the ONNX model parameters are too large, they cannot be run in MQL5 (for example, our current GPT-2 model exceeds the MQL5 file loading limit).
Another challenging issue is to solve the tokenizer problem in the transformers model, as models like GPT-2 come with a tokenizer to handle input information, and to run the GPT-2 model in MQL5, we must build the GPT-2 tokenizer in MQL5, which is a significant project. This is difficult, but not impossible. However, the MQL5 file size loading limit is a difficult problem to solve.
Although I tried to quantize it to INT8 format, it still exceeded the limit and could not be loaded. If quantized to INT4 format, although the model size meets the requirements, MQL5 does not support INT4 format quantized models! Therefore, we can only regretfully abandon this method. However, I will still provide an example of how to convert our Adapter-tuned GPT-2 model to ONNX format in this article, hoping to solve this problem soon!
In this article, I ultimately decided to discuss using Socket communication with the Python inference service. The advantage of this method is that it can ensure data security and simplify our EA implementation. In the EA, we only need to focus on our strategy and trading logic, and do not need to consider additional module integration issues. Another advantage of this method is that if there is no relevant model development environment locally, such as the model being developed and trained on a remote device, even if the development environment is incompatible with the local environment, this method can still be used to develop the EA.
Overall, although this method may seem technically complex to implement and may require more knowledge, it can achieve high operational efficiency and ensure the independence of the EA, which is crucial for the efficient real-time trading environment. Given that we have already discussed this in detail in a previous article, this article will not describe the details further. If you have any questions about the code examples, you can refer to the detailed introduction in the previous article.
Converting the GPT-2 Model to ONNX Model
In the previous section, I described the various challenges encountered when converting the fine-tuned GPT-2 model to ONNX format and using it in MQL5. However, I still believe this is a direction worth trying, so in this article, I will use an additional section to introduce how to convert this personalized fine-tuned model to ONNX format, hoping that everyone can find a solution to the current plight. If you are not interested in this part, you can skip this section.
1. Model Conversion Methods
Ⅰ. Direct Conversion (
https://github.com/rayhern/convert-gpt2-xl-to-onnx
)
This GitHub repository provides a script for directly converting GPT-2 models, based on Hugging Face's `transformers` library and `torch.onnx` exporter. However, due to the author's long-term lack of maintenance, it may have some limitations and may not be compatible with the latest `transformers` library versions.
Advantages:
Provides a relatively simple script that can be used directly; optimized specifically for GPT-2 model conversion.
Disadvantages:
The maintenance status of this repository may be unclear, and it may not be compatible with the latest `transformers` versions and only applicable to specific versions of GPT-2 models.
Ⅱ. Microsoft's ONNX API (
https://github.com/microsoft/onnxruntime-genai
)
Microsoft's `onnxruntime-genai` library provides a set of ONNX conversion and optimization APIs for generative AI models.
Advantages:
Optimized for ONNX runtime, improving inference performance, and supported and maintained by Microsoft.
Disadvantages:
Need to learn the `onnxruntime-genai` library's API, which may be more complex compared to other methods.
Ⅲ. Using `torch.onnx` to Export the Model
PyTorch provides built-in ONNX export functionality (`torch.onnx`), which can export PyTorch models to ONNX format.
Advantages:
Closely integrated with the PyTorch framework, easy to use, `torch.onnx` is a widely used ONNX export tool.
Disadvantages:
May need to handle some operator compatibility issues, especially for newer or custom operators, and may need to manually adjust some export parameters to ensure model correctness and performance.
Ⅳ. Using `transformers.onnx` to Convert the Model
Hugging Face's `transformers` library provides its own ONNX conversion tool (`transformers.onnx`), which can easily convert models from the `transformers` library to ONNX format.
Advantages:
Simple and easy to use, provides a simple command-line interface to easily convert models, closely integrated with the `transformers` library, supports multiple pre-trained models, and actively maintained and updated by the Hugging Face team.
Disadvantages:
Compared to `torch.onnx`, `transformers.onnx` is a relatively new tool and may have compatibility issues.
Ⅴ. Using Optimum
Optimum is a tool library launched by Hugging Face for model optimization and acceleration, which also provides ONNX conversion functionality.
Advantages:
Optimized integration, can combine ONNX conversion with other optimization techniques (such as quantization, pruning), and supported and maintained by the Hugging Face team.
Disadvantages:
Need to learn the usage of the Optimum library, requiring some technical foundation.
These conversion methods have their own advantages and disadvantages. You do not have to be limited to the method used in this article, and can choose a suitable method based on your needs. Our example will use the `transformers.onnx` library to convert the GPT-2 model.
2. Converting the GPT-2 Model to ONNX Model
After determining to use `transformers.onnx` for model conversion, we will now provide a detailed conversion process.
Ⅰ. Install Dependencies
First, ensure that the `transformers` library and `onnx` library are installed. If not installed, you can use the following command to install them:
pip install transformers onnx
If you need to optimize for specific hardware, such as using GPU acceleration, you also need to install `onnxruntime-gpu`:
pip install onnxruntime-gpu
Ⅱ. Conversion Command
`transformers.onnx` provides a simple command-line tool. Without special requirements, using this tool for model conversion is simple, just run the following command:
python -m transformers.onnx --model=path/to/your/tuned_model --feature=causal-lm-with-past path/to/save/onnx_model
The parameters in this command:
`python -m transformers.onnx`: Call the `transformers.onnx` tool.
`--model=path/to/your/tuned_model`: Specify the path of the fine-tuned GPT-2 model. In our example, this path is `gpt2_Adapter-tuning`.
`--feature=causal-lm-with-past`: Specify the type of model functionality. Since we are using a causal language model and need to support `past_key_values` to improve generation efficiency, we choose `causal-lm-with-past`.
`path/to/save/onnx_model`: Specify the path to save the ONNX model. For example, we can set it to `gpt2_onnx`.
Complete example command:
python -m transformers.onnx --model=gpt2_Adapter-tuning --feature=causal-lm-with-past gpt2_onnx
Run the above command in the command line, `transformers.onnx` will automatically download the necessary configuration files and convert the model to ONNX format. After the conversion is complete, you will see a file named `model.onnx` in the specified output directory (`gpt2_onnx` in this case), along with some possible JSON files such as `config.json`.
However, if you need to adjust some settings during the model conversion process to better suit the current use case, this tool clearly cannot meet our needs. Therefore, for complex application scenarios, it is still necessary to write appropriate scripts for conversion to have more precise control over the exported model form.
Ⅲ. Conversion Script
To convert the GPT-2 model fine-tuned with Adapter-Tuning, the conversion process needs to load the Adapter module and settings, and also set the ONNX OP version to avoid compatibility issues. Next, we will implement the relevant functions step by step according to our needs.
First, we import the required Python libraries and the Adapter() and GPT2LMHeadModelWithAdapters() classes. These classes were introduced in detail in the previous article (
Integrate Your Own LLM into EA (Part 5): Develop and Test Trading Strategy with LLMs (III) – Adapter-Tuning
). You can choose to directly import from the existing script, and here we copy these classes to the conversion script for better understanding:
import
os
import
logging
from
pathlib
import
Path
from
transformers.onnx
import
export, FeaturesManager
from
transformers
import
AutoConfig, AutoTokenizer, GPT2LMHeadModel, modeling_outputs
from
torch
import
nn
import
torch.nn.functional
as
F
import
onnx
# Set up basic configuration for logging
logging.basicConfig(level=logging.INFO)
tokenizer = AutoTokenizer.from_pretrained(
'gpt2'
)
# Define the Adapter class, which is a simple feed-forward network with dropout
class
Adapter(nn.Module):
def
__init__(self, in_features, bottleneck_features=
64
):
super
(Adapter, self).__init__()
# Down projection layer
self.down_project = nn.Linear(in_features, bottleneck_features)
# Up projection layer
self.up_project = nn.Linear(bottleneck_features, in_features)
# Dropout layer for regularization
self.dropout = nn.Dropout(
0.1
)
# Initialize weights of the layers
self.init_weights()
def
init_weights(self):
# Initialize weights for down projection layer
nn.init.normal_(self.down_project.weight, mean=
0.0
, std=
0.02
)
        nn.init.constant_(self.down_project.bias,
0
)
# Initialize weights for up projection layer
nn.init.normal_(self.up_project.weight, mean=
0.0
, std=
0.02
)
        nn.init.constant_(self.up_project.bias,
0
)
def
forward(self, hidden_states):
# Apply down projection and ReLU activation
hidden_states = self.down_project(hidden_states)
        hidden_states = F.relu(hidden_states)
# Apply dropout
hidden_states = self.dropout(hidden_states)
# Apply up projection
hidden_states = self.up_project(hidden_states)
# Apply dropout again
hidden_states = self.dropout(hidden_states)
return
hidden_states
# Define the GPT2LMHeadModelWithAdapters class, which inherits from GPT2LMHeadModel
# and adds adapter layers to each transformer layer
class
GPT2LMHeadModelWithAdapters(GPT2LMHeadModel):
def
__init__(self, config):
super
().__init__(config)
# Create a list of adapter modules, one for each transformer layer
self.adapters = nn.ModuleList([Adapter(config.n_embd)
for
_
in
range
(config.n_layer)])
def
forward(
        self,
        input_ids=
None
,
        past_key_values=
None
,
        attention_mask=
None
,
        token_type_ids=
None
,
        position_ids=
None
,
        head_mask=
None
,
        inputs_embeds=
None
,
        encoder_hidden_states=
None
,
        encoder_attention_mask=
None
,
        labels=
None
,
        use_cache=
None
,
        output_attentions=
None
,
        output_hidden_states=
None
,
        return_dict=
None
,
    ):
# Get the outputs from the transformer
transformer_outputs = self.transformer(
            input_ids,
            past_key_values=past_key_values,
            attention_mask=attention_mask,
            token_type_ids=token_type_ids,
            position_ids=position_ids,
            head_mask=head_mask,
            inputs_embeds=inputs_embeds,
            encoder_hidden_states=encoder_hidden_states,
            encoder_attention_mask=encoder_attention_mask,
            use_cache=use_cache,
            output_attentions=output_attentions,
            output_hidden_states=output_hidden_states,
            return_dict=return_dict,
        )
        hidden_states = transformer_outputs[
0
]
# Apply each adapter to the hidden states
for
i, adapter
in
enumerate
(self.adapters):
            hidden_states = hidden_states + adapter(hidden_states)
# Get the logits for the language modeling head
lm_logits = self.lm_head(hidden_states)
# Compute loss if labels are provided
loss =
None
if
labels
is
not
None
:
# Shift logits and labels for loss computation
shift_logits = lm_logits[..., :-
1
, :].contiguous()
            shift_labels = labels[...,
1
:].contiguous()
# Flatten the logits and labels for cross-entropy loss
loss_fct = nn.CrossEntropyLoss()
            loss = loss_fct(shift_logits.view(-
1
, shift_logits.size(-
1
)), shift_labels.view(-
1
))
# Return the outputs in the appropriate format
if
not
return_dict:
            output = (lm_logits,) + transformer_outputs[
1
:]
return
((loss,) + output)
if
loss
is
not
None
else
output
return
modeling_outputs.CausalLMOutputWithCrossAttentions(
            loss=loss,
            logits=lm_logits,
            past_key_values=transformer_outputs.past_key_values,
            hidden_states=transformer_outputs.hidden_states,
            attentions=transformer_outputs.attentions,
            cross_attentions=transformer_outputs.cross_attentions,
        )
Next, we need to load the fine-tuned GPT-2 model and control the model conversion process. We use the `load_model_and_tokenizer()` function to load the fine-tuned GPT-2 model, the `export_model_to_onnx()` function to convert the model to ONNX format, and the `main()` function to control the entire process and input/output paths. Finally, we define a `check_onnx()` function to check the export results and a `quantization()` function for quantization. Here is an example:
# Function to load the model and tokenizer
def
load_model_and_tokenizer(model_id):
try
:
# Load the model configuration
config = AutoConfig.from_pretrained(model_id)
# Load the model
model = GPT2LMHeadModelWithAdapters.from_pretrained(model_id)
# Load the tokenizer
# tokenizer = AutoTokenizer.from_pretrained('gpt2')
return
config, model,tokenizer
except
Exception
as
e:
# Log any errors that occur during loading
logging.error(
f"Error loading model and tokenizer:
{e}
"
)
raise
# Function to export the model to ONNX format
def
export_model_to_onnx(model, config, tokenizer, output_path, opset):
try
:
# Get the appropriate feature for the model
model_type = config.model_type.replace(
"-"
,
"_"
)
        feature =
"causal-lm-with-past"
# Get the ONNX configuration
onnx_config_constructor = FeaturesManager.get_config(model_type, feature=feature)
        onnx_config = onnx_config_constructor(config)
# Create the output directory if it doesn't exist
if
not
os.path.exists(output_path.parent):
            os.makedirs(output_path.parent)
# Export the model to ONNX
export(
            model=model,
            config=onnx_config,
            opset=opset,
            output=output_path,
            preprocessor=tokenizer,
        )
# Log success message
logging.info(
f"Model successfully converted to ONNX and saved in
{output_path}
"
)
except
Exception
as
e:
# Log any errors that occur during export
logging.error(
f"Error exporting model to ONNX:
{e}
"
)
raise
# Main function to orchestrate the process
def
main():
# Define the model ID, output path, and ONNX opset version
model_id =
"gpt2_Adapter-tuning"
onnx_path =
"./gpt2_onnx"
out_path = Path(os.path.join(onnx_path,
"gpt2_adapter_tuning.onnx"
))
    opset =
14
# Load the model and tokenizer
config, model, tokenizer = load_model_and_tokenizer(model_id)
# Export the model to ONNX
export_model_to_onnx(model, config, tokenizer, out_path, opset)
def
check_onnx():
# Check the ONNX model
onnx_model = onnx.load(
"gpt2_onnx/gpt2_adapter_tuning.onnx"
)
    onnx.checker.check_model(onnx_model)
print
(
"ONNX model check passed!"
)
def
quantization():
from
onnxruntime.quantization
import
quantize_dynamic, QuantType
# load model
model_path =
"gpt2_onnx/gpt2_adapter_tuning.onnx"
onnx_model = onnx.load(model_path)
#dynamic quantize INT4
quantized_model_path =
"gpt2_onnx/quantized_gpt2.onnx"
quantize_dynamic(model_path, quantized_model_path, weight_type=QuantType.QUInt4)
print
(
f"Save the quantized model to:
{quantized_model_path}
"
)
The implementation of this part of the code does not have any difficulties, and there are detailed comments in the code, so we will not discuss it in detail. We will only discuss the key parts of the code:
Must use the model class with the Adapter module to load the fine-tuned model:
model = GPT2LMHeadModelWithAdapters.from_pretrained(model_id)
File paths must be converted to the path format supported by `transformers.onnx.export()`, and cannot be directly used as string paths. We use the `Path` class from the `pathlib` library to convert:
out_path = Path(os.path.join(onnx_path,
"gpt2_adapter_tuning.onnx"
))
The `export()` function's `tokenizer` and `preprocessor` parameters can only set one. Otherwise, it will report an error. It is recommended to use `preprocessor`:
export
(model=model, config=onnx_config, opset=opset, output=output_path, preprocessor=tokenizer)
Determine the opset version, which must correspond to the opset version supported by MQL5 to load correctly. We choose opset=14:
opset =
14
The input path of the model (i.e., the folder containing the GPT-2 model fine-tuned with Adapter-Tuning) is set to the `gpt2_Adapter-tuning` folder under the current project path, and the output path is set to the `gpt2_onnx` folder under the current project path:
model_id =
"gpt2_Adapter-tuning"
onnx_path =
"./gpt2_onnx"
The `check_onnx()` and `quantization()` functions are not mandatory and are provided for reference.
Of course, this is just a basic conversion script example. We have not set more details, such as dynamic input support for sequences. If you need the corresponding functionality, please add the relevant features based on the example script.
The complete conversion script is also provided in the attachment, named `torch2onnx.py`.
Formulating EA Strategy and Server Functionality
We have determined the operation mode of the EA. Next, we need to specify a plan to determine what services the server provides and what features the client integrates: The EA client is mainly responsible for data collection and transaction implementation; the Python server receives data sent from the client, calculates the inference results, and sends the results back to the client; the EA client and the Python server communicate through Socket.
1. EA Strategy
Next, we will design a trading strategy based on the GPT-2 prediction results. Since the focus of this article is to demonstrate how to integrate the GPT-2 model into the MQL5 EA, we will create a simple trading strategy as an example. It should be emphasized that this is a simple example strategy for demonstration purposes only and does not constitute any actual trading advice. In practical applications, more complete and robust trading strategies need to be developed, and thorough backtesting and risk assessment need to be conducted.
EA Strategy Logic:
Obtain the closing price data of the past 20 time points every 1 minute.
Transmit the data to the server and wait for the server to send back the calculation results.
Send orders for trading based on the trading signals sent back by the server, without setting stop loss or take profit, and always holding only one order.
2. Server Function Design
On the server side, we have to implement the main functions of receiving data from the EA client, running model inference to get results, and calculating the trading signals to be sent back to the client based on the inference results.
Server-side functions:
Receive data from the client.
Load the GPT-2 model and tokenizer and keep the model ready at all times.
Run inference and calculate the difference between the current actual price and the mean of the predicted price based on the inference results. If the difference surpasses 0, send a "buy" signal; if less than 0, send a "sell" signal; if equal to 0, do not send any signal.
Check and decide whether to use CPU or GPU for model inference (depending on the mode supported by the current device).
Next, we will complete the corresponding functionality implementation.
Creating the Inference Service
Regarding how to create the inference service, I have provided a detailed description in a previous article (
Data label for time series mining (Part 5): Apply and Test in EA Using Socket: https://www.mql5.com/en/articles/13254
, where the `server.py` script used here is provided). The code part will still follow the main logic of the `server.py` script from the previous article, only adapting it to our fine-tuned GPT-2 model and making some other optimizations and improvements.
The modified code mainly has the following changes:
Adapt the model inference to the GPT-2 model, with significant changes in the `eva()` function.
Optimize the Socket handshake logic, adding the ability to reconnect the client without restarting the server after disconnection, which is more convenient for backtesting and does not require restarting the server after backtesting.
Add detection of the client connection status to avoid unnecessary resource waste.
Avoid redundant printing of results, only print results when the prediction results change.
Add error handling logic to avoid server crashes.
Optimize the overall code logic.
Regarding the code part, this article will not discuss the details further and will only discuss the parts that need to be modified.
1. Import required libraries
In addition to importing the normal libraries needed, we also need to import the Adapter and GPT2LMHeadModelWithAdapters classes that we built into the script. You can get these classes from my previous article on fine-tuning GPT-2, or directly import them from the `torch2onnx.py` provided in this article. The example code chooses to import the two classes directly from `torch2onnx.py`.
import
socket
from
time
import
sleep
import
pandas
as
pd
import
numpy
as
np
import
warnings
import
base64
import
hashlib
import
struct
from
torch2onnx
import
GPT2LMHeadModelWithAdapters,Adapter
from
transformers
import
AutoTokenizer
import
logging
import
torch
from
statistics
import
mean
# Set logging and warning
logging.basicConfig(level=logging.INFO)
warnings.filterwarnings(
"ignore"
)
# Set device
dvc=
'cuda'
if
torch.cuda.is_available()
else
'cpu'
# Global
model_id =
"gpt2_Adapter-tuning"
encoder_length=
20
prediction_length=
10
info_file=
"results.json"
host=
"0.0.0.0"
port=
10055
2. Add GPT-2 model loading logic in the `load_model()` function
In the original script (`server.py`), the `load_model()` function is used to load the model. Note that we need to add the GPT-2 model loading logic here, as well as the loading logic for the GPT-2 tokenizer.
# Function to loda model
def
load_model():
try
:
# Load the model
model = GPT2LMHeadModelWithAdapters.from_pretrained(model_id).to(dvc)
# Load the tokenizer
tokenizer = AutoTokenizer.from_pretrained(
'gpt2'
)
print
(
"Model loaded!"
)
return
model,tokenizer
except
Exception
as
e:
# Log any errors that occur during loading
logging.error(
f"Error loading model and tokenizer:
{e}
"
)
raise
3. Add GPT-2 model inference logic in the `eva()` function
def
eva(msg,model,tokenizer):
# Get the data
msg=np.fromstring(msg, dtype=
float
, sep=
','
).tolist()
# Parse the data
input_data=msg[-encoder_length:]
# Create the prompt
prompt =
' '
.join(
map
(
str
, input_data))
# Generate the predication
token=tokenizer.encode(prompt, return_tensors=
'pt'
).to(dvc)
        attention_mask = torch.ones_like(token).to(dvc)
        model.
eval
()
        generated = tokenizer.decode(
            model.generate(
                token,
                attention_mask=attention_mask,
                pad_token_id=tokenizer.eos_token_id,
                do_sample=
True
,
                max_length=
200
)[
0
],
            skip_special_tokens=
True
)
        generated_prices=generated.split(
'\n'
)[
0
]
# Remove non-numeric formats
def
try_float(s):
try
:
return
float
(s)
except
ValueError:
return
None
generated_prices=generated_prices.split()
        generated_prices=
list
(
map
(try_float,generated_prices))
        generated_prices = [f
for
f
in
generated_prices
if
f
is
not
None
]

        generated_prices=generated_prices[
0
:prediction_length]
# Calculate and send the results
last_price=input_data[-
1
]
        prediction_mean=mean(generated_prices)
if
(last_price-prediction_mean) >=
0
:
# print('Send sell.')
return
"sell"
else
:
# print("Send buy.")
return
"buy"
Note that the input length must match the data format used when training the GPT-2 model with Adapter-Tuning:
input_data = msg[-encoder_length:]: Take the last 20 data points sent by the client as the model input
prompt = ' '.join(map(str, input_data)): Convert the data to string format and convert it to a prompt
token = tokenizer.encode(prompt, return_tensors='pt').to(dvc): Use the tokenizer of the pre-trained GPT-2 model to encode the prompt and transfer it to the current supported device (matching the device used for model inference).
attention_mask = torch.ones_like(token).to(dvc): Define the attention mask for model inference
model.generate(token, attention_mask=attention_mask, pad_token_id=tokenizer.eos_token_id, do_sample=True, max_length=200)[0]: Run model inference
generated = tokenizer.decode(model.generate(...), skip_special_tokens=True): Decode the prediction results and set to skip special tokens
generated_prices = generated.split('\n')[0]: Split the decoded inference results
try_float(s)  : This function is used to detect whether there are elements in the inference results that cannot be converted to float format
generated_prices = generated_prices.split(): Separate the prediction results with spaces and remove separators that cannot be converted to numbers
generated_prices = list(map(try_float, generated_prices)): Convert all elements in generated_prices to float format numbers, if there are elements that cannot be converted to numbers, use the try_float(s) function to set them to None
generated_prices = [f for f in generated_prices if f is not None]: Traverse all elements in generated_prices and remove elements that are None
generated_prices = generated_prices[0:prediction_length]: Only get the first 10 predicted values as a reference
if (last_price - prediction_mean) >= 0: Calculate the difference between the last data sent by the client and the mean of the predicted values. If greater than or equal to 0, send a "sell" signal; if less than 0, send a "buy" signal
We choose to use the `transformers` library for inference. You can also use the `torch2onnx.py` script mentioned earlier to convert the model to ONNX format and use the `onnxruntime` library for inference. This method will not be discussed in this article.
4. Server
All the functionality of the server is integrated into the `server_()` class, and the overall code changes are not significant. Here, we will not interpret it in detail and will only discuss the parts that have been modified.
class
server_:
def
__init__(self, host = host, port = port):
        self.sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM,)
        self.host = host
        self.port = port
        self.sk.bind((self.host, self.port))
        self.re =
''
self.model,self.tokenizer=load_model()
        self.stop=
None
self.sk.listen(
1
)
        self.sk_, self.ad_ = self.sk.accept()
        self.last_action=
None
print
(
'server running：'
,self.sk_, self.ad_)
def
msg(self):
        self.re =
''
wsk=
False
while
True
:
            sleep(
0.5
)
if
self.is_connected():
try
:
                    data = self.sk_.recv(
2500
)
except
Exception
as
e:
break
if
not
data:
break
if
(data[
1
] &
0x80
) >>
7
:
                    fin = (data[
0
] &
0x80
) >>
7
# FIN bit
opcode = data[
0
] &
0x0f
# opcode
masked = (data[
1
] &
0x80
) >>
7
# mask bit
mask = data[
4
:
8
]
# masking key
payload = data[
8
:]
# payload data
# print('fin is：{},opcode is：{}，mask:{}'.format(fin,opcode,masked))
message =
""
for
i
in
range
(
len
(payload)):
                        message +=
chr
(payload[i] ^ mask[i %
4
])
                    data=message
                    wsk=
True
else
:
                    data=data.decode(
"utf-8"
)
if
'\r\n\r\n'
in
data:
                    self.handshake(data)
                    data=data.split(
'\r\n\r\n'
,
1
)[
1
]
if
"stop"
in
data:
                    self.stop=
True
break
if
len
(data)<
50
:
break
self.re+=data
                bt=eva(self.re, self.model,self.tokenizer)
                bt=
bytes
(bt,
"utf-8"
)
# If the signal changes,then print the information
if
bt != self.last_action:
if
bt ==
b'buy'
:
print
(
'Send buy.'
)
elif
bt ==
b'sell'
:
print
(
'Send sell.'
)
                    self.last_action = bt
if
wsk:
                    tk=
b'\x81'
lgt=
len
(bt)
                    tk+=struct.pack(
'B'
,lgt)
                    bt=tk+bt
                self.sk_.sendall(bt)
else
:
print
(
"Disconnected！Try to connect the client..."
)
try
:
# reconnect
self.sk_.close()
                    self.sk.listen(
1
)
                    self.sk_, self.ad_ = self.sk.accept()
print
(
'Reconnected:'
, self.sk_, self.ad_)
# handshake
while
True
:
                        sleep(
0.5
)
                        data = self.sk_.recv(
2500
)
                        data=data.decode(
"utf-8"
)
if
'\r\n\r\n'
in
data:
                            self.handshake(data)
break
print
(
"Reconnection succeed！"
)
# # clean the socket
# while True:
#     if not self.sk_.recv(2500):
#         break
except
Exception
as
e:
print
(
f"Reconnection failed:
{e}
"
)
return
self.re
def
__del__(self):
print
(
"server closed!"
)
        self.sk.close()
if
self.sk_
is
not
None
:
            self.sk_.close()
            self.ad_.close()
def
handshake(self,data):
try
:
# Handshake
key = data.split(
"\r\n"
)[
4
].split(
": "
)[
1
]
            GUID =
"258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
ac = base64.b64encode(hashlib.sha1((key+GUID).encode(
'utf-8'
)).digest())
            response_tpl=
"HTTP/1.1 101 Switching Protocols\r\n"
\
"Upgrade:websocket\r\n"
\
"Connection: Upgrade\r\n"
\
"Sec-WebSocket-Accept: %s\r\n"
\
"WebSocket-Location: ws://%s/\r\n\r\n"
response_str = response_tpl % (ac.decode(
'utf-8'
),
"127.0.0.1:10055"
)
            self.sk_.send(
bytes
(response_str, encoding=
'utf-8'
))
print
(
'Handshake succeed!'
)
except
Exception
as
e:
print
(
f"Connection failed:
{e}
"
)
return
None
def
is_connected(self):
try
:
# Check remote
# remote_addr = self.sk_.getpeername()
data = self.sk_.recv(
1
, socket.MSG_PEEK)
return
True
except
socket.error:
            self.last_action=
None
return
False
Add class function `is_connected(self)` to detect whether the client is online.
Add class function `handshake(self, data)` to integrate the handshake logic and avoid cluttering the main parsing logic.
Add class member `self.last_action` to detect whether the trading signal has changed. Only print results when the trading signal changes to avoid frequent printing. When the client disconnects, reset to None to avoid sending incorrect signals when the client reconnects.
Note:
Our host address is set to "0.0.0.0" because if it is set to "127.0.0.1", remote clients running on a different host will not be able to connect. This means that by setting it to "0.0.0.0", even if the server and client are not on the same host, they can still connect (the EA client needs to set the correct host IP address).
The overall code is in the attached `server.py` file. When the server is running, the terminal will give the corresponding running information.
EA Client
The client mainly follows the logic from a previous article (specifically mentioned in a previous article), with corresponding modifications in logic. It still retains two socket compatibility methods (one using Winapi to implement WebSocket, the other using the built-in Socket module in MQL5) to avoid signal interruptions caused by the MQL5 built-in Socket being unable to connect under special circumstances. The main operational logic is to initialize the Socket in the `OnInit()` function, handle trading logic in the `OnTick()` function, and handle sending data to the server and receiving inference results every fixed time in the `OnTimer()` function.
1. Define Constants
#include
<WinAPI\winhttp.mqh>
int
sk=-
1
;
string
host=
"127.0.0.1"
;
int
port=
10055
;
int
data_len=
100
;
string
pre=
NULL
;
HINTERNET ses_h,cnt_h,re_h,ws_h;
`sk`: Socket handle.
`host` and `port`: Server address and port to connect to.
`data_len`: Number of price data points to send.
`pre`: String to store prediction results.
`ses_h`, `cnt_h`, `re_h`, `ws_h`: Session handle, connection handle, request handle, and WebSocket handle for WinHttp, respectively.
2. Initialize Socket
int
OnInit
()
  {
//--- create timer
EventSetTimer
(
60
);
   ses_h=cnt_h=re_h=ws_h=
NULL
;
//handshake
ses_h=WinHttpOpen(
"MT5"
,
                     WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
NULL
,
NULL
,
0
);
//Print(ses_h);
if
(ses_h==
NULL
){
Print
(
"Http open failed!"
,
string
(kernel32::
GetLastError
()));
return
INIT_FAILED
;
      }
   cnt_h=WinHttpConnect(ses_h,
                        host,
                        port,
0
);
//Print(cnt_h);
if
(cnt_h==
NULL
){
Print
(
"Http connect failed!"
,
string
(kernel32::
GetLastError
()));
return
INIT_FAILED
;
      }
   re_h=WinHttpOpenRequest(cnt_h,
"GET"
,
NULL
,
NULL
,
NULL
,
NULL
,
0
);
if
(re_h==
NULL
){
Print
(
"Request open failed!"
,
string
(kernel32::
GetLastError
()));
return
INIT_FAILED
;
   }
uchar
nullpointer[]= {};
if
(!WinHttpSetOption(re_h,WINHTTP_OPTION_UPGRADE_TO_WEB_SOCKET,nullpointer,
0
))
     {
Print
(
"Set web socket failed!"
,
string
(kernel32::
GetLastError
()));
return
INIT_FAILED
;
       }
bool
br;  
   br = WinHttpSendRequest( re_h,
NULL
,
0
,
                             nullpointer,
0
,
0
,
0
);
if
(!br)
      {
Print
(
"send request failed!"
,
string
(kernel32::
GetLastError
()));
return
INIT_FAILED
;
         }
   br=WinHttpReceiveResponse(re_h,nullpointer);
if
(!br)
     {
Print
(
"receive response failed!"
,
string
(kernel32::
GetLastError
()));
return
INIT_FAILED
;
       }
ulong
nv=
0
;
   ws_h=WinHttpWebSocketCompleteUpgrade(re_h,nv);
if
(!ws_h)
   {
Print
(
"Web socket upgrade failed!"
,
string
(kernel32::
GetLastError
()));
return
INIT_FAILED
;
         }
else
{
Print
(
"Web socket connected！"
);
    }  
  
   WinHttpCloseHandle(re_h);
   re_h=
NULL
;

    sk=
SocketCreate
();
Print
(sk);
Print
(
GetLastError
());
if
(sk==
INVALID_HANDLE
) {
Print
(
"Failed to create socket"
);
//return INIT_FAILED;
}
if
(!
SocketConnect
(sk,host, port,
1000
))
    {
Print
(
"Failed to connect to built-in socket"
);
//return INIT_FAILED;
}
//---
return
(
INIT_SUCCEEDED
);
  }
In the initialization part, we mainly implement the initialization of Winapi WebSocket and the built-in Socket in MQL5. This part has not changed much compared to the content in the previous article, so it will not be discussed in this article.
3. Trading Strategy
void
OnTick
()
  {
//---
MqlTradeRequest
request;
MqlTradeResult
result;
//int x=SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE);
if
(pre!=
NULL
)
    {
//Print("The predicted value is:",pre);
ulong
numt=
0
;
ulong
tik=
0
;
bool
sod=
false
;
ulong
tpt=-
1
;
ZeroMemory
(request);
        numt=
PositionsTotal
();
//Print("All tickets: ",numt);
if
(numt>
0
)
         {  tik=
PositionGetTicket
(numt-
1
);    
            sod=
PositionSelectByTicket
(tik);
            tpt=
PositionGetInteger
(
POSITION_TYPE
);
//ORDER_TYPE_BUY or ORDER_TYPE_SELL
if
(tik==
0
|| sod==
false
|| tpt==
0
)
return
;
            }
if
(pre==
"buy"
)
        {
if
(tpt==
POSITION_TYPE_BUY
)
return
;
              
            request.action=
TRADE_ACTION_DEAL
;
            request.symbol=
Symbol
();
            request.volume=
0.1
;
            request.deviation=
5
;
            request.type_filling=
ORDER_FILLING_IOC
;
            request.type =
ORDER_TYPE_BUY
;  
            request.price =
SymbolInfoDouble
(
Symbol
(),
SYMBOL_ASK
);
if
(tpt==
POSITION_TYPE_SELL
)
             {
               request.position=tik;
Print
(
"Close sell order."
);
                    }
else
{
Print
(
"Open buy order."
);
                     }
OrderSend
(request, result);
               }
else
{
if
(tpt==
POSITION_TYPE_SELL
)
return
;
              
            request.action =
TRADE_ACTION_DEAL
;      
            request.symbol =
Symbol
();  
            request.volume =
0.1
;  
            request.type =
ORDER_TYPE_SELL
;  
            request.price =
SymbolInfoDouble
(
Symbol
(),
SYMBOL_BID
);  
            request.deviation =
5
;
//request.type_filling=SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE);
request.type_filling=
ORDER_FILLING_IOC
;
if
(tpt==
POSITION_TYPE_BUY
)
               {
               request.position=tik;
Print
(
"Close buy order."
);
                    }
else
{
Print
(
"OPen sell order."
);
                    }
OrderSend
(request, result);
              }
//is_pre=false;
}
    pre=
NULL
;
  }
We integrate the entire trading strategy into the `OnTick()` function to make the logic clearer. When the OnTick() function is executed, check if the global variable `pre` is empty. If it is not empty, it indicates that there are prediction results sent from the client.
Then, send trading requests based on the prediction results ("buy" or "sell"):
If "buy", open a position if there is no existing position or close an existing sell order.
If "sell", open a position if there is no existing position or close an existing buy order.
Maintain only one order throughout, without setting take profit or stop loss, and control the position only through trading signals.
4. Interaction with the Server
void
OnTimer
()
  {
//---
MqlTradeRequest
request;
MqlTradeResult
result;
char
recv_data[
5
];
double
priceData[
100
];
string
dataToSend;
char
ds[];
int
nc=
CopyClose
(
Symbol
(),
0
,
0
,data_len,priceData);
for
(
int
i=
0
;i<
ArraySize
(priceData);i++) dataToSend+=(
string
)priceData[i]+
","
;
int
dsl=
StringToCharArray
(dataToSend,ds);
if
(sk!=-
1
)
    {
if
(
SocketIsWritable
(sk))
           {
Print
(
"Send data:"
,dsl);
int
ssl=
SocketSend
(sk,ds,dsl);    
            }
uint
len=
SocketIsReadable
(sk);
if
(len)
       {
int
rsp_len=
SocketRead
(sk,recv_data,len,
500
);
if
(rsp_len>
0
)
         {
string
result=
NULL
;
           result+=
CharArrayToString
(recv_data,
0
,rsp_len);
Print
(
"The predicted value is:"
,result);
if
(
StringFind
(result,
"buy"
))
           {
            pre=
"buy"
;
           }
if
(
StringFind
(result,
"sell"
)){
             pre=
"sell"
;

               }
            }
          }
     }
else
{
ulong
send=
0
;
if
(ws_h)
       {
         send=WinHttpWebSocketSend(ws_h,
                                   WINHTTP_WEB_SOCKET_BINARY_MESSAGE_BUFFER_TYPE,
                                   ds,
                                   dsl);
//Print("Send data failed!",string(kernel32::GetLastError()));
if
(!send)
            {
ZeroMemory
(recv_data);
ulong
rb=
0
;
               WINHTTP_WEB_SOCKET_BUFFER_TYPE st=-
1
;
ulong
get=WinHttpWebSocketReceive(ws_h,recv_data,
ArraySize
(recv_data),rb,st);
if
(!get)
                {
                    pre=
NULL
;
                    pre+=
CharArrayToString
(recv_data,
0
);
Print
(
"The predicted value is:"
,pre);
                     }
                 }
            }
        }          
  }
The main function of the server is to collect 100 data points from the current chart, send them to the server, and receive inference results from the server, then modify the global variable based on the results to ensure that the trading strategy is executed according to the results given by the server. Here, we use two socket connection methods to implement the data interaction logic and automatically select the appropriate method based on the current connected socket type.
5. Resource Release
void
OnDeinit
(
const
int
reason)
  {
//--- destroy timer
EventKillTimer
();
uchar
stop[];
int
ls=
StringToCharArray
(
"stop"
,stop);
SocketSend
(sk,stop,ls);
SocketClose
(sk);
 // close the websocket
   WinHttpSendRequest(re_h,
NULL
,
0
,stop,
0
,
0
,
0
);
   BYTE closearray[]= {};
ulong
close=WinHttpWebSocketClose(ws_h,
                                    WINHTTP_WEB_SOCKET_SUCCESS_CLOSE_STATUS,
                                    closearray,
0
);
if
(close)
     {
Print
(
"websocket close error "
+
string
(kernel32::
GetLastError
()));
if
(re_h!=
NULL
)
         WinHttpCloseHandle(re_h);
if
(ws_h!=
NULL
)
         WinHttpCloseHandle(ws_h);
if
(cnt_h!=
NULL
)
         WinHttpCloseHandle(cnt_h);
if
(ses_h!=
NULL
)
         WinHttpCloseHandle(ses_h);
     }  
  }
In the `OnDeinit()` function, release related system resources and perform resource recovery.
Since the GPT-2 model inference process is not implemented in the EA, this makes our EA logic much simpler and more concise. Note that we have not added risk control logic in the EA, and relying solely on the GPT-2 inference results to decide whether to hold or open a position is a very risky approach. Please note again that this EA example should not be used for real trading!
The complete code is provided in the attachment of the article, named `gpt2_EA.mql5`.
Backtesting
To evaluate the performance of the EA, we can conduct backtesting in the MetaTrader 5 client's strategy tester. We select the appropriate range of historical data, set the backtest parameters, and then run the backtest (since our gpt2 model is trained on the NZDUSD currency pair, we can only select the NZDUSD currency pair for testing in the backtest)
Backtesting is running：
After the backtesting is completed, the results are as follows:
You can analyze the EA's profitability, maximum drawdown, win rate, and other metrics by reviewing the backtest report. Remember that our trading strategy is simple, so the backtest results are not ideal. This is mainly because our strategy has not undergone any parameter optimization or risk control, and the training process and data preparation for the model have significant optimization potential. Overall, doing this requires a lot of patience. It is important to note that due to changes in market conditions and the limitations of the model, backtest results cannot guarantee the EA's performance in future live trading, and the model's limitations may also lead to unstable prediction results.
Conclusion
In this article, we demonstrated how to int