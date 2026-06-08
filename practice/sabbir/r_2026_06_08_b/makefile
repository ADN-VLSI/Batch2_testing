build:
	@mkdir -p build
	@echo "*" > build/.gitingnore
.PHONY: aa
aa:
	@make -s clear
	@make -s build
	@cd build && xvlog -sv ../test.sv
	@cd build && xelab test -s abc
	@cd build && xsim abc -runall
.PHONY: clear
clear:
	rm -rf build




