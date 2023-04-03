# Usages:
# 1. Using an example: -s SIM_VALUE25
# 2. Using an example with pipeline: -s SIM_ROTATING_LEDS -p

TEST_BASE="./test"
CMD="${TEST_BASE}/cmd.mk"
TB="${TEST_BASE}/top_tb.sv"
SIM_EXAMPLE="SIM_RANDOM_INS"
PIPELINE=0

while [ -n "$1" ]; do
    case "$1" in
		# Simulation flag for Iverilog compilation. Options as below:
		# SIM_RANDOM_INS 		to launch a simple random instructions simulation
		# SIM_VALUE25 			to launch Value25 simulation
		# SIM_ROTATING_LEDS 	to launch rotating leds simulation
		# SIM_DB_ROTATING_LEDS 	to launch double-side rotating leds simulation
		# Usage: -s SIM_RANDOM_INS
        -s) param="$2"
			if [ $param != "SIM_RANDOM_INS" \
				-a $param != "SIM_VALUE25" \
				-a $param != "SIM_ROTATING_LEDS" \
				-a $param != "SIM_DB_ROTATING_LEDS" ]; then
				echo "Simulation $param is not implemented."
				echo "Exit with 1."
				exit 1
			fi
			SIM_EXAMPLE=$param
			shift;;
		# Pipeline implementation flag for using pipeline in RTL.
		# Usage: -p
        -p) echo "Pipeline implementation enabled"
			PIPELINE=1
			CMD="${TEST_BASE}/cmd_pipeline.mk";;
        --) shift
            break;;
        *) echo "$1 is not an option";;
    esac
    shift
done

if [ ! -d "${TEST_BASE}/simple" ]; then
	mkdir ${TEST_BASE}/simple
fi
if [ ! -d "${TEST_BASE}/pipeline" ]; then
	mkdir ${TEST_BASE}/pipeline
fi

echo "Using ${SIM_EXAMPLE} example"

if [ ${PIPELINE} -eq 1 ]; then
	OUTPUT="${TEST_BASE}/pipeline/${SIM_EXAMPLE}.vvp"
	iverilog -g2012 -o ${OUTPUT} ${TB} -s top_tb -c ${CMD} -DSIM_ON_IVERILOG -D${SIM_EXAMPLE} -DUSE_PIPELINE -Wall
else
	OUTPUT="${TEST_BASE}/simple/${SIM_EXAMPLE}.vvp"
	iverilog -g2012 -o ${OUTPUT} ${TB} -s top_tb -c ${CMD} -DSIM_ON_IVERILOG -D${SIM_EXAMPLE} -Wall
fi

if [ $? = 0 ]; then
	vvp ${OUTPUT} -fst -v
	echo "Finished."
else
	echo "Exit with $?."
	exit $?
fi

# Uncomment below to open gtkwave automatically after simulation finished.
# gtkwave ${OUTPUT%/*}/${SIM_EXAMPLE}_wave.fst