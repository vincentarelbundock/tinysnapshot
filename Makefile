.PHONY: help testall testone document check install installdep deploy

help:  ## Display this help screen
	@echo -e "\033[1mAvailable commands:\033[0m\n"
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' | sort

document:  ## Generate package documentation
	Rscript -e "devtools::document()"

check: document ## Check package
	Rscript -e "devtools::check()"

install: document ## Install package
	Rscript -e "devtools::install(dependencies = FALSE)"

installdep: document ## Install package with dependencies
	Rscript -e "devtools::install(dependencies = TRUE)"

testall: install ## Run all tests with build and install
	Rscript -e "tinytest::build_install_test(ncpu = 20)"

testone: ## Run a single test file (use testfile=path/to/file.R)
	Rscript -e "pkgload::load_all();tinytest::run_test_file('$(testfile)')"

deploy: install ## Deploy package documentation website
	Rscript -e "pkgdown::deploy_to_branch()"
