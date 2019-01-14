/*
	Group 09 (E/15/131, E/15/348)
	Simple Processor
*/

// ******** ALU ********
module ALU( RESULT, DATA1, DATA2, SELECT );
	input [7:0] DATA1,DATA2;	//Source 1 & 2	
	input [2:0] SELECT;
	output [7:0] RESULT;
	reg [7:0] Res;
	
	assign RESULT= Res;

	always @(DATA1,DATA2,SELECT)
    	begin
        case ( SELECT )
         0 : Res = DATA1;			//Forward ( loadi, mov )
         1 : Res = DATA1 + DATA2;	//Addition ( add, sub )
         2 : Res = DATA1 & DATA2;	//Bitwise AND ( and )
         3 : Res = DATA1 | DATA2;	//Bitwise OR ( or )
		 4 : Res = DATA1;			//Forward ( load )
		 5 : Res = DATA1;			//Forward ( store )
		default : Res = 0;
        endcase 
    end

endmodule

// ******** Register File ********
module regfile8x8a ( clk, INaddr, IN, OUT1addr, OUT1, OUT2addr, OUT2, busy_wait );
	
	input [2:0] OUT1addr,OUT2addr,INaddr;
	input [7:0] IN;
	input clk;
	input busy_wait;
	output [7:0] OUT1,OUT2;

	reg [63:0] regMemory = 0;
	reg [7:0] OUT1reg, OUT2reg;
	integer i;
	
	assign OUT1 = OUT1reg[7:0];
	assign OUT2 = OUT2reg[7:0];

	always @(posedge clk) begin			//Read at postive edge of Clock
		for(i=0;i<8;i=i+1) begin
			OUT1reg[i] = regMemory[ OUT1addr*8 + i ];
			OUT2reg[i] = regMemory[ OUT2addr*8 + i ];
		end
	end	
	

	always @(negedge clk) begin			//Write at negative edge of Clock
		if ( !busy_wait )begin			//Stall if DM access is happening
			for(i=0;i<8;i=i+1)begin
				regMemory[INaddr*8 + i] = IN[i];
			end
		end
	end

endmodule

// ******** Program Counter ********
module counter(clk, reset, Read_addr, busy_wait );
	input clk;
	input reset;
	input busy_wait;
	output [31:0] Read_addr;
	reg Read_addr;

	always @(negedge clk)
	begin
		if ( !busy_wait ) begin			//Stall if DM access is happening
			case(reset)
				1'b1 : begin Read_addr = 32'd0; end					//Reset if reset = 1
				1'b0 : begin Read_addr = Read_addr + 3'b100; end	//PC = PC + 4, if reset = 0
			endcase
		end
	end
endmodule

// ******** Multiplexer ********
module MUX( OUTPUT, INPUT1, INPUT2, CTRL );
	input [7:0] INPUT1, INPUT2;
	output [7:0] OUTPUT;
	input CTRL;
	reg [7:0] OUTPUT;

	always @( INPUT1, INPUT2, CTRL )
	begin
		case( CTRL )
			1'b0 : begin OUTPUT <= INPUT1; end
			1'b1 : begin OUTPUT <= INPUT2; end
		endcase
	end
endmodule

// ******** 2's Complement ********
module TwosComplement( OUTPUT, INPUT );
	input [7:0] INPUT;
	output [7:0] OUTPUT;

	assign OUTPUT[7:0] = -INPUT[7:0];

endmodule

// ******** Instruction Register ********

//Yet to implement properly
//For now takes instruction as input and returns the same instructions
module Instruction_reg ( clk, Read_Addr, instruction );
	input clk;
	input [31:0] Read_Addr;
	output [31:0] instruction;
	reg instruction;

	always @(negedge clk) 
	begin
	instruction = Read_Addr;
	end
endmodule

// ******** Control Unit ********
module CU( instruction, busy_wait, OUT1addr, OUT2addr, INaddr, Imm, Select, addSubMUX, imValueMUX, dmMUX, read, write, address );
	input [31:0] instruction;
	input busy_wait;
	output [2:0] OUT1addr;
	output [2:0] OUT2addr;
	output [2:0] Select;
	output [2:0] INaddr;
	output [7:0] Imm, address;
	output addSubMUX, imValueMUX, dmMUX, read, write;

	reg [2:0] OUT1addr, OUT2addr, INaddr, Select;
	reg [7:0] Imm, address;
	reg addSubMUX,imValueMUX, dmMUX, read, write;
	
	always @(instruction) begin
		if ( !busy_wait )
		 begin						//Stall if DM access is happening
			assign Select = instruction[26:24];		//Common Signals
			assign Imm = instruction[7:0];
			assign OUT1addr = instruction[2:0];
			assign OUT2addr = instruction[10:8];
			assign INaddr = instruction[18:16];
			assign imValueMUX = 1'b1;
			assign addSubMUX = 1'b0;
			assign write = 1'b0;
			assign read = 1'b0;
			assign dmMUX = 1'b1;
			
			case(instruction[31:24])
				
			8'b00000000 : begin			//loadi
				assign imValueMUX = 1'b0;
				end
			
			8'b00001001 : begin			//sub
				assign addSubMUX = 1'b1;
				end

			8'b00000100 : begin			//load
				assign read = 1'b1;
				assign dmMUX = 1'b0;
				assign address = instruction[7:0];	
			end
			
			8'b00000101: begin			//store
				assign write = 1'b1;
				assign address = instruction[23:16];
			 $display("memory address %d \n",address);

			end		

			endcase
		end
	end
endmodule

// ******** Data Memory ********
module data_mem( clk, rst, read, write, address, write_data, read_data,	busy_wait );
	input clk;
	input rst;
	input read;
	input write;
	input[7:0] address;
	input[7:0] write_data;
	output[7:0] read_data;
	output busy_wait;
	
	reg busy_wait = 1'b0;
	reg[7:0] read_data;

	integer  i;
	
	// Declare memory 256x8 bits 
	reg [7:0] memory_array [255:0];
	//reg [7:0] memory_ram_q [255:0];

	always @(posedge rst)			//Reset Data memory
	begin
		if (rst)
		begin
			for (i=0;i<256; i=i+1)
				memory_array[i] <= 0;
		end
	end
	
	always @( rst, read, write, address, write_data ) begin
		if ( write && !read )			//Write to Data memory
		begin
			busy_wait <= 1;
			//Artificial delay 100 cycles
			repeat(100)
			begin
				@(posedge clk);
			end

			memory_array[address] = write_data;
			busy_wait <= 0;
		end
		if (!write && read) begin		//Read from Data memory
			busy_wait <= 1;
			//Artificial delay 100 cycles
			repeat(100)
			begin
				@(posedge clk);
			end

			read_data = memory_array[address];
			busy_wait <= 0;
		end
	end
	
endmodule

// ******** Processor ********
module Processor( Read_Addr, DataMemMUXout, clk, rst );
	
	input [31:0] Read_Addr;
	input clk,rst;
	output [7:0] DataMemMUXout;
	
	wire [7:0] Result;
	wire [31:0] instruction;
	wire [2:0] OUT1addr,OUT2addr,INaddr,Select;
	wire  [7:0] Imm,OUT1,OUT2,OUTPUT,INPUT,cmp;
	wire [7:0] read_data,address;
	wire [7:0] imValueMUXout, addSubMUXout, DataMemMUXout;
	wire addSubMUX, imValueMUX, dmMUX;
	wire read, write, busy_wait, rst;
	
	Instruction_reg ir1(clk, Read_Addr, instruction);	//Instruction Regiter
	CU cu1( instruction, busy_wait, OUT1addr, OUT2addr, INaddr, Imm, Select, addSubMUX, imValueMUX, dmMUX, read, write, address );	//Control Unit
	regfile8x8a rf1( clk, INaddr, Result, OUT1addr, OUT1, OUT2addr, OUT2, busy_wait );	//Register File
	TwosComplement tcomp( OUTPUT, OUT1 );		//2'sComplement
	MUX addsubMUX( addSubMUXout, OUT1, OUTPUT, addSubMUX );		//2's complement MUX
	MUX immValMUX( imValueMUXout, Imm, addSubMUXout, imValueMUX );	//Imediate Value MUX
	MUX DataMemMUX( DataMemMUXout, read_data ,Result, dmMUX);		//Data Memory MUX 
	ALU alu1( Result, imValueMUXout, OUT2, Select );	//ALU
	data_mem dm( clk, rst, read, write, address, Result, read_data,	busy_wait);	//Data Memory

endmodule


module testDM;
	reg [31:0] Read_Addr;
	wire [7:0] Result;
	reg clk,rst;
	wire read,write;
	Processor simpleP( Read_Addr, Result, clk, rst);

	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end

	initial begin
		$display("\nPrinting The results of MUX that is before register file( output from ALU OR DM )\n");
		rst = 0;
		#20
		rst = 1;
		#20
		rst = 0;
		#20
		Read_Addr = 32'b0000000000000110xxxxxxxx00101101;//loadi r6,X,45
		$display("loadi 6,X,45");
		#20
		$display("After 1 CC	%b | %d\n",Result,Result);
		Read_Addr = 32'b0000000000000011xxxxxxxx01000001;//loadi r3,X,65
		$display("loadi 6,X,45");
		#20
		$display("After 1 CC	%b | %d\n",Result,Result);
		Read_Addr = 32'b0000010100011001xxxxxxxx00000110;//store 25,X,r6
		$display("store 25,X,6");
		#2000
		$display("After 100 CC	%b | %d\n",Result,Result);
		Read_Addr = 32'b0000010100010000xxxxxxxx00000011;//store 16,X,r3
		$display("store 16,X,3");
		#2000
		$display("After 100 CC	%b | %d\n",Result,Result );
		Read_Addr = 32'b0000010000000111xxxxxxxx00011001;//load r7,X,25
		$display("load 7,X,25");
		#20
		$display("After 1 CC	%b | %d",Result,Result);
	 	#180
		$display("After 10 CC	%b | %d",Result,Result);
	 	#800
		$display("After 50 CC	%b | %d",Result,Result);
	 	#1000
		$display("After 100 CC	%b | %d\n",Result,Result);
	 	Read_Addr = 32'b0000010000001000xxxxxxxx00010000;//load r8,X,25
		$display("load 8,X,25");
		#20
		$display("After 1 CC	%b | %d  (Should be 65, new value not loaded. need 100CC)",Result,Result);
		#1980	
		$display("After 100 CC	%b | %d\n",Result,Result);
		Read_Addr = 32'b00000001000001010000011100001000;//add 5,7,8
		$display("add 5,7,8");
		#20
		$display("After 1 CC	%b | %d\n",Result,Result);
		Read_Addr = 32'b00001001000001010000100000000111;//sub 4,8,7
		$display("sub 4,8,7");
		#20
		$display("After 1 CC	%b | %d\n",Result,Result);
		
		$finish;
	end

endmodule


/*
module test;

	reg [31:0] Read_Addr;
	wire [7:0] Result;
	reg clk;
	Processor simpleP( Read_Addr, Result, clk );

	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end
	
	initial begin

	// Operation set 1
	$display("\nOperation      Binary   | Decimal");
	$display("---------------------------------");
	//					00000000
	//							00000000
	//									00000000
	//											00000000
		Read_Addr = 32'b0000000000000100xxxxxxxx11111111;//loadi 4,X,0xFF
	#20
		$display("load r4        %b | %d",Result,Result);
	
		Read_Addr = 32'b0000000000000110xxxxxxxx10101010;//loadi 6,X,0xAA
	#20
		$display("load r6        %b | %d",Result,Result); 
		
		Read_Addr = 32'b0000000000000011xxxxxxxx10111011;//loadi 3,X,0xBB
	#20
		$display("load r3        %b | %d",Result,Result);
		
		Read_Addr = 32'b00000001000001010000011000000011;//add 5,6,3
	#20
		$display("add r5 (r6+r3) %b | %d  ****",Result,Result);

		Read_Addr = 32'b00000010000000010000010000000101;//and 1,4,5
	#20
		$display("and r1 (r4,r5) %b | %d",Result,Result);

		Read_Addr = 32'b00000011000000100000000100000110;//or 2,1,6
	#20
		$display("or r2 (r1,r6)  %b | %d",Result,Result);

		Read_Addr = 32'b0000100000001111xxxxxxxx00000010;//mov 7,X,2
	#20
		$display("copy r7 (r2)   %b | %d",Result,Result);

		Read_Addr = 32'b00001001000001000000111100000011;//sub 4,7,3
	#20
		$display("sub r4 (r7-r3) %b | %d",Result,Result);
		
	// Operation set 2
		
	$display("\nOperation      Binary   | Decimal");
		$display("---------------------------------");

		Read_Addr = 32'b0000000000000100xxxxxxxx00001101;//loadi 4,X,0xFF
	#20
		$display("load r4        %b | %d",Result,Result);
	
		Read_Addr = 32'b0000000000000110xxxxxxxx00101101;//loadi 6,X,0xAA
	#20
		$display("load r6        %b | %d",Result,Result); 

		Read_Addr = 32'b0000000000000011xxxxxxxx00100001;//loadi 3,X,0xBB
	#20
	$display("load r3        %b | %d",Result,Result);

		Read_Addr = 32'b00000001000001010000011000000011;//add 5,6,3
	#20
		$display("add r5 (r3+r6) %b | %d",Result,Result);

		Read_Addr = 32'b00000010000000010000010000000101;//and 1,4,5
	#20
		$display("and r1 (r4,r5) %b | %d",Result,Result);

		Read_Addr = 32'b00000011000000100000000100000110;//or 2,1,6
	#20
		$display("or r2 (r1,r6)  %b | %d",Result,Result);

		Read_Addr = 32'b0000100000001111xxxxxxxx00000010;//mov 7,X,2
	#20
		$display("move r7 (r2)   %b | %d",Result,Result);
	
		Read_Addr = 32'b00001001000001000000111100000011;//sub 4,7,3
	#20
		$display("sub r4 (r7-r3) %b | %d",Result,Result);
	
		$finish;
	end
endmodule
*/







/*
// ******** Test Register File ********
module testregeter;
 
	reg [2:0] INaddr,OUT1addr,OUT2addr;
	reg clk;
	reg [7:0] IN;
	wire [7:0] OUT1,OUT2;
	reg [2:0] SELECT;
	wire [7:0] RESULT;
 
	regfile8x8a regf ( clk, INaddr, IN, OUT1addr, OUT1, OUT2addr, OUT2);
	ALU test( RESULT,OUT1,OUT2,SELECT);

	initial begin
	clk = 1'b0; end
	always #10 clk = ~clk;
 
	initial begin

	#5//T=5
		IN = 12;
		INaddr = 5;
		OUT1addr = 5;
		OUT2addr = 3;

	#10//T=15								
		$display("OUT1 = %d OUT2 = %d",OUT1,OUT2);
	#20//T=35								
		$display("OUT1 = %d OUT2 = %d",OUT1,OUT2);
		IN = 10;
		INaddr = 3;
	#10//T=45
		$display("OUT1 = %d OUT2 = %d",OUT1,OUT2);		
	#10//T=55
		$display("OUT1 = %d OUT2 = %d",OUT1,OUT2);
		SELECT = 1;
	#10//T=65
		$display("%d + %d = %d\n",OUT1,OUT2,RESULT);	

	$finish;

	end
endmodule
 
// ******** Test ALU ********
module testALU;

    reg [7:0] DATA1;
    reg [7:0] DATA2;
    reg [2:0] SELECT;

    wire [7:0] RESULT;

    ALU test( RESULT,DATA1,DATA2,SELECT);
    
    initial begin
        // Apply inputs.
        DATA1 = 45;	//110
        DATA2 = 6;	//011

        SELECT = 0; #100;
	$display("%d\n",RESULT);

        SELECT = 1; #100;
	$display("%d\n",RESULT);        

	SELECT = 2; #100;
	$display("%b & %b = %b\n",DATA1,DATA2,RESULT);

	SELECT = 3; #100;
	$display("%b | %b = %b\n",DATA1,DATA2,RESULT);
    end
      
endmodule
*/
