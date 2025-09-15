`timescale 1ns/1ps
module sinc3_tb;

  reg MCLK;
  reg MDAT;
  reg RST;
  reg [1:0] MODE;
  wire [15:0] SNCOUT;
  wire ENBL;

  reg inp;  
  integer i;
  integer num_points, interval, time_stop;
  integer file;

  sinc3 uut (
    .MCLK(MCLK),
    .MDAT(MDAT),
    .SNCOUT(SNCOUT),
	.MODE(MODE),
    .ENBL(ENBL),
    .RST(RST)
  );

  initial begin
    file = $fopen("delta_sigma_output.txt", "r");

    $fscanf(file, "%d\n", num_points);
    $fscanf(file, "%d\n", interval);
    $fscanf(file, "%d\n", time_stop);
	
	MODE = 3;
    MCLK = 0;
    RST = 0;
	i = 0;
	
	#(2 * interval);
    RST = 1;

    #(time_stop)
    $stop;
  end

  always #(interval) MCLK = ~MCLK;

  always @(posedge MCLK) begin
    if (i < num_points) begin  
      $fscanf(file, "%b\n", inp);
	  MDAT <= inp;
    end else begin
	  $fclose(file);
	  MDAT = 0;
	end
  end

endmodule
