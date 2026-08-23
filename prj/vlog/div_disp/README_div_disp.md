# Divisor para Dois Displays de 7 Segmentos

## Descrição

O módulo **div_disp** implementa a conversão de um valor binário de 4 bits para representação decimal em dois displays de 7 segmentos.

O circuito recebe um número binário entre 0 e 15 e separa esse valor em dois dígitos decimais: **dezenas** e **unidades**. Cada dígito é encaminhado a uma instância do módulo **disp7seg**, responsável por converter o valor decimal para o padrão correspondente dos sete segmentos do display.

Para valores menores ou iguais a 9, somente o display das unidades é utilizado, mantendo o display das dezenas apagado.

## Módulos

O projeto é dividido em dois módulos principais:

| Módulo | Descrição |
|---|---|
| `div_disp` | Módulo principal responsável por separar o valor de entrada em dezenas e unidades e controlar os dois displays. |
| `disp7seg` | Decodificador combinacional responsável por converter um dígito decimal de 4 bits para o padrão de 7 segmentos correspondente. |

## Entrada e saída

### Módulo `div_disp`

| Sinal | Direção | Largura | Descrição |
|---|---|---:|---|
| `num` | Entrada | 4 bits | Valor binário a ser exibido. Pode representar números entre 0 e 15. |
| `disp1` | Saída | 7 bits | Controle dos segmentos do display correspondente às dezenas. |
| `disp2` | Saída | 7 bits | Controle dos segmentos do display correspondente às unidades. |

### Módulo `disp7seg`

| Sinal | Direção | Largura | Descrição |
|---|---|---:|---|
| `bin` | Entrada | 4 bits | Dígito decimal entre 0 e 9 a ser convertido. |
| `dig` | Saída | 7 bits | Padrão lógico aplicado aos sete segmentos do display. |

## Comportamento esperado

O circuito divide logicamente o valor presente em `num` em dois dígitos decimais.

Para valores entre 0 e 9:

- O valor é encaminhado diretamente ao dígito das unidades;
- O dígito das dezenas recebe zero internamente;
- O primeiro display permanece apagado;
- O segundo display apresenta o valor de `num`.

Para valores entre 10 e 15:

- O dígito das dezenas recebe o valor 1;
- O dígito das unidades recebe a diferença entre `num` e 10;
- Os dois displays permanecem ativos.

A representação decimal pode ser descrita por:

**num = 10 × dezena + unidade**

Como a entrada possui apenas 4 bits, seu maior valor possível é 15. Dessa forma, o dígito das dezenas nunca ultrapassa 1.

## Arquitetura

O módulo `div_disp` realiza inicialmente a separação do valor binário em dezenas e unidades.

Os dois valores resultantes são encaminhados para duas instâncias independentes de `disp7seg`:

```text
                         num[3:0]
                            |
                            v
                    +---------------+
                    |    div_disp   |
                    |               |
                    | separação dos |
                    |    dígitos    |
                    +-------+-------+
                            |
                    +-------+-------+
                    |               |
                    v               v
               dezena[3:0]     unidade[3:0]
                    |               |
                    v               v
              +-----------+   +-----------+
              | disp7seg  |   | disp7seg  |
              +-----+-----+   +-----+-----+
                    |               |
                    v               v
               disp1[6:0]      disp2[6:0]
```

O módulo `disp7seg` funciona como um decodificador combinacional. Para cada valor decimal válido entre 0 e 9, é produzido um padrão de 7 bits correspondente ao número que deve ser apresentado.

## Codificação dos segmentos

A implementação utiliza a seguinte tabela de conversão:

| Dígito | Entrada `bin` | Saída `dig` |
|---:|:---:|:---:|
| 0 | `0000` | `1111110` |
| 1 | `0001` | `0110000` |
| 2 | `0010` | `1101101` |
| 3 | `0011` | `1111001` |
| 4 | `0100` | `0110011` |
| 5 | `0101` | `1011011` |
| 6 | `0110` | `1011111` |
| 7 | `0111` | `1110000` |
| 8 | `1000` | `1111111` |
| 9 | `1001` | `1110011` |

Os padrões apresentados pressupõem segmentos ativos em nível lógico alto e a ordem de bits adotada pelo projeto para os sete segmentos.

## Características

- Circuito puramente combinacional;
- Não utiliza clock;
- Não utiliza reset;
- Entrada binária de 4 bits;
- Representa valores entre 0 e 15;
- Utiliza dois displays de 7 segmentos;
- Suprime o zero à esquerda para valores entre 0 e 9;
- Utiliza duas instâncias independentes do decodificador `disp7seg`;
- Separa a lógica de conversão decimal da lógica de decodificação dos segmentos;
- Não introduz latência em ciclos de clock.

## Exemplo de funcionamento

Considerando `num = 4'b1101`, correspondente ao valor decimal 13:

- A dezena é igual a 1;
- A unidade é igual a 3;
- `disp1` recebe o padrão correspondente ao número 1;
- `disp2` recebe o padrão correspondente ao número 3.

Portanto, os dois displays apresentam:

```text
13
```

Para `num = 4'b0111`, correspondente ao valor decimal 7:

- O primeiro display permanece apagado;
- O segundo display apresenta o número 7.

O resultado visual é equivalente a:

```text
 7
```

sem a apresentação de um zero à esquerda.

## Aplicações

O módulo pode ser utilizado em estruturas digitais que necessitem apresentar pequenos valores numéricos, como:

- Contadores;
- Interfaces de depuração;
- Indicadores numéricos em FPGA;
- Visualização de resultados de operações aritméticas;
- Sistemas didáticos de lógica digital;
- Interfaces simples para circuitos combinacionais;
- Exibição de estados ou valores internos de outros módulos.

## Observações

A entrada `num` possui 4 bits e, portanto, representa somente valores entre 0 e 15. A arquitetura não foi projetada para representar toda a faixa decimal de 00 a 99.

O módulo `disp7seg` deve possuir uma condição definida para entradas fora da faixa decimal de 0 a 9, evitando que valores inválidos deixem a saída sem atribuição em uma descrição combinacional.

A codificação dos segmentos depende da configuração elétrica do display utilizado. Os padrões definidos neste projeto consideram segmentos ativos em nível lógico alto. Caso o hardware utilize lógica ativa em nível baixo, os valores de saída deverão ser invertidos.

Como `disp2` representa continuamente a saída do segundo decodificador, sua interconexão pode ser realizada diretamente por atribuição contínua com `assign`. O mesmo princípio pode ser aplicado a outras conexões puramente combinacionais quando não houver necessidade de atribuição procedural.
