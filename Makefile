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

################################################################
#                                                              #
#                       User Controls                          #
#                                                              #
################################################################

# ----------  To Start, uncomment and edit this line  ----------
#                     SRC = sourcefile.tex
# ----------                                          ----------


# Set this to "true" if 'pdflatex' is needed to be used, "false" for using just 'latex'
USE_PDFLATEX = false


################################################################
#                                                              #
#                    Main Technical Work                       #
#                                                              #
################################################################


#
# Prevent 'make' from deleting any of these files
# even if it was 'make' itself that made them
#
.PRECIOUS: %.tex %.ps %.pdf


.PHONY: ps pdf                       # There are no files such as "ps" or "pdf" exactly, 
                                     # and if there are, they should be ignored


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
# This effectively is a subroutine which compiles into the default 
# output format (Postscript or PDF), by finding a single '.tex' file
#
# The variable 'ext' determines the extension of the default format
# ('ps' for Postscript, 'pdf' for PDF)
#
#
# Implicit source compilation: 
#   - check SRC variable
#   - find a TeX file, report an error if none is found
#     or, report an error if more than one is found
#   - compile the found TeX file
#
define compile_primary =
	# check SRC variable
	if [ "x$(SRC)" != "x" ]; then
		# this invocation allows multiple filenames to be set in SRC
		$(MAKE) MAKELEVEL=0 $(SRC)
		exit 0
	fi
	# SRC hasn't been set or is empty
	let cnt=0
	for f in *.tex; do
	    if [ -f "$${f}" ]; then
	        let cnt++
	    fi
	    if [ "$${cnt}" -eq "2" ]; then
	        echo More than one LaTeX files found - specify which one to use
	        exit 2
	    fi
	done
	if [ "$${cnt}" -eq "0" ]; then
		echo No LaTeX source found
		exit 2
	fi
	# variable 'f' now contains the '.tex' file
	$(MAKE) MAKELEVEL=0 "$${f%%.tex}.$(ext)"
endef

#
# This is the subroutine which compiles into the derivative output format
# That is, if the default format is Postscript, it should be used to generate a PDF
# and vice versa
#
# The variable 'ext' determines the extension of the default (primary) format
# ('ps' for Postscript, 'pdf' for PDF)
# The variable 'extsec' determines, correspondingly, the extension of the secondary format 
# ('pdf' for Postscript primary, 'ps' for PDF primary)
#
#
# Implicit derivative format compilation: 
#   - check SRC variable
#   - find a TeX file, report an error if none is found
#   - if more than one found, we still can take a guess which one to take 
#     if there is a corresponding primary ('.ps'/'.pdf') file
#   - compile the found TeX file
#   - convert it to the secondary format ('.pdf'/'.ps')
#
# This makes it handy to be able type e.g. 'make pdf' even though
# there are multiple '.tex' files present
#
define compile_secondary = 
	# check SRC variable
	if [ "x$(SRC)" != "x" ]; then
		# this invocation allows multiple filenames to be set in SRC
		$(MAKE) MAKELEVEL=0 $(SRC)
		exit 0
	fi
	# SRC hasn't been set or is empty
	let cnt=0
	for f in *.tex; do
	    if [ -f "$${f}" ]; then
	        let cnt++
	    fi
	    if [ "$${cnt}" -eq "2" ]; then
		let pcnt=0
		pfail=false
		# go through all primary output files
		# and see how many of them match a '.tex' file
		for p in *.$(ext); do
			# convert the name to '.tex'
			t="$${p%%.$(ext)}.tex"
			# only count those primary output files for which there is a '.tex' file
			if [ -f "$${p}" -a -f "$${t}" ]; then
				let pcnt++
			fi
			if [ "$${pcnt}" -eq "2" ]; then
				break
			fi
		done
		# fail if none or too many qualifying primary output files are found
		if [ "$${pcnt}" -eq "0" -o "$${pcnt}" -eq "2" ]; then
			# Give up - can't decide which one to take
		        echo More than one LaTeX files found - specify which one to use
		        exit 2
		fi
		# now we know which file to use
		f="$${t}"
		break
	    fi
	done
	if [ "$${cnt}" -eq "0" ]; then
		echo No LaTeX source found
		exit 2
	fi
	# variable 'f' now contains the '.tex' file
	# we let 'make' itself decide how to compile it into the secondary
	$(MAKE) MAKELEVEL=0 "$${f%%.tex}.$(extsec)"
endef


#
# Decide whether to create PDF via PostScript or the other way around,
# depending on whether USE_PDFLATEX is set to "true" or "false"
#
# The rest of Makefile will be pretty much split in two halves,
# one corresponding to PS being the default goal, 
# the other correponding to PDF the main goal
#


################################################################
#                  Default Goal is Postscript                  #
################################################################
ifeq ("$(USE_PDFLATEX)", "false")

#
# Set up the primary and the derivative format extensions
#
ext    := ps
extsec := pdf

#
# Convert all '.tex' file names in SRC into '.ps'
# This will speed up processing
#
override SRC := $(patsubst %.tex, %.$(ext), $(SRC))

#
# Postscript is the default goal, so 'ps' target comes first
#
.ONESHELL:
ps:
	@$(compile_primary)

.ONESHELL:
pdf:
	@$(compile_secondary)

# This is a generic rule how to create a PostScript from TeX
%.ps:: %.tex
	latex $< && latex $< && dvips -o $@ $*.dvi

# This is a generic rule how to create a PDF - generate a Postscript first,
# then convert
%.pdf: %.ps %.tex
	ps2pdf $*.$(ext)


################################################################
#                     Default Goal is PDF                      #
################################################################
else

#
# Set up the primary and the derivative format extensions
#
ext    := pdf
extsec := ps

#
# Convert all '.tex' file names in SRC into '.pdf'
# This will speed up processing
#
override SRC := $(patsubst %.tex, %.$(ext), $(SRC))

#
# PDF is the default goal, so 'pdf' target comes first
#
.ONESHELL:
pdf:
	@$(compile_primary)

.ONESHELL:
ps:
	@$(compile_secondary)

# This is a generic rule how to create a PDF from TeX
%.pdf:: %.tex
	pdflatex $< && pdflatex $<

# This is a generic rule how to create a Postscript - generate a PDF first,
# then convert
%.ps: %.pdf %.tex
	pdf2ps $*.$(ext)

################################################################
#             The end of the format-dependent part             #
################################################################
endif


# This is what happens if the user has requested a TeX file as a goal
# We're just creating a Postscript or PDF in this case
.PHONY: FORCE
%.tex: FORCE
	@$(MAKE) MAKELEVEL=0 "$*.$(ext)"


################################################################
#                     Clean up targets                         #
################################################################

.PHONY: clean clean-ps clean-pdf cleanup clean-all    # The goals such as "clean" are purely logical,
.PHONY: wipe-ps wipe-pdf wipe-all                     # and if there are files with these names by any coincidence, 
                                                      # they should be ignored in work of 'make'

clean:
	rm -f *.aux *.dvi *.log *.toc texput.log *.bak *~

#
# Perform careful cleanings: 'clean-ps' and 'clean-pdf' targets
#
# One of the formats '.ps' and .'pdf' is primary, the other one is derivative.
# A request for cleaning the primary format just does that
# A request for cleaning the secondary (derivative) format also
# removes the primary output file
#
# Both requests check for the existence of the corresponding '.tex' file
# before removing an output file
#
.ONESHELL:
clean-$(ext): clean
	@for file_product in *.$(ext)
	do
		if [ ! -f $${file_product} ]; then continue; fi
		file_tex="$${file_product%%.$(ext)}.tex"
		if [ -f $${file_tex} ]; then 
			echo "rm -f $${file_product}"
			rm -f $${file_product}
		else 
			echo "Leaving $${file_product} (no source file exists)"
		fi
	done
	@$(PERFORM_CLEAN_OUTPUT_FILES)

.ONESHELL:
clean-$(extsec): clean-$(ext)
	@for file_product in *.$(extsec)
	do
		if [ ! -f $${file_product} ]; then continue; fi
		file_tex="$${file_product%%.$(extsec)}.tex"
		if [ -f $${file_tex} ]; then 
			echo "rm -f $${file_product}"
			rm -f $${file_product}
		else 
			echo "Leaving $${file_product} (no source file exists)"
		fi
	done


#
# A couple of additional targets provided for convenience
#
cleanup: clean-$(extsec)

clean-all: clean-$(extsec)

#
# The same sequence of removal occurs with 'wipe' targets:
# if the secondary output format is requested to be "wiped',
# the corresponding target also removes the primary output format files
#
# No checks are made in 'wipe' targets, however
#
wipe-$(ext): clean
	rm -f *.$(ext)

wipe-$(extsec): wipe-$(ext)
	rm -f *.pdf

wipe-all: wipe-$(extsec)


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

.ONESHELL:
help:
	@$(HELP_MESSAGE)

.DEFAULT:
	@echo "Don't know how to process '$<' (file name correct?), try \"make help\" for help"

#
#
# To do:
#
#   * 'clean-ps' and 'clean-pdf' remove the primary output format when needed
#   * File names with spaces
#
#

#
# Version information: $Date$ $Id$ 
# 
