module registers(
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] wdata,
    input regwrite,
    input clk,
    output [31:0] rv1,
    output [31:0] rv2
    );
    
    //making 32 32-bit registers
    reg [31:0] register[31:0];
    
    
    //initialising registers to 0
    integer i;
    initial begin
        for (i=0;i<32;i=i+1)
            register[i] = 32'b0;
    end
    
    //synchronous change if write enable is 1
    always @ (posedge clk) begin
        //$monitor("x2 = %d:",register[5'd2] );
        if (regwrite == 1'b1) begin
            if (rd != 5'b0) begin //reg 0 should always be 0
                register[rd] <= wdata;
            end
        end
    end
    
    //assigning outputs
    assign rv1 = register[rs1];
    assign rv2 = register[rs2];
        
endmodule
    
            
    
    
    
    
    