module DSP48A1_tb ();
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
reg [17:0] A_tb, B_tb, D_tb, Bcin_tb;
reg [47:0] C_tb, Pcin_tb;
reg [7:0] Opmode_tb;
reg Clk_tb, Carryin_tb, RstA_tb, RstB_tb, RstM_tb, RstP_tb, RstD_tb, RstC_tb, RstCarryin_tb, RstOpmode_tb,
CEA_tb, CEB_tb, CEM_tb, CEP_tb, CEC_tb, CED_tb, CECarryin_tb, CEOpmode_tb;
wire [17:0] Bcout_dut;
wire [47:0] Pcout_dut, P_dut;
wire [35:0] M_dut;
wire Carryout_dut, CarryoutF_dut;

DSP48A1 #(
.A0REG(A0REG), .A1REG(A1REG), .B0REG(B0REG), .B1REG(B1REG),
.CREG(CREG), .DREG(DREG), .MREG(MREG), .PREG(PREG),
.CARRYINREG(CARRYINREG),.CARRYOUTREG(CARRYOUTREG), .OPMODEREG(OPMODEREG),
.CARRYINSEL(CARRYINSEL), .B_INPUT(B_INPUT), .RSTTYPE(RSTTYPE)
)
dut(
	.A(A_tb), .B(B_tb), .D(D_tb), .C(C_tb), 
	.Clk(Clk_tb), .Carryin(Carryin_tb), .Opmode(Opmode_tb), 
	.Bcin(Bcin_tb), .RstA(RstA_tb), .RstB(RstB_tb), .RstM(RstM_tb), 
	.RstP(RstP_tb), .RstD(RstD_tb), .RstC(RstC_tb), .RstCarryin(RstCarryin_tb), 
	.RstOpmode(RstOpmode_tb), .CEA(CEA_tb), .CEB(CEB_tb), .CEM(CEM_tb), 
	.CEP(CEP_tb), .CEC(CEC_tb), .CED(CED_tb), .CECarryin(CECarryin_tb), 
	.CEOpmode(CEOpmode_tb), .Pcin(Pcin_tb), .Bcout(Bcout_dut), .Pcout(Pcout_dut), 
	.P(P_dut), .M(M_dut), .Carryout(Carryout_dut), .CarryoutF(CarryoutF_dut) 
);

initial begin
	Clk_tb = 1;
	forever 
		#1 Clk_tb = ~Clk_tb;
end

initial begin
	// Initialize all control signals
	A_tb = 0;
	B_tb = 0;
	C_tb = 0;
	D_tb = 0;
	Bcin_tb = 0;
	Pcin_tb = 0;
	Opmode_tb = 0;	
	Carryin_tb = 0;
	RstA_tb = 0; 
	RstB_tb = 0; 
	RstM_tb = 0; 
	RstP_tb = 0; 
	RstD_tb = 0; 
	RstC_tb = 0; 
	RstCarryin_tb = 0; 
	RstOpmode_tb = 0;
	CEA_tb = 0;
	CEB_tb = 0; 
	CEM_tb = 0; 
	CEP_tb = 0; 
	CEC_tb = 0; 
	CED_tb = 0; 
	CECarryin_tb = 0; 
	CEOpmode_tb = 0;

	// Test rest
	RstA_tb = 1; 
	RstB_tb = 1; 
	RstM_tb = 1; 
	RstP_tb = 1; 
	RstD_tb = 1; 
	RstC_tb = 1; 
	RstCarryin_tb = 1; 
	RstOpmode_tb = 1;
	repeat(10) @(negedge Clk_tb);

	// Release reset and enable all stages
	RstA_tb = 0; 
	RstB_tb = 0; 
	RstM_tb = 0; 
	RstP_tb = 0; 
	RstD_tb = 0; 
	RstC_tb = 0; 
	RstCarryin_tb = 0; 
	RstOpmode_tb = 0;
	CEA_tb = 1;
    CEB_tb = 1; 
    CEM_tb = 1; 
    CEP_tb = 1; 
    CEC_tb = 1; 
    CED_tb = 1; 
    CECarryin_tb = 1; 
    CEOpmode_tb = 1;
    repeat(10) @(negedge Clk_tb);

    // Test Case 1: Simple addition
    A_tb = 15;
    B_tb = 20;
    C_tb = 10;
    D_tb = 30;
    Carryin_tb = 0;
    Bcin_tb = 5;
    Pcin_tb = 10;
    Opmode_tb = 8'b01101111; // Set Opmode for addition
    repeat(10) @(negedge Clk_tb);

    // Test Case 2: Subtraction
    A_tb = 60;
    B_tb = 10;
    C_tb = 35;
    D_tb = 40;
    Opmode_tb = 8'b01010100; // Set Opmode for subtraction
    repeat(10) @(negedge Clk_tb);

    // Test Case 3: Multiply with Carry-in
    A_tb = 30;
    B_tb = 10;
    C_tb = 100;
    D_tb = 30;
    Opmode_tb = 8'b00101010; // Set Opmode for multiplication with carry-in
    repeat(10) @(negedge Clk_tb);
        
    // Test Case 4: Accumulation
    A_tb = 35;
    B_tb = 30;
    C_tb = 100;
    D_tb = 30;
    Carryin_tb = 1;
    Pcin_tb = 10;
    Opmode_tb = 8'b10001101; // Set Opmode for accumulation
    repeat(10) @(negedge Clk_tb);

    // Test Case 5: chained operation
    A_tb = 25;
    B_tb = 40;
    C_tb = 150;
    D_tb = 30;
    Carryin_tb = 0;
    Opmode_tb = 8'b01111111; // Set Opmode for multiplication with carry-in
    repeat(10) @(negedge Clk_tb);
    
    // Test Case 6: Cascade B input
    Bcin_tb = 15;
    B_tb = 30;
    C_tb = 250;
    D_tb = 15;
    Carryin_tb = 0;
    Opmode_tb = 8'b11000010; // Set Opmode for using cascade input
    repeat(10) @(negedge Clk_tb);
        
    // Test Case 7: complex operation
    A_tb = 20;
    B_tb = 15;
    C_tb = 200;
    D_tb = 30;
    Carryin_tb = 1;
    Opmode_tb = 8'b10101010; // Set Opmode for pre-addition
    repeat(10) @(negedge Clk_tb);

    // Test Case 8: complex operation
    A_tb = 70;
    B_tb = 55;
    C_tb = 230;
    D_tb = 25;
    Carryin_tb = 0;
    Opmode_tb = 8'b00011000; // Set Opmode for pre-addition
    repeat(10) @(negedge Clk_tb);

    // reset and unenable all stages
	RstA_tb = 1; 
	RstB_tb = 1; 
	RstM_tb = 1; 
	RstP_tb = 1; 
	RstD_tb = 1; 
	RstC_tb = 1; 
	RstCarryin_tb = 1; 
	RstOpmode_tb = 1;
	CEA_tb = 0;
    CEB_tb = 0; 
    CEM_tb = 0; 
    CEP_tb = 0; 
    CEC_tb = 0; 
    CED_tb = 0; 
    CECarryin_tb = 0; 
    CEOpmode_tb = 0;
    repeat(10) @(negedge Clk_tb);
	$stop;
end

initial begin
	$monitor("A = %d, B = %d, C = %d, D = %d, Carryin = %b,  Bcin  = %d, Pcin = %d, Opmode = %b, M = %d, P = %d, Carryout = %b, CarryoutF = %b",
	A_tb, B_tb, C_tb, D_tb, Carryin_tb, Bcin_tb, Pcin_tb, Opmode_tb, M_dut, P_dut, Carryout_dut, CarryoutF_dut);
end

endmodule