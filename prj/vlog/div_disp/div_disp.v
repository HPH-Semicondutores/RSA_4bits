
//--------------------------------------------------------------------------------------------
module disp7seg(
    //Entradas:
    input       [3:0] bin,                  // Entrada de 4 bits pois vai de 0 a 9.
    
    //Saidas
    output reg  [6:0] dig                   // 7 pinos de saida, pois são 7 segmentos.
);
 
   always @(*)
   begin
        case (bin)
            4'b0000: dig = 7'b1111110;      //0
            4'b0001: dig = 7'b0110000;      //1
            4'b0010: dig = 7'b1101101;      //2    
            4'b0011: dig = 7'b1111001;      //3
            4'b0100: dig = 7'b0110011;      //4
            4'b0101: dig = 7'b1011011;      //5
            4'b0110: dig = 7'b1011111;      //6
            4'b0111: dig = 7'b1110000;      //7       
            4'b1000: dig = 7'b1111111;      //8 
            4'b1001: dig = 7'b1110011;      //9
            default: dig = 7'b0000000;      //Desligado
        endcase
   end
endmodule: disp7seg

//--------------------------------------------------------------------------------------------
module div_disp(
    input  wire [3:0] num,                  // Entrada de 4 bits, pois vai de 0 a 15.
    output reg  [6:0] disp1, disp2          // Saídas de 7 bits, pois são 7 segmentos.
);

reg  [3:0] b1, b2;                          // Variáveis temporáris para armazenar os dígitos das dezenas e unidades.

wire [3:0]  bin1 = b1,                      // Atribui o valor de b1 à variável bin1
            bin2 = b2;                      // Atribui o valor de b2 à variável bin2

wire [6:0] dig1, dig2;                      // Variáveis para transpassar os valores dos dígitos convertidos para 7 segmentos.

// Instanciação do módulo disp7seg para converter os dígitos binários em sinais para os displays de 7 segmentos.
disp7seg dp1  (
                .bin(bin1), 
                .dig(dig1)
                );

// Instanciação do módulo disp7seg para converter os dígitos binários em sinais para os displays de 7 segmentos.
disp7seg dp2  (
                .bin(bin2),
                .dig(dig2)
                );

always@(*)
    begin
        if(num > 9) 
            begin
                b1      = num / 10;             // Divisão inteira para obter o dígito das dezenas
                b2      = num % 10;             // Resto da divisão para obter o dígito das unidades
                disp1   = dig1;                 // Atribui o valor do dígito das dezenas ao display 1
                disp2   = dig2;                 // Atribui o valor do dígito das unidades ao display 2
            end
        else 
            begin
                b1      = 4'b0000;              // Se o número for menor ou igual a 9, o dígito das dezenas é 0
                b2      = num;                  // O dígito das unidades é o próprio número
                disp1   = 7'b0000000;           // Display off for the first digit
                disp2   = dig2;                 // Atribui o valor do dígito das unidades ao display 2
            end
    end

endmodule: div_disp

//--------------------------------------------------------------------------------------------