# Creating an MQL5-Telegram Integrated Expert Advisor (Part 2): Sending Signals from MQL5 to Telegram

**Source:** [https://www.mql5.com/en/articles/15495](https://www.mql5.com/en/articles/15495)

---

Creating an MQL5-Telegram Integrated Expert Advisor (Part 2): Sending Signals from MQL5 to Telegram
MetaTrader 5
—
Trading systems
| 12 August 2024, 11:25
1 269
0
Allan Munene Mutiiria
Introduction
In the
first part of our series
on developing a Telegram-integrated Expert Advisor for MQL5, we covered the essential steps needed to link MQL5 and Telegram. Setting up the actual application was the first step. After that, we moved on to the coding part. The reason for this particular order of events will hopefully become clearer in the next paragraphs. The upshot is that we now have a bot that can receive messages, as well as a program that can send them. We have also written a simple MQL5 program demonstrating how to send a message via the bot to the application.
Having set the foundation in Part 1, we can now proceed to the next step: transmitting trading signals to Telegram using MQL5. Our newly enhanced Expert Advisor does something quite remarkable: It not only opens and closes trades based on preset conditions but also performs the equally impressive feat of transmitting a signal to a Telegram group chat to let us know a trade was executed. The trading signals themselves have gone through a bit of a makeover, ensuring that the information we send to Telegram is as clear and concise as possible. Our "Chatty Trader" does a better job of talking to the group in Telegram than our previous version, and it does so at the same or faster pace than our old "Chatty Trader" had, which means we can expect to receive signals nearly in real-time as trades are taken or closed.
We will generate signals based on the famous moving average crossover system and relay the generated signals. In addition, if you recall, in part 1 of the series, we had just a single message that could be pretty long, and if someone wanted to add segments to the message, it would result in an error. Thus, only a single message could be sent at a time, and if there were extra segments, they would have to be relayed in different individual messages. For example, sending “A buy signal has been generated.” and “Open a buy order.”, would be either a single long message or two short messages. In this part, we will concatenate them and modify the message so that a single message can contain several text segments and characters. We will discuss the entire process in the following subtopics:
Overview of the Strategy
Implementation in MQL5
Testing the Integration
Conclusion
By the end, we will have crafted an Expert Advisor that sends trading information like signals that have been generated and the orders placed from the trading terminal to the specified Telegram chat. Let’s get started.
Overview of the Strategy
We produce trading signals with moving average crossovers, one of the most widely used technical analysis tools. We will describe what we consider to be the most straightforward and clear-cut method for using moving average crossovers to try to identify potential buy or sell opportunities. This is based on the signaling nature of the crossovers themselves, without the addition of any other tools or indicators. For simplicity's sake, we will consider only two moving averages of different periods: a shorter-term moving average and a longer-term moving average.
We will explore the function of moving average crossovers and how they yield trading signals one can act upon. Moving averages take price data and smooth it out, creating a sort of flowing line that is far better for trend identification than the actual price chart. This is because, in general, an average is always more streamlined and easier to follow than a jagged line. When you add two moving averages of different periods together, they will at some point cross each other, hence the term "crossover".
To put moving average crossover signals into practice using
MQL5
, we will begin by determining the short-term and long-term periods of the average that most align with our trading strategy. For this purpose, we will utilize standard periods such as 50 and 200 for long-term trends and 10 and 20 for shorter-term trends. After computing the moving averages, we will compare the crossover event values at each new tick or bar and convert these detected crossover signals into the binary events of "buy" or "sell" for our Expert Advisor to act upon. To easily understand what we mean, let us visualize the two instances.
Upward crossover:
Downward crossover:
These generated signals will be combined with our present MQL5-Telegram messaging framework. To achieve this, the code from Part 1 will be adapted to encompass signal detection and formatting. Upon identifying a crossover, a message will be created with the asset name, crossover direction (buy/sell), and signal time. The timely delivery of this message to a designated Telegram chat will ensure that our trading group is kept in the loop about potential trading opportunities. Apart from anything else, the assurance of receiving a message just after the crossover has occurred means that we will have a chance to initiate a trade based on the signal in question, or even open a market position and relay the position details.
Implementation in MQL5
First, we will make sure that we can segment our message and send it as a whole. In the first part, when we send a complex message that includes special characters like new line feeds, we receive an error, and we can only send it as a single message, with no structure. For example, we had this code snippet that gets the initialization event, the account equity as well as the free margin available:
double
accountEquity =
AccountInfoDouble
(
ACCOUNT_EQUITY
);
double
accountFreeMargin =
AccountInfoDouble
(
ACCOUNT_MARGIN_FREE
);
string
msg =
"🚀 EA INITIALIZED ON CHART "
+
_Symbol
+
" 🚀"
+
"📊 Account Status 📊; Equity: $"
+
DoubleToString
(accountEquity,
2
)
                +
"; Free Margin: $"
+
DoubleToString
(accountFreeMargin,
2
);
Sending this as a whole, this is what we get:
We can see that though we can send the message, its structure is not appealing. The initialization sentence should be on the first line, then the account status on the second line, the equity on the proceeding line, and the free margin information on the last line. To achieve this, a new line feed character "\n" needs to be considered as follows.
double
accountEquity =
AccountInfoDouble
(
ACCOUNT_EQUITY
);
double
accountFreeMargin =
AccountInfoDouble
(
ACCOUNT_MARGIN_FREE
);
string
msg =
"🚀 EA INITIALIZED ON CHART "
+
_Symbol
+
" 🚀"
+
"\n📊 Account Status 📊"
+
"\nEquity: $"
+
DoubleToString
(accountEquity,
2
)
                +
"\nFree Margin: $"
+
DoubleToString
(accountFreeMargin,
2
);
However, when we run the program, we get an error message on the journal as shown and the message is not sent to the Telegram chat:
To make sure that the message is successfully sent, we have to encode it. Our integration requires the encoding of our messages to handle special characters properly. For example, if our message contains anything like a space or behaves like a symbol ("&", "?", etc.), these could be misread by the Telegram Application Programming Interface (API) due to insufficient caution on our part during the integration. We are taking this seriously; it is no joke. We have seen other uses of character encoding, for instance when opening some kinds of documents on our computers as shown.
Encoding is the key to not having the types of problems we have encountered thus far, in the API not understanding what we are trying to send it so it can do what we want it to do.
For example, a message sent to the API containing a special character could interfere with the Uniform Resource Locator (URL) structure—the way the URL is "seen" by computers—and could cause errors in interpretation. The API might interpret the special character as an instruction or some other part of the code rather than as part of the actual message. This communication breakdown could occur at either end: when sending the message from the program or when receiving it at the other end of the encoding is not performing its principal function of making the unseen part of the message safe to "see." Also, using the encoding scheme means we have a message in a format that is compatible with the receiving end—the Telegram API in this case. After all, several different systems are involved in this story, and each has specific requirements for how it wants the data passed to it. Therefore, the first thing that we will do is craft a function that will encode our messages.
// FUNCTION TO ENCODE A STRING FOR USE IN URL
string
UrlEncode(
const
string
text) {
string
encodedText =
""
;
// Initialize the encoded text as an empty string
int
textLength =
StringLen
(text);
// Get the length of the input text
...

}
Here, we begin by creating a
string
data type function called "UrlEncode" that takes a single parameter or argument, text, of type
string
, which is designed to convert the provided text into a URL-encoded format. We then initialize an empty string, "encodedText", which will be used to build the URL-encoded result as we process the input text. Next, we determine the length of the input string by using the
StringLen
function, storing this length in the integer variable "textLength". This step is crucial as it allows us to know how many characters we need to process. By storing the length, we can efficiently iterate through each character of the string in a loop, ensuring that all characters are correctly encoded according to URL encoding rules. For the iteration process, we will need to use a loop.
// Loop through each character in the input string
for
(
int
i =
0
; i < textLength; i++) {
ushort
character =
StringGetCharacter
(text, i);
// Get the character at the current position
...

    }
Here, we initiate a
for loop
to iterate via all the characters contained in the input message or text, starting from the first at index 0 onwards. We get the value of the selected symbol using the
StringGetCharacter
function, which typically returns the value of a symbol, located in the specified position of a string. The position is defined by the index "i". We store the character in a
ushort
variable named "character".
// Check if the character is alphanumeric or one of the unreserved characters
if
((character >=
48
&& character <=
57
) ||
// Check if character is a digit (0-9)
(character >=
65
&& character <=
90
) ||
// Check if character is an uppercase letter (A-Z)
(character >=
97
&& character <=
122
) ||
// Check if character is a lowercase letter (a-z)
character ==
'!'
|| character ==
'\''
|| character ==
'('
||
            character ==
')'
|| character ==
'*'
|| character ==
'-'
||
            character ==
'.'
|| character ==
'_'
|| character ==
'~'
) {
// Append the character to the encoded string without encoding
encodedText +=
ShortToString
(character);
        }
Here, we check if a given character is either alphanumeric or one of the unreserved characters commonly used in URLs. The goal is to determine whether the character needs to be encoded or can be appended directly to the encoded string. First, we check if the character is a digit by verifying if its
ASCII
value falls between 48 and 57. Next, we check if the character is an uppercase letter by seeing if its
ASCII
value is between 65 and 90. Similarly, we check if the character is a lowercase letter by confirming if its
ASCII
value lies between 97 and 122. These values can be confirmed from the "ASCII table".
Digit characters - 48 to 57:
Uppercase-letter characters - 65 to 90:
Lowercase-letter characters - 97 to 122:
In addition to these alphanumeric characters, we also check for specific unreserved characters used in URLs. These include '!', ''', '(', ')', '*', '-', '.', '_', and '~'. If the character matches any of these criteria, it means that the character is either alphanumeric or one of the unreserved characters.
When the character meets any of these conditions, we append it to the "encodedText" string without encoding it. This is achieved by converting the character to its string representation using the
ShortToString
function, which ensures that the character is added to the encoded string in its original form. If none of these conditions is met, we then proceed to check for space characters.
// Check if the character is a space
else
if
(character ==
' '
) {
// Encode space as '+'
encodedText +=
ShortToString
(
'+'
);
        }
Here, we use an
else if
statement to check if the character is a space by comparing it to the space character. If the character is indeed a space, we need to encode it in a way that is appropriate for URLs. Instead of using the typical percent-encoding for spaces (%20) as we did see in the case of computer documents, we choose to encode spaces as the plus sign '+', which is another common method for representing spaces in URLs, particularly in the query component. Thus, we convert the plus sign '+' to its string representation using the
ShortToString
function and then append it to the "encodedText" string.
If up to this point, we have got uncoded characters, it means we have a head scratcher on our hands because it is complex characters like emojis. Thus we will need to handle all characters that are not alphanumeric, unreserved, or spaces by encoding them using Unicode Transformation Format-8 (UTF-8), ensuring that any character that doesn't fall into the previously checked categories is safely encoded for inclusion in a URL.
// For all other characters, encode them using UTF-8
else
{
uchar
utf8Bytes[];
// Array to hold the UTF-8 bytes
int
utf8Length = ShortToUtf8(character, utf8Bytes);
// Convert the character to UTF-8
for
(
int
j =
0
; j < utf8Length; j++) {
// Convert each byte to its hexadecimal representation prefixed with '%'
encodedText +=
StringFormat
(
"%%%02X"
, utf8Bytes[j]);
            }
        }
First, we declare an array "utf8Bytes" to hold the Unicode Transformation Format-8 (UTF-8) byte representation of the character. We then call the "ShortToUtf8" function, passing the "character" and the "utf8Bytes" array as arguments. We will explain the function shortly, but right now, just know that the function converts the character to its UTF-8 representation and returns the number of bytes used in the conversion, storing these bytes in the "utf8Bytes" array.
Next, we use a "for loop" to iterate over each byte in the "utf8Bytes" array. For each byte, we convert it to its hexadecimal representation prefixed with the '%' character, which is the standard way to percent-encode characters in URLs. We use the "StringFormat" function to format each byte as a two-digit hexadecimal number with a '%' prefix. Finally, we append this encoded representation to the "encodedText" string. In the end, we just return the results.
return
encodedText;
// Return the URL-encoded string
The full function's code snippet is as follows:
// FUNCTION TO ENCODE A STRING FOR USE IN URL
string
UrlEncode(
const
string
text) {
string
encodedText =
""
;
// Initialize the encoded text as an empty string
int
textLength =
StringLen
(text);
// Get the length of the input text
// Loop through each character in the input string
for
(
int
i =
0
; i < textLength; i++) {
ushort
character =
StringGetCharacter
(text, i);
// Get the character at the current position
// Check if the character is alphanumeric or one of the unreserved characters
if
((character >=
48
&& character <=
57
) ||
// Check if character is a digit (0-9)
(character >=
65
&& character <=
90
) ||
// Check if character is an uppercase letter (A-Z)
(character >=
97
&& character <=
122
) ||
// Check if character is a lowercase letter (a-z)
character ==
'!'
|| character ==
'\''
|| character ==
'('
||
            character ==
')'
|| character ==
'*'
|| character ==
'-'
||
            character ==
'.'
|| character ==
'_'
|| character ==
'~'
) {
// Append the character to the encoded string without encoding
encodedText +=
ShortToString
(character);
        }
// Check if the character is a space
else
if
(character ==
' '
) {
// Encode space as '+'
encodedText +=
ShortToString
(
'+'
);
        }
// For all other characters, encode them using UTF-8
else
{
uchar
utf8Bytes[];
// Array to hold the UTF-8 bytes
int
utf8Length = ShortToUtf8(character, utf8Bytes);
// Convert the character to UTF-8
for
(
int
j =
0
; j < utf8Length; j++) {
// Convert each byte to its hexadecimal representation prefixed with '%'
encodedText +=
StringFormat
(
"%%%02X"
, utf8Bytes[j]);
            }
        }
    }
return
encodedText;
// Return the URL-encoded string
}
Let us now have a look at the function responsible for converting characters to their UTF-8 representation.
//+-----------------------------------------------------------------------+
//| Function to convert a ushort character to its UTF-8 representation    |
//+-----------------------------------------------------------------------+
int
ShortToUtf8(
const
ushort
character,
uchar
&utf8Output[]) {

   ...

}
The function is of
integer
data type and takes two input parameters, the character value and the output array.
First, we convert single-byte characters.
// Handle single byte characters (0x00 to 0x7F)
if
(character <
0x80
) {
ArrayResize
(utf8Output,
1
);
// Resize the array to hold one byte
utf8Output[
0
] = (
uchar
)character;
// Store the character in the array
return
1
;
// Return the length of the UTF-8 representation
}
The conversion of single-byte characters, which have values in the range from 0x00 to 0x7F, is straightforward, as they are represented directly in UTF-8 in a single byte. We first test if the character is less than 0x80. If it is, we resize the "utf8Output" array to just one byte using the
ArrayResize
function. This allows us to have the correct size for the output UTF-8 representation. We then stick the character in the first element of the array by casting the character to an
uchar
, an exercise called
typecasting
. This would be the same as copying the character's value into the array. We return 1, indicating that the UTF-8 representation has a length of one byte. This process will efficiently handle the conversion of any single-byte character into its UTF-8 form, regardless of the operating system.
Their representation would be as follows.
0x00, UTF-8:
0x7F, UTF-8:
You can see that the decimal representation of the numbers spans from 0 to 127. You can again notice that these characters are identical to the initial Unicode characters. Probably you are wondering what all this is. Let us pause and have a deeper look. In hexadecimal notation, 0x80 and 0x7F represent specific values that can be converted to decimal for better understanding. The hexadecimal number 0x80 is equivalent to 128 in decimal. This is because hexadecimal is a base-16 number system, where each digit represents a power of 16. In 0x80, the "8" represents 8 times 16^1 (which is 128) and the "0" represents 0 times 16^0 (which is 0), giving a total of 128.
On the other hand, 0x7F is equivalent to 127 in decimal. In hexadecimal, "7F" means 7 times 16^1 plus 15 times 16^0. Calculating this, we get 7 times 16 (which is 112) plus F (which is 15), resulting in a total of 127. See the representation of A-F below. The decimal under hexadecimal F is equal to 15.
Thus, 0x80 is 128 in decimal, and 0x7F is 127 in decimal. This means that 0x80 is just one more than 0x7F, making it the boundary where the single-byte representation in UTF-8 encoding changes to a multi-byte representation.
We just wanted to make sure these explanations are detailed and that you won't be wondering about the proceeding formats and how everything makes sense. Now you know. Let us now go to the 2-byte characters.
// Handle two-byte characters (0x80 to 0x7FF)
if
(character <
0x800
) {
ArrayResize
(utf8Output,
2
);
// Resize the array to hold two bytes
utf8Output[
0
] = (
uchar
)((character >>
6
) |
0xC0
);
// Store the first byte
utf8Output[
1
] = (
uchar
)((character &
0x3F
) |
0x80
);
// Store the second byte
return
2
;
// Return the length of the UTF-8 representation
}
Here, we take care of converting characters that need two bytes in their UTF-8 representation—specifically, characters whose values lie between 0x80 and 0x7FF. To do this, we first test whether the character in question is less than 0x800 (2048 in decimal), which guarantees that it is indeed in this range. If that condition is satisfied, we resize the "utf8Output" array to hold two bytes (since it will take two bytes to represent the character in UTF-8). We then compute the actual UTF-8 representation.
The first byte is obtained by taking the character, shifting it right by 6 bits, and then combining it with 0xC0 using the logical OR operation. This computation sets the first byte's most significant bits to the UTF-8 prefix for a two-byte character. The second byte is computed by masking the character with 0x3F to get the lower 6 bits and then combining this with 0x80. This operation ensures that the second byte has the correct UTF-8 prefix.
In the end, we place these two bytes into the "utf8Output" array and report 2 back to the caller, indicating that the character requires two bytes in its UTF-8 representation. This is the necessary and correct encoding for a character that uses double the number of bits compared to a single-byte character. Then, we have the 3-byte characters.
// Handle three-byte characters (0x800 to 0xFFFF)
if
(character <
0xFFFF
) {

        ...

    }
By now, you understand what this means. Here, the hexadecimal number "0xFFFF" converts to 65,535 in decimal. We recognize that each hexadecimal digit represents a power of 16. For "0xFFFF", each digit is "F", which is 15 in decimal - we had already seen that. To calculate its decimal value, we evaluate each digit's contribution based on its position. We start with the highest place value, which is (15 * 16^3), giving us (15 * 4096 = 61,440). Next, we calculate (15 * 16^2), which equals (15 * 256 = 3,840). Then, (15 * 16^1) results in (15 * 16 = 240). Finally, (15 * 16^0) equals (15 * 1 = 15). Adding these results together, we get 61,440 + 3,840 + 240 + 15, which totals 65,535. Thus, "0xFFFF" is 65,535 in decimal. Having this in mind, there could be three instances of the 3-byte characters. Let us have a look at the first instance.
if
(character >=
0xD800
&& character <=
0xDFFF
) {
// Ill-formed characters
ArrayResize
(utf8Output,
1
);
// Resize the array to hold one byte
utf8Output[
0
] =
' '
;
// Replace with a space character
return
1
;
// Return the length of the UTF-8 representation
}
Here, we handle characters that fall within the Unicode range 0xD800 to 0xDFFF, which are known as surrogate halves and are not valid as standalone characters. We start by checking if the character is within this range. When we encounter such an ill-formed character, we first resize the "utf8Output" array to hold just one byte, ensuring that our output array is prepared to store only a single byte.
Next, we replace the invalid character with a space character by setting the first element of the "utf8Output" array to a space. This choice is a placeholder to handle the invalid input gracefully. Finally, we return 1, indicating that the UTF-8 representation of this ill-formed character is one byte long. Next, we check for emoji characters. That means we deal with characters that lie within the Unicode spectrum of 0xE000 to 0xF8FF. These characters include emojis and other extended symbols.
else
if
(character >=
0xE000
&& character <=
0xF8FF
) {
// Emoji characters
int
extendedCharacter =
0x10000
| character;
// Extend the character to four bytes
ArrayResize
(utf8Output,
4
);
// Resize the array to hold four bytes
utf8Output[
0
] = (
uchar
)(
0xF0
| (extendedCharacter >>
18
));
// Store the first byte
utf8Output[
1
] = (
uchar
)(
0x80
| ((extendedCharacter >>
12
) &
0x3F
));
// Store the second byte
utf8Output[
2
] = (
uchar
)(
0x80
| ((extendedCharacter >>
6
) &
0x3F
));
// Store the third byte
utf8Output[
3
] = (
uchar
)(
0x80
| (extendedCharacter &
0x3F
));
// Store the fourth byte
return
4
;
// Return the length of the UTF-8 representation
}
We start by determining whether the character falls within this emoji range. Since characters that lie within this range require a four-byte representation in UTF-8, we first extend the character value by performing a bitwise OR with 0x10000. This step allows us to process characters from the supplementary planes correctly.
We subsequently resize the "utf8Output" array to four bytes. This guarantees that we have sufficient space to store the entire UTF-8 encoding in the array. The calculation for the UTF-8 representation, then, is based on deriving and combining the four parts (the four bytes). For the first byte, we take the "extendedCharacter" and shift it right by 18 bits. Then we logically combine (using the bitwise OR operation, or |) this value with 0xF0 to get the appropriate "high" bits for the first byte. For the second byte, we shift the "extendedCharacter" right by 12 bits and use a similar technique to get the next part.
Similarly, we compute the third byte by right-shifting the extended character 6 bits and masking the next 6 bits. We combine this with 0x80 to get the first part of the third byte. To get the second part, we mask the extended character with 0x3F (which gives us the last 6 bits of the extended character) and combine that with 0x80. After we compute and store these two bytes in the "utf8Output" array, we return 4, indicating that the character takes 4 bytes in UTF-8. For example, we could have an emoji character 1F4B0. That is the money bag emoji.
To calculate its decimal representation, we start by converting the hexadecimal digits to decimal values. The digit 1 in the 16^4 place contributes 1×65,536=65,536. The digit F, which is 15 in decimal, in the 16^3 place contributes 15×4,096=61,440. The digit 4 in the 16^2 place contributes 4×256=1,024. The digit B, which is 11 in decimal, in the 16^1 place, contributes 11×16=176. Finally, the digit 0 in the 16^0 place contributes 0×1=0.
Adding these contributions together, we get 65,536+61,440+1,024+176+0=128,176. Therefore, 0x1F4B0 converts to 128,176 in decimal. You can confirm this in the provided image.
Lastly, we address characters that fall outside the specific ranges previously handled and need a three-byte UTF-8 representation.
else
{
ArrayResize
(utf8Output,
3
);
// Resize the array to hold three bytes
utf8Output[
0
] = (
uchar
)((character >>
12
) |
0xE0
);
// Store the first byte
utf8Output[
1
] = (
uchar
)(((character >>
6
) &
0x3F
) |
0x80
);
// Store the second byte
utf8Output[
2
] = (
uchar
)((character &
0x3F
) |
0x80
);
// Store the third byte
return
3
;
// Return the length of the UTF-8 representation
}
We begin by resizing the "utf8Output" array so it can contain the necessary three bytes. Each byte has a size of 8, so to hold three bytes, we need space for 24 bits. We then calculate in a bytewise fashion each of the three bytes of the UTF-8 encoding. The first byte is determined from the top part of the character. To calculate the second byte, we shift the character 6 bits to the right, mask the resultant value to get the next 6 bits, and combine this with 0x80 to set the continuation bits. Obtaining the third byte is conceptually the same, except we don't do any shifting. Instead, we mask to get the last 6 bits and combine them with 0x80. After determining the three bytes—which are stored in the "utf8Output" array—we return 3, indicating that the representation spans three bytes.
Finally, we have to handle cases where the character is invalid or cannot be properly encoded by replacing it with the Unicode replacement character, U+FFFD.
// Handle invalid characters by replacing with the Unicode replacement character (U+FFFD)
ArrayResize
(utf8Output,
3
);
// Resize the array to hold three bytes
utf8Output[
0
] =
0xEF
;
// Store the first byte
utf8Output[
1
] =
0xBF
;
// Store the second byte
utf8Output[
2
] =
0xBD
;
// Store the third byte
return
3
;
// Return the length of the UTF-8 representation
We begin by resizing the "utf8Output" array to three bytes, which guarantees that we have enough room for the character to be replaced. Next, we set the "utf8Output" array's bytes to the UTF-8 representation of U+FFFD. This character appears in UTF-8 as the byte sequence 0xEF, 0xBF, and 0xBD, which are the straight bytes assigned directly to "utf8Output", with 0xEF being the first byte, 0xBF being the second byte, and 0xBD being the third byte. Finally, we return 3, which indicates that the replacement character's UTF-8 representation is occupying three bytes. That is the full function that makes sure we can convert a character to UTF-8 representation. One could also use UFT-16, which is advanced, but since this does the website stuff job, let us keep everything simple. Thus, the full code for the function is as follows:
//+-----------------------------------------------------------------------+
//| Function to convert a ushort character to its UTF-8 representation    |
//+-----------------------------------------------------------------------+
int
ShortToUtf8(
const
ushort
character,
uchar
&utf8Output[]) {
// Handle single byte characters (0x00 to 0x7F)
if
(character <
0x80
) {
ArrayResize
(utf8Output,
1
);
// Resize the array to hold one byte
utf8Output[
0
] = (
uchar
)character;
// Store the character in the array
return
1
;
// Return the length of the UTF-8 representation
}
// Handle two-byte characters (0x80 to 0x7FF)
if
(character <
0x800
) {
ArrayResize
(utf8Output,
2
);
// Resize the array to hold two bytes
utf8Output[
0
] = (
uchar
)((character >>
6
) |
0xC0
);
// Store the first byte
utf8Output[
1
] = (
uchar
)((character &
0x3F
) |
0x80
);
// Store the second byte
return
2
;
// Return the length of the UTF-8 representation
}
// Handle three-byte characters (0x800 to 0xFFFF)
if
(character <
0xFFFF
) {
if
(character >=
0xD800
&& character <=
0xDFFF
) {
// Ill-formed characters
ArrayResize
(utf8Output,
1
);
// Resize the array to hold one byte
utf8Output[
0
] =
' '
;
// Replace with a space character
return
1
;
// Return the length of the UTF-8 representation
}
else
if
(character >=
0xE000
&& character <=
0xF8FF
) {
// Emoji characters
int
extendedCharacter =
0x10000
| character;
// Extend the character to four bytes
ArrayResize
(utf8Output,
4
);
// Resize the array to hold four bytes
utf8Output[
0
] = (
uchar
)(
0xF0
| (extendedCharacter >>
18
));
// Store the first byte
utf8Output[
1
] = (
uchar
)(
0x80
| ((extendedCharacter >>
12
) &
0x3F
));
// Store the second byte
utf8Output[
2
] = (
uchar
)(
0x80
| ((extendedCharacter >>
6
) &
0x3F
));
// Store the third byte
utf8Output[
3
] = (
uchar
)(
0x80
| (extendedCharacter &
0x3F
));
// Store the fourth byte
return
4
;
// Return the length of the UTF-8 representation
}
else
{
ArrayResize
(utf8Output,
3
);
// Resize the array to hold three bytes
utf8Output[
0
] = (
uchar
)((character >>
12
) |
0xE0
);
// Store the first byte
utf8Output[
1
] = (
uchar
)(((character >>
6
) &
0x3F
) |
0x80
);
// Store the second byte
utf8Output[
2
] = (
uchar
)((character &
0x3F
) |
0x80
);
// Store the third byte
return
3
;
// Return the length of the UTF-8 representation
}
    }
// Handle invalid characters by replacing with the Unicode replacement character (U+FFFD)
ArrayResize
(utf8Output,
3
);
// Resize the array to hold three bytes
utf8Output[
0
] =
0xEF
;
// Store the first byte
utf8Output[
1
] =
0xBF
;
// Store the second byte
utf8Output[
2
] =
0xBD
;
// Store the third byte
return
3
;
// Return the length of the UTF-8 representation
}
Armed with the encoding function, we can now encode our message and resend it again.
double
accountEquity =
AccountInfoDouble
(
ACCOUNT_EQUITY
);
double
accountFreeMargin =
AccountInfoDouble
(
ACCOUNT_MARGIN_FREE
);
string
msg =
"🚀EA INITIALIZED ON CHART "
+
_Symbol
+
" 🚀"
+
"\n📊Account Status 📊"
+
"\nEquity: $"
+
DoubleToString
(accountEquity,
2
)
                +
"\nFree Margin: $"
+
DoubleToString
(accountFreeMargin,
2
);
string
encloded_msg = UrlEncode(msg);
   msg = encloded_msg;
Here, we just declare a string variable named "encoded_msg" which stores our URL-encoded message, and we finally append the result to the initial message, which technically overwrites its contents instead of just declaring another variable. When we run this, this is what we get:
We can see that this was a success. We did receive the message in a structured manner. However, the emoji characters initially in the message are discarded. This is because we encoded them, and now for us to have them back, we have to input their respective formats. If you don't need to remove them, it means you hard code them, and thus, you just ignore the emoji snippet in the function. For us, let us have them in their respective format so that they can be encoded automatically.
double
accountEquity =
AccountInfoDouble
(
ACCOUNT_EQUITY
);
double
accountFreeMargin =
AccountInfoDouble
(
ACCOUNT_MARGIN_FREE
);
string
msg =
"\xF680 EA INITIALIZED ON CHART "
+
_Symbol
+
"\xF680"
+
"\n\xF4CA Account Status \xF4CA"
+
"\nEquity: $"
+
DoubleToString
(accountEquity,
2
)
                +
"\nFree Margin: $"
+
DoubleToString
(accountFreeMargin,
2
);
string
encloded_msg = UrlEncode(msg);
   msg = encloded_msg;
Here, we represent the character in "\xF***" format. If you have a word that follows the representation, make sure to use a space or a backslash "\" for distinction purposes, that is "\xF123 " or "\xF123\". When we run this, we get the following result:
We can see we now have the correct message format with all the characters encoded correctly. This is a success! We can now proceed to produce real signals.
Since the
WebRequest
function will not work on the strategy tester, and waiting for a signal generation based on moving average crossover strategy will require some time to wait for the confirmation, let us craft some other quick strategy, though we will still use the moving average strategy later, to use on the program initialization. We assess the previous bar on initialization and if it is a bullish bar, we open a buy order. Otherwise, if it is a bearish or a zero-direction bar, we open a sell order. This is as illustrated below:
The code snippet used for the logic is as below:
double
Ask =
SymbolInfoDouble
(
_Symbol
,
SYMBOL_ASK
);
double
Bid =
SymbolInfoDouble
(
_Symbol
,
SYMBOL_BID
);
double
Price_Open =
iOpen
(
_Symbol
,
_Period
,
1
);
double
Price_Close =
iClose
(
_Symbol
,
_Period
,
1
);
bool
isBuySignal = Price_Open < Price_Close;
bool
isSellSignal = Price_Open >= Price_Close;
Here, we define the price quotes, that is, the asking and bidding prices. Then, we get the opening price for the previous bar, at index 1, using the
iOpen
function, which takes 3 arguments or parameters, that is, the commodity symbol, period, and the index of the bar to get the value for. To get the closing price, the
iClose
function is used. Then we define boolean variables "isBuySignal" and "isSellSignal", which compare the values of the open and closing prices, and if the open price is less than the close price or the open price is greater than or equal to the close price, we store the buy and sell signal flags in the variables respectively.
To open the orders, we need a method.
#include
<Trade/Trade.mqh>
CTrade obj_Trade;
On the global scope, preferably at the top of the code, we include the trade class using the
#include
keyword. This gives us access to the CTrade class, which we will use to create a trade object. This is crucial as we need it to open trades.
The preprocessor will replace the line #include <Trade/Trade.mqh> with the content of the file Trade.mqh. Angle brackets indicate that the Trade.mqh file will be taken from the standard directory (usually it is terminal_installation_directory\MQL5\Include). The current directory is not included in the search. The line can be placed anywhere in the program, but usually, all inclusions are placed at the beginning of the source code, for a better code structure and easier reference. Declaration of the obj_Trade object of the CTrade class will give us access to the methods contained in that class easily, thanks to the MQL5 developers.
With these, we can now open positions.
double
lotSize =
0
, openPrice =
0
,stopLoss =
0
,takeProfit =
0
;
if
(isBuySignal ==
true
){
      lotSize =
0.01
;
      openPrice = Ask;
      stopLoss = Bid-
1000
*
_Point
;
      takeProfit = Bid+
1000
*
_Point
;
      obj_Trade.Buy(lotSize,
_Symbol
,openPrice,stopLoss,takeProfit);
   }
else
if
(isSellSignal ==
true
){
      lotSize =
0.01
;
      openPrice = Bid;
      stopLoss = Ask+
1000
*
_Point
;
      takeProfit = Ask-
1000
*
_Point
;
      obj_Trade.Sell(lotSize,
_Symbol
,openPrice,stopLoss,takeProfit);
   }
We define
double
variables to store the trading volume, the open price of the orders, the stop loss and take profit levels, and initialize them to zero. To open the positions, we first check if the "isBuySignal" contains a "true" flag, meaning that the previous bar was indeed a bull, and then open the buy position. The lot size is initialized to 0.01, the open price is the asking quote, the stop loss and take profit levels are calculated from the bidding quote, and the results are used to open the buy position. Similarly, to open the sell position, the values are computed and used in the function.
Once the positions are opened, we can now gather the information on the signal generated and the position opened in a single message, and relay it to Telegram.
string
position_type = isBuySignal ?
"Buy"
:
"Sell"
;
ushort
MONEYBAG =
0xF4B0
;
string
MONEYBAG_Emoji_code =
ShortToString
(MONEYBAG);
string
msg =
"\xF680 OPENED "
+position_type+
" POSITION."
+
"\n===================="
+
"\n"
+MONEYBAG_Emoji_code+
"Price = "
+
DoubleToString
(openPrice,
_Digits
)
          +
"\n\xF412\Time = "
+
TimeToString
(
iTime
(
_Symbol
,
_Period
,
0
),
TIME_SECONDS
)
          +
"\n\xF551\Time Current = "
+
TimeToString
(
TimeCurrent
(),
TIME_SECONDS
)
          +
"\n\xF525 Lotsize = "
+
DoubleToString
(lotSize,
2
)
          +
"\n\x274E\Stop loss = "
+
DoubleToString
(stopLoss,
_Digits
)
          +
"\n\x2705\Take Profit = "
+
DoubleToString
(takeProfit,
_Digits
)
          +
"\n_________________________"
+
"\n\xF5FD\Time Local = "
+
TimeToString
(
TimeLocal
(),
TIME_DATE
)
          +
" @ "
+
TimeToString
(
TimeLocal
(),
TIME_SECONDS
)
          ;
string
encloded_msg = UrlEncode(msg);
   msg = encloded_msg;
Here, we create a clear and precise message that contains the information related to the trading signal. We format the message with emojis and other relevant data points that we believe will make the information easy to digest for its recipients. We start by determining whether the signal is a "Buy" or "Sell" based signal, and this is achieved by the use of a
ternary operator
. Then we craft the message, including an emoji representation of a stack of money that, in our opinion, is suitable for a "Buy" or "Sell" signal. We used the actual emoji representation characters in its "ushort" format and later converted the character code to a string variable using the "ShortToString" function, to simply show that it is not a must for one to use the string formats always. However, you can see that the conversion process takes some time and space though if you want to give names to the respective characters, it is the best method.
We then put together the information on the open trading position in a string. This string, when it is converted to a message, contains the details of the trade—what kind of trade it is, what the opening price was, what the trade time was, what the current time is, what the lot size is, what the stop loss is, what the take profit is, etc. We do this in a way that makes the message somewhat visually appealing and easy to interpret.
Following the composition of the message, we call the "UrlEncode" function to encode the message for safe transmission to the URL. We especially ensure that all special characters and emojis are correctly handled and fit for the web. We then store the encoded message in a variable named "encloded_msg" and overwrite the encoded message with the initial one, or typically swap. When we run this, we get the following outcome:
You can see that we have successfully encoded the message and sent it over to Telegram in the objective structure. The full source code responsible for sending this is as follows:
//+------------------------------------------------------------------+
//|                                  TELEGRAM_MQL5_SIGNALS_PART2.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property
copyright
"Copyright 2024, MetaQuotes Ltd."
#property
link
"https://www.mql5.com"
#property
version
"1.00"
#include
<Trade/Trade.mqh>
CTrade obj_Trade;
// Define constants for Telegram API URL, bot token, and chat ID
const
string
TG_API_URL =
"https://api.telegram.org"
;
// Base URL for Telegram API
const
string
botTkn =
"7456439661:AAELUurPxI1jloZZl3Rt-zWHRDEvBk2venc"
;
// Telegram bot token
const
string
chatID =
"-4273023945"
;
// Chat ID for the Telegram chat
// The following URL can be used to get updates from the bot and retrieve the chat ID
// CHAT ID = https://api.telegram.org/bot{BOT TOKEN}/getUpdates
// https://api.telegram.org/bot7456439661:AAELUurPxI1jloZZl3Rt-zWHRDEvBk2venc/getUpdates
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int
OnInit
() {
char
data[];
// Array to hold data to be sent in the web request (empty in this case)
char
res[];
// Array to hold the response data from the web request
string
resHeaders;
// String to hold the response headers from the web request
//string msg = "EA INITIALIZED ON CHART " + _Symbol;  // Message to send, including the chart symbol
////--- Simple Notification with Emoji:
//string msg = "🚀 EA INITIALIZED ON CHART " + _Symbol + " 🚀";
////--- Buy/Sell Signal with Emoji:
//string msg = "📈 BUY SIGNAL GENERATED ON " + _Symbol + " 📈";
//string msg = "📉 SELL SIGNAL GENERATED ON " + _Symbol + " 📉";
////--- Account Balance Notification:
//double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
//string msg = "💰 Account Balance: $" + DoubleToString(accountBalance, 2) + " 💰";
////--- Trade Opened Notification:
//string orderType = "BUY";  // or "SELL"
//double lotSize = 0.1;  // Example lot size
//double price = 1.12345;  // Example price
//string msg = "🔔 " + orderType + " order opened on " + _Symbol + "; Lot size: " + DoubleToString(lotSize, 2) + "; Price: " + DoubleToString(price, 5) + " 🔔";
////--- Stop Loss and Take Profit Update:
//double stopLoss = 1.12000;  // Example stop loss
//double takeProfit = 1.13000;  // Example take profit
//string msg = "🔄 Stop Loss and Take Profit Updated on " + _Symbol + "; Stop Loss: " + DoubleToString(stopLoss, 5) + "; Take Profit: " + DoubleToString(takeProfit, 5) + " 🔄";
////--- Daily Performance Summary:
//double profitToday = 150.00;  // Example profit for the day
//string msg = "📅 Daily Performance Summary 📅; Symbol: " + _Symbol + "; Profit Today: $" + DoubleToString(profitToday, 2);
////--- Trade Closed Notification:
//string orderType = "BUY";  // or "SELL"
//double profit = 50.00;  // Example profit
//string msg = "❌ " + orderType + " trade closed on " + _Symbol + "; Profit: $" + DoubleToString(profit, 2) + " ❌";
//   ////--- Account Status Update:
//   double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
//   double accountFreeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
//   string msg = "\xF680 EA INITIALIZED ON CHART " + _Symbol + "\xF680"
//                +"\n\xF4CA Account Status \xF4CA"
//                +"\nEquity: $"
//                +DoubleToString(accountEquity,2)
//                +"\nFree Margin: $"
//                +DoubleToString(accountFreeMargin,2);
//
//   string encloded_msg = UrlEncode(msg);
//   msg = encloded_msg;
double
Ask =
SymbolInfoDouble
(
_Symbol
,
SYMBOL_ASK
);
double
Bid =
SymbolInfoDouble
(
_Symbol
,
SYMBOL_BID
);
double
Price_Open =
iOpen
(
_Symbol
,
_Period
,
1
);
double
Price_Close =
iClose
(
_Symbol
,
_Period
,
1
);
bool
isBuySignal = Price_Open < Price_Close;
bool
isSellSignal = Price_Open >= Price_Close;
double
lotSize =
0
, openPrice =
0
,stopLoss =
0
,takeProfit =
0
;
if
(isBuySignal ==
true
){
      lotSize =
0.01
;
      openPrice = Ask;
      stopLoss = Bid-
1000
*
_Point
;
      takeProfit = Bid+
1000
*
_Point
;
      obj_Trade.Buy(lotSize,
_Symbol
,openPrice,stopLoss,takeProfit);
   }
else
if
(isSellSignal ==
true
){
      lotSize =
0.01
;
      openPrice = Bid;
      stopLoss = Ask+
1000
*
_Point
;
      takeProfit = Ask-
1000
*
_Point
;
      obj_Trade.Sell(lotSize,
_Symbol
,openPrice,stopLoss,takeProfit);
   }
string
position_type = isBuySignal ?
"Buy"
:
"Sell"
;
ushort
MONEYBAG =
0xF4B0
;
string
MONEYBAG_Emoji_code =
ShortToString
(MONEYBAG);
string
msg =
"\xF680 OPENED "
+position_type+
" POSITION."
+
"\n===================="
+
"\n"
+MONEYBAG_Emoji_code+
"Price = "
+
DoubleToString
(openPrice,
_Digits
)
          +
"\n\xF412\Time = "
+
TimeToString
(
iTime
(
_Symbol
,
_Period
,
0
),
TIME_SECONDS
)
          +
"\n\xF551\Time Current = "
+
TimeToString
(
TimeCurrent
(),
TIME_SECONDS
)
          +
"\n\xF525 Lotsize = "
+
DoubleToString
(lotSize,
2
)
          +
"\n\x274E\Stop loss = "
+
DoubleToString
(stopLoss,
_Digits
)
          +
"\n\x2705\Take Profit = "
+
DoubleToString
(takeProfit,
_Digits
)
          +
"\n_________________________"
+
"\n\xF5FD\Time Local = "
+
TimeToString
(
TimeLocal
(),
TIME_DATE
)
          +
" @ "
+
TimeToString
(
TimeLocal
(),
TIME_SECONDS
)
          ;
string
encloded_msg = UrlEncode(msg);
   msg = encloded_msg;
// Construct the URL for the Telegram API request to send a message
// Format: https://api.telegram.org/bot{HTTP_API_TOKEN}/sendmessage?chat_id={CHAT_ID}&text={MESSAGE_TEXT}
const
string
url = TG_API_URL +
"/bot"
+ botTkn +
"/sendmessage?chat_id="
+ chatID +
"&text="
+ msg;
// Send the web request to the Telegram API
int
send_res =
WebRequest
(
"POST"
, url,
""
,
10000
, data, res, resHeaders);
// Check the response status of the web request
if
(send_res ==
200
) {
// If the response status is 200 (OK), print a success message
Print
(
"TELEGRAM MESSAGE SENT SUCCESSFULLY"
);
   }
else
if
(send_res == -
1
) {
// If the response status is -1 (error), check the specific error code
if
(
GetLastError
() ==
4014
) {
// If the error code is 4014, it means the Telegram API URL is not allowed in the terminal
Print
(
"PLEASE ADD THE "
, TG_API_URL,
" TO THE TERMINAL"
);
      }
// Print a general error message if the request fails
Print
(
"UNABLE TO SEND THE TELEGRAM MESSAGE"
);
   }
else
if
(send_res !=
200
) {
// If the response status is not 200 or -1, print the unexpected response code and error code
Print
(
"UNEXPECTED RESPONSE "
, send_res,
" ERR CODE = "
,
GetLastError
());
   }
return
(
INIT_SUCCEEDED
);
// Return initialization success status
}
We now need to include the trade signals based on moving average crossovers. First, we will need to declare the two moving average indicator handles and their data storage arrays.
int
handleFast =
INVALID_HANDLE
;
// -1
int
handleSlow =
INVALID_HANDLE
;
// -1
double
bufferFast[];
double
bufferSlow[];
long
magic_no =
1234567890
;
First, we declare integer data type variables named "handleFast" and "handleSlow" to house the fast and slow-moving average indicators respectively. We initialize the handles to "INVALID_HANDLE", a -1 value, signifying that they currently do not reference any valid indicator instance. We then define two
double
arrays; "bufferFast" and "bufferSlow", where we store the value we retrieve from the fast and slow indicators respectively. Finally, we declare a "long" variable to store the magic number for the positions we open. This whole logic is placed on the global scope.
On the
OnInit
function, we initialize the indicator handles and set the storage arrays as time series.
handleFast =
iMA
(
Symbol
(),
Period
(),
20
,
0
,
MODE_EMA
,
PRICE_CLOSE
);
if
(handleFast ==
INVALID_HANDLE
){
Print
(
"UNABLE TO CREATE FAST MA INDICATOR HANDLE. REVERTING NOW!"
);
return
(
INIT_FAILED
);
   }
Here, we create a handle for the fast-moving average indicator. This is done using the
iMA
function which is called with the parameters of "Symbol", "Period", 20, 0, "MODE_EMA", and "PRICE_CLOSE". The first parameter, "Symbol", is a built-in function that returns the name of the current instrument. The second parameter, "Period", returns the current timeframe. The next parameter, 20, is the number of periods for the Moving Average. The fourth parameter, 0, indicates that we want the Moving Average to be applied to the most recent price bars. The fifth parameter, "MODE_EMA", indicates that we want the Exponential Moving Average (EMA) calculated. The last parameter is the "PRICE_CLOSE", which shows that we calculate the moving average based on closing prices. This function returns a handle that uniquely identifies this moving average indicator instance and we assign it to "handleFast".
Once we have attempted to create the indicator, we verify whether the handle is valid. A result of "INVALID_HANDLE" for "handleFast" tells us that we were not able to create the handle for the fast-moving average indicator. In this case, we print a message to the log with a severity level of ERROR. The message, addressable to the user, states that the program was "UNABLE TO CREATE FAST MA INDICATOR HANDLE. REVERTING NOW!" It is made clear in the message that no handle means no indicator, which means we were not able to create the indicator handle. Since without this indic