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
	input [31:0] INS;
	output [7:0] OUT1addr;
	output [7:0] OUT2addr;
	output [2:0] SELECT;
	output [7:0] IN_ADDR;
	output [7:0] IMMEDIATE;
	output [7:0] DATA_ADDR;//Read or Write data address
	output  twosCompMux,imValueMux,writeRegMux,read,write;//newly added
    input busy_wait;
	reg [2:0] SELECT;
	reg [7:0] OUT1addr,OUT2addr,IMMEDIATE,IN_ADDR;
	reg [7:0] DATA_ADDR;//Read or Write data address
	reg  twosCompMux,imValueMux,writeRegMux,read,write; 
		
	always @(INS)   begin //begin for always  
		 if(busy_wait==0)
			begin  //begin if            
				 SELECT <= INS[26:24];
				 IMMEDIATE <= INS[7:0];
				 OUT1addr <= INS[7:0];
				 OUT2addr <= INS[15:8];
				 IN_ADDR <= INS[23:16];//input address for register file (including load word)
 				 twosCompMux <= 0; // mux select for 2's complement
				 imValueMux <= 1; //load immediate value				
				writeRegMux<=0;// get the alu RESULT as default
				read<=0;
				write<=0;
				DATA_ADDR<=INS[7:0];// read data address for load
					
			case(INS[31:24])

			8'b00000000 : begin //load
				 imValueMux <= 0;				//Select from Source 1
				end
			8'b00001001 : begin //subtraction
				  twosCompMux <= 1;				//2's complements of Source 2
				end
			
			8'b00000100 : begin			//load
				 read <= 1;
			end
			8'b00000101: begin			//store
				 write <= 1;
				  writeRegMux<=1;
				 DATA_ADDR<=INS[23:16];
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
		#2000
        memory_array[address] = write_data;
		busy_wait <= 0;
	end
    if (!write && read)
	begin
		busy_wait <= 1;
		#2000
        read_data = memory_array[address];
		busy_wait <= 0;
	end
end
 
endmodule


module testbench;

	reg CLK;
	wire [7:0] RESULT;
	reg [31:0] INS;
	wire [2:0] SELECT;
	wire  [7:0] OUT1addr,OUT2addr,IMMEDIATE,OUT1,OUT2,OUT,IN,INaddr;
	wire [7:0] immediateValue, addSubMUXout,DATA_ADDR;
	wire addSubMUX, imValueMUX,writeRegMux,waitWire;
	reg rst;
	wire busy_wait;
	wire [7:0] read_data;

      //GET the clock period
    	initial begin
    	CLK = 1'b0;
	 end
    	always #10 CLK = ~CLK;
 
	

	// ControlUnit( INS, OUT1addr, OUT2addr, DESTINATION, IMMEDIATE, SELECT, twosCompMux, imValueMux, writeRegMux,read,write,DATA_ADDR );
	ControlUnit CU( INS, OUT1addr, OUT2addr, INaddr, IMMEDIATE, SELECT, addSubMUX, imValueMUX,writeRegMux,read,write,DATA_ADDR,busy_wait);
	//regfile ( clk, INaddr, IN, OUT1addr, OUT1, OUT2addr, OUT2);
	regfile regFile( CLK, INaddr, IN, OUT1addr, OUT1, OUT2addr, OUT2 ,busy_wait);
	//TwosComp(IN,OUT);
	TwosComp twosComp(OUT1 ,OUT);
	//MUX(IN1,IN2, SELECT,OUT );
	MUX source1mux( OUT1, OUT, addSubMUX, addSubMUXout );
	MUX source2mux( IMMEDIATE, addSubMUXout, imValueMUX,immediateValue);
	MUX datamux(RESULT,read_data,writeRegMux,IN);
	//ALU(DATA1,DATA2,SELECT,RESULT);
	ALU myAlu( immediateValue, OUT2, SELECT,RESULT );



//  data_mem(clk,rst,read,write,address,write_data,read_data,busy_wait);	
	data_mem mem(CLK,rst,read,write,DATA_ADDR,RESULT,read_data,busy_wait);

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

  //resettig memory
   		rst = 0;
		#20
		rst = 1;
		#20
		rst = 0;
		#20
	INS = 32'b0000000000000110xxxxxxxx00101101;//loadi r6,X,45
		$display("loadi 6,X,45");
		#20
		$display("delay of 1 clock cycle");
		$display("value in reg6=%d\n",RESULT);

		INS = 32'b0000010100011001xxxxxxxx00000110;//store 25,X,r6
		$display("store 25,X,6");
		#2000
		$display("delay of 100 clock cycles..");
		$display("value in memory address=%d is %d\n",DATA_ADDR,RESULT);
		INS = 32'b0000010000000111xxxxxxxx00011001;//load r7,X,25
		$display("Retriving stored data again to reg7");
		$display("load 7,X,25");
		#2000
		$display("delay of 100 clock cycles");
		$display("value in reg7=%d",RESULT);

    $finish;
end
endmodule




