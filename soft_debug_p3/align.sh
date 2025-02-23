# enable 2 MHz clock reset on time stamp updates
# command code 0 = time stamp
./devreg.sh cmd_code_edge 0
# enable command
./devreg.sh cmd_en_edge   1

# enable sending SYNC on certain time stamp lower bits
# FAST command latency is 19 clocks + 1 clock for cable and COLDATA
# 0x7fec = -20 for short cable
# 0x7fe3 = -29 for 22 m cable with extra adapter
./devreg.sh cmd_stamp_sync 0x7fe7
./devreg.sh cmd_stamp_sync_en 1

# set DTS time stamp delay for alignment
./devreg.sh dts_time_delay 0x76

# enable alignment 
./devreg.sh align_en 1

# read alignment delays
./devreg.sh align0
./devreg.sh align1
./devreg.sh align2
./devreg.sh align3

