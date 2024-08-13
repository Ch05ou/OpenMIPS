module mem(
    input reset,
    input [4:0]addr,
    input wr_en,hilo_wr_en,
    input [31:0]data,hilo_wr_hi,hilo_wr_lo,
    output reg[4:0]out_addr,
    output reg out_en,hilo_out_en,
    output reg[31:0]out_data,hilo_out_hi,hilo_out_lo
);
    always @(*) begin
        if(reset)begin
            out_addr <= 5'd0;
            out_en <= 1'd0;
            out_data <= 32'd0;
            hilo_out_en <= 1'b0;
            hilo_out_hi <= 32'd0;
            hilo_out_lo <= 32'd0;
        end
        else begin
            out_data <= data;
            out_en <= wr_en;
            out_addr <= addr;
            hilo_out_en <= hilo_wr_en;
            hilo_out_hi <= hilo_wr_hi;
            hilo_out_lo <= hilo_wr_lo;
        end
    end
endmodule