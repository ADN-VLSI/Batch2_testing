build:
	@mkdir -p build
	@echo "*" > build/.gitignore

.PHONY: all
all:
	@make -s clean
	@make -s build
	@cd build && xvlog -sv ../test.sv
	@cd build && xelab test -s short_name
	@cd build && xsim short_name -runall

.PHONY: clean
clean:
	@rm -rf build