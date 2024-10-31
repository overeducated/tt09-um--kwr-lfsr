LFSR_GEN_OPTS	= 	-Hv                      \
			-i1                      \
			-n32                     \
			-C +clk                  \
			-R -rst_n                \
			-L lfsr                  \
			-T fib                   \
			--generate header        \
			--generate modules       \
			--generate logic

LFSR_TEST_LFSR	=	--generate test_lfsr

LFSR_TEST_LOGIC	=	--generate test_logic

LFSR_GEN_FILES	=	generate_lfsr generate_lfsr.dwarf lfsr.v lfsr lfsr.out lfsr.vcd
LFSR_GEN_TAGS	=	RELEASE TEST_LFSR TEST_LOGIC

TEST_OPTIONS	=

all:
	echo "must specify one of: release, test_lfsr, test_logic"
	exit -1

release:	generate_lfsr
	-[ ! -f RELEASE ] && make clean
	make TEST_OPTIONS= lfsr.v
	touch RELEASE

test_lfsr:	generate_lfsr
	-[ ! -f TEST_LFSR ] && make clean
	make TEST_OPTIONS="$(LFSR_TEST_LFSR)" lfsr.out
	touch TEST_LFSR

test_logic:	generate_lfsr
	-[ ! -f TEST_LOGIC ] && make clean
	make TEST_OPTIONS="$(LFSR_TEST_LOGIC)" lfsr.out
	touch TEST_LOGIC

clean:
	rm -f $(LFSR_GEN_FILES) $(LFSR_GEN_TAGS)

# ############################################################################################################

generate_lfsr:	generate_lfsr.cr
	crystal build $<


lfsr.v:		generate_lfsr
	./$< $(LFSR_GEN_OPTS) $(TEST_OPTIONS) > $@

lfsr:		lfsr.v
	iverilog -v -o $@ $< >& $@.out

lfsr.out:	lfsr
	./lfsr >& lfsr.out