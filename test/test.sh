TB="./test/top_tb.sv"

# Simulation flag for Iverilog compilation. Options as below:
# SIM_VALUE25 			to launch Value25 simulation
# SIM_ROTATING_LEDS 	to launch rotating leds simulation
# SIM_DB_ROTATING_LEDS 	to launch double-side rotating leds simulation
SIM_FLAG=${1:-"SIM_VALUE25"}

OUTPUT="./test/top_tb.vvp"
CMD="./test/cmd.mk"

iverilog -g2012 -o ${OUTPUT} ${TB} -s top_tb -c ${CMD} -DSIM_ON_IVERILOG -D${SIM_FLAG} -Wall

if [ $? = 0 ]; then
	vvp ${OUTPUT} -fst -v
else
	echo "Exit."
fi

# gtkwave ./test/*sim_wave.fst &