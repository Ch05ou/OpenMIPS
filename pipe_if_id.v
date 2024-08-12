module pipe_if_id(
    input clk,reset,
    input [31:0]if_pc,if_inst,
    output reg [31:0]id_pc,id_inst
);
    //---------------------------------------------------------------//
    //          This module is for pipeline (As a Buffer)            //
    //---------------------------------------------------------------//
    always @(posedge clk) begin
        if(reset)begin
            id_pc <= 32'd0;
            id_inst <= 32'd0;
        end
        else begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end
endmodule