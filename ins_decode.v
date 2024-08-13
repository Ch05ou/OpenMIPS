module ins_decode(
    input reset,
    input [31:0]pc,ins,rf_data1,rf_data2,

    // Data rewrite avoid pipeline conflict for ex
    input ex_rewrite_en,
    input [4:0]ex_rewrite_addr,
    input [31:0]ex_rewrite_data,
    // Data rewrite avoid pipeline conflict for memory
    input mem_rewrite_en,
    input [4:0]mem_rewrite_addr,
    input [31:0]mem_rewrite_data,

    output reg rd1_en,rd2_en,
    output reg[4:0]addr1,addr2,
    output reg[7:0]alu_op,
    output reg[2:0]alu_sel,
    output reg[31:0]src_data1,src_data2,
    output reg[4:0]wr_addr,
    output reg wr_en
);
    wire [5:0]opcode = ins[31:26];
    wire [4:0]rs = ins[25:21];
    wire [4:0]rt = ins[20:16];
    wire [4:0]rd = ins[15:11];
    wire [4:0]shamt = ins[10:6]; 
    wire [5:0]funct = ins[5:0];

    reg [31:0]imme;
    reg ins_check;

    always @(*) begin
        if(reset)begin
            alu_op <= 6'd0;
            alu_sel<= 8'd0;
            wr_addr <= 5'd0;
            wr_en <= 1'd0;
            ins_check <= 1'd0;
            rd1_en <= 1'd0;
            rd2_en <= 1'd0;
            addr1 <= 5'd0;
            addr2 <= 5'd0;
            imme <= 32'd0;
        end
        else begin
            alu_op <= 6'd0;
            alu_sel <= 8'd0;
            wr_addr <= rd;
            wr_en <= 1'd0;
            ins_check <= 1'd1;
            rd1_en <= 1'd0;
            rd2_en <= 1'd0;
            addr1 <= ins[25:21];
            addr2 <= ins[20:16];
            imme <= 32'd0;
            case(opcode)
                6'b000000:begin                     // R-Type insruction
                    case(shamt)
                        5'b00000:begin
                            case(funct)
                                6'b100100:begin         // AND
                                    wr_en <= 1'd1;
                                    alu_op <= 8'b00100100;
                                    alu_sel <= 3'b001;
                                    rd1_en <= 1'b1;
                                    rd2_en <= 1'b1;
                                    ins_check <= 1'b1;
                                end
                                6'b100101:begin         // OR
                                    wr_en <= 1'd1;
                                    alu_op <= 8'b00100101;
                                    alu_sel <= 3'b001;
                                    rd1_en <= 1'b1;
                                    rd2_en <= 1'b1;
                                    ins_check <= 1'b1;
                                end
                                6'b100110:begin         // XOR
                                    wr_en <= 1'b1;
                                    alu_op <= 8'b00100110;
                                    alu_sel <= 3'b001;
                                    rd1_en <= 1'b1;
                                    rd2_en <= 1'b1;
                                    ins_check <= 1'b1;
                                end
                                6'b100111:begin         // NOR
                                    wr_en <= 1'b1;
                                    alu_op <= 8'b00100111;
                                    alu_sel <= 3'b001;
                                    rd1_en <= 1'b1;
                                    rd2_en <= 1'b1;
                                    ins_check <= 1'b1;
                                end
                                6'b000100:begin         // SLLV
                                    wr_en <= 1'b1;
                                    alu_op <= 8'b01111100;
                                    alu_sel <= 3'b010;
                                    rd1_en <= 1'b1;
                                    rd2_en <= 1'b1;
                                    ins_check <= 1'b1;
                                end
                                6'b000110:begin         // SRLV
                                    wr_en <= 1'b1;
                                    alu_op <= 8'b00000010;
                                    alu_sel <= 3'b010;
                                    rd1_en <= 1'b1;
                                    rd2_en <= 1'b1;
                                    ins_check <= 1'b1;
                                end
                                6'b000111:begin         // SRAV
                                    wr_en <= 1'b1;
                                    alu_op <= 8'b00000011;
                                    alu_sel <= 3'b010;
                                    rd1_en <= 1'b1;
                                    rd2_en <= 1'b1;
                                    ins_check <= 1'b1;
                                end               
                                6'b001111:begin         // SYNC
                                    wr_en <= 1'b1;
                                    alu_op <= 8'b00000000;
                                    alu_sel <= 3'b000;
                                    rd1_en <= 1'b0;
                                    rd2_en <= 1'b1;
                                    ins_check <= 1'b1;
                                end
                                6'b001010:begin         // MOVZ
                                    alu_op <= 8'b00001010;
                                    alu_sel <= 3'b011;
                                    rd1_en <= 1'b1;
                                    rd2_en <= 1'b1;
                                    ins_check <= 1'b1;
                                    wr_en <= (src_data2 == 32'd0)? 1'b1:1'b0;
                                end
                                6'b001011:begin         // MOVN
                                    alu_op <= 8'b00001011;
                                    alu_sel <= 3'b011;
                                    rd1_en <= 1'b1;
                                    rd2_en <= 1'b1;
                                    ins_check <= 1'b1;
                                    wr_en <= (src_data2 == 32'd0)? 1'b0:1'b1;
                                end
                                6'b010000:begin         // MFHI
                                    wr_en <= 1'b1;
                                    alu_op <= 00010000;
                                    alu_sel <= 3'b011;
                                    rd1_en <= 1'b0;
                                    rd2_en <= 1'b0;
                                    ins_check <= 1'b1;
                                end
                                6'b010001:begin         // MTHI
                                    wr_en <= 1'b0;
                                    alu_op <= 00010001;
                                    alu_sel <= 3'b011;
                                    rd1_en <= 1'b1;
                                    rd2_en <= 1'b0;
                                    ins_check <= 1'b1;
                                end
                                6'b010010:begin         // MFLO
                                    wr_en <= 1'b1;
                                    alu_op <= 00010010;
                                    alu_sel <= 3'b011;
                                    rd1_en <= 1'b0;
                                    rd2_en <= 1'b0;
                                    ins_check <= 1'b1;
                                end
                                6'b010011:begin         // MTLO
                                    wr_en <= 1'b1;
                                    alu_op <= 00010011;
                                    alu_sel <= 3'b011;
                                    rd1_en <= 1'b0;
                                    rd2_en <= 1'b0;
                                    ins_check <= 1'b1;
                                end
                                default:begin
                                end
                            endcase
                        end
                    endcase
                end
                6'b001100:begin                     // ANDI
                    wr_en <= 1'd1;
                    alu_op <= 8'b00100100;
                    alu_sel <= 3'b001;
                    rd1_en <= 1'b1;
                    rd2_en <= 1'b0;
                    imme <= {16'd0,ins[15:0]};
                    wr_addr <= ins[20:16];
                    ins_check <= 1'b1;
                end
                6'b001101:begin                     // ORI
                    wr_en <= 1'd1;
                    alu_op <= 8'b00100101;
                    alu_sel <= 3'b001;
                    rd1_en <= 1'b1;
                    rd2_en <= 1'b0;
                    imme <= {16'd0,ins[15:0]};
                    wr_addr <= ins[20:16];
                    ins_check <= 1'b1;
                end
                6'b001110:begin                     // XORI
                    wr_en <= 1'd1;
                    alu_op <= 8'b00100110;
                    alu_sel <= 3'b001;
                    rd1_en <= 1'b1;
                    rd2_en <= 1'b0;
                    imme <= {16'd0,ins[15:0]};
                    wr_addr <= ins[20:16];
                    ins_check <= 1'b1;
                end
                6'b001111:begin                     // LUI
                    wr_en <= 1'd1;
                    alu_op <= 8'b00100101;
                    alu_sel <= 3'b001;
                    rd1_en <= 1'b1;
                    rd2_en <= 1'b0;
                    imme <= {ins[15:0],16'd0};
                    wr_addr <= ins[20:16];
                    ins_check <= 1'b1;
                end
                6'b110011:begin                     // PREF
                    wr_en <= 1'd1;
                    alu_op <= 8'b00000000;
                    alu_sel <= 3'b000;
                    rd1_en <= 1'b0;
                    rd2_en <= 1'b0;
                    ins_check <= 1'b1;
                end
                default:begin
                end
            endcase

            if(ins[31:21] == 11'd0)begin
                if(funct == 6'b000000)begin         // SLL
                    wr_en <= 1'd1;
                    alu_op <= 8'b01111100;
                    alu_sel <= 3'b010;
                    rd1_en <= 1'b0;
                    rd2_en <= 1'b1;
                    imme[4:0] <= ins[10:6];
                    wr_addr <= ins[15:11];
                    ins_check <= 1'b1;
                end
                else if(funct == 6'b000010)begin    // SRL
                    wr_en <= 1'd1;
                    alu_op <= 8'b00000010;
                    alu_sel <= 3'b010;
                    rd1_en <= 1'b0;
                    rd2_en <= 1'b1;
                    imme[4:0] <= ins[10:6];
                    wr_addr <= ins[15:11];
                    ins_check <= 1'b1;
                end
                else if(funct == 6'b000011)begin    // SRA
                    wr_en <= 1'd1;
                    alu_op <= 8'b00000011;
                    alu_sel <= 3'b010;
                    rd1_en <= 1'b0;
                    rd2_en <= 1'b1;
                    imme[4:0] <= ins[10:6];
                    wr_addr <= ins[15:11];
                    ins_check <= 1'b1;
                end
                else begin
                end
            end
            else begin
            end
        end
    end

    always @(*) begin
        if(reset)begin
            src_data1 <= 32'd0;
        end
        else if(rd1_en && ex_rewrite_en && (ex_rewrite_addr == addr1))begin
            src_data1 <= ex_rewrite_data;
        end
        else if(rd1_en && mem_rewrite_en && (mem_rewrite_addr == addr1))begin
            src_data1 <= mem_rewrite_data;
        end
        else if(rd1_en == 1'b1)begin
            src_data1 <= rf_data1;
        end
        else if(rd1_en == 1'b0)begin
            src_data1 <= imme;
        end
        else begin
            src_data1 <= 32'd0;
        end
    end

    always @(*) begin
        if(reset)begin
            src_data2 <= 32'd0;
        end
        else if(rd2_en && ex_rewrite_en && (ex_rewrite_addr == addr2))begin
            src_data2 <= ex_rewrite_data;
        end
        else if(rd2_en && mem_rewrite_en && (mem_rewrite_addr == addr2))begin
            src_data2 <= mem_rewrite_data;
        end
        else if(rd2_en == 1'b1)begin
            src_data2 <= rf_data2;
        end
        else if(rd2_en == 1'b0)begin
            src_data2 <= imme;
        end
        else begin
            src_data2 <= 32'd0;
        end
    end

endmodule