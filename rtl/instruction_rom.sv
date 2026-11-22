
module instruction_rom (
  input   logic [31:0]  instr_addr,
  output  logic [31:0]  instr_code
);

  logic [31:0] instr_rom [0:127];  // 128 words

  `ifdef SIMULATION_TEST // if define execute
  initial begin
    instr_rom[0] = 32'h0041_82b3; // add x5, x3, x4
    instr_rom[1] = 32'h0053_2323; // sw x6, 6(x6)
    instr_rom[2] = 32'h0023_8413; // addi x8, x7, 2
    instr_rom[3] = 32'h0063_2503; // lw x10, 6(x6)
    instr_rom[4] = 32'hfe62_8ce3; // beq x5, x6, -8
    instr_rom[5] = 32'hfe62_9ce3; // bne x5, x6, -8
    instr_rom[5] = 32'h1234_5537; // lui x10, 74565
    instr_rom[6] = 32'h1234_5597; // auipc x11, 74565
  end
  `endif

  initial
    // $readmemh("rom_code_ex2.mem", instr_rom,0 , 50);
    $readmemh("rom_code_apb_gpio.mem", instr_rom,0 , 50);



  assign instr_code = instr_rom[instr_addr[31:2]];

endmodule
