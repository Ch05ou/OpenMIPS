`define ORI_test "inst_rom_ori.data"
`define Hazard_test "inst_rom_hazard.data"
`define Logic_test "inst_rom_logic.data"
`define Shift_test "inst_rom_shift.data"
`define Move_test "inst_rom_move.data"
`define SA_test "inst_rom_sa.data"

module inst_rom(
    input chip_en,
    input [31:0]isnt_addr,
    output reg[31:0]inst
);
    reg [31:0]inst_mem[0:131070];

    initial begin
        $readmemh("inst_rom_sa.data",inst_mem);
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