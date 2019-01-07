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

module regfile ( clk, INaddr, IN, OUT1addr, OUT1, OUT2addr, OUT2);
	input [2:0] OUT1addr,OUT2addr,INaddr;
	input [7:0] IN;
	input clk;
	output [7:0] OUT1,OUT2;

	reg [7:0] reg1 =0;
	reg [7:0] reg2 =0;
	reg [7:0] reg3 =0;
	reg [7:0] reg4 =0;
	reg [7:0] reg5 =0;
	reg [7:0] reg6 =0;
	reg [7:0] reg7 =0;
	reg [7:0] reg8 =0;
	reg [7:0] res1;
	reg [7:0] res2;
	assign OUT1=res1;
	assign OUT2=res2;
	
	
	always @(negedge clk) begin
		
		case(INaddr)
		 
		 1: reg1=IN;
		 2: reg2=IN;
		 3: reg3=IN;
		 4: reg4=IN;
		 5: reg5=IN;
		 6: reg6=IN;
		 7: reg7=IN;
		 8: reg8=IN;
		 
		endcase
		
	end	
	

	always @(posedge clk) begin
		
		case(OUT1addr)
		 
		 1: res1=reg1;
		 2: res1=reg2;
		 3: res1=reg3;
		 4: res1=reg4;
		 5: res1=reg5;
		 6: res1=reg6;
		 7: res1=reg7;
		 8: res1=reg8;
		 
		endcase	
		case(OUT2addr)
		 
		 1: res2=reg1;
		 2: res2=reg2;
		 3: res2=reg3;
		 4: res2=reg4;
		 5: res2=reg5;
		 6: res2=reg6;
		 7: res2=reg7;
		 8: res2=reg8;
		 
		endcase	
			
			
	end

endmodule

// ******** Multiplexer ********
module MUX(IN1,IN2, SELECT,OUT );
	input [7:0] IN1, IN2;
	output [7:0] OUT;
	input SELECT;
	reg [7:0] OUT;

	always @( IN1, IN2, SELECT )
	begin
		case( SELECT )
			0 :  OUT <= IN1;
			1 :  OUT <= IN2; 
		endcase
	end
endmodule

// ******** 2's Complement ********
module TwosComp(IN,OUT);
	input [	7:0] IN;
	output [7:0] OUT;
	assign OUT =-IN;

endmodule

// ******** Control Unit ********
module ControlUnit( INS, OUT1addr, OUT2addr, DESTINATION, IMMEDIATE, SELECT, twosCompMux, imValueMux );
	input [31:0] INS;
	output [2:0] OUT1addr;
	output [2:0] OUT2addr;
	output [2:0] SELECT;
	output [2:0] DESTINATION;
	output [7:0] IMMEDIATE;
	output  twosCompMux,imValueMux;

	reg [2:0] OUT1addr,OUT2addr,DESTINATION,SELECT;
	reg [7:0] IMMEDIATE;
	reg  twosCompMux,imValueMux; 
	always @(INS) 
		begin
			begin
                            
				SELECT <= INS[26:24];
				 IMMEDIATE <= INS[7:0];
				 OUT1addr <= INS[2:0];
				 OUT2addr <= INS[10:8];
				 DESTINATION <= INS[18:16];
 				  twosCompMux <= 0;
				 imValueMux <= 1; //load immediate value				
				
			end	
 				
			case(INS[31:24])

			8'b00000000 : begin //load
				 imValueMux <= 0;				//Select from Source 1
				end
			8'b00001001 : begin //subtraction
				  twosCompMux <= 1;				//2's complements of Source 2
				end
			
			endcase
		end
endmodule

module control_unit_testbench;

	reg CLK;
	wire [7:0] RESULT;
	reg [31:0] INS;
	wire [2:0] OUT1addr,OUT2addr,INaddr,SELECT;
	wire  [7:0] IMMEDIATE,OUT1,OUT2,OUT,IN;
	wire [7:0] immediateValue, addSubMUXout;
	wire addSubMUX, imValueMUX;


      //GET the clock period
    	initial begin
    	CLK = 1'b0;
	 end
    	always #10 CLK = ~CLK;
 
	//ControlUnit( INS, OUT1addr, OUT2addr, INaddr, IMMEDIATE, SELECT, addSubMUX, imValueMUX );
	ControlUnit CU( INS, OUT1addr, OUT2addr, INaddr, IMMEDIATE, SELECT, addSubMUX, imValueMUX );
	//regfile ( clk, INaddr, IN, OUT1addr, OUT1, OUT2addr, OUT2);
	regfile regFile( CLK, INaddr, RESULT, OUT1addr, OUT1, OUT2addr, OUT2 );
	//TwosComp(IN,OUT);
	TwosComp twosComp(OUT1 ,OUT);
	//MUX(IN1,IN2, SELECT,OUT );
	MUX source1mux( OUT1, OUT, addSubMUX, addSubMUXout );
	MUX source2mux( IMMEDIATE, addSubMUXout, imValueMUX,immediateValue);
	//ALU(DATA1,DATA2,SELECT,RESULT);
	ALU myAlu( immediateValue, OUT2, SELECT,RESULT );
	
initial begin

	INS = 32'b0000000000000100xxxxxxxx11111111;
#40
    $display("load x        %b",RESULT);
   
	INS = 32'b0000000000000110xxxxxxxx10101010;
#40
    $display("load y        %b",RESULT); 
    
	INS = 32'b0000000000000011xxxxxxxx10111011;
#40
	$display("load z        %b",RESULT);
    
	INS = 32'b00000001000001010000011000000011;
#40
    $display("p=y+z         %b",RESULT);

	INS = 32'b00000010000000010000010000000101;
#40
    $display("q=x & p       %b",RESULT);

	INS = 32'b00000011000000100000000100000110;
#40
    $display("r=q | y       %b",RESULT);

	INS = 32'b0000100000001111xxxxxxxx00000010;
#40
    $display("s = r         %b",RESULT);

	INS = 32'b00001001000001000000111100000011;
#40
    $display("w=s-z         %b",RESULT);
    
   
    $finish;
end
endmodule




