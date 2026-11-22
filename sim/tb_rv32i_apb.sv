`timescale 1ns / 1ps

module tb_rv32i_apb();

  logic clk = 0, rst = 1;
  logic [11:0] sw = 12'h000;
  logic [11:0] led;

  always #5 clk = ~clk;

  rv32i_top dut(
    .*
  );

`ifdef VCS
  initial begin
    $fsdbDumpfile("wave.fsdb");
    $fsdbDumpvars(0, tb_rv32i_cpu);
  end
`endif

  initial begin
    #10;
    rst = 0;
    sw = 12'h05a; // (0000_0101_1010)


    #15000;
    $finish;
  end
endmodule
