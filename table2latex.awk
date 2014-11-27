#
# Takes a table and prints out a latex fragment that can be pasted
# into your latex document.
# To import the table to lyx use:
#   file>import>ASCII>lines
#   select all and redline it
#   file>export>latex
#   file>import>latex
# It is now a lyx table.
# The algorithm is very simple. Reads the first
# line and assumes all further lines will have this many columns.
#
BEGIN{	FS="\\t";
	print "\\documentclass[english]{article}"
	print "\\usepackage[T1]{fontenc}"
	print "\\usepackage[latin1]{inputenc}"
	print "\\usepackage{babel}\n\n"
	print "\\makeatletter"
	print "\\makeatother\n\n"
	print "\\begin{document}"
	}
/#/{gsub(/#/,"\\#")}
NR==1{ NoCols=NF; print "\\begin{tabular}{|*{" NoCols "}{c|}}";}
{ for (i=1;i<NoCols;i++){printf "%s&",$i};
	printf "%s\\\\\n",$i
	}
END{	print "\\end{tabular}"
	print "\\end{document}"
	}

