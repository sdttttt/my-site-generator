.PHONEY: deploy
deploy: deploy.sh
	git bash deploy.sh || bash deploy.sh

.PHONEY: post
post: newpost.sh
	git bash newpost.sh || bash newpost