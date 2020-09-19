IMGTIME := $(shell date "+%G%m%d_%H%M%S")


quick-sync:
	git add .
	git commit -m "docs: $(IMGTIME)"
	git push
