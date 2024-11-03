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

			# -n32                     \slash…
			# -n8                      \slash…

LFSR_TEST_LFSR	=	--generate test_lfsr

LFSR_TEST_LOGIC	=	--generate test_logic

LFSR_GEN_FILES	=	generate_lfsr generate_lfsr.dwarf lfsr.v lfsr lfsr.out lfsr.cocotb lfsr.vcd
LFSR_GEN_TAGS	=	RELEASE TEST_LFSR TEST_LOGIC

TEST_OPTIONS	=

# ########################################################################


all:
	echo "must specify one of: push, release, test_lfsr, test_logic"
	exit -1

# ########################################################################

.PHONY:		push
push:
	make release
	git add --all
	git commit -m "pushing release"
	git push

# ####################################

.PHONY:		clean
clean:
	rm -f $(LFSR_GEN_FILES) $(LFSR_GEN_TAGS)

# ########################################################################

.PHONY:		release
release:
	-[ ! -f RELEASE ] && make clean
	make TEST_OPTIONS= lfsr.v
	touch RELEASE

# ##################

.PHONY:		test_lfsr
test_lfsr:
	-[ ! -f TEST_LFSR ] && make clean
	make TEST_OPTIONS="$(LFSR_TEST_LFSR)" lfsr
	touch TEST_LFSR

# ##################

.PHONY:		test_logic
test_logic:
	-[ ! -f TEST_LOGIC ] && make clean
	make TEST_OPTIONS="$(LFSR_TEST_LOGIC)" lfsr
	touch TEST_LOGIC

# ########################################################################

generate_lfsr:	generate_lfsr.cr
	crystal build $<

# ##################

lfsr.v:		generate_lfsr
	./$< $(LFSR_GEN_OPTS) $(TEST_OPTIONS) > $@

# ##################

lfsr:		lfsr.v
	iverilog -v -o $@ $< >& $@.log
	./lfsr >& lfsr.out
	grep "::::" lfsr.out | cut -f5- -d: > lfsr.cocotb
	# cat ../test/test.py.in lfsr.cocotb > ../test/test.py

# ##################

# lfsr.out:	lfsr

# ########################################################################
# ########################################################################
