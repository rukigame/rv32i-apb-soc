module data_mem (
  input   logic         clk,
  input   logic [31:0]  daddr,
  input   logic [31:0]  dwdata,
  input   logic         dwe,
  input   logic [ 2:0]  itype,
  output  logic [31:0]  drdata
);
  logic [31:0] dmem [0:127];

  // store
  always_ff @(posedge clk) begin
    if(dwe) begin
      case(itype)
        // Store word
        3'b010  : dmem[daddr[31:2]] <= dwdata;

        // Store half word
        // if "daddr /  2" is "even : lower half word" or "odd : higher half word"
        3'b001  : begin
          if(daddr[1]) dmem[daddr[31:2]] <= {dwdata[15:0], dmem[daddr[31:2]][15:0]};
          else dmem[daddr[31:2]] <= {dmem[daddr[31:2]][31:16], dwdata[15:0]};
        end 

        // Store byte
        // if "daddr % 4 " is "3 : [31:24]", "2 : [23:16]", "1 : [15: 8]", "0 : [7:0]"
        3'b000 : begin
          case(daddr[1:0])
              2'b00 : dmem[daddr[31:2]] <= {dmem[daddr[31:2]][31:8],  dwdata[7:0]};
              2'b01 : dmem[daddr[31:2]] <= {dmem[daddr[31:2]][31:16], dwdata[7:0], dmem[daddr[31:2]][7:0]};
              2'b10 : dmem[daddr[31:2]] <= {dmem[daddr[31:2]][31:24], dwdata[7:0], dmem[daddr[31:2]][15:0]};
              2'b11 : dmem[daddr[31:2]] <= {dwdata[7:0], dmem[daddr[31:2]][23:0]};
          endcase
        end
        default : dmem[daddr[31:2]] <= dmem[daddr[31:2]];
      endcase
    end
  end

  // i - type (load)
  always_comb begin
    case(itype)
      // LB
      3'b000 : begin
        case(daddr[1:0])
          2'b00 : drdata = {{24{dmem[daddr[31:2]][7]}}, dmem[daddr[31:2]][7:0]};
          2'b01 : drdata = {{24{dmem[daddr[31:2]][15]}}, dmem[daddr[31:2]][15:8]};
          2'b10 : drdata = {{24{dmem[daddr[31:2]][23]}}, dmem[daddr[31:2]][23:16]};
          2'b11 : drdata = {{24{dmem[daddr[31:2]][31]}}, dmem[daddr[31:2]][31:24]};
        endcase
      end

      // LH : load half word
      3'b001 : begin
        if(daddr[1]) drdata = {{16{dmem[daddr[31:2]][31]}}, dmem[daddr[31:2]][31:16]};
        else drdata = {{16{dmem[daddr[31:2]][15]}}, dmem[daddr[31:2]][15:0]};
      end

      // LW
      3'b010 : begin
        drdata = dmem[daddr[31:2]];
      end

      // LBU
      3'b100 : begin
        case(daddr[1:0])
          2'b00 : drdata = {24'd0, dmem[daddr[31:2]][7:0]};
          2'b01 : drdata = {24'd0, dmem[daddr[31:2]][15:8]};
          2'b10 : drdata = {24'd0, dmem[daddr[31:2]][23:16]};
          2'b11 : drdata = {24'd0, dmem[daddr[31:2]][31:24]};
        endcase
      end

      // LHU
      3'b101 : begin
        if(daddr[1]) drdata = {16'd0, dmem[daddr[31:2]][31:16]};
        else drdata = {16'd0, dmem[daddr[31:2]][15:0]};
      end
      default : drdata = 32'b0;
    endcase

  end
endmodule
