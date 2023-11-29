/*#############################################*\
|*       Author: Kholoud Ebrahim Darwseh       *|
|*       Date:   28/11/2023                    *|
|*       Project Name:  alu                    *|
\*#############################################*/

interface alu_if (input bit alu_clk);
    logic rst_n;
    logic alu_enable, alu_enable_a, alu_enable_b;
    logic [7:0] alu_in_a, alu_in_b;
    logic alu_irq_clr;
    logic [1:0] alu_op_a;
    logic [1:0] alu_op_b;
    
    logic [7:0]alu_out;
    logic  alu_irq;

    property and_a_interrupt;
        @(posedge alu_clk) disable iff (!rst_n) (alu_enable && alu_enable_a && !alu_enable_b && alu_op_a == 2'b00 && alu_out == 8'hFF) |-> alu_irq;
    endproperty :and_a_interrupt

    property nand_a_interrupt;
        @(posedge alu_clk) disable iff (!rst_n) (alu_enable && alu_enable_a && !alu_enable_b && alu_op_a == 2'b01 && alu_out == 8'h00) |-> alu_irq;
    endproperty :nand_a_interrupt

    property or_a_interrupt;
        @(posedge alu_clk) disable iff (!rst_n) (alu_enable && alu_enable_a && !alu_enable_b && alu_op_a == 2'b10 && alu_out == 8'hF8) |-> alu_irq;
    endproperty :or_a_interrupt

    property xor_a_interrupt;
        @(posedge alu_clk) disable iff (!rst_n) (alu_enable && alu_enable_a && !alu_enable_b && alu_op_a == 2'b11 && alu_out == 8'h83) |-> alu_irq;
    endproperty :xor_a_interrupt

    property xnor_b_interrupt;
        @(posedge alu_clk) disable iff (!rst_n) (alu_enable && !alu_enable_a && alu_enable_b && alu_op_b == 2'b00 && alu_out == 8'hF1) |-> alu_irq;
    endproperty :xnor_b_interrupt

    property and_b_interrupt;
        @(posedge alu_clk) disable iff (!rst_n) (alu_enable && !alu_enable_a && alu_enable_b && alu_op_b == 2'b01 && alu_out == 8'hF4) |-> alu_irq;
    endproperty :and_b_interrupt

    property nor_b_interrupt;
        @(posedge alu_clk) disable iff (!rst_n) (alu_enable && !alu_enable_a && alu_enable_b && alu_op_b == 2'b10 && alu_out == 8'hF5) |-> alu_irq;
    endproperty :nor_b_interrupt

    property or_b_interrupt;
        @(posedge alu_clk) disable iff (!rst_n) (alu_enable && !alu_enable_a && alu_enable_b && alu_op_b == 2'b11 && alu_out == 8'hFF) |-> alu_irq;
    endproperty :or_b_interrupt

    property interrupt_clr_out;
        @(posedge alu_clk) alu_irq_clr |=> alu_out == 8'h00;
    endproperty :interrupt_clr_out


    and_a_irq_ass1 : assert property (and_a_interrupt);
    nand_a_irq_ass2: assert property (nand_a_interrupt);
    or_a_irq_ass3  : assert property (or_a_interrupt);
    xor_a_irq_ass4 : assert property (xor_a_interrupt);

    xnor_b_irq_ass5: assert property (xnor_b_interrupt);
    and_b_irq_ass6 : assert property (and_b_interrupt);
    nor_b_irq_ass7 : assert property (nor_b_interrupt);
    or_b_irq_ass8  : assert property (or_b_interrupt);

    irq_clr_out_ass9 : assert property (interrupt_clr_out);

endinterface :alu_if
