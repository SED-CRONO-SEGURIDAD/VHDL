library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity Counter_tb is
end;

architecture bench of Counter_tb is

  component Counter
      port(
        RESET_N     : in std_logic;
        CLK         : in std_logic;
        estado      : in std_logic_vector(1 downto 0); 
        
        valor       : out std_logic_vector(15 downto 0); 
        limite      : out std_logic                      
      );
  end component;

  signal RESET_N: std_logic;
  signal CLK: std_logic;
  signal Estado: std_logic_vector(1 downto 0);
  
  signal valor: std_logic_vector(15 downto 0);
  signal limite: std_logic;
  
  constant CLK_PERIOD	 : time		:= 1 sec / 100_000_000;		--Periodo del Reloj 10 ns

begin

 uut: Counter
    port map ( RESET_N => RESET_N,
               CLK     => CLK,
               estado  => estado,
               valor   => valor,
               limite  => limite);

 clkgen: process
  begin
    	CLK	<= '0';
        wait for 0.5 * CLK_PERIOD;
        CLK	<= '1';
        wait for 0.5 * CLK_PERIOD;
  end process;

	--Pulso de reset inicial
  RESET_N <= '0' after 0.25*CLK_PERIOD,
    		 '1' after 0.75*CLK_PERIOD;

  stimulus: process
  begin
    
    --Comprobamos que en el estado inicial no se cuenta
    estado <= "00";
    wait for 100 ns;    
    
    --Comprobamos que en estado de cuenta arribe se cuenta
    estado <= "01";
    wait for 300 ns;

    --Comprobamos que en estado de pausa se conserva el numero
    estado <= "10";
    wait for 100 ns;
    
    --Comprobamos que en estado de cuenta abajo se cuenta
    --Esperamos a que la variable limite se ponga a 1 al alzanzarse
    --el límite de la cuenta por abajo
    estado <= "11";
    wait for 400 ns;

    --Pasamos a estado 10 para que la variable limite se ponga a 0
    estado <= "10";
    wait for 40 ns;
    
    --Comprobamos que en estado de cuenta arribe se cuenta
    estado <= "01";
    wait for 100 ns;
    
   
   wait;            --!!!SI NO SE PONE ESTE WAIT NO CUENTA EL PROGRAMA
    
  end process;
  
end;