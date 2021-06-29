library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Counter is
    port(
        RESET_N     : in std_logic;                       --RESET Negado
        CLK         : in std_logic;                       --Señal de reloj
        estado      : in std_logic_vector(1 downto 0);    --Código de estado
                                                            --(00-Reset/01-Cuenta Arriba/10-Parado/11-Cuenta Abajo)
        valor       : out std_logic_vector(15 downto 0);  --Vector con el valor
        limite      : out std_logic                       --Bit para indicar que se ha llegado al límite de cuenta
    );
end entity Counter;


--La clase Counter es el contador que se activa cada segundo con la señal
--del reloj de entrada que está preescalada a 1 Hz
architecture Behavioral of Counter is
--Señales para el tratamiento de la información
signal cuenta_min_dec, cuenta_min_un, cuenta_seg_dec, cuenta_seg_un   : unsigned (3 downto 0) := "0000";
signal limit : std_logic := '0' ;   --Señal para indicar límite de cuenta alcanzado

begin
    
    contador: process (CLK)
    variable dmin, umin, dseg, useg : std_logic_vector(3 downto 0) := "0000";
    begin
        if RESET_N = '1' and rising_edge(CLK) then
            
            case estado is
            
            --Se resetea la cuenta
            when "00" =>                       
                cuenta_min_dec  <= "0000";
                cuenta_min_un   <= "0000";
                cuenta_seg_dec  <= "0000";
                cuenta_seg_un   <= "0000";
                limit           <= '0';
            
            --Se mantiene la cuenta
            when "10" =>                       
                cuenta_min_dec <= cuenta_min_dec;
                cuenta_min_un  <= cuenta_min_un;
                cuenta_seg_dec <= cuenta_seg_dec;
                cuenta_seg_un  <= cuenta_seg_un;
                limit          <= '0';
                
            --Cuenta arriba
            when "01" =>
                
                    if(cuenta_seg_un < 9) then
                        cuenta_seg_un <= cuenta_seg_un + 1;
                    else
                        cuenta_seg_un <= "0000";                        
                        if(cuenta_seg_dec < 5) then
                            cuenta_seg_dec <= cuenta_seg_dec + 1;
                        else
                            cuenta_seg_dec <= "0000";
                            if(cuenta_min_un < 9) then
                                cuenta_min_un <= cuenta_min_un + 1;
                            else
                                cuenta_min_un <= "0000";                        
                                if(cuenta_min_dec < 5) then
                                    cuenta_min_dec <= cuenta_min_dec + 1;
                                else
                                    --Si se llega a este punto la cuenta se detendrá en 59:59
                                    cuenta_min_dec  <= "0101";
                                    cuenta_min_un   <= "1001";
                                    cuenta_seg_dec  <= "0101";
                                    cuenta_seg_un   <= "1001";
                                    limit           <= '1';
                                end if;
                            end if;
                        end if;    
                    end if;           
            
            --Cuenta Abajo            
            when "11" =>
                
                    if(cuenta_seg_un > 0) then
                        cuenta_seg_un <= cuenta_seg_un - 1;
                    else
                        cuenta_seg_un <= "1001";                    
                        if(cuenta_seg_dec > 0) then
                            cuenta_seg_dec <= cuenta_seg_dec - 1;
                        else
                            cuenta_seg_dec <= "0101";
                            if(cuenta_min_un > 0) then
                                cuenta_min_un <= cuenta_min_un - 1;
                            else
                                cuenta_min_un <= "1001";
                                if(cuenta_min_dec > 0) then
                                    cuenta_min_dec <= cuenta_min_dec - 1;
                                else
                                    --Si se llega a este punto la cuenta se detendrá en 00:00
                                    cuenta_min_dec  <= "0000";
                                    cuenta_min_un   <= "0000";
                                    cuenta_seg_dec  <= "0000";
                                    cuenta_seg_un   <= "0000";
                                    limit           <= '1';
                                end if;
                            end if;
                        end if;    
                    end if;        
            
            --Error           
            when others =>          --Cuando haya un error se imprimirá 66 66
                
                cuenta_min_dec  <= "0110";
                cuenta_min_un   <= "0110";
                cuenta_seg_dec  <= "0110";
                cuenta_seg_un   <= "0110";
                limit           <= '0';
            
            end case;
        end if;
        
        --La salida de datos se hace sea cual sea el caso
        dmin := std_logic_vector(cuenta_min_dec);
        umin := std_logic_vector(cuenta_min_un);
        dseg := std_logic_vector(cuenta_seg_dec);
        useg := std_logic_vector(cuenta_seg_un);

        valor   <= dmin (3 downto 0) & umin (3 downto 0) & dseg (3 downto 0) & useg (3 downto 0);
        limite  <= limit;
    end process;
end architecture Behavioral;