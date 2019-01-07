
//Verilog module for an ALU
module ALU(DATA1,DATA2,SELECT,RESULT);
    
    //inputs,outputs and internal variables declared here
    input [7:0] DATA1,DATA2;
    input [2:0] SELECT;
    output [7:0] RESULT;
    wire [7:0] operand1,operand2;
    reg [7:0] out;
    
    //Assign A and B to internal variables for doing operations
    assign operand1 = DATA1;
    assign operand2 = DATA2;
    //Assign the output 
    assign RESULT = out;

    //Always block with inputs in the sensitivity list.
    always @(SELECT or operand1 or operand2)
    begin
        case (SELECT)
         0 : out = operand1 ;  //forward
         1 : out = operand1 + operand2; //addition
         2 : out = operand1 & operand2; //bitwise AND 
         3 : out = operand1 | operand2; //bitwise OR            
        endcase 
    end
    
endmodule


//register file
module regfile ( clk, INaddr, IN, OUT1addr, OUT1, OUT2addr, OUT2 );
	
	input [2:0] OUT1addr,OUT2addr,INaddr;
	input [7:0] IN;
	input clk;
	output [7:0] OUT1,OUT2;

	reg [63:0] regMemory = 0;
	reg [7:0] OUT1reg, OUT2reg;
	integer i;
	
	assign OUT1 = OUT1reg[7:0];
	assign OUT2 = OUT2reg[7:0];

	always @(posedge clk) begin
		for(i=0;i<8;i=i+1) begin
			OUT1reg[i] = regMemory[ OUT1addr*8 + i ];
			OUT2reg[i] = regMemory[ OUT2addr*8 + i ];
		end
	end	
	

	always @(negedge clk) begin
		for(i=0;i<8;i=i+1)begin
			regMemory[INaddr*8 + i] = IN[i];
		end		
	end

endmodule



// ******** Program Counter ********
module ProgramCounter(CLK, RESET, ADDR);
	input CLK;
	input RESET;
	output [31:0] ADDR;
	reg ADDR;

	always @(negedge CLK)
	begin
		case(RESET)
			0: begin ADDR = 32'd0; end
			1: begin ADDR = ADDR + 8; end
		endcase
	end
endmodule

// ******** Multiplexer ********
module MUX(IN1, IN2, SELECT,OUT );
	input [7:0] IN1, IN2;
	output [7:0] OUT;
	input SELECT;
	reg [7:0] OUT;

	always @( IN1, IN2, SELECT )
	begin
		case( SELECT )
			0 : assign OUT=IN1;
			1 : assign OUT=IN2;
		endcase
	end
endmodule

// ******** 2's Complement ********
module TwosComp(IN,OUT);
	input signed [7:0] IN;
	output signed [7:0] OUT;

	assign OUT[7:0] =-IN[7:0];

endmodule

// ******** Instruction Register ********
module InsReg(CLK, ADDR, OUT);
	input CLK;
	input [31:0] ADDR;
	output [31:0] OUT;
	reg OUT;

	always @(negedge CLK) 
	begin
	OUT = ADDR;
	end
endmodule

// ******** Control Unit ********
module CU( INS, OUT1addr, OUT2addr, INaddr, IMMEDIATE, SELECT, addSubMUX, imValueMUX );
	input [31:0] INS;
	output [2:0] OUT1addr;
	output [2:0] OUT2addr;
	output [2:0] SELECT;
	output [2:0] INaddr;
	output [7:0] IMMEDIATE;
	output addSubMUX,imValueMUX;

	reg [2:0] OUT1addr,OUT2addr,INaddr,SELECT;
	reg [7:0] IMMEDIATE=0;
	reg addSubMUX,imValueMUX; 

	always @(INS) 
		begin

                                 begin
				 OUT1addr <= INS[2:0];		//
				 OUT2addr <= INS[10:8];		//
				 INaddr <= INS[18:16];		//Destination Address
				 SELECT <= INS[26:24];
				IMMEDIATE <= INS[7:0];	
				end
			case(INS[31:24])

				
			8'b00000000 : begin  //loadi
						//Needed For ALU selection
				 addSubMUX <= 1'b1;				//*****Ignore*****
				 imValueMUX <= 1'b1;				//CS Select Imm Value for ALU
				end
			

			8'b00000001 : begin //add
				 addSubMUX <= 1'b0;				//Select directly from Source 2
				 imValueMUX <= 1'b1;				//Select from Source 1
				end
			8'b00000010 : begin //and
				 addSubMUX <= 1'b0;				//Select directly from Source 2
				 imValueMUX <= 1'b1;				//Select from Source 1
				end
			8'b00000011 : begin //or
				 addSubMUX <= 1'b0;				//Select directly from Source 2
				 imValueMUX <= 1'b1;				//Select from Source 1
				end
			8'b00001000 : begin  //mov
				 addSubMUX <= 1'b0;				//*****Ignore*****
				 imValueMUX <= 1'b1;				//Select from Source 1
				end
			8'b00001001 : begin //sub
				 addSubMUX <= 1'b1;				//2's complements of Source 2
				 imValueMUX <= 1'b1;				//Select from Source 1
				end
			

			endcase
		end
endmodule

// ******** Processor ********
module Processor();
	//
endmodule


module test;

	reg [31:0] ADDR;
	reg CLK;
	wire [7:0] RESULT;

	wire [31:0] INS;
	wire [2:0] OUT1addr,OUT2addr,INaddr,SELECT;
	wire  [7:0] IMMEDIATE,OUT1,OUT2,OUTPUT,IN,cmp;
	wire [7:0] imValueMUXout, addSubMUXout;
	wire addSubMUX, imValueMUX;


	InsReg instuctionReg(CLK, ADDR, INS);
	CU controlUnit( INS, OUT1addr, OUT2addr, INaddr, IMMEDIATE, SELECT, addSubMUX, imValueMUX );
	regfile registerFile( CLK, INaddr, RESULT, OUT1addr, OUT1, OUT2addr, OUT2);
	TwosComp twosComplement( OUT1 , OUTPUT);
	MUX multiplexer1(  OUT1, OUTPUT, addSubMUX,addSubMUXout );
	MUX multiplexer2( IMMEDIATE, addSubMUXout, imValueMUX, imValueMUXout );
	ALU al1( imValueMUXout, OUT2, SELECT,RESULT);
	

initial begin
    CLK = 0;
    forever #10 CLK = ~CLK;
end
 
initial begin

	// Operation set 1
	$display("\nOperation      Binary");
	$display("-----------------------");

	ADDR = 32'b0000000000000100xxxxxxxx11111111;//loadi 4,X,0xFF
#40
    $display("load v1        %b",RESULT);
   
	ADDR = 32'b0000000000000110xxxxxxxx10101010;//loadi 6,X,0xAA
#40
    $display("load v2        %b",RESULT); 
    
	ADDR = 32'b0000000000000011xxxxxxxx10111011;//loadi 3,X,0xBB
#40
	$display("load v3        %b ",RESULT);
    
	ADDR = 32'b00000001000001010000011000000011;//add 5,6,3
#40
    $display("add v4 (v2+v3) %b (Here it's overflow)",RESULT);

	ADDR = 32'b00000010000000010000010000000101;//and 1,4,5
#40
    $display("and v5 (v1,v4) %b",RESULT);

	ADDR = 32'b00000011000000100000000100000110;//or 2,1,6
#40
    $display("or v6 (v5,v2)  %b ",RESULT);

	ADDR = 32'b0000100000001111xxxxxxxx00000010;//mov 7,X,2
#40
    $display("copy v7 (v6)   %b",RESULT);

	ADDR = 32'b00001001000001000000111100000011;//sub 4,7,3
#40
    $display("sub v8 (v7-v3) %b ",RESULT);
    
// Operation set 2
    
//$display("\nOperation      Binary   | Decimal");
//	$display("---------------------------------");

//	ADDR = 32'b0000000000000100xxxxxxxx00001101;//loadi 4,X,0xFF
//#40
  //  $display("load v1        %b | %d",RESULT,RESULT);
   
	//ADDR = 32'b0000000000000110xxxxxxxx00101101;//loadi 6,X,0xAA
#40
    //$display("load v2        %b | %d",RESULT,RESULT); 

	ADDR = 32'b0000000000000011xxxxxxxx00100001;//loadi 3,X,0xBB
#40
   //$display("load v3        %b | %d",RESULT,RESULT);

	ADDR = 32'b00000001000001010000011000000011;//add 5,6,3
#40
    //$display("add v4 (v2+v3) %b | %d",RESULT,RESULT);

	ADDR = 32'b00000010000000010000010000000101;//and 1,4,5
#40
    //$display("and v5 (v1,v4) %b | %d",RESULT,RESULT);

	ADDR = 32'b00000011000000100000000100000110;//or 2,1,6
#40
    //$display("or v6 (v5,v2)  %b | %d",RESULT,RESULT);

	ADDR = 32'b0000100000001111xxxxxxxx00000010;//mov 7,X,2
#40
    //$display("copy v7 (v6)   %b | %d",RESULT,RESULT);
   
   	ADDR= 32'b00001001000001000000111100000011;//sub 4,7,3
#40
    //$display("sub v8 (v7-v3) %b | %d",RESULT,RESULT);
   
    $finish;
end
endmodule

