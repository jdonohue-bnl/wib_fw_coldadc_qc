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

	int i;
//	if (argc == 1)
	{
		printf ("writing\n");
		for (i = 0; i >= 0; i--)
		{
			femb->i2c_write (i, 3, 5, 0x40, 0x3);	
			printf ("\n");
		}
	}
	for (i = 0; i < 2; i++)
	//for (i = 0; i >= 0; i--)
	{
//		reg3 = femb->i2c_read  (i, 2, 5, 0x40);	printf("CONFIG_PLL_ICP = %x\n",reg3);
//		printf ("\n");
	}


}

