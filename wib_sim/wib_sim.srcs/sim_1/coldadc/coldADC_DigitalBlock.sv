`include "PACKAGE.types.coldADC.sv"
`include "PACKAGE.constants.coldADC.sv"

// Madorsky: removed include statement
//`ifndef JIMSCONSTANTS
//	`define	JIMSCONSTANTS
//	`include "PACKAGE.constants.coldADC.sv"
//`endif

//*******************************************************************************************
//*******************************************************************************************
//***
//*** Description: The entire digital backend for the coldADC chip including
//***		coldADC_backend and coldADC_I2Cslave.  Regfile, UART, and I2C/UART
//***		arbitration are located in the cal_core_wrapper.
//***		It is assumed that PACKAGE.constants.coldADC.sv is available to this module.
//*** Author: Jim Hoff
//***
//*******************************************************************************************
//*******************************************************************************************

module	coldADC_DigitalBlock	(
					//***
					//***	Pad Connections
					//***
						//*** for I2C
					output 	logic					PAD_SDA_c2w,			//(I2C) SDA connection (output) from cold to warm
					input 	logic					PAD_SDA_w2c,			//(I2C) SDA connection (input) from warm to cold
					input		logic					PAD_SCL,					//(I2C) SCL connection (serial clock)
					input		logic	[3:0]		PAD_chipID,				//(I2C) I2C and UART chip id
					input 	logic 				PAD_I2C_UART_SEL,	//(I2C) Selection between using UART or I2C
						//*** for Clocks
					input		logic					PAD_Clk_2MHz,			//(MISC) Sample period clock
					input		logic					PAD_Clk_64MHz,		//(MISC) "high speed" system clock
						//*** for Readout
					output	logic					PAD_frameStart,		//(READOUT) Data output, frame start indicator
					output	logic					PAD_dataOutClk,		//(READOUT) Data output, clock
					output	logic					PAD_dataOutA,			//(READOUT)
					output	logic					PAD_dataOutB,			//(READOUT)
					output	logic					PAD_dataOutC,			//(READOUT)
					output	logic					PAD_dataOutD,			//(READOUT)
					output	logic					PAD_dataOutE,			//(READOUT)
					output	logic					PAD_dataOutF,			//(READOUT)
					output	logic					PAD_dataOutG,			//(READOUT)
					output	logic					PAD_dataOutH,			//(READOUT)
						//*** reset
					input 	logic					PAD_MASTER_RESET,

						//*** Not actually for Pads...Control Signals for LVDS
					output	logic	[3:0]		PAD_lvdsICTRL,
					//***
					//***	cal_core_wrapper Connections
					//***
						//*** for I2C
					output 	logic 				CCORE_external_mode_i2c,   			// high to put regfile into extern mode
					output 	logic [7:0] 	CCORE_write_data_external_i2c, 	// RAM data in external
					output 	logic [7:0] 	CCORE_write_addr_external_i2c, 	// 8-bit RAM write address
					output 	logic 				CCORE_write_external_i2c,  			// high for external write
					output 	logic [7:0] 	CCORE_read_addr_external_i2c,  	// 8-bit RAM read address
					input 	logic [7:0] 	CCORE_read_data_external_i2c, 	// RAM data in external
					output 	logic 				CCORE_read_external_i2c,   			// high for read op
						//*** from ADCs
					input 	logic [15:0]	CCORE_adc_out_0, 								// ADC 0 output
					input 	logic [15:0]	CCORE_adc_out_1, 								// ADC 1 output
						//*** Clock for FrontEnd
					output 	logic					CCORE_Clk_16MHz,
						//*** Sample Signal for FrontEnd
					output 	logic					CCORE_frontEndSample,
						//***	from CONFIG registers
					input 	logic [3:0]		CCORE_CONFIG_lvds_i_ctrl,
					input 	logic [4:0] 	CCORE_CONFIG_start_number,
						//*** for the digital test output
					input 	logic [3:0] 	CCORE_CONFIG_dMuxSel,
					output 	logic 				PAD_digital_mux_out

				);

//***************************
//***
//***	Mostly module interconnection
//***
//***************************
	 				//logic	[15:0] 	ADCdata_A;
	 				//logic	[15:0] 	ADCdata_B;

					logic	[6:0]		I2C_pageAddr;
					logic	[7:0]		I2C_regAddr;
					logic	[7:0]		I2C_Data_w2c;
		wire 	logic	[7:0]		I2C_Data_c2w;
					logic	[6:0]		I2C_capPageAddr;
					logic					I2C_valPageAddr;
					logic					I2C_writeOp;
					logic					I2C_readOp;
					logic					I2C_Ack1;
					logic					I2C_Ack2;
					logic					I2C_Ack3;
					logic					I2C_writeReq;
					logic					I2C_softReset;

					logic	[7:0]		I2C_lvdsICTRL;
					logic	[7:0]		I2C_startNumber;
					logic	[7:0]		I2C_dMuxSel;
					logic	[4:0]		BEND_startNumber;
					logic	[3:0]		BEND_dMuxSel;

					logic 				prbs7_bitStream;
					logic 				prbs15_bitStream;

//***************************
//***
//***	Module Instantiations
//***		 Data Registers
//***
//***************************

	//***
	//***	We need to set a couple of I2C registers.  In both cases, we need to be able to overwrite them
	//***		by UART if necessary.  Therefore, we have the standard coldADC I2C registers
	//***		followed by a bit of logic that selects between them as required by the user
	//***
	//***	First, the LVDS default current.
	//***
	reg8bit_1111_1111	BEND_LVDSMAGREG_ADC_0			(	.Data(							I2C_lvdsICTRL	),
																						.dataOutBus(				I2C_Data_c2w	),
																						.dataInBus(					I2C_Data_w2c	),
																						.pageAddr(					I2C_pageAddr	),
																						.requiredChipAddr1(	ADC_BOT_1_ADC			),
																						.requiredChipAddr2(	ADC_BOT_2_ADC			),
																						.requiredChipAddr3(	ADC_BOT_3_ADC			),
																						.requiredChipAddr4(	ADC_BOT_4_ADC			),
																						.requiredChipAddr5(	ADC_TOP_1_ADC			),
																						.requiredChipAddr6(	ADC_TOP_2_ADC			),
																						.requiredChipAddr7(	ADC_TOP_3_ADC			),
																						.requiredChipAddr8(	ADC_TOP_4_ADC			),
																						.requiredPageAddr(	BENDPAGE_ADC			),
																						.regAddr(						I2C_regAddr		),
																						.requiredRegAddr(		LVDSMAGREG_ADC		),
																						.writeReq(					I2C_writeReq	),
																						.softReset(					I2C_softReset	)
																					);

	//***
	//***	Second, the Frame Start start number.
	//***
	reg8bit_0000_0100	BEND_STARTNUMREG_ADC_1		(	.Data(							I2C_startNumber	),
																						.dataOutBus(				I2C_Data_c2w		),
																						.dataInBus(					I2C_Data_w2c		),
																						.pageAddr(					I2C_pageAddr		),
																						.requiredChipAddr1(	ADC_BOT_1_ADC				),
																						.requiredChipAddr2(	ADC_BOT_2_ADC				),
																						.requiredChipAddr3(	ADC_BOT_3_ADC				),
																						.requiredChipAddr4(	ADC_BOT_4_ADC				),
																						.requiredChipAddr5(	ADC_TOP_1_ADC				),
																						.requiredChipAddr6(	ADC_TOP_2_ADC				),
																						.requiredChipAddr7(	ADC_TOP_3_ADC				),
																						.requiredChipAddr8(	ADC_TOP_4_ADC				),
																						.requiredPageAddr(	BENDPAGE_ADC				),
																						.regAddr(						I2C_regAddr			),
																						.requiredRegAddr(		STARTNUMREG_ADC			),
																						.writeReq(					I2C_writeReq		),
																						.softReset(					I2C_softReset		)
																					);

	//***
	//***	Third, the Digital Test Multiplexor
	//***
	reg8bit_0000_0000	BEND_DMUXSELREG_ADC_2			(	.Data(							I2C_dMuxSel			),
																						.dataOutBus(				I2C_Data_c2w		),
																						.dataInBus(					I2C_Data_w2c		),
																						.pageAddr(					I2C_pageAddr		),
																						.requiredChipAddr1(	ADC_BOT_1_ADC				),
																						.requiredChipAddr2(	ADC_BOT_2_ADC				),
																						.requiredChipAddr3(	ADC_BOT_3_ADC				),
																						.requiredChipAddr4(	ADC_BOT_4_ADC				),
																						.requiredChipAddr5(	ADC_TOP_1_ADC				),
																						.requiredChipAddr6(	ADC_TOP_2_ADC				),
																						.requiredChipAddr7(	ADC_TOP_3_ADC				),
																						.requiredChipAddr8(	ADC_TOP_4_ADC				),
																						.requiredPageAddr(	BENDPAGE_ADC				),
																						.regAddr(						I2C_regAddr			),
																						.requiredRegAddr(		DMUXSELREG_ADC			),
																						.writeReq(					I2C_writeReq		),
																						.softReset(					I2C_softReset		)
																					);

//***************************
//***
//***	Module Instantiation
//***		coldADC_I2Cslave
//***
//***************************

	coldADC_I2Cslave	I2C0	(	.SDA_c2w(						PAD_SDA_c2w			),
														.SDA_w2c(						PAD_SDA_w2c			),
														.SCL(								PAD_SCL					),
														.pageAddr(					I2C_pageAddr		),
														.regAddr(						I2C_regAddr			),
														.Data_w2c(					I2C_Data_w2c		),
														.Data_c2w(					I2C_Data_c2w		),
														.capturedPageAddr(	I2C_capPageAddr	),
														.validCapPageAddr(	I2C_valPageAddr	),
														.writeOp(						I2C_writeOp			),
														.readOp(						I2C_readOp			),
														.Ack1(							I2C_Ack1				),
														.Ack2(							I2C_Ack2				),
														.Ack3(							I2C_Ack3				),
														.writeReq(					I2C_writeReq		),
														.softReset(					I2C_softReset		),
														.chipID(						PAD_chipID			),
														.Clk64MHz(					PAD_Clk_64MHz		),
														.Rst_ACTIVE_LOW(		PAD_MASTER_RESET)
													);

//***************************
//***
//***	Module Instantiation
//***	coldADC_I2C_link	-	The connection between the I2C Slave, the UART, and
//***		the regfile
//***
//***************************

	coldADC_I2C_link	LINK1	(	.CCORE_external_mode_i2c(				CCORE_external_mode_i2c				),
													  .CCORE_write_data_external_i2c(	CCORE_write_data_external_i2c	),
													  .CCORE_write_addr_external_i2c(	CCORE_write_addr_external_i2c	),
													  .CCORE_write_external_i2c(			CCORE_write_external_i2c			),
													  .CCORE_read_addr_external_i2c(	CCORE_read_addr_external_i2c	),
													  .CCORE_read_data_external_i2c(	CCORE_read_data_external_i2c	),
													  .CCORE_read_external_i2c(				CCORE_read_external_i2c				),
													  .CCORE_CONFIG_lvds_i_ctrl(			CCORE_CONFIG_lvds_i_ctrl			),
														.CCORE_CONFIG_start_number(			CCORE_CONFIG_start_number			),
														.CCORE_CONFIG_dMuxSel(					CCORE_CONFIG_dMuxSel					),
														.CCORE_Clk_16MHz(								CCORE_Clk_16MHz								),
													  .I2C_pageAddr(								I2C_pageAddr										),
													  .I2C_regAddr(									I2C_regAddr											),
													  .I2C_Data_w2c(								I2C_Data_w2c										),
													  .I2C_Data_c2w(								I2C_Data_c2w										),
													  .I2C_writeOp(									I2C_writeOp											),
													  .I2C_readOp(									I2C_readOp											),
													  .I2C_Ack2(										I2C_Ack2												),
													  .I2C_Ack3(										I2C_Ack3												),
														.I2C_lvdsICTRL(								I2C_lvdsICTRL										),
														.I2C_startNumber(							I2C_startNumber									),
														.BEND_startNumber(						BEND_startNumber								),
														.I2C_dMuxSel(									I2C_dMuxSel											),
														.BEND_dMuxSel(								BEND_dMuxSel										),
													  .PAD_chipID(									PAD_chipID											),
													  .PAD_I2C_UART_SEL(						PAD_I2C_UART_SEL								),
													  .PAD_lvdsICTRL(								PAD_lvdsICTRL										)

													  );

//***************************
//***
//***	Module Instantiation
//***	coldADC_readout	-	Clk_16MHz generation, output frame formation, etc
//***
//***************************

	coldADC_readout		BEND3	(	.frameStart(			PAD_frameStart				),	//To Pin: DIG_FRAME
														.frontEndSample(	CCORE_frontEndSample	),	//To FrontEnd: Sample Signal
														.dataOutClk(			PAD_dataOutClk				),	//To Pin: DIG_CLKOUT
														.dataOutA(				PAD_dataOutA					),	//To Pin: DIG_OUTA
														.dataOutB(				PAD_dataOutB					),	//To Pin: DIG_OUTB
														.dataOutC(				PAD_dataOutC					),	//To Pin: DIG_OUTC
														.dataOutD(				PAD_dataOutD					),	//To Pin: DIG_OUTD
														.dataOutE(				PAD_dataOutE					),	//To Pin: DIG_OUTE
														.dataOutF(				PAD_dataOutF					),	//To Pin: DIG_OUTF
														.dataOutG(				PAD_dataOutG					),	//To Pin: DIG_OUTG
														.dataOutH(				PAD_dataOutH					),	//To Pin: DIG_OUTH
														.Clk_16MHz(				CCORE_Clk_16MHz				),	//To Frontend: CLK_16MHz
														.Clk_2MHz(				PAD_Clk_2MHz					),	//From Pin: CLK_2MHz
														.Clk_64MHz(				PAD_Clk_64MHz					),	//From Pin: CLK_64MHz
														.ADCdata_A(				CCORE_adc_out_0				),	//From FrontEnd: ADCdata_A
														.ADCdata_B(				CCORE_adc_out_1				),	//From FrontEnd: ADCdata_B
														.startNumber(			BEND_startNumber			)		//From slow control register
													);

//***************************
//***
//***	PRBS Module instantiations designed by Sandeep Miryala for digital_mux_out
//***
//***************************

	prbs7TopModule	prbs7		(	.clock(			PAD_Clk_64MHz							),
													 	.reset(			PAD_MASTER_RESET					),
													  .enPattern(	(BEND_dMuxSel == 4'b1110)	),
													  .prbsReg(		prbs7_bitStream						)
													);

	prbs15TopModule	prbs15	(	.clock(			PAD_Clk_64MHz							),
													 	.reset(			PAD_MASTER_RESET					),
													  .enPattern(	(BEND_dMuxSel == 4'b1111)	),
													  .prbsReg(		prbs15_bitStream					)
													);

//***************************
//***
//***	PAD_digital_mux_out
//***
//***************************
	always_comb
	begin
		case (BEND_dMuxSel)
			4'b0000:			PAD_digital_mux_out	=	CCORE_Clk_16MHz;
			4'b0001: 			PAD_digital_mux_out	=	PAD_Clk_64MHz;
			4'b0010: 			PAD_digital_mux_out	=	PAD_Clk_2MHz;
			4'b0011: 			PAD_digital_mux_out	=	CCORE_frontEndSample;
			4'b0100: 			PAD_digital_mux_out	=	I2C_Ack1;
			4'b0101: 			PAD_digital_mux_out	=	I2C_Ack2;
			4'b0110: 			PAD_digital_mux_out	=	I2C_Ack3;
			4'b0111: 			PAD_digital_mux_out	=	I2C_softReset;
			4'b1000: 			PAD_digital_mux_out	=	I2C_writeReq;
			4'b1001: 			PAD_digital_mux_out	=	CCORE_write_external_i2c;
			4'b1010: 			PAD_digital_mux_out	=	CCORE_read_external_i2c;
			4'b1011: 			PAD_digital_mux_out	=	CCORE_external_mode_i2c;
			4'b1100: 			PAD_digital_mux_out	=	^CCORE_adc_out_0;
			4'b1101: 			PAD_digital_mux_out	=	^CCORE_adc_out_1;
			4'b1110: 			PAD_digital_mux_out	=	prbs7_bitStream;
			4'b1111: 			PAD_digital_mux_out	=	prbs15_bitStream;
			//default:			PAD_digital_mux_out	=	CCORE_Clk_16MHz;
		endcase
	end
//***************************
//***
//***	endmodule
//***
//***************************
endmodule
