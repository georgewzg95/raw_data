//////////////////////////////////////////////////////////////////////////////////
// Company:          
// Engineer:        IK
// 
// Create Date:     11:35:01 03/21/2013 
// Design Name:     
// Module Name:     uart_rx_if
// Project Name:    
// Target Devices:  
// Tool versions:   
// Description:     
//                  
//                  
// Revision: 
// Revision 0.01 - File Created, {8N1}-cfg
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

interface uart_rx_if
(
    input   i_rxd
);
//////////////////////////////////////////////////////////////////////////////////
//
typedef struct {
    int speed_bod;
    int speed_ns;
    int speed_ns_half;
} cfg_t;
//////////////////////////////////////////////////////////////////////////////////
    // RXD
    bit [ 7:0]  sv_rxd;
    // ??
    cfg_t   sv_cfg;
    
//////////////////////////////////////////////////////////////////////////////////
//
task init(input int ii_speed=115_200);
    // 
    sv_rxd = 0;
    // 
    sv_cfg.speed_bod = ii_speed;
    sv_cfg.speed_ns  = (10**9)/ii_speed;
    sv_cfg.speed_ns_half = sv_cfg.speed_ns/2;
    
    // Final
endtask : init

task rxd;
    // dec vars
    bit s_done;
    // wait
    @(negedge i_rxd);
    // Data framing
    s_done = 0;
    for (int i = 0 ; i < 1+8+1; i++) // => sta+[0:7]+stp
        begin   :   DFRAME
            case(i)
                // START
                0   :   begin
                            #(sv_cfg.speed_ns_half*1ns);
                            if (i_rxd) // must be LOW
                                break; //   exit-loop
                        end
                // STOP
                9   :   begin
                            #(sv_cfg.speed_ns*1ns);
                            if (i_rxd) // must be HIGH
                                s_done = 1;
                        end
                // DATA
                default :   begin
                                #(sv_cfg.speed_ns*1ns);
                                sv_rxd[i-1] = i_rxd;
                            end
            endcase
        end
    //
    if (s_done)
        $display("[%t]: %m: rxd=%x / %c", $time, sv_rxd, (sv_rxd == 8'h0a)? " " : sv_rxd);
    else
        $display("[%t]: %m: rx-err", $time);
    // Final
endtask : rxd
//////////////////////////////////////////////////////////////////////////////////
endinterface : uart_rx_if
