module ex(
    input reset,
    input [2:0]alu_sel,
    input [7:0]alu_op,
    input [31:0]src_data1,src_data2,
    input [4:0]wr_addr,
    input wr_en,
    input [31:0]HI,LO,mem_hi_data,mem_lo_data,mem_pip_hi,mem_pip_lo,
    input mem_hilo_wr_en,mem_pip_en,
    output reg[4:0]out_addr,
    output reg[31:0]out_data,
    output reg out_en,
    output reg hilo_wr_en,
    output reg[31:0]hi_data,lo_data
);
    reg [31:0] logic_result;                                    // Logic Result
    reg [31:0] shift_result;                                    // Shift Result
    reg [31:0] hi;
    reg [31:0] lo;
    reg [31:0] move_result;

    always @(*) begin                                           // Logic Calculate
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

    always @(*) begin                                           // Shift Calculate
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

    always @(*) begin                                           // Move Calculate
        if(reset)begin
            move_result <= 32'd0;
        end
        else begin
            move_result <= 32'd0;
            case(alu_op)
                8'b00001010:begin                               // MOVZ
                    move_result <= src_data1;
                end
                8'b00001011:begin                               // MOVN
                    move_result <= src_data1;
                end
                8'b00010000:begin                               // MFHI
                    move_result <= hi;
                end
                8'b00010010:begin                               // MFLO
                    move_result <= lo;
                end
                default:begin
                end
            endcase
        end
    end
    
    always @(*) begin                                           // Result Select
        out_addr <= wr_addr;
        out_en <= wr_en;
        case(alu_sel)
            3'b001:begin
                out_data <= logic_result;
            end
            3'b010:begin
                out_data <= shift_result;
            end
            3'b011:begin
                out_data <= move_result;
            end
            default:begin
                out_data <= 32'd0;
            end
        endcase
    end

    always @(*) begin                                           // Access HI and LO
        if(reset)begin
           {hi,lo} <= 64'd0; 
        end
        else if(mem_hilo_wr_en) begin
            {hi,lo} <= {mem_hi_data,mem_lo_data};
        end
        else if(mem_pip_en)begin
            {hi,lo} <= {mem_pip_hi,mem_pip_lo};
        end
        else begin
            {hi,lo} <= {HI,LO};
        end
    end

    always @(*) begin                                           // MTHI and MTLO
        if(reset)begin
            hilo_wr_en <= 1'b0;
            hi_data <= 32'd0;
            lo_data <= 32'd0;
        end
        else begin
            case(alu_op)
                8'b00010001:begin
                    hilo_wr_en <= 1'b1;
                    hi_data <= src_data1;
                    lo_data <= lo;
                end
                8'b00010011:begin
                    hilo_wr_en <= 1'b1;
                    hi_data <= hi;
                    lo_data <= src_data1;
                end
                default:begin
                    hilo_wr_en <= 1'b0;
                    hi_data <= 32'd0;
                    lo_data <= 32'd0;
                end
            endcase
        end
    end
endmodule