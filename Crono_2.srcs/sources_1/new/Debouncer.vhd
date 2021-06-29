library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debouncer is
    port ( 
           clk     : in std_logic;      --Se�al de reloj
           btn_in  : in std_logic;      --Se�al de boton de entrada
           reset_n   : in std_logic;    --Se�al de RESET negada
           btn_out : out std_logic      --Se�al de salida al circuito
          );
end debouncer;

architecture Behavioral of debouncer is

--Utilizamos un registro de 10 bits en el que cada ciclo vamos trasladando
--su informaci�n antigua a la izquierda a la vez que introducimos en el bit
--m�s a la derecha con la informaci�n del pulsador de entrada en ese momento
signal sreg : std_logic_vector(9 downto 0);
begin
    process (clk, reset_n)
    begin
    
    if reset_n = '0' then           --Implementaci�n del RESET
        sreg <= "0000000000";
    
    elsif rising_edge(clk) then     --Traslado de los bits
            sreg <= sreg(8 downto 0) & btn_in;
        end if;
    end process;
   
--La se�al de salida ser� 1 cuando no haya rebotes en el pulsador de entrada
--y s�lo quede el recuerdo de su �ltima activaci�n seguida de 9 ceros. 
    with sreg select           
        btn_out <= '1' when "1000000000",
        '0' when others;
end Behavioral;