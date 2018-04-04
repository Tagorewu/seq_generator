/*
 * 	@module: 		dvp_seq_generator
	Designer: 		TagoreWu
	Date:			2015-7-8
	Version:		V0.2	release. 
	explain:
*/
module dvp_generator(
	//input i_clk,
	input rst_n,
	output o_pclk,
	output o_vsync,
	output o_hsync,
	output [7:0]o_data,
	
	input i_pclk,
	input i_vsync,
	input i_hsync,
	input [7:0] i_data,
	
	input i_sel
	
);
	wire osc_clk;
	//reg rst_n;
	//------------------------------
	// Instantiate OSCH primitives (XO2/3)
	//------------------------------
	defparam OSCH_inst.NOM_FREQ = "12.09";

	OSCH OSCH_inst(
		.STDBY(1'b0), // 0=Enabled, 1=Disabled
		.OSC(osc_clk),
		.SEDSTDBY()
		);

	wire clk;
	pll pll0(.CLKI( osc_clk ), .CLKOP( clk ));
	
	//-------------------------------------//
	//---- always (process) operations ----//
	//-------------------------------------//

	//   reset generator 

	//always @ (posedge clk)
	//	begin
	//		if (!rst_n ) rst_n <= 1;
	//	end
		
	reg pclk;
	reg vsync;
	reg hsync;
	reg [7:0] r_pixdata;
	reg [15:0] r_cnt;
	reg [3:0] r_clk_cnt;
	reg [31:0] p_cnt;
	parameter MAX_PCNT = 11'h400 * (120 + 80);
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		p_cnt <= 0;
	else if(p_cnt >= MAX_PCNT)
		p_cnt <= 0;
	else p_cnt <= p_cnt + 1;
	
	wire w_vsync ;
	wire w_hsync ;
	
	assign w_vsync = p_cnt[31:10] < 120;
	assign w_hsync = p_cnt[9:0] < 640;
	
	always @ (posedge clk or negedge rst_n)	
	if(!rst_n) begin
		hsync <= 0;
		vsync <= 0;
	end
	else if(w_vsync)
	begin
		hsync <= ( w_hsync ) ? 0 : 1;		
		vsync <= 0;
	end
	else begin
		hsync <= 1;
		vsync <= 1;
	end		
	
	reg[15:0] rgb565;
	always @ (posedge clk or negedge rst_n) 
	if(!rst_n)
		rgb565 <= 0;
	else
	begin 
		if( !hsync )
			rgb565 <= rgb565 + 1;
		else //if( !p_cnt[0] )			
			rgb565 <= 0;
		
	end	

	assign o_hsync = i_sel ? !hsync : !i_hsync;
	assign o_vsync = i_sel ? !vsync : !i_vsync;	
	assign o_data[7:0] = i_sel ? rgb565[7:0] : i_data[7:0];//!p_cnt[0] ? rgb565[7:0] : rgb565[15:8];
	assign o_pclk = i_sel ? clk : i_pclk;
	
endmodule
