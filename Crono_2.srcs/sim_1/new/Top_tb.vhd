library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity top_tb is
end;

architecture bench of top_tb is

  component top
      Port ( 
                clk               : in   STD_LOGIC;
                reset_n           : in   STD_LOGIC;
                startstop         : in   STD_LOGIC;
                up_down           : in   STD_LOGIC;
                display_number    : out  STD_LOGIC_VECTOR (6 downto 0);
                display_selection : out  STD_LOGIC_VECTOR (7 downto 0)
      );
  end component;

  signal clk: STD_LOGIC;
  signal reset_n: STD_LOGIC;
  signal startstop: STD_LOGIC;
  signal up_down: STD_LOGIC;
  signal display_number: STD_LOGIC_VECTOR (6 downto 0);
  signal display_selection: STD_LOGIC_VECTOR (7 downto 0) ;
  
  constant CLK_PERIOD: time := 10 ns;

begin

  uut: top 
    port map ( 
        clk               => clk,
        reset_n           => reset_n,
        startstop         => startstop,
        up_down           => up_down,
        display_number    => display_number,
        display_selection => display_selection 
    );
 
 clkgen: process
 begin
    	clk	<= '0';
        wait for 0.5 * CLK_PERIOD;
        clk	<= '1';
        wait for 0.5 * CLK_PERIOD;
  end process;

 --Pulso de reset inicial
	RESET_N <= '0' after 0.25*CLK_PERIOD,
    		   '1' after 0.75*CLK_PERIOD;

  stimulus: process
  begin
  
    startstop <= '0';          --INICIALIZAMOS
    up_down <= '0';
    wait for CLK_PERIOD;
    
    startstop <= '1';            --CUENTA ARRIBA
    wait for CLK_PERIOD;
    startstop <= '0';
    wait for 700 ns;
    
    startstop <= '1';            --PARAMOS
    wait for CLK_PERIOD;
    startstop <= '0';
    wait for 300 ns;
    --El efecto del pulsador tardará en propagarse al circuito debido al debouncer
    --Aunque en nuestra simulación parezca que es un gran retardo en la realidad no
    --lo es porque trabajamos con tiempos muy diferentes. Tiempos que no podemos
    --utilizar en la simulación si queremos una mayor claridad de los datos a observar
    
    startstop <= '1';           --REANUDAMOS
    wait for CLK_PERIOD;
    startstop <= '0';
    wait for 300 ns;
    
    startstop <= '1';           --PARAMOS
    wait for CLK_PERIOD;
    startstop <= '0';
    wait for 10*CLK_PERIOD;
    
    up_down <= '1';          --CAMBIAMOS Y MANTENEMOS PARADO
    wait for CLK_PERIOD;
    up_down <= '0';
    wait for 10*CLK_PERIOD;
    
    startstop <= '1';           --REANUDAMOS
    wait for CLK_PERIOD;
    startstop <= '0';
    wait for 500 ns;

--Tiempo de simulación necesario: 2500 ns
    
    wait;
  end process;

end;