library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Maq_Estados is
    port(  
        RESET_N     : in std_logic;                         --Señal RESET negada
        CLK         : in std_logic;                         --Señal de reloj
        IN_P        : in std_logic;                         --Señal de entrada del pulsador de Inicio/Pausa
        CAMBIO      : in std_logic;                         --Señal de entrada del pulsador de Cambio
        limite      : in std_logic;                         --Señal de límite alcanzado en la cuenta
        numero      : in std_logic_vector(15 downto 0);     --Señal codificado con el tiempo a imprimir
        
        estado      : out std_logic_vector(1 downto 0);     --Señal de salida con la información del estado de la máquina
        valor       : out std_logic_vector(31 downto 0)     --Vector con la información a imprimir en los displays
        );
end entity Maq_Estados;   
    
architecture Behavioral of Maq_Estados is

    --Creamos el tipo estado, que puede tomar 5 valores distintos
type state_t is (S0_INITIAL, S1_UPWARD, S2_STOPUP, S3_STOPDOWN, S4_DOWNWARD);
    --Creamos dos señales de tipo estado para utilizarlas como registros
signal state, next_state	:	state_t;     --State es el estado actual y next_state el estado del próximo ciclo
       
begin
    --Proceso de actualización del estado actual con el futuro
    state_register: process(CLK, RESET_N)
   	begin
   	    
   	    --Si se activa el reset se pasará al estado inicial
    	if RESET_N = '0' then
        	state <= S0_INITIAL;
        	estado <= "00";
        elsif rising_edge(CLK) then     --Cada flanco de reloj se actualiza el estado 
        	state <= next_state;        --y se cambia la información de la salida "estado"
        	case next_state is
        	   when S0_INITIAL =>
        	       estado <= "00";
        	   when S1_UPWARD =>
        	       estado <= "01";
        	   when S2_STOPUP =>
        	       estado <= "10";
        	   when S3_STOPDOWN =>
        	       estado <= "10";
        	   when S4_DOWNWARD =>
        	       estado <= "11";
        	 end case;
        end if;
    end process;
    
    --Proceso de cambio del siguiente estado
    next_state_decod: process (state, IN_P, CAMBIO, limite)
    
    begin			            
        --Asignación por defecto antes de las asignaciones. 
        --Si no se cumple ninguna condición el estado se mantendrá constante
    	next_state <= state;               
    	
    	case state is
    	
    	       --El paso de S0 a S1 requiere que se active el pulsador de Inicio y que no se haya llegado al límite de cuenta
        	when S0_INITIAL =>
            	if (IN_P = '1') and (limite = '0') then
                	next_state <= S1_UPWARD;
                end if;
                
               --El paso de S1 a S2 requiere que se active el pulsador de Pausa o que se llegue al límite de cuenta
            when S1_UPWARD =>
            	if (IN_P = '1') or (limite = '1') then
                	next_state <= S2_STOPUP;
                end if;
                
               --El paso de S2 a S1 requiere que se active el pulsador de Inicio y que no se haya llegado al límite de cuenta
               --El paso de S2 a S3 requiere que se active el pulsador de Cambio
            when S2_STOPUP =>
            	if (IN_P = '1') and (limite = '0') then            	
                	next_state <= S1_UPWARD;           --Prioridad de inicio de cuenta hacia arriba frente a cambio
                elsif CAMBIO = '1' then
                	next_state <= S3_STOPDOWN;
                end if;
                
               --El paso de S3 a S4 requiere que se active el pulsador de Inicio y que no se haya llegado al límite de cuenta
               --El paso de S3 a S2 requiere que se active el pulsador de Cambio
            when S3_STOPDOWN =>
            	if (IN_P = '1') and (limite = '0') then
                	next_state <= S4_DOWNWARD;         --Prioridad de inicio de cuenta hacia abajo frente a cambio
                elsif CAMBIO = '1' then
                	next_state <= S2_STOPUP;
                end if;
                
               --El paso de S4 a S3 requiere que se active el pulsador de Pausa o que se llegue al límite de cuenta
            when S4_DOWNWARD =>
            	if (IN_P = '1') or (limite = '1') then
                	next_state <= S3_STOPDOWN;
                end if;

            --Llegar a este caso implica que ha habido interferencia con la señal    
           	when others	=>
            	next_state <= S0_INITIAL;	--Por lo que lo más seguro es reiniciar el sistema
        end case;
    end process;

    --Proceso para la codificación de la información recibida en el vector "numero" en el vector "valor"
    --para que esta pueda ser impresa en los displays.   
    emisor: process (CLK)
    --Código para la alternancia de dígitos
    variable dmin, umin, dseg, useg : std_logic_vector(3 downto 0) := "0000";
    begin
        dmin := numero(15 downto 12);
        umin := numero(11 downto 8);
        dseg := numero(7 downto 4);
        useg := numero(3 downto 0);
        
        if state = S0_INITIAL then
           valor <= "1111" & "1111" & "1111" & "1111" &
                    dmin (3 downto 0) & umin (3 downto 0) & dseg (3 downto 0) & useg (3 downto 0);
        elsif state = S1_UPWARD then
           valor <= "1010" & "1011" & "1111" & "1111" &
                    dmin (3 downto 0) & umin (3 downto 0) & dseg (3 downto 0) & useg (3 downto 0);
        elsif state = S2_STOPUP then
           valor <= "1111" & "1111" & "1010" & "1011" & 
                    dmin (3 downto 0) & umin (3 downto 0) & dseg (3 downto 0) & useg (3 downto 0);
        elsif state = S3_STOPDOWN then
           valor <= "1111" & "1111" & "1100" & "1101" &
                    dmin (3 downto 0) & umin (3 downto 0) & dseg (3 downto 0) & useg (3 downto 0);
        elsif state = S4_DOWNWARD then
           valor <= "1100" & "1101" & "1111" & "1111" & 
                    dmin (3 downto 0) & umin (3 downto 0) & dseg (3 downto 0) & useg (3 downto 0);
        end if;
    end process;
end architecture Behavioral;