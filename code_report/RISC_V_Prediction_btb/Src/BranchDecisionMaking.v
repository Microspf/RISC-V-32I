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
//分支预测
    `BEQ:    if(Operand1==Operand2)      BranchE<=1'b1;  //BEQ
            else                        BranchE<=1'b0;
    `BNE:    if(Operand1!=Operand2)      BranchE<=1'b1;  //BNE
            else                        BranchE<=1'b0;   
    `BLT:    if(Operand1S<Operand2S)     BranchE<=1'b1;  //BLT
            else                        BranchE<=1'b0;
    `BLTU:   if(Operand1<Operand2)       BranchE<=1'b1;  //BLTU
            else                        BranchE<=1'b0;
    `BGE:    if(Operand1S>=Operand2S)    BranchE<=1'b1;  //BGE
            else                        BranchE<=1'b0;
    `BGEU:   if(Operand1>=Operand2)      BranchE<=1'b1;  //BGEU
            else                        BranchE<=1'b0;
    default:                            BranchE<=1'b0;  //NOBRANCH                            
    endcase
endmodule
