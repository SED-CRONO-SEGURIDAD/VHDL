library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Decoder is
    port(
        RESET_N     : in std_logic;                         --RESET Negado
        code        : in std_logic_vector(3 downto 0);      --C�digo de n�mero en binario del n�mero a imprimir
        digsel      : in std_logic_vector(7 downto 0);      --C�digo de d�gitos a encender
        
        segments    : out std_logic_vector(6 downto 0);     --C�digo de salida a displays
        digits      : out std_logic_vector(7 downto 0)      --D�gitos encendidos
    );
end entity Decoder;


--La clase Decoder es un decodificador de la informaci�n que se le introduce en c�digode 4 bits para la impresi�n
--de los n�meros del 0 al 9 y de diferentes caracteres en los diferentes d�gitos de los displays
architecture Dataflow of Decoder is
--Variable auxiliar para el tratamiento de la informaci�n
signal digitos      : std_logic_vector(7 downto 0);

begin
    with code select
        segments <=  "0000001" when "0000",  --0
                     "1001111" when "0001",  --1
                     "0010010" when "0010",  --2
                     "0000110" when "0011",  --3
                     "1001100" when "0100",  --4
                     "0100100" when "0101",  --5
                     "0100000" when "0110",  --6
                     "0001111" when "0111",  --7
                     "0000000" when "1000",  --8
                     "0000100" when "1001",  --9
                     "1000001" when "1010",  --U
                     "0011000" when "1011",  --P
                     "1000010" when "1100",  --d
                     "1100010" when "1101",  --o
                     "1111110" when others;  --Gui�n

    --Conectamos la entrada a la salida               
    digitos <= digsel;       
    --Implementaci�n del RESET_N
    digits <= digitos when RESET_N = '1' else
    		  "11111111" when RESET_N = '0';   --Si se resetea se apagan todos los d�gitos
    			
end architecture Dataflow;