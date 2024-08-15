module ctrl(
    input reset,
    input id_stall,ex_stall,
    output reg[5:0]stall_en
);
    // stall_en[0] -> PC stall
    // stall_en[1] -> pipe-id stall 
    // stall_en[2] -> id stall
    // stall_en[3] -> ex stall
    // stall_en[4] -> pipe-ex stall
    // stall_en[5] -> mem stall
    always@(*)begin
        if(reset)begin
            stall_en <= 6'b000000;
        end
        else if(id_stall)begin
            stall_en <= 6'b001111;
        end
        else if(ex_stall)begin
            stall_en <= 6'b000111;
        end
        else begin
            stall_en <= 6'b000000;
        end
    end
endmodule