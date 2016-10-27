module ssd_driver(
	
	input             	 smpl,		/* Sample pulse	*/
	
	input 	  [ 15 : 0 ] val_in,		/* Value we need to display over all SSDs	*/
	
	output reg [ 3 : 0 ]  ssd_sel,	/* SSD select corresponding to 1 of the 4 SSDs	*/
	
	output reg [ 6 : 0 ]  num_out		/* Hex value we output to selected SSD	*/
    
	 );

/* SSD hex encodings	*/
localparam ZERO   = 7'b0000001; 
localparam ONE    = 7'b1001111; 
localparam TWO    = 7'b0010010; 
localparam THREE  = 7'b0000110;
localparam FOUR   = 7'b1001100; 
localparam FIVE   = 7'b0100100; 
localparam SIX    = 7'b0100000; 
localparam SEVEN  = 7'b0001111; 
localparam EIGHT  = 7'b0000000; 
localparam NINE   = 7'b0001100;
localparam A		= 7'b0001000;
localparam B	   = 7'b1100000;
localparam C 		= 7'b0110001;
localparam D 		= 7'b1000010;
localparam E 		= 7'b0110000;
localparam F 		= 7'b0111000;

reg [ 6 : 0 ] ssd_hex_enc [ 15 : 0 ];		/* Array of SSD hex encodings	*/

reg [ 3 : 0 ] state = 4'b0001;	/* 4 states corresponding to each of the 4 SSDs	*/


	initial begin 
	
		/* Initialize array	*/
		ssd_hex_enc[ 0 ]  <= ZERO;
		ssd_hex_enc[ 1 ]  <= ONE;
		ssd_hex_enc[ 2 ]  <= TWO;
		ssd_hex_enc[ 3 ]  <= THREE;
		ssd_hex_enc[ 4 ]  <= FOUR;
		ssd_hex_enc[ 5 ]  <= FIVE;
		ssd_hex_enc[ 6 ]  <= SIX;
		ssd_hex_enc[ 7 ]  <= SEVEN;
		ssd_hex_enc[ 8 ]  <= EIGHT;
		ssd_hex_enc[ 9 ]  <= NINE;   
		ssd_hex_enc[ 10 ] <= A;
		ssd_hex_enc[ 11 ] <= B;
		ssd_hex_enc[ 12 ] <= C;
		ssd_hex_enc[ 13 ] <= D;
		ssd_hex_enc[ 14 ] <= E;
		ssd_hex_enc[ 15 ] <= F;
		
  end

	/* Update a single SSD at each sample pulse	*/
	always@( posedge smpl ) begin        

		// Update num_out to correspond to round-robin SSD
		case(state) 

		// Right-most SSD
		4'b0001: begin
			num_out <= ssd_hex_enc[ val_in[ 3 : 0 ] ];
			ssd_sel <= 4'b1110;
			state <= 4'b0010;
		end

		// Middle-right SSD
		4'b0010: begin
		  num_out <= ssd_hex_enc[ val_in[ 7 : 4 ] ];
		  ssd_sel <= 4'b1101;
		  state   <= 4'b0100;
		end

		// Middle-left SSD
		4'b0100: begin
		  num_out <= ssd_hex_enc[ val_in[ 11 : 8 ] ];
		  ssd_sel <= 4'b1011;
		  state   <= 4'b1000;
		end

		// Left-most SSD	
		4'b1000: begin 
		  num_out <= ssd_hex_enc[ val_in[ 15 : 12 ] ];
		  ssd_sel <= 4'b0111;
		  state   <= 4'b0001;
		end  
			  
	endcase
	
	
  end // always
  

endmodule
