/*#############################################*\
|*       Author: Kholoud Ebrahim Darwseh       *|
|*       Date:   28/11/2023                    *|
|*       Project Name:  alu                    *|
\*#############################################*/

module alu (alu_clk, rst_n, alu_enable, alu_enable_a, alu_enable_b, alu_in_a, alu_in_b, alu_irq_clr, alu_op_a, alu_op_b, alu_out, alu_irq);
    input alu_clk, rst_n;
    input alu_enable, alu_enable_a, alu_enable_b;
    input [7:0] alu_in_a, alu_in_b;
    input alu_irq_clr;
    input [1:0] alu_op_a, alu_op_b;

    output reg [7:0]alu_out;
    output  alu_irq;

    assign alu_irq = (
                (alu_enable_a && !alu_enable_b && alu_enable && alu_op_a == 2'b00 && alu_out == 8'hFF)||
                (alu_enable_a && !alu_enable_b && alu_enable && alu_op_a == 2'b01 && alu_out == 8'h00)||
                (alu_enable_a && !alu_enable_b && alu_enable && alu_op_a == 2'b10 && alu_out == 8'hF8)|| 
                (alu_enable_a && !alu_enable_b && alu_enable && alu_op_a == 2'b11 && alu_out == 8'h83)||

                (alu_enable_b && !alu_enable_a && alu_enable && alu_op_b == 2'b00 && alu_out == 8'hF1)||
                (alu_enable_b && !alu_enable_a && alu_enable && alu_op_b == 2'b01 && alu_out == 8'hF4)||
                (alu_enable_b && !alu_enable_a && alu_enable && alu_op_b == 2'b10 && alu_out == 8'hF5)|| 
                (alu_enable_b && !alu_enable_a && alu_enable && alu_op_b == 2'b11 && alu_out == 8'hFF)
    ) ? 1'b1 : 1'b0;

    always @(posedge alu_clk, negedge rst_n) begin
        if(! rst_n ) begin // active low rst
            alu_out <= 0;
        end
        else begin
            if(alu_enable_a && !alu_enable_b && alu_enable) begin
                case(alu_op_a)
                    2'b00 : begin  //AND
                        alu_out <= alu_in_a & alu_in_b;

                        if(alu_out == 'hFF && alu_irq_clr == 1)     
                            alu_out <= 8'h00;
                    end
                    2'b01 : begin  //NAND
                        alu_out <= ~(alu_in_a & alu_in_b);

                        if(alu_out == 'h00 && alu_irq_clr == 1)     alu_out <= 8'h00;
                    end
                    2'b10 : begin  //OR
                        alu_out <= alu_in_a | alu_in_b;

                        if(alu_out == 'hF8 && alu_irq_clr == 1)     alu_out <= 8'h00;
                    end
                    2'b11 : begin  //XOR
                        alu_out <= alu_in_a ^ alu_in_b;

                        if(alu_out == 'h83 && alu_irq_clr == 1)     alu_out <= 8'h00;
                    end
                    default : alu_out <= 0;
                endcase
            end
            else if(alu_enable_b && !alu_enable_a && alu_enable) begin
                case(alu_op_b)
                    2'b00 : begin  //XNOR
                        alu_out <= ~(alu_in_a ^ alu_in_b);

                        if(alu_out == 'hF1 && alu_irq_clr == 1)     alu_out <= 8'h00;
                    end
                    2'b01 : begin  //AND
                        alu_out <= alu_in_a & alu_in_b;

                        if(alu_out == 'hF4 && alu_irq_clr == 1)     alu_out <= 8'h00;
                    end
                    2'b10 : begin  //NOR
                        alu_out <= ~(alu_in_a | alu_in_b);

                        if(alu_out == 'hF5 && alu_irq_clr == 1)     alu_out <= 8'h00;
                    end
                    2'b11 : begin  //OR
                        alu_out <= alu_in_a | alu_in_b;

                        if(alu_out == 'hFF && alu_irq_clr == 1)     alu_out <= 8'h00;
                    end
                    default : alu_out <= 0;
                endcase
            end
            else
                alu_out <= 0;
        end
    end
endmodule
