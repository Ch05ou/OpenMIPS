`timescale 1ns/1ps
module openmips_min_sopc_tb();

  reg     CLOCK_50;
  reg     rst;
  
  initial begin
    $fsdbDumpfile("OpenMIPS");
    $fsdbDumpvars("+mda");
    $fsdbDumpMDA;
  end
       
  initial begin
    CLOCK_50 = 1'b0;
    forever #10 CLOCK_50 = ~CLOCK_50;
  end
      
  initial begin
    rst = 1'b1;
    #195 rst= 1'b0;
    #1000 $stop;
  end
       
  SOPC openmips_min_sopc0(
		.clk(CLOCK_50),
		.reset(rst)	
	);

  reg [22:0]cycle=0;

  always @(posedge CLOCK_50 ) begin
    cycle = cycle+1;
    if(cycle > 50)begin
      $display("--------------------------------Simulation Complete !--------------------------------");
      $finish;
    end  
  end

endmodule