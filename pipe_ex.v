module pipe_ex(
    input clk,reset,
    input [4:0]out_addr,
    input out_en,hilo_wr_en,
    input [31:0]out_data,hilo_wr_hi,hilo_wr_lo,
    output reg[4:0]pipe_out_addr,
    output reg pipe_out_en,pipe_hilo_en,
    output reg[31:0]pipe_out_data,pipe_hilo_hi,pipe_hilo_lo
);
    always @(posedge clk ) begin
        if(reset)begin
            pipe_out_data <= 32'd0;
            pipe_out_en <= 1'd0;
            pipe_out_addr <= 5'd0;
            pipe_hilo_en <= 1'b0;
            pipe_hilo_hi <= 32'd0;
            pipe_hilo_lo <= 32'd0;
        end
        else begin
            pipe_out_addr <= out_addr;
            pipe_out_en <= out_en;
            pipe_out_data <= out_data;
            pipe_hilo_en <= hilo_wr_en;
            pipe_hilo_hi <= hilo_wr_hi;
            pipe_hilo_lo <= hilo_wr_lo;
        end
    end
endmodule