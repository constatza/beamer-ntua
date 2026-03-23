.RECIPEPREFIX := >

DECK ?= gnns
SOURCE := latex/$(DECK)/main.tex
AUXDIR := latex/$(DECK)/.build
OUTDIR := presentations
PDF := $(AUXDIR)/main.pdf

.PHONY: build export gnns example clean dist-framework

build:
> mkdir -p "$(AUXDIR)" "$(OUTDIR)"
> latexmk -pdf -interaction=nonstopmode -halt-on-error "$(SOURCE)"

export: build
> cp "$(PDF)" "$(OUTDIR)/$(DECK).pdf"

gnns:
> $(MAKE) export DECK=gnns

example:
> $(MAKE) export DECK=example

dist-framework:
> ./scripts/package-ntuabeamer.sh

clean:
> latexmk -C "$(SOURCE)"
