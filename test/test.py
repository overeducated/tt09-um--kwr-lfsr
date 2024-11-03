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


    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x00
    assert  dut.uo_out.value == 0x00

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x01

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x02

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x04

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x09

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x12

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x25

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x4b

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x96

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x81
    assert  dut.uo_out.value == 0x2c

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x82
    assert  dut.uo_out.value == 0x59

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x84
    assert  dut.uo_out.value == 0xb3

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x89
    assert  dut.uo_out.value == 0x67

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x92
    assert  dut.uo_out.value == 0xcf

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xa5
    assert  dut.uo_out.value == 0x9f

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xcb
    assert  dut.uo_out.value == 0x3e

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x96
    assert  dut.uo_out.value == 0x7c

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xac
    assert  dut.uo_out.value == 0xf8

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd9
    assert  dut.uo_out.value == 0xf1

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd9
    assert  dut.uo_out.value == 0xf1

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd9
    assert  dut.uo_out.value == 0xf1

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd9
    assert  dut.uo_out.value == 0xf1

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd9
    assert  dut.uo_out.value == 0xf1

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd9
    assert  dut.uo_out.value == 0xf1

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd9
    assert  dut.uo_out.value == 0xf1

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xb3
    assert  dut.uo_out.value == 0xe3

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xe7
    assert  dut.uo_out.value == 0xc6

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xcf
    assert  dut.uo_out.value == 0x8d

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xcf
    assert  dut.uo_out.value == 0x8d

    dut.ui_in.value           = 0xc5
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xcf
    assert  dut.uo_out.value == 0x8d

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x9f
    assert  dut.uo_out.value == 0x1b

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x9f
    assert  dut.uo_out.value == 0x1b

    dut.ui_in.value           = 0xc5
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x9f
    assert  dut.uo_out.value == 0x1b

    dut.ui_in.value           = 0xc5
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xbe
    assert  dut.uo_out.value == 0x37

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xbe
    assert  dut.uo_out.value == 0x37

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xbe
    assert  dut.uo_out.value == 0x37

    dut.ui_in.value           = 0xc5
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xbe
    assert  dut.uo_out.value == 0x37

    dut.ui_in.value           = 0xc5
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xfc
    assert  dut.uo_out.value == 0x6e

    dut.ui_in.value           = 0x45
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xfc
    assert  dut.uo_out.value == 0x6e

    dut.ui_in.value           = 0x45
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf8
    assert  dut.uo_out.value == 0xdd

    dut.ui_in.value           = 0x45
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf1
    assert  dut.uo_out.value == 0xba

    dut.ui_in.value           = 0x45
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xe3
    assert  dut.uo_out.value == 0x75

    dut.ui_in.value           = 0x45
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xc6
    assert  dut.uo_out.value == 0xea

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x8d
    assert  dut.uo_out.value == 0xd4

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x9b
    assert  dut.uo_out.value == 0xa8

    dut.ui_in.value           = 0x05
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xb7
    assert  dut.uo_out.value == 0x50

    dut.ui_in.value           = 0x45
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xee
    assert  dut.uo_out.value == 0xa1

    dut.ui_in.value           = 0xc5
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xdd
    assert  dut.uo_out.value == 0x42

    dut.ui_in.value           = 0xc5
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xba
    assert  dut.uo_out.value == 0x84

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xba
    assert  dut.uo_out.value == 0x84

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xba
    assert  dut.uo_out.value == 0x84

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xba
    assert  dut.uo_out.value == 0x84

    dut.ui_in.value           = 0xc5
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xba
    assert  dut.uo_out.value == 0x84

    dut.ui_in.value           = 0xc5
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf5
    assert  dut.uo_out.value == 0x09

    dut.ui_in.value           = 0xc5
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf5
    assert  dut.uo_out.value == 0x09

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf5
    assert  dut.uo_out.value == 0x09

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf5
    assert  dut.uo_out.value == 0x09

    dut.ui_in.value           = 0x85
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf5
    assert  dut.uo_out.value == 0x09

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf5
    assert  dut.uo_out.value == 0x09

    dut.rst_n.value = 0
    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x00
    assert  dut.uo_out.value == 0x00

    dut.rst_n.value = 1
    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x00
    assert  dut.uo_out.value == 0x00

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x01

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x02

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x04

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x08

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x11

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x23

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x47

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x80
    assert  dut.uo_out.value == 0x8f

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x81
    assert  dut.uo_out.value == 0x1f

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x82
    assert  dut.uo_out.value == 0x3e

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x84
    assert  dut.uo_out.value == 0x7d

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x88
    assert  dut.uo_out.value == 0xfa

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x91
    assert  dut.uo_out.value == 0xf4

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xa3
    assert  dut.uo_out.value == 0xe9

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xc7
    assert  dut.uo_out.value == 0xd3

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x8f
    assert  dut.uo_out.value == 0xa6

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x9f
    assert  dut.uo_out.value == 0x4d

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xbe
    assert  dut.uo_out.value == 0x9a

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xfd
    assert  dut.uo_out.value == 0x34

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xfa
    assert  dut.uo_out.value == 0x68

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf4
    assert  dut.uo_out.value == 0xd1

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xe9
    assert  dut.uo_out.value == 0xa2

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd3
    assert  dut.uo_out.value == 0x45

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xa6
    assert  dut.uo_out.value == 0x8b

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xcd
    assert  dut.uo_out.value == 0x17

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x9a
    assert  dut.uo_out.value == 0x2f

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xb4
    assert  dut.uo_out.value == 0x5e

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xe8
    assert  dut.uo_out.value == 0xbd

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xd1
    assert  dut.uo_out.value == 0x7b

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xa2
    assert  dut.uo_out.value == 0xf6

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xc5
    assert  dut.uo_out.value == 0xed

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x8b
    assert  dut.uo_out.value == 0xdb

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0x97
    assert  dut.uo_out.value == 0xb7

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xaf
    assert  dut.uo_out.value == 0x6e

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xde
    assert  dut.uo_out.value == 0xdd

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xbd
    assert  dut.uo_out.value == 0xbb

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xfb
    assert  dut.uo_out.value == 0x77

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xf6
    assert  dut.uo_out.value == 0xef

    dut.ui_in.value           = 0x27
    await  ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xed
    assert  dut.uo_out.value == 0xdf
