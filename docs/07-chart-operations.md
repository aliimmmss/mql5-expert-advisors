# MQL5 Chart Operations

> Source: https://www.mql5.com/en/docs/chart_operations

Functions for working with charts programmatically.

## Chart Navigation

```mql5
// Get/set chart period
ENUM_TIMEFRAMES period = ChartPeriod(0);
ChartSetSymbolPeriod(0, _Symbol, PERIOD_H1);

// Navigate to specific time
ChartNavigate(0, CHART_BEGIN, 0);        // Go to beginning
ChartNavigate(0, CHART_END, 0);          // Go to end
ChartNavigate(0, CHART_CURRENT_POS, 100); // Scroll 100 bars right
```

## Chart Properties

```mql5
// Get chart properties
long first_vis = ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
long vis_bars = ChartGetInteger(0, CHART_VISIBLE_BARS);
long width = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
long height = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

// Set chart properties
ChartSetInteger(0, CHART_AUTOSCROLL, true);
ChartSetInteger(0, CHART_SHIFT, true);
ChartSetInteger(0, CHART_SCALE, 3);
ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
```

## Chart Objects

```mql5
// Create objects
ObjectCreate(0, "MyLine", OBJ_HLINE, 0, 0, 1.1000);
ObjectCreate(0, "MyTrend", OBJ_TREND, 0, time1, price1, time2, price2);
ObjectCreate(0, "MyText", OBJ_TEXT, 0, time, price);
ObjectCreate(0, "MyArrow", OBJ_ARROW, 0, time, price);

// Set object properties
ObjectSetInteger(0, "MyLine", OBJPROP_COLOR, clrRed);
ObjectSetInteger(0, "MyLine", OBJPROP_WIDTH, 2);
ObjectSetInteger(0, "MyLine", OBJPROP_STYLE, STYLE_DASH);
ObjectSetString(0, "MyText", OBJPROP_TEXT, "Hello");
ObjectSetString(0, "MyText", OBJPROP_FONT, "Arial");
ObjectSetInteger(0, "MyText", OBJPROP_FONTSIZE, 12);

// Delete objects
ObjectDelete(0, "MyLine");
ObjectsDeleteAll(0, "MyPrefix_");
```

## Object Types

**Lines:**
- `OBJ_HLINE` - horizontal line
- `OBJ_VLINE` - vertical line
- `OBJ_TREND` - trend line
- `OBJ_TRENDBYANGLE` - trend by angle
- `OBJ_CYCLES` - cycles

**Channels:**
- `OBJ_CHANNEL` - equidistant channel
- `OBJ_REGRESSION` - regression channel
- `OBJ_STDDEVCHANNEL` - standard deviation channel
- `OBJ_PITCHFORK` - Andrew's pitchfork

**Shapes:**
- `OBJ_RECTANGLE` - rectangle
- `OBJ_TRIANGLE` - triangle
- `OBJ_ELLIPSE` - ellipse

**Fibonacci:**
- `OBJ_FIBO` - Fibonacci retracement
- `OBJ_FIBOTIMES` - Fibonacci time zones
- `OBJ_FIBOFAN` - Fibonacci fan
- `OBJ_FIBOARC` - Fibonacci arcs
- `OBJ_FIBOCHANNEL` - Fibonacci channel

**Arrows/Labels:**
- `OBJ_ARROW` - arrow
- `OBJ_ARROW_UP` - up arrow
- `OBJ_ARROW_DOWN` - down arrow
- `OBJ_ARROW_BUY` - buy arrow
- `OBJ_ARROW_SELL` - sell arrow
- `OBJ_LABEL` - text label (screen coordinates)
- `OBJ_TEXT` - text anchored to chart coordinates

## Drawing on Chart

```mql5
// Draw a buy arrow
ObjectCreate(0, "BuySignal", OBJ_ARROW_BUY, 0, TimeCurrent(), iLow(_Symbol, _Period, 0));
ObjectSetInteger(0, "BuySignal", OBJPROP_COLOR, clrGreen);
ObjectSetInteger(0, "BuySignal", OBJPROP_WIDTH, 3);

// Draw a horizontal line for SL/TP
ObjectCreate(0, "SL_Line", OBJ_HLINE, 0, 0, sl_price);
ObjectSetInteger(0, "SL_Line", OBJPROP_COLOR, clrRed);
ObjectSetInteger(0, "SL_Line", OBJPROP_STYLE, STYLE_DASH);

// Draw text label (screen coordinates)
ObjectCreate(0, "InfoLabel", OBJ_LABEL, 0, 0, 0);
ObjectSetInteger(0, "InfoLabel", OBJPROP_XDISTANCE, 10);
ObjectSetInteger(0, "InfoLabel", OBJPROP_YDISTANCE, 30);
ObjectSetString(0, "InfoLabel", OBJPROP_TEXT, "EA Active");
ObjectSetString(0, "InfoLabel", OBJPROP_FONT, "Arial Bold");
ObjectSetInteger(0, "InfoLabel", OBJPROP_FONTSIZE, 14);
ObjectSetInteger(0, "InfoLabel", OBJPROP_COLOR, clrLime);
```

## Screen Updates

```mql5
// Redraw chart
ChartRedraw(0);

// Get chart ID
long chart_id = ChartID();

// Open new chart
long new_chart = ChartOpen(_Symbol, PERIOD_H1);

// Close chart
ChartClose(new_chart);

// Screenshot
ChartScreenShot(0, "screenshot.png", 1920, 1080, ALIGN_RIGHT);
```
