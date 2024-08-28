`timescale 1ns/1ps
module openmips_min_sopc_tb();

  reg     clk;
  reg     reset;
  
  initial begin
    $fsdbDumpfile("OpenMIPS");
    $fsdbDumpvars("+mda");
    $fsdbDumpMDA;
  end
       
  initial begin
    clk = 1'b0;
    forever #10 clk = ~clk;
  end
      
  initial begin
    reset = 1'b1;
    #195 reset= 1'b0;
  end
       
  SOPC openmips_min_sopc0(
		.clk(clk),
		.reset(reset)	
	);

  reg [22:0]cycle=0;

  always @(posedge clk ) begin
    cycle = cycle+1;
    if(cycle > 800)begin
      $display("--------------------------------Simulation Complete !--------------------------------");
      $finish;
    end  
  end

endmodule