//////////////////////////////////////////////////////////////////////////////////
// Company:         
// Engineer:        IK
// 
// Create Date:     11:35:01 03/21/2013 
// Design Name:     
// Module Name:     tb
// Project Name:    
// Target Devices:  
// Tool versions:   
// Description:     
//                  
//                  
// Revision: 
// Revision 0.01 - File Created, 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module tb;
//////////////////////////////////////////////////////////////////////////////////
//
parameter   p_Tclk  =   5ns; // 200MHz
parameter   p_Trst  =   120ns;

//////////////////////////////////////////////////////////////////////////////////
    // SYS_CON
    reg     s_sys_clk;
    reg     s_rst;
    
    
//////////////////////////////////////////////////////////////////////////////////
//
// 
//
always 
begin   :   SYS_CLK
    #(p_Tclk / 2.0) s_sys_clk <= !s_sys_clk;
end

initial
begin   :   init_POR
    // 
    
    // clr
    s_sys_clk = 0;
    s_rst = 0;
    
    // Final
end
//////////////////////////////////////////////////////////////////////////////////
//
// Instantiate DUT
//
mblite_top              dut
(
//SYS_CON
.sys_diff_clock_clk_p   ( s_sys_clk), // 200MHz clock input from board
.sys_diff_clock_clk_n   (!s_sys_clk),
// LEG
.led_8bits_tri_o        (),
// UART
.rs232_uart_rxd         (1'b1),
.rs232_uart_txd         ()
);
//////////////////////////////////////////////////////////////////////////////////
//
// UART BFM
//
uart_rx_if U_RXD (dut.rs232_uart_txd);

initial
begin   :   UART_RX
    U_RXD.init();
    #(p_Trst);
    forever
        U_RXD.rxd();
end
//////////////////////////////////////////////////////////////////////////////////
//
// 
//
initial
begin   :   GPIO_POLL
    #(p_Trst);
    forever
        begin   :   WRK
            @(dut.led_8bits_tri_o);
            $display("[%t]: %m: dut-gpio=%x", $time, dut.led_8bits_tri_o); 
        end
end
//////////////////////////////////////////////////////////////////////////////////
//
// {BREAK ON CPU-EXIT}
//
`ifndef GATE_LEVEL
initial
begin   :   _CPU // !!!RTL-sim
    #(p_Trst);
    do @(posedge dut.s_clk_50);
    while (dut.u0.U_MBLITE.imem.dat_o != 32'hB8000000);
    #100us; // tx byte via UART-115200
    $display("[%t]: %m: BREAK ON CPU-EXIT", $time); 
    $stop;
end
`else
initial
begin   :   _GPIO // !!!GATE-sim
    // dec var
    time s_time;
    logic [7:0] sv_gpio;
    // 
    s_time = $time;
    sv_gpio = dut.led_8bits_tri_o;
    do begin : _POLL
        // dly
        @(posedge s_sys_clk);
        // chk-upd
        if (sv_gpio !== dut.led_8bits_tri_o) // gpio-activity 
            begin   :   _UPD
                sv_gpio = dut.led_8bits_tri_o;
                s_time = $time;
            end
        else // no activity
            begin   :   _CHK
                if (($time - s_time) > 1ms) // t-out
                    break;
            end
    end while(1);
    // 
    $display("[%t]: %m: BREAK ON GPIO-TIMEOUT", $time); 
    $stop;
end
`endif // GATE_LEVEL
//////////////////////////////////////////////////////////////////////////////////
//
// TB Tasks
//
task dut_arst;
    // simple async
    s_rst <= 1; #(p_Tclk);
    s_rst <= 0;
    // Final
endtask : dut_arst

default clocking cb @(s_sys_clk);
endclocking : cb

//////////////////////////////////////////////////////////////////////////////////
endmodule
