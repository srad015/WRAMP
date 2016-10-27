/*
 * reg_file.sv - 16 x 32-bit Register File
 * Serge Radinovich
 * 1298923
 */

module reg_file(
  
  input 				   clk,
  
  // Indices into register file for
  // register reads
  input   [ 3 : 0 ]	rd_idx1, rd_idx2, rd_idx3,
 
  // Flags indicating write operations
  // Only one flag set at a time
  input 				   reg_write,
  
  // Index into register that should be written to
  input 	[ 3 : 0 ]	wr_idx,
  
  // Data that should be written to register
  input 	[ 31 : 0 ]	wr_data,
  
  // Output data from register read requests
  output [ 31 : 0 ]	rd_data1, rd_data2, rd_data3

);

	/*  Registers in our reg file */
	reg [ 31 : 0 ] mem [ 0 : 15 ]; 
  
	/* Asynch reads */
	assign rd_data1 = rd_idx1 == 4'd0 ? 32'd0 : mem[ rd_idx1 ][ 31 : 0 ];
	assign rd_data2 = rd_idx2 == 4'd0 ? 32'd0 : mem[ rd_idx2 ][ 31 : 0 ];
	assign rd_data3 = rd_idx3 == 4'd0 ? 32'd0 : mem[ rd_idx3 ][ 31 : 0 ];

	/* Sequential write */
	always @( posedge clk ) begin
		
		/* Write during execution stage and only if requested */
		if ( reg_write && wr_idx != 4'd0 ) begin
		
		  mem[wr_idx] <= wr_data;
		  
		end 
		
	end
endmodule

