.PHONEY: deploy
deploy: deploy.sh
	git bash deploy.sh || sh deploy.sh

.PHONEY: post
post: newpost.sh
	git bash newpost.sh || sh newpost