`timescale 1ns / 1ns
`include "rsa_core_io.v"

module rsa_core_io_tb;

    // ---------------------------------------------------------------------------
    // PARAMETERS
    // ---------------------------------------------------------------------------
    parameter DATA_WIDTH = 4;
    parameter D_WID      = DATA_WIDTH - 1;
    parameter CLK_PERIOD = 10;

    // ---------------------------------------------------------------------------
    // SIGNAL DECLARATIONS
    // ---------------------------------------------------------------------------
    reg             core_clk;
    reg             core_rst;
    reg             core_load;
    reg [D_WID:0]   core_din;

    // Sinais provenientes do rsa_core
    reg             core_done;
    reg             core_err;
    reg [D_WID:0]   core_dout;

    wire [1:0]      core_clk_o;
    wire [5:0]      core_led_o;

    // Displays 1 e 2: entrada RSA
    wire [6:0]      core_din_disp1;
    wire [6:0]      core_din_disp2;

    // Displays 3 e 4: saída RSA
    wire [6:0]      core_dout_disp3;
    wire [6:0]      core_dout_disp4;

    // ---------------------------------------------------------------------------
    // DUV INSTANTIATION
    // ---------------------------------------------------------------------------
    rsa_core_io #(
        .DATA_WIDTH(DATA_WIDTH)
    ) duv (
        .core_clk       (core_clk),
        .core_rst       (core_rst),
        .core_load      (core_load),
        .core_din       (core_din),
        .core_done      (core_done),
        .core_err       (core_err),
        .core_dout      (core_dout),
        .core_clk_o     (core_clk_o),
        .core_led_o     (core_led_o),
        .core_din_disp1 (core_din_disp1),
        .core_din_disp2 (core_din_disp2),
        .core_dout_disp3(core_dout_disp3),
        .core_dout_disp4(core_dout_disp4)
    );

    // ---------------------------------------------------------------------------
    // SIMULATION DATA (VCD DUMP)
    // ---------------------------------------------------------------------------
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, rsa_core_io_tb);
    end

    // ---------------------------------------------------------------------------
    // CLOCK GENERATION
    // ---------------------------------------------------------------------------
    initial begin
        core_clk = 1'b0;
        forever #(CLK_PERIOD / 2) core_clk = ~core_clk;
    end

    // ---------------------------------------------------------------------------
    // PROCESSO PRINCIPAL DE TESTE
    // ---------------------------------------------------------------------------
    initial begin
        // Inicializacao apenas dos sinais de controle e dados (core_clk tratado no outro bloco)
        core_rst  = 1'b0;
        core_load = 1'b0;
        core_done = 1'b0;
        core_err  = 1'b0;
        core_din  = 4'd0;
        core_dout = 4'd0;

        $display("==================================================");
        $display("         INICIANDO TESTBENCH: RSA CORE I/O        ");
        $display("==================================================");

        // 1. Aplicando Reset do Sistema
        #15;
        core_rst = 1'b1;
        $display("[%0t ns] Reset ativado.", $time);
        #(CLK_PERIOD * 2);
        core_rst = 1'b0;
        $display("[%0t ns] Reset desativado.", $time);
        #(CLK_PERIOD);
        
        // 2. Teste de Displays com Números Menores e Maiores que 9
        $display("\n--- Teste 1: Displays de Entrada e Saida ---");
        core_din  = 4'd5;  // Deve exibir 0 no disp1 e 5 no disp2
        core_dout = 4'd12; // Deve exibir 1 no disp3 e 2 no disp4
        #(CLK_PERIOD);
        $display("[%0t ns] Entrada (core_din) = %d | Saida (core_dout) = %d", $time, core_din, core_dout);

        // 3. Teste do Efeito LOAD Snake
        $display("\n--- Teste 2: Ativacao do LOAD (Snake LED) ---");
        core_load = 1'b1;
        #(CLK_PERIOD);
        core_load = 1'b0; // Pulso de borda de subida
        
        // Espera ciclos de clock para ver a rotacao do Snake nos LEDs
        repeat (8) begin
            #(CLK_PERIOD);
            $display("[%0t ns] LED Mux (LOAD Snake State) = %b", $time, core_led_o);
        end

        // 4. Teste da Sinalizacao DONE (Prioridade Mux: DONE > LOAD)
        $display("\n--- Teste 3: Ativacao do DONE ---");
        core_done = 1'b1;
        #(CLK_PERIOD * 2);
        $display("[%0t ns] LED Mux (DONE Ativo - Esperado 111111) = %b", $time, core_led_o);

        // 5. Teste da Sinalizacao ERROR (Prioridade Mux: ERROR > DONE > LOAD)
        $display("\n--- Teste 4: Ativacao do ERROR (Prioridade Maxima) ---");
        core_err = 1'b1;
        #(CLK_PERIOD);
        $display("[%0t ns] LED Mux (ERROR Ativo com Clock ALTO) = %b", $time, core_led_o);
        #(CLK_PERIOD / 2); // Borda de descida do clock para ver inversao
        $display("[%0t ns] LED Mux (ERROR Ativo com Clock BAIXO) = %b", $time, core_led_o);
        #(CLK_PERIOD / 2);

        // 6. Limpando Erros e Finalizando
        $display("\n--- Teste 5: Restaurando Sinais para Repouso ---");
        core_err  = 1'b0;
        core_done = 1'b0;
        #(CLK_PERIOD * 2);
        $display("[%0t ns] LED Mux (Estado Final Inativo - Esperado 000000) = %b", $time, core_led_o);

        $display("==================================================");
        $display("            TESTE CONCLUIDO COM SUCESSO           ");
        $display("==================================================");
        $finish;
    end

    // Monitoramento continuo para depuracao via terminal
    initial begin
        $monitor("Tempo: %0t ns | DIN: %d | DOUT: %d | Load: %b | Done: %b | Err: %b | LEDs: %b",
                 $time, core_din, core_dout, core_load, core_done, core_err, core_led_o);
    end

endmodule