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
    input  wire [4:0]    lfsr_length,

    output reg  [31:0]   mask_value,
    output reg           mask_valid
);

    always @(*)
    begin
        case (lfsr_length)
               5'd00 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd01 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd02 : begin mask_value   = 32'b00000000000000000000000000000011; mask_valid  = 1; end
               5'd03 : begin mask_value   = 32'b00000000000000000000000000000110; mask_valid  = 1; end
               5'd04 : begin mask_value   = 32'b00000000000000000000000000001100; mask_valid  = 1; end
               5'd05 : begin mask_value   = 32'b00000000000000000000000000010100; mask_valid  = 1; end
               5'd06 : begin mask_value   = 32'b00000000000000000000000000110000; mask_valid  = 1; end
               5'd07 : begin mask_value   = 32'b00000000000000000000000001100000; mask_valid  = 1; end
               5'd08 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd09 : begin mask_value   = 32'b00000000000000000000000100010000; mask_valid  = 1; end
               5'd10 : begin mask_value   = 32'b00000000000000000000001001000000; mask_valid  = 1; end
               5'd11 : begin mask_value   = 32'b00000000000000000000010100000000; mask_valid  = 1; end
               5'd12 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd13 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd14 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd15 : begin mask_value   = 32'b00000000000000000110000000000000; mask_valid  = 1; end
               5'd16 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd17 : begin mask_value   = 32'b00000000000000010010000000000000; mask_valid  = 1; end
               5'd18 : begin mask_value   = 32'b00000000000000100000010000000000; mask_valid  = 1; end
               5'd19 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd20 : begin mask_value   = 32'b00000000000010010000000000000000; mask_valid  = 1; end
               5'd21 : begin mask_value   = 32'b00000000000101000000000000000000; mask_valid  = 1; end
               5'd22 : begin mask_value   = 32'b00000000001100000000000000000000; mask_valid  = 1; end
               5'd23 : begin mask_value   = 32'b00000000010000100000000000000000; mask_valid  = 1; end
               5'd24 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd25 : begin mask_value   = 32'b00000001001000000000000000000000; mask_valid  = 1; end
               5'd26 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd27 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd28 : begin mask_value   = 32'b00001001000000000000000000000000; mask_valid  = 1; end
               5'd29 : begin mask_value   = 32'b00010100000000000000000000000000; mask_valid  = 1; end
               5'd30 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd31 : begin mask_value   = 32'b01001000000000000000000000000000; mask_valid  = 1; end
             default : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
        endcase
    end // always

endmodule // generate_mask_fibonacci_

// ////////////////////////////////////////////////////////////////////////

module generate_mask_fibonacci_4_taps
(
    input  wire [4:0]    lfsr_length,

    output reg  [31:0]   mask_value,
    output reg           mask_valid
);

    always @(*)
    begin
        case (lfsr_length)
               5'd00 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd01 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd02 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd03 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd04 : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
               5'd05 : begin mask_value   = 32'b00000000000000000000000000011110; mask_valid  = 1; end
               5'd06 : begin mask_value   = 32'b00000000000000000000000000110110; mask_valid  = 1; end
               5'd07 : begin mask_value   = 32'b00000000000000000000000001111000; mask_valid  = 1; end
               5'd08 : begin mask_value   = 32'b00000000000000000000000010111000; mask_valid  = 1; end
               5'd09 : begin mask_value   = 32'b00000000000000000000000110110000; mask_valid  = 1; end
               5'd10 : begin mask_value   = 32'b00000000000000000000001101100000; mask_valid  = 1; end
               5'd11 : begin mask_value   = 32'b00000000000000000000011101000000; mask_valid  = 1; end
               5'd12 : begin mask_value   = 32'b00000000000000000000110010100000; mask_valid  = 1; end
               5'd13 : begin mask_value   = 32'b00000000000000000001101100000000; mask_valid  = 1; end
               5'd14 : begin mask_value   = 32'b00000000000000000011010100000000; mask_valid  = 1; end
               5'd15 : begin mask_value   = 32'b00000000000000000111010000000000; mask_valid  = 1; end
               5'd16 : begin mask_value   = 32'b00000000000000001011010000000000; mask_valid  = 1; end
               5'd17 : begin mask_value   = 32'b00000000000000011110000000000000; mask_valid  = 1; end
               5'd18 : begin mask_value   = 32'b00000000000000111001000000000000; mask_valid  = 1; end
               5'd19 : begin mask_value   = 32'b00000000000001110010000000000000; mask_valid  = 1; end
               5'd20 : begin mask_value   = 32'b00000000000011001010000000000000; mask_valid  = 1; end
               5'd21 : begin mask_value   = 32'b00000000000111001000000000000000; mask_valid  = 1; end
               5'd22 : begin mask_value   = 32'b00000000001001110000000000000000; mask_valid  = 1; end
               5'd23 : begin mask_value   = 32'b00000000011010100000000000000000; mask_valid  = 1; end
               5'd24 : begin mask_value   = 32'b00000000110110000000000000000000; mask_valid  = 1; end
               5'd25 : begin mask_value   = 32'b00000001111000000000000000000000; mask_valid  = 1; end
               5'd26 : begin mask_value   = 32'b00000011100010000000000000000000; mask_valid  = 1; end
               5'd27 : begin mask_value   = 32'b00000111001000000000000000000000; mask_valid  = 1; end
               5'd28 : begin mask_value   = 32'b00001100101000000000000000000000; mask_valid  = 1; end
               5'd29 : begin mask_value   = 32'b00011101000000000000000000000000; mask_valid  = 1; end
               5'd30 : begin mask_value   = 32'b00110010100000000000000000000000; mask_valid  = 1; end
               5'd31 : begin mask_value   = 32'b01111000000000000000000000000000; mask_valid  = 1; end
             default : begin mask_value   = 32'b00000000000000000000000000000000; mask_valid  = 0; end
        endcase
    end // always

endmodule // generate_mask_fibonacci_

// ////////////////////////////////////////////////////////////////////////

module lfsr_fibonacci
(
    input  wire           clk,
    input  wire           rst_n,
    input  wire  [4:0]    lfsr_length,
    input  wire           lfsr_n_taps,

    output reg  [31:0]    lfsr_value,
    output reg            lfsr_valid
);

    wire        [31:0]    mask_value_2_taps;
    wire                  mask_valid_2_taps;

    generate_mask_fibonacci_2_taps    gmf2t
    (
        .lfsr_length(lfsr_length),
        .mask_value(mask_value_2_taps),
        .mask_valid(mask_valid_2_taps)
    );

    wire        [31:0]    mask_value_4_taps;
    wire                  mask_valid_4_taps;

    generate_mask_fibonacci_4_taps    gmf4t
    (
        .lfsr_length(lfsr_length),
        .mask_value(mask_value_4_taps),
        .mask_valid(mask_valid_4_taps)
    );

    reg         [31:0]    mask_value;
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
            lfsr_value       <= 32'd1;
            lfsr_valid       <= 1;
        end
        else if (~mask_valid)
        begin
            // force current value/valid to invalid
            lfsr_value  <= 32'd0;
            lfsr_valid  <= 0;
        end
        else
        begin
            // shift the previous value and add in the computed (reduced) feedback value, set valid correctly (already verified mask is valid)
            lfsr_value       <= { lfsr_value[30:0], ^(lfsr_value & mask_value) };
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

    reg         [4:0]     length;
    reg                   n_taps;
    reg                   hold;
    reg                   step;
    reg                   step_on;
    reg                   c_clk;
    reg                   c_clk_ena;

    wire        [31:0]    value;
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
          length             <= ui_in[UI_IN_LENGTH_4:UI_IN_LENGTH_0];
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
            uio_out[UIO_OUT_VALUE_14:UIO_OUT_VALUE_08]  <= value[14:08];
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
