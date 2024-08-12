module pipe_ex(
    input clk,reset,
    input [4:0]out_addr,
    input out_en,
    input [31:0]out_data,
    output reg[4:0]pipe_out_addr,
    output reg pipe_out_en,
    output reg[31:0]pipe_out_data
);
    always @(posedge clk ) begin
        if(reset)begin
            pipe_out_data <= 32'd0;
            pipe_out_en <= 1'd0;
            pipe_out_addr <= 5'd0;
        end
        else begin
            pipe_out_addr <= out_addr;
            pipe_out_en <= out_en;
            pipe_out_data <= out_data;
        end
    end
endmodule