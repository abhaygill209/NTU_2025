`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2025 16:13:20
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb(

    );
    
    reg start;
    wire [4:0] data_out;
    reg  [31:0] data;
    reg clk, rst, WVALID;
    wire [5:0] len, ptr_data, ptr_read;
    reg [42:0] codebook_data;
    wire WREADY;
    wire codebook_idle;
    wire [31:0] read;
    reg  buf_valid;
    wire buf_ready; 
    wire ready;
    reg [49:0] RAM;
    reg [7:0] ptr_RAM; 
    integer i, j;
    wire [1:0] state;
    
    wire [63:0] buffer;
    
    Decoder inst(rst, clk, start, ready,
                data, buf_valid, buf_ready, len, data_out, ptr_data, ptr_read, read, state, buffer, 
                codebook_data, WVALID, WREADY, codebook_idle);
    
    initial clk = 0;
    always #5 clk = ~clk;
    initial begin 
    rst = 1;
    //filling the code book 
    
    //Codebook 
    /*
        format for codebook 
        Length | source | code
        6-bit  | 5-bit  | 32-bit
    */
    
    #10 codebook_data = {6'd2, 5'd1, 32'b00zz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz}; // symbol 1
        WVALID = 1; // will remain valid while codebook is getting filled
    #10 
    #10 codebook_data = {6'd2, 5'd2, 32'b01zz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz}; // symbol 2
    #10 
    #10 codebook_data = {6'd3, 5'd3, 32'b100z_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz}; // symbol 3
    #10 
    #10 codebook_data = {6'd3, 5'd4, 32'b101z_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz}; // symbol 4
    #10 
    #10 codebook_data = {6'd4, 5'd5, 32'b1100_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz}; // symbol 5
    #10 
    #10 codebook_data = {6'd4, 5'd6, 32'b1101_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz}; // symbol 6
    #10 
    #10 codebook_data = {6'd5, 5'd7, 32'b1110_0zzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz}; // symbol 7
    #10 
    #10 codebook_data = {6'd4, 5'd9, 32'b1111_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz}; // symbol 8
    #10 
    #10 codebook_data = {6'd5, 5'd8, 32'b1110_1zzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz}; // symbol 9
    #20 WVALID = 0;
    
    // this thing fails if we have any wrong data 
    // initialising buffer by puting 64 bit data into it 
    #10 buf_valid = 1; data = 32'b00_01_100_101_1100_1101_11100_11101_1111;
    $display("data = %b; ptr_RAM = %d; length = %d; buffer = %b", data, ptr_RAM, len, buffer);
    #10 data = 32'b00_01_100_101_1100_1101_11100_11101_1111;
    $display("data = %b; ptr_RAM = %d; length = %d; buffer = %b", data, ptr_RAM, len, buffer);

    #30 buf_valid = 0;
    #10
    @(posedge clk);
    RAM = 50'b00_01_100_101_1100_1101_11100_11101_1111_1101_11100_11101_1111;
;   $display("data = %b; ptr_RAM = %d; length = %d; buffer = %b", data, ptr_RAM, len, buffer);
    ptr_RAM = 8'd49;
    start = 1;
    // data transfer and working on it 
    
    while (ptr_RAM < 50) begin
        @(posedge clk)
        i = ptr_RAM;
        j = 0;    // because you're sending len bits
        
        while (j<len) begin 
            data[32'd31 - j] = RAM[i];
            $display("data:%b", data[32'd31 - j] );
             j = j + 1;
             i = i - 1;
        end 

        ptr_RAM = ptr_RAM - len;
        $display("data = %b; ptr_RAM = %d; length = %d; buffer = %b", data, ptr_RAM, len, buffer);
    end
    #165 start = 0;
    #100 $stop;
    end 
    
endmodule
