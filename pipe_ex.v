module pipe_ex(
    input clk,reset,
    input [4:0]out_addr,
    input out_en,hilo_wr_en,
    input [31:0]out_data,hilo_wr_hi,hilo_wr_lo,
    input [5:0]stall_en,
    input [63:0]hilo_in,
    input [1:0]counter_in,
    output reg[4:0]pipe_out_addr,
    output reg pipe_out_en,pipe_hilo_en,
    output reg[31:0]pipe_out_data,pipe_hilo_hi,pipe_hilo_lo,
    output reg[64:0]pipe_hilo_out,
    output reg[1:0]pipe_counter_out
);
    always @(posedge clk ) begin
        if(reset)begin
            pipe_out_data <= 32'd0;
            pipe_out_en <= 1'd0;
            pipe_out_addr <= 5'd0;
            pipe_hilo_en <= 1'b0;
            pipe_hilo_hi <= 32'd0;
            pipe_hilo_lo <= 32'd0;
            pipe_hilo_out <= {32'd0,32'd0};
            pipe_counter_out <= 2'b00;
        end
        else if(stall_en[3] && stall_en[4] == 1'b0)begin
            pipe_out_data <= 32'd0;
            pipe_out_en <= 1'd0;
            pipe_out_addr <= 5'd0;
            pipe_hilo_en <= 1'b0;
            pipe_hilo_hi <= 32'd0;
            pipe_hilo_lo <= 32'd0;
            pipe_hilo_out <= hilo_in;
            pipe_counter_out <= counter_in;
        end
        else if(!stall_en[3])begin
            pipe_out_addr <= out_addr;
            pipe_out_en <= out_en;
            pipe_out_data <= out_data;
            pipe_hilo_en <= hilo_wr_en;
            pipe_hilo_hi <= hilo_wr_hi;
            pipe_hilo_lo <= hilo_wr_lo;
            pipe_hilo_out <= {32'd0,32'd0};
            pipe_counter_out <= 2'b00;
        end
        else begin
            pipe_hilo_out <= hilo_in;
            pipe_counter_out <= counter_in;
        end
    end
endmodule