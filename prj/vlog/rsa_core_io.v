

module rsa_core_io(


);




module disp7seg(
    input       [3:0] bin,        //entrada de 4 bits pois vai de 0 a 9.
    
    //Saidas
    output reg  [6:0] dig   //7 pinos de saida, pois são 7 segmentos.
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
        endcase
   end
endmodule: disp7seg

module div_disp(
    input  wire [3:0] num,
    output reg  [6:0] disp1, disp2
);

localparam      n1 = 4'b0000,
                n2 = 4'b0001,
                n3 = 4'b0010,
                n4 = 4'b0011,
                n5 = 4'b0100,
                n6 = 4'b0101,
                n7 = 4'b0110,
                n8 = 4'b0111,
                n9 = 4'b1000;

wire [3:0] bin1, bin2;
wire [6:0] dig1, dig2;

disp7seg disp1  (
                .bin(bin1),
                .dig(dig1)
                );

disp7seg disp2  (
                .bin(bin2),
                .dig(dig2)
                );

always@(*)
    begin
        case(num)
            n1: 
            begin
                bin1 = 4'b0000;
                bin2 = 4'b0001;
                disp1 = dig1;
                disp2 = dig2;
            end
            n2: 
            begin
                bin1 = 4'b0000;
                bin2 = 4'b0010;
                disp1 = dig1;
                disp2 = dig2;
            end
            n3: 
            begin
                bin1 = 4'b0000;
                bin2 = 4'b0011;
                disp1 = dig1;
                disp2 = dig2;
            end
            n4: 
            begin
                bin1 = 4'b0000;
                bin2 = 4'b0100;
                disp1 = dig1;
                disp2 = dig2;
            end
            n5: 
            begin
                bin1 = 4'b0000;
                bin2 = 4'b0101;
                disp1 = dig1;
                disp2 = dig2;
            end
            n6: 
            begin
                bin1 = 4'b0000;
                bin2 = 4'b0110;
                disp1 = dig1;
                disp2 = dig2;
            end
            n7: 
            begin
                bin1 = 4'b0000;
                bin2 = 4'b0111;
                disp1 = dig1;
                disp2 = dig2;
            end
            n8: 
            begin
                bin1 = 4'b0000;
                bin2 = 4'b1000;
                disp1 = dig1;
                disp2 = dig2;
            end
            n9: 
            begin
                bin1 = 4'b0000;
                bin2 = 4'b1001;
                disp1 = dig1;
                disp2 = dig2;
            end
            default:
            begin
                bin1 = 4'b0000;
                bin2 = 4'b0000;
                disp1 = dig1;
                disp2 = dig2;
            end
        endcase
    end

endmodule: div_disp