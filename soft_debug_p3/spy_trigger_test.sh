# enable TRIGGER command on timing code 0x8
# command code 0x8 = FakeTrig0
./devreg.sh cmd_code_trigger 0x8
# enable command
./devreg.sh cmd_en_trigger 1

# program count of words to record, 256K words
./devreg.sh spy_rec_time 0x40000

while true
do
	# reset spy memory
	./devreg.sh daq_spy_reset0 1
	./devreg.sh daq_spy_reset0 0

	# wait for it to record stuff
	sleep 0.1


	# wait for full flag. It will be set to 1 when trigger comes
	while true
	do
		full=`./devreg.sh daq_spy_full0`
		if [[ "$full" == "0x1" ]]
		then
			printf "DAQ spy memory full\n"
			break
		fi
	done
done

