IMGTIME := `shell date --rfc-3339="ns"`

git add .
git commit -m "docs: $(IMGTIME)"
git push -v