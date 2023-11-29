/*#############################################*\
|*       Author: Kholoud Ebrahim Darwseh       *|
|*       Date:   28/11/2023                    *|
|*       Project Name:  alu                    *|
\*#############################################*/

package alu_pkg;
    typedef enum bit [1:0] {AND_a, NAND_a, OR_a, XOR_a} op_a_e;
    typedef enum bit [1:0] {XNOR_b, AND_b, NOR_b, OR_b} op_b_e;
    
    parameter PERIOD = 10;
    parameter TIMES  = 2000;
    bit clk_running =1;
endpackage :alu_pkg
