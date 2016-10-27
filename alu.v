/*
 * alu.sv - arithmetic logic unit
 * Serge Radinovich
 * 1298923
 */

module alu(

  input clk,
  
  // Flag indicationg +, -, |, ...
  input	     [ 3 : 0 ]	 func,
  
  // Operands
  input	     [ 31 : 0 ] a, b,
  
  // Output
  output reg  [ 31 : 0 ] out,
  
  // Multiplication finish flag
  output      				 mult_fin,
  
  // Multiplication enable flag
  output 	  				 mult_en_
  
 );

  reg 	mult_en  = 0;
  assign mult_en_ = mult_en;

  reg  [ 63 : 0 ] multiplicand;
  reg  [ 31 : 0 ] multiplier;
  wire [ 63 : 0 ] accum;
  
  /* Shift-add multiplier */
  multiplier mult(
    .clk					(clk),
    .rst					(!mult_en),
    .en					(mult_en),
    .multiplicand_in (multiplicand),
    .multiplier_in	(multiplier),
    .accum				(accum),
    .fin					(mult_fin)
  );
  
	always @( * ) begin

		out = 32'd0;
      mult_en = 1'b0;
	   multiplicand = 64'd0;
	   multiplier = 32'd0;

		case (func)

			4'd0 : out = a + b;	

			4'd2 : out = a - b;	
			
			4'd11: out = a & b;		

			4'd13: out = a | b;
			 
			4'd14: out = b << 16;  

			4'd15: out = a ^ b;	
			
			4'd5: begin 

			 if(!mult_en && !mult_fin) begin 
			 
				mult_en 				  = 1;
				multiplicand[63:32] = 32'd0;
				multiplicand[31:0]  = a;
				multiplier 			  = b;
				
			 end
			 
			 if(mult_fin) begin 

				mult_en = 0;
				out 	  = accum[31:0];

			 end 
			 
			end

		endcase
  
  end // always@

endmodule