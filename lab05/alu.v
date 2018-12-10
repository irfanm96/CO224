
module ALU (RESULT,DATA1,DATA2,SELECT);
    
    //inputs,outputs and internal variables declared here
    input [7:0] DATA1,DATA2;
    input [2:0] SELECT;
    output [7:0] RESULT;
    wire [7:0] operand1,operand2;
    reg [7:0] out;
    
    assign operand1 = DATA1;
    assign operand2 = DATA2;
    //Assign the output 
    //assign RESULT = out;

    //Always block with inputs in the sensitivity list.
    always @(SELECT or operand1 or operand2);
    
     initial begin
        case (SELECT)
            0 : out=8'b01101010;  //forward
	    1 :	out=8'b01101010; //add
	    2 : out=8'b01101010; //bitwise and 
            3 : out=8'b01101010; // bitwise or
        endcase 
    end
assign RESULT = out;
    
endmodule



module alu_testbench;

    // Inputs
    reg [7:0] DATA1;
    reg [7:0] DATA2;
    reg [2:0] SELECT;

    // Outputs
    wire [7:0] RESULT;

    // Instantiate the Unit Under Test (UUT)
    ALU test (.RESULT(RESULT),.DATA1(DATA1),.DATA2(DATA2),.SELECT(SELECT));
    
    initial 
	begin
        DATA1 = 8'b01101010;
        DATA2 = 8'b00111011;
        SELECT = 1; 
	#10 $display("DATA1= %b, DATA2= %b, SELECT= %b, RESULT= %b\n",DATA1,DATA2,SELECT,RESULT);	 
    end
      
endmodule

