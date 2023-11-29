`timescale 1ns/1ps

/*#############################################*\
|*       Author: Kholoud Ebrahim Darwseh       *|
|*       Date:   28/11/2023                    *|
|*       Project Name:  alu                    *|
\*#############################################*/

import alu_pkg::*;

module top;
    bit clk;
    
    initial begin
        while(clk_running == 1) begin
            #(PERIOD/2); clk = ~clk;
        end
        if(clk_running == 0) begin
            $display("Time endded");
        end
    end

    alu_if  vif(.alu_clk(clk));
    alu     dut(.alu_clk(clk), 
                .rst_n(vif.rst_n), 
                .alu_enable(vif.alu_enable), 
                .alu_enable_a(vif.alu_enable_a), 
                .alu_enable_b(vif.alu_enable_b), 
                .alu_in_a(vif.alu_in_a), 
                .alu_in_b(vif.alu_in_b), 
                .alu_irq_clr(vif.alu_irq_clr), 
                .alu_op_a(vif.alu_op_a), 
                .alu_op_b(vif.alu_op_b), 
                .alu_out(vif.alu_out), 
                .alu_irq(vif.alu_irq)
    );
    test    tb (vif);

    initial begin
        $dumpfile("alu_dump.vcd");
        $dumpvars;
    end
endmodule :top
