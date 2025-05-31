`timescale 1ns / 1ps

`include "Parameters.v"   
module BranchDecisionMaking(
    input wire [2:0] BranchTypeE,
    input wire [31:0] Operand1,Operand2,
    output reg BranchE
    );
wire signed [31:0] Operand1S = $signed(Operand1);
wire signed [31:0] Operand2S = $signed(Operand2);
    //
    always@(*)
    case(BranchTypeE)
//是否有分支
    `BEQ:    if(Operand1==Operand2)      BranchE<=1'b1;  //BEQ
            else                        BranchE<=1'b0;
    `BNE:    if(Operand1!=Operand2)      BranchE<=1'b1;  //BNE
            else                        BranchE<=1'b0;   
    default:                            BranchE<=1'b0;  //NOBRANCH                            
    endcase
endmodule
