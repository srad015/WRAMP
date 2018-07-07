module memory(

           input 						clk,

           input      [ 19 : 0 ] 	mem_address,				/* Address to read / write */

           input 	  [ 31 : 0 ] 	mem_write_value,			/* Value to write if enabled  */

           input 						mem_write_enable,			/* Flag enabling sequential write */

           output reg [ 31 : 0 ] 	mem_read_value				/* Output from sequential read */

       );

/* 32-bit WORD count of our block RAM */
parameter MEM_SIZE = 1024;


/* Declare our memory as an array of 32-bit words */
reg [ 31 : 0 ] memory[ 0 : ( MEM_SIZE-1 ) ];

/* Initialise our block RAM */
integer i;

initial begin

    for ( i = 0; i < MEM_SIZE; i = i + 1 )
        memory[i] <= 0;

    /*
    Initialize our calculator programme

    $1 : buttons
    $2 : switches
    $3 : accum
    $4 : btn_ctr
    $5 : branch_chk	
    $8 : ctr_max
    */

    /* Initialize ctr_max */
    memory[ 20'h00000 ] <= 32'h1800ffff; // addi $8, $0, 0xffff
    memory[ 20'h00001 ] <= 32'h1880ffff; // addi $8, $8, 0xffff

    /* Read buttons */
    memory[ 20'h00002 ] <= 32'h81001001; // lw $1 <= mem[0x0 + 0x1001]

    /* if ( btns == 0 ) btn_ctr = 0 */
    memory[ 20'h00003 ] <= 32'ha0100001; // beqz $1, 0x2

    /* Iterate btn_ctr */
    memory[ 20'h00004 ] <= 32'h14400001; // addi $4, $4, 0x1

    /* Skip reset */
    memory[ 20'h00005 ] <= 32'h40000007; // J : PC <= 7

    /* Reset btn_ctr */
    memory[ 20'h00006 ] <= 32'h14000000; // addi $4, $0, 0x0

    /* Check btn_ctr against ctr_max */
    memory[ 20'h00007 ] <= 32'h054f0008; // xor $5, $4, $8

    /* if ( btn_ctr_chk == 0 ) skip loop */
    memory[ 20'h00008 ] <= 32'ha0500001; // beqz $5, 0x1

    /* Loop to start */
    memory[ 20'h00009 ] <= 32'h40000000; // J : PC <= 0x0

    /* Reset ctr for next loop */
    memory[ 20'h0000a ] <= 32'h14000000; // addi $4, $0, 0x0

    /* Read switches */
    memory[ 20'h0000b ] <= 32'h82001000; // lw $2 <= mem[0x0 + 0x1000]

    /* Read accum */
    memory[ 20'h0000c ] <= 32'h83001002; // lw $3 <= mem[0x0 + 0x1002]

    /* Reset operation */
    memory[ 20'h0000d ] <= 32'h151f0001; // xor $5, $1, 0x1
    memory[ 20'h0000e ] <= 32'hb0500001; // bnez $5, 0x1
    memory[ 20'h0000f ] <= 32'h13000000; // addi $1, $0, 0x0

    /* Addition operation */
    memory[ 20'h00010 ] <= 32'h151f0008; // xor $5, $1, 0x8
    memory[ 20'h00011 ] <= 32'hb0500001; // bnez $5, 0x1
    memory[ 20'h00012 ] <= 32'h03200003; // add $3, $2, $3

    /* Subtraction operation */
    memory[ 20'h00013 ] <= 32'h151f0004; // xor $5, $1, 0x4
    memory[ 20'h00014 ] <= 32'hb0500001; // bnez $5, 0x1
    memory[ 20'h00015 ] <= 32'h03320002; // sub $3, $3, $2

    /* Multiplication operation */
    memory[ 20'h00016 ] <= 32'h151f0002; // xor $5, $1, 0x2
    memory[ 20'h00017 ] <= 32'hb0500001; // bnez $5, 0x1
    memory[ 20'h00018 ] <= 32'h03350002; // mult $3, $3, $2

    /* Store result of operation to accum */
    memory[ 20'h00019 ] <= 32'h93001002; // sw $3, 1002($0)

    /* Loop to start */
    memory[ 20'h0001a ] <= 32'h40000000; // J : PC <= 0x0

end // initial

/* Sequential read / write */
always @ ( posedge clk ) begin

    /* Write */
    if( mem_write_enable ) begin

        memory[ mem_address ] <= mem_write_value;

    end

    /* Read */
    mem_read_value <= memory[ mem_address ];

end // @( posedge clk )


endmodule
