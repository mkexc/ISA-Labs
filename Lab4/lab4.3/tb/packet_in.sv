class packet_in extends uvm_sequence_item;
    rand bit [31:0] A;
    rand bit [31:0] B;

	constraint specialCases { A[30:23] != 'hFF ; B[30:23] != 'hFF ; A[30:23] != 'h00 ; B[30:23] != 'h00 ; }
	constraint exponentBoundaries { A[30:23] + B[30:23] - 127 > 1 ; A[30:23] + B[30:23] - 127 < 254 ; }
    constraint distProbSignificands { A[22:0] + B[22:0] dist { [1:2**12]:=100, [(2**12)+1:2**17]:=10, [(2**17+1):(2**23)-1]:=100}; }
    constraint distProbExponent { A[30:23] + B[30:23] - 127 dist { [1:15]:=100, [16:239]:=10, [240:254]:=100 }; }

    `uvm_object_utils_begin(packet_in)
        `uvm_field_int(A, UVM_ALL_ON|UVM_HEX)
        `uvm_field_int(B, UVM_ALL_ON|UVM_HEX)
    `uvm_object_utils_end

    function new(string name="packet_in");
        super.new(name);
    endfunction: new
endclass: packet_in
