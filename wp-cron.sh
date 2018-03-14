#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'

init () {
        printf "Locating WordPress installations"

        while read line
        do
                let i++

                configcheck="false"

                wp config has DISABLE_WP_CRON --path=$line


                if [ $? -eq 0 ]
                then
                        configcheck=`wp config get DISABLE_WP_CRON --path=$line`
                fi

                wp_cron[$i]=[$configcheck]

                INSTPATH[$i]=$line

                printf "."
        done <<< "$(find | grep wp-config.php | sed -r 's:/wp-config.php::' | sort )"

        echo ""
        echo Found $i WordPress installations
}

printmenu(){
        echo "Main Menu"
        echo ""
        echo "1:  Set DISABLE_WP_CRON to true on all WordPress Installations"
        echo "2:  Set DISABLE_WP_CRON to false on all WordPress Installations"
        echo "3:  List all WordPress Installations"
        echo "4:  Toggle DISABLE_WP_CRON on a single WordPress Installation"
        echo "5:  Run all WP Cron jobs due"
        echo "6:  Exit"
        echo ""
        echo "Select Item"
}

printlist(){
        for ((index=1;index<=$i;index++))
        do
                if [ ${wp_cron[$index]} = "[true]" ]
                then
                        color=$GREEN
                else
                        color=$RED
                fi

                echo -e "${index} : ${CYAN}${INSTPATH[$index]}${NC} : DISABLE_WP_CRON = ${color}${wp_cron[$index]}${NC}"
        done
}

toggle(){
        path="${INSTPATH[$1]}"
        if [ ${wp_cron[$1]} = "[true]" ]
        then
                newvalue="false"
        else
                newvalue="true"
        fi

        result=`wp config set DISABLE_WP_CRON $newvalue --type=constant --path=${INSTPATH[$1]}`
        if [ $? -ne 0 ]
        then
                echo "Failed to set DISABLE_WP_CRON to $newvalue for ${INSTPATH[$1]}"
        else
                configcheck=`wp config get DISABLE_WP_CRON --path=${INSTPATH[$1]}`
                wp_cron[$1]=[$configcheck]
        fi

}

setall(){
        for ((index=1;index<=$i;index++))
        do
                result=`wp config set DISABLE_WP_CRON $1 --type=constant --path=${INSTPATH[$index]}`

                if [ $? -ne 0 ]
                then
                        echo "Failed to set DISABLE_WP_CRON to $1 for ${INSTPATH[$index]}"
                else
                        configcheck=`wp config get DISABLE_WP_CRON --path=${INSTPATH[$index]}`
                        wp_cron[$index]=[$configcheck]                        
                fi
        done
}

wp-cron () {
        echo "**************** Starting wp-cron **************"
        echo `date -u  +'%F %T %:z'` - Running wp-cron
        echo

        for ((index=1;index<=$i;index++))
        do
                if [ ${wp_cron[$index]} = "[true]" ]
                then
                        if [ "$interactive" = "1" ]; then
                                echo -e "${CYAN}`date -u  +'%F %T %:z'` - ${INSTPATH[$index]}${NC}"
                        else
                                echo -e "`date -u  +'%F %T %:z'` - ${INSTPATH[$index]}"
                        fi

                        wp cron event run --due-now --path=${INSTPATH[$index]}
                fi
        done
        echo
        echo "**************** wp-cron complete  **************"
}

usage(){
        echo "Usage: wp-cron.sh [options...]"
        echo "Options:"
        echo " -r, --runall           Run all pending WordPress cron tasks on all WordPress installations"
        echo "                        that have the WordPress Cron system disabled"
        echo " -i, --interactive      Run in interactive mode with menu"
        echo " -h, --help             Display help contents"
        echo ""
        echo "The program will scan locate all WordPress installations recursively within the current directory."
        echo ""
        echo "Interactive Mode displays an interactive menu to list all discovered WordPress installations, enable/disable"
        echo "the WordPress Cron system for all installations, or toggle the WordPress Cron system on an individual"
        echo "installation.  It also provides an option to run all pending WordPress Cron jobs on all sites that have been"
        echo "setup for manual proccessing."
        echo ""
}

declare -a INSTPATH
i=0

while [ "$1" != "" ]; do
    case $1 in
        -r | --runall )         init
                                wp-cron
                                exit
                                ;;
        -i | --interactive )    init
                                interactive=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ "$interactive" = "1" ]; then
while true; do
                printmenu

                read menuid
                echo ""

                case $menuid in
                1)
                        setall "true"
                        ;;
                2)
                        setall "false"
                        ;;
                3)
                        printlist
                        ;;
                4)
                        let installid=-1
                        let invalid=0

                        while [ "$installid" -lt "0" ] || [ "$installid" -gt "$i" ]; do
                                if [ "$invalid" -eq "1" ]
                                then
                                        echo "Invalid choice"
                                fi
                                echo -n "What WordPress Installation would you like to toggle?  Enter the number from the list (0 to cancel):"

                                read  installid
                                let invalid=1
                        done
                        echo ""
                        toggle $installid
                        ;;
                5)
                        wp-cron
                        ;;
                6)
                        exit
                        ;;
                *)
                        echo "Invalid choice"
                        ;;
                esac
        done
else
        usage
fi



