module div(
	input clk,
	input reset,
	input sign,
	input [31:0]opdata1,
	input [31:0]opdata2,
	input start,
	input cancel,
	output reg[63:0]result,
	output reg ready
);
    localparam div_free = 2'b00;
    localparam div_by_zero = 2'b01;
    localparam div_on = 2'b10;
    localparam div_end = 2'b11;

	wire[32:0] div_temp;
	reg[5:0] cnt;
	reg[64:0] dividend;
	reg[1:0] state;
	reg[31:0] divisor;	 
	reg[31:0] temp_op1;
	reg[31:0] temp_op2;
	
	assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};


	always @ (posedge clk) begin
		if (reset) begin
			state <= div_free;
			ready <= 1'b0;
			result <= {32'h00000000,32'h00000000};
		end 
        else begin
            case (state)
                div_free:begin
                    if(start && cancel == 1'b0)begin
                        if(opdata2 == 32'h00000000) begin
                            state <= div_by_zero;
                        end 
                        else begin
                            state <= div_on;
                            cnt <= 6'b000000;
                            if(sign == 1'b1 && opdata1[31] == 1'b1 )begin
                                temp_op1 = ~opdata1 + 1;
                            end 
                            else begin
                                temp_op1 = opdata1;
                            end
                            if(sign == 1'b1 && opdata2[31] == 1'b1 )begin
                                temp_op2 = ~opdata2 + 1;
                            end 
                            else begin
                                temp_op2 = opdata2;
                            end
                            dividend <= {32'h00000000,32'h00000000};
                            dividend[32:1] <= temp_op1;
                            divisor <= temp_op2;
                        end
                    end 
                    else begin
                        ready <= 1'b0;
                        result <= {32'h00000000,32'h00000000};
                    end          	
                end
                div_by_zero:begin
                    dividend <= {32'h00000000,32'h00000000};
                    state <= div_end;		 		
                end
                div_on:begin
                    if(cancel == 1'b0) begin
                        if(cnt != 6'b100000) begin
                            if(div_temp[32] == 1'b1) begin
                                dividend <= {dividend[63:0] , 1'b0};
                            end 
                            else begin
                                dividend <= {div_temp[31:0] , dividend[31:0] , 1'b1};
                            end
                            cnt <= cnt + 1;
                        end 
                        else begin
                            if((sign == 1'b1) && ((opdata1[31] ^ opdata2[31]) == 1'b1)) begin
                                dividend[31:0] <= (~dividend[31:0] + 1);
                            end
                            if((sign == 1'b1) && ((opdata1[31] ^ dividend[64]) == 1'b1)) begin              
                                dividend[64:33] <= (~dividend[64:33] + 1);
                            end
                            state <= div_end;
                            cnt <= 6'b000000;            	
                        end
                    end 
                    else begin
                        state <= div_free;
                    end	
                end
                div_end:begin
                    result <= {dividend[64:33], dividend[31:0]};  
                    ready <= 1'b1;
                    if(start == 1'b0) begin
                        state <= div_free;
                        ready <= 1'b0;
                        result <= {32'h00000000,32'h00000000};       	
                    end		  	
                end
            endcase
		end
	end
endmodule