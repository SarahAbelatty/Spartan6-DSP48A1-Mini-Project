module DSP48A1 (
	A, B, D, C, Clk, Carryin, Opmode, Bcin, RstA, RstB, RstM, RstP, RstD, RstC, RstCarryin, RstOpmode,
    CEA, CEB, CEM, CEP, CEC, CED, CECarryin, CEOpmode, Pcin, Bcout, Pcout, P, M, Carryout, CarryoutF 
);

// Parameter to configure the registers
parameter A0REG = 0;
parameter A1REG = 1;
parameter B0REG = 0;
parameter B1REG = 1;
parameter CREG = 1;
parameter DREG = 1;
parameter MREG = 1;
parameter PREG = 1;
parameter CARRYINREG = 1;
parameter CARRYOUTREG = 1;
parameter OPMODEREG = 1;
parameter CARRYINSEL = "OPMODE5";
parameter B_INPUT = "DIRECT";
parameter RSTTYPE = "SYNC";

// Input ports
input [17:0] A, B, D, Bcin;
input [47:0] C, Pcin;
input [7:0] Opmode;
input Clk, Carryin, RstA, RstB, RstM, RstP, RstD, RstC, RstCarryin, RstOpmode,
CEA, CEB, CEM, CEP, CEC, CED, CECarryin, CEOpmode;

// Output ports
output [17:0] Bcout;
output [47:0] Pcout, P;
output [35:0] M;
output Carryout, CarryoutF;

wire [17:0] A0_reg;
// Register pipeline for A input
DSP48A1_D_BLOCK #(.WIDTH(18), .REG(A0REG), .RSTTYPE(RSTTYPE)) m1(.D(A), .rst(RstA), .clk(Clk), .En(CEA), .out(A0_reg));

wire [17:0] D_reg;
// Register pipeline for D input
DSP48A1_D_BLOCK #(.WIDTH(18), .REG(DREG), .RSTTYPE(RSTTYPE)) m2(.D(D), .rst(RstD), .clk(Clk), .En(CED), .out(D_reg));

wire [47:0] C_reg;
// Register pipeline for C input
DSP48A1_D_BLOCK #(.WIDTH(48), .REG(CREG), .RSTTYPE(RSTTYPE)) m3(.D(C), .rst(RstC), .clk(Clk), .En(CEC), .out(C_reg));

wire [17:0] B0_reg;
// Conditional generation for B input
generate
	// Direct B input mode
	if (B_INPUT == "DIRECT") 
		DSP48A1_D_BLOCK #(.WIDTH(18), .REG(B0REG), .RSTTYPE(RSTTYPE)) m5(.D(B), .rst(RstB), .clk(Clk), .En(CEB), .out(B0_reg));
	// Cascade B input mode
	else if (B_INPUT == "CASCADE")
		DSP48A1_D_BLOCK #(.WIDTH(18), .REG(B0REG), .RSTTYPE(RSTTYPE)) m6(.D(Bcin), .rst(RstB), .clk(Clk), .En(CEB), .out(B0_reg));
endgenerate

wire [17:0] A1_reg;
// Register pipeline for A1
DSP48A1_D_BLOCK #(.WIDTH(18), .REG(A1REG), .RSTTYPE(RSTTYPE)) m7(.D(A0_reg), .rst(RstA), .clk(Clk), .En(CEA), .out(A1_reg));

wire [7:0] Opmode_reg;
// Register pipeline for Opmode
DSP48A1_D_BLOCK #(.WIDTH(8), .REG(OPMODEREG), .RSTTYPE(RSTTYPE)) m8(.D(Opmode), .rst(RstOpmode), .clk(Clk), .En(CEOpmode), .out(Opmode_reg));

wire [17:0] add_or_sub_reg;
// add or subtract logic based on Opmode
assign add_or_sub_reg = (Opmode_reg[6])? (D_reg - B0_reg):(D_reg + B0_reg);

wire [17:0] B_or_Preaddingsub;
// Select between B or Pre-add/Sub based on Opmode
assign B_or_Preaddingsub = (Opmode_reg[4])? add_or_sub_reg:B0_reg;

wire [17:0] B1_reg;
// Register pipeline for B1
DSP48A1_D_BLOCK #(.WIDTH(18), .REG(B1REG), .RSTTYPE(RSTTYPE)) m9(.D(B_or_Preaddingsub), .rst(RstB), .clk(Clk), .En(CEB), .out(B1_reg));

// Assign Bcout
assign Bcout = B1_reg;

wire [35:0] mul_reg;
// Multiplication logic
assign mul_reg = A1_reg * B1_reg;

wire [35:0] M_reg;
// Register pipeline for M
DSP48A1_D_BLOCK #(.WIDTH(36), .REG(MREG), .RSTTYPE(RSTTYPE)) m10(.D(mul_reg), .rst(RstM), .clk(Clk), .En(CEM), .out(M_reg));

generate
	genvar i;
	for(i=0; i<36; i=i+1)
		buf(M[i], M_reg[i]);
endgenerate

wire [47:0] conc_DAB;
// Concatenate inputs D, A, and B
assign conc_DAB = {D, A, B};

reg [47:0] X_out;
// X_out logic based on Opmode
always @(*) begin
	case (Opmode_reg[1:0])
		0: X_out = 0;
		1: X_out = mul_reg;
		2: X_out = P;
		3: X_out = conc_DAB;
	endcase
end

reg [47:0] Z_out;
// Z_out logic based on Opmode
always @(*) begin
	case (Opmode_reg[3:2])
		0: Z_out = 0;
		1: Z_out = Pcin;
		2: Z_out = P;
		3: Z_out = C_reg;
	endcase
end

wire Opmode_Carry;
// Opmode carry logic
assign Opmode_Carry = (CARRYINSEL == "CARRYIN")? Carryin:(CARRYINSEL == "OPMODE5")? Opmode_reg[5]:0;

wire CIN;
// Register pipeline for carry-in
DSP48A1_D_BLOCK #(.WIDTH(1), .REG(CARRYINREG), .RSTTYPE(RSTTYPE)) m11(.D(Opmode_Carry), .rst(RstCarryin), .clk(Clk), .En(CECarryin), .out(CIN));

wire Carryout_reg;
wire [47:0] add_or_sub_outreg;
// Addition or subtraction based on Opmode
assign {Carryout_reg, add_or_sub_outreg} = (Opmode_reg[7])? (Z_out - (X_out + CIN)):(X_out + Z_out + CIN);

// Register pipeline for carry-out
DSP48A1_D_BLOCK #(.WIDTH(1), .REG(CARRYOUTREG), .RSTTYPE(RSTTYPE)) m12(.D(Carryout_reg), .rst(RstCarryin), .clk(Clk), .En(CECarryin), .out(Carryout));
assign CarryoutF = Carryout;

// Register pipeline for Pcout
DSP48A1_D_BLOCK #(.WIDTH(48), .REG(PREG), .RSTTYPE(RSTTYPE)) m13(.D(add_or_sub_outreg), .rst(RstP), .clk(Clk), .En(CEP), .out(P));
assign Pcout = P;

endmodule

