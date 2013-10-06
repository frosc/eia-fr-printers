#!/bin/bash

credentials="${HOME}/Secret/hefr_credentials"
server="hefrprint"

config_credentials() {
    username=$(grep 'username=' ${credentials} | awk -F= '{print $2}')
    password=$(grep 'password=' ${credentials} | awk -F= '{print $2}')
    domain=$(grep 'domain=' ${credentials} | awk -F= '{print $2}')
}

get_ppd() {
    filter=$1
    lpinfo -m | grep "$filter" | head -n 1 | awk '{print $1}'
}

get_konica_list() {
    smbclient -A ${credentials} -L ${server} 2>/dev/null | \
        egrep -i 'MF_.*PS.*Bizhub' | \
        egrep -v "MF_(HEG|FON|Beauregard)" | \
        awk '{print $1}'
}

get_dj_list() {
    smbclient -A ${credentials} -L ${server} 2>/dev/null | \
        egrep -i "designjet4000.*_PS" | \
        egrep -v 'FON_' | \
        awk '{print $1}'
}

add_printer() {
    queue=$1
    model=$2
    location=$3
    destination="HEFR_${queue}"
    echo "Adding $queue"
    sudo lpadmin -p "${destination}" \
        -v smb://${domain}%5C${username}:${password}@${server}/${queue} \
        -m ${model} -L "HEFR ${location}" -E 
    sudo lpadmin -p "${destination}" -o pdftops-renderer-default=pdftops
}

add_konica_printers() {
    konica_ppd=$(get_ppd 'KONICA MINOLTA C[56]52')
    for i in $(get_konica_list); do
        location=$(echo $i | sed 's/MF_//' | sed 's/_PS//')
        add_printer $i $konica_ppd $location
    done
}

add_dj_printers() {
    dj_ppd=$(get_ppd 'HP Designjet 4000ps Postscript')
    for i in $(get_dj_list); do
        location=`echo $i | sed 's/_DesignJet.*//'`
        add_printer $i $dj_ppd $location
    done
}

usage() {
    echo "Usage: $0 options..."
    echo
    echo "Options:"
    echo "    -l      : list available printers queues"
    echo "    -a      : add all printers"
    echo "    -c FILE : use FILE for credentials"
    echo
}

list() {
    echo "---------------"
    echo "Konica Printers"
    echo "---------------"
    get_konica_list
    echo
    echo "---------------"
    echo "HP DJ Printers"
    echo "--------------"
    get_dj_list
    echo
}

cmd=usage
while getopts ":alc:" opt; do
    case $opt in
        a)
            cmd=add
            ;;
        l)
            cmd=list
            ;;
        c)
            credentials=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

case $cmd in
    usage)
        usage
        ;;
    list)
        list
        ;;
    add)
        config_credentials
        add_konica_printers
        add_dj_printers
        ;;
esac;
        
# credential file:
# ----------------
# username=firstname.lastname
# password=YOUR_VERY_SECRET_PASSWORD
# domain=sofr

