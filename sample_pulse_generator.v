module sample_pulse_generator(

	input rst,
	
	input clk,		
  
	output smpl    /* Output pulse */                                                  

  );
	 
  localparam SAMPLE_CNT_MAX = 16'd24999;			/* Clock must posedge this many times for sample pulse */
  reg [ 16 : 0 ] smpl_cnt = SAMPLE_CNT_MAX;		/* Sample pulse ticker */
  
  /* Tick on clock edge */
  always@( posedge clk ) begin 
  
	if(rst)begin 
	
		smpl_cnt <= SAMPLE_CNT_MAX;
		
	end 
	else begin
	
		if( smpl_cnt != 16'd0 ) 
			smpl_cnt <= smpl_cnt - 16'd1;
		else
			smpl_cnt <= SAMPLE_CNT_MAX;
			
	end //ifrst
	
  end //always@
  
  assign smpl = smpl_cnt == 16'd0;					/* Output pulse when ticker is zero */

endmodule
