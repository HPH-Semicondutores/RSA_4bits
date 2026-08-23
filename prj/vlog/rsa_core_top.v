//--------------------------------------------------------------------------------------------
// RSA TOP
//--------------------------------------------------------------------------------------------

module rsa_top #(
    parameter DATA_WIDTH = 4,
    parameter RESET      = 1'b1,
    parameter LOAD       = 1'b1
)(
    input  wire                  core_clk,
    input  wire                  core_rst,
    input  wire                  core_load,
    input  wire [DATA_WIDTH-1:0] core_din,

    output wire                  core_done,
    output wire                  core_err,
    output wire [DATA_WIDTH-1:0] core_dout,

    output wire [1:0]            core_clk_o,
    output wire [5:0]            core_led_o,

    output wire [6:0]            core_din_disp1,
    output wire [6:0]            core_din_disp2,
    output wire [6:0]            core_dout_disp3,
    output wire [6:0]            core_dout_disp4
);

wire                  core_clk_w;
wire                  core_done_w;
wire                  core_err_w;
wire [DATA_WIDTH-1:0] core_dout_w;

//--------------------------------------------------------------------------------------------
// RSA CORE
//--------------------------------------------------------------------------------------------

rsa_core #(
                    .DATA_WIDTH     (DATA_WIDTH),
                    .RESET          (RESET),
                    .LOAD           (LOAD)
                )
core (
                    .core_clk       (core_clk),
                    .core_rst       (core_rst),
                    .core_load      (core_load),
                    .core_din       (core_din),
                    .core_done      (core_done_w),
                    .core_err       (core_err_w),
                    .core_dout      (core_dout_w),
                    .core_clk_o     (core_clk_w)
                );

//--------------------------------------------------------------------------------------------
// RSA I/O
//--------------------------------------------------------------------------------------------

rsa_core_io #(
                    .DATA_WIDTH     (DATA_WIDTH)
                )
io (
                    .core_clk       (core_clk_w),
                    .core_rst       (core_rst),
                    .core_load      (core_load),
                    .core_din       (core_din),
                    .core_done      (core_done_w),
                    .core_err       (core_err_w),
                    .core_dout      (core_dout_w),
                    .core_clk_o     (core_clk_o),
                    .core_led_o     (core_led_o),
                    .core_din_disp1 (core_din_disp1),
                    .core_din_disp2 (core_din_disp2),
                    .core_dout_disp3(core_dout_disp3),
                    .core_dout_disp4(core_dout_disp4)
                );

assign core_done = core_done_w;
assign core_err  = core_err_w;
assign core_dout = core_dout_w;

endmodule: rsa_top

//--------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------
// top-level module for RSA core I/O
//--------------------------------------------------------------------------------------------

module rsa_core_io#(
    parameter   DATA_WIDTH = 4,
                D_WID      = DATA_WIDTH-1
)(
    input  wire             core_clk,
    input  wire             core_rst,
    input  wire             core_load,
    input  wire [D_WID:0]   core_din,

    // Sinais provenientes do rsa_core
    input  wire             core_done,
    input  wire             core_err,
    input  wire [D_WID:0]   core_dout,

    output wire [1:0]       core_clk_o,
    output wire [5:0]       core_led_o,

    // Displays 1 e 2: entrada RSA
    output wire [6:0]       core_din_disp1,
    output wire [6:0]       core_din_disp2,

    // Displays 3 e 4: saída RSA
    output wire [6:0]       core_dout_disp3,
    output wire [6:0]       core_dout_disp4
);

//--------------------------------------------------------------------------------------------
// Interconexões dos módulos de indicação por LED
//--------------------------------------------------------------------------------------------

wire [5:0] led_load_w;
wire [5:0] led_done_w;
wire [5:0] led_error_w;

// O clock externo é apenas uma conexão do clock do núcleo.
assign core_clk_o[0] = core_clk;
assign core_clk_o[1] = core_clk;

//--------------------------------------------------------------------------------------------
// Displays 1 e 2 - Entrada RSA
//--------------------------------------------------------------------------------------------

div_disp dp_input (
                    .num            (core_din),
                    .disp1          (core_din_disp1),
                    .disp2          (core_din_disp2)
                );

//--------------------------------------------------------------------------------------------
// Displays 3 e 4 - Saída RSA
//--------------------------------------------------------------------------------------------

div_disp dp_output (
                    .num            (core_dout),
                    .disp1          (core_dout_disp3),
                    .disp2          (core_dout_disp4)
                );

//--------------------------------------------------------------------------------------------
// LOAD snake
//--------------------------------------------------------------------------------------------

rsa_core_io_load_snake load_snake (
                    .core_clk       (core_clk),
                    .core_rst       (core_rst),
                    .core_load      (core_load),
                    .core_done      (core_done),
                    .load_led_o     (led_load_w)
                );

//--------------------------------------------------------------------------------------------
// DONE
//--------------------------------------------------------------------------------------------

rsa_core_io_done done_led (
                    .core_clk       (core_clk),
                    .core_rst       (core_rst),
                    .core_done      (core_done),
                    .done_led_o     (led_done_w)
                );

//--------------------------------------------------------------------------------------------
// ERROR
//--------------------------------------------------------------------------------------------

rsa_core_io_error error_led (
                    .core_clk       (core_clk),
                    .core_rst       (core_rst),
                    .core_err       (core_err),
                    .error_led_o    (led_error_w)
                );

//--------------------------------------------------------------------------------------------
// LED output mux
// Prioridade: ERROR > DONE > LOAD
//--------------------------------------------------------------------------------------------

rsa_core_io_led_mux led_mux (
                    .core_done      (core_done),
                    .core_err       (core_err),
                    .load_led_i     (led_load_w),
                    .done_led_i     (led_done_w),
                    .error_led_i    (led_error_w),
                    .core_led_o     (core_led_o)
                );

endmodule: rsa_core_io

//--------------------------------------------------------------------------------------------
// Multiplexador dos LEDs
//
// Prioridade:
//   ERROR -> padrão de erro
//   DONE  -> todos os LEDs ligados
//   LOAD  -> snake
//--------------------------------------------------------------------------------------------

module rsa_core_io_led_mux (
    input  wire         core_done,
    input  wire         core_err,

    input  wire [5:0]   load_led_i,
    input  wire [5:0]   done_led_i,
    input  wire [5:0]   error_led_i,

    output wire [5:0]   core_led_o
);

assign core_led_o = core_err  ? error_led_i :
                    core_done ? done_led_i  :
                                load_led_i;

endmodule: rsa_core_io_led_mux

//--------------------------------------------------------------------------------------------
// LOAD snake
//
// Uma borda de subida em core_load inicia o deslocamento circular.
// Enquanto ativo e core_done = 0, o bit '1' percorre os seis LEDs.
// core_done encerra o snake; a indicação visual de DONE pertence ao módulo
// rsa_core_io_done.
//--------------------------------------------------------------------------------------------

module rsa_core_io_load_snake (
    input  wire         core_clk,
    input  wire         core_rst,
    input  wire         core_load,
    input  wire         core_done,

    output reg  [5:0]   load_led_o
);

reg core_load_d;
reg sh_active;

wire load_posedge = core_load & ~core_load_d;


// Registro do estado anterior de LOAD para detecção de borda.
always @(posedge core_clk or posedge core_rst)
    begin
        if (core_rst) core_load_d <= 1'b0;
        else          core_load_d <= core_load;
    end

// Shift register circular.
always @(posedge core_clk or posedge core_rst)
    begin
        if (core_rst)
            begin
                load_led_o <= 6'b000000;
                sh_active  <= 1'b0;
            end
        else
            begin
                // DONE apenas encerra a animação de LOAD.
                if (core_done)
                    begin
                        load_led_o <= 6'b000000;
                        sh_active  <= 1'b0;
                    end

                // Borda de subida de LOAD inicia o snake.
                else if (load_posedge)
                    begin
                        load_led_o <= 6'b000001;
                        sh_active  <= 1'b1;
                    end

                // Rotação à esquerda enquanto o snake estiver ativo.
                else if (sh_active)
                    begin
                        load_led_o <= {load_led_o[4:0], load_led_o[5]};
                    end

                else
                    begin
                        load_led_o <= 6'b000000;
                    end
            end
    end

endmodule: rsa_core_io_load_snake

//--------------------------------------------------------------------------------------------
// DONE
//
// Quando core_done é reconhecido em uma borda de core_clk, todos os seis LEDs
// são ligados. Quando DONE deixa de estar ativo, o registrador retorna para zero.
//--------------------------------------------------------------------------------------------

module rsa_core_io_done (
    input  wire         core_clk,
    input  wire         core_rst,
    input  wire         core_done,

    output reg  [5:0]   done_led_o
);

always @(posedge core_clk or posedge core_rst)
    begin
        if (core_rst) done_led_o <= 6'b000000;
        else
            begin
                if (core_done) done_led_o <= 6'b111111;
                else           done_led_o <= 6'b000000;
            end
    end

endmodule: rsa_core_io_done


//--------------------------------------------------------------------------------------------
// ERROR
//
// Preserva o comportamento do bloco original:
// quando core_err está ativo, os LEDs recebem o padrão alternado 010101.
//--------------------------------------------------------------------------------------------

module rsa_core_io_error (
    input  wire         core_clk,
    input  wire         core_rst,
    input  wire         core_err,

    output reg  [5:0]   error_led_o
);

wire clk_inv = ~core_clk;

always @(posedge core_clk or posedge core_rst)
    begin
        if (core_rst)
            begin
                error_led_o <= 6'b000000;
            end
        else
            begin
                if (core_err)
                    begin
                        error_led_o[0] <= core_clk;
                        error_led_o[1] <= clk_inv;
                        error_led_o[2] <= core_clk;
                        error_led_o[3] <= clk_inv;
                        error_led_o[4] <= core_clk;
                        error_led_o[5] <= clk_inv;
                    end
                else
                    begin
                        error_led_o <= 6'b000000;
                    end
            end
    end

endmodule: rsa_core_io_error

//--------------------------------------------------------------------------------------------
// Display de 7 segmentos
//--------------------------------------------------------------------------------------------

module disp7seg(
    input       [3:0] bin,
    output reg  [6:0] dig
);

always @(*)
    begin
        case (bin)
            4'b0000: dig = 7'b1111110;
            4'b0001: dig = 7'b0110000;
            4'b0010: dig = 7'b1101101;
            4'b0011: dig = 7'b1111001;
            4'b0100: dig = 7'b0110011;
            4'b0101: dig = 7'b1011011;
            4'b0110: dig = 7'b1011111;
            4'b0111: dig = 7'b1110000;
            4'b1000: dig = 7'b1111111;
            4'b1001: dig = 7'b1110011;
            default: dig = 7'b0000000;
        endcase
    end

endmodule: disp7seg

//--------------------------------------------------------------------------------------------
// Divisor para dois displays
//--------------------------------------------------------------------------------------------

module div_disp(
    input  wire [3:0] num,
    output reg  [6:0] disp1, disp2
);

reg [3:0] b1, b2;

wire [3:0] bin1 = b1,
           bin2 = b2;

wire [6:0] dig1, dig2;

disp7seg dp1 (
                .bin    (bin1),
                .dig    (dig1)
            );

disp7seg dp2 (
                .bin    (bin2),
                .dig    (dig2)
            );

always @(*)
    begin
        if (num > 9)
            begin
                b1    = num / 10;
                b2    = num % 10;
                disp1 = dig1;
                disp2 = dig2;
            end
        else
            begin
                b1    = 4'b0000;
                b2    = num;
                disp1 = 7'b0000000;
                disp2 = dig2;
            end
    end

endmodule: div_disp


//--------------------------------------------------------------------------------------------

// Consolidated Verilog source
// Top module: rsa_core
// Included modules:
//   - rsa_core_mult
//   - rsa_core_mod
//   - rsa_core_ctrl
//   - rsa_core

// ============================================================
// Module: rsa_core_mult
// ============================================================
module rsa_core_mult #(
  parameter DATA_WIDTH = 4,
  parameter RESET      = 1,
  parameter START      = 1
) (
  input                       mult_clk,
  input                       mult_rst,
  input                       mult_start,
  input  [DATA_WIDTH-1:0]     mult_a,
  input  [DATA_WIDTH-1:0]     mult_b,
  output                      mult_done,
  output [2*DATA_WIDTH-1:0]   mult_c
);
  // Explicitly size the state constants as 3-bit numbers
  	localparam [2:0]INIT      = 3'd0,
                  	ANALYZE   = 3'd1,
                   	SHIFT_ADD = 3'd2,
                   	SHIFT     = 3'd3,
                   	DONE      = 3'd4;

 	reg [2:0] state_reg;
 	reg[2:0] state_ns;
  	reg [$clog2(DATA_WIDTH+1)-1:0] a_cnt;
  	reg [DATA_WIDTH-1:0] a_reg, b_reg;
 	reg [2*DATA_WIDTH-1:0] p_reg, c_reg;
  	reg done_ff;

	// OUTPUT SIGNALS CONNECTIONS
   	assign mult_done = done_ff;
  	assign mult_c    = c_reg;

	// NEXT STATE DECODE LOGIC
	always @ (mult_rst, mult_start, b_reg[DATA_WIDTH-1], a_cnt, state_reg) begin
		if (mult_rst == RESET)
	    	state_ns = INIT;
	    else begin
	     	case(state_reg)
		        INIT:
		        	state_ns = (mult_start == START) ? ANALYZE : INIT;
		        	
		        ANALYZE:
		        	state_ns = (b_reg[DATA_WIDTH-1]) ? SHIFT_ADD : SHIFT;
		        	
		        SHIFT_ADD: begin
		          if (a_cnt != (DATA_WIDTH-1))
		            state_ns = (b_reg[DATA_WIDTH-1]) ? SHIFT_ADD : SHIFT;
		          else
		            state_ns = DONE;
		        end
		        
		        SHIFT: begin
		          if (a_cnt != (DATA_WIDTH-1))
		            state_ns = (b_reg[DATA_WIDTH-1]) ? SHIFT_ADD : SHIFT;
		          else
		            state_ns = DONE;
		        end
		        
		        DONE:
		        	state_ns = INIT;
		        default:
		        	state_ns = INIT;
	    	endcase
	    end
	  end

	always @(posedge mult_clk) begin
    	case(state_reg)
        	INIT: begin
				p_reg   <= 0;
				a_cnt   <= 0;
				done_ff <= 1'b0;
				a_reg   <= mult_a;
				b_reg   <= mult_b;
        	end
			ANALYZE: begin
				b_reg <= {b_reg[DATA_WIDTH-2:0], 1'b0};
			end
			SHIFT_ADD: begin
				p_reg <= a_reg + {p_reg[2*DATA_WIDTH-2:0], 1'b0};
				a_cnt <= a_cnt + 1'b1;
				b_reg <= {b_reg[DATA_WIDTH-2:0], 1'b0};
			end
			SHIFT: begin
				p_reg <= {p_reg[2*DATA_WIDTH-2:0], 1'b0};
				a_cnt <= a_cnt + 1'b1;
				b_reg <= {b_reg[DATA_WIDTH-2:0], 1'b0};
			end
			DONE: begin
				done_ff <= 1'b1;
				c_reg   <= p_reg;
			end
		endcase
		state_reg <= state_ns;
	end
endmodule


// ============================================================
// Module: rsa_core_mod
// ============================================================
// PARAMETROS:
//   DATA_WIDTH  : Largura dos dados (default 8)
//   RESET       : N�vel ativo do reset (default 0)
//   START       : N�vel ativo do sinal de in�cio (default 1)

module rsa_core_mod #(
    parameter DATA_WIDTH = 4,
    parameter RESET      = 1,   // N�vel de reset ativo
    parameter START      = 1    // N�vel ativo para mod_start
)(
    input                         mod_clk,
    input                         mod_rst,
    input                         mod_start,
    input      [2*DATA_WIDTH-1:0] mod_a,
    input      [DATA_WIDTH-1:0]   mod_b,
    output                        mod_done,
    output                        mod_err,
    output     [DATA_WIDTH-1:0]   mod_c
);

  // Defini��o dos estados da FSM (8 estados)
  localparam INIT     = 3'b000,
             CHECK    = 3'b001,
             PREPARE  = 3'b010,
             COMPARE  = 3'b011,
             SUBTRACT = 3'b100,
             SHIFT    = 3'b101,
             DONE     = 3'b110,
             ERROR    = 3'b111;

  // Declara��o dos sinais internos
  reg 	[2:0] state_reg;
  reg	[2:0] state_ns;
  reg	[DATA_WIDTH:0] a_cnt;
  reg	[2*DATA_WIDTH-1:0] t_reg, n_reg;
  reg	[DATA_WIDTH-1:0] r_reg;
  reg	mod_done_ff, mod_err_ff;

  // Atribui��o das sa�das
  assign mod_done = mod_done_ff;
  assign mod_err  = mod_err_ff;
  assign mod_c    = r_reg;

  // L�gica combinacional para o c�lculo do pr�ximo estado (FSM)
  always @(mod_rst, mod_start, t_reg, n_reg, a_cnt, state_reg) begin
    if (mod_rst == RESET)
      state_ns = INIT;
    else begin
      case (state_reg)
        INIT: begin
          if (mod_start == START)
            state_ns = CHECK;
          else
            state_ns = INIT;
        end
        CHECK: begin
          if (n_reg[DATA_WIDTH-1:0] == {DATA_WIDTH{1'b0}})
            state_ns = ERROR;
          else
            state_ns = PREPARE;
        end
        PREPARE: begin
          if (n_reg[2*DATA_WIDTH-2] == 1'b0)
            state_ns = PREPARE;
          else
            state_ns = COMPARE;
        end
        COMPARE: begin
          if (t_reg >= n_reg)
            state_ns = SUBTRACT;
          else
            state_ns = SHIFT;
        end
        SUBTRACT: begin
          if (a_cnt != 0)
            state_ns = COMPARE;
          else
            state_ns = DONE;
        end
        SHIFT: begin
          if (a_cnt != 0)
            state_ns = COMPARE;
          else
            state_ns = DONE;
        end
        DONE:
        	state_ns = INIT;
        ERROR:
        	state_ns = INIT;
        default: state_ns = INIT;
      endcase
    end
  end

  // Bloco sequencial � o clock edge (posedge ou negedge) � escolhido via generate
      always @(posedge mod_clk) begin
        case (state_reg)
          INIT: begin
            mod_done_ff <= 1'b0;
            t_reg       <= mod_a;
            n_reg[DATA_WIDTH-1:0] <= mod_b;
            n_reg[2*DATA_WIDTH-1:DATA_WIDTH] <= {DATA_WIDTH{1'b0}};
            a_cnt       <= {DATA_WIDTH+1{1'b0}};
          end
          CHECK: begin
            // Nada a transferir nesta fase
          end
          PREPARE: begin
            a_cnt <= a_cnt + 1'b1;
            n_reg <= { n_reg[2*DATA_WIDTH-2:0], 1'b0 };
          end
          COMPARE: begin
            // Nenhuma transfer�ncia nesta fase
          end
          SUBTRACT: begin
            t_reg <= t_reg - n_reg;
            n_reg <= { 1'b0, n_reg[2*DATA_WIDTH-1:1] };
            a_cnt <= a_cnt - 1'b1;
          end
          SHIFT: begin
            n_reg <= { 1'b0, n_reg[2*DATA_WIDTH-1:1] };
            a_cnt <= a_cnt - 1'b1;
          end
          DONE: begin
            r_reg       <= t_reg[DATA_WIDTH-1:0];
            mod_done_ff <= 1'b1;
            mod_err_ff  <= 1'b0;
          end
          ERROR: begin
            mod_err_ff  <= 1'b1;
            mod_done_ff <= 1'b1;
            r_reg       <= {DATA_WIDTH{1'b1}};
          end
          default: begin
            // N�o faz nada
          end
        endcase
        state_reg <= state_ns;
      end
endmodule


// ============================================================
// Module: rsa_core_ctrl
// ============================================================
module rsa_core_ctrl #(
    parameter DATA_WIDTH = 4,
    parameter RESET = 1'b1,
    parameter LOAD = 1'b1
)(
    input wire ctrl_clk,
    input wire ctrl_rst,
    input wire ctrl_load,
    input wire [DATA_WIDTH-1:0] ctrl_din,
    input wire ctrl_loadx,
    input wire [DATA_WIDTH-1:0] ctrl_dinx,
    output ctrl_done,
    output ctrl_err,
    output [DATA_WIDTH-1:0] ctrl_c,
    output ctrl_start,
    output [DATA_WIDTH-1:0] ctrl_n,
    output [DATA_WIDTH-1:0] ctrl_m,
    output [DATA_WIDTH-1:0] ctrl_doutx
);

    localparam ONE = 8'd1;
    
    localparam [3:0] 
        INIT    = 4'd0,
        LOAD_M  = 4'd1,
        WAIT_M  = 4'd2,
        LOAD_E  = 4'd3,
        WAIT_E  = 4'd4,
        LOAD_N  = 4'd5,
        WAIT_N  = 4'd6,
        ERROR   = 4'd7,
        CASE0   = 4'd8,
        ANALYZE = 4'd9,
        DONE    = 4'd10,
        CASE1   = 4'd11,
        CASE2   = 4'd12,
        START   = 4'd13;
    
    reg 	[3:0]state_reg;
    reg		[3:0]state_ns;
    
    reg [DATA_WIDTH-1:0] n_reg;
    reg [DATA_WIDTH-1:0] e_reg;
    reg [DATA_WIDTH-1:0] m_reg;
    reg [DATA_WIDTH-1:0] x_reg;
    reg [DATA_WIDTH-1:0] c_reg;
    reg err_ff;
    reg start_ff;
    reg done_ff;
    
    assign ctrl_c = c_reg;
    assign ctrl_n = n_reg;
    assign ctrl_m = m_reg;
    assign ctrl_doutx = x_reg;
    
    assign ctrl_done = done_ff;
    assign ctrl_start = start_ff;
    assign ctrl_err = err_ff;
    
    always @(ctrl_rst, ctrl_load, n_reg, e_reg, ctrl_loadx, state_reg) begin
    	if (ctrl_rst == RESET)
			state_ns = INIT;
    	else
        	case (state_reg)
        	    INIT:
        	    	state_ns = LOAD_M;        	    	
        	    LOAD_M:
        	    	state_ns = (ctrl_load == LOAD) ? WAIT_M : LOAD_M;
        	    WAIT_M:
        	    	state_ns = (ctrl_load == LOAD) ? WAIT_M : LOAD_E;
        	    LOAD_E:
        	    	state_ns = (ctrl_load == LOAD) ? WAIT_E : LOAD_E;
        	    WAIT_E:
        	    	state_ns = (ctrl_load == LOAD) ? WAIT_E : LOAD_N;
        	    LOAD_N:
        	    	state_ns = (ctrl_load == LOAD) ? WAIT_N : LOAD_N;
        	    WAIT_N: begin
        	        if (ctrl_load == LOAD)
        	            state_ns = WAIT_N;
        	        else if (n_reg == 0)
        	            state_ns = ERROR;
        	        else if (e_reg == 0)
        	            state_ns = CASE0;
        	        else if (e_reg == 1)
        	            state_ns = CASE1;
        	        else
        	            state_ns = CASE2;
        	    end
        	    ERROR:
        	    	state_ns = LOAD_M;
        	    CASE0:
        	    	state_ns = ANALYZE;
        	    
        	    ANALYZE: begin
        	        if (!ctrl_loadx)
        	            state_ns = ANALYZE;
        	        else
        	        	if (e_reg == 0)
        	            	state_ns = DONE;
	        	        else
        	            	state_ns = START;
        	    end
        	    DONE:
        	    	state_ns = LOAD_M;
        	    CASE1:
        	    	state_ns = ANALYZE;
        	    CASE2:
        	    	state_ns = ANALYZE;
        	    START:
        	    	state_ns = ANALYZE;
        	    default:
        	    	state_ns = INIT;
        	endcase
    end
    
    always @(posedge ctrl_clk) begin
		case (state_reg)
        	INIT: begin
            	err_ff		<= 1'b0;
                start_ff	<= 1'b0;
                done_ff		<= 1'b0;
        	end
			LOAD_M: begin
            	m_reg 		<= ctrl_din;
                x_reg 		<= ctrl_din;
                done_ff 	<= 1'b0;
            end
            WAIT_M:begin
            end
            LOAD_E:
            	e_reg 		<= ctrl_din;
            WAIT_E:begin
            end
			LOAD_N:
				n_reg 		<= ctrl_din;
            ERROR: begin
            	done_ff 	<= 1'b1;
                err_ff 		<= 1'b1;
                c_reg 		<= {DATA_WIDTH{1'b1}};
            end
            CASE0: begin
				start_ff	<= 1'b1;
				m_reg		<= ONE;
				x_reg		<= ONE;
			end
			ANALYZE: begin
				x_reg		<= ctrl_dinx;
				start_ff	<= 1'b0;
			end	
			DONE: begin
				c_reg		<= x_reg;
				done_ff		<= 1'b1;
				err_ff		<= 1'b0;				
			end	
			CASE1: begin
				x_reg		<= ONE;
				start_ff	<= 1'b1;
				e_reg		<= e_reg - 1;
			end
			CASE2: begin
				start_ff	<= 1'b1;
				e_reg		<= e_reg - 2;
			end
			START: begin
				start_ff	<= 1'b1;
				e_reg		<= e_reg - 1;
            end
		endcase
        state_reg <= state_ns;
    end
endmodule


// ============================================================
// Module: rsa_core (TOP)
// ============================================================
module rsa_core #(
    parameter DATA_WIDTH = 4,
    parameter RESET = 1'b1,
    parameter LOAD = 1'b1
)
(
    input wire core_clk,
    input wire core_rst,
    input wire core_load,
    input wire [DATA_WIDTH-1:0] core_din,
    output wire core_done,
    output wire core_err,
    output wire [DATA_WIDTH-1:0] core_dout,
    output wire core_clk_o
);

    assign core_clk_o = core_clk;

    // Internal signals
    wire ctrl_start_sig;
    wire [DATA_WIDTH-1:0] ctrl_m_sig;
    wire [DATA_WIDTH-1:0] ctrl_n_sig;
    wire [DATA_WIDTH-1:0] ctrl_doutx_sig;

    wire mult_done_sig;
    wire [2*DATA_WIDTH-1:0] mult_c_sig;

    wire mod_done_sig;
    wire [DATA_WIDTH-1:0] mod_c_sig;

    // Component instantiations
    rsa_core_mult #(
        .DATA_WIDTH(DATA_WIDTH),
        .RESET(RESET),
        .START(1'b1)
    ) rsa_core_mult_blk (
        .mult_clk(core_clk),
        .mult_rst(core_rst),
        .mult_start(ctrl_start_sig),
        .mult_a(ctrl_m_sig),
        .mult_b(ctrl_doutx_sig),
        .mult_done(mult_done_sig),
        .mult_c(mult_c_sig)
    );

    rsa_core_mod #(
        .DATA_WIDTH(DATA_WIDTH),
        .RESET(RESET),
        .START(1'b1)
    ) rsa_core_mod_blk (
        .mod_clk(core_clk),
        .mod_rst(core_rst),
        .mod_start(mult_done_sig),
        .mod_a(mult_c_sig),
        .mod_b(ctrl_n_sig),
        .mod_done(mod_done_sig),
        .mod_err(), // Deixe isso desconectado apenas se for realmente necessário
        .mod_c(mod_c_sig)
    );

    rsa_core_ctrl #(
        .DATA_WIDTH(DATA_WIDTH),
        .RESET(RESET),
        .LOAD(LOAD)
    ) rsa_core_ctrl_blk (
        .ctrl_clk(core_clk),
        .ctrl_rst(core_rst),
        .ctrl_load(core_load),
        .ctrl_din(core_din),
        .ctrl_loadx(mod_done_sig),
        .ctrl_dinx(mod_c_sig),
        .ctrl_done(core_done),
        .ctrl_err(core_err),
        .ctrl_c(core_dout),
        .ctrl_start(ctrl_start_sig),
        .ctrl_n(ctrl_n_sig),
        .ctrl_m(ctrl_m_sig),
        .ctrl_doutx(ctrl_doutx_sig)
    );

endmodule
