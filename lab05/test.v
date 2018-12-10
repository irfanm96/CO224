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


module alu_testbench;

    // Inputs
    reg [7:0] input1;
    reg [7:0] input2;
    reg [2:0] select;

    // Outputs
    wire [7:0] result;

    // Instantiate the ALU
    ALU my_alu (input1,  input2, select, result );
    
    initial begin
        // Apply inputs.
      $monitor("DATA1= %b, DATA2= %b, SELECT= %b, RESULT= %b\n",input1,input2,select,result);
        input1 = 8'b00000011;
        input2 = 8'b00000001;
        select = 0; #10 
        select = 1; #10 
        select = 2; #10 
        select = 3; 
        
    end

endmodule
