library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_Std.all;

entity Gestor_Display_tb is
end;

architecture bench of Gestor_Display_tb is
    
    --Inputs
    signal RESET_N : std_logic;
    signal CLK : std_logic;
    signal vector : std_logic_vector(31 downto 0);
    
    --Outputs
    signal code : std_logic_vector(3 downto 0);
    signal digsel : std_logic_vector(7 downto 0);
    
    component Gestor_Display
        generic (frec_emision: integer:=2_000_000); --Para 50 HZ usamos 2 000 000
        port(
            RESET_N     : in std_logic;
            CLK         : in std_logic;
            vector      : in std_logic_vector(31 downto 0);
            
            code        : out std_logic_vector(3 downto 0);
            digsel      : out std_logic_vector(7 downto 0)
        );
    end component Gestor_Display;
        
constant CLK_PERIOD	 : time		:= 1 sec / 100_000_000;
    
begin

utt: Gestor_Display
    generic map( frec_emision => 2) --Para las simulaciones reducimos considerablemente
    port map(                       --la frecuencia de emisión, para poder observar
        RESET_N     => RESET_N,     --los cambios de dígitos
        CLK         => CLK,
        vector      => vector,
        
        code        => code,
        digsel      => digsel
    );
    
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
    		   
--Como estímulos vamos a introducir diferentes cuartetos de bits y observar 
--cómo la clase los reparte en los diferentes dígitos a imprimir
  stimulus: process
  begin		   
    vector <= "1111"&"1111"&"1111"&"1111"&
              "0000"&"0000"&"0000"&"0000";
    wait for 300 ns;
    
    vector <= "1010"&"1011"&"1111"&"1111"&
              "0000"&"0001"&"0110"&"0101";
    wait for 300 ns;
    
    vector <= "1111"&"1111"&"1100"&"1101"&
              "1001"&"1000"&"0011"&"0000";
    wait for 300 ns;
    
    wait;	   
  end process;
end bench;
