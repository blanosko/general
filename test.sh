#!/bin/bash
############################################################################################################
#Zadanie skriptu od websupportu

############################################################################################################
#Navedie na -h option ked sa nezada nic okrem mena skriptu
[ $# -eq 0 ] && { echo "Type -h for help"; exit 999; }

############################################################################################################
#Globalne premenne
DISK_THRESHOLD=75 # Hranica od ktorej bude vypisovat vytazenie disku
LINE_COUNT=$(grep "" -c $2)

############################################################################################################
#Funkcie
ValidateFile () {
    echo "#################################################" 
        awk '{ 
        if(NF == 8   &&   $1 ~ /mysql/   &&   $3 ~ /dbs/   &&   ($3 ~ /sd/ || $3 ~ /xvd/)   &&   $4 ~ /G/   &&   $5 ~ /G/   &&   $6 ~ /G/   &&   $7 ~ /%/) {

            printf "OK: %s \n",$0 > "/dev/stdout"

                } 
        else if(NF == 0) {

            printf "BLANK LINE: %s \n",$0 " ----------- on line number " NR > "/dev/stderr" 

                }
        else if(!(NF == 8   &&   $1 ~ /mysql/   &&   $3 ~ /dbs/   &&   ($3 ~ /sd/ || $3 ~ /xvd/)   &&   $4 ~ /G/   &&   $5 ~ /G/   &&   $6 ~ /G/   &&   $7 ~ /%/)) {

            printf "INVALID: %s \n",$0 " ----------- on line number " NR > "/dev/stderr" 

                }                                    
        }' $1 | sort 
    echo "#################################################"                 

}

ValidateInput () {
    echo "ERROR: Filename missing. Please enter filename and hit ENTER: "
    read -r file
    echo "#################################################" 
    awk '{ 
        if(NF == 8   &&   $1 ~ /mysql/   &&   $3 ~ /dbs/   &&   ($3 ~ /sd/ || $3 ~ /xvd/)   &&   $4 ~ /G/   &&   $5 ~ /G/   &&   $6 ~ /G/   &&   $7 ~ /%/) {

            printf "OK: %s \n",$0 > "/dev/stdout"

                } 
        else if(NF == 0) {

            printf "BLANK LINE: %s \n",$0 " ----------- on line number " NR > "/dev/stderr" 

                }
        else if(!(NF == 8   &&   $1 ~ /mysql/   &&   $3 ~ /dbs/   &&   ($3 ~ /sd/ || $3 ~ /xvd/)   &&   $4 ~ /G/   &&   $5 ~ /G/   &&   $6 ~ /G/   &&   $7 ~ /%/)) {

            printf "INVALID: %s \n",$0 " ----------- on line number " NR > "/dev/stderr" 

                }                                    
        }' $file | sort
    echo "#################################################"                 

}

CheckDiskUsageFile () {

    awk -v dt=$DISK_THRESHOLD '{if($7 > dt) print "Hostname: " $1 ", disk space usage is " $7}' $1

}

CheckDiskUsageInput () {

    echo "ERROR: Filename missing. Please enter filename and hit ENTER: "
    read -r file
    awk -v dt=$DISK_THRESHOLD '{if($7 > dt) print "Hostname: " $1 ", disk space usage is " $7}' $file
}

CountFile () {
    
awk -v lc=$LINE_COUNT '{ 
        if(NF == 8   &&   $1 ~ /mysql/   &&   $3 ~ /dbs/   &&   ($3 ~ /sd/ || $3 ~ /xvd/)   &&   $4 ~ /G/   &&   $5 ~ /G/   &&   $6 ~ /G/   &&   $7 ~ /%/) {
            
          printf "Valid lines: \n" lc > "/dev/stderr"

                } 
        
        

        }' $1 | sort | tail -1
}

CountInput () {

    echo ""

}


############################################################################################################
#Skript start
optspec=":h-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        -)
            case "${OPTARG}" in

                full)
                    if [[ -f $2 && $2 != 0 ]]
                    then

                        CheckDiskUsageFile $2

                    else [[ $2 = 0 ]]

                        CheckDiskUsageInput  

                    fi
                    ;;

                count)
                    if [[ -f $2 && $2 != 0 ]]               
                    then
                        #echo "Line count: "
                        #grep "" -c $2
                        CountFile $2
                        #echo "Blank lines: "
                        #grep -cvP '\S' $2
                    else
                        echo "ERROR: filename not supplied" >&2
                        exit
                    fi
                    ;;

                validate)
                    if [[ -f $2 && $2 != 0 ]]               
                    then

                        ValidateFile $2    

                    else

                        ValidateInput 

                    fi
                    ;;
                *)
                    if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                        echo "Unknown option --${OPTARG}" >&2
                    fi
                    ;;
            esac;;
        h)
            echo "Usage: $0 [--full] [--count] [--validate] <filename>"
            echo "-------------------------------------------------"  
            echo "Format vstupu: <server>: (<pocet> dbs)<disk> <total>G <used>G <free>G <perc>% <mount>"
            echo "-------------------------------------------------"  
            echo "[--full] <filename> - Zistuje ci je percentualne vyuzitie disku vacsie ako DISK_THRESHOLD premenna (default 75%)"
            echo "[--count] <filename> - Spocita a vypise pocet validnych a prazdnych riadkov"
            echo "[--validate] <filename> - Validuje riadky ci splnaju specifikovany format zapisu"
            echo "-------------------------------------------------"   
            exit 2
            ;;
        *)
            if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
                echo "Non-option argument: '-${OPTARG}'" >&2
            fi
            ;;
    esac
done
############################################################################################################
#Skript end


