module ins_decode(
    input reset,
    input [31:0]pc,ins,rf_data1,rf_data2,

    // Data rewrite avoid pipeline conflict for ex
    input ex_rewrite_en,
    input [4:0]ex_rewrite_addr,
    input [31:0]ex_rewrite_data,
    input mem_rewrite_en,
    input [4:0]mem_rewrite_addr,
    input [31:0]mem_rewrite_data,

    // Data rewrite avoid pipeline conflict for memory
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
                6'b001101:begin
                    wr_en <= 1'd1;
                    alu_op <= 8'b00100101;
                    alu_sel <= 3'b001;
                    rd1_en <= 1'b1;
                    rd2_en <= 1'b0;
                    imme <= {16'd0,ins[15:0]};
                    wr_addr <= ins[20:16];
                    ins_check <= 1'b1;
                end
                default:begin
                end
            endcase
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