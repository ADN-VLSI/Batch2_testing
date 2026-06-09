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
	@cd build && xvlog -sv ../gray_to_bin.sv ../gray_to_bin_tb.sv
	@cd build && xelab alu_tb -s top
	@cd build && xsim top -runall