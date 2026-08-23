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
