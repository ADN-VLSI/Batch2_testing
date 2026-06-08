build:
	@mkdir -p build
	@echo "*" > build/.gitignore

.PHONY: all
all: clean build
	@cd build && xvlog -sv ../test.sv
	@cd build && xelab test -s khalid_short
	@cd build && xsim khalid_short -runall

.PHONY: clean
clean:
	@rm -rf build
