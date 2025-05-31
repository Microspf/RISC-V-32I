`timescale 1ns / 1ps
// next PC生成
module NPC_Generator(
    input wire [31:0] PCF,JalrTarget, BranchTarget, JalTarget, BranchPredictedTargetF,PCE,
    input wire BranchE,JalD,JalrE,BranchPredictedF,BranchPredictedE,
    output reg [31:0] PC_In
    );
    always @(*)
    begin
        if(JalrE) // jump
            PC_In <= JalrTarget;
        else if(BranchE && ~BranchPredictedE) //预测不跳转但实际跳转
            PC_In <= BranchTarget;
		else if(~BranchE && BranchPredictedE) //预测跳转但实际不跳转
			PC_In <= PCE + 4;
        else if(JalD) // jump
            PC_In <= JalTarget;
        else if(BranchPredictedF) // 预测跳转且实际跳转
			PC_In <= BranchPredictedTargetF;
		else
            PC_In <= PCF + 4;
    end
endmodule
