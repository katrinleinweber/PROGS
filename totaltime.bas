REM  *****  BASIC  *****

Sub Main

End Sub

function vol(a,b,c)
	vol=a*b*c
end function

REM *********************
function totaltime(a)
' calculates the total time represented by a string such as
' 8:45-9:00+10:30-11:30, which indicates a total time of 1:15
	dim b$(),c$()
	t=0
	' remove brackets
	j=instr(a,"(")  :  mid(a,j,1,"")
	j=instr(a,")")  :  mid(a,j,1,"")
	' split time slots
    b=split(a,"+")
    for i=lbound(b()) to ubound(b())
    	' split time pairs
		c=split(b(i),"-")
		' sum
		t=t+(timevalue(c(1))-timevalue(c(0)))
	next i
	' returning
	totaltime=t
end function


