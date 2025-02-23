`include "PACKAGE.types.coldADC.sv"
`include "PACKAGE.constants.coldADC.sv"
//*******************************************************************************************
//*******************************************************************************************
//***
//*** Description: The entire digital backend for the coldADC chip including
//***		coldADC_backend and coldADC_I2C_ADCslave and the cal_core_wrapper.
//***		It is assumed that PACKAGE.constants.coldADCfr.sv is available to this module.
//*** Author: Jim Hoff
//***
//*******************************************************************************************
//*******************************************************************************************

module	coldADC_digital	(
					//***
					//*** Connections for coldADC_DigitalBlock
					//***
						//*** for I2C_ADC
					output 	logic					PAD_SDA_c2w,			//(I2C_ADC) SDA connection (output) from cold to warm
					input 	logic					PAD_SDA_w2c,			//(I2C_ADC) SDA connection (input) from warm to cold
					input		logic					PAD_SCL,					//(I2C_ADC) SCL connection (serial clock)
					input		logic	[3:0]		PAD_chipID,				//(I2C_ADC) I2C and UART_ADC chip id
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
						//*** Digital Test Output
					output 	logic 				PAD_digital_mux_out,
						//*** reset
					input 	logic					PAD_MASTER_RESET,

						//*** Not actually for Pads...Control Signals for LVDS
					output	logic	[3:0]		PAD_lvdsICTRL,
						//*** Clock for FrontEnd
						//	ALTERED BY CARL
						//		output 	logic					Clk_16MHz,
			    output logic Clk_16MHz_cu0,     // dries cal_unit0 // Madorsky: ADC data clock
          output logic Clk_16MHz_cu1,     // drives cal_unit1
          output logic Clk_16MHz_adc,     // drives ADC
						//*** Sample Signal for FrontEnd
					output 	logic					frontEndSample, // Madorsky: channel 0 and 8 marker
					//***
					//*** Connections for cal_core_wrapper
					//***
			    output 	logic					PAD_miso,             // UART_ADC output from current chip
			    output 	logic	[15:0]	w0_0_0 , //  weight w0 (ADC0)
			    output 	logic	[15:0]	w0_1_0 , //  weight w0 (ADC0)
			    output 	logic	[15:0]	w0_2_0 , //  weight w0 (ADC0)
			    output 	logic	[15:0]	w0_3_0 , //  weight w0 (ADC0)
			    output 	logic	[15:0]	w0_4_0 , //  weight w0 (ADC0)
			    output 	logic	[15:0]	w0_5_0 , //  weight w0 (ADC0)
			    output 	logic	[15:0]	w0_6_0 , //  weight w0 (ADC0)
			    output 	logic	[15:0]	w0_7_0 , //  weight w0 (ADC0)
			    output 	logic	[15:0]	w0_8_0 , //  weight w0 (ADC0)
			    output 	logic	[15:0]	w0_9_0 , //  weight w0 (ADC0)
			    output 	logic	[15:0]	w0_10_0 , //  weight w0 (ADC0)
			    output 	logic	[15:0]	w0_11_0 , //  weight w0 (ADC0)
			    output 	logic	[15:0]	w0_12_0 , //  weight w0 (ADC0)
			    output 	logic	[15:0]	w0_13_0 , //  weight w0 (ADC0)
			    output 	logic	[15:0]	w0_14_0 , //  weight w0 (ADC0)
			    output 	logic	[15:0]	w2_0_0,
			    output 	logic	[15:0]	w2_1_0,
			    output 	logic	[15:0]	w2_2_0,
			    output 	logic	[15:0]	w2_3_0,
			    output 	logic	[15:0]	w2_4_0,
			    output 	logic	[15:0]	w2_5_0,
			    output 	logic	[15:0]	w2_6_0,
			    output 	logic	[15:0]	w2_7_0,
			    output 	logic	[15:0]	w2_8_0,
			    output 	logic	[15:0]	w2_9_0,
			    output 	logic	[15:0]	w2_10_0,
			    output 	logic	[15:0]	w2_11_0,
			    output 	logic	[15:0]	w2_12_0,
			    output 	logic	[15:0]	w2_13_0,
			    output 	logic	[15:0]	w2_14_0,
			    output 	logic	[15:0]	w0_0_1,
			    output 	logic	[15:0]	w0_1_1,
			    output 	logic	[15:0]	w0_2_1,
			    output 	logic	[15:0]	w0_3_1,
			    output 	logic	[15:0]	w0_4_1,
			    output 	logic	[15:0]	w0_5_1,
			    output 	logic	[15:0]	w0_6_1,
			    output 	logic	[15:0]	w0_7_1,
			    output 	logic	[15:0]	w0_8_1,
			    output 	logic	[15:0]	w0_9_1,
			    output 	logic	[15:0]	w0_10_1,
			    output 	logic	[15:0]	w0_11_1,
			    output 	logic	[15:0]	w0_12_1,
			    output 	logic	[15:0]	w0_13_1,
			    output 	logic	[15:0]	w0_14_1,
			    output 	logic	[15:0]	w2_0_1,
			    output 	logic	[15:0]	w2_1_1,
			    output 	logic	[15:0]	w2_2_1,
			    output 	logic	[15:0]	w2_3_1,
			    output 	logic	[15:0]	w2_4_1,
			    output 	logic	[15:0]	w2_5_1,
			    output 	logic	[15:0]	w2_6_1,
			    output 	logic	[15:0]	w2_7_1,
			    output 	logic	[15:0]	w2_8_1,
			    output 	logic	[15:0]	w2_9_1,
			    output 	logic	[15:0]	w2_10_1,
			    output 	logic	[15:0]	w2_11_1,
			    output 	logic	[15:0]	w2_12_1,
			    output 	logic	[15:0]	w2_13_1,
			    output 	logic	[15:0]	w2_14_1,

			// outputs to control ADC
			//	output 	logic					extern_force_refp [1:0], // forces postive reference
					output 	logic					extern_force_refp_0, // forces postive reference
					output 	logic					extern_force_refp_1, // forces postive reference
			//	output 	logic					extern_force_refn [1:0], // forces negative reference
					output 	logic					extern_force_refn_0, // forces negative reference
					output 	logic					extern_force_refn_1, // forces negative reference
			//	output 	logic					extern_force_cm [1:0], // forces common-mode reference
					output 	logic					extern_force_cm_0, // forces common-mode reference
					output 	logic					extern_force_cm_1, // forces common-mode reference
			//	output 	logic					extern_force_msb [1:0], // data force MSB bit
					output 	logic					extern_force_msb_0, // data force MSB bit
					output 	logic					extern_force_msb_1, // data force MSB bit
			//	output 	logic					extern_force_lsb [1:0], // data force MSB bit
					output 	logic					extern_force_lsb_0, // data force MSB bit
					output 	logic					extern_force_lsb_1, // data force MSB bit
			                                // data force is 00, 01, or 10
			//	output 	logic					extern_caldac_ctrl [1:0], // controls calibration dac.
					output 	logic					extern_caldac_ctrl_0, // controls calibration dac.
					output 	logic					extern_caldac_ctrl_1, // controls calibration dac.
			                                // 0: dac=-vrefd/4; 1: dac=vrefd/4
			    output 	logic	[0:6]		extern_calibrate_stage0, // high to put
			                                        // ADC0 analog stage in cal mode
			    output 	logic	[0:6]		extern_calibrate_stage1, // high to put
			                                        // ADC1 analog stage in cal mode

			//	output 	logic					adc_pd [1:0],          // high to power down ADC0/1
					output 	logic					adc_pd_0,          // high to power down ADC0/1
					output 	logic					adc_pd_1,          // high to power down ADC0/1
			    output 	logic					adc_disable_gb,        // high to disable gain boosters
			    output 	logic					adc_sync_mode,         // =1 for ADC to put out sync pattern
			    output 	logic					adc_test_mode,         // =1 for ADC to convert test input
			    output 	logic	[2:0]		adc_bias,        // ADC bias current adjust
			    output 	logic	[1:0]		nonov_ctrl,     // adjust phi1/phi2 nonoverlap time
			//   output 	logic					edge_select,      // 0 = nominal, 1 = 180 degree phase shift
			//	 output 	logic					samp_ctrl,         // adjust phi1p/phi1 delay time
					output 	logic					edge_select_cu0,      // 0 = nominal, 1 = 180 degree phase shift
			    output 	logic					edge_select_cu1,      // 0 = nominal, 1 = 180 degree phase shift
			//	output 	logic					adc_output_format,  // 0 = two's complement, 1 = offset binary
					output 	logic					adc_output_format_cu0,  // 0 = two's complement, 1 = offset binary
			    output 	logic					adc_output_format_cu1,  // 0 = two's complement, 1 = offset binary
			    output 	logic					enable_radix_converter, // 0 = disable, 1 = enable (derived
			                                        // from ADC output format)
			// outputs to control buffer and SHA
			    output 	logic					ibuff_sdc_pd,          // power down s2d
			    output 	logic					ibuff_db_pd,           // power down diff buffer
			    output 	logic	[3:0]		ibuff_ctrl,      // input buffer control word
			    output 	logic	[7:0]		sha_pd_0,        // power down for SHAs for ADC0
			    output 	logic	[7:0]		sha_pd_1,        // power down for SHAs for ADC1
			    output 	logic					sha_se_input,          // 0 =  accepting differential signal
			                                        // 1 = need to convert to diff from se
			    output 	logic	[2:0]		sha0_bias,       // ADC SHA0 current adjust
			    output 	logic	[2:0]		sha1_bias,       // ADC SHA1 current adjust
			    output 	logic	[2:0]		sha2_bias,       // ADC SHA2 current adjust
			    output 	logic	[2:0]		sha3_bias,       // ADC SHA3 current adjust
			    output 	logic	[2:0]		sha4_bias,       // ADC SHA4 current adjust
			    output 	logic	[2:0]		sha5_bias,       // ADC SHA5 current adjust
			    output 	logic	[2:0]		sha6_bias,       // ADC SHA6 current adjust
			    output 	logic	[2:0]		sha7_bias,       // ADC SHA7 current adjust
			    output 	logic	[2:0]		freeze_select_0, // which SHA to connect (when frozen)
			    output 	logic	[2:0]		freeze_select_1, // which SHA to connect (when frozen)
			//	output 	logic					freeze_sha [1:0],      // high to freeze which SHA connected
					output 	logic					freeze_sha_0,      // high to freeze which SHA connected
					output 	logic					freeze_sha_1,      // high to freeze which SHA connected
			// ALTERED BY CARL
			//	output 	logic					clk_sha_select,  // 0 = use backend sha_clk, 1 = use
					output 	logic					clk_sha_select_cu0,  // 0 = use backend sha_clk, 1 = use
					output 	logic					clk_sha_select_cu1,  // 0 = use backend sha_clk, 1 = use
					output 	logic					clk_sha_select_analog,  // 0 = use backend sha_clk, 1 = use
					output 	logic	[1:0]		sha_select_ctrl,  // 0 = use backend sha_clk, 1 = use
			                                    // internal sha_clk
			// outputs to control reference gen block
			    output 	logic	[7:0]		vrefp_ctrl,     // controls VREFP DAC
			    output 	logic	[7:0]		vrefn_ctrl,      // controls VREFN DAC
			    output 	logic	[7:0]		vcmo_ctrl,       // controls VCMO DAC
			    output 	logic	[7:0]		vcmi_ctrl,       // controls VCMI DAC
			    output 	logic	[1:0]		vrefp_offset,    // controls VREFP offset adjust
			    output 	logic	[1:0]		vrefn_offset,    // controls VREFN offset adjust
			    output 	logic	[1:0]		vcmo_offset,     // controls VCMO offset adjust
			    output 	logic	[1:0]		vcmi_offset,     // controls VCMI offset adjust
			    output 	logic	[7:0]		i_vdac_0_ctrl,   // controls VDAC current DAC
			    output 	logic	[7:0]		i_vdac_1_ctrl,   // controls VDAC current DAC
			    output 	logic	[7:0]		ibuff0_bjt_ctrl, // controls se buffer current DAC
			    output 	logic	[7:0]		ibuff1_bjt_ctrl, // controls se buffer current DAC
			    output 	logic					external_reference,    // high for external ADC ref voltages
			    output 	logic					external_bgr,          // high for external bandgap
			    output 	logic					bgr_select,            // 0-> BJT, 1-> CMOS
			    output 	logic	[15:0]	ref_monitor,     // pre-decoded cntl for local monitor
			    output 	logic	[11:0]	ref_powerdown,  // powerdown word for BNL reference
			    output 	logic	[2:0]		ref_bias,        // ref buffer bias current adjust
			// outputs to control LBNL reference gen block
			    output 	logic	[7:0]		vrefp_ctrl_cmos, // controls CMOS VREFP DAC
			    output 	logic	[7:0]		vrefn_ctrl_cmos, // controls CMOS VREFN DAC
			    output 	logic	[7:0]		vcmo_ctrl_cmos,  // controls CMOS VCMO DAC
			    output 	logic	[7:0]		vcmi_ctrl_cmos,  // controls CMOS VCMI DAC
			    output 	logic	[1:0]		iref_sel,        // selects where chip bias currents
			                                        // come from
			                                        // 00 -> BGR, 01 -> CMOS ref (int R)
			                                        // 10 -> CMOS ref (ext R) 11 -> plan B
			    output 	logic	[2:0]		vt_iref_trim_ctrl, // trim vt-reference currents
			                                          // 5 uA LSB
			    output 	logic					vt_kickstart,    // high to kickstart CMOS reference
			    output 	logic	[5:0]		ibuff0_cmos, // controls diff buffer current DAC
			    output 	logic	[5:0]		ibuff1_cmos, // controls diff buffer current DAC

			// outputs for cal_engine
			//  output 	logic					calibrate [1:0],       // active high calibration command
					output 	logic					calibrate_0,       // active high calibration command
					output 	logic					calibrate_1,       // active high calibration command
			//	ALTERED BY CARL
			//    output 	logic	[3:0]		meas_cycles,     // # of measurements
			                                        // for each weight (averaging)
			                                        // cycles = 2^meas_cycles
					output 	logic	[3:0]		meas_cycles_cu0,     // # of measurements
			    output 	logic	[3:0]		meas_cycles_cu1,     // # of measurements

			//	ALTERED BY CARL
			 //   output 	logic	[2:0]		cal_stages,  // # of bits to calibrate (up to seven)
					output 	logic	[2:0]		cal_stages_cu0,  // # of bits to calibrate (up to seven)
			    output 	logic	[2:0]		cal_stages_cu1,  // # of bits to calibrate (up to seven)
			// output for correction logic test
			//	ALTERED BY CARL
	    //	output 	logic					test_correction_logic,
					output 	logic					test_correction_logic_cu0,
			    output 	logic					test_correction_logic_cu1,

			    output 	logic	[0:14]	test_lsb0,  // ADC0 test word LSB
			    output 	logic	[0:14]	test_msb0,  // ADC0 test word MSB
			    output 	logic	[0:14]	test_lsb1,  // ADC1 test word LSB
			    output 	logic	[0:14]	test_msb1,  // ADC1 test word MSB

			// outputs to control voltage and current monitors
			    output 	logic					vmonitor_enable,       // 0-> disable, 1-> enable
			    output 	logic					imonitor_enable,       // 0-> disable, 1-> enable
			    output 	logic	[2:0]		vmonitor_select, // 000 --> VBGR, 001 --> VCMI,
			                                        // 010 --> VCMO, 011 --> VREFP,
			                                        // 100 --> VREFN
			    output 	logic	[2:0]		imonitor_select, // 000 --> IMASTER, 001 --> IBUFF,
			                                        // 010 --> IADC0, 011 --> IADC1,
			                                        // 100 --> ICOMP0, 101 --> ICOMP1
			// SSO outputs
					output 	logic					PAD_sso_data_out_0,    // output bits (ADC0)
			    output 	logic					PAD_sso_data_out_1,    // output bits (ADC1)
					output 	logic					PAD_sso_frame_clk,     // frame clock (div16)
					output  logic 				PAD_sso_out_clk, 			//gated 16MHz Clock

			// external inputs from UART_ADC (external to cal core)
			    input logic 					PAD_mosi,                   // input to UART_ADC on current chip
			// inputs from ADCs
			    input logic 	[15:0] 	synced_adc_cal_0,  // synced adc word w calibration // Madorsky: drop data here at 16 MHz clock rising
			    input logic 	[15:0] 	synced_adc_cal_1,  // synced adc word w calibration
			    input logic 	[15:0] 	synced_adc_nocal_0,// synced adc word w/o calib
			    input logic 	[15:0] 	synced_adc_nocal_1,// synced adc word w/o calib
			    input logic 	[0:14] 	synced_msb_0,      // MSBs from each ADC
			    input logic 	[0:14] 	synced_msb_1,      // MSBs from each ADC
			    input logic 	[0:14] 	synced_lsb_0,      // LSBs from each ADC
			    input logic 	[0:14] 	synced_lsb_1,      // LSBs from each ADC
			// control r/w from cal engine
			    input logic 	[15:0] 	write_data_0, // data (w0/w2) to write to CL regfile
			    input logic 	[15:0] 	write_data_1, // data (w0/w2) to write to CL regfile

			    input logic 	[2:0] 	current_stage_0, // current stage
			    input logic 	[2:0] 	current_stage_1, // current stage
			//	input logic 					clear_regs_internal [1:0], // initialize cal registers
					input logic 					clear_regs_internal_0, // initialize cal registers
					input logic 					clear_regs_internal_1, // initialize cal registers
			//	input logic 					weight_sel [1:0],         // 0 = sel w0; 1 = sel w2
					input logic 					weight_sel_0,         // 0 = sel w0; 1 = sel w2
					input logic 					weight_sel_1,         // 0 = sel w0; 1 = sel w2
			//	input logic 					g_sel [1:0],             // 1 = write gain measurement
					input logic 					g_sel_0,             // 1 = write gain measurement
					input logic 					g_sel_1,             // 1 = write gain measurement
			//	input logic 					o_sel [1:0],             // 1 = write offset measurement
					input logic 					o_sel_0,             // 1 = write offset measurement
					input logic 					o_sel_1,             // 1 = write offset measurement
			//	input logic 					write [1:0],             // set = 1 to write word to cl_regfile
					input logic 					write_0,             // set = 1 to write word to cl_regfile
					input logic 					write_1,             // set = 1 to write word to cl_regfile
			//	input logic 					busy [1:0]               // 1 if calibration active
					input logic 					busy_0,               // 1 if calibration active
					input logic 					busy_1               // 1 if calibration active

				);

//***************************
//***
//***	Wires for module interconnect
//***
//***************************

logic  				CCORE_external_mode_i2c;
logic	[7:0]		CCORE_write_data_external_i2c;
logic	[7:0]		CCORE_write_addr_external_i2c;
logic  				CCORE_write_external_i2c;
logic	[7:0]		CCORE_read_addr_external_i2c;
logic	[7:0]		CCORE_read_data_external_i2c;
logic  				CCORE_read_external_i2c;
logic	[15:0]	CCORE_adc_out_0;
logic	[15:0]	CCORE_adc_out_1;
logic [3:0]		CCORE_CONFIG_lvds_i_ctrl;
logic [4:0]		CCORE_CONFIG_start_number;
logic [3:0]		CCORE_CONFIG_dMuxSel;
logic  				CCORE_testBit1;
logic  				CCORE_testBit2;
logic 				CCORE_sso_enable;

logic					almost_sso_data_out	[1:0];
//***************************
//***
//***	Getting rid of those pesky unpacked arrays
//***
//***************************
logic					extern_force_refp	[1:0];
logic					extern_force_refn	[1:0];
logic					extern_force_cm	[1:0];
logic					extern_force_msb	[1:0];
logic					extern_force_lsb	[1:0];
logic					extern_caldac_ctrl	[1:0];
logic 				adc_pd [1:0];
logic 				freeze_sha [1:0];
logic	 				calibrate [1:0];
logic 				clear_regs_internal [1:0];
logic 				weight_sel [1:0];
logic 				g_sel [1:0];
logic 				o_sel [1:0];
logic 				write [1:0];
logic 				busy [1:0];

//	ALTERED BY CARL
//***************************
//***
//***	wires for observability (post P&R)
//***
//***************************
logic [1:0] adc_output_select; // selects cal or uncal ADC data
logic config_test_data_mode; // =1 to send test data out
logic [15:0] config_adc0_pattern;  // fake ADC0 data
logic [15:0] config_adc1_pattern;  // fake ADC1 data

//***************************
//***
//***	wires for fanning out signals to cal_units
//***
//***************************
logic [2:0] cal_stages;
logic Clk_16MHz;
logic clk_sha_select;
logic edge_select;
logic [3:0] meas_cycles;
logic adc_output_format;
logic test_correction_logic;
//	END ALTERATION BY CARL

always_comb
	begin
		extern_force_refp_0					=	extern_force_refp[0];
		extern_force_refp_1					=	extern_force_refp[1];
		extern_force_refn_0					=	extern_force_refn[0];
		extern_force_refn_1					=	extern_force_refn[1];
		extern_force_cm_0						=	extern_force_cm[0];
		extern_force_cm_1						=	extern_force_cm[1];
		extern_force_lsb_0					=	extern_force_lsb[0];
		extern_force_lsb_1					=	extern_force_lsb[1];
		extern_force_msb_0					=	extern_force_msb[0];
		extern_force_msb_1					=	extern_force_msb[1];
		extern_caldac_ctrl_0				=	extern_caldac_ctrl[0];
		extern_caldac_ctrl_1				=	extern_caldac_ctrl[1];
		adc_pd_0										=	adc_pd[0];
		adc_pd_1										=	adc_pd[1];
		freeze_sha_0								=	freeze_sha[0];
		freeze_sha_1								=	freeze_sha[1];
		calibrate_0									=	calibrate[0];
		calibrate_1									=	calibrate[1];
		clear_regs_internal[0]			=	clear_regs_internal_0;
		clear_regs_internal[1]			=	clear_regs_internal_1;
		weight_sel[0]								=	weight_sel_0;
		weight_sel[1]								=	weight_sel_1;
		g_sel[0]										=	g_sel_0;
		g_sel[1]										=	g_sel_1;
		o_sel[0]										=	o_sel_0;
		o_sel[1]										=	o_sel_1;
		write[0]										=	write_0;
		write[1]										=	write_1;
		busy[0]											=	busy_0;
		busy[1]											=	busy_1;
		//	ALTERED BY CARL
		cal_stages_cu0                  = cal_stages;
		cal_stages_cu1                  = cal_stages;
		Clk_16MHz_cu0                   = Clk_16MHz;
		Clk_16MHz_cu1                   = Clk_16MHz;
		Clk_16MHz_adc                   = Clk_16MHz;
		clk_sha_select_cu0              = clk_sha_select;
		clk_sha_select_cu1              = clk_sha_select;
		clk_sha_select_analog           = clk_sha_select;
		edge_select_cu0                 = edge_select;
		edge_select_cu1                 = edge_select;
		meas_cycles_cu0                 = meas_cycles;
		meas_cycles_cu1                 = meas_cycles;
		adc_output_format_cu0           = adc_output_format;
		adc_output_format_cu1           = adc_output_format;
		test_correction_logic_cu0       = test_correction_logic;
		test_correction_logic_cu1       = test_correction_logic;
		//	END ALTERATION BY CARL
	end
//***************************
//***
//***	Simple logic to create PAD_sso_out_clk
//***
//***************************
always_comb
	begin
		PAD_sso_out_clk	=	Clk_16MHz && CCORE_sso_enable;
	end
//***************************
//***
//***	Module Instantiation: coldADC_DigitalBlock
//***
//***************************

coldADC_DigitalBlock	coldADC_DigitalBlock_0	(
		.PAD_SDA_c2w(										PAD_SDA_c2w										),
		.PAD_SDA_w2c(										PAD_SDA_w2c										),
		.PAD_SCL(												PAD_SCL												),
		.PAD_chipID(										PAD_chipID										),
		.PAD_I2C_UART_SEL(							PAD_I2C_UART_SEL							),
		.PAD_Clk_2MHz(									PAD_Clk_2MHz									),
		.PAD_Clk_64MHz(									PAD_Clk_64MHz									),
		.PAD_frameStart(								PAD_frameStart								),
		.PAD_dataOutClk(								PAD_dataOutClk								),
		.PAD_dataOutA(									PAD_dataOutA									),
		.PAD_dataOutB(									PAD_dataOutB									),
		.PAD_dataOutC(									PAD_dataOutC									),
		.PAD_dataOutD(									PAD_dataOutD									),
		.PAD_dataOutE(									PAD_dataOutE									),
		.PAD_dataOutF(									PAD_dataOutF									),
		.PAD_dataOutG(									PAD_dataOutG									),
		.PAD_dataOutH(									PAD_dataOutH									),
		.PAD_MASTER_RESET(							PAD_MASTER_RESET							),
		.PAD_lvdsICTRL(									PAD_lvdsICTRL									),
		.CCORE_external_mode_i2c(				CCORE_external_mode_i2c				),
		.CCORE_write_data_external_i2c(	CCORE_write_data_external_i2c	),
		.CCORE_write_addr_external_i2c(	CCORE_write_addr_external_i2c	),
		.CCORE_write_external_i2c(			CCORE_write_external_i2c			),
		.CCORE_read_addr_external_i2c(	CCORE_read_addr_external_i2c	),
		.CCORE_read_data_external_i2c(	CCORE_read_data_external_i2c	),
		.CCORE_read_external_i2c(				CCORE_read_external_i2c				),
		.CCORE_adc_out_0(								CCORE_adc_out_0								),
		.CCORE_adc_out_1(								CCORE_adc_out_1								),
		.CCORE_Clk_16MHz(								Clk_16MHz											),
		.CCORE_frontEndSample(					frontEndSample								),
		.CCORE_CONFIG_lvds_i_ctrl(			CCORE_CONFIG_lvds_i_ctrl			),
		.CCORE_CONFIG_start_number(			CCORE_CONFIG_start_number			),
		.CCORE_CONFIG_dMuxSel(					CCORE_CONFIG_dMuxSel					),
		.PAD_digital_mux_out(						PAD_digital_mux_out						)
	);

//***************************
//***
//***	Module Instantiation: cal_core
//***
//***************************
	always_comb
		begin
			PAD_sso_data_out_1	=		almost_sso_data_out[1];
			PAD_sso_data_out_0	=		almost_sso_data_out[0];
		end

	cal_core	cal_core_1    (
		.adc_out_0(										CCORE_adc_out_0								),
		.adc_out_1(										CCORE_adc_out_1								),
		.read_data(										CCORE_read_data_external_i2c	),
		.miso(												PAD_miso											),
		.w0_0_0(											w0_0_0												),
		.w0_1_0(											w0_1_0												),
		.w0_2_0(											w0_2_0												),
		.w0_3_0(											w0_3_0												),
		.w0_4_0(											w0_4_0												),
		.w0_5_0(											w0_5_0												),
		.w0_6_0(											w0_6_0												),
		.w0_7_0(											w0_7_0												),
		.w0_8_0(											w0_8_0												),
		.w0_9_0(											w0_9_0												),
		.w0_10_0(											w0_10_0												),
		.w0_11_0(											w0_11_0												),
		.w0_12_0(											w0_12_0												),
		.w0_13_0(											w0_13_0												),
		.w0_14_0(											w0_14_0												),
		.w2_0_0(											w2_0_0												),
		.w2_1_0(											w2_1_0												),
		.w2_2_0(											w2_2_0												),
		.w2_3_0(											w2_3_0												),
		.w2_4_0(											w2_4_0												),
		.w2_5_0(											w2_5_0												),
		.w2_6_0(											w2_6_0												),
		.w2_7_0(											w2_7_0												),
		.w2_8_0(											w2_8_0												),
		.w2_9_0(											w2_9_0												),
		.w2_10_0(											w2_10_0												),
		.w2_11_0(											w2_11_0												),
		.w2_12_0(											w2_12_0												),
		.w2_13_0(											w2_13_0												),
		.w2_14_0(											w2_14_0												),
		.w0_0_1(											w0_0_1												),
		.w0_1_1(											w0_1_1												),
		.w0_2_1(											w0_2_1												),
		.w0_3_1(											w0_3_1												),
		.w0_4_1(											w0_4_1												),
		.w0_5_1(											w0_5_1												),
		.w0_6_1(											w0_6_1												),
		.w0_7_1(											w0_7_1												),
		.w0_8_1(											w0_8_1												),
		.w0_9_1(											w0_9_1												),
		.w0_10_1(											w0_10_1												),
		.w0_11_1(											w0_11_1												),
		.w0_12_1(											w0_12_1												),
		.w0_13_1(											w0_13_1												),
		.w0_14_1(											w0_14_1												),
		.w2_0_1(											w2_0_1												),
		.w2_1_1(											w2_1_1												),
		.w2_2_1(											w2_2_1												),
		.w2_3_1(											w2_3_1												),
		.w2_4_1(											w2_4_1												),
		.w2_5_1(											w2_5_1												),
		.w2_6_1(											w2_6_1												),
		.w2_7_1(											w2_7_1												),
		.w2_8_1(											w2_8_1												),
		.w2_9_1(											w2_9_1												),
		.w2_10_1(											w2_10_1												),
		.w2_11_1(											w2_11_1												),
		.w2_12_1(											w2_12_1												),
		.w2_13_1(											w2_13_1												),
		.w2_14_1(											w2_14_1												),
		.extern_force_refp(						extern_force_refp							),
		.extern_force_refn(						extern_force_refn							),
		.extern_force_cm(							extern_force_cm								),
		.extern_force_msb(						extern_force_msb							),
		.extern_force_lsb(						extern_force_lsb							),
		.extern_caldac_ctrl(					extern_caldac_ctrl						),
		.extern_calibrate_stage_0(		extern_calibrate_stage0				),
		.extern_calibrate_stage_1(		extern_calibrate_stage1				),
		.adc_pd(											adc_pd												),
		.adc_disable_gb(							adc_disable_gb								),
		.adc_sync_mode(								adc_sync_mode									),
		.adc_test_mode(								adc_test_mode									),
		.adc_bias(										adc_bias											),
		.nonov_ctrl(									nonov_ctrl										),
		.edge_select(									edge_select										),
		.adc_output_format(						adc_output_format							),
		.enable_radix_converter(			enable_radix_converter				),
		.ibuff_sdc_pd(								ibuff_sdc_pd									),
		.ibuff_db_pd(									ibuff_db_pd										),
		.ibuff_ctrl(									ibuff_ctrl										),
		.sha_pd_0(										sha_pd_0											),
		.sha_pd_1(										sha_pd_1											),
		.sha_se_input(								sha_se_input									),
		.sha0_bias(										sha0_bias											),
		.sha1_bias(										sha1_bias											),
		.sha2_bias(										sha2_bias											),
		.sha3_bias(										sha3_bias											),
		.sha4_bias(										sha4_bias											),
		.sha5_bias(										sha5_bias											),
		.sha6_bias(										sha6_bias											),
		.sha7_bias(										sha7_bias											),
		.freeze_select_0(							freeze_select_0								),
		.freeze_select_1(							freeze_select_1								),
		.freeze_sha(									freeze_sha										),
		.clk_sha_select(							clk_sha_select								),
		.sha_select_ctrl(							sha_select_ctrl								),
		.vrefp_ctrl(									vrefp_ctrl										),
		.vrefn_ctrl(									vrefn_ctrl										),
		.vcmo_ctrl(										vcmo_ctrl											),
		.vcmi_ctrl(										vcmi_ctrl											),
		.vrefp_offset(								vrefp_offset									),
		.vrefn_offset(								vrefn_offset									),
		.vcmo_offset(									vcmo_offset										),
		.vcmi_offset(									vcmi_offset										),
		.i_vdac_0_ctrl(								i_vdac_0_ctrl									),
		.i_vdac_1_ctrl(								i_vdac_1_ctrl									),
		.ibuff0_bjt_ctrl(							ibuff0_bjt_ctrl								),
		.ibuff1_bjt_ctrl(							ibuff1_bjt_ctrl								),
		.external_reference(					external_reference						),
		.external_bgr(								external_bgr									),
		.bgr_select(									bgr_select										),
		.ref_monitor(									ref_monitor										),
		.ref_powerdown(								ref_powerdown									),
		.ref_bias(										ref_bias											),
		.vrefp_ctrl_cmos(							vrefp_ctrl_cmos								),
		.vrefn_ctrl_cmos(							vrefn_ctrl_cmos								),
		.vcmo_ctrl_cmos(							vcmo_ctrl_cmos								),
		.vcmi_ctrl_cmos(							vcmi_ctrl_cmos								),
		.iref_sel(										iref_sel											),
		.vt_iref_trim_ctrl(						vt_iref_trim_ctrl							),
		.vt_kickstart(								vt_kickstart									),
		.ibuff0_cmos(									ibuff0_cmos										),
		.ibuff1_cmos(									ibuff1_cmos										),
		.calibrate(										calibrate											),
		.meas_cycles(									meas_cycles										),
		.cal_stages(									cal_stages										),
		.test_correction_logic(				test_correction_logic					),
		.test_lsb0(										test_lsb0											),
		.test_msb0(										test_msb0											),
		.test_lsb1(										test_lsb1											),
		.test_msb1(										test_msb1											),
		.vmonitor_enable(							vmonitor_enable								),
		.imonitor_enable(							imonitor_enable								),
		.vmonitor_select(							vmonitor_select								),
		.imonitor_select(							imonitor_select								),
		.sso_data_out(								almost_sso_data_out						),
		.sso_frame_clk(								PAD_sso_frame_clk							),
		.sso_enable(									CCORE_sso_enable							),
		.config_lvds_i_ctrl(					CCORE_CONFIG_lvds_i_ctrl			),
		.config_start_number(					CCORE_CONFIG_start_number			),
		.config_debug_enable(					CCORE_CONFIG_debug_enable			),
		.config_debug_select(					CCORE_CONFIG_dMuxSel					),
		.adc_output_select(           adc_output_select							),
		.config_test_data_mode(       config_test_data_mode					),
		.config_adc0_pattern(         config_adc0_pattern						),
		.config_adc1_pattern(         config_adc1_pattern						),
		.mosi(												PAD_mosi											),
		.chip_id(											PAD_chipID										),
		.write_addr_external_i2c(			CCORE_write_addr_external_i2c	),
		.write_data_external_i2c(			CCORE_write_data_external_i2c	),
		.read_addr_external_i2c(			CCORE_read_addr_external_i2c	),
		.external_mode_i2c(						CCORE_external_mode_i2c				),
		.write_external_i2c(					CCORE_write_external_i2c			),
		.read_external_i2c(						CCORE_read_external_i2c				),
		.synced_adc_cal_0(						synced_adc_cal_0							),
		.synced_adc_cal_1(						synced_adc_cal_1							),
		.synced_adc_nocal_0(					synced_adc_nocal_0						),
		.synced_adc_nocal_1(					synced_adc_nocal_1						),
		.synced_msb_0(								synced_msb_0									),
		.synced_msb_1(								synced_msb_1									),
		.synced_lsb_0(								synced_lsb_0									),
		.synced_lsb_1(								synced_lsb_1									),
		.write_data_0(								write_data_0									),
		.write_data_1(								write_data_1									),
		.current_stage_0(							current_stage_0								),
		.current_stage_1(							current_stage_1								),
		.clear_regs_internal(					clear_regs_internal						),
		.weight_sel(									weight_sel										),
		.g_sel(												g_sel													),
		.o_sel(												o_sel													),
		.write(												write													),
		.busy(												busy													),
		.clk(													Clk_16MHz											),
		.reset_n(											PAD_MASTER_RESET							)
	);

//***************************
//***
//***	endmodule
//***
//***************************

endmodule
