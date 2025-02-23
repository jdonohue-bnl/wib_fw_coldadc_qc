`include "PACKAGE.types.colData.sv"
`include "PACKAGE.constants.colData.sv"
//*******************************************************************************************
//*******************************************************************************************
//***
//***	Module Name: dataFeed
//***		The purpose of this module is to output a single bit to the LARASIC.
//***	Given a single bit (dataToBeOutput) and a clock (Clk_64MHz_Sys), the module
//***	manipulates SDO and SCK to transmit that single bit to the LARASIC.
//***
//*******************************************************************************************
//*******************************************************************************************
module	dataFeed	(	output	logic				SDO,
										output	logic				SCK,
										output	logic				flag_S0_DF_IDLE,
										output	logic				flag_S1_DF_NEWDATA,
										output	logic				flag_S2_DF_SCK1,
										output	logic				flag_S3_DF_SCK0,
										input		logic				dataToBeOutput,
										input		logic				validScanData,
										input 	logic [7:0] dataFeedCount,
										input		logic				Clk_64MHz_Sys,
										input		logic				Rst_ACTIVE_LOW
									);


//***************************
//***
//***	Variables
//***
//***************************
	dataFeedStates	feedState;
	dataFeedStates	nextFeedState;

	logic						almostSDO;
	logic 	[7:0]		S1_DF_NEWDATA_Count;
	logic 	[7:0]		S2_DF_SCK1_Count;
	logic 	[7:0]		S3_DF_SCK0_Count;

	logic 	[7:0]		fullCount;
	logic 	[6:0]		halfCount;

//***************************
//***
//***	Assignments
//***
//***************************
	assign	flag_S0_DF_IDLE			=	(feedState == S0_DF_IDLE		?	ONE	:	ZERO);
	assign	flag_S1_DF_NEWDATA	=	(feedState == S1_DF_NEWDATA	?	ONE	:	ZERO);
	assign	flag_S2_DF_SCK1			=	(feedState == S2_DF_SCK1		?	ONE	:	ZERO);
	assign	flag_S3_DF_SCK0			=	(feedState == S3_DF_SCK0		?	ONE	:	ZERO);

	assign 	fullCount 		=	dataFeedCount - 8'b0000_0001;
	assign 	halfCount			=	dataFeedCount[7:1] - 7'b000_0001;

//***************************
//***
//***	State Machine
//***
//***************************
	//***State Registers
	always_ff @(posedge Clk_64MHz_Sys or negedge Rst_ACTIVE_LOW)
	if (Rst_ACTIVE_LOW == ZERO)
		feedState <= S0_DF_IDLE;
	else
		feedState <= nextFeedState;

	//***************************
	//***
	//*** State Logic
	//***	1) If we are in Idle and there is no validScanData, we stay in Idle (S0_DF_IDLE)
	//*** 2) If we are in Idle and there is validScanData, we move to NewData (S1_DF_NEWDATA)
	//***	3) If we are in NewData, it is time to output new SDO data
	//***	4) If we are in NewData, we remain here for dataFeedCount/2 Clk_64MHz_Sys periods
	//*** 			then we move on to SCK=1 (S2_DF_SCK1)
	//*** 5) If we are in SCK=1, we remain here for dataFeedCount Clk_64MHz_Sys periods
	//*** 			then we move on to SCK=0 (S3_DF_SCK0)
	//*** 6) If we are in SCK=0, we remain here for dataFeedCount/2 Clk_64MHz_Sys periods
	//*** 			then we move on to Idle (S0_DF_IDLE)
	//***
	//***************************
	always_comb
		unique case	(feedState)
		S0_DF_IDLE		:	if	( validScanData	==	ONE )
												nextFeedState	=	S1_DF_NEWDATA;
										else
												nextFeedState	=	S0_DF_IDLE;

		S1_DF_NEWDATA	:	if 	( S1_DF_NEWDATA_Count >= halfCount )
												nextFeedState	=	S2_DF_SCK1;
										else
												nextFeedState	=	S1_DF_NEWDATA;

		S2_DF_SCK1		:	if 	( S2_DF_SCK1_Count >= fullCount )
												nextFeedState	=	S3_DF_SCK0;
										else
												nextFeedState	=	S2_DF_SCK1;

		S3_DF_SCK0		:	if 	( S3_DF_SCK0_Count[6:0] >= halfCount )
												nextFeedState	=	S0_DF_IDLE;
										else
												nextFeedState	=	S3_DF_SCK0;
		endcase

	//***************************
	//***
	//*** The Counters
	//*** 	All the counters are essentially the same.  During their state, then count
	//*** by one.  During their orthogonal state, they reset to zero.
	//***
	//***************************
	logic 	Rst_S1_DF_NEWDATA_Count;
	logic 	Rst_S2_DF_SCK1_Count;
	logic 	Rst_S3_DF_SCK0_Count;

	assign	Rst_S1_DF_NEWDATA_Count	=	!Rst_ACTIVE_LOW || (feedState	==	S3_DF_SCK0_Count);

	always @( posedge Clk_64MHz_Sys or posedge Rst_S1_DF_NEWDATA_Count	)
		if( Rst_S1_DF_NEWDATA_Count == ONE )
			S1_DF_NEWDATA_Count 	<=	8'b0000_0000;
		else if( feedState == S1_DF_NEWDATA )
		 	S1_DF_NEWDATA_Count 	<=	S1_DF_NEWDATA_Count + 8'b0000_0001;
		else
			S1_DF_NEWDATA_Count 	<=	S1_DF_NEWDATA_Count;

	assign	Rst_S2_DF_SCK1_Count	=	!Rst_ACTIVE_LOW || (feedState	==	S0_DF_IDLE);

	always @( posedge Clk_64MHz_Sys or posedge Rst_S2_DF_SCK1_Count	)
		if( Rst_S2_DF_SCK1_Count == ONE )
			S2_DF_SCK1_Count 	<=	8'b0000_0000;
		else if( feedState == S2_DF_SCK1 )
		 	S2_DF_SCK1_Count 	<=	S2_DF_SCK1_Count + 8'b0000_0001;
		else
			S2_DF_SCK1_Count 	<=	S2_DF_SCK1_Count;

	assign	Rst_S3_DF_SCK0_Count	=	!Rst_ACTIVE_LOW || (feedState	==	S1_DF_NEWDATA);

	always @( posedge Clk_64MHz_Sys or posedge Rst_S3_DF_SCK0_Count	)
		if( Rst_S3_DF_SCK0_Count == ONE )
			S3_DF_SCK0_Count 	<=	8'b0000_0000;
		else if( feedState == S3_DF_SCK0 )
		 	S3_DF_SCK0_Count 	<=	S3_DF_SCK0_Count + 8'b0000_0001;
		else
			S3_DF_SCK0_Count 	<=	S3_DF_SCK0_Count;

	//*** The Outputs
	always @( posedge Clk_64MHz_Sys )
		if( (feedState == S0_DF_IDLE) && (validScanData == ZERO))
			SDO		<=	ZERO;
		else if ( feedState == S1_DF_NEWDATA )
			SDO 	<=	dataToBeOutput;
		else
			SDO 	<=	SDO;

	always @( posedge Clk_64MHz_Sys )
		if ( feedState == S2_DF_SCK1 )
			SCK		<=	ONE;
		else
		 	SCK 	<= 	ZERO;

endmodule

//*******************************************************************************************
//*******************************************************************************************
//***
//***	Module Name: scanInScanOut
//***		The purpose of this module is, given 144-bits of data to be scanned out to LARASIC,
//***	provide that data 1 bit at a time to the dataFeed module so that it can scan that data
//***	out to the LARASIC.  Simultaneously, it must capture the data scanned out by the LARASIC
//*** back into a second 144-bit data array for later comparison.
//***
//*******************************************************************************************
//*******************************************************************************************
module	scanInScanOut	(	output	logic					SCK,
												output	logic					SDO,
												input		logic					SDI,
												output	logic					CS,
												input		logic					Clk_64MHz_Sys,
												input		logic					scanStart,
												output	logic					scanDone,
												output 	logic 				compareResult,
												input		logic [143:0]	dataToBeScannedOut,
												input 	logic [7:0]		dataFeedCount,
												input		logic					Rst_ACTIVE_LOW
											);

//***************************
//***
//***	Variables
//***
//***************************

				scanInOutStates	scanState;
				scanInOutStates	nextScanState;

	 			logic	[7:0]		chainPointer;

	 			logic	[143:0]	SDOchain;

	 			logic					dataToBeOutput;
				logic					flag_S0_SISO_IDLE;
				logic					flag_S1_SISO_LOAD;
	 			logic					flag_S2_SISO_SCAN;
				logic					flag_S3_SISO_DONE;

	 			logic					startDataFeed;

	 			logic					SDOscanBackbit;

				logic 				validScanData;

	wire 	logic		flag_S0_DF_IDLE;
	wire 	logic		flag_S1_DF_NEWDATA;
	wire 	logic		flag_S2_DF_SCK1;
	wire 	logic		flag_S3_DF_SCK0;

//***************************
//***
//***	Assignments
//***
//***************************
	assign	flag_S0_SISO_IDLE	=	(scanState == S0_SISO_IDLE)	?	ONE	:	ZERO;
	assign	flag_S1_SISO_LOAD	=	(scanState == S1_SISO_LOAD)	?	ONE	:	ZERO;
	assign	flag_S2_SISO_SCAN	=	(scanState == S2_SISO_SCAN)	?	ONE	:	ZERO;
	assign	flag_S3_SISO_DONE	=	(scanState == S3_SISO_DONE)	?	ONE	:	ZERO;

	assign 	scanDone 	=	flag_S3_SISO_DONE;

//***************************
//***
//***	State Machine
//***
//***************************
	//State Registers
	always_ff @(posedge Clk_64MHz_Sys or negedge Rst_ACTIVE_LOW)
	if (Rst_ACTIVE_LOW == ZERO)
		scanState <= S0_SISO_IDLE;
	else
		scanState <= nextScanState;

	//State Logic
	always_comb
	unique case	(scanState)
		S0_SISO_IDLE		:	if	(scanStart	==	ONE)
												nextScanState	=	S1_SISO_LOAD;
											else
												nextScanState	=	S0_SISO_IDLE;

		S1_SISO_LOAD		:	nextScanState		=	S2_SISO_SCAN;

		S2_SISO_SCAN		:	if	((chainPointer	==	8'b1111_1111) && (flag_S0_DF_IDLE == ONE))
												nextScanState	=	S3_SISO_DONE;
											else
												nextScanState	=	S2_SISO_SCAN;

		S3_SISO_DONE		:	nextScanState		=	S0_SISO_IDLE;

	endcase

//***************************
//***
//***	Follow-on Logic
//***
//***************************
//***
//***	Control the data to be given to dataFeed
//***
//***	A) On the negative edge of the Clk_64MHz_Sys...
//***		In S1_SISO_LOADA, the SDOchain gets loaded in parallel
//***
//***	B) In S3_SISO_SCAN, the chainPointer decrements on the rising edge
//*** 	of flag_dataFeed_Advance
//***
//***************************
	always_ff @(posedge flag_S1_SISO_LOAD)
			SDOchain	<=	dataToBeScannedOut;

	always_ff @(posedge flag_S3_DF_SCK0 or posedge flag_S0_SISO_IDLE)
		if( flag_S0_SISO_IDLE == ONE )
			chainPointer <= 8'b1000_1111; //143
		else
			chainPointer <= chainPointer - 8'b0000_0001;

	assign dataToBeOutput = SDOchain[chainPointer];

//***************************
//***
//***	Create the validScanData signal
//***		Scan data is valid during and after the S1_SISO_LOAD state (flag_S1_SISO_LOAD)
//***	and until after the rising edge of flag_S3_DF_SCK0 when chainPointer equals
//*** -1.  In both cases, S1_SISO_LOAD and flag_S3_DF_SCK0 are activated at
//*** the positive edge of Clk_64MHz_Sys.  Therefore, we can activate validScanData on
//*** the negative edge of Clk_64MHz_Sys under the right conditions.
//***
//***************************

	always @( negedge Clk_64MHz_Sys or posedge flag_S0_SISO_IDLE )
		if (flag_S0_SISO_IDLE == ONE)
			validScanData	<=	ZERO;
		else if ( flag_S1_SISO_LOAD == ONE )
			validScanData	<=	ONE;
		else if (flag_S2_SISO_SCAN && flag_S3_DF_SCK0 && (chainPointer == 8'b1111_1111))
			validScanData <=	ZERO;
		else
			validScanData	<=	validScanData;

//***************************
//***
//***		The LARASIC SDI captures incoming data on the falling edge of the SCK and
//***	it advances the shift registers on the rising edge of the SCK.  Moreover,
//***	its SDI (my SDO) is always equal to the data input of the first bit (bit 0) of its
//*** programming daisy chain and its SDO (my SDI) is always equal to the Q output
//*** of the last bit (bit 143) of its programming daisy chain.
//***
//***		So, we capture the current contents of bit 143 (my SDI) on the falling edge of SCK.
//***	We also capture the current contents of bit 0 (my SDO) at the same time.
//***
//***************************

	logic 	capturedSDI;
	logic 	capturedSDO;

	always @( negedge SCK )
		begin
			capturedSDI	<=	SDI;
			capturedSDO	<=	SDO;
		end

//***************************
//***
//***		Since the LARASIC always outputs bit 143 of its daisy chain, and since
//***	we are always shifting in 144 bits (from 0 to 143) and since my SDO is equal
//***	to the D input of bit 0 of the daisy chain, and, finally, since we intend
//*** to do a double scan, my SDI should always have the same logical value as
//*** my SDO during the second scan. If we always do an instantanious combinatorial
//*** comparison of my SDI and my SDO and then keep a running comparison during the
//*** scan, we will be able to provide the results of the comparison as soon as
//*** the second scan is over.
//***
//***************************

	logic 	runningComparison;
	logic 	instantComparison;
	logic 	Rst_runningComparison;

	always_comb
		instantComparison	=	(capturedSDI == capturedSDO) ?	ONE	:	ZERO;

	assign 	Rst_runningComparison =	flag_S0_SISO_IDLE	|| (chainPointer == 8'b1000_1111); //8'b1000_1111 = 143

	always @( posedge SCK or posedge Rst_runningComparison )
		if ( Rst_runningComparison == ONE )
			runningComparison	<=	ONE;
		else
			runningComparison	<=	runningComparison && instantComparison;

	always @( posedge scanDone or negedge Rst_ACTIVE_LOW)
		if( Rst_ACTIVE_LOW == ZERO )
			compareResult	<=	ZERO;
		else
			compareResult	<=	runningComparison;

//***************************
//***
//***	In S2_SISO_ACTDF, the CS (chip select) signal is activated
//***	In S4_SISO_DONE, the CS signal is deactivated
//***	In S0_SISO_IDLE, it is reset
//***
//***************************
	always_ff @(negedge Clk_64MHz_Sys or posedge flag_S0_SISO_IDLE)
		if (flag_S0_SISO_IDLE == ONE)
			CS	<=	ZERO;
		else if ((flag_S1_SISO_LOAD == ONE) || (flag_S2_SISO_SCAN == ONE))
			CS	<=	ONE;
		else
			CS	<=	ZERO;

//***************************
//***
//***	Instantiate the dataFeed
//***
//***************************

	dataFeed	df0	(	.SDO(										SDO									),
									.SCK(										SCK									),
									.flag_S0_DF_IDLE(				flag_S0_DF_IDLE			),
									.flag_S1_DF_NEWDATA(		flag_S1_DF_NEWDATA	),
									.flag_S2_DF_SCK1(				flag_S2_DF_SCK1			),
									.flag_S3_DF_SCK0(				flag_S3_DF_SCK0			),
									.dataToBeOutput(				dataToBeOutput			),
									.validScanData(					validScanData				),
									.dataFeedCount(					dataFeedCount				),
									.Clk_64MHz_Sys(					Clk_64MHz_Sys				),
									.Rst_ACTIVE_LOW(				Rst_ACTIVE_LOW			)
								);

endmodule

//*******************************************************************************************
//*******************************************************************************************
//***
//***	Module Name: fastActCapture
//***
//*******************************************************************************************
//*******************************************************************************************
module	fastActCapture	(	output 	logic		capturedCommand,
													input 	logic 	freeCommand,
													input 	logic		commandEnable,
													input 	logic 	commandTerminate,
													input		logic		Clk_64MHz_Sys,
													input		logic		Rst_ACTIVE_LOW
												);

	//*** 	All  capturedCommand is activated by the negative edge of the Clk_64MHz_Sys
	//***	and exists for one clock period (negative edge to negative edge)
	always @( posedge Clk_64MHz_Sys or negedge Rst_ACTIVE_LOW )
		if (Rst_ACTIVE_LOW == ZERO)
			capturedCommand 	<=	ZERO;
		else if ( (freeCommand == ONE) && (commandEnable == ONE) )
			capturedCommand 	<=	ONE;
		else if ( commandTerminate == ONE )
			capturedCommand 	<=	ZERO;
		else
			capturedCommand 	<=	capturedCommand;

endmodule

//*******************************************************************************************
//*******************************************************************************************
//***
//***	Module Name: colData_FE_Calibrate
//***
//*******************************************************************************************
//*******************************************************************************************
module	colData_FE_Calibrate	(	output	logic				SCK,
																output	logic				SDO,
																output	logic				CS,
																output 	logic 			flag_CALIB_RUNNING,
																input		logic				Clk_64MHz_Sys,
																input		logic				Clk_2MHz_Sys,
																input		logic	[7:0]	Req_2MHZ_Count,
																input		logic	[7:0]	Req_64MHZ_Count,
																input		logic	[7:0]	Req_CALIB_Count,
																input 	logic 			flag_calibrateStart,
																input 	logic 			stopCalibrating,
																input		logic				Rst_ACTIVE_LOW
															);
//***************************
//***
//***	Variables
//***
//***************************

				calibrateState_type	calibrateState;
				calibrateState_type	nextCalibrateState;

				logic				found_ADC_CONV;
				logic	[7:0]	count_2MHZ;
				logic	[7:0]	count_64MHZ;
				logic	[7:0]	count_CALIB;
				logic				basicClearFAC;
				logic				calibrateClear;
				logic				Clear2;

	wire	logic				clearCounters;
	wire	logic				clearCalibCnt;

	wire	logic				clearFAC;

//***************************
//***
//***	Assignments
//***
//***************************

	assign	flag_CALIB_IDLE				=	(calibrateState == S0_CALIB_IDLE)			?	ONE	:	ZERO;
	assign	flag_CALIB_CNT2MHZ		=	(calibrateState == S1_CALIB_CNT2MHZ)	?	ONE	:	ZERO;
	assign	flag_CALIB_CNT64MHZ		=	(calibrateState == S2_CALIB_CNT64MHZ)	?	ONE	:	ZERO;
	assign	flag_CALIB_CALIB			=	(calibrateState == S3_CALIB_CALIB)		?	ONE	:	ZERO;
	assign 	flag_CALIB_RUNNING		=	!flag_CALIB_IDLE;

	assign 	flag_IDLE_OR_CNT2MHZ 	=	flag_CALIB_IDLE || flag_CALIB_CNT2MHZ;
	assign 	flag_IDLE_OR_CNT64MHZ =	flag_CALIB_IDLE || flag_CALIB_CNT64MHZ;
	assign 	flag_IDLE_OR_CALIB		=	flag_CALIB_IDLE	||	flag_CALIB_CALIB;

//***************************
//***
//***	State Machine
//***
//***************************
	//State Registers
	always_ff @(posedge Clk_64MHz_Sys or negedge Rst_ACTIVE_LOW)
	if (Rst_ACTIVE_LOW == ZERO)
		calibrateState	<=	S0_CALIB_IDLE;
	else
		calibrateState	<=	nextCalibrateState;

	//State Logic
	always_comb
	unique	case	(calibrateState)

	//S0_CALIB_IDLE			:	if ((flag_calibrateStart == ONE) && (BlockCalibrate == ZERO))
	S0_CALIB_IDLE			:	if (flag_calibrateStart == ONE)
												nextCalibrateState	=	S1_CALIB_CNT2MHZ;
											else
												nextCalibrateState	=	S0_CALIB_IDLE;

	S1_CALIB_CNT2MHZ	:	if (stopCalibrating == ONE)
												nextCalibrateState	=	S0_CALIB_IDLE;
											else if (count_2MHZ	==	Req_2MHZ_Count)
												nextCalibrateState	=	S2_CALIB_CNT64MHZ;
											else
												nextCalibrateState	=	S1_CALIB_CNT2MHZ;

	S2_CALIB_CNT64MHZ	:	if (stopCalibrating == ONE)
												nextCalibrateState	=	S0_CALIB_IDLE;
											else if (count_64MHZ		==	Req_64MHZ_Count)
												nextCalibrateState	=	S3_CALIB_CALIB;
											else
												nextCalibrateState	=	S2_CALIB_CNT64MHZ;

	S3_CALIB_CALIB		:	if (stopCalibrating == ONE)
												nextCalibrateState	=	S0_CALIB_IDLE;
											else if ((count_CALIB	>=	Req_CALIB_Count) && (stopCalibrating == ZERO))
												nextCalibrateState	=	S1_CALIB_CNT2MHZ;
											else
												nextCalibrateState	=	S3_CALIB_CALIB;

	//default 					:	nextCalibrateState	=	S0_CALIB_IDLE;

	endcase

//***************************
//***
//***	Follow-on Logic
//***
//***************************
	//If I am in Calibrate Mode, I start in S1_CALIB_CNT2MHZ
	//First I count the number of Clk_2MHz_Sys rising edges
	always @(posedge Clk_2MHz_Sys or posedge flag_IDLE_OR_CNT64MHZ)
		if (flag_IDLE_OR_CNT64MHZ == ONE)
			count_2MHZ	<=	8'b0000_0000;
		else if (calibrateState == S1_CALIB_CNT2MHZ)
			count_2MHZ	<=	count_2MHZ + 8'b0000_0001;

	//When I reach the appropriate number of Clk_2MHz_Sys rising edges
	//then I count the number of Clk_64MHz_Sys rising edges
	always @(posedge Clk_64MHz_Sys or posedge flag_IDLE_OR_CALIB)
		if (flag_IDLE_OR_CALIB == ONE)
			count_64MHZ	<=	8'b0000_0000;
		else if (calibrateState == S2_CALIB_CNT64MHZ)
			count_64MHZ	<=	count_64MHZ + 8'b0000_0001;

	//When I reach the appropriate number of Clk_64MHz_Sys rising edges
	//then I activate the Calibrate signal and count the number of Clk_64MHz_Sys rising edges
	//to obtain the appropriate Calibrate signal width

	always @(posedge Clk_64MHz_Sys or posedge flag_IDLE_OR_CNT2MHZ)
		if (flag_IDLE_OR_CNT2MHZ == ONE)
			count_CALIB	<=	8'b0000_0000;
		else if (calibrateState == S3_CALIB_CALIB)
			count_CALIB	<=	count_CALIB + 8'b0000_0001;

	//Output the CALIB_STRB signal
	always @(posedge Clk_64MHz_Sys)
		if (calibrateState == S0_CALIB_IDLE)
			begin
				SCK 	<=	ZERO;
				SDO 	<=	ZERO;
				CS 		<=	ZERO;
			end
		else if (calibrateState == S1_CALIB_CNT2MHZ)
			begin
				SCK 	<=	ZERO;
				SDO 	<=	ZERO;
				CS 		<=	ZERO;
			end
		else if (calibrateState == S2_CALIB_CNT64MHZ)
			begin
				SCK 	<=	ZERO;
				SDO 	<=	ZERO;
				CS 		<=	ZERO;
			end
		else if (calibrateState == S3_CALIB_CALIB)
			begin
				SCK 	<=	ONE;
				SDO 	<=	ZERO;
				CS 		<=	ZERO;
			end
		else
			begin
				SCK 	<=	ZERO;
				SDO 	<=	ZERO;
				CS 		<=	ZERO;
			end

endmodule


//*******************************************************************************************
//*******************************************************************************************
//***
//***	Module Name: colData_feConfig
//***
//*******************************************************************************************
//*******************************************************************************************
module	colData_feConfig	(	output	logic					SCK,
														output	logic					SDO,
														input		logic					SDI,
														output	logic					CS,
														input		logic					Clk_64MHz_Sys,
														input 	logic 				Clk_2MHz_Sys,
														input		logic					fastAct_LARASIC_Calibrate,
														input		logic					fastAct_LARASIC_Reset,
														input		logic					fastAct_LARASIC_Program,
														input 	logic [7:0]		Req_2MHZ_Count,
														input 	logic [7:0]		Req_64MHZ_Count,
														input 	logic [7:0]		Req_CALIB_Count,
														input 	logic [7:0]		requiredHardCount,
														input 	logic [7:0]		dataFeedCount,
														input		logic [143:0]	dataToBeScannedOut,
														output	logic					compDone,
														output	logic					compResult,
														output 	logic 				calibDone,
														input		logic					Rst_ACTIVE_LOW
													);

//***************************
//***
//***	Variables
//***
//***************************
	feConfigStates			configState;
	feConfigStates			nextConfigState;

				logic [7:0]		step1Count;
				logic [7:0]		step2Count;
				logic [7:0]		step3Count;

	wire	logic					SCK_CALIB;
	wire	logic					SDO_CALIB;
	wire	logic					CS_CALIB;
	wire	logic					flag_CALIB_RUNNING;
	wire	logic					SCK_SCAN;
	wire	logic					SDO_SCAN;
	wire	logic					SDI_SCAN;
	wire	logic					CS_SCAN;
	wire	logic					startScanning;
	wire	logic					scanDone;
	wire	logic					startCalibrating;
	wire	logic					stopCalibrating;
	wire	logic					startResetting;
	wire 	logic 				flag_myCalibrateIsRunning;


//***************************
//***
//***	Assignments
//***
//***************************
	assign	flag_CONFIG_IDLE				=	(configState == S0_IDLE)				?	ONE	:	ZERO;
	assign	flag_CONFIG_PROG_START	=	(configState == S1_PROG_START)	?	ONE	:	ZERO;
	assign	flag_CONFIG_PROG_SCAN1	=	(configState == S2_PROG_SCAN1)	?	ONE	:	ZERO;
	assign	flag_CONFIG_PROG_PAUSE	=	(configState == S3_PROG_PAUSE)	?	ONE	:	ZERO;
	assign	flag_CONFIG_PROG_SCAN2	=	(configState == S4_PROG_SCAN2)	?	ONE	:	ZERO;
	assign	flag_CONFIG_PROG_DONE		=	(configState == S5_PROG_DONE)		?	ONE	:	ZERO;
	assign 	flag_CONFIG_CALIB_START	=	(configState == S6_CALIB_START)	?	ONE	:	ZERO;
	assign 	flag_CONFIG_CALIB_RUN		=	(configState == S7_CALIB_RUN)		?	ONE	:	ZERO;
	assign	flag_CONFIG_CALIB_DONE	=	(configState == S8_CALIB_DONE)	?	ONE	:	ZERO;
	assign	flag_CONFIG_HARD_START	=	(configState == S9_HARD_START)	?	ONE	:	ZERO;
	assign	flag_CONFIG_HARD_STEP1	=	(configState == S10_HARD_STEP1)	?	ONE	:	ZERO;
	assign	flag_CONFIG_HARD_STEP2	=	(configState == S11_HARD_STEP2)	?	ONE	:	ZERO;
	assign	flag_CONFIG_HARD_STEP3	=	(configState == S12_HARD_STEP3)	?	ONE	:	ZERO;
	assign	flag_CONFIG_HARD_DONE		=	(configState == S13_HARD_DONE)	?	ONE	:	ZERO;

	assign	flag_almostDone	=	flag_CONFIG_PROG_DONE || flag_CONFIG_CALIB_DONE || flag_CONFIG_HARD_DONE;
	assign 	flag_NotProgramming	=	!(flag_CONFIG_PROG_START || flag_CONFIG_PROG_SCAN1
																				|| flag_CONFIG_PROG_PAUSE || flag_CONFIG_PROG_SCAN2 || flag_CONFIG_PROG_DONE);
	assign 	flag_NotCalibrating	=	!(flag_CONFIG_CALIB_START || flag_CONFIG_CALIB_RUN || flag_CONFIG_CALIB_DONE);
	assign 	flag_NotResetting	=	!(flag_CONFIG_HARD_START || flag_CONFIG_HARD_STEP1
																				|| flag_CONFIG_HARD_STEP2 || flag_CONFIG_HARD_STEP3	|| flag_CONFIG_HARD_DONE);

//***************************
//***
//***	State Machine
//***
//***************************
	//State Registers
	always_ff @(posedge Clk_64MHz_Sys or negedge Rst_ACTIVE_LOW)
	if (Rst_ACTIVE_LOW == ZERO)
		configState <= S0_IDLE;
	else
		configState <= nextConfigState;

	//State Logic
	always_comb
	unique case	(configState)

		S0_IDLE					:	if (startScanning	==	ONE)
												nextConfigState	=	S1_PROG_START;
											else if (startCalibrating == 	ONE)
												nextConfigState	=	S6_CALIB_START;
											else if (startResetting == 	ONE)
												nextConfigState	=	S9_HARD_START;
											else
												nextConfigState	=	S0_IDLE;

		S1_PROG_START		:	nextConfigState	=	S2_PROG_SCAN1;

		S2_PROG_SCAN1		:	if (scanDone	==	ONE)
												nextConfigState	=	S3_PROG_PAUSE;
											else
												nextConfigState	=	S2_PROG_SCAN1;

		S3_PROG_PAUSE		:	nextConfigState	=	S4_PROG_SCAN2;

		S4_PROG_SCAN2		:	if (scanDone	==	ONE)
												nextConfigState	=	S5_PROG_DONE;
											else
												nextConfigState	=	S4_PROG_SCAN2;

		S5_PROG_DONE		:	nextConfigState	=	S0_IDLE;

		S6_CALIB_START	:	nextConfigState	=	S7_CALIB_RUN;

		S7_CALIB_RUN		:	if (stopCalibrating	==	ONE)
												nextConfigState	=	S8_CALIB_DONE;
											else
												nextConfigState	=	S7_CALIB_RUN;

		S8_CALIB_DONE		:	nextConfigState	=	S0_IDLE;

		S9_HARD_START		:	nextConfigState	=	S10_HARD_STEP1;

		S10_HARD_STEP1	:	if (step1Count	==	requiredHardCount)
												nextConfigState	=	S11_HARD_STEP2;
											else
												nextConfigState	=	S10_HARD_STEP1;

		S11_HARD_STEP2	:	if (step2Count	==	requiredHardCount)
												nextConfigState	=	S12_HARD_STEP3;
											else
												nextConfigState	=	S11_HARD_STEP2;

		S12_HARD_STEP3	:	if (step3Count	==	requiredHardCount)
												nextConfigState	=	S13_HARD_DONE;
											else
												nextConfigState	=	S12_HARD_STEP3;


		S13_HARD_DONE		:	nextConfigState	=	S0_IDLE;

	endcase

//***************************
//***
//***	Circuit Block Instantiations
//***
//***************************

	//*** Since the fastAct commands exist from one negative edge of Clk_64MHz_Sys to the next,
	//*** 	they must be captured and held if there is a chance they might need to exist for
	//***		a longer period of time.  In the case of the config interface, these fastAct
	//*** 	commands can come at almost any time and must endure until used.

	//***	In the case of the Calibration of LARASIC, there is one command, fastAct_LARASIC_Calibrate
	//***		that is used once to start the Calibrate phase and once to end it.  The start command
	//***		can occur at any time as long as the colData_feConfig state machine is not already
	//*** 	calibrating (hence flag_NotCalibrating).  The start command can end as soon as we are
	//***		actually calibrating (flag_CONFIG_CALIB_RUN), but if there was a timing issue and
	//*** 	the startCalibrating command were to disappear before the colData_FE_Calibrate state machine
	//*** 	advanced to its S1_CALIB_CNT2MHZ state, thre could be problems. Since the
	//*** 	start command has no consequences while we are actually calibrating, it is safe to wait
	//*** 	until the calibration is done (flag_CONFIG_CALIB_DONE) to terminate the start command.
	//*** 	The stop command can only be issued while we are calibrating (flag_CONFIG_CALIB_RUN) and
	//*** 	it is terminated when we return to idle (flag_CONFIG_IDLE).

	fastActCapture	startCalibrate_1	(	.capturedCommand(		startCalibrating					),
																			.freeCommand(				fastAct_LARASIC_Calibrate	),
																			.commandEnable(			flag_NotCalibrating				),
																			.commandTerminate(	flag_CONFIG_CALIB_DONE		),
																			.Clk_64MHz_Sys(			Clk_64MHz_Sys							),
																			.Rst_ACTIVE_LOW(		Rst_ACTIVE_LOW						)
																		);

	fastActCapture	stopCalibrate_2		(	.capturedCommand(		stopCalibrating						),
																			.freeCommand(				fastAct_LARASIC_Calibrate	),
																			.commandEnable(			flag_CONFIG_CALIB_RUN			),
																			.commandTerminate(	flag_CONFIG_IDLE					),
																			.Clk_64MHz_Sys(			Clk_64MHz_Sys							),
																			.Rst_ACTIVE_LOW(		Rst_ACTIVE_LOW						)
																		);

	colData_FE_Calibrate	colData_FE_Calibrate_0	(	.SCK(									SCK_CALIB									),
																									.SDO(									SDO_CALIB									),
																									.CS(									CS_CALIB									),
																									.flag_CALIB_RUNNING(	flag_myCalibrateIsRunning	),
																									.Clk_64MHz_Sys(				Clk_64MHz_Sys							),
																									.Clk_2MHz_Sys(				Clk_2MHz_Sys							),
																									.Req_2MHZ_Count(			Req_2MHZ_Count						),
																									.Req_64MHZ_Count(			Req_64MHZ_Count						),
																									.Req_CALIB_Count(			Req_CALIB_Count						),
																									.flag_calibrateStart(	flag_CONFIG_CALIB_START		),
																									.stopCalibrating(			stopCalibrating						),
																									.Rst_ACTIVE_LOW(			Rst_ACTIVE_LOW						)
																								);

	//***	In the case of the Programming of LARASIC, there is one command, fastAct_LARASIC_Program
	//*** 	that starts the scan.  It can be executed at any time as long as we are not currently
	//***		programming (flag_NotProgramming) and is terminated when the programming is done
	//*** 	(flag_CONFIG_PROG_DONE). Note that startScanning advances the configState (colData_feConfig state machine)
	//***		flag_CONFIG_PROG_START and

	fastActCapture	startScan_3		(	.capturedCommand(		startScanning							),
																	.freeCommand(				fastAct_LARASIC_Program		),
																	.commandEnable(			flag_NotProgramming				),
																	.commandTerminate(	flag_CONFIG_PROG_DONE			),
																	.Clk_64MHz_Sys(			Clk_64MHz_Sys							),
																	.Rst_ACTIVE_LOW(		Rst_ACTIVE_LOW						)
																);

	assign 	scanStartTwice	=	flag_CONFIG_PROG_START || flag_CONFIG_PROG_PAUSE;

	scanInScanOut	scanInScanOut_4	(	.SCK(									SCK_SCAN						),
																	.SDO(									SDO_SCAN						),
																	.SDI(									SDI									),
																	.CS(									CS_SCAN							),
																	.Clk_64MHz_Sys(				Clk_64MHz_Sys				),
																	.scanStart(						scanStartTwice			),
																	.scanDone(						scanDone						),
																	.compareResult(				compareResult				),
																	.dataToBeScannedOut(	dataToBeScannedOut	),
																	.dataFeedCount(				dataFeedCount				),
																	.Rst_ACTIVE_LOW(			Rst_ACTIVE_LOW			)
																);

	//***	In the case of the Hard Reset of LARASIC, there is one command, fastAct_LARASIC_Reset
	//*** 	that starts the reset.  It can be executed at any time as long as we are not currently
	//***		resetting (flag_NotResetting) and is terminated when the resetting is done
	//*** 	(flag_CONFIG_PROG_DONE).

	fastActCapture	startRst_5		(	.capturedCommand(		startResetting						),
																	.freeCommand(				fastAct_LARASIC_Reset			),
																	.commandEnable(			flag_NotResetting					),
																	.commandTerminate(	flag_CONFIG_HARD_DONE			),
																	.Clk_64MHz_Sys(			Clk_64MHz_Sys							),
																	.Rst_ACTIVE_LOW(		Rst_ACTIVE_LOW						)
																);

	//***************************
	//***
	//***	Follow-on Logic
	//***
	//***************************
	//***
	//*** Increment step1Count during flag_CONFIG_HARD_STEP1
	//*** Increment step2Count during flag_CONFIG_HARD_STEP2
	//*** Increment step3Count during flag_CONFIG_HARD_STEP3
	//***	Zero them during IDLE
	//*** Hold them otherwise

	always @( negedge Clk_64MHz_Sys or posedge flag_CONFIG_IDLE )
		if( flag_CONFIG_IDLE == ONE )
			begin
				step1Count	<=	8'b0000_0000;
				step2Count	<=	8'b0000_0000;
				step3Count	<=	8'b0000_0000;
			end
		else if ( flag_CONFIG_HARD_STEP1 == ONE )
			begin
				step1Count	<=	step1Count + 8'b0000_0001;
				step2Count	<=	step2Count;
				step3Count	<=	step3Count;
			end
		else if ( flag_CONFIG_HARD_STEP2 == ONE )
			begin
				step1Count	<=	step1Count;
				step2Count	<=	step2Count + 8'b0000_0001;
				step3Count	<=	step3Count;
			end
		else if ( flag_CONFIG_HARD_STEP3 == ONE )
			begin
				step1Count	<=	step1Count;
				step2Count	<=	step2Count;
				step3Count	<=	step3Count + 8'b0000_0001;
			end
		else
			begin
				step1Count	<=	step1Count;
				step2Count	<=	step2Count;
				step3Count	<=	step3Count;
			end

	//*** Set the status flag compDone when the programming is done (flag_CONFIG_PROG_DONE)
	always @( posedge flag_CONFIG_PROG_DONE or posedge flag_CONFIG_PROG_START )
		if( flag_CONFIG_PROG_START == ONE )
			compDone 	<=	ZERO;
		else
			compDone 	<=	ONE;

	always @( posedge compDone or posedge flag_CONFIG_PROG_START )
	if( flag_CONFIG_PROG_START == ONE )
		compResult 	<=	ZERO;
	else
		compResult	<=	compareResult;

	//*** Set the status flag calibDone when the calibration is done (flag_CONFIG_CALIB_DONE)
	always @( posedge flag_CONFIG_CALIB_DONE or posedge flag_CONFIG_CALIB_START )
		if( flag_CONFIG_CALIB_START == ONE )
			calibDone 	<=	ZERO;
		else
			calibDone 	<=	ONE;

	//CS, SDO, SCK Logic
	//Output "Default Mode" (i.e. CS=SCK=SDO=zero) unless we are scanning
	always_comb
	unique case (configState)
	S0_IDLE					:	begin
											CS	=	ZERO;
											SCK	=	ZERO;
											SDO	=	ZERO;
										end
//***
	S1_PROG_START		:	begin
											CS	=	ZERO;
											SCK	=	ZERO;
											SDO	=	ZERO;
										end
//***
//***
	S2_PROG_SCAN1		:	begin
											CS	=	CS_SCAN;
											SCK	=	SCK_SCAN;
											SDO	=	SDO_SCAN;
										end
//***
//***
	S3_PROG_PAUSE		:	begin
											CS	=	ZERO;
											SCK	=	ZERO;
											SDO	=	ZERO;
										end
//***
//***
	S4_PROG_SCAN2		:	begin
											CS	=	CS_SCAN;
											SCK	=	SCK_SCAN;
											SDO	=	SDO_SCAN;
										end
//***
//***
	S5_PROG_DONE		:	begin
											CS	=	ZERO;
											SCK	=	ZERO;
											SDO	=	ZERO;
										end
//***
//***
	S6_CALIB_START	:	begin
											CS	=	ZERO;
											SCK	=	ZERO;
											SDO	=	ZERO;
										end
//***
//***
	S7_CALIB_RUN		:	begin
											CS	=	CS_CALIB;
											SCK	=	SCK_CALIB;
											SDO	=	SDO_CALIB;
										end
//***
//***
	S8_CALIB_DONE		:	begin
											CS	=	ZERO;
											SCK	=	ZERO;
											SDO	=	ZERO;
										end
//***
//***
	S9_HARD_START		:	begin
											CS	=	ZERO;
											SCK	=	ZERO;
											SDO	=	ZERO;
										end
//***
//***
	S10_HARD_STEP1	:	begin
											CS	=	ZERO;
											SCK	=	ONE;
											SDO	=	ZERO;
										end
//***
//***
	S11_HARD_STEP2	:	begin
											CS	=	ONE;
											SCK	=	ONE;
											SDO	=	ZERO;
										end
//***
//***
	S12_HARD_STEP3	:	begin
											CS	=	ZERO;
											SCK	=	ONE;
											SDO	=	ZERO;
										end
//***
//***
	S13_HARD_DONE		:	begin
											CS	=	ZERO;
											SCK	=	ZERO;
											SDO	=	ZERO;
										end
//***
//***
	S14_UNUSED2			:	begin
											CS	=	ZERO;
											SCK	=	ZERO;
											SDO	=	ZERO;
										end
//***
//***
	S15_UNUSED3			:	begin
											CS	=	ZERO;
											SCK	=	ZERO;
											SDO	=	ZERO;
										end
//***
	endcase

endmodule
