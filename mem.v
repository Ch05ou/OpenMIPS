module mem(
    input reset,
    input [4:0]addr,
    input wr_en,
    input [31:0]data,
    output reg[4:0]out_addr,
    output reg out_en,
    output reg[31:0]out_data
);
    always @(*) begin
        if(reset)begin
            out_addr <= 5'd0;
            out_en <= 1'd0;
            out_data <= 32'd0;
        end
        else begin
            out_data <= data;
            out_en <= wr_en;
            out_addr <= addr;
        end
    end
endmodule