library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Prescaler is
    -- VALOR PARA CONSEGUIR 1Hz 50000000 en onda cuadrada/100000000 en pulso único
    generic (frec: integer:=50000000);  
    port(
        CLK         : in std_logic;     --Señal de reloj de entrada
        
        prescaled   : out std_logic     --Señal de reloj de salida de 1Hz
    );
end entity Prescaler;

--Esta clase emite una onda de salida acorde a un prescalado del reloj
--para poder conseguir una señal de 1 Hz

architecture Behavioral of Prescaler is

signal temp : std_logic := '0';

begin
    preescalado_reloj: process (CLK)

    variable cnt : integer := 0;
    begin
        if rising_edge(CLK) then
			if (cnt=frec) then
			    cnt := 0;
				temp <= not temp;
			else
			    cnt := cnt + 1;				
			end if;
		end if;
	end process;
	
	prescaled <= temp;

end architecture BEhavioral;