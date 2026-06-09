.DEFAULT_GOAL := sim

.PHONY: clean
clean:
	@rm -rf build

build:
	@mkdir -p build
	@echo "*" > build/.gitignore

.PHONY: sim
sim:
	@make -s clean
	@make -s build
	@cd build && xvlog -sv ../mem.sv ../mem_tb_sabbir.sv
	@cd build && xelab mem_tb_sabbir -s top
	@cd build && xsim top -runall
