module DUT(dut_if.port_in in_inter, dut_if.port_out out_inter, output enum logic [1:0] {INITIAL,WAIT,SEND} state);
    
    fpmul fpmul_under_test(.FP_A(in_inter.A),.FP_B(in_inter.B),.clk(in_inter.clk),.FP_Z(out_inter.data));

    always_ff @(posedge in_inter.clk)
    begin
        if(in_inter.rst) begin
            in_inter.ready <= 0;
            out_inter.data <= 'x;
            out_inter.valid <= 0;
            state <= INITIAL;
        end
        else case(state)
                INITIAL: begin
                    in_inter.ready <= 1;
                    state <= WAIT;
                end
                
                WAIT: begin
                    if(in_inter.valid) begin
                        in_inter.ready <= 0;
                        @(posedge in_inter.clk);
                        @(posedge in_inter.clk);
                        @(posedge in_inter.clk);
                                      
                        //out_inter.data <= in_inter.A * in_inter.B;
                        $display("fpmul: input FP_A = %f, input FP_B = %f, output FP_Z = %f",$bitstoshortreal(in_inter.A),$bitstoshortreal(in_inter.B),$bitstoshortreal(out_inter.data));
                        $display("fpmul: input FP_A = %b, input FP_B = %b, output FP_Z = %b",in_inter.A,in_inter.B,out_inter.data);
                        out_inter.valid <= 1;
                        state <= SEND;
                    end
                end
                
                SEND: begin
                    if(out_inter.ready) begin
                        out_inter.valid <= 0;
                        in_inter.ready <= 1;
                        state <= WAIT;
                    end
                end
        endcase
    end
endmodule: DUT
