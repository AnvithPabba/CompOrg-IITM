module alu(
    input [31:0] input1,
    input [31:0] input2,
    input [3:0] alucon,
    output reg zero_,
    output reg [31:0] out
    );
    
    always @ (*) begin
        //$display("%d",input1);
        case (alucon)
            
            4'b0000 : out <= input1 + input2; //add 
            4'b1000 : out <= input1 - input2; //sub 
            4'b0001 : out <= input1 << input2; //sll 
            4'b0101 : out <= input1 >> input2; //srl 
            4'b0010 : out <= $signed(input1) < $signed(input2); //slt 
            4'b0011 : out <= input1 < input2; //sltu 
            4'b0100 : out <= input1 ^ input2; //xor 
            4'b0110 : out <= input1 | input2; //or 
            4'b0111 : out <= input1 & input2; //and 
            4'b1101 : out <= $signed(input1) >>> input2; //sra
            default : out <= 32'b0;
        
        endcase
            
        if(out == 0) begin
            zero_ <= 1'b1;                
        end else begin
            zero_ <= 1'b0;
        end
            
    end 
            
endmodule
    