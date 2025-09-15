/* ----- Toshiba Electronic Devices & Storage Corporation -----  */ 
/* SINC3 Digital filter example with VerilogHDL for TLP7830/7930 */ 
 
module sinc3 (MCLK, MDAT, RST, MODE, SNCOUT, ENBL);

input MCLK, MDAT;          /* Output of TLP7830/7930 */ 
input RST;
input [1:0] MODE;                 /* Filter reset signal */  
output reg [15:0] SNCOUT;  /* SINC3 filter output with 16bit */ 
output reg ENBL;            /* SNCOUT Enable signal */ 

wire [15:0] DEC, DEC_HALF;

reg [34:0] acc0,acc1,acc2,acc3,acc3_prev; 
reg [34:0] dif1,dif2,dif3,dif1_prev,dif2_prev; 
/* Registor for Accumlation and Differentiation */ 
 
reg [15:0] mclkcnt; /* MCLK Counter */ 
reg decclk; /* CLK by decimation rating based */

assign DEC = MODE[1] ? (MODE[0] ? 2048 : 1024) : (MODE[0] ? 512 : 256);
assign DEC_HALF = DEC >> 1;
 
/* ---------- 3 times Accumulation ---------- */ 
always@(MDAT)
begin 
	if(MDAT == 0) 
		acc0 <= 35'd0; 
	else 
		acc0 <= 35'd1;
end
//assign acc0=(!MDAT)?0:1; 
  
always@(negedge MCLK or negedge RST) 
begin 
	if(!RST) 
	begin /* Initialization */ 
		acc1 <= 35'd0; 
		acc2 <= 35'd0; 
		acc3 <= 35'd0; 
	end 
	else 
	begin /* Accumulation */ 
		acc1 <= acc1 + acc0; 
		acc2 <= acc2 + acc1; 
		acc3 <= acc3 + acc2; 
	end 
end 
 
/* ---------- Decimation clock gen ---------- */ 
always@(posedge MCLK or negedge RST) //counter from 0~255
begin 
	if(!RST) 
		mclkcnt <= 16'd0; 
	else if ( mclkcnt == (DEC - 1) ) 
		mclkcnt <= 16'd0; 
	else 
		mclkcnt <= mclkcnt +16'b1; 
end 
 
always@( posedge MCLK or negedge RST ) 
begin 
	if(!RST) 
		decclk <= 1'b0; 
	else begin 
		if ( mclkcnt == (DEC_HALF - 1) ) //134=1
			decclk <= 1'b1; 
		else if ( mclkcnt == DEC - 1) 
			decclk <= 1'b0; 
	end 
end 

/* ---------- 3 times Differntiation ---------- */ 
always@(posedge decclk or negedge RST) 
begin 
	if(!RST) 
	begin /* Initialization */ 
		acc3_prev <= 35'd0; 
		dif1_prev <= 35'd0; 
		dif2_prev <= 35'd0; 
		dif1 <= 35'd0; 
		dif2 <= 35'd0; 
		dif3 <= 35'd0; 
	end else begin /* Differentiation */ 
		dif1 <= acc3 - acc3_prev; 
		dif2 <= dif1 - dif1_prev; 
		dif3 <= dif2 - dif2_prev; 
		acc3_prev <= acc3; 
		dif1_prev <= dif1; 
		dif2_prev <= dif2; 
	end 
end 
 
/* ---------- Output bit number will be set to 16bits ---------- */ 
always@(posedge decclk) 
begin 
	case(MODE)
	  0:SNCOUT <= (dif3[24:10] == 17'h10000) ? 16'hFFFF : dif3[23:8];
	  1:SNCOUT <= (dif3[27:10] == 17'h10000) ? 16'hFFFF : dif3[26:11]; 
	  2:SNCOUT <= (dif3[30:10] == 17'h10000) ? 16'hFFFF : dif3[29:14]; 
	  3:SNCOUT <= (dif3[33:10] == 17'h10000) ? 16'hFFFF : dif3[32:17]; 
	endcase
end 
 
/* ---------- Making Enable signal ---------- */ 
always@(posedge MCLK or negedge RST ) 
begin 
	if (!RST) 
	begin /* Initialization */ 
		ENBL <= 1'b0; 
	end else begin /* Making Enable signal */ 
		if ( mclkcnt == (DEC_HALF - 1)) 
		begin 
			ENBL <= 1'b1; 
		end 
		else 
			ENBL <= 1'b0; 
	end 
end 
endmodule 