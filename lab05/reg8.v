//Verilog module for an ALU
module REG(clk,inaddr,in,out1addr,out2addr,out1,out2);
    
    //inputs,outputs and internal variables declared here
    input [7:0]  in;
    input  clk;
    input inaddr,out1addr,out2addr;
    output [7:0] out1,out2;
    wire  inaddrw,out1addrw,out2addrw;
    wire [7:0] inw;
    reg [7:0] out1reg,out2reg;
    
    reg [7:0] reg1,reg2,reg3,reg4,reg5,reg6,reg7,reg8; 
      
assign inaddrw=inaddr;
assign out1addrw=out1addr;
assign out2addrw=out2addr;
assign clkw=clk;
assign inw=in;
assign out1=out1reg;
assign out2=out2reg;


 always @(negedge clk)
   begin
   $display("\n"); 
	case (inaddr)
        1:   reg1=inw;
	2:   reg2=inw;
	3:   reg3=inw;       
	4:   reg4=inw;
	5:   reg5=inw;
	6:   reg6=inw;
	7:   reg7=inw;
	8:   reg8=inw;
	endcase       
 end
 
 always @(out1addr or out2addr)
    begin
       case (out1addr)
	1: out1reg=reg1;
	2: out1reg=reg2;
	3: out1reg=reg3;       
	4: out1reg=reg4;
	5: out1reg=reg5;
	6: out1reg=reg6;
	7: out1reg=reg7;
	8: out1reg=reg8;
	endcase
end 
endmodule


module reg_testbench;

    // Inputs
    reg  inaddr,out1addr,out2addr,clk;
    reg [7:0] in;
    // Outputs
    wire [7:0] out1,out2;

    // Instantiate the ALU
    
 REG  reg8(clk,inaddr,in,out1addr,out2addr,out1,out2);

    initial begin
        // Apply inputs.
        in = 8'b00000011;
        inaddr = 1;
        out1addr = 1;
        out2addr = 2; 
        clk=0;
	#1 
        $display("OUT1= %b, OUT2= %b, inaddr= %b, in= %b clk =%b \n",out1,out2,inaddr,in,clk);
 
#1 
        $display("OUT1= %b, OUT2= %b, inaddr= %b, in= %b clk =%b\n",out1,out2,inaddr,in,clk);
 #1 
        $display("OUT1= %b, OUT2= %b, inaddr= %b, in= %b clk =%b\n",out1,out2,inaddr,in,clk);
 #1 
        $display("OUT1= %b, OUT2= %b, inaddr= %b, in= %b clk =%b\n",out1,out2,inaddr,in,clk);
 #1 
        $display("OUT1= %b, OUT2= %b, inaddr= %b, in= %b clk =%b\n",out1,out2,inaddr,in,clk);
#1 
 $display("OUT1= %b, OUT2= %b, inaddr= %b, in= %b clk =%b\n",out1,out2,inaddr,in,clk);
 
#10 $finish;
    end

always begin 
#5 clk=~clk;
end

endmodule
