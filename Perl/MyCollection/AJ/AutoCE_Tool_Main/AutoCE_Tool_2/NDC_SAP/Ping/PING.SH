#!/system/bin/sh

ip=$1
round=$1
i=1

if [ "$ip" == "" ]; then
    echo "Usage: ./ping.sh [ip] time"
    exit 1
fi

name=$(date +%Y%m%d_%H%M)

while [ 1 ]
do
    echo "-----Round $i" >> ./"$name"_out.log
	ping -f -l 1400 "$ip"
    sleep 5
    i=$(($i+1))
    if [ "$i" == "$round" ]; then
        exit 0 
    fi
done
