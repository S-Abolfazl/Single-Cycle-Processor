
module RB(clk, reg_write, R1, R2, read_data1, read_data2, write_back);
	input clk;
	input reg_write;
	input [2:0] R1;
	input [2:0] R2;
	input [7:0] write_back;
	output[7:0] read_data1;
	output[7:0] read_data2;

	reg [7:0] rb [0:7];
	integer i;
	initial begin
		for (i = 0; i < 8; i = i + 1) begin
			rb[i] = 0;	
		end
	end

	assign read_data1 = rb[R1];
	assign read_data2 = rb[R2];

	always @(posedge clk) begin
		if (reg_write) begin
			rb[R1] <= write_back;
		end
	end
endmodule

module IM(addr, dout);
	input [7:0] addr;
	output [15:0] dout;
	reg [15:0] im [0:255];

	initial begin
		im[0] = 16'b1100001100001010;

		im[1] = 16'b0000001111010000;

		im[2] = 16'b0000000001001010;

		im[3] = 16'b0000010100011010;

		im[4] = 16'b1001000000000000;

		im[5] = 16'b1101000101100100;

		im[6] = 16'b1100110001100100;
	end

	assign dout = im[addr];
endmodule


module DM(clk, write_en, mem_Address, writeData, read_data);
	input clk;
	input write_en;
	input [7:0] mem_Address;
	input [7:0] writeData;
	output [7:0] read_data;

	reg [7:0] dm [0:255];
	
	always @(posedge clk) begin
		if (write_en == 1)
			dm[mem_Address] = writeData;
	end
	assign read_data = dm[mem_Address];
endmodule

module mips_core (clk, rst, out);
	input  clk;
	input  rst;
	output out;

	wire 	[7:0]  		instruction_addr;
	wire  	[15:0] 		instruction_data;
	wire 	[7:0]  		mem_Address;
	wire 	[7:0]  		mem_readData;
	wire  	[7:0]  		mem_writeData;
	reg  	[7:0] 		PC;
	wire 	[15:0] 		IR;
	wire 	[7:0] 		read_data1;
	wire 	[7:0] 		read_data2;
	wire 	[7:0] 		write_back;
	wire 	[7:0] 		aluA;
	wire 	[7:0] 		aluB;
	reg  	[7:0] 		alu_result;
	wire	[7:0]		addr;
	wire	[2:0]		R2;
	wire	[2:0]		R1;
	wire	[10:8]		R1_A;
	wire	[5:3]		R1_B;
	wire [4:0]  func;
	
	//Control signals
	reg 			AluSrc;
	reg 			memtoreg;
	wire [3:0]		op;
	reg 			jump;
	reg 			write_en;
	reg 			memRead;
	reg 			reg_write;
	reg				CF;
	reg				ZF;
	reg				SF;
	reg				OF;
	wire			MSB;
	wire [7:0]		imm8;
	reg 			instruction_mem_write_enable;
	reg  [15:0]		instruction_input_data;
	wire [7:0]		index;	


	// Constants
	parameter ADD_OP 	= 5'b00001;
	parameter AND_OP 	= 5'b00010;
	parameter SUB_OP 	= 5'b00011;
	parameter OR_OP 	= 5'b00100;
	parameter XOR_OP 	= 5'b00101;
	parameter MOV_OP 	= 5'b00110;
	parameter XCHG_OP 	= 5'b00111;
	parameter NOT_OP 	= 5'b01000;
	parameter SAR_OP 	= 5'b01001;
	parameter SLR_OP 	= 5'b01010;
	parameter SAL_OP 	= 5'b01011;
	parameter SLL_OP 	= 5'b01100;
	parameter ROL_OP 	= 5'b01101;
	parameter ROR_OP 	= 5'b01110;
	parameter INC_OP 	= 5'b01111;
	parameter DEC_OP 	= 5'b10000;
	parameter NOP_OP 	= 5'b00000;
	parameter CMP_OP 	= 5'b10100;
	//////////////////////////////
	parameter JE_OP 	= 4'b0000;
	parameter JB_OP 	= 4'b0001;
	parameter JA_OP 	= 4'b0010;
	parameter JL_OP 	= 4'b0011;
	parameter JG_OP 	= 4'b0100;
	parameter JMP_OP 	= 4'b0101;
	parameter LI_OP 	= 4'b1000;
	parameter LM_OP 	= 4'b1001;
	parameter SM_OP 	= 4'b1010;

	
	RB rb(clk, reg_write, R1, R2, read_data1, read_data2, write_back);

	IM instruction_mem (PC,IR);

	DM data_mem (clk, write_en, mem_Address, read_data1, mem_readData);


	// 															Fetch
	
	
	always @(posedge clk)
	begin

    if(rst) begin
		PC = 0;
	end
	else
		if (jump == 0)
			PC = PC + 1;
		else
			PC = addr;
	end


	assign instruction_addr = PC;
	assign IR = instruction_data;

	// 															Decode

	// 															ctrl-signals

	assign MSB 			= IR[15];
	assign R1_A 		= IR[5:3];
	assign R1_B			= IR[10:8];
	assign R2			= IR[2:0];
	assign R1			= MSB ? R1_B : R1_A;
	assign addr			= IR[7:0];
	assign op 			= IR[14:11];
	assign func 		= IR[10:6];
	assign imm8 		= MSB ? IR[7:0] : (IR[2] ? {5'b11111,IR[2:0]} : {5'b00000, IR[2:0]});
	assign index 		= aluB % 8;
	
	always @(IR)
	begin
		if (MSB == 0)begin				// R - type
			if (op == 0) begin
				AluSrc = IR[9];
	 			memtoreg = 0;
				jump = 0;
				write_en = 0;
				memRead = 0;
				if(func == NOP_OP || func == CMP_OP)
					reg_write = 0;
				else
					reg_write = 1;
				end
			end
		else begin						// 	J type
			case (op)
				JE_OP: begin
					jump 		= ZF;
					AluSrc 		= 0;
					memtoreg 	= 0;
					write_en 	= 0;
					memRead 	= 0;
					reg_write 	= 0;
					instruction_mem_write_enable = 0;
				end
				
				JB_OP: begin
					jump 		= CF;
					memtoreg	= 0;
					write_en 	= 0;
					memRead 	= 0;
					reg_write 	= 0;
					instruction_mem_write_enable = 0;
				end
				
				JA_OP: begin
					jump = ((CF == 0) | (ZF == 0));
					memtoreg 	= 0;
					write_en 	= 0;
					memRead 	= 0;
					reg_write 	= 0;
					instruction_mem_write_enable = 0;
				end

				JL_OP: begin
					jump 		= (SF != OF);
					memtoreg 	= 0;
					write_en	= 0;
					memRead 	= 0;
					reg_write 	= 0;
					instruction_mem_write_enable = 0;
				end

				JG_OP: begin
					jump 		= ((SF == OF) & (ZF == 0));
					memtoreg 	= 0;
					write_en 	= 0;
					memRead 	= 0;
					reg_write 	= 0;
					instruction_mem_write_enable = 0;
				end

				JMP_OP: begin
					jump 		= 1;
					AluSrc 		= 0;
					memtoreg 	= 0;
					write_en 	= 0;
					memRead 	= 0;
					reg_write 	= 0;
					instruction_mem_write_enable = 0;
				end
				
				LI_OP: begin
					jump 			= 0;
					memtoreg 		= 0;
					write_en 		= 0;
					memRead 		= 0;
					AluSrc 			= 1;
					// func 			= 5'b11111;
					reg_write 		= 1;
					instruction_mem_write_enable = 0;
					// alu_func = 3'b110;	// z = alub
				end

				LM_OP: begin
					jump 		= 0;
					memRead 	= 1;
					memtoreg 	= 1;
					write_en 	= 0;
					reg_write 	= 1;
				end

				SM_OP: begin
					jump 		= 0;
					memRead 	= 0;
					write_en 	= 1;
					reg_write 	= 0;
				end
			endcase	
		end
	end

	//																	decode

	//																	ALU_ctrl
	assign aluA = read_data1;
	assign aluB = AluSrc ? imm8 : read_data2;
	
	reg [7:0] temp_1;
	reg [7:0] temp_2;
	reg [7:0] bits_to_rotate;
	integer i;
	// 																	ALU
	always @(*)
	begin
		if (MSB == 0) begin
		case (func)
			ADD_OP:	begin
				 		{CF , alu_result} = aluA + aluB;			
						if ((!aluA[7] & !aluB[7] & alu_result[7]) | (aluA[7] & aluB[7] & !alu_result[7]))
							OF = 1;
						else
							OF = 0;
						ZF = (alu_result == 0);
						SF = OF ? CF : alu_result[7];
					end
			
			AND_OP:	begin
				 		alu_result = aluA & aluB;
						OF = 0;
						CF = 0;
						if (alu_result == 0)
							ZF = 1;
						else 
							ZF = 0;
						if (OF)
							SF = CF;
						else 
							SF = alu_result;
					end
			
			SUB_OP:	begin 
						{CF , alu_result} = aluA - aluB;
						if ((!aluA[7] & !aluB[7] & alu_result[7]) | (aluA[7] & aluB[7] & !alu_result[7]))
							OF = 1;
						else
							OF = 0;
						if (alu_result == 0)
							ZF = 1;
						else 
							ZF = 0;
						if (OF)
							SF = CF;
						else 
							SF = alu_result;
					end
			
			OR_OP:	begin
				 		alu_result = aluA | aluB;	
						OF=0; 
						CF=0;
						if (alu_result == 0)
							ZF = 1;
						else 
							ZF = 0;
						if (OF)
							SF = CF;
						else 
							SF = alu_result;
					end
			
			XOR_OP:	begin
				 		{CF , alu_result} = aluA ^ aluB;			
						OF=0; 
						CF=0;
						if (alu_result == 0)
							ZF = 1;
						else 
							ZF = 0;
						if (OF)
							SF = CF;
						else 
							SF = alu_result;
					end
			
			MOV_OP:	begin
					alu_result = aluB;
					end
			
			XCHG_OP:begin
						// یک شبه دستور است و میتوان در سه سیکل و با کمک دستور موو آن را انجام داد
			 			// برای انجام شدن این شبه دستو حدااقل سه سیکل نیاز است
					end
			
			NOT_OP:	begin
				 		alu_result = ~aluA;
					end

			SAR_OP:	begin
				 		alu_result = aluA >>> aluB;
						CF = aluA[aluB - 1];
						OF = 0;
						if (alu_result == 0)
							ZF = 1;
						else 
							ZF = 0;
						if (OF)
							SF = CF;
						else 
							SF = alu_result;
					end
			
			SLR_OP:	begin
						alu_result = aluA >> aluB;
						CF = aluA[aluB - 1];
						if (alu_result[7] == aluA[7])
							OF = 1;
						else
							OF = 0;
						if (alu_result == 0)
							ZF = 1;
						else 
							ZF = 0;
						if (OF)
							SF = CF;
						else 
							SF = alu_result;
					end

			SAL_OP:	begin
				 		alu_result = aluA <<< aluB;
						CF = aluA[aluB - 1];
						OF = 0;
						if (alu_result == 0)
							ZF = 1;
						else 
							ZF = 0;
						if (OF)
							SF = CF;
						else 
							SF = alu_result;					
					end

			SLL_OP:	begin
				 		alu_result = aluA << aluB;
						CF = aluA[aluB - 1];
						if (alu_result[7] == aluA[7])
							OF = 1;
						else
							OF = 0;
						if (alu_result == 0)
							ZF = 1;
						else 
							ZF = 0;
						if (OF)
							SF = CF;
						else 
							SF = alu_result;
					end

			ROL_OP: begin
						temp_1 = 0; 
						temp_2 = aluA;
						for (i = 0; i < aluB + 1; i = i + 1)begin
							bits_to_rotate = i;
							temp_1 = (temp_2 << bits_to_rotate) | (temp_2 >> (8'd8 - bits_to_rotate));
						end

						alu_result = temp_1;

						// alu_result = {aluA[7: 8 -index], aluA[index - 1:0]};
						CF = aluA[aluB - 1];
						if (alu_result[7] == aluA[7])
							OF = 1;
						else
							OF = 0;
						if (alu_result == 0)
							ZF = 1;
						else 
							ZF = 0;
						if (OF)
							SF = CF;
						else 
							SF = alu_result;
					end

			ROR_OP: begin
						temp_1 = 0; 
						temp_2 = aluA;
						for (i = 0; i < aluB + 1; i = i + 1)begin
							bits_to_rotate = i;
							temp_1 = (temp_2 >> bits_to_rotate) | (temp_2 << (8'd8 - bits_to_rotate));
						end

						alu_result = temp_1;

						// alu_result = {aluA[index - 1:0], aluA[7:index]};
						CF = aluA[aluB - 1];
						if (alu_result[7] == aluA[7])
							OF = 1;
						else
							OF = 0;
						if (alu_result == 0)
							ZF = 1;
						else 
							ZF = 0;
						if (OF)
							SF = CF;
						else 
							SF = alu_result;
					end

			INC_OP: begin
				 		{CF , alu_result} = aluA + 8'd1;	
						if ((!aluA[7] & alu_result[7]))
							OF = 1;
						else
							OF = 0;
						if (alu_result == 0)
							ZF = 1;
						else 
							ZF = 0;
						if (OF)
							SF = CF;
						else 
							SF = alu_result[7];				
					end

			DEC_OP: begin 
						{CF , alu_result} = aluA - 1;
						if ((aluA[7] & !alu_result[7]))
							OF = 1;
						else
							OF = 0;
						if (alu_result == 0)
							ZF = 1;
						else 
							ZF = 0;
						if (OF)
							SF = CF;
						else 
							SF = alu_result;
					end

			NOP_OP: begin
				
				end
			
			CMP_OP: begin
						{CF , alu_result} = aluA - aluB;
						if ((!aluA[7] & !aluB[7] & alu_result[7]) | (aluA[7] & aluB[7] & !alu_result[7]))
							OF = 1;
						else
							OF = 0;
						if (alu_result == 0)
							ZF = 1;
						else 
							ZF = 0;
						if (OF)
							SF = CF;
						else 
							SF = alu_result;
					end
		endcase
		ZF = (alu_result == 0);
		SF = OF ? CF : alu_result[7];
		end
		
		else 
			alu_result = aluB;
	end

	// 																	Memory
	assign mem_Address = addr;
	assign mem_writeData  = read_data2;
	

	// 																	Write back

	assign write_back = memtoreg ? mem_readData :  alu_result;
	assign 				out = write_back;
endmodule 
