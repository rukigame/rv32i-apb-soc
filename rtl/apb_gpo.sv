`timescale 1ns / 1ps

module apb_gpo(
    input   logic           clk,
    input   logic           rst_n,
    input   logic   [31:0]  PADDR,
    input   logic   [31:0]  PWDATA,
    input   logic           PWRITE,
    input   logic           PSEL,
    input   logic           PENABLE,
    output  logic           PREADY,
    output  logic   [31:0]  PRDATA,
    output  logic   [ 7:0]  GPO_OUT
    );

    localparam GPO_CTR_ADDR = 8'h00;
    localparam GPO_ODR_ADDR = 8'h04;

    logic   [7:0]  GPO_CTR;    // 000h
    logic   [7:0]  GPO_ODR;    // 004h

    assign PREADY = (PENABLE & PSEL) ? 1'b1 : 1'b0;

    always_ff @ (posedge clk) begin
        if(!rst_n) begin
            GPO_CTR <= 8'h0;
            GPO_ODR <= 8'h0;
        end else begin
            if(PREADY & PWRITE) begin
                if(PADDR[7:0] == GPO_CTR_ADDR) begin
                    GPO_CTR <= PWDATA[7:0];
                end else if(PADDR[7:0] == GPO_ODR_ADDR) begin
                    GPO_ODR <= PWDATA[7:0];
                end else begin

                end
            end
        end
    end

    assign PRDATA = (PADDR[7:0] == GPO_CTR_ADDR) ? {24'h0, GPO_CTR} :
                    (PADDR[7:0] == GPO_ODR_ADDR) ? {24'h0, GPO_ODR} : 32'hz;

    // General purpose
    assign GPO_OUT = (GPO_CTR) ? GPO_ODR : 8'bz;

endmodule
