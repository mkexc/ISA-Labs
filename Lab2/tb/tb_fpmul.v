module tb_fpmul ();

   wire CLK_i;
   wire RST_n_i;
   wire [31:0] DATA_i;
   wire [31:0] DOUT_i;

   clk_gen CG(.CLK(CLK_i),
                .RST_n(RST_n_i));

   data_maker SM(.CLK(CLK_i),
                .RST_n(RST_n_i),
		 .DATA(DATA_i));

   FPmul UUT(.clk(CLK_i),
	     .FP_A(DATA_i),
           .FP_B(DATA_i),
           .FP_Z(DOUT_i));

   data_sink DS(.CLK(CLK_i),
                .RST_n(RST_n_i),
		.DIN(DOUT_i));   

endmodule

		   
