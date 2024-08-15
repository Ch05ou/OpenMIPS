module pipe_ins_decode(
    input clk,reset,
    input [2:0]alu_sel,
    input [7:0]alu_op,
    input [31:0]src_data1,src_data2,
    input [4:0]wr_addr,
    input [5:0]stall_en,
    input wr_en,
    output reg[2:0]pipe_alu_sel,
    output reg[7:0]pipe_alu_op,
    output reg[31:0]pipe_src_data1,pipe_src_data2,
    output reg[4:0]pipe_wr_addr,
    output reg pipe_wr_en
);
    //---------------------------------------------------------------//
    //          This module is for pipeline (As a Buffer)            //
    //---------------------------------------------------------------//
    
    always @(posedge clk) begin
        if(reset || (stall_en[2] && !stall_en[3]))begin
            pipe_alu_sel <= 3'd0;
            pipe_alu_op <= 8'd0;
            pipe_src_data1 <= 32'd0;
            pipe_src_data2 <= 32'd0;
            pipe_wr_addr <= 5'd0;
            pipe_wr_en <= 1'd0;
        end
        else if(!stall_en[2])begin
            pipe_alu_sel <= alu_sel;
            pipe_alu_op <= alu_op;
            pipe_src_data1 <= src_data1;
            pipe_src_data2 <= src_data2;
            pipe_wr_addr <= wr_addr;
            pipe_wr_en <= wr_en;
        end
        else begin
        end
    end
endmodule