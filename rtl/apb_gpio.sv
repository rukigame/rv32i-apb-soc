`timescale 1ns / 1ps

module apb_gpio(
    input   logic           clk,
    input   logic           rst_n,
    input   logic   [31:0]  PADDR,
    input   logic   [31:0]  PWDATA,
    input   logic           PWRITE,
    input   logic           PSEL,
    input   logic           PENABLE,
    output  logic           PREADY,
    output  logic   [31:0]  PRDATA,
    inout   wire    [ 7:0]  GPIO_INOUT  // inout은 wire로 선언
    );

    localparam GPIO_CTR_ADDR = 8'h00;
    localparam GPIO_ODR_ADDR = 8'h04;
    localparam GPIO_IDR_ADDR = 8'h08;

    logic   [7:0]   GPIO_CTR;    // 방향 제어 레지스터 (1: Out, 0: In)
    logic   [7:0]   GPIO_ODR;    // 출력 데이터 레지스터
    wire    [7:0]   GPIO_IDR;    // 입력 데이터 와이어 (실시간 핀 모니터링)

    assign PREADY = (PENABLE & PSEL) ? 1'b1 : 1'b0;

    // 1. APB Write (비동기 리셋 감도 목록 추가, IDR 리셋 삭제)
    always_ff @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            GPIO_CTR <= 8'h0;
            GPIO_ODR <= 8'h0;
        end else begin
            if(PREADY & PWRITE) begin
                if(PADDR[7:0] == GPIO_CTR_ADDR) begin
                    GPIO_CTR <= PWDATA[7:0];
                end else if(PADDR[7:0] == GPIO_ODR_ADDR) begin
                    GPIO_ODR <= PWDATA[7:0];
                end
            end
        end
    end

    // 2. APB Read (기본값을 32'h0으로 안정화)
    assign PRDATA = (PADDR[7:0] == GPIO_CTR_ADDR) ? {24'h0, GPIO_CTR} :
                    (PADDR[7:0] == GPIO_ODR_ADDR) ? {24'h0, GPIO_ODR} :
                    (PADDR[7:0] == GPIO_IDR_ADDR) ? {24'h0, GPIO_IDR} : 32'h0;

 // gpio import & export

    genvar i;

    generate

        for (i = 0; i < 8; i = i + 1) begin

            // [출력 버퍼]: CTR이 1(Output)일 때만 ODR을 핀으로 방출, 0(Input)이면 핀을 하이임피던스(z)로 열어둠

            assign GPIO_INOUT[i] = (GPIO_CTR[i]) ? GPIO_ODR[i] : 1'bz;



            // [입력 버퍼]: CTR이 0(Input)일 때 외부 핀 전압을 IDR로 통과 (그림의 아래쪽 반대 스위치)

            assign GPIO_IDR[i]   = (~GPIO_CTR[i]) ? GPIO_INOUT[i] : 1'b0;

        end

    endgenerate

endmodule