########################################################################
########################################################################
# module ???
########################################################################

    TOOL_DESCRIPTOR     = "LFSR generator"
    TOOL_DESCRIPTXX     = "              "              # there's probably a way to do something like " "*(TOOL_DESCRIPTOR.size) but …

    ########################################################################
    # example run command
    #    % crystal run --error-trace lfsr.cr -- -Hv -i1 -n2 -C +clk -R -rst_n -L lfsr -T fib --generate modules --generate logic
    ########################################################################

    # language and library setup

    require "json"
    require "option_parser"

    ####################################
    # constants

    TT_INPUT            = "ai"
    TT_OUTPUT           = "ao"
    TT_INPUT_OUTPUT     = "aio"
    TT_INPUT_OUTPUT_EN  = "aio_en"

    # **** could validate that LFSR[i][0] == i... ****

    lfsr_init_value  = 1              # kwr::HACK--- initializing to a 1 value rather than something smarter (and contained in the table for generality?)

    NULL_2TAP  = [-1, -1]

    # **** this table uses 1-based taps, thus SIZE..1, not (SIZE-1)..0

    LFSR_2TAP  =  [
                      NULL_2TAP, #  0 # **** [0] represents the invalid entry (can't have an 2-tap LFSR with length 0!) ****
                      NULL_2TAP, #  1 # **** [0] represents the invalid entry (can't have an 2-tap LFSR with length 0!) ****
                      [ 2,  1],  #  2 # 4,
                      [ 3,  2],  #  3 # 8,
                      [ 4,  3],  #  4 # 16,
                      [ 5,  3],  #  5 # 32,
                      [ 6,  5],  #  6 # 64,
                      [ 7,  6],  #  7 # 128,
                      NULL_2TAP, #  8 # 256,
                      [ 9,  5],  #  9 # 512,
                      [10,  7],  # 10 # 1024,
                      [11,  9],  # 11 # 2048,
                      NULL_2TAP, # 12 # 4096,
                      NULL_2TAP, # 13 # 8192,
                      NULL_2TAP, # 14 # 16384,
                      [15, 14],  # 15 # 32768,
                      NULL_2TAP, # 16 # 65536,
                      [17, 14],  # 17 # 131072,
                      [18, 11],  # 18 # 262144,
                      NULL_2TAP, # 19 # 524288,
                      [20, 17],  # 20 # 1048576,
                      [21, 19],  # 21 # 2097152,
                      [22, 21],  # 22 # 4194304,
                      [23, 18],  # 23 # 8388608,
                      NULL_2TAP, # 24 # 16777216,
                      [25, 22],  # 25 # 33554432,
                      NULL_2TAP, # 26 # 67108864,
                      NULL_2TAP, # 27 # 134217728,
                      [28, 25],  # 28 # 268435456,
                      [29, 27],  # 29 # 536870912,
                      NULL_2TAP, # 30 # 1073741824,
                      [31, 28],  # 31 # 2147483648,
                      NULL_2TAP, # 32 # 4294967296,
                      [33, 20],  # 33 # 8589934592,
                      NULL_2TAP, # 34 # 17179869184,
                      [35, 33],  # 35 # 34359738368,
                      [36, 25],  # 36 # 68719476736,
                      NULL_2TAP, # 37 # 137439000000,
                      NULL_2TAP, # 38 # 274878000000,
                      [39, 35],  # 39 # 549756000000,
                      NULL_2TAP, # 40 # 1099510000000,
                      [41, 38],  # 41 # 2199020000000,
                      NULL_2TAP, # 42 # 4398050000000,
                      NULL_2TAP, # 43 # 8796090000000,
                      NULL_2TAP, # 44 # 17592200000000,
                      NULL_2TAP, # 45 # 35184400000000,
                      NULL_2TAP, # 46 # 70368700000000,
                      [47, 42],  # 47 # 140737000000000,
                      NULL_2TAP, # 48 # 281475000000000,
                      [49, 40],  # 49 # 562950000000000,
                      NULL_2TAP, # 50 # 1.1259E+15,
                      NULL_2TAP, # 51 # 2.2518E+15,
                      [52, 49],  # 52 # 4.5036E+15,
                      NULL_2TAP, # 53 # 9.0072E+15,
                      NULL_2TAP, # 54 # 1.80144E+16,
                      [55, 31],  # 55 # 3.60288E+16,
                      NULL_2TAP, # 56 # 7.20576E+16,
                      [57, 50],  # 57 # 1.44115E+17,
                      [58, 39],  # 58 # 2.8823E+17,
                      NULL_2TAP, # 59 # 5.76461E+17,
                      [60, 59],  # 60 # 1.15292E+18,
                      NULL_2TAP, # 61 # 2.30584E+18,
                      NULL_2TAP, # 62 # 4.61169E+18,
                      [63, 62],  # 63 # 9.22337E+18,
                      NULL_2TAP, # 64 # 1.84467E+19,
                      [65, 47],  # 65 # 3.68935E+19,
                      NULL_2TAP, # 66 # 7.3787E+19,
                      NULL_2TAP, # 67 # 1.47574E+20,
                  ]

    TAPS_2TAP  = 2
    MAX_2TAP   = LFSR_2TAP.size - 1

    ##################

    NULL_4TAP  = [-1, -1, -1, -1]

    # **** this table uses 1-based taps, thus SIZE..1, not (SIZE-1)..0

    LFSR_4TAP  =  [
                      NULL_4TAP,          #  0 # **** [0] represents the invalid entry (can't have an 4-tap LFSR with length 0!) ****
                      NULL_4TAP,          #  1 # **** [0] represents the invalid entry (can't have an 4-tap LFSR with length 1!) ****
                      NULL_4TAP,          #  2 # **** [0] represents the invalid entry (can't have an 4-tap LFSR with length 2!) ****
                      NULL_4TAP,          #  3 # **** [0] represents the invalid entry (can't have an 4-tap LFSR with length 3!) ****
                      NULL_4TAP,          #  4 #
                      [ 5,  4,  3,  2],   #  5 # 32,
                      [ 6,  5,  3,  2],   #  6 # 64,
                      [ 7,  6,  5,  4],   #  7 # 128,
                      [ 8,  6,  5,  4],   #  8 # 256,
                      [ 9,  8,  6,  5],   #  9 # 512,
                      [10,  9,  7,  6],   # 10 # 1024,
                      [11, 10,  9,  7],   # 11 # 2048,
                      [12, 11,  8,  6],   # 12 # 4096,
                      [13, 12, 10,  9],   # 13 # 8192,
                      [14, 13, 11,  9],   # 14 # 16384,
                      [15, 14, 13, 11],   # 15 # 32768,
                      [16, 14, 13, 11],   # 16 # 65536,
                      [17, 16, 15, 14],   # 17 # 131072,
                      [18, 17, 16, 13],   # 18 # 262144,
                      [19, 18, 17, 14],   # 19 # 524288,
                      [20, 19, 16, 14],   # 20 # 1048576,
                      [21, 20, 19, 16],   # 21 # 2097152,
                      [22, 19, 18, 17],   # 22 # 4194304,
                      [23, 22, 20, 18],   # 23 # 8388608,
                      [24, 23, 21, 20],   # 24 # 16777216,
                      [25, 24, 23, 22],   # 25 # 33554432,
                      [26, 25, 24, 20],   # 26 # 67108864,
                      [27, 26, 25, 22],   # 27 # 134217728,
                      [28, 27, 24, 22],   # 28 # 268435456,
                      [29, 28, 27, 25],   # 29 # 536870912,
                      [30, 29, 26, 24],   # 30 # 1073741824,
                      [31, 30, 29, 28],   # 31 # 2147483648,
                      [32, 30, 26, 25],   # 32 # 4294967296,
                      [33, 32, 29, 27],   # 33 # 8589934592,
                      [34, 31, 30, 26],   # 34 # 17179869184,
                      [35, 34, 28, 27],   # 35 # 34359738368,
                      [36, 35, 29, 28],   # 36 # 68719476736,
                      [37, 36, 33, 31],   # 37 # 137439000000,
                      [38, 37, 33, 32],   # 38 # 274878000000,
                      [39, 38, 35, 32],   # 39 # 549756000000,
                      [40, 37, 36, 35],   # 40 # 1099510000000,
                      [41, 40, 39, 38],   # 41 # 2199020000000,
                      [42, 40, 37, 35],   # 42 # 4398050000000,
                      [43, 42, 38, 37],   # 43 # 8796090000000,
                      [44, 42, 39, 38],   # 44 # 17592200000000,
                      [45, 44, 42, 41],   # 45 # 35184400000000,
                      [46, 40, 39, 38],   # 46 # 70368700000000,
                      [47, 46, 43, 42],   # 47 # 140737000000000,
                      [48, 44, 41, 39],   # 48 # 281475000000000,
                      [49, 45, 44, 43],   # 49 # 562950000000000,
                      [50, 48, 47, 46],   # 50 # 1.1259E+15,
                      [51, 50, 48, 45],   # 51 # 2.2518E+15,
                      [52, 51, 49, 46],   # 52 # 4.5036E+15,
                      [53, 52, 51, 47],   # 53 # 9.0072E+15,
                      [54, 51, 48, 46],   # 54 # 1.80144E+16,
                      [55, 54, 53, 49],   # 55 # 3.60288E+16,
                      [56, 54, 52, 49],   # 56 # 7.20576E+16,
                      [57, 55, 54, 52],   # 57 # 1.44115E+17,
                      [58, 57, 53, 52],   # 58 # 2.8823E+17,
                      [59, 57, 55, 52],   # 59 # 5.76461E+17,
                      [60, 58, 56, 55],   # 60 # 1.15292E+18,
                      [61, 60, 59, 56],   # 61 # 2.30584E+18,
                      [62, 59, 57, 56],   # 62 # 4.61169E+18,
                      [63, 62, 59, 58],   # 63 # 9.22337E+18,
                      [64, 63, 61, 60],   # 64 # 1.84467E+19,
                      [65, 64, 62, 61],   # 65 # 3.68935E+19,
                      [66, 60, 58, 57],   # 66 # 7.3787E+19,
                      [67, 66, 65, 62],   # 67 # 1.47574E+20,
                  ]

    TAPS_4TAP  = 4
    MAX_4TAP   = LFSR_4TAP.size - 1

    ##################

    DQ                 = '"'
    SQ                 = "'"
    DQED_SQ            = DQ + SQ + DQ           # there has to be a better way....
    SQED_DQ            = SQ + DQ + SQ           # there has to be a better way....

    ##################
    ##################

    enum    Language
        Unknown
        #
        Verilog
        VHDL
        SystemVerilog
    end # enum

    #########

    enum    Polarity
        Unknown
        #
        Positive
        Negative
    end # enum

    #########

    enum    Type
        Unknown
        #
        Fibonacci
        # Galois
    end # enum

    #########

    enum    Generate
        Unknown
        #
        # All
        Header
        Modules
        Logic
        Test_LFSR
        Test_Logic
    end # enum

    ##################
    ##################

    class Option_State
        include JSON::Serializable

        property  what
        property  language

        property  type
        property  lfsr_init_value
        property  lfsr_length_bound
        property  lfsr_length_max
        property  lfsr_length_size

        #property  tap_table
        #property  tap_table_null
        #property  tap_table_max
        #property  tap_table_n_taps

        property  lfsr_symbol
        property  clock_symbol
        property  reset_symbol

        property  clock_polarity
        property  reset_polarity

        #########

        @what               : Generate
        @language           : Language

        @type               : Type
        @lfsr_init_value    : Int32             # could be inadequate; instead, could be an array of non-zero bits which should be set using a generated sequence of (1 << a[i]) | ...
        @lfsr_length_bound  : Int32
        @lfsr_length_max    : Int32
        @lfsr_length_size   : Int32

        #@tap_table          : Array(Array(Int32))
        #@tap_table_null     : Array(Int32)
        #@tap_table_max      : Int32
        #@tap_table_n_taps   : Int32

        @lfsr_symbol        : String
        @clock_symbol       : String
        @reset_symbol       : String

        @clock_polarity     : Polarity
        @reset_polarity     : Polarity

        #########

        def initialize
            @what               = Generate::Unknown
            @language           = Language::Unknown

            @type               = Type::Unknown
            @lfsr_init_value    = 0
            @lfsr_length_bound  = 0
            @lfsr_length_max    = 0
            @lfsr_length_size   = 0

            #@tap_table          = [] of Array(Int32)
            #@tap_table_null     = [] of Int32
            #@tap_table_max      = 0
            #@tap_table_n_taps   = 0

            @lfsr_symbol        = ""
            @clock_symbol       = ""
            @reset_symbol       = ""

            @clock_polarity     = Polarity::Unknown
            @reset_polarity     = Polarity::Unknown
        end # def

        ##################

        def to_generate(what : String)
            if (what == "")
                puts "Must specify what code to generate"
                exit -1
            else
                wtest  = what.downcase

                case (what)
                  when "header"
                    @what  = Generate::Header

                  when "modules"
                    @what  = Generate::Modules

                  when "logic"
                    @what  = Generate::Logic

                  when "test_lfsr"
                    @what  = Generate::Test_LFSR

                  when "test_logic"
                    @what  = Generate::Test_Logic

                  else
                    puts "Don't know how to generate #{what}"
                    exit -1
                end # case
            end # if

            #########

            if (@language == Language::Unknown)
                puts "Must specify the language"
            end # if

            #########

            if (@type == Type::Unknown)
                puts "Must specify the LFSR type"
                exit -1
            end # if

            #########

            # kwr::WARN!!!! this test only works for a two-tap configuration; it fails for a four-tap configuration (but is verified later during generation????)
            #if ((@lfsr_length_max < 2) || (@lfsr_length_max > @tap_table_max))
            if ((@lfsr_length_max < 2) || (@lfsr_length_bound < 2))
                puts "LFSR length maximum #{@lfsr_length_max} and bound #{@lfsr_length_bound} must be at least 2"
                exit -1
            end # if

            #########

            #if (@n_taps != @tap_table_n_taps)
            #    puts "LFSR taps #{@n_taps} must match tap-table taps #{@tap_table_n_taps}b LFSR"
            #    exit -1
            #end # if

            #########

            if (@lfsr_init_value == 0)
                puts "LFSR initial value #{@lfsr_init_value} must be specified (and be non-zero!)"
                exit -1
            end # if

            #########

            if ((what == Generate::Logic) && (@lfsr_symbol  == ""))
                puts "Must specify the LFSR symbol"
                exit -1
            end # if

            #########

            if (@clock_symbol == "")
                puts "Must specify the clock symbol"
                exit -1
            end # if

            #########

            if (@reset_symbol == "")
                puts "Must specify the reset symbol"
                exit -1
            end # if

            #########

            if (@clock_polarity == Polarity::Unknown)
                puts "Must specify the clock polarity"
                exit -1
            end # if

            #########

            if (@reset_polarity == Polarity::Unknown)
                puts "Must specify the reset polarity"
                exit -1
            end # if

            #########

            #which_taps  = @tap_table[@lfsr_length_max]
            #if (which_taps == @tap_table_null)
            #    puts "There is no valid LSFR of length #{@lfsr_length_max} with #{@n_taps} taps"
            #    exit -1
            #elsif (which_taps.size != @n_taps)
            #    puts "Mismatch between number of taps specified in the tap table #{which_taps.size} and the requested #{@n_taps}"
            #    exit -1
            #end # if

            #########

            return (self.dup)
        end # def create_generate
    end # class Option_State

    ########################################################################

    class HDL_Generator
        @@hdl_classes  = Hash(Language, self.class).new
        @@generated    = false

        ##################

        # add subclass works fine so long as it is invoked
        # as HDL_Generator.add_subclass without specific typing;
        # what it doesn't do is to allow HDL_Generator subclasses to be used
        # or, so far, to allow indirect (dynamic-class) method invocation

        # for better or worse, each class now has its own class variables
        # and do not share the top-level declaring class's class variables.

        # for args, can use gt : Language but not gc : HDL_Generator...

        # currently we end up with gc : HDL_Generator.class rather than HDL_Generator as the type;
        # the former doesn't seem right (with what i understand at the moment) but does seem to work
        # while the latter doesn't work

        def self.add_subclass(gt : Language, gc : self.class) : Nil
            @@hdl_classes[gt]  = gc
        end

        ##################

        def self.generate(gen_opts) : Nil
            lang  = gen_opts.language
            gc    = @@hdl_classes[lang]

            if (gc.nil?)
                puts "No generator class available for language #{lang}"
                exit -1
            end # if

            puts ""         if (@@generated)

            what  = gen_opts.what

            #gc.generate_modules(gen_opts)

            #case (what)
            #  when Generate::Modules
            #    gc.generate_modules(gen_opts)

            #  when Generate::LFSR
            #    gc.generate_logic(gen_opts)

            #  else
            #    puts "Don't know how to generate a #{what}"
            #    exit -1
            #end # case

            case (what)
              when Generate::Header
                case (lang)
                  when Language::Verilog
                    Verilog_Generator        .generate_header(gen_opts)

                  when Language::SystemVerilog
                    SystemVerilog_Generator  .generate_header(gen_opts)

                  when Language::VHDL
                    VHDL_Generator           .generate_header(gen_opts)

                  else
                    puts "Don't know how to generate modules RTL for #{lang}"
                    exit -1
                end # case

              when Generate::Modules
                case (lang)
                  when Language::Verilog
                    Verilog_Generator        .generate_modules(gen_opts)

                  when Language::SystemVerilog
                    SystemVerilog_Generator  .generate_modules(gen_opts)

                  when Language::VHDL
                    VHDL_Generator           .generate_modules(gen_opts)

                  else
                    puts "Don't know how to generate modules RTL for #{lang}"
                    exit -1
                end # case

              when Generate::Logic
                case (lang)
                  when Language::Verilog
                    Verilog_Generator        .generate_logic(gen_opts)

                  when Language::SystemVerilog
                    SystemVerilog_Generator  .generate_logic(gen_opts)

                  when Language::VHDL
                    VHDL_Generator           .generate_logic(gen_opts)

                  else
                    puts "Don't know how to generate logic RTL for #{lang}"
                    exit -1
                end # case

              when Generate::Test_LFSR
                case (lang)
                  when Language::Verilog
                    Verilog_Generator        .generate_test_lfsr(gen_opts)

                  when Language::SystemVerilog
                    SystemVerilog_Generator  .generate_test_lfsr(gen_opts)

                  when Language::VHDL
                    VHDL_Generator           .generate_test_lfsr(gen_opts)

                  else
                    puts "Don't know how to generate test_lfsr RTL for #{lang}"
                    exit -1
                end # case

              when Generate::Test_Logic
                case (lang)
                  when Language::Verilog
                    Verilog_Generator        .generate_test_logic(gen_opts)

                  when Language::SystemVerilog
                    SystemVerilog_Generator  .generate_test_logic(gen_opts)

                  when Language::VHDL
                    VHDL_Generator           .generate_test_logic(gen_opts)

                  else
                    puts "Don't know how to generate test_logic RTL for #{lang}"
                    exit -1
                end # case

              else
                puts "Don't know how to generate a #{what}"
                exit -1
            end # case

            @@generated  = true

        end # def self.generate
    end # class HDL_Generator

    ####################################

    class Verilog_Generator       < HDL_Generator
        HDL_Generator.add_subclass(Language::Verilog, self)

        ##################

        def self.generate_header(gen_opts) : Nil
            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// @BEGIN Header"
            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""

            puts "`ifndef _tt09_kwr_lfsr__header_"
            puts "`define _tt09_kwr_lfsr__header_"

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""

            puts "// ////////////////////////////////////"
            puts "// Copyright (c) 2024 Kevin W. Rudd"
            puts "// SPDX-License-Identifier: Apache-2.0"
            puts "// ////////////////////////////////////"

            puts ""

            puts "`default_nettype    none"

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""

            puts "`endif // _tt09_kwr_lfsr__header_"

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// @END Header\n"
            puts "// ////////////////////////////////////////////////////////////////////////"
        end # def self.generate_modules

        ##################

        def self.puts_io_parameters : Nil
            # puts "    // verilator lint_off UNUSEDSIGNAL"

            puts ""

            puts "    // input IO connections"
            puts "    parameter    UI_IN_HOLD               = 7;"
            puts "    parameter    UI_IN_STEP               = 6;"
            puts "    parameter    UI_IN_N_TAPS             = 5;"
            puts "    parameter    UI_IN_LENGTH_4           = 4;"
            puts "    parameter    UI_IN_LENGTH_3           = 3;"
            puts "    parameter    UI_IN_LENGTH_2           = 2;"
            puts "    parameter    UI_IN_LENGTH_1           = 1;"
            puts "    parameter    UI_IN_LENGTH_0           = 0;"

            puts ""

            puts "    // bidirectional IO connections (Static)"
            puts "    parameter    UIO_OUT_VALID            = 7;"
            puts "    parameter    UIO_OUT_VALUE_14         = 6;"
            puts "    parameter    UIO_OUT_VALUE_13         = 5;"
            puts "    parameter    UIO_OUT_VALUE_12         = 4;"
            puts "    parameter    UIO_OUT_VALUE_11         = 3;"
            puts "    parameter    UIO_OUT_VALUE_10         = 2;"
            puts "    parameter    UIO_OUT_VALUE_09         = 1;"
            puts "    parameter    UIO_OUT_VALUE_08         = 0;"

            puts ""

            puts "    // bidirectional IO output-enable (Static)"
            puts "    parameter    UIO_OE                   = 8'b11111111;"

            puts ""

            puts "    // output IO connections (Static)"
            puts "    parameter    UO_OUT_VALUE_07          = 7;"
            puts "    parameter    UO_OUT_VALUE_06          = 6;"
            puts "    parameter    UO_OUT_VALUE_05          = 5;"
            puts "    parameter    UO_OUT_VALUE_04          = 4;"
            puts "    parameter    UO_OUT_VALUE_03          = 3;"
            puts "    parameter    UO_OUT_VALUE_02          = 2;"
            puts "    parameter    UO_OUT_VALUE_01          = 1;"
            puts "    parameter    UO_OUT_VALUE_00          = 0;"

            # puts "    // verilator lint_on UNUSEDSIGNAL"
        end # def self.puts_io_parameters

        ##################

        def self.generate_modules_feedback_mask(gen_opts, n_taps)
            case n_taps
              when 2
                tap_table         = LFSR_2TAP
                tap_table_null    = NULL_2TAP
                tap_table_max     = MAX_2TAP
                tap_table_n_taps  = TAPS_2TAP

              when 4
                tap_table         = LFSR_4TAP
                tap_table_null    = NULL_4TAP
                tap_table_max     = MAX_4TAP
                tap_table_n_taps  = TAPS_4TAP

              else
                puts "LFSR taps must be 2 or 4 (provided #{n_taps})"
                exit -1
            end # case

            lfsr_length_bound  = gen_opts.lfsr_length_bound

            # kwr::QUERY??? should we instead cap it at the maximum size and warn the user?
            if (lfsr_length_bound > tap_table_max)
                puts "LFSR length #{lfsr_length_bound} is greater than the tap-table maximum length #{tap_table_max}"
                exit -1
            end

            case (gen_opts.type)
              when Type::Fibonacci
                lfsr_length_max   = gen_opts.lfsr_length_max
                lfsr_length_size  = gen_opts.lfsr_length_size

                puts "module generate_mask_fibonacci_#{n_taps}_taps"
                puts "("
                puts "    input  wire [#{lfsr_length_size - 1}:0]    lfsr_length,"

                puts ""

                puts "    output reg  [#{lfsr_length_max  - 1}:0]   mask_value,"
                puts "    output reg           mask_valid"
                puts ");"

                puts ""

                puts "    always @(*)"
                puts "    begin"

                # kwr::HACK--- should probably fix the width parameter more cleanly, but this is the simplest hack that doesn't add more generation state/inconsistency…
                puts "        case (lfsr_length)"

                in_lb   = 0
                in_ub   = imin(lfsr_length_max, lfsr_length_bound) - 1

                in_lb.upto(in_ub) \
                do | i |
                    if (i > tap_table_max)
                        puts "Unexpected invalid LFSR length #{i} > #{tap_table_max}"
                    end # if

                    taps  = tap_table[i]

                    if (taps != tap_table_null)
                        valid  = 1

                    else
                        taps   = [] of Int32                                         # no taps...
                        valid  = 0
                    end # if

                    # kwr::FIXME!!!! inefficient code…
                    # generate the mask inefficiently due to crystal strings behavior
                    # as this approach generates ~lfsr_length_max strings
                    # which could be done quicker by testing for index inclusion in the taps array
                    # but … this version seems to work … which is good enough for now!

                    mask  = "0" * lfsr_length_bound

                    # **** the tables use 1-based taps, thus SIZE..1, not (SIZE-1)..0
                    taps.each { | t | mask  = mask.sub(lfsr_length_bound - t, "1"); }

                    # kwr::HACK!!!! fixes layout for two digits…
                    if (i < 10)
                        puts "               #{lfsr_length_size}'d0#{i} : begin mask_value   = #{lfsr_length_bound}'b#{mask}; mask_valid  = #{valid}; end"
                    else
                        puts  "               #{lfsr_length_size}'d#{i} : begin mask_value   = #{lfsr_length_bound}'b#{mask}; mask_valid  = #{valid}; end"
                    end # if
                end # do

                out_lb  = in_ub + 1
                out_ub  = lfsr_length_max - 1

                #mask    = "x" * lfsr_length_bound                                                  # could we get hugely-better results with casex and "x"?
                mask    = "0" * lfsr_length_bound

                out_lb.upto(out_ub) \
                do | i |
                    # kwr::HACK!!!! fixes layout for two digits…
                    if (i < 10)
                        puts "               #{lfsr_length_size}'d0#{i} : begin mask_value   = #{lfsr_length_bound}'b#{mask}; mask_valid  = 0; end"
                    else
                        puts "               #{lfsr_length_size}'d#{i} : begin mask_value   = #{lfsr_length_bound}'b#{mask}; mask_valid  = 0; end"
                    end # if
                end # do

                puts "             default : begin mask_value   = #{lfsr_length_bound}'b#{mask}; mask_valid  = 0; end"
                puts "        endcase"
# puts "$display(#{DQ}$$$$ n_taps=#{n_taps} lfsr_length=%d, mask_value=0b%064b mask_valid=0b%b#{DQ}, lfsr_length, mask_value, mask_valid);"
                puts "    end // always"

                puts ""

                puts "endmodule // generate_mask_fibonacci_"

              # when Type::Galois
              #   # TBD....

              else
                puts "Feedback type #{gen_opts.type} unimplemented"
                exit -1
            end # case type
        end # def self.generate_modules_feedback_mask

        ##################

        def self.generate_modules_shift_register(gen_opts)
            clock_symbol      = gen_opts.clock_symbol
            clock_polarity    = gen_opts.clock_polarity

            reset_symbol      = gen_opts.reset_symbol
            reset_polarity    = gen_opts.reset_polarity

            lfsr_length_max   = gen_opts.lfsr_length_max
            lfsr_length_size  = gen_opts.lfsr_length_size
            lfsr_init_value   = gen_opts.lfsr_init_value

            puts "module lfsr_fibonacci"
            puts "("
            puts "    input  wire           clk,"
            puts "    input  wire           rst_n,"

            puts "    input  wire  [#{lfsr_length_size - 1}:0]    lfsr_length,"
            puts "    input  wire           lfsr_n_taps,"

            puts ""

            puts "    output reg  [#{lfsr_length_max - 1}:0]    lfsr_value,"
            puts "    output reg            lfsr_valid"
            puts ");"

            puts ""

            puts "    wire        [#{lfsr_length_max - 1}:0]    mask_value_2_taps;"
            puts "    wire                  mask_valid_2_taps;"

            puts ""

            puts "    generate_mask_fibonacci_2_taps    gmf2t"
            puts "    ("
            puts "        .lfsr_length(lfsr_length),"
            puts "        .mask_value(mask_value_2_taps),"
            puts "        .mask_valid(mask_valid_2_taps)"
            puts "    );"

            puts ""

            puts "    wire        [#{lfsr_length_max - 1}:0]    mask_value_4_taps;"
            puts "    wire                  mask_valid_4_taps;"

            puts ""

            puts "    generate_mask_fibonacci_4_taps    gmf4t"
            puts "    ("
            puts "        .lfsr_length(lfsr_length),"
            puts "        .mask_value(mask_value_4_taps),"
            puts "        .mask_valid(mask_valid_4_taps)"
            puts "    );"

            puts ""

            puts "    reg         [#{lfsr_length_max - 1}:0]    mask_value;"
            puts "    reg                   mask_valid;"

            puts ""

            # puts "    reg         [#{lfsr_length_max - 1}:0]    lfsr_value_prev;"
            # puts "    reg                   lfsr_valid_prev;"

            # puts ""

            puts "    always @(*)"
            puts "    begin"
            puts "        if      (lfsr_n_taps)"
            puts "        begin"
            puts "            mask_value  = mask_value_4_taps;"
            puts "            mask_valid  = mask_valid_4_taps;"
            puts "        end"

            puts "        else"
            puts "        begin"
            puts "            mask_value  = mask_value_2_taps;"
            puts "            mask_valid  = mask_valid_2_taps;"
            puts "        end"
            puts "        // endif"
            puts "    end // always"

            puts ""

            puts "    always @(#{polarity?(clock_polarity, pos: "posedge ", neg: "negedge ")}#{clock_symbol},"
            puts "             #{polarity?(reset_polarity, pos: "posedge ", neg: "negedge ")}#{reset_symbol})"
            puts "    begin"

            puts "        if      (#{polarity?(reset_polarity, pos: "", neg: "~")}#{reset_symbol})"
                                # should lfsr_init_value be specified in the table (at the 0-length position?) as tap-dependent?
                                # or are all maximal-length lfsr 2^n - 1 with 0 being the only invalid & stable state?
            puts "        begin"

            puts "            // initialize current value/valid"
            puts "            lfsr_value       <= #{lfsr_length_max}'d#{lfsr_init_value};"
            puts "            lfsr_valid       <= 1;"
            puts "        end"

            puts "        else if (~mask_valid)"
                                # should lfsr_invalid_value but specified somewhere?
                                # or are all maximal-length lfsr 2^n - 1 with 0 being the only invalid & stable state?
            puts "        begin"
            puts "            // force current value/valid to invalid"
            puts "            lfsr_value  <= #{lfsr_length_max}'d0;"
            puts "            lfsr_valid  <= 0;"
            puts "        end"

            puts "        else"
            puts "        begin"
            puts "            // shift the previous value and add in the computed (reduced) feedback value, set valid correctly (already verified mask is valid)"
            puts "            lfsr_value       <= { lfsr_value[#{lfsr_length_max - 2}:0], ^(lfsr_value & mask_value) };"
            puts "            lfsr_valid       <= 1;"
            puts "        end"
            puts "        // endif"

            puts ""

# puts "$display(#{DQ}@@@@ LFSR clk = 0b%b, rst_n = 0b%b, lfsr_length = 0b%0#{lfsr_length_size}b, lfsr_n_taps = 0b%b, mask_value = 0b%0#{lfsr_length_max}b, mask_valid = 0b%b, lfsr_value = 0b%0#{lfsr_length_max}b, lfsr_valid = 0b%b#{DQ}, clk, rst_n, lfsr_length, lfsr_n_taps, mask_value, mask_valid, lfsr_value, lfsr_valid);"

            puts "    end // always"

            puts ""

            puts "endmodule // lfsr_fibonacci"
        end # def self.generate_module_shift_register

        ##################

        def self.generate_modules(gen_opts) : Nil
            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// @BEGIN Modules"
            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""

            puts "`ifndef _tt09_kwr_lfsr__modules_"
            puts "`define _tt09_kwr_lfsr__modules_"

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""

            self.generate_modules_feedback_mask(gen_opts, 2)

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""

            self.generate_modules_feedback_mask(gen_opts, 4)

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""

            self.generate_modules_shift_register(gen_opts)

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""

            puts "`endif // _tt09_kwr_lfsr__modules_"

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// @END Modules\n"
            puts "// ////////////////////////////////////////////////////////////////////////"
        end # def self.generate_modules

        ##################

        def self.expand_symbol_range(*, symbol, from, to)
            # kwr::HACK!!!! fixed max width and pattern…
            (from..to).map \
            do | i |
                if (i >= 10)
                    "#{symbol}_#{i}"
                else
                    "#{symbol}_0#{i}"
                end
            end \
            .join(", ")
        end # def self.expand_symbol_range

        ##################

        def self.generate_logic(gen_opts) : Nil
            clock_symbol       = gen_opts.clock_symbol
            clock_polarity     = gen_opts.clock_polarity

            reset_symbol       = gen_opts.reset_symbol
            reset_polarity     = gen_opts.reset_polarity

            lfsr_length_max    = gen_opts.lfsr_length_max
            lfsr_length_bound  = gen_opts.lfsr_length_bound
            lfsr_length_size   = gen_opts.lfsr_length_size
            lfsr_init_value    = gen_opts.lfsr_init_value

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// @BEGIN Logic\n"
            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""

            puts "`ifndef _tt09_kwr_lfsr__logic_"
            puts "`define _tt09_kwr_lfsr__logic_"

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// ////////////////////////////////////////////////////////////////////////"

            puts "module tt_um__kwr_lfsr__top // top-level (and business) logic"
            puts "("

            puts "    // parameters from tt09 top-module definition on nhttps://tinytapeout.com/hdl/important/, reformatted for consistency"

            puts "    input  wire           #{clock_symbol},        // clock"
            puts "    input  wire           #{reset_symbol},      // reset"

            puts "    input  wire           ena,        // will go high when the design is enabled"

            puts "    input  wire  [7:0]    ui_in,      // Dedicated inputs"
            puts "    input  wire  [7:0]    uio_in,     // IOs: Input path"

            puts "    output reg   [7:0]    uo_out,     // Dedicated outputs"
            puts "    output reg   [7:0]    uio_out,    // IOs: Output path"
            puts "    output wire  [7:0]    uio_oe      // IOs: Enable path (active high: 0=input, 1=output)"
            puts ");"

            puts ""

            puts "    // All unused inputs must be used to prevent warnings"
            # puts "    wire                  _u0;"
            # puts "    wire                  _u1;"
            # puts "    wire                  _u2;"
            puts "    wire                  _unused;"

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""

            puts "    reg         [#{lfsr_length_size - 1}:0]     length;"
            puts "    reg                   n_taps;"

            puts "    reg                   hold;"
            # puts "    reg                   hold_on;"

            puts "    reg                   step;"
            puts "    reg                   step_on;"


            # puts "    reg                   clock_mask;"
            puts "    reg                   c_clk;"
            puts "    reg                   c_clk_ena;"

            puts ""

            puts "    wire        [#{lfsr_length_max  - 1}:0]    value;"
            puts "    wire                  valid;"

            puts ""

            puts "    lfsr_fibonacci    lfsr"
            puts "    ("
            puts "        .clk(c_clk),"
            puts "        .rst_n(rst_n),"
            puts "        .lfsr_length(length),"
            puts "        .lfsr_n_taps(n_taps),"
            puts "        .lfsr_value(value),"
            puts "        .lfsr_valid(valid)"
            puts "    );"

            puts ""

            self.puts_io_parameters

            puts ""

            puts "    // constant outputs"
            puts "    assign    uio_oe         = UIO_OE;"
            puts "    assign    _unused        = &{ena, &uio_in, 1'b0};"

            puts ""

            puts "    // ////////////////////////////////////////////////////////////////////////"
            puts "    // get inputs"

            # puts ""

            puts "    always @(#{polarity?(clock_polarity, pos: "negedge ", neg: "posedge ")}#{clock_symbol})"
            puts "    begin"
            puts "          hold               <= ui_in[UI_IN_HOLD];"
            puts "          step               <= ui_in[UI_IN_STEP];"

            puts "          step_on            <= hold &  step;"

            puts "          n_taps             <= ui_in[UI_IN_N_TAPS];"
            puts "          length             <= ui_in[UI_IN_LENGTH_#{lfsr_length_size - 1}:UI_IN_LENGTH_0];"
            puts "    end // always"

            puts ""

            puts "    // ////////////////////////////////////////////////////////////////////////"
            puts "    // manage each cycle"

            puts ""

            puts "    always @(*)"
            puts "    begin // determine lfsr clocking"
            puts "        c_clk_ena  = ~hold | (hold & step & ~step_on);"
            puts "        c_clk      = #{clock_symbol}#{polarity?(clock_polarity, pos: " & ", neg: " | ~")}c_clk_ena;"
            puts "    end // always"

            # puts ""

            # puts "    // generate and pass on a conditioned clock (falling)"
            # puts "    always @(#{polarity?(clock_polarity, pos: "negedge ", neg: "posedge ")}#{clock_symbol})"
            # puts "    begin"
            # puts "                 step_on  <= step;"
            # puts "    end // always"

            puts ""

            puts "    // generate outputs"
            puts "    always @(#{polarity?(clock_polarity, pos: "posedge ", neg: "negedge ")}c_clk,"
            puts "             #{polarity?(reset_polarity, pos: "posedge ", neg: "negedge ")}#{reset_symbol})"

            puts "    begin"
            puts "        if      (#{polarity?(reset_polarity, pos: "", neg: "~")}#{reset_symbol})"
            puts "        begin // reset outputs"
            puts "            uio_out[UIO_OUT_VALID]                      <= 0;"
            puts "            uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]  <= 0;"
            puts "            uo_out                                      <= 0;"

            puts "        end"

            puts "        else"
            puts "        begin // lagtch outputs"
            puts "            uio_out[UIO_OUT_VALID]                      <= valid;"

            # need a function self.generate_signal(symbol_name, hi_bit, lo_bit) which produces symbol_name, symbol_name[hi_bit], symbol_name[hi_bit:lo_bit]
            # … could extend to an additional hi_bit and lo_bit that produces symbol if both hi_bit(s) and lo_bit(s) match
            # … could extend to zero-fill or space-fill to align to n bits
            # need a function self.range_valid(hi_bit, lo_bit) which is true if hi_bit >= lo_bit

            if    (lfsr_length_bound >= 15)
                puts "            uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]  <= value[14:08];"
                puts "            uo_out                                      <= value[07:00];"
            elsif (lfsr_length_bound == 14)
                puts "            uio_out[UIO_OUT_VALUE_14]                   <= 0;"
                puts "            uio_out[UIO_OUT_VALUE_13:UIO_OUT_VALUE_08]  <= value[13:08];"
                puts "            uo_out                                      <= value[07:00];"
            elsif (lfsr_length_bound >  10)
                puts "            uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_#{lfsr_length_bound}]  <= 0;"
                puts "            uio_out[UIO_OUT_VALUE_#{lfsr_length_bound - 1}:UIO_OUT_VALUE_08]  <= value[#{lfsr_length_bound - 1}:08];"
                puts "            uo_out                                      <= value[07:00];"
            elsif (lfsr_length_bound == 10)
                puts "            uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_10]  <= 0;"
                puts "            uio_out[UIO_OUT_VALUE_09:UIO_OUT_VALUE_08]  <= value[09:08];"
                puts "            uo_out                                      <= value[07:00];"
            elsif (lfsr_length_bound ==  9)
                puts "            uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_09]  <= 0;"
                puts "            uio_out[UIO_OUT_VALUE_08]                   <= value[08];"
                puts "            uo_out                                      <= value[07:00];"
            elsif (lfsr_length_bound ==  8)
                puts "            uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]  <= 0;"
                puts "            uo_out                                      <= value[07:00];"
            elsif (lfsr_length_bound ==  7)
                puts "            uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]  <= 0;"
                puts "            uo_out                                      <= value[07];"
                puts "            uo_out                                      <= value[06:00];"
            else
                puts "            uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]  <= 0;"
                puts "            uo_out                                      <= value[07:0#{lfsr_length_bound}];"
                puts "            uo_out                                      <= value[0#{lfsr_length_bound - 1}:00];"
            end # if

            puts "        end"
            puts "        // endif"

            puts "    end // always"

            puts ""

            puts "endmodule // tt_um__kwr_lfsr__top"

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""

            puts "`endif // _tt09_kwr_lfsr__logic_"

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// @END Logic\n"
            puts "// ////////////////////////////////////////////////////////////////////////"

        end # def generate_logic

        #########

        def self.generate_test_lfsr(gen_opts) : Nil
            clock_symbol      = gen_opts.clock_symbol
            clock_polarity    = gen_opts.clock_polarity

            reset_symbol      = gen_opts.reset_symbol
            reset_polarity    = gen_opts.reset_polarity

            lfsr_length_max   = gen_opts.lfsr_length_max
            lfsr_length_size  = gen_opts.lfsr_length_size
            lfsr_init_value   = gen_opts.lfsr_init_value

            lfsr_length       = 7

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// @BEGIN Test_LFSR\n"
            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""
            puts "`ifndef _tt09_kwr_lfsr__test_lfsr_"
            puts "`define _tt09_kwr_lfsr__test_lfsr_"
            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""

            puts "// ... test code goes here ...."

            puts ""

            puts "module test_lfsr;"

            puts "    reg                   clk;"
            puts "    reg                   rst_n;"

            # puts "    reg                   lfsr_hold;"
            puts "    reg          [#{lfsr_length_size - 1}:0]    lfsr_length;"
            puts "    reg                   lfsr_n_taps;"

            # puts "    reg         [#{lfsr_length_max  - 1}:0]    lfsr_value_prev;"
            # puts "    reg                   lfsr_valid_prev;"

            puts ""

            puts "    wire        [#{lfsr_length_max - 1}:0]    lfsr_value;"
            puts "    wire                  lfsr_valid;"

            puts ""

            puts "    lfsr_fibonacci    lfsr"
            puts "    ("
            puts "        .clk(clk),"
            puts "        .rst_n(rst_n),"
            puts "        .lfsr_length(lfsr_length),"
            puts "        .lfsr_n_taps(lfsr_n_taps),"
            puts "        .lfsr_value(lfsr_value),"
            puts "        .lfsr_valid(lfsr_valid)"
            puts "    );"

            puts ""

            puts "    integer               cycle;"

            puts ""

            puts "    initial"
            puts "    begin"

            puts "        cycle             = 0;"
            puts "        $display(#{DQ}#### cycle = %d#{DQ}, cycle);"

            puts ""

            puts "        clk               = 0;"
            puts "        rst_n             = 1;"
            puts "        $display(#{DQ}#### cycle = %d, clk = %d, rst_n = %d, lfsr_valid = %d, lfsr_value = 0b%0#{lfsr_length}b#{DQ}, cycle, clk, rst_n, lfsr_valid, lfsr_value[#{lfsr_length - 1}:0]);"

            puts ""

            puts "        lfsr_length       = #{lfsr_length_size}'d#{lfsr_length};"
            puts "        lfsr_n_taps       = 0;"

            puts ""

            puts "        #50;"
            puts "        rst_n             = 0;"
            puts "        $display(#{DQ}#### cycle = %d, clk = %d, rst_n = %d, lfsr_valid = %d, lfsr_value = 0b%0#{lfsr_length}b#{DQ}, cycle, clk, rst_n, lfsr_valid, lfsr_value[#{lfsr_length - 1}:0]);"

            puts ""

            puts "        #50;"
            puts "        clk               = 1;"
            puts "        $display(#{DQ}#### cycle = %d, clk = %d, rst_n = %d, lfsr_valid = %d, lfsr_value = 0b%0#{lfsr_length}b#{DQ}, cycle, clk, rst_n, lfsr_valid, lfsr_value[#{lfsr_length - 1}:0]);"

            puts ""

            puts "        #50;"
            puts "        clk               = 0;"
            puts "        $display(#{DQ}#### cycle = %d, clk = %d, rst_n = %d, lfsr_valid = %d, lfsr_value = 0b%0#{lfsr_length}b#{DQ}, cycle, clk, rst_n, lfsr_valid, lfsr_value[#{lfsr_length - 1}:0]);"

            puts ""

            puts "        #50;"
            puts "        clk               = 1;"
            puts "        $display(#{DQ}#### cycle = %d, clk = %d, rst_n = %d, lfsr_valid = %d, lfsr_value = 0b%0#{lfsr_length}b#{DQ}, cycle, clk, rst_n, lfsr_valid, lfsr_value[#{lfsr_length - 1}:0]);"

            puts ""

            puts "        #50;"
            puts "        clk               = 0;"
            puts "        $display(#{DQ}#### cycle = %d, clk = %d, rst_n = %d, lfsr_valid = %d, lfsr_value = 0b%0#{lfsr_length}b#{DQ}, cycle, clk, rst_n, lfsr_valid, lfsr_value[#{lfsr_length - 1}:0]);"

            puts ""

            puts "        #50;"
            puts "        clk               = 1;"
            puts "        $display(#{DQ}#### cycle = %d, clk = %d, rst_n = %d, lfsr_valid = %d, lfsr_value = 0b%0#{lfsr_length}b#{DQ}, cycle, clk, rst_n, lfsr_valid, lfsr_value[#{lfsr_length - 1}:0]);"
            # puts "        lfsr_value_prev   = lfsr_value;"

            puts ""

            puts "        #50;"
            puts "        rst_n             = 1;"
            puts "        $display(#{DQ}#### cycle = %d, clk = %d, rst_n = %d, lfsr_valid = %d, lfsr_value = 0b%0#{lfsr_length}b#{DQ}, cycle, clk, rst_n, lfsr_valid, lfsr_value[#{lfsr_length - 1}:0]);"

            puts ""

            puts "        #50;"
            puts "        clk               = 0;"
            puts "        $display(#{DQ}#### cycle = %d, clk = %d, rst_n = %d, lfsr_valid = %d, lfsr_value = 0b%0#{lfsr_length}b#{DQ}, cycle, clk, rst_n, lfsr_valid, lfsr_value[#{lfsr_length - 1}:0]);"

            puts ""

            puts "        cycle  = cycle + 1;"

            puts "    end"

            puts ""

            puts "    always"
            puts "    begin"

            puts "        if      (cycle > 100)"
            puts "        begin"
            puts "            $finish;"
            puts "        end"

            puts ""

            puts "        else if (cycle > 0)"
            puts "        begin"

            puts "            #50;"
            puts "            clk               = 1;"
            puts "            $display(#{DQ}#### cycle = %d, clk = %d, rst_n = %d, lfsr_valid = %d, lfsr_value = 0b%0#{lfsr_length}b#{DQ}, cycle, clk, rst_n, lfsr_valid, lfsr_value[#{lfsr_length - 1}:0]);"
            # puts "            lfsr_value_prev   = lfsr_value;"

            puts ""

            puts "            #50;"
            puts "            clk               = 0;"
            puts "            $display(#{DQ}#### cycle = %d, clk = %d, rst_n = %d, lfsr_valid = %d, lfsr_value = 0b%0#{lfsr_length}b#{DQ}, cycle, clk, rst_n, lfsr_valid, lfsr_value[#{lfsr_length - 1}:0]);"

            puts "        end"
            puts "        // endif"

            puts ""

            puts "        cycle             = cycle + 1;"

            puts "    end // always"

            puts ""

            puts "endmodule // test_lfsr"

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""

            puts "`endif // _tt09_kwr_lfsr__test_lfsr_"

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// @END Test_LFSR\n"
            puts "// ////////////////////////////////////////////////////////////////////////"
        end # def self.generate_test_lfsr    end # class Verilog_Generator

        #########

        def self.test_logic_prep : Nil
        end # def self.test_logic_prep

        #########

        def self.test_logic_init : Nil
            puts ""

        end # def self.test_logic_init

        #########

        def self.test_logic_display_interface(lfsr_length_size) : Nil
            puts ""

            puts "            $display(#{DQ}        clk      = 0b%b#{DQ}, clk);"
            puts "            $display(#{DQ}        rst_n    = 0b%b#{DQ}, rst_n);"
            puts "            $display(#{DQ}        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b#{DQ}, ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_#{lfsr_length_size - 1}:UI_IN_LENGTH_0]);"
            puts "            $display(#{DQ}        uio_in   = 0b%08b#{DQ}, uio_in);"
            puts "            $display(#{DQ}        uo_out   = 0b%08b                   value_l =           0b%08b#{DQ}, uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);"
            puts "            $display(#{DQ}        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b#{DQ}, uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);"
        end # def self.test_logic_display_interface

        #########

        def self.test_logic_final : Nil
        end # def self.test_logic_final

        #########

        def self.test_logic_reset
            puts ""

            puts "            #0;"
            puts "            clk                                   = 0;"
            puts "            rst_n                                 = 1;"

            puts ""

            puts "            #25;"
            puts "            rst_n                                 = 0;"

            puts ""

            puts "            #25;"
            puts "            clk                                   = 1;"

            puts ""

            puts "            #25;"
            puts "            rst_n                                 = 1;"

            puts ""
        end # def self.test_logic_reset

        #########

        def self.test_logic_assign_ui_in(lfsr_length_size)
            puts ""

            puts "            ui_in[UI_IN_HOLD]                     = hold;"
            puts "            ui_in[UI_IN_STEP]                     = step;"
            puts "            ui_in[UI_IN_N_TAPS]                   = n_taps;"
            puts "            ui_in[UI_IN_LENGTH_#{lfsr_length_size - 1}:UI_IN_LENGTH_0]  = length;"
        end # defself.test_logic_assign_ui_in

        #########

        def self.test_logic_cycle(lfsr_length_size)
            puts "            #50;"
            puts "            clk                                   = 1;"

            puts ""

            puts "            $display(#{DQ}^^^^ @ %d    <<<<<<<<<    <<<<<<<<<#{DQ},                                           cycle);"
                              self.test_logic_display_interface(lfsr_length_size)

            puts "            #50;"
            puts "            clk                                   = 0;"

            puts ""

            puts "            $display(#{DQ}xxxx @ %d                 ---------     ---------#{DQ},                             cycle);"

                              self.test_logic_display_interface(lfsr_length_size)
            puts "            $display(#{DQ}vvvv @ %d                          >>>>>>>>>     >>>>>>>>>#{DQ},                    cycle);"
        end # def self.test_logic_cycle

        #########

        def self.generate_test_logic(gen_opts)
            # puts "#{self.name}.generate_test(gen_opts) is not implemented"
            # exit -1

            clock_symbol      = gen_opts.clock_symbol
            clock_polarity    = gen_opts.clock_polarity

            reset_symbol      = gen_opts.reset_symbol
            reset_polarity    = gen_opts.reset_polarity

            lfsr_length_max   = gen_opts.lfsr_length_max
            lfsr_length_size  = gen_opts.lfsr_length_size
            lfsr_init_value   = gen_opts.lfsr_init_value

            lfsr_length       = 7

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// @BEGIN Test_Logic\n"
            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""

            puts "`ifndef _tt09_kwr_lfsr__test_logic_"
            puts "`define _tt09_kwr_lfsr__test_logic_"

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""

            puts "// ... test code goes here ...."

            puts ""

            puts "module test_logic;"

            puts "    reg                   clk;        // clock"
            puts "    reg                   rst_n;      // reset_n - low to reset"

            puts "    reg                   ena;        // will go high when the design is enabled"

            puts "    reg   [7:0]           ui_in;      // Dedicated inputs"
            puts "    reg   [7:0]           uio_in;     // IOs: Input path"

            puts "    wire  [7:0]           uo_out;     // Dedicated outputs"
            puts "    wire  [7:0]           uio_out;    // IOs: Output path"

            puts "    wire  [7:0]           uio_oe;     // IOs: Enable path (active high: 0=input, 1=output)"

            puts ""

            puts "    integer               cycle;"

            puts "    reg                   hold;"
            puts "    reg                   step;"
            puts "    reg                   n_taps;"
            puts "    reg   [#{lfsr_length_size - 1}:0]           length;"


            puts ""

            puts "    tt_um__kwr_lfsr__top    top"
            puts "    ("
            puts "        .clk(clk),"
            puts "        .rst_n(rst_n),"
            puts "        .ena(ena),"
            puts "        .ui_in(ui_in),"
            puts "        .uio_in(uio_in),"
            puts "        .uo_out(uo_out),"
            puts "        .uio_out(uio_out),"
            puts "        .uio_oe(uio_oe)"
            puts "    );"

            puts ""

            self.puts_io_parameters

            #########

            puts ""

            puts "    initial"
            puts "    begin"
            puts "        cycle  = 0;"
            puts "        $dumpfile(#{DQ}lfsr.vcd#{DQ});"
            puts "        $dumpvars(0, test_logic, top);"

            puts "    end // initial"

            #########

            two_tap_length   = 5
            four_tap_length  = 7        # was 11 but have been testing shorter lfsr lengths

            puts ""

            # puts "    always @(#{polarity?(clock_polarity, pos: "posedge ", neg: "negedge ")}#{clock_symbol})"
            # puts "    begin"
            # puts "        if (cycle > 0)"
            # puts "        begin"
            # puts "            $display(#{DQ}::::#{DQ});"
            # puts "            $display(#{DQ}::::    await  ClockCycles(dut.clk, 1)#{DQ});"
            # puts "            $display(#{DQ}::::    assert dut.uio_out.value == 0x%02x#{DQ}, uio_out);"
            # puts "            $display(#{DQ}::::    assert  dut.uo_out.value == 0x%02x#{DQ},  uo_out);"
            # # puts "            $display(#{DQ}:::: 8'b%08b 8'b%08b#{DQ}, uio_out, uo_out);"
            # # puts "            $display(#{DQ}:::: 8'b%08b 8'b%08b#{DQ}, uio_out, uo_out);"
            # puts "        end"
            # puts "        // endif"
            # puts "    end // always"

            # puts ""

            puts "    always"
            puts "    begin"

            puts "        $display(#{DQ}==================================== cycle = %d ====================================#{DQ}, cycle);"

            puts "        $display(#{DQ}// dump begin#{DQ});"

            puts "        if (cycle > 1)"
            puts "        begin"
            puts "            $display(#{DQ}::::#{DQ});"
            puts "            $display(#{DQ}::::    dut.ui_in.value           = 0x%02x#{DQ}, ui_in);"

            puts ""

            puts "            $display(#{DQ}::::    await  ClockCycles(dut.clk, 1)#{DQ});"
            puts "            $display(#{DQ}::::    assert dut.uio_out.value == 0x%02x#{DQ}, uio_out);"
            puts "            $display(#{DQ}::::    assert  dut.uo_out.value == 0x%02x#{DQ},  uo_out);"
            # # puts "            $display(#{DQ}:::: 8'b%08b 8'b%08b#{DQ}, uio_out, uo_out);"
            puts "        end"
            puts "        // endif"

            # not quite sure why if…end if…else…end fails to execute without this intervening non-if construct; bad verilog, no silicon biscuit.
            puts "        $display(#{DQ}// dump end#{DQ});"

            puts "        if      (cycle ==   0)"
            puts "        begin"
            puts "            $display(#{DQ}!!!! @ %d    Initializion begun           .........    .........    .........#{DQ}, cycle);"
            puts "            $display(#{DQ}~~~~ INIT    taps 2, length 7#{DQ});"
            puts "            hold                                  = 0;"
            puts "            step                                  = 0;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_reset
            puts "            $display(#{DQ}!!!! @ %d    Initialization completed     .........    .........    .........#{DQ}, cycle);"
            puts "        end"

            puts ""

            puts "        else if (cycle ==   20)"
            puts "        begin"
            puts "            $display(#{DQ}~~~~ HOLD#{DQ});"
            puts "            hold                                  = 1;"
            puts "            step                                  = 0;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""

            puts "        else if (cycle ==   25)"
            puts "        begin"
            puts "            $display(#{DQ}~~~~ HOLD STEP#{DQ});"
            puts "            hold                                  = 1;"
            puts "            step                                  = 0;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""

            puts "        else if (cycle ==   26)"
            puts "        begin"
            puts "            $display(#{DQ}~~~~ HOLD#{DQ});"
            puts "            hold                                  = 0;"
            puts "            step                                  = 0;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""

            puts "        else if (cycle ==   29)"
            puts "        begin"
            puts "            $display(#{DQ}~~~~ HOLD STEP#{DQ});"
            puts "            hold                                  = 1;"
            puts "            step                                  = 0;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""

            puts "        else if (cycle ==   31)"
            puts "        begin"
            puts "            $display(#{DQ}~~~~ HOLD STEP#{DQ});"
            puts "            hold                                  = 1;"
            puts "            step                                  = 1;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""

            puts "        else if (cycle ==   32)"
            puts "        begin"
            puts "            $display(#{DQ}~~~~ HOLD#{DQ});"
            puts "            hold                                  = 1;"
            puts "            step                                  = 0;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""

            puts "        else if (cycle ==   34)"
            puts "        begin"
            puts "            $display(#{DQ}~~~~ HOLD STEP#{DQ});"
            puts "            hold                                  = 1;"
            puts "            step                                  = 1;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""

            puts "        else if (cycle ==   36)"
            puts "        begin"
            puts "            $display(#{DQ}~~~~ HOLD#{DQ});"
            puts "            hold                                  = 1;"
            puts "            step                                  = 0;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""

            puts "        else if (cycle ==   38)"
            puts "        begin"
            puts "            $display(#{DQ}~~~~ HOLD STEP#{DQ});"
            puts "            hold                                  = 1;"
            puts "            step                                  = 1;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""

            puts "        else if (cycle ==   40)"
            puts "        begin"
            puts "            $display(#{DQ}~~~~ RUN STEP#{DQ});"
            puts "            hold                                  = 0;"
            puts "            step                                  = 1;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""

            puts "        else if (cycle ==   45)"
            puts "        begin"
            puts "            $display(#{DQ}~~~~ RUN#{DQ});"
            puts "            hold                                  = 0;"
            puts "            step                                  = 0;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""

            puts "        else if (cycle ==   47)"
            puts "        begin"
            puts "            $display(#{DQ}~~~~ RUN STEP#{DQ});"
            puts "            hold                                  = 0;"
            puts "            step                                  = 1;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""

            puts "        else if (cycle ==   49)"
            puts "        begin"
            puts "            $display(#{DQ}~~~~ HOLD STEP#{DQ});"
            puts "            hold                                  = 1;"
            puts "            step                                  = 1;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""

            puts "        else if (cycle ==   51)"
            puts "        begin"
            puts "            $display(#{DQ}~~~~ HOLD#{DQ});"
            puts "            hold                                  = 1;"
            puts "            step                                  = 0;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""


            puts "        else if (cycle ==   54)"
            puts "        begin"
            puts "            $display(#{DQ}~~~~ HOLD STEP#{DQ});"
            puts "            hold                                  = 1;"
            puts "            step                                  = 1;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""

            puts "        else if (cycle ==   57)"
            puts "        begin"
            puts "            $display(#{DQ}~~~~ HOLD#{DQ});"
            puts "            hold                                  = 1;"
            puts "            step                                  = 0;"
            puts "            length                                = #{two_tap_length};"
            puts "            n_taps                                = 0;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""

            puts "        else if (cycle ==  60)"
            puts "        begin"
            puts "            $display(#{DQ}!!!! @ %d    Renitializion begun           .........    .........    .........#{DQ}, cycle);"
            puts "            $display(#{DQ}~~~~ INIT    taps 4 length 11#{DQ});"
            puts "            hold                                  = 0;"
            puts "            step                                  = 0;"
            puts "            length                                = #{four_tap_length};"
            puts "            n_taps                                = 1;"
                              self.test_logic_assign_ui_in(lfsr_length_size)
                              self.test_logic_reset
            puts "            $display(#{DQ}!!!! @ %d    Reinitialization completed     .........    .........    .........#{DQ}, cycle);"
            puts "        end"

            puts ""

            puts "        else if (cycle  > 100)"
            puts "        begin"

            puts "            $display(#{DQ}#### @ %d    ##########{DQ}, cycle);"
                              self.test_logic_display_interface(lfsr_length_size)

            puts ""

            puts "            $finish;"

            puts "        end"

            puts ""

            puts "        else if (cycle  >  50)"
            puts "        begin"
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"

            puts ""

            puts "        else if (cycle > 0)"
            puts "        begin"
                              self.test_logic_cycle(lfsr_length_size)
            puts "        end"
            puts "        // endif"

            puts ""

            puts "        cycle  = cycle + 1;"

            puts "    end // always"

            puts ""

            puts "endmodule // test_logic"

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// ////////////////////////////////////////////////////////////////////////"

            puts ""

            puts "`endif // _tt09_kwr_lfsr__test_logic_"

            puts ""

            puts "// ////////////////////////////////////////////////////////////////////////"
            puts "// @END Test_Logic\n"
            puts "// ////////////////////////////////////////////////////////////////////////"
        end # def self.generate_test_logic
    end # class Verilog_Generator

    ####################################

    class SystemVerilog_Generator < Verilog_Generator
        HDL_Generator.add_subclass(Language::SystemVerilog, self)

        #########

        def self.generate_header(gen_opts)
            puts "#{self.name}.generate_header(gen_opts) is not implemented"
            exit -1
        end # def self.generate_modules

        #########

        def self.generate_modules(gen_opts)
            puts "#{self.name}.generate_modules(gen_opts) is not implemented"
            exit -1
        end # def self.generate_modules

        #########

        def self.generate_logic(gen_opts)
            puts "#{self.name}.generate_logic(gen_opts) is not implemented"
            exit -1
        end # def self.generate_modules

        #########

        def self.generate_test_lfsr(gen_opts)
            puts "#{self.name}.generate_test(gen_opts) is not implemented"
            exit -1
        end # def self.generate_test_lfsr

        #########

        def self.generate_test_logic(gen_opts)
            puts "#{self.name}.generate_test(gen_opts) is not implemented"
            exit -1
        end # def self.generate_test_logic
    end # class SystemVerilog_Generator

    ####################################

    class VHDL_Generator          < HDL_Generator
        HDL_Generator.add_subclass(Language::VHDL, self)

        #########

        def self.generate_header(gen_opts)
            puts "#{self.name}.generate_header(gen_opts) is not implemented"
            exit -1
        end # def self.generate_modules

        #########

        def self.generate_modules(gen_opts)
            puts "#{self.name}.generate_modules(gen_opts) is not implemented"
            exit -1
        end # def self.generate_modules

        #########

        def self.generate_logic(gen_opts)
            puts "#{self.name}.generate_logic(gen_opts) is not implemented"
            exit -1
        end # def self.generate_logic

        #########

        def self.generate_test_lfsr(gen_opts)
            puts "#{self.name}.generate_test(gen_opts) is not implemented"
            exit -1
        end # def self.generate_test_lfsr

        #########

        def self.generate_test_logic(gen_opts)
            puts "#{self.name}.generate_test(gen_opts) is not implemented"
            exit -1
        end # def self.generate_test_logic
    end # class HDL_Generator

    ########################################################################
    ########################################################################

    # helper functions (should be included elsewhere?)

    def split_symbol(symbol)
        if (symbol.size == 0)
            return {Polarity::Unknown, symbol }

        elsif (symbol[0] == '+')
            return { Polarity::Positive, symbol.lchop }

        elsif (symbol[0] == '-')
            return { Polarity::Negative, symbol.lchop }

        else
            return { Polarity::Unknown, symbol }
        end
    end # def split_symbol

    #########

    def polarity?(pol, *, pos="", neg="", unk=pos)
        case pol
          when Polarity::Positive
            return (pos)

          when Polarity::Negative
            return (neg)

          when Polarity::Unknown
            return (unk)

          else
            puts "polarity?: #{pol} is not a valid polarity"
            exit -1
        end # case
    end # def polarity?

    #########

    def imin(a, b)
        return ((a < b) ? a : b)
    end

    #########

    def imax(a, b)
        return ((a > b) ? a : b)
    end

    ########################################################################
    ########################################################################

    to_generate        = [] of Option_State
    options            = Option_State.new

    generated          = true

    ####################################

    parser  = OptionParser.new do | parser |
        parser.banner = "Welcome to the #{TOOL_DESCRIPTOR}!"

        #########

        parser.on "-C CLOCK", "--clock=CLOCK", "Specify CLOCK symbol to be used in generated RTL" \
        do | clock |
            clock_polarity, clock_symbol  = split_symbol(clock)

            options.clock_polarity  = clock_polarity
            options.clock_symbol    = clock_symbol

            generated                     = false
        end # parser.on "-C"

        #########

        parser.on "-g WHAT", "--generate WHAT", "Generate mode" \
        do | what |
            to_generate.push(options.to_generate(what))

            generated  = true
        end # parser.on "-h"

        #########

        parser.on "-h", "--help", "Display help" \
        do
            puts parser
            exit
        end # parser.on "-h"

        #########

        parser.on "-H LANG", "--hdl=LANG", "Select HDL language LANG" \
        do | lang |
            ltest  = lang.downcase

            case (ltest)
              when "verilog", "v"
                options.language  = Language::Verilog

              when "vhdl"
                options.language  = Language::VHDL
                puts "VHDL is not yet supported"
                exit -1

              when "system verilog", "sv"
                options.language  = Language::SystemVerilog

              else
                puts "Unknown language #{lang}"
                exit -1
            end # case

            generated  = false
        end # parser.on "-H"

        #########

        parser.on "-L LFSR", "--lfsr=LFSR", "Specify LFSR symbol to be used in generated RTL" \
        do | lfsr |
            options.lfsr_symbol  = lfsr

            generated            = false
        end # parser.on "-L"

        #########

        parser.on "-i IVAL", "--init=IVAL", "Specify initial value to be used in generated RTL to initialize the LFSR" \
        do | ival |
            itest  = ival.to_i?

            if    (itest.nil?)
                puts "LFSR length must be a smallish integer (provided #{ival})"
                exit -1

            else
                options.lfsr_init_value    = itest
            end # if

            generated            = false
        end # parser.on "-L"

        #########

        parser.on "-n N", "--width=N", "Specify (maximum) LFSR width" \
        do | n |
            wtest  = n.to_i?

            if    (wtest.nil?)
                puts "LFSR maximum width must be a smallish integer (provided #{n})"
                exit -1

            else
                options.lfsr_length_bound  = wtest

                # there's certainly a trivial-enough mathematical approach
                #     width  = log2(wtest).ceil
                #     bound  = 1 << (width - 1)
                # but i don't wan't to figure out how to do it (and debug it) in crystal right now.

                if    (wtest <=  2)
                    options.lfsr_length_size   =  1
                    options.lfsr_length_max    =  2

                elsif (wtest <=  4)
                    options.lfsr_length_size   =  2
                    options.lfsr_length_max    =  4

                elsif (wtest <=  8)
                    options.lfsr_length_size   =  3
                    options.lfsr_length_max    =  8

                elsif (wtest <= 16)
                    options.lfsr_length_size   =  4
                    options.lfsr_length_max    = 16

                elsif (wtest <= 32)
                    options.lfsr_length_size   =  5
                    options.lfsr_length_max    = 32

                # elsif (wtest <= 64)
                #     options.lfsr_length_size   =  6
                #     options.lfsr_length_max    = 64

                else
                    puts "LFSR (maximum) width #{wtest} is greater than 32 (exceeds 5 bits) which is not supported by the current RTL model"
                end # if
            end # if

            generated  = false
        end # parser.on "-n"

        #########

        parser.on "-R RESET", "--reset=reset", "Specify RESET symbol to be used in generated RTL" \
        do | reset |
            reset_polarity, reset_symbol  = split_symbol(reset)

            options.reset_polarity  = reset_polarity
            options.reset_symbol    = reset_symbol

            generated  = false
        end # parser.on "-R"

        #########

        parser.on "-t T", "--taps=T", "Specify LSFR taps" \
        do | t |
            puts " taps option is deprecated and taps selected by input port"

            #ttest  = t.to_i?

            #case (ttest)
            #  when nil
            #    puts "LSFR taps must be a smallish integer (provided #{t})"
            #    exit -1

            #  when 2
            #    options.n_taps            = 2

            #    options.tap_table         = LFSR_2TAP
            #    options.tap_table_null    = NULL_2TAP
            #    options.tap_table_max     = MAX_2TAP
            #    options.tap_table_n_taps  = TAPS_2TAP

            #  when 4
            #    options.n_taps            = 4

            #    options.tap_table         = LFSR_4TAP
            #    options.tap_table_null    = NULL_4TAP
            #    options.tap_table_max     = MAX_4TAP
            #    options.tap_table_n_taps  = TAPS_4TAP

            #  else
            #    puts "LFSR taps must be 2 or 4 (provided #{t})"
            #    exit -1
            #end # case

            #generated  = false
        end # parser.on "-t"

        #########

        parser.on "-T TYPE", "--type=TYPE", "Select LFSR type to generate" \
        do | type |
            ttest  = type.downcase

            case (ttest)
              when "fibonacci", "fib", "f"
                options.type  = Type::Fibonacci

              when "galois",     "gal",  "g"
                # options.type  = Type::Galois
                puts "Galois is not yet supported"
                exit -1

              else
                puts "Unknown LFSR type #{type}"
                exit -1
            end # case

            generated  = false
        end # parser.on "-T"

        #########

        parser.on "-v", "--version", "Show version information" \
        do
            puts "    version 1.0"
            exit
        end # parser.on "-v"
    end # parser.on "-l …"

    ####################################

    # puts "ARGV      => #{ARGV}"
    # puts "ARGV.size => #{ARGV.size}"

    if (ARGV.size == 0)
        puts "#{TOOL_DESCRIPTOR}: must specify generator options in command line"
        puts "#{TOOL_DESCRIPTXX}      e.g., crystal run --error-trace lfsr.cr -- -Hv -i1 -n32 -C +clk -R -rst_n -L lfsr -T fib --generate modules --generate logic --generate test"
        puts ""
        puts parser
        exit -1
    end

    parser.parse

    if (!generated)
        puts "Options have been specified without a subsequent generate directive"
        exit -1
    end # if

    ####################################

    first_generation  = true

    to_generate.each do | gen_opts |
        if (first_generation)
            first_generation  = false

        else
            puts ""
        end

        HDL_Generator.generate(gen_opts)
    end # do

########################################################################
# end module ???
########################################################################
########################################################################
