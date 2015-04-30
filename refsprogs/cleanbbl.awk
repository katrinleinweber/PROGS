#
# this awk cleans up the bbl file (output from LaTeX and BibTeX)
# so that it displays as a plain ASCII file
# 2009/02/27 CMDR
# 
# 2011-02-24 take care of more special characters (\i,\j)
#

BEGIN{nowreading=0}
/^\\bibitem/{
	while ($0!~"{[^}]*}$"){getline}
	print gensub("^.*{(.*)}.*$","\\1",1)
	nowreading=1 
	next}
       {gsub("\\\\newblock","")
	gsub("\\\\penalty[0-9]*","") 
	# diacritics
	$0=gensub("{*\\\\[`'~\"^v]{*([a-zA-Z])}*","\\1","g");
	# single letter marks
	$0=gensub("{*\\\\([ijoO])}*","\\1","g");
	# break spaces
	gsub("~"," ");
	# LaTeX tags
	$0=gensub("\\\\emph{([^}]*)}?","\\1","g");
	$0=gensub("\\\\textit{([^}]*)}?","\\1","g");
	$0=gensub("\\\\textbf{([^}]*)}?","\\1","g");
	$0=gensub("\\\\doi{([^}]*)}","doi:\\1","g");
	$0=gensub("{\\\\natexlab{[a-z]*}}","","g");
	# curlies around capitals
	$0=gensub("{([A-Z]*)}","\\1","g");
	# lurking curlies
	gsub("}","");
	gsub("{","");
	}
nowreading{print}
/^$/{nowreading=0}

