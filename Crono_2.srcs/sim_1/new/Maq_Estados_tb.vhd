library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_Std.all;

entity Maq_Estados_tb is
end;

architecture bench of Maq_Estados_tb is
    
    --Inputs
    signal RESET_N  : std_logic;
    signal CLK      : std_logic;
    signal IN_P     : std_logic;
    signal CAMBIO   : std_logic;
    signal limite   : std_logic;
    signal numero   : std_logic_vector(15 downto 0);
    
    --Outputs
    signal estado   :  std_logic_vector(1 downto 0);
    signal valor    :  std_logic_vector(31 downto 0);
    
    component Maq_Estados is
    port(  
        RESET_N     : in std_logic;                        
        CLK         : in std_logic;                         
        IN_P        : in std_logic;                        
        CAMBIO      : in std_logic;                       
        limite      : in std_logic;                       
        numero      : in std_logic_vector(15 downto 0);  
        
        estado      : out std_logic_vector(1 downto 0);    
        valor       : out std_logic_vector(31 downto 0)     
        );
    end component Maq_Estados; 
        
constant CLK_PERIOD	 : time		:= 1 sec / 100_000_000;
    
begin

utt: Maq_Estados
    port map(
        RESET_N     => RESET_N,
        CLK         => CLK,
        IN_P        => IN_P,
        CAMBIO      => CAMBIO,
        limite      => limite,
        numero      => numero,
        
        estado      => estado,
        valor       => valor
    );

--Proceso de generación de la señal de reloj
  clkgen: process
  begin
    	CLK	<= '0';
        wait for 0.5 * CLK_PERIOD;
        CLK	<= '1';
        wait for 0.5 * CLK_PERIOD;
  end process;

--Vamos a utilizar los pulsadores para observar los cambios de los diferentes estados y
--vamos a introducir un número para comprobar que lo codifica correctamente
  stimulus: process
  begin		
  
  --Configuración inicial
    IN_P        <= '0';
    CAMBIO      <= '0';
    limite      <= '0';
    numero      <= "0000000000000000";

  --Pulso de RESET inicial                                                                  S0
	RESET_N <= '0';
	wait for CLK_PERIOD;       
	RESET_N <= '1';
    
    numero <= "1010"&"1011"&"1001"&"0011";  --Introducimos un número                        S1
    IN_P <= '1';                            
    wait for CLK_PERIOD;            --Simulamos un flanco de entrada del pulsador Inicio    
    IN_P <= '0';
    wait for CLK_PERIOD;
    
    --Comprobamos que el boton de Cambio no funciona si no estamos pausados                 S1
    CAMBIO <= '1';
    wait for CLK_PERIOD;            --Simulamos un flanco de entrada del pulsador CAmbio
    CAMBIO <= '0';
    wait for CLK_PERIOD;
    
    --Comprobamos que el pulsador de Inicio/Pausa puede cambiar el estado                   S2
    IN_P <= '1';                            
    wait for CLK_PERIOD;            --Simulamos un flanco de entrada del pulsador Inicio
    IN_P <= '0';
    wait for CLK_PERIOD;
    
    --Comprobamos que el boton de Cambio funciona ahora que estamos parados                 S3
    CAMBIO <= '1';
    wait for CLK_PERIOD;            --Simulamos un flanco de entrada del pulsador CAmbio
    CAMBIO <= '0';
    wait for CLK_PERIOD;
    
    --Comprobamos que el pulsador de Inicio/Pausa puede cambiar el estado                   S4
    IN_P <= '1';                            
    wait for CLK_PERIOD;            --Simulamos un flanco de entrada del pulsador Inicio
    IN_P <= '0';
    wait for CLK_PERIOD;
    
    --Comprobamos que la variable limite cambia el estado                                   S3
    limite <= '1';
    wait for CLK_PERIOD;
    
    --Comprobamos que mientras la variable límite sea 1 no se puede iniciar la cuenta       S3
    IN_P <= '1';                            
    wait for CLK_PERIOD;            --Simulamos un flanco de entrada del pulsador Inicio
    IN_P <= '0';
    wait for CLK_PERIOD;
    
    wait;	   
  end process;
end bench;