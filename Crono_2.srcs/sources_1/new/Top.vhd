library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    Port ( 
         clk               : in  STD_LOGIC;
         reset_n           : in  STD_LOGIC;
         startstop         : in  STD_LOGIC;
         up_down           : in  STD_LOGIC;
           
         display_number    : out  STD_LOGIC_VECTOR (6 downto 0);
         display_selection : out  STD_LOGIC_VECTOR (7 downto 0);
         display_point     : out  STD_LOGIC
         );
end top;

--La clase Top es la que auna todas las entidades en un único programa

architecture Behavioral of top is
-- SEÑALES ENTRE DIFERENTES COMPONENTES

    --SEÑALES SALIDA DEL DEBOUNCER  // ENTRADAS MÁQUINA DE ESTADOS
    signal STARTSTOP_DEB : std_logic;      --Boton startstop sin rebotes
    signal UPDOWN_DEB : std_logic;         --Boton up_down sin rebotes

    --SEÑAL SALIDA DE LA MAQUINA DE ESTADOS  //  ENTRADA GESTOR DE DISPLAY
    signal VALOR : std_logic_vector(31 downto 0);
    
    --SEÑALES SALIDA GESTOR DE DISPLAY // ENTRADA DECODER
    signal CODE : std_logic_vector(3 downto 0);
    signal DIGSEL : std_logic_vector(7 downto 0);
    
    --SEÑALES SALIDA DE LA MÁQUINA DE ESTADOS // ENTRADAS COUNTER
    signal ESTADO : std_logic_vector(1 downto 0);
    
    --SEÑALES SALIDA DE COUNTER // ENTRADA MÁQUINA DE ESTADOS
    signal NUMERO : std_logic_vector(15 downto 0);
    signal LIMITE : std_logic;
    
    --SELAÑES SALIDA DE PRESCALER // ENTRADA COUNTER
    signal PRESCALED : std_logic;
    
-- COMPONENTES

COMPONENT debouncer is
    port( 
         clk     : in std_logic;
         btn_in  : in std_logic; 
         reset_n : in std_logic;
         
         btn_out : out std_logic
         );
END COMPONENT;

COMPONENT Maq_Estados
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
END COMPONENT;

COMPONENT Gestor_Display
    generic (frec_emision: integer:=200_000); --Para 500 HZ usamos 200 000
    port(
        RESET_N     : in std_logic;
        CLK         : in std_logic;
        vector      : in std_logic_vector(31 downto 0);
        
        code        : out std_logic_vector(3 downto 0);
        digsel      : out std_logic_vector(7 downto 0);
        punto       : out std_logic
    );
END COMPONENT Gestor_Display;

COMPONENT Decoder is
    port(
        RESET_N     : in std_logic;                        
        code        : in std_logic_vector(3 downto 0);      
        digsel      : in std_logic_vector(7 downto 0);      
        
        segments    : out std_logic_vector(6 downto 0);    
        digits      : out std_logic_vector(7 downto 0)      
        );
END COMPONENT;

COMPONENT Prescaler is
    generic (frec: integer:=50000000);  -- VALOR PARA CONSEGUIR 1Hz 50000000 en onda cuadrada/100000000 en pulso único
    port(
        CLK         : in std_logic;
        
        prescaled   : out std_logic
    );
END COMPONENT Prescaler;

COMPONENT Counter is
    port(
        RESET_N     : in std_logic;                       
        CLK         : in std_logic;
        estado      : in std_logic_vector(1 downto 0);    
        
        valor       : out std_logic_vector(15 downto 0); 
        limite      : out std_logic                       
    );
END COMPONENT Counter;

begin
-- INSTANCIAS DE LOS COMPONENTES

Inst_debouncer_STARTSTOP: debouncer        --Antirebotes para inicio-pausa
    port map(
            clk     =>  clk,
            btn_in  =>  startstop,           
            reset_n =>  reset_n,
            
            btn_out =>  STARTSTOP_DEB
            );
            
Inst_debouncer_UPDOWN: debouncer            --Antirebotes para cambio
    port map(
            clk     =>  clk,
            btn_in  =>  up_down,           
            reset_n =>  reset_n,
            
            btn_out =>  UPDOWN_DEB
            );
            
Inst_MAQ_ESTADOS : Maq_Estados
    port map(  
            RESET_N =>  reset_n,    
            CLK     =>  clk,              
            IN_P    =>  STARTSTOP_DEB,    
            CAMBIO  =>  UPDOWN_DEB,
            limite  =>  LIMITE,
            numero  =>  NUMERO,   
        
            estado  => ESTADO,
            valor   => VALOR
            );
--Para probar el testbench se debe colocar una frec de 5            
Inst_PRESCALER : Prescaler  
    generic map (frec => 50000000)  -- VALOR PARA CONSEGUIR 1Hz 50000000 en onda cuadrada/100000000 en pulso único
    port map(
        CLK         => clk,
        
        prescaled   => PRESCALED
    );

INST_COUNTER : Counter
    port map(
        RESET_N     => reset_n,                
        CLK         => PRESCALED,
        estado      => ESTADO, 
        
        valor       => NUMERO,
        limite      => LIMITE              
    );
 
--Para probar el testbench se debe colocar una frec de 1
Inst_GESTOR_DISPLAY : Gestor_Display 
    generic map( frec_emision => 200_000)
    port map(
        RESET_N     => reset_n,
        CLK         => clk,
        vector      => VALOR,
        
        code        => CODE,
        digsel      => DIGSEL,
        punto       => display_point
    );
            
Inst_DECODER : decoder
     port map(
             RESET_N   =>  reset_n,    
             code      =>  CODE,
             digsel    =>  DIGSEL,
        
             segments  =>  display_number,
             digits    =>  display_selection
             );                   

end Behavioral;