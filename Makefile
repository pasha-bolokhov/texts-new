#
#
# Smart Makefile for running LaTeX
#
# Put the name of the source file into SRC variable
#
# Sample execution:
#
# "make ps"
#
# "make pdf"
#
# "make clean"
#
# "make cleanup"
#


# ----------  To Start, uncomment and edit this line  ----------
#                     SRC = sourcefile.tex
# ----------                                          ----------

# Set this to "true" if 'pdflatex' is needed to be used, "false" for using just 'latex'
USE_PDFLATEX = true


# goals that do not require SRC to be set
CLEANING_GOALS = clean clean-ps clean-pdf cleanup clean-all wipe-ps wipe-pdf wipe-all

# goals that do require SRC to be set
SRC_GOALS = ps pdf

# process SRC only if there are goals other than clean-type
ifeq ("$(MAKECMDGOALS)", "")
  # no arguments is considered as a non-cleaning goal, requiring specification of SRC
  NONCLEANING_SRC_ARGS := "1"
else
  NONCLEANING_SRC_ARGS := $(filter-out $(CLEANING_GOALS), $(MAKECMDGOALS))
  NONCLEANING_SRC_ARGS := $(filter $(SRC_GOALS), $(NONCLEANING_SRC_ARGS))
endif

# if there was at least one of SRC_GOALS supplied to 'make'
# then we try to setup SRC ourselves
ifneq ("$(NONCLEANING_SRC_ARGS)", "")
    #
    # we got here because the user wants to compile something,
    # but he/she did not specify which file, so most likely have run
    #         make ps        
    # or
    #         make pdf
    #
    # we will ensure that there is only one .tex file 
    # in the current directory and take this file as the 'target'
    # 

    # pick up the first TeX file
    # let the shell itself correctly split the list of files matching the pattern
    SRC ?= $(shell  for f in *.tex; do [ -f "$${f}" ] && echo "$${f}"; break; done)

    ifeq ("$(SRC)", "")
      $(error No LaTeX source found)
    endif
endif

# strip the suffix ".tex"
override SRC ::= $(basename $(SRC))


#
# Check that USE_PDFLATEX is set to something reasonable
# The user must be completely aware of the implications of the
# current state of this variable if decided to modify it
#
ifneq ("$(USE_PDFLATEX)", "true")
ifneq ("$(USE_PDFLATEX)", "false")
    $(error USE_PDFLATEX set to neither "true" nor "false": "$(USE_PDFLATEX)")
endif
endif

#
# Decide whether to create PDF via PostScript or the other way around,
# depending on whether USE_PDFLATEX is set to "true" or "false"
#
ifneq ("$(USE_PDFLATEX)", "true")    ## Generate Postscript first

# Postscript is the default goal
ps: $(SRC).ps

pdf: $(SRC).pdf

# This is a generic rule how to create a PostScript from TeX
%.ps: %.tex
	latex $< && latex $< && dvips -o $@ $*.dvi

# This is a generic rule how to create a PDF - generate a Postscript first,
# then convert
%.pdf: %.ps %.tex
	ps2pdf $<

else                                 ## Generate PDF first via 'pdflatex'

# PDF is the default goal
pdf: $(SRC).pdf

ps: $(SRC).ps

# This is a generic rule how to create a PDF from TeX
%.pdf: %.tex
	pdflatex $< && pdflatex $<

# This is a generic rule how to create a Postscript - generate a PDF first,
# then convert
%.ps: %.pdf %.tex
	pdf2ps $<

endif


clean:
	rm -f *.aux *.dvi *.log *.toc texput.log *.bak *~

clean-ps: clean
	@for file_product in *.ps; do \
		if [ ! -f $${file_product} ]; then continue; fi; \
		file=$$(basename $${file_product} .ps); \
		file_tex=$${file}.tex; \
		if [ -f $${file_tex} ]; then \
			echo "rm -f $${file_product}"; \
			rm -f $${file_product}; \
		else \
			echo "Leaving $${file_product} (no source file exists)"; \
		fi; \
	done;

clean-pdf: clean-ps
	@for file_product in *.pdf; do \
		if [ ! -f $${file_product} ]; then continue; fi; \
		file=$$(basename $${file_product} .pdf); \
		file_tex=$${file}.tex; \
		if [ -f $${file_tex} ]; then \
			echo "rm -f $${file_product}"; \
			rm -f $${file_product}; \
		else \
			echo "Leaving $${file_product} (no source file exists)"; \
		fi; \
	done;

cleanup: clean-pdf

clean-all: clean-pdf

wipe-ps: clean
	rm -f *.ps

wipe-pdf: wipe-ps
	rm -f *.pdf

wipe-all: wipe-pdf

#
# Provide a help message upon request
#

define HELP_MESSAGE = 
echo "HEP Makefile: compiles LaTeX source into Postscript or PDF."
echo ""
echo "Invocation: "
echo ""
echo "If only one TeX file is present in the current directory"
echo "    make"
echo ""
echo "More specifically"
echo "    make ps"
echo "or"
echo "    make pdf"
echo "will generate, respectfully, Postscript or PDF"
echo ""
echo "If more than one TeX file is present in the current directory,"
echo "have to specify which one to use,"
echo "    make stau-decay.tex"
echo ""
echo "To remove .aux, .dvi and so on files, run"
echo "    make clean"
echo ""
echo "See inside of 'Makefile' for more control options"
endef

help:
	@$(HELP_MESSAGE)

.DEFAULT:
	@echo "Don't know how to process '$<' (file name correct?), try \"make help\" for help"

#
# Version information: $Date$ $Id$ 
# 
