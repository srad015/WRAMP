module multiplier(

           input 					 clk,

           input 					 rst,

           input 					 en,

           input 	  [ 63 : 0 ] multiplicand_in,

           input 	  [ 31 : 0 ] multiplier_in,

           output reg [ 63 : 0 ] accum,

           output reg 				 fin

       );

/* Iterator 0 - 31 for shift-add multiplier */
reg [ 7 : 0 ] cycle = 0;

reg [ 63 : 0 ] multiplicand;
reg [ 31 : 0 ] multiplier;

always@( posedge clk )begin

    if( rst )begin

        cycle 		 <= 0;
        accum 		 <= 0;
        multiplicand <= 64'd0;
        multiplier 	 <= 32'd0;
        accum 		 <= 64'd0;
        fin 			 <= 0;

    end else
        if( en && !fin )begin

            /* End of multiplication */
            if( multiplier == 32'd0 && cycle != 8'd0 ) begin

                fin <= 1;

            end

            /* First cycle */
            if( cycle == 8'd0 )begin

                multiplicand[ 31 : 0 ] <= ( multiplicand_in << 1 );
                multiplier 				 <= ( multiplier_in >> 1 );

                if(multiplier_in[ 0 ] == 1'b1)
                    accum <= multiplicand_in;

            end
            else begin

                multiplicand <= ( multiplicand << 1 );
                multiplier   <= ( multiplier >> 1 );

                if( multiplier[ 0 ] == 1'b1 )
                    accum <= accum + multiplicand;

            end

            cycle <= cycle + 1;

        end

end
endmodule
