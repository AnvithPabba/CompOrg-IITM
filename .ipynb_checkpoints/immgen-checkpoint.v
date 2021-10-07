module immgen(
    input [31:0] idata,
    output reg [31:0] imm
    );
    
    always @ (*) begin
        
        //$display("%d :",imm);
        
        case (idata[6:0])
            
            //U-type
            7'b0110111, //LUI
            7'b0010111: //AUIPC
                imm <= {idata[31:12], 12'd0};
                        
            //J-type
            7'b1101111: //JAL
                imm <= {{12{idata[31]}}, idata[19:12], idata[20], idata[30:21], 1'b0};
                        
            //B-type
            7'b1100011: //BEQ BNE BLT BGE BLTU BGEU 
                imm <= {{20{idata[31]}}, idata[7], idata[30:25], idata[11:8], 1'b0};  
                        
            //S-type
            7'b0100011: //SB SH SW
                imm <= {{20{idata[31]}}, idata[31:25], idata[11:7]};
                        
            //I-type
            7'b1100111: //JALR        
                imm <= {{20{idata[31]}},idata[31:20]};
                    
            7'b0000011: //LB LH LW LBU LHU
                case (idata[14:12])
                    
                    3'b000, //LB LH LW LBU LHU
                    3'b001,
                    3'b010,
                    3'b100,
                    3'b101:
                        imm <= {{20{idata[31]}},idata[31:20]};
                    default:
                        imm <= 32'b0;
                endcase
                    
            7'b0010011: //
                        
                case (idata[14:12])
                    
                    3'b000, //ADDI SLTI SLTIU XORI ORI ANDI
                    3'b010,
                    3'b011,
                    3'b100,
                    3'b110,
                    3'b111:
                        imm <= {{20{idata[31]}},idata[31:20]};
                    
                    3'b001, //SLLI SRLI SRAI 
                    3'b101:
                        imm <= {{27{1'b0}},idata[24:20]};
                    default:
                        imm <= 32'b0;
                endcase
                    
            default: //R-type
                imm <= 32'b0;
            
        endcase
    end
endmodule
    