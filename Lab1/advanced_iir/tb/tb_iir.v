module tb_iir ();

   wire CLK_i;
   wire RST_n_i;
   wire [12:0] DIN_i;
   wire VIN_i;
   wire [12:0] A1_2_i;
   wire [12:0] B0_i;
   wire [12:0] B1_A1B0_i;
   wire [12:0] A1B1_i;
   wire [12:0] DOUT_i;
   wire VOUT_i;
   wire END_SIM_i;

   clk_gen CG(.END_SIM(END_SIM_i),
  	      .CLK(CLK_i),
	      .RST_n(RST_n_i));

   data_maker SM(.CLK(CLK_i),
	         .RST_n(RST_n_i),
		 .VOUT(VIN_i),
		 .DOUT(DIN_i),
		 .A1_2(A1_2_i),
		 .B0(B0_i),
		 .B1_A1B0(B1_A1B0_i),
       .A1B1(A1B1_i),
		 .END_SIM(END_SIM_i));

   myiir UUT(.CLK(CLK_i),
	     .RST_n(RST_n_i),
	     .DIN(DIN_i),
             .VIN(VIN_i),
	     .A1_2(A1_2_i),
		 .B0(B0_i),
		 .B1_A1B0(B1_A1B0_i),
       .A1B1(A1B1_i),
             .DOUT(DOUT_i),
             .VOUT(VOUT_i));

   data_sink DS(.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VIN(VOUT_i),
		.DIN(DOUT_i));   

endmodule

		   
