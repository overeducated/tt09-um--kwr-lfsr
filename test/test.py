# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.ui_in.value = 5

    # Wait for one clock cycle to see the output values
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x00
    assert  dut.uo_out.value == 0x00

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x00
    assert  dut.uo_out.value == 0x00

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x01

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x02

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x04

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x09

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x12

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x25

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x4b

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x96

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x81
    assert  dut.uo_out.value == 0x2c

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x82
    assert  dut.uo_out.value == 0x59

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x84
    assert  dut.uo_out.value == 0xb3

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x89
    assert  dut.uo_out.value == 0x67

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x92
    assert  dut.uo_out.value == 0xcf

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xa5
    assert  dut.uo_out.value == 0x9f

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xcb
    assert  dut.uo_out.value == 0x3e

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x96
    assert  dut.uo_out.value == 0x7c

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xac
    assert  dut.uo_out.value == 0xf8

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd9
    assert  dut.uo_out.value == 0xf1

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd9
    assert  dut.uo_out.value == 0xf1

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd9
    assert  dut.uo_out.value == 0xf1

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd9
    assert  dut.uo_out.value == 0xf1

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd9
    assert  dut.uo_out.value == 0xf1

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd9
    assert  dut.uo_out.value == 0xf1

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd9
    assert  dut.uo_out.value == 0xf1

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xb3
    assert  dut.uo_out.value == 0xe3

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xe7
    assert  dut.uo_out.value == 0xc6

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xcf
    assert  dut.uo_out.value == 0x8d

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xcf
    assert  dut.uo_out.value == 0x8d

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xcf
    assert  dut.uo_out.value == 0x8d

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x9f
    assert  dut.uo_out.value == 0x1b

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x9f
    assert  dut.uo_out.value == 0x1b

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x9f
    assert  dut.uo_out.value == 0x1b

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xbe
    assert  dut.uo_out.value == 0x37

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xbe
    assert  dut.uo_out.value == 0x37

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xbe
    assert  dut.uo_out.value == 0x37

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xbe
    assert  dut.uo_out.value == 0x37

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xfc
    assert  dut.uo_out.value == 0x6e

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xfc
    assert  dut.uo_out.value == 0x6e

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf8
    assert  dut.uo_out.value == 0xdd

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf1
    assert  dut.uo_out.value == 0xba

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xe3
    assert  dut.uo_out.value == 0x75

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xc6
    assert  dut.uo_out.value == 0xea

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x8d
    assert  dut.uo_out.value == 0xd4

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x9b
    assert  dut.uo_out.value == 0xa8

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xb7
    assert  dut.uo_out.value == 0x50

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xee
    assert  dut.uo_out.value == 0xa1

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xdd
    assert  dut.uo_out.value == 0x42

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xba
    assert  dut.uo_out.value == 0x84

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xba
    assert  dut.uo_out.value == 0x84

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xba
    assert  dut.uo_out.value == 0x84

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xba
    assert  dut.uo_out.value == 0x84

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xba
    assert  dut.uo_out.value == 0x84

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf5
    assert  dut.uo_out.value == 0x09

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf5
    assert  dut.uo_out.value == 0x09

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf5
    assert  dut.uo_out.value == 0x09

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf5
    assert  dut.uo_out.value == 0x09

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf5
    assert  dut.uo_out.value == 0x09

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x00
    assert  dut.uo_out.value == 0x00

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x00
    assert  dut.uo_out.value == 0x00

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x01

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x02

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x04

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x08

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x11

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x23

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x47

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x8f

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x81
    assert  dut.uo_out.value == 0x1f

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x82
    assert  dut.uo_out.value == 0x3e

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x84
    assert  dut.uo_out.value == 0x7d

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x88
    assert  dut.uo_out.value == 0xfa

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x91
    assert  dut.uo_out.value == 0xf4

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xa3
    assert  dut.uo_out.value == 0xe9

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xc7
    assert  dut.uo_out.value == 0xd3

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x8f
    assert  dut.uo_out.value == 0xa6

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x9f
    assert  dut.uo_out.value == 0x4d

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xbe
    assert  dut.uo_out.value == 0x9a

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xfd
    assert  dut.uo_out.value == 0x34

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xfa
    assert  dut.uo_out.value == 0x68

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf4
    assert  dut.uo_out.value == 0xd1

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xe9
    assert  dut.uo_out.value == 0xa2

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd3
    assert  dut.uo_out.value == 0x45

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xa6
    assert  dut.uo_out.value == 0x8b

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xcd
    assert  dut.uo_out.value == 0x17

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x9a
    assert  dut.uo_out.value == 0x2f

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xb4
    assert  dut.uo_out.value == 0x5e

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xe8
    assert  dut.uo_out.value == 0xbd

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd1
    assert  dut.uo_out.value == 0x7b

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xa2
    assert  dut.uo_out.value == 0xf6

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xc5
    assert  dut.uo_out.value == 0xed

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x8b
    assert  dut.uo_out.value == 0xdb

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x97
    assert  dut.uo_out.value == 0xb7

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xaf
    assert  dut.uo_out.value == 0x6e

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xde
    assert  dut.uo_out.value == 0xdd

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xbd
    assert  dut.uo_out.value == 0xbb

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xfb
    assert  dut.uo_out.value == 0x77

    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf6
    assert  dut.uo_out.value == 0xef
