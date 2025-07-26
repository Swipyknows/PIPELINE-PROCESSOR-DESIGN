module pipeline_4(zout,rs1,rs2,rd,clk1,clk2,addr,func);
    input [7:0] rs1,rs2,rd,func;
    input [3:0] addr;
    input clk1, clk2; //two phased clock
    output [7:0] zout;

    reg [15:0] L12_A, L12_B, L23_Z, L34_Z;
    reg [7:0] L12_addr, L23_addr, L34_addr;
    reg [3:0] L12_func, L23_rd, L12_rd;

    reg [15:0] regbank [0:15];
    reg [15:0] mem [0:255];

    assign zout = L34_Z;
    always @(posedge clk1) begin
        // Stage 1: Read from registers
        L12_A <= #2 regbank[rs1];
        L12_B <= #2 regbank[rs2];
        L12_rd <= #2 rd;
        L12_addr <= #2 addr;
        L12_func <= #2 func;   /*stage 1*/
    end
    always @(negedge clk2) begin
        // Stage 2: Perform operation
        case (L12_func)
            4'b0000: L23_Z <= #2 L12_A + L12_B; // ADD
            4'b0001: L23_Z <= #2 L12_A - L12_B; // SUB
            4'b0010: L23_Z <= #2 L12_A & L12_B; // AND
            4'b0011: L23_Z <= #2 L12_A; // SELA
            4'b0100: L23_Z <= #2 L12_B; // SELB
            4'b0101: L23_Z <= #2 ~L12_A;        // NOT
            4'b0110: L23_Z <= #2 L12_A | L12_B; // OR
            4'b0111: L23_Z <= #2 L12_A ^ L12_B; // XOR
            4'b1000: L23_Z <= #2 mem[L12_addr]; // LOAD
            4'b1001: mem[L12_addr] <= #2 L12_A; // STORE
            default: L23_Z <= #2 16'h0000;      // Default case
        endcase
        L23_addr <= #2 L12_addr;
        L23_rd <= #2 L12_rd; /*stage 2*/
     end
    always @(posedge clk1) //stage 3
        begin
            regbank[L23_rd] <= #2 L23_Z; // Write back to register
            L34_Z <= #2 L23_Z; // Pass the result to the next stage
            L34_addr <= #2 L23_addr; // Pass the address
        end
    always @(negedge clk2) 
        begin
            $display("Memory[%3d] = %3d", L34_addr, L34_Z);
            mem[L34_addr] <= #2 L34_Z; // Write back to memory --stage 4
        end
endmodule
        

