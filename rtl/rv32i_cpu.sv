module rv32i_top (
  input   logic         clk,
  input   logic         rst,
  input   logic [11:0]  sw,
  output  wire [11:0]  led
);

  logic rst_n;
  assign rst_n = ~rst;


  logic [31:0]  instr_code;
  logic [31:0]  instr_addr;
  logic [31:0]  bus_addr;
  logic [31:0]  bus_wdata;
  logic [31:0]  bus_rdata;
  logic         ready;
  logic         bus_we;
  logic         transfer;
  logic [ 2:0]  itype;

  // APB interface
  logic         PREADY0;  // APB RAM
  logic         PREADY1;  // GPI
  logic         PREADY2;  // GP0
  logic         PREADY3;  // GPIO
  logic         PREADY4;  // FND
  logic         PREADY5;  // UART
  logic         PREADY6;  //
  logic [31:0]  PRDATA0;
  logic [31:0]  PRDATA1;
  logic [31:0]  PRDATA2;
  logic [31:0]  PRDATA3;
  logic [31:0]  PRDATA4;
  logic [31:0]  PRDATA5;
  logic [31:0]  PRDATA6;
  logic [31:0]  PADDR;
  logic [31:0]  PWDATA;
  logic         PWRITE;
  logic         PENABLE;
  logic         PSEL0;
  logic         PSEL1;
  logic         PSEL2;
  logic         PSEL3;
  logic         PSEL4;
  logic         PSEL5;
  logic         PSEL6;



  instruction_rom U_INSTR_ROM (.*);
  rv32i_cpu U_RV32I_CPU (.*);
  //data_mem U_DATA_MEM ( .*);

  apb_requester U_APB_REQUESTER (.*);

  apb_bram U_APB_BRAM (
    .*,
    .PSEL(PSEL0),
    .PREADY(PREADY0),
    .PRDATA(PRDATA0)
  );

  apb_gpi U_APB_GPI(
      .*,
      .PSEL(PSEL1),
      .PREADY(PREADY1),
      .PRDATA(PRDATA1),
      .GPI_IN(sw[7:0])
  );

  apb_gpo U_APB_GPO (
      .*,
      .PSEL(PSEL2),
      .PREADY(PREADY2),
      .PRDATA(PRDATA2),
      .GPO_OUT(led[7:0])
  );

  apb_gpio U_APB_GPIO(
    .*,
    .PSEL(PSEL3),
    .PREADY(PREADY3),
    .PRDATA(PRDATA3),
    .GPIO_INOUT({sw[11:8], led[11:8]})
  );

endmodule


module rv32i_cpu (
  input   logic         clk,
  input   logic         rst_n,
  input   logic [31:0]  instr_code,
  input   logic [31:0]  bus_rdata,
  input   logic         ready,
  output  logic [31:0]  instr_addr,
  output  logic [31:0]  bus_addr,
  output  logic [31:0]  bus_wdata,
  output  logic         bus_we,
  output  logic         transfer,
  output  logic [ 2:0]  itype
);

  logic         pc_en;
  logic         rf_we;
  logic         branch;
  logic         jal;
  logic         jalr;
  logic         alusrc_sel;
  logic [3:0]   alu_control;
  logic [2:0]   rf_srcsel;

  control_unit U_CONTORL_UNIT(
    .*
  );

  datapath U_DATAPATH (
    .*
  );
endmodule
