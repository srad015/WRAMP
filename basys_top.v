module basys_top(
   
    input				 CLK_50MHZ_IN,					/* System clock */

    input  [ 7 : 0 ]  SWITCH_IN,						/* Toggle switches */

    input  [ 3 : 0 ]  BUTTON_IN,						/* Push buttons */

    output [ 7 : 0 ]  LED_OUT,						/* LEDs */

    output [ 6 : 0 ]  SEVENSEG_SEG_OUT,			/* SSD single-digit code */
	 
    output        	 SEVENSEG_DP_OUT,				
	 
    output [ 3 : 0 ]  SEVENSEG_DIGIT_SEL_OUT		/* SSD iterator */
   );
	
	
	/* Generate initial reset pulse */
	reg [ 3 : 0 ] rst = 4'b1111;
	always @( posedge CLK_50MHZ_IN ) begin
		 
		 rst <= rst >> 1;
		 
	end


	/* WRAMP sub-system */
	wire [ 6 : 0 ] ssd_seg_out;		/* Value to assign to selected SSD */
	wire [ 3 : 0 ] ssd_sel_out;		/* Selected SSD */
	wramp_subsystem wramp_ss(		
		/* Input */
		.rst				( rst[ 0 ] ),
		.CLK_50MHZ_IN	( CLK_50MHZ_IN ),
		.switch_in		( SWITCH_IN ),
		.btn_in			( BUTTON_IN ),
		/* Output */
		.ssd_seg_out	( ssd_seg_out ),
		.ssd_sel_out	( ssd_sel_out )
	);

	/* Output to BaSys */
	assign LED_OUT = SWITCH_IN;
	assign SEVENSEG_DP_OUT = 1'b1;

	assign SEVENSEG_SEG_OUT = ssd_seg_out;
	assign SEVENSEG_DIGIT_SEL_OUT = ssd_sel_out;

endmodule
