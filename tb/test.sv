`timescale 1ns/1ps

/*#############################################*\
|*       Author: Kholoud Ebrahim Darwseh       *|
|*       Date:   28/11/2023                    *|
|*       Project Name:  alu                    *|
\*#############################################*/

import alu_pkg::*;

module test(alu_if tb_if);
    bit interrupt_flag;
    int unsigned rand_num;

    class transaction;
        rand bit rst_n;
        rand bit alu_enable, alu_enable_a, alu_enable_b;
        rand bit [7:0] alu_in_a, alu_in_b;
        bit alu_irq_clr;
        rand op_a_e alu_op_a;
        rand op_b_e alu_op_b;
    
        bit [7:0]alu_out;
        bit  alu_irq;

        constraint rst_n_c     {rst_n dist {1:=95, 0:=5};}       // (rst 0: 5/100 , 0: 95/100) active low
        constraint enable_c    {alu_enable dist {1:=110, 0:=10};}
        constraint enable_ab_c {
            // alu_enable_a ==0 <->  alu_enable_b ==1;  
            // alu_enable_b ==0 <->  alu_enable_a ==1; 
            
            ((alu_enable_a ==0 && alu_enable_b ==1)|| (alu_enable_a ==1 && alu_enable_b ==0));  
        }
        constraint op_a_c      {alu_op_a inside {[0:3]};}
        constraint op_b_c      {alu_op_b inside {[0:3]};}   
        constraint op_a_and_c  {
            if(alu_enable && alu_enable_a && !alu_enable_b)
                alu_op_a == 2'b00 -> alu_in_b != 8'h00;
        }
        constraint op_a_nand_c {
            if(alu_enable && alu_enable_a && !alu_enable_b)
                alu_op_a == 2'b01 -> (alu_in_a != 8'hFF && alu_in_b != 8'h03);
        }
        constraint op_b_and_c  {
            if(alu_enable && alu_enable_b && !alu_enable_a)
                alu_op_b == 2'b01 -> alu_in_b != 8'h03;
        }
        constraint op_b_nor_c  {
            if(alu_enable && alu_enable_b && !alu_enable_a)
                alu_op_b == 2'b10 -> alu_in_a != 8'hF5;
        }
    endclass :transaction

    transaction tr = new();

    covergroup cov_op_a;
        option.per_instance = 1;

        op_a :coverpoint tr.alu_op_a {
            bins AND_a  = {0};
            bins NAND_a = {1};
            bins OR_a   = {2};
            bins XOR_a  = {3};
        }
    endgroup :cov_op_a

    covergroup cov_op_b;
        option.per_instance = 1;

        op_b :coverpoint tr.alu_op_b {
            bins XNOR_b = {0};
            bins AND_b  = {1};
            bins NOR_b  = {2};
            bins OR_b   = {3};
        }
    endgroup :cov_op_b

    covergroup cov_in;
        option.per_instance = 1;

        in_a_op_a :coverpoint {tr.alu_enable, tr.alu_enable_a, tr.alu_enable_b, tr.alu_op_a, tr.alu_in_a} {
            illegal_bins  nand_in_a_ff = {{1'b1, 1'b1, 1'b0, 2'b01, 8'hFF}};
            wildcard bins in_a_op_a    = {{1'b1, 1'b1, 1'b0, 2'b01, 8'h??}};
        }
        in_b_op_a :coverpoint {tr.alu_enable, tr.alu_enable_a, tr.alu_enable_b, tr.alu_op_a, tr.alu_in_b} {
            illegal_bins and_in_b_00  = {{1'b1, 1'b1, 1'b0, 2'b00, 8'h00}};
            illegal_bins nand_in_b_03 = {{1'b1, 1'b1, 1'b0, 2'b01, 8'h03}};
            wildcard bins in_b_op_a   = {{1'b1, 1'b1, 1'b0, 2'b01, 8'h??}};
        }
        in_a_op_b :coverpoint {tr.alu_enable, tr.alu_enable_a, tr.alu_enable_b, tr.alu_op_b, tr.alu_in_a} {
            illegal_bins nor_in_a   = {{1'b1, 1'b0, 1'b1, 2'b10, 8'hF5}};
            wildcard bins in_a_op_b = {{1'b1, 1'b0, 1'b1, 2'b10, 8'h??}};
        }
        in_b_op_b :coverpoint {tr.alu_enable, tr.alu_enable_a, tr.alu_enable_b, tr.alu_op_b, tr.alu_in_b} {
            illegal_bins and_in_b   = {{1'b1, 1'b0, 1'b1, 2'b01, 8'h03}};
            wildcard bins in_b_op_b = {{1'b1, 1'b0, 1'b1, 2'b01, 8'h??}};
        }
    endgroup :cov_in

    covergroup cov_out;
        option.per_instance = 1;

        out_a :coverpoint {tr.alu_enable, tr.alu_enable_a, tr.alu_enable_b, tr.alu_op_a, tr.alu_out} {
            bins out_00_and_a  = {{1'b1, 1'b1, 1'b0,  2'b00, 8'h00}};
            bins out_ff_and_a  = {{1'b1, 1'b1, 1'b0,  2'b00, 8'hFF}};
            bins out_00_nand_a = {{1'b1, 1'b1, 1'b0,  2'b01, 8'h00}};
            bins out_ff_nand_a = {{1'b1, 1'b1, 1'b0,  2'b01, 8'hFF}};
            bins out_00_or_a   = {{1'b1, 1'b1, 1'b0,  2'b10, 8'h00}};
            bins out_ff_or_a   = {{1'b1, 1'b1, 1'b0,  2'b10, 8'hFF}};
            bins out_00_xor_a  = {{1'b1, 1'b1, 1'b0,  2'b11, 8'h00}};
            bins out_ff_xor_a  = {{1'b1, 1'b1, 1'b0,  2'b11, 8'hFF}};

            bins out_and_a_ir  = {{1'b1, 1'b1, 1'b0,  2'b00, 8'hFF}};
            bins out_nand_a_ir = {{1'b1, 1'b1, 1'b0,  2'b01, 8'h00}};
            bins out_or_a_ir   = {{1'b1, 1'b1, 1'b0,  2'b10, 8'hF8}};
            bins out_xor_a_ir  = {{1'b1, 1'b1, 1'b0,  2'b11, 8'h83}};
            bins other_a       = default;
        }
        out_b :coverpoint {tr.alu_enable, tr.alu_enable_a, tr.alu_enable_b, tr.alu_op_b, tr.alu_out} {
            bins out_00_and_b  = {{1'b1, 1'b0,  1'b1, 2'b00, 8'h00}};
            bins out_ff_and_b  = {{1'b1, 1'b0,  1'b1, 2'b00, 8'hFF}};
            bins out_00_nand_b = {{1'b1, 1'b0,  1'b1, 2'b01, 8'h00}};
            bins out_ff_nand_b = {{1'b1, 1'b0,  1'b1, 2'b01, 8'hFF}};
            bins out_00_or_b   = {{1'b1, 1'b0,  1'b1, 2'b10, 8'h00}};
            bins out_ff_or_b   = {{1'b1, 1'b0,  1'b1, 2'b10, 8'hFF}};
            bins out_00_xor_b  = {{1'b1, 1'b0,  1'b1, 2'b11, 8'h00}};
            bins out_ff_xor_b  = {{1'b1, 1'b0,  1'b1, 2'b11, 8'hFF}};

            bins out_xnor_b_ir = {{1'b1, 1'b0,  1'b1, 2'b00, 8'hF1}};
            bins out_and_b_ir  = {{1'b1, 1'b0,  1'b1, 2'b01, 8'hF4}};
            bins out_nor_b_ir  = {{1'b1, 1'b0,  1'b1, 2'b10, 8'hF5}};
            bins out_or_b_ir   = {{1'b1, 1'b0,  1'b1, 2'b11, 8'hFF}};
            bins other_b       = default;
        }
    endgroup :cov_out

    cov_op_a  cov_op_a_h = new();
    cov_op_b  cov_op_b_h = new();
    cov_in    cov_in_h   = new();
    cov_out   cov_out_h  = new();

    initial begin
        repeat(TIMES +20) begin
            $display("********************************");
            rand_num ++;
            $display("rand_num = %0d", rand_num);
            fork 
                begin
                    if(rand_num <= TIMES/2-50) begin
                        assert(tr.randomize());
                        $display("rand 1 with no inline constraints");
                    end 
                    else if(rand_num > TIMES/2-50 +1 && rand_num <= TIMES/2) begin
                        assert(tr.randomize() with {
                            alu_op_b ==0; alu_enable_a ==1; alu_enable ==1;
                            (
                                (alu_in_a == 8'hFF && alu_in_b == 8'hFF && alu_op_a ==2'b00) || 
                                (alu_in_a == 8'hFF && alu_in_b == 8'hFF && alu_op_a ==2'b01) ||
                                (alu_in_a == 8'hF0 && alu_in_b == 8'hF8 && alu_op_a ==2'b10) ||
                                (alu_in_a == 8'h83 && alu_in_b == 8'h00 && alu_op_a ==2'b11)
                            );  
                        });
                        $display("rand 2 with inline constraints for interrup a");
                    end 

                    else if(rand_num > TIMES/2+1 && rand_num <= TIMES-50) begin
                        assert(tr.randomize());
                        $display("rand 3 with no inline constraints");
                    end
                    else if(rand_num > TIMES-50+1 && rand_num <= TIMES) begin
                        assert(tr.randomize() with {
                            alu_op_a ==0; alu_enable_b ==1; alu_enable ==1;
                            (
                                (alu_in_a == 8'h0E && alu_in_b == 8'h00 && alu_op_b ==2'b00) ||  
                                (alu_in_a == 8'hF4 && alu_in_b == 8'hFF && alu_op_b ==2'b01) ||
                                (alu_in_a == 8'h0A && alu_in_b == 8'h00 && alu_op_b ==2'b10) ||
                                (alu_in_a == 8'hFF && alu_in_b == 8'h00 && alu_op_b ==2'b11)
                            );  
                        });
                        $display("rand 4 with inline constraints for interrup b");
                    end
                    else begin
                        assert(tr.randomize());
                        $display("rand 5 with no inline constraints");
                    end 

                    @(negedge tb_if.alu_clk);
                    #(PERIOD/2.0 - PERIOD/20.0);
                    tb_if.rst_n        = tr.rst_n;

                    if(tb_if.rst_n == 0) begin
                        tb_if.alu_enable   = 0;
                        tb_if.alu_enable_a = 0;
                        tb_if.alu_enable_b = 0;
                        tb_if.alu_in_a     = 0;
                        tb_if.alu_in_b     = 0;
                        tb_if.alu_op_a     = 0;
                        tb_if.alu_op_b     = 0;
                        tb_if.alu_irq_clr  = 0; 
                    end
                    else begin
                        tb_if.alu_enable   = tr.alu_enable;
                        tb_if.alu_enable_a = tr.alu_enable_a;
                        tb_if.alu_enable_b = tr.alu_enable_b;
                        tb_if.alu_in_a     = tr.alu_in_a;
                        tb_if.alu_in_b     = tr.alu_in_b;
                        tb_if.alu_op_a     = tr.alu_op_a;
                        tb_if.alu_op_b     = tr.alu_op_b;
                        tb_if.alu_irq_clr  = 0;
                    end
                    
                    $display("rst_n         = %1b", tb_if.rst_n);
                    
                    $display("alu_enable    = %1b", tb_if.alu_enable);
                    $display("alu_enable_a  = %1b", tb_if.alu_enable_a);
                    $display("alu_enable_b  = %1b", tb_if.alu_enable_b);
                    $display("alu_in_a      = %8b", tb_if.alu_in_a);
                    $display("alu_in_b      = %8b", tb_if.alu_in_b);

                    if(tb_if.rst_n && tb_if.alu_enable && tb_if.alu_enable_a && !tb_if.alu_enable_b)
                        $display("alu_op_a      = ", tr.alu_op_a.name());
                    else if(tb_if.rst_n && tb_if.alu_enable && !tb_if.alu_enable_a && tb_if.alu_enable_b)
                        $display("alu_op_b      = ", tr.alu_op_b.name());
                    else if(tb_if.rst_n == 0)
                        $display ("No operation will be done");

                    @(posedge tb_if.alu_clk);
                    #(PERIOD/2.0 - PERIOD/20.0);
                    if(tb_if.rst_n == 0) begin
                        tr.alu_irq         = 0;
                        tr.alu_out         = 0;
                    end
                    else begin
                        tr.alu_irq         = tb_if.alu_irq;
                        tr.alu_out         = tb_if.alu_out;
                    end
                    
                    $display("alu_out       = %8b", tb_if.alu_out);
                    $display("alu_irq       = %1b", tb_if.alu_irq);

                    @(negedge tb_if.alu_clk);
                    #(PERIOD/2.0 - PERIOD/20.0);
                    if(tb_if.alu_irq)
                        tb_if.alu_irq_clr  = 1;
                    else
                        tb_if.alu_irq_clr  = 0;

                    $display("alu_irq_clr   = %1b", tb_if.alu_irq_clr);

                    @(posedge tb_if.alu_clk);
                    #(PERIOD/2.0 - PERIOD/20.0);
                    tr.alu_irq_clr  = tb_if.alu_irq_clr;
                    $display("After_clr_alu_out  = %8b", tb_if.alu_out);
                    $display("After_clr_alu_irq  = %1b", tb_if.alu_irq);
                end
                
                begin
                    bit [7:0] Expected_out;
                    bit       Expected_irq;
                    if(tb_if.rst_n == 1) begin
                        @(posedge tb_if.alu_clk);
                        #(PERIOD/2.0 - PERIOD/20.0);
                        cov_in_h.sample();
                        cov_out_h.sample();
                        if(tb_if.alu_enable_a && !tb_if.alu_enable_b && tb_if.alu_enable) begin
                            cov_op_a_h.sample();
                            case(tb_if.alu_op_a)
                                2'b00 : begin  //AND
                                    Expected_out = tb_if.alu_in_a & tb_if.alu_in_b;
                                end
                                2'b01 : begin  //NAND
                                    Expected_out = ~(tb_if.alu_in_a & tb_if.alu_in_b);
                                end
                                2'b10 : begin  //OR
                                    Expected_out = tb_if.alu_in_a | tb_if.alu_in_b;
                                end
                                2'b11 : begin  //XOR
                                    Expected_out = tb_if.alu_in_a ^ tb_if.alu_in_b;
                                end
                            endcase
                        end
                        else if(tb_if.alu_enable_b && !tb_if.alu_enable_a && tb_if.alu_enable) begin
                            cov_op_b_h.sample();
                            case(tb_if.alu_op_b)
                                2'b00 : begin  //XNOR
                                    Expected_out = ~(tb_if.alu_in_a ^ tb_if.alu_in_b);
                                end
                                2'b01 : begin  //AND
                                    Expected_out = tb_if.alu_in_a & tb_if.alu_in_b;
                                end
                                2'b10 : begin  //NOR
                                    Expected_out = ~(tb_if.alu_in_a | tb_if.alu_in_b);
                                end
                                2'b11 : begin  //OR
                                    Expected_out = tb_if.alu_in_a | tb_if.alu_in_b;
                                end
                            endcase
                        end
            
                        if(!tb_if.alu_enable) begin
                            if(tb_if.alu_out == 0 && tb_if.alu_irq == 0)
                                $display("PASSED_1: ", "alu_out == %0b  alu_irq == %0b", tb_if.alu_out, tb_if.alu_irq);
                            else
                                $error("FAILEF_1: ", "alu_out == %0b  alu_irq == %0b", tb_if.alu_out, tb_if.alu_irq);
                        end
                        else begin
                            if(Expected_out == tb_if.alu_out) 
                                $display("PASSED_2: ", "Expected_out = %8b   alu_out = %8b", Expected_out, tb_if.alu_out);
                            else
                                $error("FAILED_2: ", "Expected_out = %8b   alu_out = %8b", Expected_out, tb_if.alu_out);

                            if( (tb_if.alu_enable_a && !tb_if.alu_enable_b && tb_if.alu_enable && tb_if.alu_op_a == 2'b00 && tb_if.alu_out == 8'hFF)||   
                                (tb_if.alu_enable_a && !tb_if.alu_enable_b && tb_if.alu_enable && tb_if.alu_op_a == 2'b01 && tb_if.alu_out == 8'h00)||
                                (tb_if.alu_enable_a && !tb_if.alu_enable_b && tb_if.alu_enable && tb_if.alu_op_a == 2'b10 && tb_if.alu_out == 8'hF8)|| 
                                (tb_if.alu_enable_a && !tb_if.alu_enable_b && tb_if.alu_enable && tb_if.alu_op_a == 2'b11 && tb_if.alu_out == 8'h83)||
                                (tb_if.alu_enable_b && !tb_if.alu_enable_a && tb_if.alu_enable && tb_if.alu_op_b == 2'b00 && tb_if.alu_out == 8'hF1)||
                                (tb_if.alu_enable_b && !tb_if.alu_enable_a && tb_if.alu_enable && tb_if.alu_op_b == 2'b01 && tb_if.alu_out == 8'hF4)||
                                (tb_if.alu_enable_b && !tb_if.alu_enable_a && tb_if.alu_enable && tb_if.alu_op_b == 2'b10 && tb_if.alu_out == 8'hF5)|| 
                                (tb_if.alu_enable_b && !tb_if.alu_enable_a && tb_if.alu_enable && tb_if.alu_op_b == 2'b11 && tb_if.alu_out == 8'hFF)) begin
                                    if(tb_if.alu_irq == 1) begin
                                        $display("PASSED_3: ", "there is interrupt, alu_irq = %1b", tb_if.alu_irq);
                                        interrupt_flag = 1;
                                    end
                                    else
                                        $error("FAILED_3: ", "alu_irq = %1b", tb_if.alu_irq);
                            end
                            else begin
                                if(tb_if.alu_irq == 0) begin
                                    $display("PASSED_4: ", "there is no interrupt, alu_irq = %1b", tb_if.alu_irq);
                                    interrupt_flag = 0;
                                end
                                else
                                    $error("FAILED_4: ", "alu_irq = %1b", tb_if.alu_irq);
                            end
                                
                            @(posedge tb_if.alu_clk);
                            #(PERIOD/2.0 - PERIOD/20.0);
                            if(interrupt_flag == 1) begin
                                if(tb_if.alu_irq == 0 && tb_if.alu_irq_clr == 1 && tb_if.alu_out == 0)
                                    $display("PASSED_5: ", "clear interrupt, alu_irq = %1b  alu_irq_clr == %1b  alu_out == %8b", tb_if.alu_irq, tb_if.alu_irq_clr, tb_if.alu_out);
                                else
                                    $error("FAILED_5: ", "alu_irq = %1b  alu_irq_clr == %1b  alu_out == %8b", tb_if.alu_irq, tb_if.alu_irq_clr, tb_if.alu_out);
                            end
                            else begin
                                if(tb_if.alu_irq == 0 && tb_if.alu_irq_clr == 0 && tb_if.alu_out == Expected_out)
                                    $display("PASSED_6: ", "No interrupt, alu_irq = %1b  alu_irq_clr == %1b  alu_out == %8b", tb_if.alu_irq, tb_if.alu_irq_clr, tb_if.alu_out);
                                else
                                    $error("FAILED_6: ", "alu_irq = %1b  alu_irq_clr == %1b  alu_out == %8b", tb_if.alu_irq, tb_if.alu_irq_clr, tb_if.alu_out);
                            end
                        end
                    end
                end
            join
        end
        $display("********************************");
        $display("Coverage of cov_op_a = %.2f%%", cov_op_a_h.get_coverage());
        $display("Coverage of cov_op_b = %.2f%%", cov_op_b_h.get_coverage());
        $display("Coverage of cov_in_h = %.2f%%", cov_in_h.get_coverage());
        $display("Coverage of cov_out_h = %.2f%%", cov_out_h.get_coverage());

        clk_running =0;
    end
endmodule :test
