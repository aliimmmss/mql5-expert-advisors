#!/usr/bin/env python3
"""Scrape the MQL5 Book from mql5.com and save chapters as markdown files."""

import urllib.request
import time
import os
import re
from bs4 import BeautifulSoup, NavigableString, Tag
import html2text

BASE_URL = "https://www.mql5.com"
OUTPUT_DIR = os.path.expanduser("~/mql5-expert-advisors/book")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Complete ordered list of all book pages (section, sub-section pages)
# Format: (url_path, display_title, is_section_header)
BOOK_STRUCTURE = [
    # Part 1: Introduction to MQL5 and development environment
    ("/en/book/intro", "Introduction to MQL5 and development environment", True),
    ("/en/book/intro/edit_compile_run", "Editing, compiling, and running programs", False),
    ("/en/book/intro/mql_wizard", "MQL Wizard and program draft", False),
    ("/en/book/intro/statement_blocks", "Statements, code blocks, and functions", False),
    ("/en/book/intro/first_program", "First program", False),
    ("/en/book/intro/types_and_values", "Data types and values", False),
    ("/en/book/intro/variables_and_identifiers", "Variables and identifiers", False),
    ("/en/book/intro/init_assign_express", "Assignment and initialization, expressions and arrays", False),
    ("/en/book/intro/data_input", "Data input", False),
    ("/en/book/intro/errors_debug", "Error fixing and debugging", False),
    ("/en/book/intro/a_data_output", "Data output", False),
    ("/en/book/intro/b_formatting", "Formatting, indentation, and spaces", False),
    ("/en/book/intro/c_summing_up", "Mini summary", False),

    # Part 2: Programming fundamentals
    ("/en/book/basis", "Programming fundamentals", True),
    ("/en/book/basis/identifiers", "Identifiers", False),
    ("/en/book/basis/builtin_types", "Built-in types", False),
    ("/en/book/basis/variables", "Variables", False),
    ("/en/book/basis/arrays", "Arrays", False),
    ("/en/book/basis/expressions", "Expressions", False),
    ("/en/book/basis/conversion", "Type conversion", False),
    ("/en/book/basis/statements", "Statements", False),
    ("/en/book/basis/functions", "Functions", False),
    ("/en/book/basis/preprocessor", "Preprocessor", False),

    # Part 3: Object Oriented Programming
    ("/en/book/oop", "Object Oriented Programming", True),
    ("/en/book/oop/structs_and_unions", "Structures and unions", False),
    ("/en/book/oop/structs_and_unions/structs_definition", "Structure definition", False),
    ("/en/book/oop/structs_and_unions/structs_assignment", "Structure assignment", False),
    ("/en/book/oop/structs_and_unions/structs_access", "Access to structure members", False),
    ("/en/book/oop/structs_and_unions/structs_composition", "Structure composition", False),
    ("/en/book/oop/structs_and_unions/structs_ctor_dtor", "Constructors and destructors", False),
    ("/en/book/oop/structs_and_unions/structs_methods", "Structure methods", False),
    ("/en/book/oop/structs_and_unions/structs_pack_dll", "Structures for DLL", False),
    ("/en/book/oop/structs_and_unions/unions", "Unions", False),
    ("/en/book/oop/classes_and_interfaces", "Classes and interfaces", False),
    ("/en/book/oop/classes_and_interfaces/classes_declaration_definition", "Class declaration and definition", False),
    ("/en/book/oop/classes_and_interfaces/classes_definition", "Class definition", False),
    ("/en/book/oop/classes_and_interfaces/classes_access_rights", "Access rights", False),
    ("/en/book/oop/classes_and_interfaces/classes_encapsulation", "Encapsulation", False),
    ("/en/book/oop/classes_and_interfaces/classes_ctors", "Constructors", False),
    ("/en/book/oop/classes_and_interfaces/classes_dtors", "Destructors", False),
    ("/en/book/oop/classes_and_interfaces/classes_this", "this pointer", False),
    ("/en/book/oop/classes_and_interfaces/classes_static", "Static members", False),
    ("/en/book/oop/classes_and_interfaces/classes_inheritance", "Inheritance", False),
    ("/en/book/oop/classes_and_interfaces/classes_polymorphism", "Polymorphism", False),
    ("/en/book/oop/classes_and_interfaces/classes_abstraction", "Abstraction", False),
    ("/en/book/oop/classes_and_interfaces/classes_abstract_interfaces", "Abstract classes and interfaces", False),
    ("/en/book/oop/classes_and_interfaces/classes_pointers", "Pointers to objects", False),
    ("/en/book/oop/classes_and_interfaces/classes_new_delete_pointers", "new, delete, and pointers", False),
    ("/en/book/oop/classes_and_interfaces/classes_ref_pointers_const", "References, pointers, and const", False),
    ("/en/book/oop/classes_and_interfaces/classes_composition", "Composition", False),
    ("/en/book/oop/classes_and_interfaces/classes_namespace_context", "Namespaces and context", False),
    ("/en/book/oop/classes_and_interfaces/classes_operator_overloading", "Operator overloading", False),
    ("/en/book/oop/classes_and_interfaces/classes_oop_inheritance", "OOP inheritance", False),
    ("/en/book/oop/classes_and_interfaces/classes_virtual_override", "Virtual methods and override", False),
    ("/en/book/oop/classes_and_interfaces/classes_dynamic_cast_void", "Dynamic cast and void pointers", False),
    ("/en/book/oop/classes_and_interfaces/classes_final_delete", "Final and delete", False),
    ("/en/book/oop/templates", "Templates", False),
    ("/en/book/oop/templates/templates_principles", "Template principles", False),
    ("/en/book/oop/templates/templates_functions", "Template functions", False),
    ("/en/book/oop/templates/templates_header", "Template header", False),
    ("/en/book/oop/templates/templates_methods", "Template methods", False),
    ("/en/book/oop/templates/templates_objects", "Template objects", False),
    ("/en/book/oop/templates/templates_nested", "Nested templates", False),
    ("/en/book/oop/templates/templates_for_standard_and_object_types", "Templates for standard and object types", False),
    ("/en/book/oop/templates/templates_specialization", "Template specialization", False),
    ("/en/book/oop/templates/templates_vs_macro", "Templates vs macros", False),

    # Part 4: Common APIs
    ("/en/book/common", "Common APIs", True),
    ("/en/book/common/conversions", "Conversions", False),
    ("/en/book/common/conversions/conversions_numbers", "Number conversions", False),
    ("/en/book/common/conversions/conversions_datetime", "Date/time conversions", False),
    ("/en/book/common/conversions/conversions_color", "Color conversions", False),
    ("/en/book/common/conversions/conversions_enums", "Enum conversions", False),
    ("/en/book/common/conversions/conversions_normalize", "Normalize", False),
    ("/en/book/common/conversions/conversions_complex", "Complex conversions", False),
    ("/en/book/common/conversions/conversions_structs", "Struct conversions", False),
    ("/en/book/common/strings", "Strings", False),
    ("/en/book/common/strings/strings_init", "String initialization", False),
    ("/en/book/common/strings/strings_concatenation", "String concatenation", False),
    ("/en/book/common/strings/strings_comparison", "String comparison", False),
    ("/en/book/common/strings/strings_case_trim", "Case and trim", False),
    ("/en/book/common/strings/strings_find_replace_split", "Find, replace, split", False),
    ("/en/book/common/strings/strings_format", "String formatting", False),
    ("/en/book/common/strings/strings_codepages", "String codepages", False),
    ("/en/book/common/arrays", "Arrays", False),
    ("/en/book/common/arrays/arrays_dynamic", "Dynamic arrays", False),
    ("/en/book/common/arrays/arrays_init_fill", "Array initialization and fill", False),
    ("/en/book/common/arrays/arrays_as_series", "Arrays as series", False),
    ("/en/book/common/arrays/arrays_edit", "Array editing", False),
    ("/en/book/common/arrays/arrays_metrics", "Array metrics", False),
    ("/en/book/common/arrays/arrays_compare_sort_search", "Compare, sort, search", False),
    ("/en/book/common/arrays/arrays_move_swap", "Move and swap", False),
    ("/en/book/common/arrays/arrays_print", "Array print", False),
    ("/en/book/common/arrays/zero_memory", "Zero memory", False),
    ("/en/book/common/maths", "Math functions", False),
    ("/en/book/common/maths/maths_max_min", "Max and min", False),
    ("/en/book/common/maths/maths_abs", "Absolute value", False),
    ("/en/book/common/maths/maths_mod", "Modulus", False),
    ("/en/book/common/maths/maths_rounding", "Rounding", False),
    ("/en/book/common/maths/maths_pow_sqrt", "Power and sqrt", False),
    ("/en/book/common/maths/maths_exp_log", "Exp and log", False),
    ("/en/book/common/maths/maths_trig", "Trigonometric functions", False),
    ("/en/book/common/maths/maths_hyper", "Hyperbolic functions", False),
    ("/en/book/common/maths/maths_rand", "Random numbers", False),
    ("/en/book/common/maths/maths_nan", "NaN handling", False),
    ("/en/book/common/maths/maths_byte_swap", "Byte swap", False),
    ("/en/book/common/files", "File operations", False),
    ("/en/book/common/files/files_folders", "File folders", False),
    ("/en/book/common/files/files_exist_delete", "File existence and deletion", False),
    ("/en/book/common/files/files_copy_move", "File copy and move", False),
    ("/en/book/common/files/files_find", "File find", False),
    ("/en/book/common/files/files_open_close", "File open and close", False),
    ("/en/book/common/files/files_handles", "File handles", False),
    ("/en/book/common/files/files_modes_bin_txt", "Binary and text modes", False),
    ("/en/book/common/files/files_txt_codepage", "Text file codepages", False),
    ("/en/book/common/files/files_txt_atomic", "Atomic text file operations", False),
    ("/en/book/common/files/files_bin_structs", "Binary file structures", False),
    ("/en/book/common/files/files_bin_atomic", "Atomic binary file operations", False),
    ("/en/book/common/files/files_arrays", "File arrays", False),
    ("/en/book/common/files/files_cursor", "File cursor", False),
    ("/en/book/common/files/files_flush", "File flush", False),
    ("/en/book/common/files/files_save_load", "File save and load", False),
    ("/en/book/common/files/files_properties", "File properties", False),
    ("/en/book/common/files/files_select", "File select", False),
    ("/en/book/common/globals", "Global variables", False),
    ("/en/book/common/globals/globals_set_get", "Set and get globals", False),
    ("/en/book/common/globals/globals_exist_time", "Global existence time", False),
    ("/en/book/common/globals/globals_delete", "Delete globals", False),
    ("/en/book/common/globals/globals_flush", "Flush globals", False),
    ("/en/book/common/globals/globals_list", "List globals", False),
    ("/en/book/common/globals/globals_condition", "Global conditions", False),
    ("/en/book/common/globals/globals_temp", "Temporary globals", False),
    ("/en/book/common/timing", "Date and time", False),
    ("/en/book/common/timing/timing_gmt", "GMT time", False),
    ("/en/book/common/timing/timing_local_server", "Local and server time", False),
    ("/en/book/common/timing/timing_count", "Time counting", False),
    ("/en/book/common/timing/timing_daylight_saving", "Daylight saving", False),
    ("/en/book/common/timing/timing_sleep", "Sleep", False),
    ("/en/book/common/output", "Output functions", False),
    ("/en/book/common/output/output_print", "Print", False),
    ("/en/book/common/output/output_alert", "Alert", False),
    ("/en/book/common/output/output_comment", "Comment", False),
    ("/en/book/common/output/output_messagebox", "MessageBox", False),
    ("/en/book/common/output/output_sound", "Sound", False),
    ("/en/book/common/environment", "Terminal environment", False),
    ("/en/book/common/environment/env_mode", "Environment mode", False),
    ("/en/book/common/environment/env_build", "Build info", False),
    ("/en/book/common/environment/env_connectivity", "Connectivity", False),
    ("/en/book/common/environment/env_resources", "Resources", False),
    ("/en/book/common/environment/env_screen", "Screen info", False),
    ("/en/book/common/environment/env_keyboard", "Keyboard", False),
    ("/en/book/common/environment/env_last_error", "Last error", False),
    ("/en/book/common/environment/env_user_error", "User error", False),
    ("/en/book/common/environment/env_debug_break", "Debug break", False),
    ("/en/book/common/environment/env_stop", "Stop", False),
    ("/en/book/common/environment/env_terminal_close", "Terminal close", False),
    ("/en/book/common/environment/env_permissions", "Permissions", False),
    ("/en/book/common/environment/env_constants", "Constants", False),
    ("/en/book/common/environment/env_listing", "Listing", False),
    ("/en/book/common/environment/env_bar_lang", "Bar and language", False),
    ("/en/book/common/environment/env_descriptive", "Descriptive", False),
    ("/en/book/common/environment/env_signature", "Signature", False),
    ("/en/book/common/environment/env_type_license", "Type and license", False),
    ("/en/book/common/environment/env_variables", "Environment variables", False),
    ("/en/book/common/matrices", "Matrices and vectors", False),
    ("/en/book/common/matrices/matrices_init", "Matrix initialization", False),
    ("/en/book/common/matrices/matrices_types", "Matrix types", False),
    ("/en/book/common/matrices/matrices_manipulations", "Matrix manipulations", False),
    ("/en/book/common/matrices/matrices_mul", "Matrix multiplication", False),
    ("/en/book/common/matrices/matrices_expressions", "Matrix expressions", False),
    ("/en/book/common/matrices/matrices_characteristics", "Matrix characteristics", False),
    ("/en/book/common/matrices/matrices_decomposition", "Matrix decomposition", False),
    ("/en/book/common/matrices/matrices_sle", "Systems of linear equations", False),
    ("/en/book/common/matrices/matrices_stats", "Matrix statistics", False),
    ("/en/book/common/matrices/matrices_ml", "Matrix ML", False),
    ("/en/book/common/matrices/matrices_copy", "Matrix copy", False),
    ("/en/book/common/matrices/matrices_copyrates", "Copy rates to matrix", False),
    ("/en/book/common/matrices/matrices_copyticks", "Copy ticks to matrix", False),

    # Part 5: Creating application programs
    ("/en/book/applications", "Creating application programs", True),
    ("/en/book/applications/runtime", "Runtime", False),
    ("/en/book/applications/runtime/runtime_lifecycle", "Program lifecycle", False),
    ("/en/book/applications/runtime/runtime_oninit_ondeinit", "OnInit and OnDeinit", False),
    ("/en/book/applications/runtime/runtime_onstart", "OnStart", False),
    ("/en/book/applications/runtime/runtime_events_overview", "Events overview", False),
    ("/en/book/applications/runtime/runtime_features_by_progtype", "Features by program type", False),
    ("/en/book/applications/runtime/runtime_threads", "Threads", False),
    ("/en/book/applications/runtime/runtime_remove", "Remove program", False),
    ("/en/book/applications/script_service", "Scripts and services", False),
    ("/en/book/applications/script_service/scripts", "Scripts", False),
    ("/en/book/applications/script_service/services", "Services", False),
    ("/en/book/applications/script_service/script_service_limitations", "Script/service limitations", False),
    ("/en/book/applications/timeseries", "Time series", False),
    ("/en/book/applications/timeseries/timeseries_symbol_period", "Symbol and period", False),
    ("/en/book/applications/timeseries/timeseries_copy_funcs_overview", "Copy functions overview", False),
    ("/en/book/applications/timeseries/timeseries_ohlcvs", "OHLCV data", False),
    ("/en/book/applications/timeseries/timeseries_bars", "Bars", False),
    ("/en/book/applications/timeseries/timeseries_single_value", "Single value access", False),
    ("/en/book/applications/timeseries/timeseries_highest_lowest", "Highest and lowest", False),
    ("/en/book/applications/timeseries/timeseries_ibarshift", "iBarShift", False),
    ("/en/book/applications/timeseries/timeseries_mqlrates", "MqlRates", False),
    ("/en/book/applications/timeseries/timeseries_ticks_mqltick", "Ticks and MqlTick", False),
    ("/en/book/applications/timeseries/timeseries_properties", "Time series properties", False),
    ("/en/book/applications/timeseries/timeseries_storage_tech", "Storage technology", False),
    ("/en/book/applications/indicators_make", "Creating indicators", False),
    ("/en/book/applications/indicators_make/indicators_features", "Indicator features", False),
    ("/en/book/applications/indicators_make/indicators_begin", "Indicator basics", False),
    ("/en/book/applications/indicators_make/indicators_buffers_plots", "Buffers and plots", False),
    ("/en/book/applications/indicators_make/indicators_buffer_to_plot_mapping", "Buffer to plot mapping", False),
    ("/en/book/applications/indicators_make/indicators_setindexbuffer", "SetIndexBuffer", False),
    ("/en/book/applications/indicators_make/indicators_plotindexsetinteger", "PlotIndexSetInteger", False),
    ("/en/book/applications/indicators_make/indicators_empty_value", "Empty values", False),
    ("/en/book/applications/indicators_make/indicators_color", "Indicator colors", False),
    ("/en/book/applications/indicators_make/indicators_labels", "Indicator labels", False),
    ("/en/book/applications/indicators_make/indicators_caption_digits", "Caption and digits", False),
    ("/en/book/applications/indicators_make/indicators_separate_window", "Separate window", False),
    ("/en/book/applications/indicators_make/indicators_window_chart_separate", "Window vs chart", False),
    ("/en/book/applications/indicators_make/indicators_properties", "Indicator properties", False),
    ("/en/book/applications/indicators_make/indicators_oncalculate", "OnCalculate", False),
    ("/en/book/applications/indicators_make/indicators_newbars", "New bars detection", False),
    ("/en/book/applications/indicators_make/indicators_multisymbol", "Multi-symbol indicators", False),
    ("/en/book/applications/indicators_make/indicators_wait_none", "Wait mode none", False),
    ("/en/book/applications/indicators_make/indicators_limitations", "Indicator limitations", False),
    ("/en/book/applications/indicators_make/indicators_wizard", "Indicator wizard", False),
    ("/en/book/applications/indicators_make/indicators_test", "Testing indicators", False),
    ("/en/book/applications/indicators_use", "Using indicators", False),
    ("/en/book/applications/indicators_use/indicators_standard", "Standard indicators", False),
    ("/en/book/applications/indicators_use/indicators_standard_use", "Standard indicator usage", False),
    ("/en/book/applications/indicators_use/indicators_chart_plus_subwindow", "Chart and subwindow", False),
    ("/en/book/applications/indicators_use/indicators_chart_review", "Chart review", False),
    ("/en/book/applications/indicators_use/indicators_apply_to", "Apply to", False),
    ("/en/book/applications/indicators_use/indicators_shifted", "Shifted indicators", False),
    ("/en/book/applications/indicators_use/indicators_descriptors", "Indicator descriptors", False),
    ("/en/book/applications/indicators_use/indicators_parameters", "Indicator parameters", False),
    ("/en/book/applications/indicators_use/indicators_copybuffer", "CopyBuffer", False),
    ("/en/book/applications/indicators_use/indicators_barscalculated", "BarsCalculated", False),
    ("/en/book/applications/indicators_use/indicators_indicatorcreate", "IndicatorCreate", False),
    ("/en/book/applications/indicators_use/indicators_flexible_create", "Flexible indicator creation", False),
    ("/en/book/applications/indicators_use/indicators_indicatorrelease", "IndicatorRelease", False),
    ("/en/book/applications/indicators_use/indicators_multitimeframe", "Multi-timeframe indicators", False),
    ("/en/book/applications/indicators_use/indicators_icustom", "iCustom", False),
    ("/en/book/applications/timer", "Timer", False),
    ("/en/book/applications/timer/timer_ontimer", "OnTimer", False),
    ("/en/book/applications/timer/timer_event_set", "EventSetTimer", False),
    ("/en/book/applications/timer/timer_event_set_millisecond", "Millisecond timer", False),
    ("/en/book/applications/charts", "Charts", False),
    ("/en/book/applications/charts/charts_id", "Chart ID", False),
    ("/en/book/applications/charts/charts_open_close", "Open and close charts", False),
    ("/en/book/applications/charts/charts_list", "Chart list", False),
    ("/en/book/applications/charts/charts_symbol_period", "Chart symbol and period", False),
    ("/en/book/applications/charts/charts_set_symbol_period", "Set symbol and period", False),
    ("/en/book/applications/charts/charts_main_properties", "Main chart properties", False),
    ("/en/book/applications/charts/charts_properties_overview", "Chart properties overview", False),
    ("/en/book/applications/charts/charts_string_properties", "Chart string properties", False),
    ("/en/book/applications/charts/charts_scale_time", "Time scale", False),
    ("/en/book/applications/charts/charts_scale_price", "Price scale", False),
    ("/en/book/applications/charts/charts_shift", "Chart shift", False),
    ("/en/book/applications/charts/charts_mode", "Chart mode", False),
    ("/en/book/applications/charts/charts_count_visibility", "Count and visibility", False),
    ("/en/book/applications/charts/charts_color", "Chart colors", False),
    ("/en/book/applications/charts/charts_navigate", "Chart navigation", False),
    ("/en/book/applications/charts/charts_redraw", "Chart redraw", False),
    ("/en/book/applications/charts/charts_screenshot", "Chart screenshot", False),
    ("/en/book/applications/charts/charts_coordinates", "Chart coordinates", False),
    ("/en/book/applications/charts/charts_floating", "Floating charts", False),
    ("/en/book/applications/charts/charts_indicators", "Chart indicators", False),
    ("/en/book/applications/charts/charts_keyboard_mouse", "Keyboard and mouse", False),
    ("/en/book/applications/charts/charts_show_elements", "Show elements", False),
    ("/en/book/applications/charts/charts_window_state", "Window state", False),
    ("/en/book/applications/charts/charts_tpl", "Chart templates", False),
    ("/en/book/applications/charts/charts_on_drop", "OnDrop event", False),
    ("/en/book/applications/objects", "Graphical objects", False),
    ("/en/book/applications/objects/objects_main_characteristics", "Main object characteristics", False),
    ("/en/book/applications/objects/objects_create", "Create objects", False),
    ("/en/book/applications/objects/objects_find", "Find objects", False),
    ("/en/book/applications/objects/objects_delete", "Delete objects", False),
    ("/en/book/applications/objects/objects_move", "Move objects", False),
    ("/en/book/applications/objects/objects_properties_get_set", "Get/set properties", False),
    ("/en/book/applications/objects/objects_properties_main", "Main properties", False),
    ("/en/book/applications/objects/objects_time_price_coordinates", "Time-price coordinates", False),
    ("/en/book/applications/objects/objects_time_price", "Time and price", False),
    ("/en/book/applications/objects/objects_get_time_value", "Get time value", False),
    ("/en/book/applications/objects/objects_screen_coordinates", "Screen coordinates", False),
    ("/en/book/applications/objects/objects_corner_x_y", "Corner, X, Y", False),
    ("/en/book/applications/objects/objects_anchor", "Object anchor", False),
    ("/en/book/applications/objects/objects_angle", "Object angle", False),
    ("/en/book/applications/objects/objects_color_style", "Color and style", False),
    ("/en/book/applications/objects/objects_width_height", "Width and height", False),
    ("/en/book/applications/objects/objects_font", "Object font", False),
    ("/en/book/applications/objects/objects_levels", "Object levels", False),
    ("/en/book/applications/objects/objects_rays", "Object rays", False),
    ("/en/book/applications/objects/objects_arrow_codes", "Arrow codes", False),
    ("/en/book/applications/objects/objects_bitmap", "Bitmap objects", False),
    ("/en/book/applications/objects/objects_bitmap_offset", "Bitmap offset", False),
    ("/en/book/applications/objects/objects_edit", "Edit objects", False),
    ("/en/book/applications/objects/objects_state", "Object state", False),
    ("/en/book/applications/objects/objects_pressed_state", "Pressed state", False),
    ("/en/book/applications/objects/objects_chart", "Object chart", False),
    ("/en/book/applications/objects/objects_timeframes", "Object timeframes", False),
    ("/en/book/applications/objects/objects_z_order", "Z-order", False),
    ("/en/book/applications/objects/objects_gann_fibo_elliott", "Gann, Fibonacci, Elliott", False),
    ("/en/book/applications/objects/objects_stddev_channel", "StdDev channel", False),
    ("/en/book/applications/events", "Events", False),
    ("/en/book/applications/events/events_chart", "Chart events", False),
    ("/en/book/applications/events/events_objects", "Object events", False),
    ("/en/book/applications/events/events_mouse", "Mouse events", False),
    ("/en/book/applications/events/events_keyboard", "Keyboard events", False),
    ("/en/book/applications/events/events_custom", "Custom events", False),
    ("/en/book/applications/events/events_onchartevent", "OnChartEvent", False),
    ("/en/book/applications/events/events_properties", "Event properties", False),

    # Part 6: Trading automation
    ("/en/book/automation", "Trading automation", True),
    ("/en/book/automation/symbols", "Symbols", False),
    ("/en/book/automation/account", "Account", False),
    ("/en/book/automation/marketbook", "Market book (DOM)", False),
    ("/en/book/automation/experts", "Expert Advisors", False),
    ("/en/book/automation/experts/experts_ontick", "OnTick", False),
    ("/en/book/automation/experts/experts_order_deal_position", "Orders, deals, positions", False),
    ("/en/book/automation/experts/experts_request_types", "Request types", False),
    ("/en/book/automation/experts/experts_mqltraderequest", "MqlTradeRequest", False),
    ("/en/book/automation/experts/experts_mqltradecheckresult", "MqlTradeCheckResult", False),
    ("/en/book/automation/experts/experts_mqltraderesult", "MqlTradeResult", False),
    ("/en/book/automation/experts/experts_execution_filling", "Execution and filling", False),
    ("/en/book/automation/experts/experts_market_buy_sell", "Market buy and sell", False),
    ("/en/book/automation/experts/experts_ordercheck", "OrderCheck", False),
    ("/en/book/automation/experts/experts_ordersend_ordersendasync", "OrderSend", False),
    ("/en/book/automation/experts/experts_sync_vs_async", "Sync vs async", False),
    ("/en/book/automation/experts/experts_pending", "Pending orders", False),
    ("/en/book/automation/experts/experts_pending_expiration", "Pending order expiration", False),
    ("/en/book/automation/experts/experts_modify_order", "Modify orders", False),
    ("/en/book/automation/experts/experts_remove_order", "Remove orders", False),
    ("/en/book/automation/experts/experts_position_list", "Position list", False),
    ("/en/book/automation/experts/experts_positionget_funcs", "PositionGet functions", False),
    ("/en/book/automation/experts/experts_position_properties", "Position properties", False),
    ("/en/book/automation/experts/experts_modify_position", "Modify positions", False),
    ("/en/book/automation/experts/experts_close", "Close positions", False),
    ("/en/book/automation/experts/experts_closeby", "CloseBy", False),
    ("/en/book/automation/experts/experts_order_list", "Order list", False),
    ("/en/book/automation/experts/experts_orderget_funcs", "OrderGet functions", False),
    ("/en/book/automation/experts/experts_order_properties", "Order properties", False),
    ("/en/book/automation/experts/experts_order_type", "Order types", False),
    ("/en/book/automation/experts/experts_order_filter", "Order filter", False),
    ("/en/book/automation/experts/experts_history_select", "History select", False),
    ("/en/book/automation/experts/experts_historydealget_funcs", "HistoryDealGet functions", False),
    ("/en/book/automation/experts/experts_historyorderget_funcs", "HistoryOrderGet functions", False),
    ("/en/book/automation/experts/experts_deal_properties", "Deal properties", False),
    ("/en/book/automation/experts/experts_transaction_type", "Transaction types", False),
    ("/en/book/automation/experts/experts_ontrade", "OnTrade", False),
    ("/en/book/automation/experts/experts_ontradetransaction", "OnTradeTransaction", False),
    ("/en/book/automation/experts/experts_trade_state", "Trade state", False),
    ("/en/book/automation/experts/experts_ordercalcmargin", "OrderCalcMargin", False),
    ("/en/book/automation/experts/experts_ordercalcprofit", "OrderCalcProfit", False),
    ("/en/book/automation/experts/experts_multisymbol", "Multi-symbol trading", False),
    ("/en/book/automation/experts/experts_trailing_stop", "Trailing stop", False),
    ("/en/book/automation/experts/experts_limitations", "EA limitations", False),
    ("/en/book/automation/experts/experts_wizard", "EA wizard", False),
    ("/en/book/automation/tester", "Strategy tester", False),
    ("/en/book/automation/tester/tester_time", "Tester time", False),
    ("/en/book/automation/tester/tester_ticks", "Tester ticks", False),
    ("/en/book/automation/tester/tester_math_calc", "Math calculations in tester", False),
    ("/en/book/automation/tester/tester_example_ea", "Example EA", False),
    ("/en/book/automation/tester/tester_criterion", "Optimization criterion", False),
    ("/en/book/automation/tester/tester_parameterrange", "Parameter range", False),
    ("/en/book/automation/tester/tester_directives", "Tester directives", False),
    ("/en/book/automation/tester/tester_multicurrency_sync", "Multi-currency sync", False),
    ("/en/book/automation/tester/tester_chart_limits", "Chart limits in tester", False),
    ("/en/book/automation/tester/tester_debug_profile", "Debug and profile", False),
    ("/en/book/automation/tester/tester_limitations", "Tester limitations", False),
    ("/en/book/automation/tester/tester_ontester", "OnTester", False),
    ("/en/book/automation/tester/tester_ontester_init_pass_deinit", "Tester init/deinit", False),
    ("/en/book/automation/tester/tester_testerstatistics", "TesterStatistics", False),
    ("/en/book/automation/tester/tester_testerstop", "TesterStop", False),
    ("/en/book/automation/tester/tester_testerhideindicators", "TesterHideIndicators", False),
    ("/en/book/automation/tester/tester_frameadd", "FrameAdd", False),
    ("/en/book/automation/tester/tester_framenext", "FrameNext", False),
    ("/en/book/automation/tester/tester_withdraw_deposit", "Withdraw and deposit", False),

    # Part 7: Advanced language tools
    ("/en/book/advanced", "Advanced language tools", True),
    ("/en/book/advanced/custom_symbols", "Custom symbols", False),
    ("/en/book/advanced/custom_symbols/custom_symbols_create_delete", "Create and delete custom symbols", False),
    ("/en/book/advanced/custom_symbols/custom_symbols_properties", "Custom symbol properties", False),
    ("/en/book/advanced/custom_symbols/custom_symbols_rates", "Custom symbol rates", False),
    ("/en/book/advanced/custom_symbols/custom_symbols_ticks", "Custom symbol ticks", False),
    ("/en/book/advanced/custom_symbols/custom_symbols_sessions", "Custom symbol sessions", False),
    ("/en/book/advanced/custom_symbols/custom_symbols_margin", "Custom symbol margin", False),
    ("/en/book/advanced/custom_symbols/custom_symbols_market_book", "Custom symbol market book", False),
    ("/en/book/advanced/custom_symbols/custom_symbols_trade_specifics", "Custom symbol trade specifics", False),
    ("/en/book/advanced/calendar", "Economic calendar", False),
    ("/en/book/advanced/calendar/calendar_overview", "Calendar overview", False),
    ("/en/book/advanced/calendar/calendar_countries", "Calendar countries", False),
    ("/en/book/advanced/calendar/calendar_event_kinds_by_country_currency", "Event kinds by country", False),
    ("/en/book/advanced/calendar/calendar_event_kind_by_id", "Event kind by ID", False),
    ("/en/book/advanced/calendar/calendar_records_by_country_currency", "Records by country", False),
    ("/en/book/advanced/calendar/calendar_records_by_event_kind", "Records by event kind", False),
    ("/en/book/advanced/calendar/calendar_record_by_id", "Record by ID", False),
    ("/en/book/advanced/calendar/calendar_change_last", "Change last", False),
    ("/en/book/advanced/calendar/calendar_change_last_by_event", "Change last by event", False),
    ("/en/book/advanced/calendar/calendar_filter_custom", "Custom filter", False),
    ("/en/book/advanced/calendar/calendar_cache_tester", "Calendar cache tester", False),
    ("/en/book/advanced/calendar/calendar_trading", "Calendar trading", False),
    ("/en/book/advanced/crypt", "Cryptography", False),
    ("/en/book/advanced/crypt/crypt_overview", "Cryptography overview", False),
    ("/en/book/advanced/crypt/crypt_encode", "Encode", False),
    ("/en/book/advanced/crypt/crypt_decode", "Decode", False),
    ("/en/book/advanced/network", "Network", False),
    ("/en/book/advanced/network/network_email", "Email", False),
    ("/en/book/advanced/network/network_ftp", "FTP", False),
    ("/en/book/advanced/network/network_push", "Push notifications", False),
    ("/en/book/advanced/network/network_http", "HTTP", False),
    ("/en/book/advanced/network/network_socket_create_connect", "Socket create and connect", False),
    ("/en/book/advanced/network/network_socket_state", "Socket state", False),
    ("/en/book/advanced/network/network_socket_send_read", "Socket send and read", False),
    ("/en/book/advanced/network/network_socket_timeouts", "Socket timeouts", False),
    ("/en/book/advanced/network/network_socket_tls_handshake_cert", "TLS handshake and cert", False),
    ("/en/book/advanced/network/network_socket_tls_send_read", "TLS send and read", False),
    ("/en/book/advanced/sqlite", "SQLite", False),
    ("/en/book/advanced/sqlite/sqlite_overview", "SQLite overview", False),
    ("/en/book/advanced/sqlite/sqlite_intro", "SQLite introduction", False),
    ("/en/book/advanced/sqlite/sqlite_db_create_open_close", "Database create, open, close", False),
    ("/en/book/advanced/sqlite/sqlite_simple_queries", "Simple queries", False),
    ("/en/book/advanced/sqlite/sqlite_prepare", "Prepare statements", False),
    ("/en/book/advanced/sqlite/sqlite_bind", "Bind parameters", False),
    ("/en/book/advanced/sqlite/sqlite_read", "Read data", False),
    ("/en/book/advanced/sqlite/sqlite_columns", "Columns", False),
    ("/en/book/advanced/sqlite/sqlite_print", "Print data", False),
    ("/en/book/advanced/sqlite/sqlite_reset", "Reset", False),
    ("/en/book/advanced/sqlite/sqlite_scheme_types", "Scheme types", False),
    ("/en/book/advanced/sqlite/sqlite_crud_examples", "CRUD examples", False),
    ("/en/book/advanced/sqlite/sqlite_table_exists", "Table exists", False),
    ("/en/book/advanced/sqlite/sqlite_transactions", "Transactions", False),
    ("/en/book/advanced/sqlite/sqlite_export_import", "Export and import", False),
    ("/en/book/advanced/sqlite/sqlite_orm", "ORM", False),
    ("/en/book/advanced/sqlite/sqlite_example_ts", "Example time series", False),
    ("/en/book/advanced/libraries", "Libraries", False),
    ("/en/book/advanced/libraries/libraries_path_lookup", "Path lookup", False),
    ("/en/book/advanced/libraries/libraries_export", "Export", False),
    ("/en/book/advanced/libraries/libraries_import", "Import", False),
    ("/en/book/advanced/libraries/libraries_class_template", "Class template", False),
    ("/en/book/advanced/libraries/libraries_dll", "DLL", False),
    ("/en/book/advanced/libraries/libraries_dotnet", ".NET", False),
    ("/en/book/advanced/project", "Projects", False),
    ("/en/book/advanced/project/project_mqproj", "MQProj", False),
    ("/en/book/advanced/project/project_websockets", "WebSockets", False),
    ("/en/book/advanced/project/project_websocket_server", "WebSocket server", False),
    ("/en/book/advanced/project/project_websocket_mql5", "WebSocket MQL5", False),
    ("/en/book/advanced/project/project_nodejs", "Node.js", False),
    ("/en/book/advanced/project/project_echo_chat_mql5", "Echo chat MQL5", False),
    ("/en/book/advanced/project/project_web_service_plan", "Web service plan", False),
    ("/en/book/advanced/project/project_trade_signal_server", "Trade signal server", False),
    ("/en/book/advanced/project/project_trade_signal_client_mql5", "Trade signal client", False),
    ("/en/book/advanced/python", "Python integration", False),
    ("/en/book/advanced/python/python_install", "Python install", False),
    ("/en/book/advanced/python/python_init", "Python init", False),
    ("/en/book/advanced/python/python_funcs_overview", "Python functions overview", False),
    ("/en/book/advanced/python/python_account_info", "Account info", False),
    ("/en/book/advanced/python/python_symbols", "Symbols", False),
    ("/en/book/advanced/python/python_copyrates", "Copy rates", False),
    ("/en/book/advanced/python/python_copyticks", "Copy ticks", False),
    ("/en/book/advanced/python/python_positions", "Positions", False),
    ("/en/book/advanced/python/python_orders", "Orders", False),
    ("/en/book/advanced/python/python_ordercheck_ordersend", "OrderCheck and OrderSend", False),
    ("/en/book/advanced/python/python_history_deals", "History deals", False),
    ("/en/book/advanced/python/python_terminal_info", "Terminal info", False),
    ("/en/book/advanced/python/python_margin_profit", "Margin and profit", False),
    ("/en/book/advanced/python/python_marketbook", "Market book", False),
    ("/en/book/advanced/python/python_last_error", "Last error", False),
    ("/en/book/advanced/resources", "Resources", False),
    ("/en/book/advanced/resources/resources_directive", "Resource directive", False),
    ("/en/book/advanced/resources/resources_variables", "Resource variables", False),
    ("/en/book/advanced/resources/resources_sharing", "Resource sharing", False),
    ("/en/book/advanced/resources/resources_indicators", "Resource indicators", False),
    ("/en/book/advanced/resources/resources_applied_usecase", "Applied use case", False),
    ("/en/book/advanced/resources/resources_textout", "TextOut", False),
    ("/en/book/advanced/resources/resources_resourcecreate", "ResourceCreate", False),
    ("/en/book/advanced/resources/resources_resourcereadimage", "ResourceReadImage", False),
    ("/en/book/advanced/resources/resources_resourcesave", "ResourceSave", False),
    ("/en/book/advanced/resources/resources_resourcefree", "ResourceFree", False),

    # Conclusion
    ("/en/book/conclusion", "Conclusion", True),
]


def sanitize_filename(title):
    """Convert a title to a safe filename."""
    # Convert to lowercase
    name = title.lower()
    # Replace non-alphanumeric chars with hyphens
    name = re.sub(r'[^a-z0-9]+', '-', name)
    # Strip leading/trailing hyphens
    name = name.strip('-')
    # Collapse multiple hyphens
    name = re.sub(r'-+', '-', name)
    return name


def fetch_page(url_path):
    """Fetch a page and return its HTML content."""
    url = BASE_URL + url_path
    req = urllib.request.Request(url, headers={
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
    })
    try:
        resp = urllib.request.urlopen(req, timeout=30)
        return resp.read().decode('utf-8')
    except Exception as e:
        print(f"  ERROR fetching {url}: {e}")
        return None


def html_to_markdown(help_div, title):
    """Convert the help div content to markdown, preserving code blocks."""
    if not help_div:
        return f"# {title}\n\n*Content could not be retrieved.*\n"

    lines = [f"# {title}\n"]

    # Process all direct children of help_div
    for element in help_div.children:
        if isinstance(element, NavigableString):
            text = str(element).strip()
            if text:
                lines.append(text)
            continue

        if not isinstance(element, Tag):
            continue

        # Get the paragraph class
        classes = element.get('class', [])
        class_str = ' '.join(classes) if classes else ''

        # Code examples
        if 'p_CodeExample' in class_str:
            code_text = element.get_text()
            # Replace non-breaking spaces with regular spaces
            code_text = code_text.replace('\xa0', ' ')
            lines.append("```")
            lines.append(code_text)
            lines.append("```")
            continue

        # Images
        if 'p_ImageCaption' in class_str:
            img = element.find('img')
            if img:
                src = img.get('src', '')
                if src and not src.startswith('http'):
                    src = BASE_URL + src
                caption = element.get_text().strip()
                if caption:
                    lines.append(f"![{caption}]({src})")
                elif src:
                    lines.append(f"![]({src})")
            continue

        # Regular text
        if 'p_Text' in class_str or element.name in ['p', 'div']:
            # Convert inner HTML to markdown
            h = html2text.HTML2Text()
            h.body_width = 0
            h.protect_links = True
            h.ignore_images = False
            text = h.handle(str(element)).strip()
            if text:
                lines.append(text)
            continue

        # Handle headers
        if element.name in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']:
            level = int(element.name[1])
            prefix = '#' * (level + 1)  # +1 because our title is already h1
            text = element.get_text().strip()
            if text:
                lines.append(f"{prefix} {text}")
            continue

        # Handle lists
        if element.name in ['ul', 'ol']:
            h = html2text.HTML2Text()
            h.body_width = 0
            h.protect_links = True
            text = h.handle(str(element)).strip()
            if text:
                lines.append(text)
            continue

        # Handle tables
        if element.name == 'table':
            h = html2text.HTML2Text()
            h.body_width = 0
            h.protect_links = True
            text = h.handle(str(element)).strip()
            if text:
                lines.append(text)
            continue

        # Handle horizontal rules
        if element.name == 'hr':
            lines.append("---")
            continue

        # Fallback: convert to markdown
        text = element.get_text().strip()
        if text:
            # Check if it's a special separator used on mql5
            if text == '---':
                lines.append("---")
            else:
                lines.append(text)

    # Clean up excessive blank lines
    result = '\n'.join(lines)
    result = re.sub(r'\n{4,}', '\n\n\n', result)
    return result


def main():
    total = len(BOOK_STRUCTURE)
    print(f"Scraping {total} pages from MQL5 Book...\n")

    # Track section numbers for better file naming
    current_part = 0
    chapter_num = 0

    for i, (url_path, title, is_section) in enumerate(BOOK_STRUCTURE):
        chapter_num += 1
        prefix = f"{chapter_num:03d}"
        filename = f"{prefix}-{sanitize_filename(title)}.md"
        filepath = os.path.join(OUTPUT_DIR, filename)

        print(f"[{chapter_num}/{total}] {title}")
        print(f"  URL: {BASE_URL + url_path}")
        print(f"  File: {filename}")

        html = fetch_page(url_path)
        if html:
            soup = BeautifulSoup(html, 'html.parser')
            help_div = soup.find('div', id='help')
            markdown = html_to_markdown(help_div, title)

            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(markdown)

            print(f"  Saved ({len(markdown)} bytes)")
        else:
            # Create placeholder
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(f"# {title}\n\n*Content could not be retrieved.*\nSource: {BASE_URL + url_path}\n")
            print(f"  Saved placeholder")

        # Rate limit: 0.5 second between requests
        if i < total - 1:
            time.sleep(0.5)

    # Create an index file
    index_lines = ["# MQL5 Programming for Traders\n",
                    f"*Book scraped from [mql5.com/en/book]({BASE_URL}/en/book)*\n",
                    f"*Author: Stanislav Korotky*\n",
                    f"Total chapters: {total}\n\n"]
    for i, (url_path, title, is_section) in enumerate(BOOK_STRUCTURE):
        prefix = f"{i+1:03d}"
        filename = f"{prefix}-{sanitize_filename(title)}.md"
        if is_section:
            index_lines.append(f"\n## [{title}]({filename})\n")
        else:
            indent = "  " if not is_section else ""
            index_lines.append(f"{indent}- [{title}]({filename})")

    index_path = os.path.join(OUTPUT_DIR, "000-INDEX.md")
    with open(index_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(index_lines))
    print(f"\nIndex saved: {index_path}")

    print(f"\nDone! Scraped {total} chapters to {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
