module pipe_mem(
    input clk,reset,
    input [4:0]mem_addr,
    input mem_en,mem_hilo_en,
    input [31:0]mem_data,mem_hi,mem_lo,
    output reg[4:0]pipe_mem_addr,
    output reg pipe_mem_en,pipe_hilo_en,
    output reg[31:0]pipe_mem_data,pipe_hi,pipe_lo
);
    always @(posedge clk ) begin
        if(reset)begin
            pipe_mem_en <= 1'b0;
            pipe_mem_addr <= 5'd0;
            pipe_mem_data <= 32'd0;
            pipe_hilo_en <= 1'b0;
            pipe_hilo_hi <= 32'd0;
            pipe_hilo_lo <= 32'd0;
        end
        else begin
            pipe_mem_en <= mem_en;
            pipe_mem_addr <= mem_addr;
            pipe_mem_data <=mem_data;
            pipe_hilo_en <= mem_hilo_en;
            pipe_hi <= mem_hi;
            pipe_lo <= mem_lo;
        end
    end
endmodule