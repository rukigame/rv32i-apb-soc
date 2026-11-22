module control_unit
  import rv32i_pkg::*;
(
  input   logic         clk,
  input   logic         rst_n,
  input   logic [31:0]  instr_code,
  input   logic         ready,    // from APB requester
  output  logic         rf_we,
  output  logic         pc_en,
  output  logic         branch,
  output  logic         jal,
  output  logic         jalr,
  output  logic         alusrc_sel,
  output  logic [ 3:0]  alu_control,
  output  logic [ 2:0]  rf_srcsel,
  output  logic         bus_we,
  output  logic         transfer, // to apb requester
  output  logic [ 2:0]  itype // instruction type : funct3
);

  logic [2:0] funct3;

  opcode_e  opcode;
  instr_rtype_e instr_rtype;
  instr_btype_e instr_btype;

  assign opcode = opcode_e'(instr_code[6:0]);
  assign funct3 = instr_code [14:12];

  // for debuging
  assign instr_rtype = instr_rtype_e'(alu_control);
  assign instr_btype = instr_btype_e'(funct3);

  typedef enum logic [3:0] {
    FETCH,
    DECODE,
    EXECUTE,
    MEM,
    WB
  } state_e;

  state_e c_state, n_state;

  always_ff @(posedge clk) begin
    if(!rst_n)
      c_state <= FETCH;
    else
      c_state <= n_state;
  end


  always_comb begin
    n_state = c_state;
    case(c_state)
      FETCH : begin
        n_state = DECODE;
      end
      DECODE : begin
        n_state = EXECUTE;
      end
      EXECUTE : begin
        case(opcode)
          OP_RTYPE, OP_BTYPE, OP_ITYPE, OP_ULTYPE, OP_UATYPE, OP_JTYPE, OP_JLTYPE  : n_state = FETCH;
          OP_STYPE, OP_ILTYPE : n_state = MEM;
        endcase
      end

      MEM : begin
        if(ready) begin
          if(opcode == OP_STYPE) n_state = FETCH;
          else n_state = WB;
        end
      end
      WB : begin
        n_state = FETCH;
      end
      // MEM : begin
      //   if(opcode == OP_STYPE) begin
      //     if(ready) n_state = FETCH;
      //   end else n_state = WB;
      // end
      // WB :
      //   if(ready) n_state = FETCH;
    endcase
  end





  always_comb begin
     pc_en       = 1'b0;
     rf_we       = 1'b0;
     branch      = 1'b0;
     jal         = 1'b0;
     jalr        = 1'b0;
     pc_en       = 1'b0;
     alusrc_sel  = 1'b0;
     alu_control = 4'b0000; // {funct7[5], funct3}
     rf_srcsel   = 3'b000;    // To control for WB to reg_file , 0:alu _result, 1 : drdata
     bus_we      = 1'b0;
     transfer    = 1'b0;
     itype       = 3'b111;   // SW, LW
    case(c_state)
      FETCH :
        pc_en = 1'b1;
      EXECUTE : begin
        case(opcode)
          // r-type
          OP_RTYPE : begin // r-type
            rf_we       = 1'b1;
            alusrc_sel  = 1'b0;
            alu_control = {instr_code[30], funct3};
            rf_srcsel   = 3'b000;   // To control for WB to reg file, 0:alu_result, 1:drdata
          end

          // b-type
          OP_BTYPE : begin
            branch      = 1'b1;
            alusrc_sel  = 1'b0;
            alu_control = {1'b0, funct3};
          end

          // s-type
          OP_STYPE : begin // s-type
            alusrc_sel  = 1'b1;
            alu_control = 4'b0000;
          end

          // i-type(from r-type)
          OP_ITYPE : begin
            rf_we       = 1'b1;
            alusrc_sel  = 1'b1; //IMM
            rf_srcsel   = 3'b000;   // To control for WB to reg
            // need if line
            if(funct3 == 3'b101)alu_control = {instr_code[30], funct3};
            else alu_control = {1'b0, funct3};
          end

          // il-type
          OP_ILTYPE : begin
            alusrc_sel  = 1'b1;   // to calculate data mem addr
            alu_control = 4'd0;  //  ADD rs1 + imm
          end

          // u-ltype(lui)
          OP_ULTYPE : begin
            rf_we       = 1'b1;
            rf_srcsel   = 3'b010;
          end

          // u-type(auipc)
          OP_UATYPE : begin
            rf_we       = 1'b1;
            rf_srcsel   = 3'b011;
          end

          // j-type (jal)
          OP_JTYPE : begin
            rf_we       = 1'b1;
            rf_srcsel   = 3'b100;
            jal         = 1'b1;
          end

          // j-type(jalr)
          OP_JLTYPE : begin
            rf_we       = 1'b1;
            rf_srcsel   = 3'b100;
            jalr        = 1'b1;
          end
        endcase
      end

      //MEM
      MEM : begin
        itype     = funct3;
        transfer  = 1'b1;     // to APB requester
        if(opcode == OP_STYPE) bus_we = 1'b1;
      end

      // WB
      WB : begin
        rf_we = 1'b1;
        rf_srcsel = 3'b001;
      end
    endcase
  end
endmodule
