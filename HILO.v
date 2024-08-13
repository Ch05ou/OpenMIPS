module HILO(
    input clk,reset,
    input wr_en,
    input [31:0]HI,LO,
    output reg[31:0]out_HI,out_LO
);
    always @(posedge clk ) begin
        if(reset)begin
            out_HI <= 32'd0;
            out_LO <= 32'd0; 
        end
        else begin
            out_HI <= (wr_en)? HI:out_HI;
            out_LO <= (wr_en)? LO:out_LO;
        end
    end
endmodule