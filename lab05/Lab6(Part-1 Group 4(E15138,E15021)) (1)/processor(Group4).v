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
         4:  out=operand1; // load 
		 5:  out=operand1; // store 
		endcase 
    end
    
endmodule

module regfile ( clk, INaddr, IN, OUT1addr, OUT1, OUT2addr, OUT2 ,busy_wait) ;
	input [7:0] OUT1addr,OUT2addr;
	input [7:0] IN,INaddr;
	input clk,busy_wait;
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
	
// writing
	always @(negedge clk) begin
		if(busy_wait==0)
		begin
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
	end	
	
// reading
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
module ControlUnit( INS, OUT1addr, OUT2addr, IN_ADDR, IMMEDIATE, SELECT, twosCompMux, imValueMux, writeRegMux,read,write,DATA_ADDR ,busy_wait);
	input [31:0] INS;//get the 32 bit instruction 
	input busy_wait; // signal from memory to stall
	
	output [7:0] OUT1addr;//output1 address 
	output [7:0] OUT2addr;//output2 address
	output [2:0] SELECT;//select signal for alu
	output [7:0] IN_ADDR;// input address for register file
	output [7:0] IMMEDIATE;// immediate value from instruction
	output [7:0] DATA_ADDR;//Read or Write data address in memory
	output  twosCompMux,imValueMux,writeRegMux; //multiplexer controls
	output read,write; // read write signal for memory

	reg [2:0] SELECT; 
	reg [7:0] OUT1addr,OUT2addr,IMMEDIATE,IN_ADDR;
	reg [7:0] DATA_ADDR;
	reg  twosCompMux,imValueMux,writeRegMux;
	reg read,write; 
		
	always @(INS)   begin //begin for always  
		 if(busy_wait==0)
			begin  //begin if            
				 SELECT <= INS[26:24]; // get alu control
				 IMMEDIATE <= INS[7:0]; // get immediate value
				 OUT1addr <= INS[7:0]; // output 1 address for reg file
				 OUT2addr <= INS[15:8]; // output 2 address for reg file
				 IN_ADDR <= INS[23:16];//input address for register file (including load word)
 				 twosCompMux <= 0; // mux select for 2's complement
				 imValueMux <= 1; //load immediate value				
				writeRegMux<=0;// get the alu RESULT as default
				read<=0;// no read from memory (default)
 				write<=0;// no write from memory (default)
				DATA_ADDR<=INS[7:0];// read data address for load
					
			case(INS[31:24])

			8'b00000000 : begin //load
				 imValueMux <= 0;				//Select from Source 1
				end
			8'b00001001 : begin //subtraction
				  twosCompMux <= 1;				//2's complements of Source 2
				end
			
			8'b00000100 : begin			//load
				 read <= 1; // send read signal to memory
				 writeRegMux<=1; // change the input address mux for reg file
			end
			8'b00000101: begin			//store
				 write <= 1;// send write signal to memory 
				 DATA_ADDR<=INS[23:16]; // send the location of the memory to write
			end
			endcase

		end
		end // end for always
endmodule

module data_mem(clk,rst,read,write,address,write_data,read_data,busy_wait);
input           clk;
input           rst;
input           read;
input           write;
input[7:0]      address;
input[7:0]      write_data;
output[7:0]     read_data;
output			busy_wait;

reg[7:0]     read_data;
reg busy_wait=1'b0;
integer  i;

// Declare memory 256x8 bits 
reg [7:0] memory_array [255:0];
//reg [7:0] memory_ram_q [255:0];

always @(posedge rst)
begin
    if (rst)
    begin
        for (i=0;i<256; i=i+1)
            memory_array[i] <= 0;
    end
end

always @(rst, read, write, address, write_data)
begin
    if (write && !read)
	begin
		busy_wait <= 1;
	repeat(100)
			begin
				@(posedge clk);
			end
        memory_array[address] = write_data;
		busy_wait <= 0;
	end
    if (!write && read)
	begin
		busy_wait <= 1;
	repeat(100)
			begin
				@(posedge clk);
			end
        read_data = memory_array[address];
		busy_wait <= 0;
	end
end
 
endmodule


module processor(clk,finalOut,rst,INS);

	input clk,rst; // clock for the processor and memory reset signal
 	input [31:0] INS; //instruction
	
	output [7:0] finalOut; //output after the multiplexer in reg file 
	
	wire [7:0] RESULT;
	wire [2:0] SELECT;
	wire  [7:0] OUT1addr,OUT2addr,IMMEDIATE,OUT1,OUT2,OUT,IN,INaddr;
	wire [7:0] immediateValue, addSubMUXout,DATA_ADDR;
	wire addSubMUX, imValueMUX,writeRegMux,waitWire;
	wire busy_wait;
	wire [7:0] read_data;

	// ControlUnit( INS, OUT1addr, OUT2addr, DESTINATION, IMMEDIATE, SELECT, twosCompMux, imValueMux, writeRegMux,read,write,DATA_ADDR );
	//wires are placed correctly | checked
	ControlUnit CU( INS, OUT1addr, OUT2addr, INaddr, IMMEDIATE, SELECT, addSubMUX, imValueMUX,writeRegMux,read,write,DATA_ADDR,busy_wait);
	//regfile ( clk, INaddr, IN, OUT1addr, OUT1, OUT2addr, OUT2);
	//IN signal comes from the mux
	regfile regFile( clk, INaddr, finalOut, OUT1addr, OUT1, OUT2addr, OUT2 ,busy_wait);
	//TwosComp(IN,OUT);
	TwosComp twosComp(OUT1 ,OUT);
	//MUX(IN1,IN2, SELECT,OUT );
	MUX source1mux( OUT1, OUT, addSubMUX, addSubMUXout );
	MUX source2mux( IMMEDIATE, addSubMUXout, imValueMUX,immediateValue);
	MUX datamux(RESULT,read_data,writeRegMux,finalOut);
	//ALU(DATA1,DATA2,SELECT,RESULT);
	ALU myAlu( immediateValue, OUT2, SELECT,RESULT );



//  data_mem(clk,rst,read,write,address,write_data,read_data,busy_wait);	
	data_mem mem(clk,rst,read,write,DATA_ADDR,RESULT,read_data,busy_wait);
endmodule


module testDM;
	reg [31:0] INS;
	wire [7:0] Result;
	reg clk,rst;
	processor simpleP(clk,Result, rst,INS);

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
		INS = 32'b0000000000000110xxxxxxxx00101101;//loadi r6,X,45
		$display("loadi 6,X,45");
		#20
		$display("After 1 CC	%b | %d\n",Result,Result);
		INS = 32'b0000000000000011xxxxxxxx01000001;//loadi r3,X,65
		$display("loadi 6,X,45");
		#20
		$display("After 1 CC	%b | %d\n",Result,Result);
		INS = 32'b0000010100011001xxxxxxxx00000110;//store 25,X,r6
		$display("store 25,X,6");
		#2000
		$display("After 100 CC	%b | %d\n",Result,Result);
		INS = 32'b0000010100010000xxxxxxxx00000011;//store 16,X,r3
		$display("store 16,X,3");
		#2000
		$display("After 100 CC	%b | %d\n",Result,Result );
		INS = 32'b0000010000000111xxxxxxxx00011001;//load r7,X,25
		$display("load 7,X,25");
		#20
		$display("After 1 CC	%b | %d",Result,Result);
	 	#180
		$display("After 10 CC	%b | %d",Result,Result);
	 	#800
		$display("After 50 CC	%b | %d",Result,Result);
	 	#1000
		$display("After 100 CC	%b | %d\n",Result,Result);
	 	INS = 32'b0000010000001000xxxxxxxx00010000;//load r8,X,25
		$display("load 8,X,25");
		#20
		$display("After 1 CC	%b | %d  (Should be 65, new value not loaded. need 100CC)",Result,Result);
		#1980	
		$display("After 100 CC	%b | %d\n",Result,Result);
		INS = 32'b00000001000001010000011100001000;//add 5,7,8
		$display("add 5,7,8");
		#20
		$display("After 1 CC	%b | %d\n",Result,Result);
		INS = 32'b00001001000001010000100000000111;//sub 4,8,7
		$display("sub 4,8,7");
		#20
		$display("After 1 CC	%b | %d\n",Result,Result);
		
		$finish;
	end

endmodule







