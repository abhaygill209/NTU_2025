`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2025 00:54:43
// Design Name: 
// Module Name: Decoder
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


module Decoder(
//standard signals 
input      rst,
input      clk,
input      decode,
output reg ready,

// compressed data fetch, read, process
input      [31:0] data,
input      buf_valid,
output reg buf_ready,
output reg [5:0]  len,
output reg [4:0]  data_out,
output reg [6:0]  ptr_data, ptr_read,
output reg [31:0] read,
output reg [1:0] state,
output reg [63:0] buffer, //buffer for entring data

//for codebook 
input      [42:0] codebook_data,
input      WVALID,
output reg WREADY,
output     codebook_idle
);
    
    // **huffman codebook**
    reg [4:0] ptr_codebook;
    reg [31:0] i; // iterator
    /*
       format:-
       Length | source | code
    */     
    reg [31:0] code [31:0];
    reg [5:0]  length [31:0];
    reg [4:0]  source [31:0];
    wire cb_ready;
    
    // de-compression    
    reg [5:0] j,k;

    
    // Initial signals 
    initial begin 
        buffer       = 64'd0;
        ptr_data     = 7'd63;
        ptr_read     = 7'd63;
        ptr_codebook = 5'd0;
        len          = 6'd0;
        data_out     = 5'dz;
        WREADY       = 0;
        read         = 32'd0;
        j            = 7'd0;
        k            = 7'd0;
        state        = 1'b00;
        buf_ready    = 0;
    end 
    
    // ** Codebook Data Entry ** 
    always @(posedge clk or negedge rst)
    begin
        if (!rst)
        begin 
            WREADY       <= 0;
            ptr_codebook <= 0;
            
            //for casez to be valid even when new entries are made into codebook. 
            for (k = 6'd0; k < 6'd32; k = k + 1) begin
                code[k] = 32'dz; 
            end
            
        end 
        else if (WVALID && WREADY)
        begin
            WREADY                <= 0; 
            code[ptr_codebook]    <= codebook_data[31:0];
            source[ptr_codebook]  <= codebook_data[36:32];
            length[ptr_codebook]  <= codebook_data[42:37];
            ptr_codebook          <= ptr_codebook + 1;
        end
        else if (WVALID)
            WREADY <= 1;
    end 
    // if codebook is empty or full
    assign codebook_idle = (ptr_codebook == 5'd0)? 1:0;
    
   // Buffer Handling
    always @(posedge clk or negedge rst)
    begin 
        if (!rst)
        begin
            buffer <= 64'd0;
        end
        else 
        begin 
            // how to fill buffer ?? 
            // test with data as we want to store it in the buffer 
            //fill buffer twice for initialisation 
            if (buf_valid && !buf_ready && ((state == 2'b00) || (state == 2'b01)))
            begin
                buf_ready <= 1;
            end 
            if (buf_ready && buf_valid) begin 
                case (state)
                    2'b00: begin
                        buffer[63:32] <= data;
                        state         <= 2'b01;
                    end
                    2'b01: begin 
                        buffer[31:0]  <= data;
                        state         <= 2'b10;
                        ready         <= 1;
                    end
                endcase 
              buf_ready <= 0;
            end
            if (state == 2'b10 && decode) begin 
                state = 2'b11;
            end 
            
            //fill the remaining lengths that are used
            if (state == 2'b11) begin 
                i = 32'd31; //big endian 
                while(i > 32'd31-len)
                begin 
                    buffer[ptr_data] = data[i];
                    i = i - 1;
                    ptr_data = ptr_data - 1;
                end 
            end 
            ptr_read <= ptr_read - len;
        end 
        
    end
    
    
    // **** CAM and length handling **** 
always @(*)
        begin 
         
            // if processing starts and once buffer is full 
            if (decode && (state==2'b11)) begin
            
            k = 7'd0;
            j = ptr_read;
            while (k < 7'd32) begin
                read[7'd31 - k] =  buffer[j];
                j = j - 1;
                k = k + 1;
            end 
            
            casez (read)
            code[0]: begin 
                data_out = source[0];
                len      = length[0];
            end
            code[1]: begin 
                data_out = source[1];
                len      = length[1];
            end
            code[2]: begin 
                data_out = source[2];
                len      = length[2];
            end
            code[3]: begin 
                data_out = source[3];
                len      = length[3];
            end
            code[4]: begin 
                data_out = source[4];
                len      = length[4];
            end
            code[5]: begin 
                data_out = source[5];
                len      = length[5];
            end
            code[6]: begin 
                data_out = source[6];
                len      = length[6];
            end
            code[7]: begin 
                data_out = source[7];
                len      = length[7];
            end
            code[8]: begin 
                data_out = source[8];
                len      = length[8];
            end
            code[9]: begin 
                data_out = source[9];
                len      = length[9];
            end
            code[10]: begin 
                data_out = source[10];
                len      = length[10];
            end
            code[11]: begin 
                data_out = source[11];
                len      = length[11];
            end
            code[12]: begin 
                data_out = source[12];
                len      = length[12];
            end
            code[13]: begin 
                data_out = source[13];
                len      = length[13];
            end
            code[14]: begin 
                data_out = source[14];
                len      = length[14];
            end
            code[15]: begin 
                data_out = source[15];
                len      = length[15];
            end
            code[16]: begin 
                data_out = source[16];
                len      = length[16];
            end
            code[17]: begin 
                data_out = source[17];
                len      = length[17];
            end
            code[18]: begin 
                data_out = source[18];
                len      = length[18];
            end
            code[19]: begin 
                data_out = source[19];
                len      = length[19];
            end
            code[20]: begin 
                data_out = source[20];
                len      = length[20];
            end
            code[21]: begin 
                data_out = source[21];
                len      = length[21];
            end
            code[22]: begin 
                data_out = source[22];
                len      = length[22];
            end
            code[23]: begin 
                data_out = source[23];
                len      = length[23];
            end        
            code[24]: begin 
                data_out = source[24];
                len      = length[24];
            end        
            code[25]: begin 
                data_out = source[25];
                len      = length[25];
            end
            code[26]: begin 
                data_out = source[26];
                len      = length[26];
             end
             code[27]: begin 
                data_out = source[27];
                len      = length[27];
             end
             code[28]: begin 
                data_out = source[28];
                len      = length[28];
             end
             code[29]: begin 
                data_out = source[29];
                len      = length[29];
             end
             code[30]: begin 
                data_out = source[30];
                len      = length[30];
             end
             code[31]: begin 
                data_out = source[31];
                len      = length[31];
             end  
            default begin 
                data_out = 32'dz;
                len      = 6'd0;
            end 
            endcase
            end 
            
            //if decode signal goes low then we have this thing
            else if (!decode && (state == 2'b11))
            begin
                state = 2'd00;
                len = 6'd0;
                data_out = 5'dz;
                ready = 0;
            end 
            
        end
    
    
    
endmodule
