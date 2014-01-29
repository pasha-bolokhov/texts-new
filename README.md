HEP-LaTeX-Makefile
==================

This project delivers a single 'Makefile' useful for HEP community 
writing articles in LaTeX. The primary use is to remove the overhead
of typing 'latex' twice, converting PS to PDF (or vice versa) when needed,
and majorly, of having to remove the annoying '*.tex~' '*.aux' '*.log' 
and so on files.


To illustrate simplicity, in a directory containing only one TeX source file, 
a simple

$ make

will do the job creating a PS file (or, the default target can be changed to PDF),
automatically finding the TeX file, and compiling it. 


The second use is that a single 

$ make clean

will remove all the generated LaTeX overhead files such as '*.aux', '*.log',
Emacs backup '*~' and so on. This command will NOT remove the generated PS 
or PDF files.


The 'Makefile' is highly customizeable, abundant with comments targeted
at users unfamiliar with 'Makefile' semantics. Simplest variable modifications
do most of customization tricks


Report errors to "Pasha Bolokhov <pasha.bolokhov@gmail.com>"

