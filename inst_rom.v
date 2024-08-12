module inst_rom(
    input chip_en,
    input [31:0]isnt_addr,
    output reg[31:0]inst
);
    reg [31:0]inst_mem[0:131070];

    initial begin
        $readmemh("inst_rom.data",inst_mem);
    end

    always @(*) begin
        if(~chip_en)begin
            inst <= 32'd0;
        end
        else begin
            inst <= inst_mem[isnt_addr[18:2]];
        end
    end
endmodule