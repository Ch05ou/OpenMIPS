module program_counter(
    input clk,reset,
    output reg chip_en,
    output reg [31:0]pc
);
    //---------------------------------------------------------------//
    //                      Program Counter                          //
    //---------------------------------------------------------------//
    always @(posedge clk) begin
        if(reset)begin
            chip_en <= 1'b0;
        end
        else begin
            chip_en <= 1'b1;
        end
    end

    always @(posedge clk) begin
        if(~chip_en)begin
            pc <= 32'd0;
        end
        else begin
            pc <= pc + 4;
        end
    end
endmodule