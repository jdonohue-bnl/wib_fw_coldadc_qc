#include <cstdio>
#include <cstdlib>
#include <unistd.h>
#include <fstream>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdio.h>

#include "femb.h"

using namespace std;

int main (int argc, char * argv[])
{


	int femb_ind = -1;
	sscanf (argv[1], "%d", &femb_ind);
	if (femb_ind < 0 || femb_ind > 3) 
	{
		printf ("invalid FEMB index. Usage: femb_test index(0..3)");
		exit (4);
	}

	printf ("Configuring FEMB %d\n", femb_ind);

	FEMB* femb = new FEMB(femb_ind);

	int reg3;

	// chip_num_on_FEMB=(0|1), chip_addr=2, reg_page, reg_addr

	uint8_t global_reg_1 = 0, global_reg_2 = 0, channel_reg = 0x38; 

	int i;
	if (argc == 2)
	{
		// See COLDATA datasheet
		// MSB goes first
		// [MSB] Ch15 .. Ch0 global_reg_1 global_reg_2 [LSB]
		// COLDATA registers 0x80 .. 0x91

		// set WIB_FEEDBACK_CODE registers to B2
		femb->i2c_write(0, 3, 0, 0x2B, 0xB2); // only works on TOP COLDATA, addr = 3
		femb->i2c_write(0, 3, 0, 0x2C, 0xB2); // only works on TOP COLDATA, addr = 3
		femb->i2c_write(0, 3, 0, 0x2D, 0xB2); // only works on TOP COLDATA, addr = 3

		// set ACTCOMMANDREG register to 9
		femb->i2c_write(0, 3, 0, 0x20, 0x09);

		// issue FAST ACT command to enable loopback
		io_reg_write (&(femb->coldata_fast_cmd[0]), REG_FAST_CMD_CODE, 2);

		// dummy writes to burn time, to let FAST command finish
		for (int s = 0; s < 6; s++)
			io_reg_write (&(femb->coldata_i2c[0]), REG_COLD_I2C_STIM, 0);

		// issue stimulus
		io_reg_write (&(femb->coldata_i2c[0]), REG_COLD_I2C_STIM, 1);

		// wait a bit for loopback to arrive
		usleep(10);

		// read measured latency
		uint32_t latn = io_reg_read (&(femb->coldata_i2c[0]), REG_COLD_I2C_LATN);

		// remove stimulus, otherwise I2C SDA line will be left shorted to 0
		io_reg_write (&(femb->coldata_i2c[0]), REG_COLD_I2C_STIM, 0);

		printf ("latency: %d\n", latn);
	}
}

