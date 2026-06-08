khalid_output.txt: khalid_msg.txt
	@cp khalid_msg.txt khalid_output.txt
	@echo "Copied khalid_msg.txt to khalid_output.txt"

khalid_msg.txt:
	@echo "Hello, World!" > khalid_msg.txt
	@echo "Generated khalid_msg.txt with content: Hello, World!"

.PHONY: clean
clean:
	@rm -f khalid_msg.txt khalid_output.txt
	@echo "Cleaned up generated files."