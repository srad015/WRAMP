
module ctrl_unit(  
  
  // Which operation current instruction requested
  input  	 [ 3 : 0 ]	op_code,
  
  // Which function current instruction requested
  input  	 [ 3 : 0 ] 	func_in,
  
  // Some instructions require a change to function
  output reg [ 3 : 0 ] 	func_out,
  
  // Flags regarding alu operands
  output reg 				reg_x_reg, reg_x_imm,
  
  // Flags regarding branching instructions
  output reg				beqz, bnez,
  
  // Flags regarding memory read / write
  output reg				lw, sw, 
  
  // Flag regarding register write
  output reg				reg_write, 
  
  // Flag regarding PC jump
  output reg				jump,
  
  output reg				jal,
  
  output reg 				jr
  
);

  always @( * ) begin
	/* Reset */
	beqz	    <= 1'b0;
	bnez	    <= 1'b0;
	lw		    <= 1'b0;
	sw		    <= 1'b0;
	reg_write <= 1'b0;
   jump	    <= 1'b0;
   jal		 <= 1'b0;
   jr	       <= 1'b0;
   reg_x_reg <= 1'b0;
   reg_x_imm <= 1'b0;
   func_out  <= 4'd0;
             
	case (op_code)
          
		 /* reg x reg */
       4'b0000: begin 
          	
		 	reg_write <= 1'b1;
			reg_x_reg <= 1'b1;
			func_out  <= func_in;
            
       end

       /* reg x imm */
       4'b0001: begin  
            
			reg_write <= 1'b1;
			reg_x_imm <= 1'b1;
			func_out  <= func_in;
            
       end

       /* load hi word */
		 4'b0011: begin 

			reg_x_imm <= 1'b1;
			reg_write <= 1'b1;
			func_out  <= func_in;
			
		 end 

       /* load word */
		 4'b1000: begin
			
			 lw  	 	 <= 1'b1;
			 func_out <= 4'b0000; // Set to +
			
		 end

		 /* store word */
		 4'b1001: begin	
			  
			 sw 		 <= 1'b1;
			 func_out <= 4'b0000; // Set to +
			
		 end

		 /* jump */
		 4'b0100: begin	
			
			 jump 	 <= 1'b1;
			 func_out <= 4'b0000; // Set to +
			
		 end
		 
		 /* jump register */
		 4'b0101: begin 
			
			jr 		<= 1'b1;
			jump 		<= 1'b1;
			func_out <= 4'b0000; // Set to +
			
		 end
		 
		 /* jump and link */
		 4'b0110: begin
			jump 		<= 1'b1;
			jal 		<= 1'b1;            
			func_out <= 4'b0000; // Set to +
		 end

		 /* beqz */
		 4'b1010: begin	
			
			beqz 		<= 1'b1;
			func_out <= 4'b0000; // Set to +
			
		 end

		 /* bnez */
		 4'b1011: begin	
		 
			 bnez 	 <= 1'b1;
			 func_out <= 4'b0000; // Set to +
			
		 end

   endcase

 end // always@
endmodule