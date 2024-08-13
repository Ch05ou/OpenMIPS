`include "program_counter.v"
`include "pipe_if_id.v"
`include "reg_file.v"
`include "ins_decode.v"
`include "pipe_ins_decode.v"
`include "ex.v"
`include "pipe_ex.v"
`include "mem.v"
`include "pipe_mem.v"
`include "HILO.v"

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
    wire ex_hilo_en;
    wire [31:0]ex_hi;
    wire [31:0]ex_lo;

    wire ex_pipe_hilo_en;
    wire [31:0]ex_pipe_hi;
    wire [31:0]ex_pipe_lo;

    wire mem_en,mem_hilo_en;
    wire [4:0]mem_addr;
    wire [31:0]mem_data,mem_hi,mem_lo;

    wire out_mem_en;
    wire [4:0]out_mem_addr;
    wire [31:0]out_mem_data;

    wire pip_mem_en,pipe_mem_hilo_en;
    wire [4:0]pip_mem_addr;
    wire [31:0]pip_mem_data,pipe_mem_hi,pipe_mem_lo;

    wire data1_en,data2_en;
    wire [4:0]data1_addr,data2_addr;
    wire [31:0]data1_data,data2_data;

    wire [31:0]HI,Lo;

    program_counter u_program_counter  (.clk(clk),.reset(reset),.chip_en(rom_en),.pc(pc));
    
    assign rom_addr_out = pc;
    
    pipe_if_id      u_pipe_if_id       (.clk(clk),.reset(reset),
                                        .if_pc(pc),
                                        .if_inst(rom_data_in),
                                        .id_pc(id_pc),
                                        .id_inst(id_inst)
                                        );

    ins_decode      u_ins_decode       (.reset(reset),
                                        .pc(id_pc),                 
                                        .ins(id_inst),                  // [I] Instruction from Instruction ROM 
                                        .rf_data1(data1_data),          // [I] Register data from Register file
                                        .rf_data2(data2_data),          // [I] Register data from Register file
                                        .ex_rewrite_en(ex_out_en),
                                        .ex_rewrite_addr(ex_out_addr),
                                        .ex_rewrite_data(ex_out_data),
                                        .mem_rewrite_en(out_mem_en),
                                        .mem_rewrite_addr(out_mem_addr),
                                        .mem_rewrite_data(out_mem_data),
                                        .rd1_en(data1_en),              // [O] Register file Read enable
                                        .rd2_en(data2_en),              // [O] Register file Read enable
                                        .addr1(data1_addr),             // [O] (Read) Register file data Address 
                                        .addr2(data2_addr),             // [O] (Read) Register file data Address 
                                        .alu_op(id_alu_op),             // [O] ALU's operator code
                                        .alu_sel(id_alu_sel),           // [O] ALU function select
                                        .src_data1(id_data1),           // [O] Output for register data/imm to ex (ALU Module)
                                        .src_data2(id_data2),           // [O] Output for register data/imm to ex (ALU Module)
                                        .wr_addr(id_addr),              // [O] Register file Write address
                                        .wr_en(id_en)                   // [O] Register file Write Enable
                                        );

    reg_file        u_reg_file         (.clk (clk),.reset(reset),       
                                        .wr_en(pip_mem_en),             // [I] write enable
                                        .rd1_en(data1_en),              // [I] read enable
                                        .rd2_en(data2_en),              // [I] read enable
                                        .wr_data(pip_mem_data),         // [I] write data
                                        .wr_addr(pip_mem_addr),         // [I] write address
                                        .addr1(data1_addr),             // [I] read address
                                        .addr2(data2_addr),             // [I] read address
                                        .out_data1(data1_data),         // [O] read data
                                        .out_data2(data2_data)          // [O] read data
                                        );

    pipe_ins_decode u_pipe_ins_decode  (.clk(clk),.reset(reset),        
                                        .alu_sel(id_alu_sel),           
                                        .alu_op(id_alu_op),             
                                        .src_data1(id_data1),           
                                        .src_data2(id_data2),           
                                        .wr_addr(id_addr),              
                                        .wr_en(id_en),                  
                                        .pipe_alu_sel(ex_alu_sel),      
                                        .pipe_alu_op(ex_alu_op),        
                                        .pipe_src_data1(ex_data1),      
                                        .pipe_src_data2(ex_data2),      
                                        .pipe_wr_addr(ex_addr),         
                                        .pipe_wr_en(ex_en)              
                                        );

    ex              u_ex               (.reset(reset),                  
                                        .alu_sel(ex_alu_sel),           // []
                                        .alu_op(ex_alu_op),             // []
                                        .src_data1(ex_data1),           // []
                                        .src_data2(ex_data2),           // []
                                        .wr_addr(ex_addr),              // []
                                        .wr_en(ex_en),                  // []
                                        .out_addr(ex_out_addr),         // []
                                        .out_data(ex_out_data),         // []
                                        .out_en(ex_out_en),             // []
                                        .mem_hilo_wr_en(mem_hilo_en),              
                                        .mem_pip_en(pipe_mem_hilo_en),
                                        .HI(HI),
                                        .LO(LO),
                                        .mem_hi_data(mem_hi),
                                        .mem_lo_data(mem_lo),
                                        .mem_pip_hi(pipe_mem_hi),
                                        .mem_pip_lo(pipe_mem_lo),
                                        .hilo_wr_en(ex_hilo_en),
                                        .hi_data(ex_hi),
                                        .lo_data(ex_lo)
                                        );

    pipe_ex         u_pipe_ex          (.clk(clk),.reset(reset),
                                        .out_addr(ex_out_addr),
                                        .out_en(ex_out_en),
                                        .out_data(ex_out_data),
                                        .pipe_out_addr(mem_addr),
                                        .pipe_out_en(mem_en),
                                        .pipe_out_data(mem_data),
                                        .hilo_wr_en(ex_hilo_en),
                                        .hilo_wr_hi(ex_hi),
                                        .hilo_wr_lo(ex_lo),
                                        .pipe_hilo_en(ex_pipe_hilo_en),
                                        .pipe_hilo_hi(ex_pipe_hi),
                                        .pipe_hilo_lo(ex_pipe_lo)
                                        );

    mem             u_mem              (.reset(reset),      
                                        .addr(mem_addr),                // []
                                        .wr_en(mem_en),                 // []
                                        .data(mem_data),                // []
                                        .out_addr(out_mem_addr),        // []
                                        .out_en(out_mem_en),            // []
                                        .out_data(out_mem_data)         // []
                                        .hilo_wr_en(ex_pipe_hilo_en),
                                        .hilo_wr_hi(ex_pipe_hi),
                                        .hilo_wr_lo(ex_pipe_lo),
                                        .hilo_out_en(mem_hilo_en),
                                        .hilo_out_hi(mem_hi),
                                        .hilo_out_lo(mem_lo)
                                        );

    pipe_mem        u_pipe_mem         (.clk(clk),.reset(reset),
                                        .mem_addr(out_mem_addr),
                                        .mem_en(out_mem_en),
                                        .mem_data(out_mem_data),
                                        .pipe_mem_addr(pip_mem_addr),
                                        .pipe_mem_en(pip_mem_en),
                                        .pipe_mem_data(pip_mem_data),
                                        .mem_hilo_en(mem_hilo_en),
                                        .mem_hi(mem_hi),
                                        .mem_lo(mem_lo),
                                        .pipe_hilo_en(pipe_mem_hilo_en),
                                        .pipe_hi(pipe_mem_hi),
                                        .pipe_lo(pipe_mem_lo)
                                        );
    HILO            u_HILO             (
                                        .clk(clk),.reset(reset),
                                        .wr_en(pipe_mem_hilo_en),
                                        .HI(pipe_mem_hi),
                                        .LO(pipe_mem_lo),
                                        .out_HI(HI),
                                        .out_LO(LO)
                                        );

endmodule