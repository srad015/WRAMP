module wramp (

           input         			 rst,

           input         			 clk,

           input 		 [ 31 : 0 ]  mem_read_value,		/* Incoming value from memory block or io */

           output reg [ 19 : 0 ]  mem_address,			/* Address of value requested by CPU */

           output reg      		 mem_write_enable,	/* Enable write to memory block or io ssd value */

           output reg [ 31 : 0 ]  mem_write_value	   /* Value written to memory block or io ssd value */

       );

/* Instruction register */
reg [ 31 : 0 ] ir;

/* Program counter */
reg [ 19 : 0 ] ctr = 0;

/* Nets to transfer instruction to ctrl_unit */
wire [ 3  : 0 ] op_code;
wire [ 3  : 0 ] func;
wire [ 3  : 0 ] rs;
wire [ 3  : 0 ] rt;
reg  [ 3  : 0 ] rd;
wire [ 15 : 0 ] imm;
wire [ 19 : 0 ] offset;
reg  [ 3  : 0 ] jr_idx;
wire 				jal;
wire 				jr;
reg 				reg_write2;

/* Asynch assign above nets */
always@( * ) begin

    if( jal && reg_write2 )
        rd = 4'hF;
    else if( jr )
        rd = jr_idx;
    else
        rd = ir[ 27 : 24 ];

end
assign op_code  = ir[ 31 : 28 ];
assign rs       = ir[ 23 : 20 ];
assign func     = ir[ 19 : 16 ];
assign rt       = ir[ 3  : 0  ];
assign imm      = ir[ 15 : 0  ];
assign offset	= ir[ 19 : 0  ];

/* Flags set by ctrl_unit / alu_ctrl*/
wire [ 3 : 0 ]  func_out;
wire 				beqz;
wire 				bnez;
wire 				lw;
wire 				sw;
wire 				jump;
wire 				reg_x_reg;
wire 				reg_x_imm;
wire 				reg_write;

/* States in our FSM */
parameter FETCH_A   = 4'd0;
parameter FETCH_B   = 4'd1;
parameter FETCH_C   = 4'd2;
parameter DECODE    = 4'd3;
parameter EXECUTE_A = 4'd4;
parameter EXECUTE_B = 4'd5;
parameter EXECUTE_C = 4'd6;

/* Declare state variables */
reg [3:0] state = FETCH_A;
reg [3:0] next  = FETCH_B;

/* Values read from register file
  (may or may not be used in alu) */
wire [ 31 : 0 ] reg_out1;
wire [ 31 : 0 ] reg_out2;
wire [ 31 : 0 ] reg_out3;

/* Control unit which sets flags
   for our data path */
ctrl_unit ctrl(
              /* Input */
              .op_code		( op_code ),
              .func_in		( func ),
              /* Output */
              .func_out	( func_out ),
              .beqz			( beqz ),
              .bnez			( bnez ),
              .reg_x_reg	( reg_x_reg ),
              .reg_x_imm	( reg_x_imm ),
              .lw			( lw ),
              .sw			( sw ),
              .reg_write	( reg_write ),
              .jump			( jump ),
              .jal			( jal ),
              .jr			( jr )
          );



wire [ 31 : 0 ] alu_out;				/* Result of our alu */
reg  [ 31 : 0 ] write_data;			/* Intermediary register for writing to register file on next clk edge */
reg  [ 31 : 0 ] write_data2;		/* LW write */

/* Inputs to our alu (set in alu_ctrl) */
wire [ 31 : 0 ] alu_in1;
wire [ 31 : 0 ]	alu_in2;

/* Control for alu (select arguments) */
alu_ctrl alu_ctrl_(
             /* Input */
             .reg_x_reg		( reg_x_reg ),
             .reg_x_imm		( reg_x_imm ),
             .branch			( bnez || beqz ),
             .jump				( jump ),
             .lw_sw			( sw || lw ),
             .reg_out1		( reg_out1 ),
             .reg_out2		( reg_out2 ),
             .instr_imm		( imm ),
             .instr_offset	( offset ),
             .pc				( ctr ),
             /* Output */
             .alu_in1			( alu_in1 ),
             .alu_in2			( alu_in2 )
         );

/* Flags for multi-cycle multiplier */
wire mult_fin;
wire mult_en;
/* Perform arithmetic */
alu alu_(
        /* Input */
        .clk			( clk ),
        .func			( func_out ),
        .a				( alu_in1 ),
        .b				( alu_in2 ),
        /* Output */
        .out			( alu_out ),
        .mult_fin	( mult_fin ),
        .mult_en_	( mult_en )
    );

/* Multiplex our write inputs */
wire [31:0]wr_muxd = reg_write == 1 ? write_data : write_data2;

/* Register file */
reg_file rf(
             .clk			( clk ),
             .rd_idx1		( rs ),
             .rd_idx2		( rt ),
             .rd_idx3		( rd ),
             .rd_data1	( reg_out1 ),
             .rd_data2	( reg_out2 ),
             .rd_data3	( reg_out3 ),
             .reg_write	( reg_write || reg_write2 ),
             .wr_idx		( rd ),
             .wr_data		( wr_muxd )
         );


/* Combinational FSM updates */
always @( * ) begin

    /* Reset */
    next = state;

    case (state)

        FETCH_A: next = FETCH_B;
        FETCH_B: next = FETCH_C;
        FETCH_C: next = DECODE;

        DECODE: begin
            if(!mult_en || mult_fin)begin
                next = EXECUTE_A;
            end else begin
                next = DECODE;
            end
        end

        EXECUTE_A: next = EXECUTE_B;
        EXECUTE_B: next = EXECUTE_C;
        EXECUTE_C: next = FETCH_A;

    endcase
end // @(*)


/* Sequential FSM block */
always@( posedge clk )begin

    /* Reset */
    if ( rst )begin

        state <= FETCH_A;
        ctr 	<= 0;

    end else begin

        /* Update current state */
        state <= next;

        if( state == DECODE )
            write_data <= alu_out;

        /* Fetch */
        if( state == FETCH_A || state == FETCH_C ) begin

            reg_write2 <= 0;

            mem_write_enable <= 0;

            /* Request read from memory block at ctr */
            if( state == FETCH_A ) begin

                mem_address[19:0] <= ctr[19:0];

            end
            else if(state == FETCH_C) begin

                /* Read next instruction we requested from memory */
                ir[31:0] <= mem_read_value[31:0];
                /* Increment ctr */
                ctr 	 <= ctr + 20'd1;

            end // else if

        end // if(fetch)
        /* Execute */
        else if( state == EXECUTE_A || state == EXECUTE_C )begin

            /* Store word */
            if( sw )begin

                /* Request write to memory */
                mem_address 	  <= alu_out[ 19 : 0 ];
                mem_write_enable <= 1;
                mem_write_value  <= reg_out3;

            end
            /* Load word */
            else if( lw && !reg_write2 ) begin


                if( state == EXECUTE_A )begin

                    /* Request read  */
                    mem_address[ 19 : 0 ] <= alu_out[ 19 : 0 ];

                end else if( state == EXECUTE_C ) begin

                    /* Store into register */
                    reg_write2  <= 1;
                    write_data2 <= mem_read_value;

                end

            end
            /* Jump */
            else if(jump && !jal && !jr) begin

                ctr <= alu_out[ 19 : 0 ];

            end
            /* Jump and link */
            else if( jal && !reg_write2 ) begin

                ctr         <= alu_out[ 19 : 0 ];

                reg_write2  <= 1;
                write_data2 <= ctr;

            end
            /* Jump register */
            else if( jr ) begin

                if( state == EXECUTE_A )begin

                    /* Read register */
                    jr_idx <= alu_out[ 3 : 0 ];

                end else if( state == EXECUTE_C ) begin

                    /* Update ctr */
                    ctr <= reg_out3[ 19 :0] ;

                end

            end
            /* Branch */
            else if( beqz || bnez ) begin

                if( ( !reg_out1 && beqz ) || (reg_out1 && bnez) )
                    ctr <= write_data[ 19 : 0 ];

            end
        end //if(execute)

    end




end //always
////////////////////////////////////////////////////

endmodule
