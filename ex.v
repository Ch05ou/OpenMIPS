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
    reg [31:0] move_result;                                     // Move Result
    reg [31:0] calculate_result;
    reg [63:0] mul_result;

    wire [31:0] sum_result;                                     // Sum Result

    wire overflow;
    wire [31:0]cal_data2;                                       // Check src_data2 get complement or not
    wire data1_less_data2;
    wire [31:0]data1_not;
    wire [31:0]mul_data1,mul_data2;
    wire [63:0]hilo_tmp;

    assign cal_data2 = ((alu_op == 8'b00100010) ||
                        (alu_op == 8'b00100011) ||
                        (alu_op == 8'b00101010))? ~(src_data2)+1'b1 : src_data2;
    
    assign sum_result = src_data1 + cal_data2;

    assign data1_less_data2 = (alu_op == 8'b00101010)?
                                ((src_data1[31] && !src_data2[31]) ||                   // data1 < 0 , data2 > 0 -> data1 < data2 
                                (!src_data1[31] && !src_data2 && sum_result[31]) ||     // data1 > 0 , data2 > 0 , sum < 0 -> data1 < data2
                                (src_data1[31] && src_data2[31] && sum_result[31]))         // data1 < 0 , data2 < 0 , sum < 0 -> data1 < data2
                                :(src_data1 < src_data2);

    assign overflow = ((!src_data1[31] && !cal_data2[31]) && sum_result[31]) || ((src_data1[31] && cal_data2[31]) && (!sum_result[31]));
    
    assign mul_data1 = (((alu_op == 8'b10101001)||(alu_op == 8'b00011000)) && (src_data1[31] == 1'b1))? (~src_data1+1):src_data1;
    assign mul_data2 = (((alu_op == 8'b10101001)||(alu_op == 8'b00011000)) && (src_data2[31] == 1'b1))? (~src_data2+1):src_data2;
    assign hilo_tmp = mul_data1 * mul_data2;

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
    always @(*) begin                                           // ADD/SUB/Compare Calculate
        if(reset)begin
            calculate_result <= 32'd0;
        end
        else begin
            case(alu_op)
                8'b00101010,8'b00101011:begin                           // SLT , SLTU
                    calculate_result <= data1_less_data2;
                end
                8'b00100000,8'b00100001,8'b01010101,8'b01010110:begin   // ADD , ADDI , ADDU , ADDIU 
                    calculate_result <= sum_result;
                end
                8'b00100010,8'b00100011:begin                           // SUB , SUBU
                    calculate_result <= sum_result;
                end
                8'b10110000:begin                                       // CLZ
                    /*calculate_result <= (src_data1[31])? 32'd0 : (src_data1[30])? :32'd1 :
                                        (src_data1[29])? 32'd2 : (src_data1[28])? : 32'd3 :
                                        (src_data1[27])? 32'd4 : (src_data1[26])? : 32'd5 :
                                        (src_data1[25])? 32'd6 : (src_data1[24])? : 32'd7 :
                                        (src_data1[23])? 32'd8 : (src_data1[22])? : 32'd9 :
                                        (src_data1[21])? 32'd10 : (src_data1[20])? : 32'd11 :
                                        (src_data1[19])? 32'd12 : (src_data1[18])? : 32'd13 :
                                        (src_data1[17])? 32'd14 : (src_data1[16])? : 32'd15 :
                                        (src_data1[15])? 32'd16 : (src_data1[14])? : 32'd17 :
                                        (src_data1[13])? 32'd18 : (src_data1[12])? : 32'd19 :
                                        (src_data1[11])? 32'd20 : (src_data1[10])? : 32'd21 :
                                        (src_data1[9])? 32'd22 : (src_data1[8])? : 32'd23 :
                                        (src_data1[7])? 32'd24 : (src_data1[6])? : 32'd25 :
                                        (src_data1[5])? 32'd26 : (src_data1[4])? : 32'd27 :
                                        (src_data1[3])? 32'd28 : (src_data1[2])? : 32'd29 :
                                        (src_data1[1])? 32'd30 : (src_data1[0])? : 32'd31 : 32'd32;*/   
                    casez(src_data1)
                        32'b1???????????????????????????????: calculate_result <= 32'd0;
                        32'b01??????????????????????????????: calculate_result <= 32'd1;
                        32'b001?????????????????????????????: calculate_result <= 32'd2;
                        32'b0001????????????????????????????: calculate_result <= 32'd3;
                        32'b00001???????????????????????????: calculate_result <= 32'd4;
                        32'b000001??????????????????????????: calculate_result <= 32'd5;
                        32'b0000001?????????????????????????: calculate_result <= 32'd6;
                        32'b00000001????????????????????????: calculate_result <= 32'd7;
                        32'b000000001???????????????????????: calculate_result <= 32'd8;
                        32'b0000000001??????????????????????: calculate_result <= 32'd9;
                        32'b00000000001?????????????????????: calculate_result <= 32'd10;
                        32'b000000000001????????????????????: calculate_result <= 32'd11;
                        32'b0000000000001???????????????????: calculate_result <= 32'd12;
                        32'b00000000000001??????????????????: calculate_result <= 32'd13;
                        32'b000000000000001?????????????????: calculate_result <= 32'd14;
                        32'b0000000000000001????????????????: calculate_result <= 32'd15;
                        32'b00000000000000001???????????????: calculate_result <= 32'd16;
                        32'b000000000000000001??????????????: calculate_result <= 32'd17;
                        32'b0000000000000000001?????????????: calculate_result <= 32'd18;
                        32'b00000000000000000001????????????: calculate_result <= 32'd19;
                        32'b000000000000000000001???????????: calculate_result <= 32'd20;
                        32'b0000000000000000000001??????????: calculate_result <= 32'd21;
                        32'b00000000000000000000001?????????: calculate_result <= 32'd22;
                        32'b000000000000000000000001????????: calculate_result <= 32'd23;
                        32'b0000000000000000000000001???????: calculate_result <= 32'd24;
                        32'b00000000000000000000000001??????: calculate_result <= 32'd25;
                        32'b000000000000000000000000001?????: calculate_result <= 32'd26;
                        32'b0000000000000000000000000001????: calculate_result <= 32'd27;
                        32'b00000000000000000000000000001???: calculate_result <= 32'd28;
                        32'b000000000000000000000000000001??: calculate_result <= 32'd29;
                        32'b0000000000000000000000000000001?: calculate_result <= 32'd30;
                        32'b00000000000000000000000000000001: calculate_result <= 32'd31;
                        default:calculate_result <= 32'd32;
                    endcase        
                end
                8'b10110001:begin                                       // CLO
                    casez(src_data1)
                        32'b0???????????????????????????????: calculate_result <= 32'd0;
                        32'b10??????????????????????????????: calculate_result <= 32'd1;
                        32'b110?????????????????????????????: calculate_result <= 32'd2;
                        32'b1110????????????????????????????: calculate_result <= 32'd3;
                        32'b11110???????????????????????????: calculate_result <= 32'd4;
                        32'b111110??????????????????????????: calculate_result <= 32'd5;
                        32'b1111110?????????????????????????: calculate_result <= 32'd6;
                        32'b11111110????????????????????????: calculate_result <= 32'd7;
                        32'b111111110???????????????????????: calculate_result <= 32'd8;
                        32'b1111111110??????????????????????: calculate_result <= 32'd9;
                        32'b11111111110?????????????????????: calculate_result <= 32'd10;
                        32'b111111111110????????????????????: calculate_result <= 32'd11;
                        32'b1111111111110???????????????????: calculate_result <= 32'd12;
                        32'b11111111111110??????????????????: calculate_result <= 32'd13;
                        32'b111111111111110?????????????????: calculate_result <= 32'd14;
                        32'b1111111111111110????????????????: calculate_result <= 32'd15;
                        32'b11111111111111110???????????????: calculate_result <= 32'd16;
                        32'b111111111111111110??????????????: calculate_result <= 32'd17;
                        32'b1111111111111111110?????????????: calculate_result <= 32'd18;
                        32'b11111111111111111110????????????: calculate_result <= 32'd19;
                        32'b111111111111111111110???????????: calculate_result <= 32'd20;
                        32'b0111111111111111111110??????????: calculate_result <= 32'd21;
                        32'b11111111111111111111110?????????: calculate_result <= 32'd22;
                        32'b111111111111111111111110????????: calculate_result <= 32'd23;
                        32'b1111111111111111111111110???????: calculate_result <= 32'd24;
                        32'b11111111111111111111111110??????: calculate_result <= 32'd25;
                        32'b111111111111111111111111110?????: calculate_result <= 32'd26;
                        32'b1111111111111111111111111110????: calculate_result <= 32'd27;
                        32'b11111111111111111111111111110???: calculate_result <= 32'd28;
                        32'b111111111111111111111111111110??: calculate_result <= 32'd29;
                        32'b1111111111111111111111111111110?: calculate_result <= 32'd30;
                        32'b11111111111111111111111111111110: calculate_result <= 32'd31;
                        default:calculate_result <= 32'd32;
                    endcase 
                end
                default:begin
                    calculate_result <= 32'd0;
                end
            endcase
        end    
    end

    always @(*) begin
        if(reset)begin
            mul_result <= 64'd0;
        end
        else if((alu_op == 8'b10101001)||(alu_op == 8'b00011000))begin
            if(src_data1[31] ^ src_data2[31])begin
                mul_result <= ~hilo_tmp+1;
            end
            else begin
                mul_result <= hilo_tmp;
            end
        end
        else begin
            mul_result <= hilo_tmp;
        end
    end

    always @(*) begin                                           // Result Select
        out_addr <= wr_addr;
        out_en <= ((alu_op == 8'b00100000 || alu_op == 8'b01010101 || alu_op == 00100010) && overflow)? 1'b0:wr_en;
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
            3'b100:begin
                out_data <= calculate_result;
            end
            3'b101:begin
                out_data <= mul_result[31:0];
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
                8'b00011001,8'b00011000:begin
                    hilo_wr_en <= 1'b1;
                    hi_data <= mul_result[63:32];
                    lo_data <= mul_result[31:0];
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