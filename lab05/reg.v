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


module testregeter;
 
reg [2:0] INaddr,OUT1addr,OUT2addr;
reg clk;
reg [7:0] IN;
wire [7:0] OUT1,OUT2;
 
    	regfile regf ( clk, INaddr, IN, OUT1addr, OUT1, OUT2addr, OUT2);

    	initial begin
    	clk = 1'b0; end
    	always #10 clk = ~clk;
 
initial begin

	IN = 12;
	INaddr = 5;
	OUT1addr = 5;
	OUT2addr = 3;

#10							
	$display("OUT1addr=>%d OUT1 = %d OUT2addr=>%d OUT2 = %d ",OUT1addr,OUT1,OUT2addr,OUT2);
#10							
	$display("OUT1addr=>%d OUT1 = %d OUT2addr=>%d OUT2 = %d",OUT1addr,OUT1,OUT2addr,OUT2);								
	IN = 7;
	INaddr = 3;
#10
	$display("OUT1addr=>%d OUT1 = %d OUT2addr=>%d OUT2 = %d ",OUT1addr,OUT1,OUT2addr,OUT2);		
#10
	$display("OUT1addr=>%d OUT1 = %d OUT2addr=>%d OUT2 = %d ",OUT1addr,OUT1,OUT2addr,OUT2);		

$finish;

end
endmodule
