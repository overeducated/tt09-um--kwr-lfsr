// ////////////////////////////////////////////////////////////////////////
// @BEGIN Header
// ////////////////////////////////////////////////////////////////////////

`ifndef _tt09_kwr_lfsr__header_
`define _tt09_kwr_lfsr__header_

// ////////////////////////////////////////////////////////////////////////
// ////////////////////////////////////////////////////////////////////////

// ////////////////////////////////////
// Copyright (c) 2024 Kevin W. Rudd
// SPDX-License-Identifier: Apache-2.0
// ////////////////////////////////////

`default_nettype    none

// ////////////////////////////////////////////////////////////////////////
// ////////////////////////////////////////////////////////////////////////

`endif // _tt09_kwr_lfsr__header_

// ////////////////////////////////////////////////////////////////////////
// @END Header
// ////////////////////////////////////////////////////////////////////////


// ////////////////////////////////////////////////////////////////////////
// @BEGIN Modules
// ////////////////////////////////////////////////////////////////////////

`ifndef _tt09_kwr_lfsr__modules_
`define _tt09_kwr_lfsr__modules_

// ////////////////////////////////////////////////////////////////////////
// ////////////////////////////////////////////////////////////////////////

module generate_mask_fibonacci_2_taps
(
    input  wire [2:0]    lfsr_length,

    output reg  [7:0]   mask_value,
    output reg           mask_valid
);

    always @(*)
    begin
        case (lfsr_length)
               3'd00 : begin mask_value   = 8'b00000000; mask_valid  = 0; end
               3'd01 : begin mask_value   = 8'b00000000; mask_valid  = 0; end
               3'd02 : begin mask_value   = 8'b00000011; mask_valid  = 1; end
               3'd03 : begin mask_value   = 8'b00000110; mask_valid  = 1; end
               3'd04 : begin mask_value   = 8'b00001100; mask_valid  = 1; end
               3'd05 : begin mask_value   = 8'b00010100; mask_valid  = 1; end
               3'd06 : begin mask_value   = 8'b00110000; mask_valid  = 1; end
               3'd07 : begin mask_value   = 8'b01100000; mask_valid  = 1; end
             default : begin mask_value   = 8'b00000000; mask_valid  = 0; end
        endcase
    end // always

endmodule // generate_mask_fibonacci_

// ////////////////////////////////////////////////////////////////////////

module generate_mask_fibonacci_4_taps
(
    input  wire [2:0]    lfsr_length,

    output reg  [7:0]   mask_value,
    output reg           mask_valid
);

    always @(*)
    begin
        case (lfsr_length)
               3'd00 : begin mask_value   = 8'b00000000; mask_valid  = 0; end
               3'd01 : begin mask_value   = 8'b00000000; mask_valid  = 0; end
               3'd02 : begin mask_value   = 8'b00000000; mask_valid  = 0; end
               3'd03 : begin mask_value   = 8'b00000000; mask_valid  = 0; end
               3'd04 : begin mask_value   = 8'b00000000; mask_valid  = 0; end
               3'd05 : begin mask_value   = 8'b00011110; mask_valid  = 1; end
               3'd06 : begin mask_value   = 8'b00110110; mask_valid  = 1; end
               3'd07 : begin mask_value   = 8'b01111000; mask_valid  = 1; end
             default : begin mask_value   = 8'b00000000; mask_valid  = 0; end
        endcase
    end // always

endmodule // generate_mask_fibonacci_

// ////////////////////////////////////////////////////////////////////////

module lfsr_fibonacci
(
    input  wire           clk,
    input  wire           rst_n,
    input  wire  [2:0]    lfsr_length,
    input  wire           lfsr_n_taps,

    output reg  [7:0]    lfsr_value,
    output reg            lfsr_valid
);

    wire        [7:0]    mask_value_2_taps;
    wire                  mask_valid_2_taps;

    generate_mask_fibonacci_2_taps    gmf2t
    (
        .lfsr_length(lfsr_length),
        .mask_value(mask_value_2_taps),
        .mask_valid(mask_valid_2_taps)
    );

    wire        [7:0]    mask_value_4_taps;
    wire                  mask_valid_4_taps;

    generate_mask_fibonacci_4_taps    gmf4t
    (
        .lfsr_length(lfsr_length),
        .mask_value(mask_value_4_taps),
        .mask_valid(mask_valid_4_taps)
    );

    reg         [7:0]    mask_value;
    reg                   mask_valid;

    always @(*)
    begin
        if      (lfsr_n_taps)
        begin
            mask_value  = mask_value_4_taps;
            mask_valid  = mask_valid_4_taps;
        end
        else
        begin
            mask_value  = mask_value_2_taps;
            mask_valid  = mask_valid_2_taps;
        end
        // endif
    end // always

    always @(posedge clk,
             negedge rst_n)
    begin
        if      (~rst_n)
        begin
            // initialize current value/valid
            lfsr_value       <= 8'd1;
            lfsr_valid       <= 1;
        end
        else if (~mask_valid)
        begin
            // force current value/valid to invalid
            lfsr_value  <= 8'd0;
            lfsr_valid  <= 0;
        end
        else
        begin
            // shift the previous value and add in the computed (reduced) feedback value, set valid correctly (already verified mask is valid)
            lfsr_value       <= { lfsr_value[6:0], ^(lfsr_value & mask_value) };
            lfsr_valid       <= 1;
        end
        // endif

    end // always

endmodule // lfsr_fibonacci

// ////////////////////////////////////////////////////////////////////////
// ////////////////////////////////////////////////////////////////////////

`endif // _tt09_kwr_lfsr__modules_

// ////////////////////////////////////////////////////////////////////////
// @END Modules
// ////////////////////////////////////////////////////////////////////////


// ////////////////////////////////////////////////////////////////////////
// @BEGIN Logic
// ////////////////////////////////////////////////////////////////////////

`ifndef _tt09_kwr_lfsr__logic_
`define _tt09_kwr_lfsr__logic_

// ////////////////////////////////////////////////////////////////////////
// ////////////////////////////////////////////////////////////////////////
module tt_um__kwr_lfsr__top // top-level (and business) logic
(
    // parameters from tt09 top-module definition on nhttps://tinytapeout.com/hdl/important/, reformatted for consistency
    input  wire           clk,        // clock
    input  wire           rst_n,      // reset
    input  wire           ena,        // will go high when the design is enabled
    input  wire  [7:0]    ui_in,      // Dedicated inputs
    input  wire  [7:0]    uio_in,     // IOs: Input path
    output reg   [7:0]    uo_out,     // Dedicated outputs
    output reg   [7:0]    uio_out,    // IOs: Output path
    output wire  [7:0]    uio_oe      // IOs: Enable path (active high: 0=input, 1=output)
);

    // All unused inputs must be used to prevent warnings
    wire                  _unused;

// ////////////////////////////////////////////////////////////////////////

    reg         [2:0]     length;
    reg                   n_taps;
    reg                   hold;
    reg                   step;
    reg                   step_on;
    reg                   c_clk;
    reg                   c_clk_ena;

    wire        [7:0]    value;
    wire                  valid;

    lfsr_fibonacci    lfsr
    (
        .clk(c_clk),
        .rst_n(rst_n),
        .lfsr_length(length),
        .lfsr_n_taps(n_taps),
        .lfsr_value(value),
        .lfsr_valid(valid)
    );


    // input IO connections
    parameter    UI_IN_HOLD               = 7;
    parameter    UI_IN_STEP               = 6;
    parameter    UI_IN_N_TAPS             = 5;
    parameter    UI_IN_LENGTH_4           = 4;
    parameter    UI_IN_LENGTH_3           = 3;
    parameter    UI_IN_LENGTH_2           = 2;
    parameter    UI_IN_LENGTH_1           = 1;
    parameter    UI_IN_LENGTH_0           = 0;

    // bidirectional IO connections (Static)
    parameter    UIO_OUT_VALID            = 7;
    parameter    UIO_OUT_VALUE_14         = 6;
    parameter    UIO_OUT_VALUE_13         = 5;
    parameter    UIO_OUT_VALUE_12         = 4;
    parameter    UIO_OUT_VALUE_11         = 3;
    parameter    UIO_OUT_VALUE_10         = 2;
    parameter    UIO_OUT_VALUE_09         = 1;
    parameter    UIO_OUT_VALUE_08         = 0;

    // bidirectional IO output-enable (Static)
    parameter    UIO_OE                   = 8'b11111111;

    // output IO connections (Static)
    parameter    UO_OUT_VALUE_07          = 7;
    parameter    UO_OUT_VALUE_06          = 6;
    parameter    UO_OUT_VALUE_05          = 5;
    parameter    UO_OUT_VALUE_04          = 4;
    parameter    UO_OUT_VALUE_03          = 3;
    parameter    UO_OUT_VALUE_02          = 2;
    parameter    UO_OUT_VALUE_01          = 1;
    parameter    UO_OUT_VALUE_00          = 0;

    // constant outputs
    assign    uio_oe         = UIO_OE;
    assign    _unused        = &{ena, &uio_in, 1'b0};

    // ////////////////////////////////////////////////////////////////////////
    // get inputs
    always @(negedge clk)
    begin
          hold               <= ui_in[UI_IN_HOLD];
          step               <= ui_in[UI_IN_STEP];
          step_on            <= hold &  step;
          n_taps             <= ui_in[UI_IN_N_TAPS];
          length             <= ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0];
    end // always

    // ////////////////////////////////////////////////////////////////////////
    // manage each cycle

    always @(*)
    begin // determine lfsr clocking
        c_clk_ena  = ~hold | (hold & step & ~step_on);
        c_clk      = clk & c_clk_ena;
    end // always

    // generate outputs
    always @(posedge c_clk,
             negedge rst_n)
    begin
        if      (~rst_n)
        begin // reset outputs
            uio_out[UIO_OUT_VALID]                      <= 0;
            uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]  <= 0;
            uo_out                                      <= 0;
        end
        else
        begin // lagtch outputs
            uio_out[UIO_OUT_VALID]                      <= valid;
            uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]  <= 0;
            uo_out                                      <= value[07:00];
        end
        // endif
    end // always

endmodule // tt_um__kwr_lfsr__top

// ////////////////////////////////////////////////////////////////////////
// ////////////////////////////////////////////////////////////////////////

`endif // _tt09_kwr_lfsr__logic_

// ////////////////////////////////////////////////////////////////////////
// @END Logic
// ////////////////////////////////////////////////////////////////////////


// ////////////////////////////////////////////////////////////////////////
// @BEGIN Test_Logic
// ////////////////////////////////////////////////////////////////////////

`ifndef _tt09_kwr_lfsr__test_logic_
`define _tt09_kwr_lfsr__test_logic_

// ////////////////////////////////////////////////////////////////////////
// ////////////////////////////////////////////////////////////////////////

// ... test code goes here ....

module test_logic;
    reg                   clk;        // clock
    reg                   rst_n;      // reset_n - low to reset
    reg                   ena;        // will go high when the design is enabled
    reg   [7:0]           ui_in;      // Dedicated inputs
    reg   [7:0]           uio_in;     // IOs: Input path
    wire  [7:0]           uo_out;     // Dedicated outputs
    wire  [7:0]           uio_out;    // IOs: Output path
    wire  [7:0]           uio_oe;     // IOs: Enable path (active high: 0=input, 1=output)

    integer               cycle;
    reg                   hold;
    reg                   step;
    reg                   n_taps;
    reg   [2:0]           length;

    tt_um__kwr_lfsr__top    top
    (
        .clk(clk),
        .rst_n(rst_n),
        .ena(ena),
        .ui_in(ui_in),
        .uio_in(uio_in),
        .uo_out(uo_out),
        .uio_out(uio_out),
        .uio_oe(uio_oe)
    );


    // input IO connections
    parameter    UI_IN_HOLD               = 7;
    parameter    UI_IN_STEP               = 6;
    parameter    UI_IN_N_TAPS             = 5;
    parameter    UI_IN_LENGTH_4           = 4;
    parameter    UI_IN_LENGTH_3           = 3;
    parameter    UI_IN_LENGTH_2           = 2;
    parameter    UI_IN_LENGTH_1           = 1;
    parameter    UI_IN_LENGTH_0           = 0;

    // bidirectional IO connections (Static)
    parameter    UIO_OUT_VALID            = 7;
    parameter    UIO_OUT_VALUE_14         = 6;
    parameter    UIO_OUT_VALUE_13         = 5;
    parameter    UIO_OUT_VALUE_12         = 4;
    parameter    UIO_OUT_VALUE_11         = 3;
    parameter    UIO_OUT_VALUE_10         = 2;
    parameter    UIO_OUT_VALUE_09         = 1;
    parameter    UIO_OUT_VALUE_08         = 0;

    // bidirectional IO output-enable (Static)
    parameter    UIO_OE                   = 8'b11111111;

    // output IO connections (Static)
    parameter    UO_OUT_VALUE_07          = 7;
    parameter    UO_OUT_VALUE_06          = 6;
    parameter    UO_OUT_VALUE_05          = 5;
    parameter    UO_OUT_VALUE_04          = 4;
    parameter    UO_OUT_VALUE_03          = 3;
    parameter    UO_OUT_VALUE_02          = 2;
    parameter    UO_OUT_VALUE_01          = 1;
    parameter    UO_OUT_VALUE_00          = 0;

    initial
    begin
        cycle  = 0;
        $dumpfile("lfsr.vcd");
        $dumpvars(0, test_logic, top);
    end // initial

    always
    begin
        $display("==================================== cycle = %d ====================================", cycle);
        if      (cycle ==   0)
        begin
            $display("!!!! @ %d    Initializion begun           .........    .........    .........", cycle);
            $display("~~~~ INIT    taps 2, length 7");
            hold                                  = 0;
            step                                  = 0;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;

            #0;
            clk                                   = 0;
            rst_n                                 = 1;

            #25;
            rst_n                                 = 0;

            #25;
            clk                                   = 1;

            #25;
            rst_n                                 = 1;

            $display("!!!! @ %d    Initialization completed     .........    .........    .........", cycle);
        end

        else if (cycle ==   20)
        begin
            $display("~~~~ HOLD");
            hold                                  = 1;
            step                                  = 0;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle ==   25)
        begin
            $display("~~~~ HOLD STEP");
            hold                                  = 1;
            step                                  = 0;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle ==   26)
        begin
            $display("~~~~ HOLD");
            hold                                  = 0;
            step                                  = 0;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle ==   29)
        begin
            $display("~~~~ HOLD STEP");
            hold                                  = 1;
            step                                  = 0;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle ==   31)
        begin
            $display("~~~~ HOLD STEP");
            hold                                  = 1;
            step                                  = 1;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle ==   32)
        begin
            $display("~~~~ HOLD");
            hold                                  = 1;
            step                                  = 0;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle ==   34)
        begin
            $display("~~~~ HOLD STEP");
            hold                                  = 1;
            step                                  = 1;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle ==   36)
        begin
            $display("~~~~ HOLD");
            hold                                  = 1;
            step                                  = 0;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle ==   38)
        begin
            $display("~~~~ HOLD STEP");
            hold                                  = 1;
            step                                  = 1;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle ==   40)
        begin
            $display("~~~~ RUN STEP");
            hold                                  = 0;
            step                                  = 1;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle ==   45)
        begin
            $display("~~~~ RUN");
            hold                                  = 0;
            step                                  = 0;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle ==   47)
        begin
            $display("~~~~ RUN STEP");
            hold                                  = 0;
            step                                  = 1;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle ==   49)
        begin
            $display("~~~~ HOLD STEP");
            hold                                  = 1;
            step                                  = 1;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle ==   51)
        begin
            $display("~~~~ HOLD");
            hold                                  = 1;
            step                                  = 0;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle ==   54)
        begin
            $display("~~~~ HOLD STEP");
            hold                                  = 1;
            step                                  = 1;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle ==   57)
        begin
            $display("~~~~ HOLD");
            hold                                  = 1;
            step                                  = 0;
            length                                = 5;
            n_taps                                = 0;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle ==  60)
        begin
            $display("!!!! @ %d    Renitializion begun           .........    .........    .........", cycle);
            $display("~~~~ INIT    taps 4 length 11");
            hold                                  = 0;
            step                                  = 0;
            length                                = 7;
            n_taps                                = 1;

            ui_in[UI_IN_HOLD]                     = hold;
            ui_in[UI_IN_STEP]                     = step;
            ui_in[UI_IN_N_TAPS]                   = n_taps;
            ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]  = length;

            #0;
            clk                                   = 0;
            rst_n                                 = 1;

            #25;
            rst_n                                 = 0;

            #25;
            clk                                   = 1;

            #25;
            rst_n                                 = 1;

            $display("!!!! @ %d    Reinitialization completed     .........    .........    .........", cycle);
        end

        else if (cycle  > 100)
        begin
            $display("#### @ %d    #########", cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);

            $finish;
        end

        else if (cycle  >  50)
        begin
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end

        else if (cycle > 0)
        begin
            #50;
            clk                                   = 1;

            $display("^^^^ @ %d    <<<<<<<<<    <<<<<<<<<",                                           cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            #50;
            clk                                   = 0;

            $display("xxxx @ %d                 ---------     ---------",                             cycle);

            $display("        clk      = 0b%b", clk);
            $display("        rst_n    = 0b%b", rst_n);
            $display("        ui_in    = 0b%08b    hold  = 0b%b    step = 0b%b    n_taps = 0b%b    length = 0b%05b", ui_in, ui_in[UI_IN_HOLD], ui_in[UI_IN_STEP], ui_in[UI_IN_N_TAPS], ui_in[UI_IN_LENGTH_2:UI_IN_LENGTH_0]);
            $display("        uio_in   = 0b%08b", uio_in);
            $display("        uo_out   = 0b%08b                   value_l =           0b%08b", uo_out, uo_out[UO_OUT_VALUE_07:UO_OUT_VALUE_00]);
            $display("        uio_out  = 0b%08b    valid = 0b%b    value_h = 0b%07b", uio_out, uio_out[UIO_OUT_VALID], uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]);
            $display("vvvv @ %d                          >>>>>>>>>     >>>>>>>>>",                    cycle);
        end
        // endif

        cycle  = cycle + 1;
    end // always

endmodule // test_logic

// ////////////////////////////////////////////////////////////////////////
// ////////////////////////////////////////////////////////////////////////

`endif // _tt09_kwr_lfsr__test_logic_

// ////////////////////////////////////////////////////////////////////////
// @END Test_Logic
// ////////////////////////////////////////////////////////////////////////
