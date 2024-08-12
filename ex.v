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
    reg [31:0] result;

    always @(*) begin
        if(reset)begin
            result <= 32'd0;
        end
        else begin
            case(alu_op)
                8'b00100101:begin
                    result <= src_data1 | src_data2;
                end
                default:begin
                    result <= 32'd0;
                end
            endcase
        end
    end
    
    always @(*) begin
        out_addr <= wr_addr;
        out_en <= wr_en;
        case(alu_sel)
            3'b001:begin
                out_data <= result;
            end
            default:begin
                out_data <= 32'd0;
            end
        endcase
    end
endmodule