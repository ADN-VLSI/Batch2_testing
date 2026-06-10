module khalid_array (

//PACKED ARRAY:
    input  logic [3:0][7:0] data_in,
    output logic [3:0][7:0] data_out,

//UNPACKED ARRAY:
    input  logic [7:0] data_in2 [3:0],
    output logic [7:0] data_out2 [3:0]  
    
//
    // Note: The order of unpacked ports in the module declaration must match the order of connections in the testbench instantiation!
);  

    // For the sake of this example, let's just pass the inputs directly to the outputs
    assign data_out = data_in; 
    assign data_out2 = data_in2; 
 
endmodule