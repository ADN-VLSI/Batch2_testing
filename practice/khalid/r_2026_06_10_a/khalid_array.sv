module khalid_array (

//PACKED ARRAY:
    input  logic [3:0][7:0] data_in,
    output logic [3:0][7:0] data_out

//UNPACKED ARRAY:
    input  logic [7:0] data_in [3:0],
    output logic [7:0] data_out [3:0]    
);
    
endmodule