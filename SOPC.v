`include "inst_rom.v"
`include "OpenMIPS.v"
module SOPC(
    input clk,reset
);
    wire [31:0]isnt_addr,inst;
    wire rom_en;
    OpenMIPS CPU(.clk(clk),.reset(reset),.rom_data_in(inst),.rom_addr_out(isnt_addr),.rom_en(rom_en));
    inst_rom rom(.chip_en(rom_en),.isnt_addr(isnt_addr),.inst(inst));
endmodule