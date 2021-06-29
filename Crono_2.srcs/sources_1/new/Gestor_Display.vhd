library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Gestor_Display is
    --Esta es la frecuencia de impresión de los números en los displays
    generic (frec_emision: integer:=200_000); --Para 500 HZ usamos 200 000
    port(
        RESET_N     : in std_logic;                         --RESET Negado
        CLK         : in std_logic;                         --Señal de reloj
        vector      : in std_logic_vector(31 downto 0);     --Información a imprimir
        
        code        : out std_logic_vector(3 downto 0);      --Código de número en binario del número a imprimir
        digsel      : out std_logic_vector(7 downto 0);      --Código de dígitos a encender
        punto       : out std_logic                          --Punto de separación entre minutos y unidades
    );
end entity Gestor_Display;


architecture Behavioral of Gestor_Display is

    --Clock Enable
signal CE : std_logic := '0';
    --Señal para la cuenta del prescaler
signal cuenta : integer range 0 to frec_emision := 0;
    --Señal para el cambio de estado del emisor
signal n  : integer range 0 to 7 := 0;

begin

--Proceso de preescalado de la señal del reloj para conseguir una impresión correcta
--de los números en los displays
    preescalado_reloj: process (CLK, RESET_N)

    begin
        --Si se resetea, se inicia la cuenta, o se pausa; se empieza a contar desde 0
        if RESET_N = '0' then
		  cuenta <= 0;
		  CE <= '0';
		elsif rising_edge(CLK) then
			if (cuenta = frec_emision) then      --Cuando se llega a la frecuencia de emisión
				cuenta <= 0;                     --se habilida la señal CE y se pone la cuenta
				CE <= '1';                       --a cero.
			else
				cuenta <= cuenta + 1;           --Siempre que no se haya llegado a la frecuencia 
				CE <= '0';                      --de emisión se aumenta la cuenta y se pone CE a 0
			end if;
		end if;   
	end process;
	
--Proceso que cambia el dígito de los displays que se quiere imprimir. Cambia cada pulso de CE
	cambio_display: process (CLK)
	begin
	   if RESET_N = '0' then
	       n <= 0;
	   elsif rising_edge(CLK) and CE = '1' then
	       if n = 7 then
	          n <= 0;
	       else
	          n <= n + 1;
	       end if;	          
	   end if;
	end process;
	
--Proceso que recoge la información que se le pasa a través de la variable "vector" y la reparte
--en las variables asociadas a los diferentes dígitos para su correcta impresión en los displays
	salida: process (CLK, RESET_N)
	
	variable dig1, dig2, dig3, dig4, dmin, umin, dseg, useg : std_logic_vector(3 downto 0) := "0000";
	
	begin
	   dig1 := vector(31 downto 28);
	   dig2 := vector(27 downto 24);
	   dig3 := vector(23 downto 20);
	   dig4 := vector(19 downto 16);
	   dmin := vector(15 downto 12);
       umin := vector(11 downto 8);
       dseg := vector(7 downto 4);
       useg := vector(3 downto 0);
	
	   case n is
	       when 0 =>
	           code <= dig1;           --Los dígitos a encender se habilitan
	           digsel <= "01111111";   --con lógica negativa
	           punto <= '1';
	       when 1 =>                   
	           code <= dig2;
	           digsel <= "10111111";
	           punto <= '1';
	       when 2 =>
	           code <= dig3;
	           digsel <= "11011111";
	           punto <= '1';
	       when 3 =>
	           code <= dig4;
	           digsel <= "11101111";
	           punto <= '1';
	       when 4 =>
	           code <= dmin;
	           digsel <= "11110111";
	           punto <= '1';
	       when 5 =>                   --El punto de separación entre min
	           code <= umin;           --y seg forma parte del display 6
	           digsel <= "11111011";
	           punto <= '0';
	       when 6 =>
	           code <= dseg;
	           digsel <= "11111101";
	           punto <= '1';
	       when 7 =>
	           code <= useg;
	           digsel <= "11111110";
	           punto <= '1';
	       when others =>
	           code <= "0000";
	           digsel <= "11111111";
	           punto <= '1';
	       end case;
	       
	end process;
end Behavioral;
