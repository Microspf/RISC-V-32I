`timescale 1ns / 1ps
// 冒险处理单元
module HarzardUnit( 
    input wire CpuRst, ICacheMiss, DCacheMiss, 
    input wire BranchE, JalrE, JalD, BranchPredictedE,
    input wire [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
    input wire [1:0] RegReadE,
    input wire [2:0] MemToRegE, RegWriteM, RegWriteW,
    output reg StallF, FlushF, StallD, FlushD, StallE, FlushE, StallM, FlushM, StallW, FlushW,
    output reg [1:0] Forward1E, Forward2E
    );
    //
    //存储和刷新信号生成
    always @ (*)
        if(CpuRst)
            {StallF,FlushF,StallD,FlushD,StallE,FlushE,StallM,FlushM,StallW,FlushW} <= 10'b0101010101;
        else if(DCacheMiss | ICacheMiss)
            {StallF,FlushF,StallD,FlushD,StallE,FlushE,StallM,FlushM,StallW,FlushW} <= 10'b1010101010;
        else if((BranchPredictedE ^ BranchE) | JalrE) //BranchPredictedE ^ BranchE为1表示预测结果与实际跳转结果不同
            {StallF,FlushF,StallD,FlushD,StallE,FlushE,StallM,FlushM,StallW,FlushW} <= 10'b0001010000;
        else if(MemToRegE & ((RdE==Rs1D)||(RdE==Rs2D)) )
            {StallF,FlushF,StallD,FlushD,StallE,FlushE,StallM,FlushM,StallW,FlushW} <= 10'b1010010000;
        else if(JalD)
            {StallF,FlushF,StallD,FlushD,StallE,FlushE,StallM,FlushM,StallW,FlushW} <= 10'b0001000000;
        else
            {StallF,FlushF,StallD,FlushD,StallE,FlushE,StallM,FlushM,StallW,FlushW} <= 10'b0000000000;
    //Forward Register Source 1
    always@(*)begin
        if( (RegWriteM!=3'b0) && (RegReadE[1]!=0) && (RdM==Rs1E) &&(RdM!=5'b0) )
            Forward1E<=2'b10;
        else if( (RegWriteW!=3'b0) && (RegReadE[1]!=0) && (RdW==Rs1E) &&(RdW!=5'b0) )
            Forward1E<=2'b01;
        else
            Forward1E<=2'b00;
    end
    //Forward Register Source 2
    always@(*)begin
        if( (RegWriteM!=3'b0) && (RegReadE[0]!=0) && (RdM==Rs2E) &&(RdM!=5'b0) )
            Forward2E<=2'b10;
        else if( (RegWriteW!=3'b0) && (RegReadE[0]!=0) && (RdW==Rs2E) &&(RdW!=5'b0) )
            Forward2E<=2'b01;
        else
            Forward2E<=2'b00;
    end      
endmodule
