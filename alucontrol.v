module alucontrol(
    input [1:0] aluop,
    input [6:0] funct7,
    input [2:0] funct3,
    input [31:0] idata,
    output reg [3:0] alucon
    );
    
    always @ (*) begin
        
        alucon <= 4'b1010; //since 4'b1010 hasnt been used
        
        if (aluop == 2'b00) begin //Load and Store
            alucon <= 4'b0000; //same as add
        end
                 
        if (aluop == 2'b01) begin //branch type
            case (funct3)
            3'b000: alucon<=4'b1000; //this is bge, which is sub
            3'b001: alucon<=4'b1000;
            3'b100: alucon<=4'b0010; //this is blt, which is slt
            3'b101: alucon<=4'b0010;
            3'b110: alucon<=4'b0011; //this is bltu, which is sltu (unsigned)
            3'b111: alucon<=4'b0011;
            endcase   
        end
        
        if (aluop == 2'b10) begin //R-type instructions
            if (idata[6:0] == 7'b0010011 && (funct3 != 3'b001) && (funct3 != 3'b101) ) begin
                alucon[2:0] <= funct3[2:0];
                alucon[3] <= idata[5];
            end
            
            else begin
                alucon[2:0] <= funct3[2:0];
                alucon[3] <= funct7[5];
            end
            
        end
        
    end
    
endmodule