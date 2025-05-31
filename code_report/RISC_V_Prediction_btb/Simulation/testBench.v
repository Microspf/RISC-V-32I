`timescale 1ns / 1ps

`define DataRamContentLoadPath "C:\\Users\\spf\\Documents\\GitHub\\RISC-V-32I\\code_report\\RISC_V_Prediction_btb\\Simulation\\SimFiles\\btb.data"
`define InstRamContentLoadPath "C:\\Users\\spf\\Documents\\GitHub\\RISC-V-32I\\code_report\\RISC_V_Prediction_btb\\Simulation\\SimFiles\\btb.inst"
`define DataRamContentSavePath "C:\\Users\\spf\\Documents\\GitHub\\RISC-V-32I\\code_report\\RISC_V_Prediction_btb\\Simulation\\SimFiles\\DataRamContent.txt"
`define InstRamContentSavePath "C:\\Users\\spf\\Documents\\GitHub\\RISC-V-32I\\code_report\\RISC_V_Prediction_btb\\Simulation\\SimFiles\\InstRamContent.txt"
`define BRAMWORDS 4096  //一个字定为4字节，所以BaseRam有4096*4B = 16KB

/*
测试指令的汇编代码：
00: addi x5, x0, 0
04: addi x5, x0, 0
08: addi x6, x0, 0
// x7 是用于比较的常量
0c: addi x7, x0, 3
// 外层循环
10: addi x6, x6, 1
// 每次外层循环开始，重置x5的值
// 内层循环
14: addi x5, x6, 0
18: beq x6,x7, 2 // x6=x7,跳出外层循环
1c: addi x5, x5, 1
// 内层bne共执行3+2+1=6次
// 外层第1次执行前x5=2，内层第一次执行时，BTB中不存在匹配的项，分支成功，存入BTB表中，第二次执行时，BTB中存在匹配的项，分支失败，从BTB中删除对应项
// 外层第2次执行前x5=3，内层第一次执行时，BTB中不存在匹配的项，分支失败，无需操作BTB
20: bne x5,x7, -2
// 第一次运行到20时，理应跳转到1c，但是ex阶段和if阶段需要时钟打拍，共消耗两拍才能把PC更新
// 外层bne共执行3次
// 第1次执行前x6=1，BTB中不存在匹配的项，分支成功，存入BTB表中
// 第2次执行前x6=2，BTB中存在匹配的项，分支成功
// 第3次执行前x6=3，BTB中存在匹配的项，分支失败，删除BTB中对应的项
24: bne x6, x7, -20
28: addi x6, x6, 1
2c: addi x3, x0, 1
*/

module testBench(
    );
    //
    reg CPU_CLK;
    reg CPU_RST;
    reg [31:0] CPU_Debug_DataRAM_A2;
    reg [31:0] CPU_Debug_DataRAM_WD2;
    reg [3:0] CPU_Debug_DataRAM_WE2;
    wire [31:0] CPU_Debug_DataRAM_RD2;
    reg [31:0] CPU_Debug_InstRAM_A2;
    reg [31:0] CPU_Debug_InstRAM_WD2;
    reg [3:0] CPU_Debug_InstRAM_WE2;
    wire [31:0] CPU_Debug_InstRAM_RD2;
    wire [31:0] PC;
    // 时钟信号
    always #1 CPU_CLK = ~CPU_CLK;
    // 连接CPU模块
    RV32Core RV32Core1(
        .CPU_CLK(CPU_CLK),
        .CPU_RST(CPU_RST),
        .CPU_Debug_DataRAM_A2(CPU_Debug_DataRAM_A2),
        .CPU_Debug_DataRAM_WD2(CPU_Debug_DataRAM_WD2),
        .CPU_Debug_DataRAM_WE2(CPU_Debug_DataRAM_WE2),
        .CPU_Debug_DataRAM_RD2(CPU_Debug_DataRAM_RD2),
        .CPU_Debug_InstRAM_A2(CPU_Debug_InstRAM_A2),
        .CPU_Debug_InstRAM_WD2(CPU_Debug_InstRAM_WD2),
        .CPU_Debug_InstRAM_WE2(CPU_Debug_InstRAM_WE2),
        .CPU_Debug_InstRAM_RD2(CPU_Debug_InstRAM_RD2),
        .PC(PC)
        );
    //定义 file handles
    integer LoadDataRamFile;
    integer LoadInstRamFile;
    integer SaveDataRamFile;
    integer SaveInstRamFile;
    //
    integer i;
    //
    initial 
    begin
        $display("Initialing reg values..."); 
        CPU_Debug_DataRAM_WD2 = 32'b0;
        CPU_Debug_DataRAM_WE2 = 4'b0;
        CPU_Debug_InstRAM_WD2 = 32'b0;
        CPU_Debug_InstRAM_WE2 = 4'b0;
        CPU_Debug_DataRAM_A2 = 32'b0;
        CPU_Debug_InstRAM_A2 = 32'b0;
        CPU_CLK=1'b0;
        CPU_RST = 1'b0;
        #10
        
        $display("Loading DataRam Content from file..."); 
        LoadDataRamFile = $fopen(`DataRamContentLoadPath,"r");
        if(LoadDataRamFile==0)
            $display("Failed to Open %s, Do Not Load DataRam values from file!",`DataRamContentLoadPath);
        else    begin  
            CPU_Debug_DataRAM_A2 = 32'h0;     
            $fscanf(LoadDataRamFile,"%h",CPU_Debug_DataRAM_WD2);
            if($feof(LoadDataRamFile))
                CPU_Debug_DataRAM_WE2 = 4'b0;
            else
                CPU_Debug_DataRAM_WE2 = 4'b1111;
            #10
            for(i=0;i<`BRAMWORDS;i=i+1)
            begin
                if($feof(LoadDataRamFile))
                    CPU_Debug_DataRAM_WE2 = 4'b0;
                else
                    CPU_Debug_DataRAM_WE2 = 4'b1111;
                @(negedge CPU_CLK);
                CPU_Debug_DataRAM_A2 = CPU_Debug_DataRAM_A2+4;
                $fscanf(LoadDataRamFile,"%h",CPU_Debug_DataRAM_WD2);
            end
            $fclose(LoadDataRamFile);
        end
        
        $display("Loading InstRam Content from file..."); 
        LoadInstRamFile = $fopen(`InstRamContentLoadPath,"r");
        if(LoadInstRamFile==0)
            $display("Failed to Open %s, Do Not Load InstRam values from file!",`InstRamContentLoadPath);
        else    begin  
            CPU_Debug_InstRAM_A2 = 32'h0;     
            $fscanf(LoadInstRamFile,"%h",CPU_Debug_InstRAM_WD2);
            if($feof(LoadInstRamFile))
                CPU_Debug_InstRAM_WE2 = 4'b0;
            else
                CPU_Debug_InstRAM_WE2 = 4'b1111;
            #10
            for(i=0;i<`BRAMWORDS;i=i+1)
            begin
                if($feof(LoadInstRamFile))
                    CPU_Debug_InstRAM_WE2 = 4'b0;
                else
                    CPU_Debug_InstRAM_WE2 = 4'b1111;
                @(negedge CPU_CLK);
                CPU_Debug_InstRAM_A2 = CPU_Debug_InstRAM_A2+4;
                $fscanf(LoadInstRamFile,"%h",CPU_Debug_InstRAM_WD2);
            end
            $fclose(LoadInstRamFile);
        end
        
        $display("Start Instruction Execution!"); 
        #10;   
        CPU_RST = 1'b1;
        #100;   
        CPU_RST = 1'b0;
        #40000 												// waiting for instruction Execution to End
        $display("Finish Instruction Execution!"); 
        
        $display("Saving DataRam Content to file..."); 
        CPU_Debug_DataRAM_A2 = 32'b0;
        #10
        SaveDataRamFile = $fopen(`DataRamContentSavePath,"w");
        if(SaveDataRamFile==0)
            $display("Failed to Open %s, Do Not Save DataRam values to file!",`DataRamContentSavePath);
        else
        begin
            $fwrite(SaveDataRamFile,"i\tAddr\tAddr\tData\tData\n");
            #10
            for(i=0;i<`BRAMWORDS;i=i+1)
                begin
                @(posedge CPU_CLK);
                $fwrite(SaveDataRamFile,"%4d\t%8h\t%4d\t%8h\t%4d\n",i,CPU_Debug_DataRAM_A2,CPU_Debug_DataRAM_A2,CPU_Debug_DataRAM_RD2,CPU_Debug_DataRAM_RD2);
                CPU_Debug_DataRAM_A2 = CPU_Debug_DataRAM_A2+4;
                end
            $fclose(SaveDataRamFile);
        end
        
        $display("Saving InstRam Content to file..."); 
        SaveInstRamFile = $fopen(`InstRamContentSavePath,"w");
        if(SaveInstRamFile==0)
            $display("Failed to Open %s, Do Not Save InstRam values to file!",`InstRamContentSavePath);
        else
        begin
            CPU_Debug_InstRAM_A2 = 32'b0;
            #10
            $fwrite(SaveInstRamFile,"i\tAddr\tAddr\tData\tData\n");
            #10
            for(i=0;i<`BRAMWORDS;i=i+1)
                begin
                @(posedge CPU_CLK);
                $fwrite(SaveInstRamFile,"%4d\t%8h\t%4d\t%8h\t%4d\n",i,CPU_Debug_InstRAM_A2,CPU_Debug_InstRAM_A2,CPU_Debug_InstRAM_RD2,CPU_Debug_InstRAM_RD2);
                CPU_Debug_InstRAM_A2 = CPU_Debug_InstRAM_A2+4;
                end
            $fclose(SaveInstRamFile);      
        end      

        $display("Simulation Ended!"); 
        $stop();
    end
    
endmodule
