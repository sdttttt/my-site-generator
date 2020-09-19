IMGTIME := $(shell date "+%G%m%d_%H%M%S")


deploy:
	git add .
	git commit -m "docs: $(IMGTIME)"
