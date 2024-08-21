module DSP48A1_D_BLOCK (D, rst, clk, En, out);
parameter WIDTH = 18;
parameter REG = 1;
parameter RSTTYPE = "SYNC";
input [WIDTH-1:0] D;
input clk, rst, En;
output [WIDTH-1:0] out;
reg [WIDTH-1:0] out_reg;
generate
	if (RSTTYPE == "SYNC") begin
		always @(posedge clk) begin
			if (rst) 
				out_reg <= 0;
			else if (En)
				out_reg <= D;				
		end
	end
	else if (RSTTYPE == "ASYNC") begin
		always @(posedge clk or posedge rst) begin
			if (rst) 
				out_reg <= 0;
			else if (En)
				out_reg <= D;
		end
	end
endgenerate
assign out = (REG)? out_reg:D;

endmodule

