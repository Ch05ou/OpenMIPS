module pipe_mem(
    input clk,reset,
    input [4:0]mem_addr,
    input mem_en,
    input [31:0]mem_data,
    output reg[4:0]pipe_mem_addr,
    output reg pipe_mem_en,
    output reg[31:0]pipe_mem_data
);
    always @(posedge clk ) begin
        if(reset)begin
            pipe_mem_en <= 1'b0;
            pipe_mem_addr <= 5'd0;
            pipe_mem_data <= 32'd0;
        end
        else begin
            pipe_mem_en <= mem_en;
            pipe_mem_addr <= mem_addr;
            pipe_mem_data <=mem_data;
        end
    end
endmodule