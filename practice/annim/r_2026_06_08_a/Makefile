output.txt: msg.txt
	cp msg.txt file.txt
	cp msg.txt output.txt

msg.txt:
	@echo "in the txt" > msg.txt
	@echo "prints in the terminal"

file.txt:
	@echo "another file" > file.txt
	@echo "prints file in the terminal "

.PHONY: clean
clean:
	@rm -f msg.txt output.txt file.txt
	@echo "all cleaned up"



