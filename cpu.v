/*
NAME - Anvith Pabba
COURSE - ee2003 (COMPUTER ORGANISATION)
ASSIGNMENT - 4
*/


module cpu (
    input clk, //clock
    input reset, //reset
    output [31:0] iaddr, //pc
    input [31:0] idata, //instrcution data
    output [31:0] daddr, //dmem address
    input [31:0] drdata, //data from dmem read
    output [31:0] dwdata, //data to be written to dmem
    output [3:0] dwe //dmem write enable
);
    reg [31:0] iaddr;
    reg [31:0] dwdata;
    reg [3:0]  dwe;
    
    //control
    wire [1:0] alusrc;
    wire [1:0] aluop;
    wire memtoreg;
    wire branch;
    wire jump;
    wire regwrite;
    
    //alucontrol
    wire [3:0] alucon;    
    
    //immgen
    wire [31:0] immgen;
    
    //alu
    wire zero;
    wire [31:0] aluout;
    
    //dmem
    reg [31:0] drdataload;
    
    //register
    wire [31:0] rv1;
    wire [31:0] rv2;
    wire [31:0] rv1_r;
    
    
    wire [31:0] PC_branch;
    assign PC_branch = iaddr + immgen;
    
    wire [31:0] JALR_pc;
    assign JALR_pc = immgen+rv1_r;
    
    //PC counter
    always @(posedge clk) begin
        //$display("rv1 = %d, rv2 = %d, alu = %d, alucon = %b",rv1, immgen, aluout, alucon);
        //$display("JALR_pc = %h, idata = %h, opcode = %b:", JALR_pc, idata, idata[6:0]);  
        //$display("iaddr = %h, idata = %h:", iaddr, idata);         
        if (reset) begin
            iaddr <= 0; //so that next cycle, no instruction hapens
            
        end else begin 
            
            iaddr <= iaddr + 4; //in default case
            
            if(branch) begin
                if( (idata[14:12] == 3'b000 ||idata[14:12] == 3'b101 ||idata[14:12] == 3'b111) && (zero==1'b1) ) begin //beq bge bgeu
                    iaddr <= PC_branch;
                end
                        
                if( (idata[14:12] == 3'b001 ||idata[14:12] == 3'b100 ||idata[14:12] == 3'b110) && (zero==1'b0) ) begin //blt btlu bne
                    iaddr <= PC_branch;
                end           
            end
            
            if(jump) begin
                if( idata[6:0]== 7'b1100111 ) begin //jalr
                    iaddr <= {JALR_pc[31:1], 1'b0};
                end
                        
                if( idata[6:0]== 7'b1101111 ) begin //jal
                    iaddr <= PC_branch;
                end           
            end
    
        end
    end
    
    //instantiating the control module
    control CONTROL(
        .idata(idata),
        .alusrc(alusrc),
        .aluop(aluop),
        .memtoreg(memtoreg),
        .branch(branch),
        .jump(jump),
        .regwrite(regwrite)
        
    );
    
    //instantiating the alu control module
    alucontrol ALUCONTROL(
        .aluop(aluop),
        .funct7(idata[31:25]),
        .funct3(idata[14:12]),
        .idata(idata),
        .alucon(alucon)
    );
    
    //instantiating the sign immediate generating module
    immgen IMMGEN(
        .idata(idata),
        .imm(immgen)
    );
    
    assign rv1 = ((idata[6:0] == 7'b1101111) || (idata[6:0] == 7'b1100111)) ? iaddr+4 : (alusrc[1]) ? iaddr : rv1_r; 
    //for auipc -> pc and for jal/jalr -> pc+4
    
    //instantiating the alu module
    alu ALU(
        .input1(rv1), 
        .input2((alusrc[0]) ? immgen : rv2), 
        .alucon(alucon),
        .zero_(zero),
        .out(aluout)   
    ); 
    
    //instantiating the registers
    registers REGISTERS(
        .rs1( ((idata[6:0] == 7'b1101111) || (idata[6:0] == 7'b0010111) || (idata[6:0] == 7'b0110111)) ? 5'b0 : idata[19:15]), //jal, auipc, lui
        .rs2( ((idata[6:0] == 7'b1101111) || (idata[6:0] == 7'b0010111) || (idata[6:0] == 7'b0110111)  || (idata[6:0] == 7'b1100111)) ? 5'b0 : idata[24:20]), //jalr, auipc, lui, jal
        .rd( (idata[6:0] == 7'b1100011) ? 5'b0 : idata[11:7]), //for branch
        .wdata((memtoreg) ? drdataload : aluout), //only drdataload for load type instructions
        .regwrite(regwrite),
        .clk(clk),
        .rv1(rv1_r),
        .rv2(rv2)
    );
    
    assign daddr= aluout;
        
    always @(idata,daddr) begin
        
        if (idata[6:0] == 7'b0000011) begin //load instructions
            
            case(idata[14:12]) 
                
                3'b000: begin //lb
                    
                    case(daddr[1:0])
                        
                        2'b00: 
                            drdataload <= $signed(drdata[7:0]);
                        2'b01: 
                            drdataload <= $signed(drdata[15:8]);
                        2'b10: 
                            drdataload <= $signed(drdata[23:16]);
                        2'b11: 
                            drdataload <= $signed(drdata[31:24]);
                        default: 
                            drdataload <= 32'b0;
                        
                    endcase
                    
                end
                
                3'b001: begin //lh
                    
                    case(daddr[1:0])
                        
                        2'b00: 
                            drdataload <= $signed(drdata[15:0]);
                        2'b10: 
                            drdataload <= $signed(drdata[31:16]);
                        default: 
                            drdataload <= 32'b0;
                    endcase
                    
                end
                
                3'b010: 
                    drdataload <= drdata; //lw 
                
                3'b100: begin //lbu
                    
                    case(daddr[1:0])
                        
                        2'b00: 
                            drdataload <= drdata[7:0];
                        2'b01: 
                            drdataload <= drdata[15:8];
                        2'b10: 
                            drdataload <= drdata[23:16];
                        2'b11: 
                            drdataload <= drdata[31:24];
                        default: 
                            drdataload <= 32'b0;
                        
                    endcase
                    
                end
                
                3'b101: begin //lhu
                    
                    case(daddr[1:0])
                        
                        2'b00: 
                            drdataload <= drdata[15:0];
                        2'b10: 
                            drdataload <= drdata[31:16];
                        default: 
                            drdataload <= 32'b0;
                        
                    endcase
                    
                end
                
                default: 
                    drdataload <= 32'b0;
                
            endcase
            
        end
        
        else drdataload <= 32'b0;
        

        if (idata[6:0] == 7'b0100011) begin //store instructions
            
            dwdata <= (rv2 << daddr[1:0] *8);
            
            case(idata[14:12])
                
                3'b000: begin //sb

                    case(daddr[1:0])
                        
                        2'b00: 
                            dwe <= 4'b0001;
                        2'b01: 
                            dwe <= 4'b0010;
                        2'b10: 
                            dwe <= 4'b0100;
                        2'b11: 
                            dwe <= 4'b1000;
                        default: 
                            dwe <= 4'b0000;
                        
                    endcase
                    
                end
                
                3'b001: begin //sh
                    
                    case(daddr[1:0])
                        
                        2'b00: 
                            dwe <= 4'b0011;
                        2'b10: 
                            dwe <= 4'b1100;
                        default: 
                            dwe <= 4'b0000;
                        
                    endcase
                    
                end
                
                3'b010: begin //sw
                    
                    case(daddr[1:0])
                        
                        2'b00: 
                            dwe <= 4'b1111;
                        default: 
                            dwe <= 4'b0000;
                        
                    endcase
                    
                end
                default: 
                    dwe <= 4'b0000;
                
            endcase
        end
        
        else 
            dwe <= 4'b0000;
            dwdata <= rv2;
        
    end
        
    
endmodule