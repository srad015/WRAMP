module alu_ctrl(

           // Flags as to second operand in
           // arithmetic op
           input 						reg_x_reg, reg_x_imm,

           // Flag indicating bnez / beqz instruction
           input 						branch,

           // Flag indicating jump instruction
           input 						jump,

           // Flag indicating lw / sw instruction
           input 						lw_sw,

           // Register reads as possible operands to
           // arithmetic operation
           input [ 31 : 0 ] 		reg_out1, reg_out2,

           // Immediate value from instruction as
           // possible second operand
           input [ 15 : 0 ] 		instr_imm,

           // Memory offset value from instruction
           // as possible operand
           input [ 19 : 0 ] 		instr_offset,

           // Program counter as possible operand
           input [ 19 : 0 ] 		pc,

           // Operands selected for upcoming
           // arithmetic operation
           output reg [ 31 : 0 ] alu_in1, alu_in2

       );


always@(*)begin

    // Reset operands
    alu_in1 = 32'd0;
    alu_in2 = 32'd0;

    if(reg_x_reg)begin

        alu_in1 = reg_out1;
        alu_in2 = reg_out2;

    end
    else if(reg_x_imm) begin

        alu_in1 		= reg_out1;
        alu_in2[15:0] = instr_imm[15:0];



    end
    else if(branch) begin

        alu_in1[19:0] = pc[19:0];
        alu_in2[19:0] = instr_offset[19:0];

    end
    else if(jump) begin

        alu_in1[19:0] = 20'd0;
        alu_in2[19:0] = instr_offset[19:0];

    end
    else if(lw_sw) begin

        alu_in1 		= reg_out1;
        alu_in2[19:0] = instr_offset[19:0];

    end

end // always@

endmodule
