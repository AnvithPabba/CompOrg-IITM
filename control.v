module control(
    input [31:0] idata, //instrcution data 
    output reg [1:0] aluop, //for alucontrol 
    output reg regwrite, //whether we need to write in a register or not 
    output reg [1:0] alusrc, //for selecting inputs to the alu 
    //output [3:0] dwe //for writing into dmem 
    output reg memtoreg, 
    output reg branch, 
    output reg jump 
    
    
    );
    
    always @ (*) begin
        
        //memtoreg
        memtoreg <= (idata[6:0] == 7'b0000011); //only for load
                       
        //aluop
        case(idata[6:0])
            
            7'b1100011: aluop <= 2'b01; //branch
            
            7'b0010011: aluop <= 2'b10; //r-type
            7'b0110011: aluop <= 2'b10; //r-type
            
            default: aluop <= 2'b00;

        endcase
                                    
        //alusrc
        case(idata[6:0])
            
            7'b0010111: alusrc <= 2'b11; //for auipc
            
            7'b0100011: alusrc <= 2'b01; //if immgen is one input to the alu
            7'b0000011: alusrc <= 2'b01;
            7'b0010011: alusrc <= 2'b01;
            7'b0110111: alusrc <= 2'b01; //lui
            
            default: alusrc <= 2'b00;
            
        endcase
        
                
        //regwrite        
        case(idata[6:0])
            
            7'b0110011: regwrite<= 1'b1;
            7'b0000011: regwrite<= 1'b1;
            7'b0010011: regwrite<= 1'b1;
            7'b1101111: regwrite<= 1'b1;
            7'b1100111: regwrite<= 1'b1;
            7'b0010111: regwrite<= 1'b1;
            7'b0110111: regwrite<= 1'b1;
            
            default: regwrite<= 1'b0;

        endcase
                
        //branch
        case(idata[6:0])
            
            7'b1100011: branch<= 1'b1;
            default: branch<= 1'b0;
            
        endcase
        
        //jump
        case(idata[6:0])
            
            7'b1100111: jump<= 1'b1;
            7'b1101111: jump<= 1'b1;
            default: jump<= 1'b0;
            
        endcase

    end
    
endmodule
    
    
    