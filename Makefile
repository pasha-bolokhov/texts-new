#
#
# Smart Makefile for running LaTeX for HEP users
#
#
# Sample execution:
#
#   "make"
#
#   "make pdf"
#
#   "make kaon.tex"
#
#   "make kaon.pdf"
#
#   "make clean"
#
#   "make cleanup"
#
#
# DESCRIPTION
# ===========
#
# The purpose of this Makefile is to automate the everyday LaTeX typesetting routine.
# Namely, to automate LaTeX compilation and generation of Postscript or PDF output.
#
# 1. As is well-known, LaTeX usually needs two runs to generate a meaningful output
#
# 2. Its output is DVI, which is not satisfactory for modern user
#
# 3. LaTeX creates a *lot* of auxiliary files, such as 'aux', 'log', 'toc' and so on
#
# So users very often tend to create their own shell scripts which do LaTeX compilation,
# namely, compile the source file twice, and then convert output to Postscript 
# (note that 'pdflatex' generates PDF automatically, by-passing DVI).
# As the user moves from one publication to another, they would copy their shell script,
# and, typically, change the script accordingly, so it uses the file name of the new publication.
# And, surely, this works alright, but it does normally require "some" shell programming
# skills (although maybe not very advanced), and modification of your script 
# each time you start a new paper.
#
# We come about with a Makefile instead, which, we argue is much more versatile than
# such home-made scripts. 
# There are many reasons why we choose to use a Makefile instead of a shell script,
# and we explain them in detail at the end of this description; for now we just 
# stress that 'make' is a very wide-spread tool, and is so old that it 
# exists in all Unix distributions [in the end, it's often far more easy to type "make"
# than type a name of some shell script like "./compile"].
# Note that we are actually targeting precisely Unix or Linux users, as the users
# of OS/X or Windows would typically use a commercial environment or integrated editors which
# provide a certain degree of automation in terms of LaTeX typesetting.
#
# This Makefile is highly customizable. There are simple "user controls" (settings)
# which alter the workflow of compilation. There are also more advanced controls 
# which allow you to do small tricks, and finally you can just modify the core 
# of this Makefile if there is a need and you know how to do it.
#
# Note that this 'Makefile' will work and is intended only for *simple* projects. 
# If you are an experimentalist who are writing a report which includes multiple subdirectories,
# C or Fortran source files, data files, figures, or even Makefiles of your own --
# you are better off by yourself. This Makefile will likely not be able to automatically
# guess your ideas about how to compile your complex report and you might find it unuseful
# or ineffective for your needs. It may interfere with your existing assembly tools
# (e.g. you may already have a Makefile). It's not that it's impossible to use it still,
# and, if you are experienced with Makefiles, you can attempt to customize this script
# to the needs of your project and find it rock.
#
# The same may be true for a theorist who is writing a large report
#
#
# INSTALLATION: 
# None. Just copy this Makefile into your working directory. 
# Type "make" if impatient and see what it has for you
#
#
# Examples
# -------- 
#
# In order to explain the use of this Makefile, we provide illustrative examples,
# which, we hope, will prompt the reader to immediately jump into using this tool.
# 
# 1. You have just ONE source TeX file for your paper in your directory, no figures.
#    The following command will create a Postscript
#
#      $ make ps
#
#    Note that Makefile will automatically find the (only) source file in your directory,
#    call LaTeX (twice), and convert the output into Postscript.
#    Since you very often might need to re-compile the Postscript file, 'ps' is made a default goal,
#    and so if you type just
#
#      $ make
#
#    you'll get a Postscript file without even giving a hint which file you want to LaTeX!
#
#    So yes, your steps are: put this 'Makefile' into your directory, type "make" and you get
#    a Postscript file
#
#    Then, a command
#
#      $ make clean
#
#    will remove all '.aux', '.toc' files, but will leave the Postscript in place.
#
#    If you really need a PDF, then just use
#
#      $ make pdf
#
#    and it will convert the '.ps' file into 'pdf'. Trust me, it's faster than type 
#
#      $ ps2pdf AdS2xS5.ps AdS2xS5.pdf .
#
#    Moreover, it will *not* re-generate the '.ps' file - not unless the LaTeX source has been changed. 
#    This is a general feature of 'make' - it will not generate an output file if it
#    thinks the file is up-to-date.
#    If, on the other hand, you add something new about alternative compactification manifolds
#    to your source file, "make pdf" will first re-compile the source into '.ps' and then generate
#    a new '.pdf'.
#    In this sense, "make pdf" implies doing "make ps" as the first step. 
#
#    Now, those people who use 'pdflatex' - say, when writing a presentation - don't need
#    a Postscript, as 'pdflatex' generates PDF automatically. Please see below in "Controls"
#    how to switch this Makefile to using 'pdflatex' instead.
#
#
#
# 2. You have TWO (or more) LaTeX files in your directory. We would not know why.
#    Some of them might be older versions of your text. Some of them may be figures generated
#    by 'xfig' or a similar tool. Some of them can just be temporary pieces of text
#    or formulas which you saved under names "tmp.tex", "t.tex", "test.tex" and so on. 
#    Some of them can have notations, definitions or formatting that you frequently use, and include
#    with directive '\include'.
#
#    We however *assume* that only one text file at a time is used as a "goal", and other
#    files can be considered as irrelevant for the matter of compilation. 
#    Makefile is unable to guess which file your main text is.
#
#    Then you have to provide the goal -
#
#      $ make muon-g2.tex
#
#    will generate a Postscript (or PDF if you've switched Makefile to use 'pdflatex').
#    You can use the TAB key when typing the filename for bash to complete it, 
#    so you don't have to type it all the way.
#
#    You can be more specific if you want,
#
#      $ make muon-g2.ps
#
#    or 
#
#      $ make muon-g2.pdf
#
#    to generate a PDF. 
#
#    If you just need to convert to PDF (which is a "derivative" format, i.e. obtained from Postscript),
#    you can actually type
#
#      $ make pdf
#
#    if the Postscript file already exists (and is the only Postscript file).
#    Makefile will realize: "there is a single Postscript corresponding to a certain TeX file,
#    so let's generate a PDF for that file now as it most certainly is the main text file"
#
#    Now, if you get tired of typing "make muon-g2.tex" every time, and you know you are about
#    to spend the next month writing that paper, you can go down below into the "User Controls"
#    section of this Makefile, and assign your file name to the SRC variable:
#
#      SRC = muon-g2.tex
#
#    Makefile will not ask you for the file name anymore, and "make", "make ps" or "make pdf" 
#    will be there for you.
#    See the "Controls" section of this Description if you need details about which variable
#    does what.
#
#
#
# 3. Texts with FIGURES. If your LaTeX file includes figures, you may be fine. But if you modify
#    or update a figure, you will notice that 'make' will be reluctant to re-compile your 
#    main text (and incorporate the new figure) -- it simply thinks that the Postscript is up-to-date. 
#
#    You have to tell 'Makefile' that your output file also depends on pictures: go to the
#    "User Control" section below, and set up the FIGURES variable:
#
#      FIGURES = chirality-flip.eps  B-meson.eps  LSP-loop.eps
#
#    or, if you're a theorist, 
#
#      FIGURES = Geneva.jpg  St.Genis-Charlys-Pub.jpg  Leman-Fountain.jpg  Chamonix.jpg
#
#    In fact, it may not even really be figures that your Postscript output depends upon, but other kinds of files 
#    which you may modify from time to time -- in which case an exactly similar variable with just slightly 
#    more appropriate name is used:
#
#      DEPENDS = notations.tex  MSc-thesis-style.tex  PPRdarkblue.sty
#
#    If you do so, 'make' will know that if any of these files gets modified, it has to re-do the Postscript.
#
#    (You can put those file names into FIGURES instead of DEPENDS if you want, but we still think the former 
#    variable should be reserved for names like "Fountain.jpg" and "Hiking-Jura.jpg")
#
#    Note: if you occasionally put into FIGURES or DEPENDS a file name that does not exist, 
#          'make' will punch you (indeed, say you're declaring to add a picture of you skiing at Chamonix,
#          while you actually haven't been in Chamonix) - you gotta get that fixed
#


#
# Plan of documentation
# =====================
#
# - Simple invocation
#
# - Specifying a file
#
# - Cleaning
#
# - Controls
#
# - Structure of Makefile 
#
# - Save/Restore
#
# - Why Makefile
#
# - Suggestions/Problems
#


################################################################
#                                                              #
#                       User Controls                          #
#                                                              #
################################################################

# ----------  To Start, uncomment and edit this line  ----------
#                     SRC = sourcefile.tex
# ----------                                          ----------


#
# Figures and other files your source file (and output) may depend upon.
# You only need to add them if you plan to modify these files often
#
# Examples:
#
#     FIGURES = instan-vertex.eps   sphaleron.eps
#
#     DEPENDS = notations.tex   MITpresentation.sty
#
FIGURES = 
DEPENDS = 


#
# Set this to "true" if 'pdflatex' is needed to be used, "false" for using just 'latex'
#
USE_PDFLATEX = false

#
# This is what gets unconditionally deleted by any 'make clean' command
# Edit this or add other file types if seems handy
#
AUXILIARIES = *.aux *.dvi *.log *.toc texput.log *.bak *~

#
# These variables determine the invocation form of the utilities that are being exploited
# Feel free to change these if necessary
#
LATEX = latex
PDFLATEX = pdflatex
DVIPS = dvips
PS2PDF = ps2pdf
PDF2PS = pdf2ps

# Setting the shell to avoid possible inteference with user's settings
# (although normally this would not happen as 'make' ignores user's SHELL)
SHELL = /bin/sh

# The remove command - this would rarely be changed
# However, you can always "disable" this variable by setting it to
# something else, like ':' to ensure that nothing gets deleted 
# at alls times, e.g. "make RM=: ..."
RM = rm -f


#
# Git related settings
#
GIT = git

# You can replace these with your credentials if you like
export GIT_AUTHOR_NAME = HEP Makefile Save Repository
export GIT_AUTHOR_EMAIL = HEP-Makefile@localhost

# This is the directory where we will store back-ups.
# It can be altered if really needed, but generically it is suggested
# that this directory be different from default Git directory '.git'
# so that if at some point you decide to use Git for version control,
# our auto-saves would not clash with that version control
export GIT_DIR = .git-HEP-backups

# This variable should be modified if 'make' is run
# from elsewhere than the working text directory
export GIT_WORK_TREE = .


#
# HEP-LaTeX-Makefile project on GitHub
#
HEP_LATEX_MAKEFILE_ON_GITHUB = https://github.com/pasha-bolokhov/HEP-LaTeX-Makefile/raw/master/Makefile
USE_CURL = true

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
	(( cnt = 0 ))
	for f in *.tex; do
	    if [ -f "$${f}" ]; then
	        (( cnt++ ))
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
	(( cnt=0 ))
	for f in *.tex; do
	    if [ -f "$${f}" ]; then
	        (( cnt++ ))
	    fi
	    if [ "$${cnt}" -eq "2" ]; then
		(( pcnt = 0 ))
		pfail=false
		# go through all primary output files
		# and see how many of them match a '.tex' file
		for p in *.$(ext); do
			# convert the name to '.tex'
			t="$${p%%.$(ext)}.tex"
			# only count those primary output files for which there is a '.tex' file
			if [ -f "$${p}" -a -f "$${t}" ]; then
				(( pcnt++ ))
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
%.ps:: %.tex $(FIGURES) $(DEPENDS)
	$(LATEX) $< && $(LATEX) $< && $(DVIPS) -o $@ $*.dvi

# This is a generic rule how to create a PDF - generate a Postscript first,
# then convert
%.pdf: %.ps %.tex $(FIGURES) $(DEPENDS)
	$(PS2PDF) $*.$(ext)


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
%.pdf:: %.tex $(FIGURES) $(DEPENDS)
	$(PDFLATEX) $< && $(PDFLATEX) $<

# This is a generic rule how to create a Postscript - generate a PDF first,
# then convert
%.ps: %.pdf %.tex $(FIGURES) $(DEPENDS)
	$(pdf2ps) $*.$(ext)

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

#
# The target 'clean' is always performed when any cleaning command is invoked
#
clean:
	-$(RM) $(AUXILIARIES)

#
# Perform careful cleanings: 'clean-ps' and 'clean-pdf' targets
#
# One of the formats '.ps' and .'pdf' is primary, the other one is derivative.
# A request for cleaning the primary format just does that.
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
			echo "$(RM) $${file_product}"
			$(RM) $${file_product}
		else 
			echo "Leaving $${file_product} (no source file exists)"
		fi
	done

.ONESHELL:
clean-$(extsec): clean-$(ext)
	@for file_product in *.$(extsec)
	do
		if [ ! -f $${file_product} ]; then continue; fi
		file_tex="$${file_product%%.$(extsec)}.tex"
		if [ -f $${file_tex} ]; then 
			echo "$(RM) $${file_product}"
			$(RM) $${file_product}
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
	-$(RM) *.$(ext)

wipe-$(extsec): wipe-$(ext)
	-$(RM) *.pdf

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


################################################################
#                                                              #
#                    Identification Token                      #
#                                                              #
################################################################

#
# This variable is used in order to distinguish this makefile from
# any other people's makefiles they might have. A simple "grep" command
# directed on a 'Makefile' will then be able to tell whether
# it is a HEP-LaTeX-Makefile, or some makefile belonging to somebody's
# project (and therefore completely irrelevant for our purposes)
#
HEP_LATEX_MAKEFILE_IDENTIFICATION_TOKEN = HEP_LATEX_MAKEFILE_IDENTIFICATION_TOKEN



################################################################
#                                                              #
#                      Backup with Git                         #
#                                                              #
################################################################

#
# This is the essential part of the 'save' procedure.
#
# Every time we first check if we need to initialize the repository.
# If we do, we create a repository which is by default different from '.git'
# so it does not clash with possible version control exploited by the user.
# The repository itself needs to be put into the list of ignores, 
# as otherwise 'git' will add the repository into itself.
#
# We check whether any changes in fact have been made by the user ('git status'),
# stage *all* files without exceptions ('git add -A'),
# and add them into the repository ('git commit') with 
# a message that contains the current time for logging purposes.
# We also add a consequent numeric tag for easier retrieval later.
#
define git_save =
	# Check that Git exists
	if ! hash $(GIT) 2>/dev/null; then
		echo "Need to have 'Git' installed to use \"save/restore\" features of HEP Makefile" 1>&2
		exit 2
	fi

	# Create a repository if does not exist yet
	if [ ! -d $(GIT_DIR) ]; then
		$(GIT) init || exit $$?
		echo "/$(GIT_DIR)/" >>$(GIT_DIR)/info/exclude		# Make 'git' ignore its own repository
		echo "/Makefile" >>$(GIT_DIR)/info/exclude		# Ignore this Makefile as well
	fi

	# Get the current tag number
	tag=$$($(GIT) tag | sort -n | tail -1)
	if [ "x$${tag}" = "x" ]; then
		(( tag = 0 ))
	else
		extrasym=$$(echo $${tag} | sed 's/[0-9]//g')
		if [ "x$${extrasym}" != "x" ]; then
			echo "Non-numeric tag name \"$${tag}\" in repository history" 1>&2
			exit 2
		fi
		# Move the tag number on
		(( tag++ ))
	fi

	# Stage all modified, added and deleted files
	$(GIT) add -A || exit $$?

	# Now check whether anything has changed at all
	status=$$($(GIT) status --porcelain)
	if [ "x$${status}" = "x" ]; then
		echo "No changes found"
		exit
	fi

	# Use date as the essential part of the commit message
	MESSAGE="HEP Makefile Backup performed on $$(date)"

	# Go ahead and commit it in
	$(GIT) commit -m "$${MESSAGE}" || { 
		errno=$$?
		echo -n "Commit failed (errno $${errno}). Attempting to unstage changes... " 1>&2
		$(GIT) reset || exit $$?
		echo "done" 1>&2
		exit $${errno}
	}

	# Add a tag with a numeric name
	$(GIT) tag $${tag} || {
		errno=$$?
		echo "Wasn't able to create a numeric tag -- won't be able to easily restore this version" 1>&2
		exit $${errno}
	}
	echo "Saved the working state with a tag \"$${tag}\""
endef


#
# This is the essential part of the 'unerase' procedure
#
#  
#
define git_unerase =
	# Check that Git exists
	if ! hash $(GIT) 2>/dev/null; then
		echo "Need to have 'Git' installed to use \"save/restore\" features of HEP Makefile" 1>&2
		exit 2
	fi

	# If the repository does not exist, we've nothing to do!
	if [ ! -d $(GIT_DIR) ]; then
	    echo 'Looks like nothing has been saved yet!' 1>&2
	    exit 2
	fi

	# Print a message about files being restored
	files=$$($(GIT) ls-files --deleted | tr \\n " ")    # Need to get rid of 'newline' character 
                                                            # between the file names
	if [ "x$${files}" != "x" ]; then                    
		echo "Restoring $${files}"
	else
		echo "No deleted files found"
	fi

	# Sift the list of deleted files through the pipe and into 'checkout'
	$(GIT) ls-files --deleted -z | xargs -0 git checkout -- 
endef

#
# This is the essential part of the 'show-saved' target
#
define show_saved =
	# Check that Git exists
	if ! hash $(GIT) 2>/dev/null; then
		echo "Need to have 'Git' installed to use \"save/restore\" features of HEP Makefile" 1>&2
		exit 2
	fi

	# If the repository does not exist, we've nothing to do!
	if [ ! -d $(GIT_DIR) ]; then
	    echo 'Looks like nothing has been saved yet!' 1>&2
	    exit 2
	fi

	# Show the list of the cached files
	$(GIT) ls-files --cached | column
endef

#
# This is the essential part of the 'list-saved' target
#
define list_saved =
	# Check that Git exists
	if ! hash $(GIT) 2>/dev/null; then
		echo "Need to have 'Git' installed to use \"save/restore\" features of HEP Makefile" 1>&2
		exit 2
	fi

	# If the repository does not exist, we've nothing to do!
	if [ ! -d $(GIT_DIR) ]; then
	    echo 'Looks like nothing has been saved yet!' 1>&2
	    exit 2
	fi

	# Get the list of tags
	tags=$$($(GIT) tag | sort -n)
	if [ "x$${tags}" = "x" ]; then
		echo No tagged revisions found
		exit
	fi

	# Print the tags along with the corresponding committer dates
	echo
	echo -e "\tRevision\t\tWhen"
	echo
	for tag in $${tags}; do
		date=$$($(GIT) show $${tag} --pretty="format:%cd (%cr)" | head -1)
		echo -e "\t    $${tag}\t\t    $${date}"
	done
endef

#
# This is the essential part of the 'restore-%' target
#
# First, if there are any changes, we save them. 
# Check out the requested tag and move the 'master' branch
# to point to the current tag
#
define git_checkout =
	# Check that Git exists
	if ! hash $(GIT) 2>/dev/null; then
		echo "Need to have 'Git' installed to use \"save/restore\" features of HEP Makefile" 1>&2
		exit 2
	fi

	# If the repository does not exist, we've nothing to do!
	if [ ! -d $(GIT_DIR) ]; then
	    echo 'Looks like nothing has been saved yet!' 1>&2
	    exit 2
	fi

	# Check whether the requested tag exists
	tag=$$(echo $@ | sed 's/restore-//')
	found=$$($(GIT) tag | grep "$${tag}")
	if [ "x$${found}" = "x" ]; then
		echo "Tag \"$${tag}\" not found in repository history" 1>&2
		exit 2
	fi

	# See if anything needs to be saved first
	status=$$($(GIT) status --porcelain)
	if [ "x$${status}" != "x" ]; then
		echo Saving changes first...
		$(MAKE) MAKELEVEL=0 save || exit $$?
	fi

	# Finally, do the checkout
	echo
	echo "Checking out \"$${tag}\""...
	$(GIT) checkout -b tmp $${tag} > /dev/null

	# Reset the master to the current position
	$(GIT) branch -M tmp master
endef

#
# This is the essential part of the 'update-make' target
#
define update_make =
	# Check if we have "curl" or "wget"
	if [ "x$(USE_CURL)" = "xtrue" ]; then
		use_curl=1
		if ! hash curl 2>/dev/null; then
			if ! hash wget 2>/dev/null; then
				echo "Need to have \"curl\" or \"wget\" installed" 1>&2
				exit 2
			fi
			use_curl=0
		fi
	elif [ "x$(USE_CURL)" = "xfalse" ]; then
		if ! hash wget 2>/dev/null; then
			echo "Need to have \"curl\" or \"wget\" installed" 1>&2
			exit 2
		fi
		use_curl=0
	else
		echo "USE_CURL must be either \"true\" or \"false\", but not \"$(USE_CURL)\"" 1>&2
		exit 2
	fi

	echo "Will now download Makefile from GitHub into \"Makefile.latest\"..." 1>&2
	echo 1>&2

	if [ $${use_curl} -eq 1 ]; then
		curl -L -o Makefile.latest -f $(HEP_LATEX_MAKEFILE_ON_GITHUB)
	else
		wget -O Makefile.latest $(HEP_LATEX_MAKEFILE_ON_GITHUB)
	fi || {
		errno=$$?
		echo -e "" 1>&2
		echo -e "\tCouldn't retrieve the latest Makefile" 1>&2
		echo -e "\tYou may try to download it yourself from:" 1>&2
		echo -e "\t$(HEP_LATEX_MAKEFILE_ON_GITHUB)" 1>&2
		echo -e "\t" 1>&2
		exit $${errno}
	}

	echo "" 1>&2
	echo "Check \"Makefile.latest\" and rename it into \"Makefile\" when ready" 1>&2
endef


#
# The actual Git targets
#
.PHONY: save restore show-saved list-saved
.PHONY: update-make
.ONESHELL: save restore show-saved list-saved
.ONESHELL: update-make

save:
	@$(git_save)

unerase:
	@$(git_unerase)

show-saved:
	@$(show_saved)

list-saved:
	@$(list_saved)

restore-%:
	@$(git_checkout)

update-make:
	@$(update_make)

#
#
# To do:
#
#   * File names with spaces
#   * Documentation
#   * Check version and origin of 'make'
#   * Make 'Makefile' as much GNU-compliant as possible
#   * Make banners hierarchical
#   * Recursive invocation of 'make' does not pass along the name of Makefile
#   * Check for errors near the first "git ls-files" in 'git_restore'
#   * Move various common checks (such as whether 'git' exists) into variables
#
#

#
# Version information: $Date$ $Id$ 
# 
