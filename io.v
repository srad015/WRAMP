module io(

	input 					 rst,	
	
	input 					 clk,	
	
	input 	  [ 7 : 0 ]  switch_in,	
	
	input 	  [ 3 : 0 ]  btn_in,	

	input      [ 31 : 0 ] ssd_write_value,
		
	input 					 ssd_write_enable,

	output reg [ 7 : 0 ]  IO_SWITCH_STATUS,
	
	output reg [ 3 : 0 ]  IO_BUTTON_STATUS,
	
	output 	  [ 6 : 0 ]  ssd_display,
	
	output 	  [ 3 : 0 ]  IO_SSD_SEL,
	
	output reg [ 31 : 0 ] IO_SSD_VALUE

  );


	wire smpl;
	sample_pulse_generator smpl_gen(
		/* Input */
		.rst	( rst ),
		.clk	( clk ),
		/* Output */
		.smpl	( smpl )
	);
	
	ssd_driver driv(
		/* Input */
		.smpl		( smpl ),
		.val_in	( IO_SSD_VALUE[ 15 : 0 ] ),
		/* Output */
		.ssd_sel ( IO_SSD_SEL ),
		.num_out ( ssd_display )
	);
	
	/* Update registers on clk */
	always @ ( posedge clk ) begin 
	
			/* Read btn and switches */
			IO_SWITCH_STATUS <= switch_in;
			IO_BUTTON_STATUS <= btn_in;
			
			/* Write to SSD value */
			if( ssd_write_enable )
				IO_SSD_VALUE <= ssd_write_value;
			
	end


endmodule
