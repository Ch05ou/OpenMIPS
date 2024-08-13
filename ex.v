module ex(
    input reset,
    input [2:0]alu_sel,
    input [7:0]alu_op,
    input [31:0]src_data1,src_data2,
    input [4:0]wr_addr,
    input wr_en,
    output reg[4:0]out_addr,
    output reg[31:0]out_data,
    output reg out_en
);
    reg [31:0] logic_result;                                     // Logic Result
    reg [31:0] shift_result;                                     // Shift Result

    always @(*) begin
        if(reset)begin
            logic_result <= 32'd0;
        end
        else begin
            case(alu_op)
                8'b00100101:begin                                // OR
                    logic_result <= src_data1 | src_data2;
                end
                8'b00100100:begin                                // AND
                    logic_result <= src_data1 & src_data2;
                end
                8'b00100110:begin                               // XOR
                    logic_result <= src_data1 ^ src_data2;
                end
                8'b00100111:begin                               // NOR
                    logic_result <= ~(src_data1 | src_data2);
                end
                default:begin
                    logic_result <= 32'd0;
                end
            endcase
        end
    end

    always @(*) begin
        if(reset)begin
            shift_result <= 32'd0;
        end
        else begin
            case(alu_op)
                8'b00000010:begin                               // SRL
                    shift_result <= src_data2 >> src_data1[4:0];
                end
                8'b00000011:begin                               // SRA
                    shift_result <= ({32{src_data2[31]}} << (6'd32 - {1'b0,src_data1[4:0]}))    
                    |src_data2 >> src_data1[4:0];           
                end
                8'b01111100:begin                               //SLL
                    shift_result <= src_data2 << src_data1[4:0];
                end
                default:begin
                end
            endcase
        end
    end
    
    always @(*) begin
        out_addr <= wr_addr;
        out_en <= wr_en;
        case(alu_sel)
            3'b001:begin
                out_data <= logic_result;
            end
            3'b010:begin
                out_data <= shift_result;
            end
            default:begin
                out_data <= 32'd0;
            end
        endcase
    end
endmodule