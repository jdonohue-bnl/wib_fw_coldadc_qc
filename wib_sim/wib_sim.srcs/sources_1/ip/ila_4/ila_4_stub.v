// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1.1_AR73018 (win64) Build 2960000 Wed Aug  5 22:57:20 MDT 2020
// Date        : Sat Oct 17 04:25:15 2020
// Host        : uf-eng-srv-1 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/madorsky/github/wib_sim/wib_sim/wib_sim.srcs/sources_1/ip/ila_4/ila_4_stub.v
// Design      : ila_4
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2020.1.1_AR73018" *)
module ila_4(clk, probe0, probe1, probe2, probe3)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[3:0],probe1[6:0],probe2[2:0],probe3[0:0]" */;
  input clk;
  input [3:0]probe0;
  input [6:0]probe1;
  input [2:0]probe2;
  input [0:0]probe3;
endmodule
