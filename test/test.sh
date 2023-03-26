TOP="./test/top_tb.sv"
OUTPUT="./test/value25_sim_test.vvp"
CMD="./test/cmd.mk"

iverilog -g2012 -o ${OUTPUT} ${TOP} -s top_tb -c ${CMD} -DSIMULATION -DSIM_ON_IVERILOG -Wall

if [ $? = 0 ]; then
	vvp ${OUTPUT} -fst -v
else
	echo "Exit."
fi

# gtkwave ./test/wave.fst &