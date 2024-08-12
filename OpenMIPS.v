`include "program_counter.v"
`include "pipe_if_id.v"
`include "reg_file.v"
`include "ins_decode.v"
`include "pipe_ins_decode.v"
`include "ex.v"
`include "pipe_ex.v"
`include "mem.v"
`include "pipe_mem.v"

module OpenMIPS(
    input clk,reset,
    input [31:0]rom_data_in,
    output [31:0]rom_addr_out,
    output rom_en
);
    wire [31:0]pc;
    wire [31:0]id_pc;
    wire [31:0]id_inst;

    wire [7:0]id_alu_op;
    wire [2:0]id_alu_sel;
    wire [31:0]id_data1;
    wire [31:0]id_data2;
    wire       id_en;
    wire [4:0]id_addr;

    wire [7:0]ex_alu_op;
    wire [2:0]ex_alu_sel;
    wire [31:0]ex_data1;
    wire [31:0]ex_data2;
    wire       ex_en;
    wire [4:0]ex_addr;

    wire ex_out_en;
    wire [4:0]ex_out_addr;
    wire [31:0]ex_out_data;

    wire mem_en;
    wire [4:0]mem_addr;
    wire [31:0]mem_data;

    wire out_mem_en;
    wire [4:0]out_mem_addr;
    wire [31:0]out_mem_data;

    wire pip_mem_en;
    wire [4:0]pip_mem_addr;
    wire [31:0]pip_mem_data;

    wire data1_en,data2_en;
    wire [4:0]data1_addr,data2_addr;
    wire [31:0]data1_data,data2_data;

    program_counter u_program_counter  (.clk(clk),.reset(reset),.chip_en(rom_en),.pc(pc));
    
    assign rom_addr_out = pc;
    
    pipe_if_id      u_pipe_if_id       (.clk(clk),.reset(reset),.if_pc(pc),.if_inst(rom_data_in),.id_pc(id_pc),.id_inst(id_inst));

    ins_decode      u_ins_decode       (.reset(reset),.pc(id_pc),.ins(id_inst),.rf_data1(data1_data),.rf_data2(data2_data),.rd1_en(data1_en),.rd2_en(data2_en),.addr1(data1_addr),
                                        .addr2(data2_addr),.alu_op(id_alu_op),
                                        .alu_sel(id_alu_sel),.src_data1(id_data1),.src_data2(id_data2),.wr_addr(id_addr),.wr_en(id_en));

    reg_file        u_reg_file         (.clk (clk),.reset(reset),.wr_en(pip_mem_en),.rd1_en(data1_en),.rd2_en(data2_en),.wr_data(pip_mem_data),.wr_addr(pip_mem_addr),
                                        .addr1(data1_addr),.addr2(data2_addr),.out_data1(data1_data),.out_data2(data2_data));

    pipe_ins_decode u_pipe_ins_decode  (.clk(clk),.reset(reset),.alu_sel(id_alu_sel),.alu_op(id_alu_op),.src_data1(id_data1),.src_data2(id_data2),.wr_addr(id_addr),.wr_en(id_en),
                                        .pipe_alu_sel(ex_alu_sel),.pipe_alu_op(ex_alu_op),.pipe_src_data1(ex_data1),.pipe_src_data2(ex_data2),.pipe_wr_addr(ex_addr),
                                        .pipe_wr_en(ex_en));

    ex              u_ex               (.reset(reset),.alu_sel(ex_alu_sel),.alu_op(ex_alu_op),.src_data1(ex_data1),.src_data2(ex_data2),.wr_addr(ex_addr),.wr_en(ex_en),
                                        .out_addr(ex_out_addr),.out_data(ex_out_data),.out_en(ex_out_en));

    pipe_ex         u_pipe_ex          (.clk(clk),.reset(reset),.out_addr(ex_out_addr),.out_en(ex_out_en),.out_data(ex_out_data),
                                        .pipe_out_addr(mem_addr),.pipe_out_en(mem_en),.pipe_out_data(mem_data));

    mem             u_mem              (.reset(reset),.addr(mem_addr),.wr_en(mem_en),.data(mem_data),.out_addr(out_mem_addr),.out_en(out_mem_en),.out_data(out_mem_data));

    pipe_mem        u_pipe_mem         (.clk(clk),.reset(reset),.mem_addr(out_mem_addr),.mem_en(out_mem_en),.mem_data(out_mem_data),
                                        .pipe_mem_addr(pip_mem_addr),.pipe_mem_en(pip_mem_en),.pipe_mem_data(pip_mem_data));

endmodule