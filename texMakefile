
# pdfs = paper.pdf
# 
# all : $(pdfs:.pdf=.dvi) $(pdfs)


%.dvi: %.tex
	-latex $*
	-bibtex $*
	-latex $*
	-bibtex $*
	-latex $*
	-latex $* 
	-latex $* 

%.ps : %.dvi
	-dvips  -M -t letter -Ppdf -f $*.dvi > $*.ps
	# dvips -f $*.dvi > $*.ps

%.pdf : %.ps
	ps2pdf $*.ps
	# echo pdf complete

# .PHONY : clean cleanall
# 
# clean: 
# 	rm -f $(pdfs:.pdf=.ps) $(pdfs:.pdf=.dvi) \
# 		$(pdfs:.pdf=.log) $(pdfs:.pdf=.aux)


# cleanall : clean
# 	rm -f $(pdfs) 

