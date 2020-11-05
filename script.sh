#!/bin/bash
############################################################################################################
#Zadanie skriptu od websupportu

############################################################################################################
#Globalne premenne
DISK_THRESHOLD=75 # Hranica od ktorej bude vypisovat vytazenie disku

############################################################################################################
#Funkcie


FullOption () {

    #Ak je zadany input existujuci subor a nerovna sa 0
    if [[ -f $1 && $1 != 0 ]]
                    then
                        #Porovna DISK_THRESHOLD premennu s hodnotou v zadanom subore
                        awk -v dt=$DISK_THRESHOLD '{if($7 > dt) print "Hostname: " $1 ", disk space usage is " $7}' $1

                    else

                        #Porovna DISK_THRESHOLD premennu s hodnotou v zadanom subore (pyta vstup s klavesnice)
                        echo "ERROR: Filename missing. Please enter filename and hit ENTER: "
                        read -r file
                        awk -v dt=$DISK_THRESHOLD '{if($7 > dt) print "Hostname: " $1 ", disk space usage is " $7}' $file

                    fi
    

}

CountOption () {

    if [[ -f $1 && $1 != 0 ]]               
                    then

                        #TOTAL 
                        awk '{ ++count } END { print "Total lines: " count}' $1

                        #VALID
                        awk 'NF == 8 && $1~/mysql/ && $2~/[[:digit:]+]/ && $3~/dbs/ && ($3~/sd/ || $3~/xvd/) && $4~/[[:digit:]+]/ && $5~/[[:digit:]+]/ && $6~/[[:digit:]+]/ && $4~/[[:digit:]+]/ { 
                            
                            ++count } END { print "Valid lines: " count}' $1

                        #INVALID and BLANK
                        awk 'NF == 0 { ++countB } (!(NF == 8 && $1~/mysql/ && $2~/[[:digit:]+]/ && $3~/dbs/ && ($3~/sd/ || $3~/xvd/) && $4~/[[:digit:]+]/ && $5~/[[:digit:]+]/ && $6~/[[:digit:]+]/ && $4~/[[:digit:]+]/)) { 
                            
                            ++countI } END { print "Invalid lines: " countI " (" countB + 0 " of them are BLANK)"}' $1

                    else

                        echo "ERROR: Filename missing. Please enter filename and hit ENTER: "
                        read -r file 
                        #TOTAL
                        awk '{ ++count } END { print "Total lines: " count}' $file

                        #VALID
                        awk 'NF == 8 && $1~/mysql/ && $2~/[[:digit:]+]/ && $3~/dbs/ && ($3~/sd/ || $3~/xvd/) && $4~/[[:digit:]+]/ && $5~/[[:digit:]+]/ && $6~/[[:digit:]+]/ && $4~/[[:digit:]+]/ { ++count } END { print "Valid lines: " count}' $file

                        #INVALID and BLANK
                        awk 'NF == 0 { ++countB } (!(NF == 8 && $1~/mysql/ && $2~/[[:digit:]+]/ && $3~/dbs/ && ($3~/sd/ || $3~/xvd/) && $4~/[[:digit:]+]/ && $5~/[[:digit:]+]/ && $6~/[[:digit:]+]/ && $4~/[[:digit:]+]/)) { ++countI } END { print "Invalid lines: " countI " (" countB + 0 " of them are BLANK)"}' $file


                    fi

    
} 

ValidateOption () {

    if [[ -f $1 && $1 != 0 ]]               
                    then

                        echo "#################################################" 
                        #awk 'NR==FNR {count[$0]++; next} count[$0]>1 {printf "DUPLICATE: %s \n",$0 " ----------- on line number " NR > "/dev/stderr"}' $1 $1
                        awk '{ 
                        if(NF == 8 && $1~/mysql/ && $2~/[[:digit:]+]/ && $3~/dbs/ && ($3~/sd/ || $3~/xvd/) && $4~/[[:digit:]+]/ && $5~/[[:digit:]+]/ && $6~/[[:digit:]+]/ && $4~/[[:digit:]+]/) {

                            printf "OK: %s \n",$0 > "/dev/stdout"

                                                            } 
                        else if(NF == 0) {

                            printf "BLANK LINE: %s \n",$0 " ----------- on line number " NR > "/dev/stderr" 

                                                            }
                        else if(!(NF == 8 && $1~/mysql/ && $2~/[[:digit:]+]/ && $3~/dbs/ && ($3~/sd/ || $3~/xvd/) && $4~/[[:digit:]+]/ && $5~/[[:digit:]+]/ && $6~/[[:digit:]+]/ && $4~/[[:digit:]+]/)) {

                            printf "INVALID: %s \n",$0 " ----------- on line number " NR > "/dev/stderr" 

                                                            }                                    
                            }' $1 | sort -k 2
                        echo "#################################################" 

                    else

                        echo "ERROR: Filename missing. Please enter filename and hit ENTER: "
                        read -r file
                        echo "#################################################" 
                        #awk 'NR==FNR {count[$0]++; next} count[$0]>1 {printf "DUPLICATE: %s \n",$0 " ----------- on line number " NR > "/dev/stderr"}' $file $file
                        awk '{ 
                        if(NF == 8 && $1~/mysql/ && $2~/[[:digit:]+]/ && $3~/dbs/ && ($3~/sd/ || $3~/xvd/) && $4~/[[:digit:]+]/ && $5~/[[:digit:]+]/ && $6~/[[:digit:]+]/ && $4~/[[:digit:]+]/) {

                            printf "OK: %s \n",$0 > "/dev/stdout"

                                                            } 
                        else if(NF == 0) {

                            printf "BLANK LINE: %s \n",$0 " ----------- on line number " NR > "/dev/stderr" 

                                                            }
                        else if(!(NF == 8 && $1~/mysql/ && $2~/[[:digit:]+]/ && $3~/dbs/ && ($3~/sd/ || $3~/xvd/) && $4~/[[:digit:]+]/ && $5~/[[:digit:]+]/ && $6~/[[:digit:]+]/ && $4~/[[:digit:]+]/)) {

                            printf "INVALID: %s \n",$0 " ----------- on line number " NR > "/dev/stderr" 

                                                            }
                            }' $file | sort
                        echo "#################################################"
                    fi

}

Help () {

    echo "////////////////////////////////////////////////////"
    echo "Usage: $0 --full || --count || --validate <filename>"
    echo "-------------------------------------------------"  
    echo "Format vstupu: <server>: (<pocet> dbs)<disk> <total>G <used>G <free>G <perc>% <mount>"
    echo "-------------------------------------------------"
    echo "Meno suboru sa moze zadat bud priamo za skript a option alebo zadat iba skript a option a skript vypyta nazov zo vstupu usera"  
    echo "-------------------------------------------------"    
    echo "[--full] <filename> - Zistuje ci je percentualne vyuzitie disku vacsie ako DISK_THRESHOLD premenna (default 75%)"
    echo "[--count] <filename> - Spocita a vypise pocet vsetkych, validnych, invalidnych a prazdnych riadkov"
    echo "[--validate] <filename> - Validuje riadky ci splnaju specifikovany format zapisu"
    echo "////////////////////////////////////////////////////"  
    exit 2

}

############################################################################################################
#Navedie na -h option ked sa nezada nic okrem mena skriptu
#!/bin/bash
############################################################################################################
#Zadanie skriptu od websupportu

############################################################################################################
#Globalne premenne
DISK_THRESHOLD=75 # Hranica od ktorej bude vypisovat vytazenie disku

############################################################################################################
#Funkcie


FullOption () {

    #Ak je zadany input existujuci subor a nerovna sa 0
    if [[ -f $1 && $1 != 0 ]]
                    then
                        #Porovna DISK_THRESHOLD premennu s hodnotou v zadanom subore
                        awk -v dt=$DISK_THRESHOLD '{if($7 > dt) print "Hostname: " $1 ", disk space usage is " $7}' $1

                    else

                        #Porovna DISK_THRESHOLD premennu s hodnotou v zadanom subore (pyta vstup s klavesnice)
                        echo "ERROR: Filename missing. Please enter filename and hit ENTER: "
                        read -r file
                        awk -v dt=$DISK_THRESHOLD '{if($7 > dt) print "Hostname: " $1 ", disk space usage is " $7}' $file

                    fi
    

}

CountOption () {

    if [[ -f $1 && $1 != 0 ]]               
                    then

                        #TOTAL 
                        awk '{ ++count } END { print "Total lines: " count}' $1

                        #VALID
                        awk 'NF == 8 && $1~/mysql/ && $2~/[[:digit:]+]/ && $3~/dbs/ && ($3~/sd/ || $3~/xvd/) && $4~/[[:digit:]+]/ && $5~/[[:digit:]+]/ && $6~/[[:digit:]+]/ && $4~/[[:digit:]+]/ { 
                            
                            ++count } END { print "Valid lines: " count}' $1

                        #INVALID and BLANK
                        awk 'NF == 0 { ++countB } (!(NF == 8 && $1~/mysql/ && $2~/[[:digit:]+]/ && $3~/dbs/ && ($3~/sd/ || $3~/xvd/) && $4~/[[:digit:]+]/ && $5~/[[:digit:]+]/ && $6~/[[:digit:]+]/ && $4~/[[:digit:]+]/)) { 
                            
                            ++countI } END { print "Invalid lines: " countI " (" countB + 0 " of them are BLANK)"}' $1

                    else

                        echo "ERROR: Filename missing. Please enter filename and hit ENTER: "
                        read -r file 
                        #TOTAL
                        awk '{ ++count } END { print "Total lines: " count}' $file

                        #VALID
                        awk 'NF == 8 && $1~/mysql/ && $2~/[[:digit:]+]/ && $3~/dbs/ && ($3~/sd/ || $3~/xvd/) && $4~/[[:digit:]+]/ && $5~/[[:digit:]+]/ && $6~/[[:digit:]+]/ && $4~/[[:digit:]+]/ { ++count } END { print "Valid lines: " count}' $file

                        #INVALID and BLANK
                        awk 'NF == 0 { ++countB } (!(NF == 8 && $1~/mysql/ && $2~/[[:digit:]+]/ && $3~/dbs/ && ($3~/sd/ || $3~/xvd/) && $4~/[[:digit:]+]/ && $5~/[[:digit:]+]/ && $6~/[[:digit:]+]/ && $4~/[[:digit:]+]/)) { ++countI } END { print "Invalid lines: " countI " (" countB + 0 " of them are BLANK)"}' $file


                    fi

    
} 

ValidateOption () {

    if [[ -f $1 && $1 != 0 ]]               
                    then

                        echo "#################################################" 
                        #awk 'NR==FNR {count[$0]++; next} count[$0]>1 {printf "DUPLICATE: %s \n",$0 " ----------- on line number " NR > "/dev/stderr"}' $1 $1
                        awk '{ 
                        if(NF == 8 && $1~/mysql/ && $2~/[[:digit:]+]/ && $3~/dbs/ && ($3~/sd/ || $3~/xvd/) && $4~/[[:digit:]+]/ && $5~/[[:digit:]+]/ && $6~/[[:digit:]+]/ && $4~/[[:digit:]+]/) {

                            printf "OK: %s \n",$0 > "/dev/stdout"

                                                            } 
                        else if(NF == 0) {

                            printf "BLANK LINE: %s \n",$0 " ----------- on line number " NR > "/dev/stderr" 

                                                            }
                        else if(!(NF == 8 && $1~/mysql/ && $2~/[[:digit:]+]/ && $3~/dbs/ && ($3~/sd/ || $3~/xvd/) && $4~/[[:digit:]+]/ && $5~/[[:digit:]+]/ && $6~/[[:digit:]+]/ && $4~/[[:digit:]+]/)) {

                            printf "INVALID: %s \n",$0 " ----------- on line number " NR > "/dev/stderr" 

                                                            }                                    
                            }' $1 | sort -k 2
                        echo "#################################################" 

                    else

                        echo "ERROR: Filename missing. Please enter filename and hit ENTER: "
                        read -r file
                        echo "#################################################" 
                        #awk 'NR==FNR {count[$0]++; next} count[$0]>1 {printf "DUPLICATE: %s \n",$0 " ----------- on line number " NR > "/dev/stderr"}' $file $file
                        awk '{ 
                        if(NF == 8 && $1~/mysql/ && $2~/[[:digit:]+]/ && $3~/dbs/ && ($3~/sd/ || $3~/xvd/) && $4~/[[:digit:]+]/ && $5~/[[:digit:]+]/ && $6~/[[:digit:]+]/ && $4~/[[:digit:]+]/) {

                            printf "OK: %s \n",$0 > "/dev/stdout"

                                                            } 
                        else if(NF == 0) {

                            printf "BLANK LINE: %s \n",$0 " ----------- on line number " NR > "/dev/stderr" 

                                                            }
                        else if(!(NF == 8 && $1~/mysql/ && $2~/[[:digit:]+]/ && $3~/dbs/ && ($3~/sd/ || $3~/xvd/) && $4~/[[:digit:]+]/ && $5~/[[:digit:]+]/ && $6~/[[:digit:]+]/ && $4~/[[:digit:]+]/)) {

                            printf "INVALID: %s \n",$0 " ----------- on line number " NR > "/dev/stderr" 

                                                            }
                            }' $file | sort
                        echo "#################################################"
                    fi

}

Help () {

    echo "////////////////////////////////////////////////////"
    echo "Usage: $0 --full || --count || --validate <filename>"
    echo "-------------------------------------------------"  
    echo "Format vstupu: <server>: (<pocet> dbs)<disk> <total>G <used>G <free>G <perc>% <mount>"
    echo "-------------------------------------------------"
    echo "Meno suboru sa moze zadat bud priamo za skript a option alebo zadat iba skript a option a skript vypyta nazov zo vstupu usera"  
    echo "-------------------------------------------------"    
    echo "[--full] <filename> - Zistuje ci je percentualne vyuzitie disku vacsie ako DISK_THRESHOLD premenna (default 75%)"
    echo "[--count] <filename> - Spocita a vypise pocet vsetkych, validnych, invalidnych a prazdnych riadkov"
    echo "[--validate] <filename> - Validuje riadky ci splnaju specifikovany format zapisu"
    echo "////////////////////////////////////////////////////"  
    exit 2

}

############################################################################################################
#Navedie na -h option ked sa nezada nic okrem mena skriptu
[ $# -eq 0 ] && { echo "ERROR: No option provided. Try -h for help."; exit; }

############################################################################################################
#Skript start
optspec=":h-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        -)
            case "${OPTARG}" in

                full)
                    
                    FullOption $2

                    ;;

                count)

                    CountOption $2
                    
                    ;;

                validate)
                    
                    ValidateOption $2

                    ;;
                *)
                    #Zobrazi HELP ked sa zada neexistujuci "--" option
                    echo "ERROR: Unknown option. " > "/dev/stderr"
                    Help
                    ;;
            esac;;
        h)

            Help
            
            ;;

        *)
            #Zobrazi HELP ked sa zada neexistujuci "-" option
            echo "ERROR: Unknown option. " > "/dev/stderr"
            Help
            ;;
    esac
done
############################################################################################################
#Skript end
