library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity debouncer_tb is
end;

architecture bench of debouncer_tb is

  component debouncer
      port ( clk     : in std_logic;
             btn_in  : in std_logic; 
             reset_n : in std_logic;
             btn_out : out std_logic
            );
  end component;

--Señales para modificar la información
  signal clk: std_logic;
  signal btn_in: std_logic;
  signal reset_n: std_logic;
  signal btn_out: std_logic ;

--Periodo del reloj
 constant CLK_PERIOD	 : time		:= 1 sec / 100_000_000;

begin

  uut: debouncer port map ( clk     => clk,
                            btn_in  => btn_in,
                            reset_n => reset_n,
                            btn_out => btn_out );

--Proceso de generación de la señal del reloj       
  clkgen: process
  begin
    	CLK	<= '0';
        wait for 0.5 * CLK_PERIOD;
        CLK	<= '1';
        wait for 0.5 * CLK_PERIOD;
  end process;

--Pulso de RESET inicial
	RESET_N <= '0' after 0.25*CLK_PERIOD,
    		   '1' after 0.75*CLK_PERIOD;

--Proceso de Prueba
  stimulus: process
  begin
                            --Damos un pulso positivo del pulsador de entrada
    btn_in <= '1';
    wait for 2 * CLK_PERIOD;
                            --Desactivamos el pulsador de entrada y esperamos hasta que
    btn_in <= '0';          --se active el de salida
    wait until btn_out = '1';
    wait for 0.5 * CLK_PERIOD;
    
                            --Ahora vamos a dar dos pulsos de entrada para comprobar que
    btn_in <= '1';          --el segundo pulso resetea el tiempo de activación del pulsador
    wait for 2 * CLK_PERIOD;--de salida
    btn_in <= '0';
    wait for CLK_PERIOD;
    btn_in <= '1';
    wait for CLK_PERIOD;
    
    btn_in <= '0';          
    wait until btn_out = '1';
    
    wait;
  
  end process;

end;