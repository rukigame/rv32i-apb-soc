# 기여 범위 (Contributions)

4인 팀 프로젝트(AI 시스템 반도체 설계 1기 7조, 2026.09). 팀원 동의를 받아 전체 RTL을 공개하며,
포트폴리오에서 다루는 것은 **김진환 담당 파트(APB Interface)** 입니다.

| 파일 | 내용 | 작성 |
| --- | --- | --- |
| rtl/apb_requester.sv | APB Master: IDLE/SETUP/ACCESS FSM, address_decoder, apb_mux | **김진환** |
| rtl/apb_ram.sv | apb_bram Completer (512B) | **김진환** |
| rtl/apb_gpi.sv, apb_gpo.sv, apb_gpio.sv | GPI / GPO / 양방향 GPIO Completer | **김진환** |
| sim/tb_rv32i_apb.sv, sim/*.mem | APB 검증용 테스트벤치·ROM 코드 | **김진환** |
| docs/img/wave_*.png, memory_map.png 등 | 파형·구조도 | **김진환** |
| rtl/rv32i_cpu.sv (rv32i_cpu), datapath.sv, control_unit.sv, define.svh, pkg/ | RV32I Multi-Cycle 코어 | 문준석 |
| rtl/rv32i_cpu.sv (rv32i_top), instruction_rom.sv, data_memory.sv | Top 통합, 펌웨어 테스트 | 김서연 |
| (저장소 미포함) UVM 테스트벤치 | VCS/Verdi UVM 검증 | 홍성은 |

※ 파일별 작성자 표기는 발표 역할 분담 기준입니다. 공동 수정 부분은 확인 후 고치세요.
