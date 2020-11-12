#!/bin/bash 

#	File to easily download content and manage local copies of the mycourses.ntua.gr CMS.
#
#	Copyright (C) 2020  Tryfonas Themas
# 
#	Author: Tryfonas Themas <tryfonthem@gmail.com>
#
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program.  If not, see <https://www.gnu.org/licenses/>.


POSITIONAL=()
while [[ $# -gt 0 ]]
do
	key="$1"

	case $key in
		-c|--course)
COURSE="$2"
    shift # past argument
    shift # past value
    ;;
    -l|--location)
LOCATION="$2"
    shift # past argument
    shift # past value
    ;;
    -f|--file)
FILE="$2"
    shift # past argument
    shift # past value
    ;;
    -w|--workdir)
WORKDIR="$2"
    shift # past argument
    shift # past value
    ;;
    -t|--tabs)
TABS="$2"
    shift # past argument
    shift # past value
    ;;
    -a|--all)
ALL=true
    shift # past argument
    ;;
    -p|--password)
password="$2"
    shift # past argument
    shift # past value
    ;;
    -u|--username)
login="$2"
    shift # past argument
    shift # past value
    ;;
	-ow|--overwrite)
OVERWRITE=true
    shift # past argument
    ;;
    -u|--update)
UPDATE=true
    shift # past argument
    ;;
    -h|--help)
echo "MANUAL"
exit 0
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ $ALL ];
then
	start=`date +%s`
	echo -e '\n----------OPTION TO DOWNLOAD ALL OF MYCOURSES REGISTERED COURSES---------\n'

	if [ -z "$login" ];then
		echo "Enter Login:"
		read login
	fi
	if [ -z "$password" ];then
		echo "Enter Password:"
		read -s password
	fi
	wget -q --save-cookies cookies.txt --keep-session-cookies --post-data "login=$login&password=$password"  https://mycourses.ntua.gr/index.php
	if ! { [ "$(cat index.php | grep 'login' )" == "" ]; };then 
		echo -e '\n'"Wrong Username or Password"
		rm cookies.txt index.php
		exit 1
	fi

	cat index.php |grep '<a href=".*" class="menu">' | sed -E 's/( +|\t|<a href\=.*courses\/)|(...class..menu..)//g' > data.dat
	ncourses=$( cat data.dat | wc -l)
	IFS=$'\n\r' read -d '' -r -a COURSE < data.dat

	rm index.php data.dat
	for((i=0; i<$ncourses ; i++)); do
		./"$BASH_SOURCE" -c "${COURSE[i]}" -u "$login" -p "$password" -ow; 
	done
	end=`date +%s`
	echo -e '\n\n---------TOTAL DOWNLOAD COMPLETE IN '"$((end-start))"'s---------\n'
	exit 0
fi

if [ -z "$FILE" ];
then
	if [ -z "$login" ];then
		echo "Enter Login:"
		read login
	fi
	if [ -z "$password" ];then
		echo "Enter Password:"
		read -s password
	fi

	echo -e '\nDOWNLOADING '"$RED$COURSE${NC}"
	echo -e "$RED$COURSE${NC}"
	wget -q --save-cookies cookies.txt --keep-session-cookies --post-data "login=$login&password=$password" --delete-after https://mycourses.ntua.gr/index.php

	wget -q --load-cookies cookies.txt --delete-after "http://mycourses.ntua.gr/course_description/index.php?cidReq=$COURSE"

	wget -q --load-cookies cookies.txt http://mycourses.ntua.gr/document/document.php
	
	if ! { [ "$(cat document.php | grep 'login' )" == "" ]; };then 
		echo -e '\n'"Wrong Username or Password"
		rm cookies.txt document.php
		exit 1
	fi
	
	TABS="";
	mkdir $COURSE
	WORKDIR=$(pwd)
	start=`date +%s`
else
	if [ $OVERWRITE ];then
		rm -r "$WORKDIR/$COURSE$LOCATION"
	fi
	mkdir "$WORKDIR/$COURSE$LOCATION"
	loc="$WORKDIR/$COURSE$LOCATION"
	cd $loc
	echo -e "$TABS${RED}$(echo $LOCATION | sed 's:.*/::')${NC}"
	wget -q --load-cookies "$WORKDIR/cookies.txt" -P "$WORKDIR/$COURSE/$LOCATION/" -O document.php "http://mycourses.ntua.gr$FILE"
fi
TABS="$TABS|   "
grep -no '<td align="left"><span style="float:left;width:20px">' document.php | awk -F: '{print $1}' > data.dat

matches=$( grep -no '<td align="left"><span style="float:left;width:20px">' document.php | wc -l)

IFS=$'\n' read -d '' -r -a lines < data.dat

for((i=0; i<$matches ; i++)); do sed "${lines[i]}q;d" document.php ; done > data.dat

grep -a goto data.dat > download.txt
grep -a cmd data.dat > folders.txt
grep -Po '(?<=href=")[^"]*' download.txt| uniq > data.dat
sed 's/\&amp;/\&/g' data.dat > download.txt
grep -Po '(?<=href=")[^"]*' folders.txt| uniq > data.dat
sed 's/\&amp;/\&/g' data.dat > folders.txt

ndowns=$( cat download.txt | wc -l)

IFS=$'\n' read -d '' -r -a downs < download.txt

cat download.txt |  sed "s@+@ @g;s@%@\\\\x@g" | xargs -0 printf "%b"> data.dat
iconv -f greek -t UTF-8 -o data.dat data.dat
sed -E 's/(\&cidReq\=MECH.*)|(goto..url..)//g' data.dat > correctname.txt

IFS=$'\n' read -d '' -r -a filename < correctname.txt

for((i=0; i<$ndowns ; i++));do
	echo -e "$TABS|---$(echo ${filename[i]} | sed 's:.*/::')"
	wget -q -O "$WORKDIR/$COURSE/${filename[i]}" "http://mycourses.ntua.gr/document/${downs[i]}" 
done

nfolders=$( cat folders.txt | wc -l);
IFS=$'\n' read -d '' -r -a redir < folders.txt

awk -F'file=' '{print $2}' folders.txt > data.dat
cat data.dat |  sed "s@+@ @g;s@%@\\\\x@g" | xargs -0 printf "%b"> correctname.txt

iconv -f greek -t UTF-8 -o correctname.txt correctname.txt 
IFS=$'\n' read -d '' -r -a locaten < correctname.txt

rm download.txt correctname.txt folders.txt data.dat document.php

for((i=0; i<$nfolders ; i++)); do
	cd $WORKDIR
	./"$BASH_SOURCE" -c "$COURSE" -l "${locaten[i]}" -f "${redir[i]}" -w "$WORKDIR" -t "$TABS"; 
done

if [ -z "$FILE" ]; then 
	rm  cookies.txt
	end=`date +%s`
	echo -e '\n\n ---DOWNLOAD COMPLETE IN '"$((end-start))"'s---\n'
fi