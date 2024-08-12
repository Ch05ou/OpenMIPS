module reg_file(
    input clk,reset,wr_en,rd1_en,rd2_en,
    input [31:0]wr_data,
    input [4:0]wr_addr,addr1,addr2,
    output reg [31:0]out_data1,out_data2
);
    //---------------------------------------------------------------//
    // Register Read is using nono-blocking                          //
    //        -> because it need to get data immediatly              //
    // Register 0 : $0 always zero                                   //
    //---------------------------------------------------------------//
    reg [31:0]register_file[31:0];
    integer i;

    always @(posedge clk) begin
        if(reset)begin
            for(i=0;i<32;i=i+1)begin
                register_file[i] <= 31'd0;
            end        
        end
        else begin
            register_file[wr_addr] <= (wr_en)? wr_data:register_file[wr_addr];
        end
    end

    always @(*) begin
        if(reset || ~rd1_en)begin
            out_data1 <= 32'd0;
        end
        else begin
            if(addr1 == wr_addr && wr_en)begin
                out_data1 <= wr_data;
            end
            else if(addr1 == 32'd0)begin
                out_data1 <= 32'd0;
            end
            else begin
                out_data1 <= register_file[addr1];
            end
        end
    end

    always @(*) begin
        if(reset || ~rd2_en)begin
            out_data2 <= 32'd0;
        end
        else begin
            if(addr2 == wr_addr && wr_en)begin
                out_data2 <= wr_data;
            end
            else if(addr2 == 32'd0)begin
                out_data2 <= 32'd0;
            end
            else begin
                out_data2 <= register_file[addr2];
            end
        end
    end

endmodule