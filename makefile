IMGTIME := $(shell date --rfc-3339="ns")

quick-sync:
	git add .
	git commit -m "docs: $(IMGTIME)"
	git push
