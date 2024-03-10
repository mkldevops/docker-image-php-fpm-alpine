
GIT			= @git

help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?## .*$$)|(^## )' Makefile | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'


## —— Git ————————————————————————————————————————————————————————————————
git-clean-branches: ## Clean merged branches
	$(GIT) remote prune origin
	(git branch --merged | egrep -v "(^\*|main|master|dev)" | xargs git branch -d) || true

git-rebase: ## Rebase the current branch
	$(GIT) pull --rebase $q
	$(GIT) pull --rebase origin main $q

message ?= $(shell git branch --show-current | sed -E 's/^([0-9]+)-([^-]+)-(.+)/\2: \#\1 \3/' | sed "s/-/ /g")
git-auto-commit:
	$(GIT) add .
	$(GIT) commit -m "${message}" -q || true

current_branch=$(shell git rev-parse --abbrev-ref HEAD)
git-push:
	$(GIT) push origin "$(current_branch)" --force-with-lease --force-if-includes

#commit: q=-q
commit: ## Commit and push the current branch
	@$(MAKE) --no-print-directory git-auto-commit git-rebase git-push ## Commit and push the current branch
