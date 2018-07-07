module wramp_subsystem(

           input 				rst,

           input 				CLK_50MHZ_IN,		/*System clock */

           input  [ 7 : 0 ] 	switch_in, 			/* Toggle switches */

           input  [ 3 : 0 ] 	btn_in,				/* Push buttons */

           output [ 6 : 0 ] 	ssd_seg_out,		/* SSD single-digit code */

           output [ 3 : 0 ] 	ssd_sel_out			/* SSD iterator */

       );

/* From CPU to memory / io */
wire [ 19 : 0 ] cpu_address;
wire 				 cpu_write_enable;
wire [ 31 : 0 ] cpu_write_value;
reg  [ 31 : 0 ] cpu_read_value;

/* CPU which interfaces with memory */
wramp cpu(
          /* Input */
          .rst					( rst ),
          .clk					( CLK_50MHZ_IN ),
          .mem_read_value		( cpu_read_value ),
          /* Output */
          .mem_address			( cpu_address ),
          .mem_write_enable	( cpu_write_enable ),
          .mem_write_value	( cpu_write_value )
      );



/* Multiplexed based on cpu_address */
wire [ 31 : 0 ] mem_read_value;			/* Value output by memory module */
reg 				 mem_write_enable;		/* Write enable for input to memory module */

memory mem(
           /* Input */
           .clk					( CLK_50MHZ_IN ),
           .mem_address		( cpu_address ),
           .mem_write_enable	( mem_write_enable ),
           .mem_write_value	( cpu_write_value ),
           /* Output */
           .mem_read_value	( mem_read_value )
       );


/* Multiplexed based on cpu_address */
wire [ 7 : 0 ] 	io_sw_status;		/* Value output by io module */
wire [ 3 : 0 ] 	io_btn_status;		/* Value output by io module */
wire [ 31 : 0 ] 	io_ssd_status;		/* Value output by io module */
reg 					ssd_write_enable;	/* Write enable for input to io module */

io i_o(
       /* Input */
       .rst 					( rst ),
       .clk					( CLK_50MHZ_IN ),
       .switch_in			( switch_in ),
       .btn_in				( btn_in ),
       .ssd_write_value	( cpu_write_value ),
       .ssd_write_enable	( ssd_write_enable ),
       /* Output */
       .IO_SWITCH_STATUS	( io_sw_status ),
       .IO_BUTTON_STATUS	( io_btn_status ),
       .IO_SSD_VALUE		( io_ssd_status ),
       .IO_SSD_SEL			( ssd_sel_out ),
       .ssd_display		( ssd_seg_out )
   );


/* Memory-mapped io */
parameter SWITCH_ADDR = 20'h01000;	/* io switch reg */
parameter BTN_ADDR 	 = 20'h01001;	/* io btn reg */
parameter SSD_ADDR    = 20'h01002;	/* io ssd value reg */

/* Multiplex logic based on cpu_address */
always@( * )begin

    /* Reset */
    cpu_read_value = 32'd0;
    mem_write_enable = 1'b0;
    ssd_write_enable = 1'b0;

    /* CPU requests memory block RAM read / write */
    if( cpu_address < SWITCH_ADDR )begin

        cpu_read_value = mem_read_value;
        mem_write_enable = cpu_write_enable;

    end
    /* CPU requests io switch status read */
    else if( cpu_address == SWITCH_ADDR )begin

        cpu_read_value = io_sw_status;

    end
    /* CPU requests io btn status read */
    else if( cpu_address == BTN_ADDR ) begin

        cpu_read_value = io_btn_status;

    end
    /* CPU requests ssd value read / write */
    else if( cpu_address == SSD_ADDR ) begin

        cpu_read_value = io_ssd_status;
        ssd_write_enable = cpu_write_enable;
    end

end // @(*)


endmodule
