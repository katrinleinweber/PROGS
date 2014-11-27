
OUTP=${REFERENCETYPE:-hol}

while ( echo $1 | grep "^-" > /dev/null ); do
        case $1 in
        -bbl )  OUTP=bbl
                shift
                ;;
        -asc )  OUTP=asc
                shift
                ;;
        -* )    echo Option not recognised $1
                exit 2
                ;;
        esac
done

echo $OUTP
echo $*
echo $#


