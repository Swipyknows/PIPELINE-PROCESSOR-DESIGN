`include "pipeline.v"
module pipe2_test;
    wire [7:0] z;
    reg [7:0] rs1, rs2, rd, func;
    reg [3:0] addr;
    reg clk1, clk2;
    integer k;
    pipeline_4 p4(z, rs1, rs2, rd, clk1, clk2, addr, func);
    initial begin
        clk1=0;
        clk2=0;
        repeat(20)
            begin
                #5 clk1=1; #5 clk1=0;
                #5 clk2=1; #5 clk2=0;
            end
    end
    
    initial
        for(k=0;k<16;k=k+1)
            p4.regbank[k] = k; // Initialize register bank
    initial
        for(k=0;k<256;k=k+1)
            p4.mem[k] = 8'b0; // Initialize memory with zeros
    initial begin
        #5 rs1=5; rs2=3; rd=10; func=0; addr=125;
        #20 rs1=3; rs2=2; rd=11; func=1; addr=126;
        #20 rs1=4; rs2=1; rd=12; func=2; addr=127;
        #20 rs1=2; rs2=5; rd=13; func=3; addr=128;
        #20 rs1=1; rs2=4; rd=14; func=4; addr=129;
        #20 rs1=0; rs2=6; rd=15; func=5; addr=130;
        #120;
        for(k=125;k<131;k=k+1)
           $display("Memory[%3d] = %3d", k, p4.mem[k]);
    end
    initial 
        begin
            $dumpfile("pipeline_test.vcd");
            $dumpvars(0, pipe2_test);
            #300;
            $finish;
        end
endmodule