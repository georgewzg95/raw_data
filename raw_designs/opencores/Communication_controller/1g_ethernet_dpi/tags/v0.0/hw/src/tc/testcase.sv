//////////////////////////////////////////////////////////////////////////////////
// Company:         
// Engineer:        IK
// 
// Create Date:     11:35:01 03/21/2013 
// Design Name:     
// Module Name:     testcase
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

module testcase;
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
//
// Instantiate TB
//
tb tb();

//////////////////////////////////////////////////////////////////////////////////
//
// 
//
initial
begin   :   TC
    // init-msg
    $display("[%t]: %m: START", $time);
    // init-clr
    tb.dut_arst();
    
    // proc
    #500ms;
    // Final
    #1us;
    $display("[%t]: %m: STOP", $time);
    $finish;
end
//////////////////////////////////////////////////////////////////////////////////
endmodule
