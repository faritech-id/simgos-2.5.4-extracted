#!/bin/sh

if [ $# -lt 1 ]; then
	echo "Usage: $0 last_version"
	echo "Example: bash patch.sh 2.0-190929"
	exit 1
fi

version="$1"

if [ -f /var/log/simrsgos-latest.txt ]; then
	yes | mv /var/log/simrsgos-latest.txt /var/log/simgos-latest.txt
fi

if [ -f /var/log/simrsgos-test.txt ]; then
	yes | mv /var/log/simrsgos-test.txt /var/log/simgos-test.txt
fi

if [ "$version" == "" ]; then
	if [ -f /var/log/simgos-latest.txt ]; then
		version=`cat /var/log/simgos-latest.txt`
	fi
fi

if [ "$version" == "test" ]; then
	if [ -f /var/log/simgos-test.txt ]; then
		version=`cat /var/log/simgos-test.txt`
	else
		version="";
	fi
fi

if [ "$version" == "" ]; then
	version="2.0-190929"
fi

echo "Latest Version: $version"

lastVersion=`echo $version | cut -d \- -f 1`
mayor=`echo $lastVersion | cut -d \. -f 1`
minor=`echo $lastVersion | cut -d \. -f 2`
patch=`echo $lastVersion | cut -d \. -f 3`
lastBuild=`echo $version | cut -d \- -f 2`
lengthBuild=${#lastBuild}

if [ "$patch" = "" ]; then
	if [ "$minor" != "" ]; then
		patch="0"
	fi
fi

if [ $lengthBuild = 6 ]; then
	lastBuild=$lastBuild"00"
fi

passn=`cat ../pass.new`

cat > /var/tmp/my.cnf <<-EOF
[client]
host=127.0.0.1
port=3306
user=root
password=$passn
EOF

isConnect=`mysql --defaults-extra-file=/var/tmp/my.cnf < test.sql`
status=`echo $isConnect | grep 'STATUS' | sed 's/STATUS //g'` 

if [ "$status" != "OK" ]; then
	exit 0
fi

versionLatest="$lastVersion"
buildLatest="$lastBuild"

fr="2.*"
sudo rm -rf $fr

mayors=`ls -vd *`
for may in $mayors
do
	if [ -f $may ]; then
		continue
	fi
	if [ $may -ge $mayor ]; then
		cd $may
		minors=`ls -vd *`
		for min in $minors
		do
			if [ -f $min ]; then
				continue
			fi
			if [ $min -ge $minor ]; then
				cd $min
				patchs=`ls -vd *`
				for p in $patchs
				do
					if [ -f $p ]; then
						continue
					fi
					if [ $p -ge $patch ] || [ $p == 0 ]; then
						versionLatest="$may.$min.$p"
						echo "========================================"
						echo "Version: $versionLatest"
						echo "========================================" 
						cd $p
						builds=`ls -vd *`
						for b in $builds
						do
							if [ -f $b ]; then
								continue
							fi
							if [ $b -gt $lastBuild ]; then
								buildLatest="$b"
								echo "## Build: $b"
								cd $b
								sqls=`ls`
								for sql in $sqls
								do
									echo "--------> SQL: $sql"
									mysql --defaults-extra-file=/var/tmp/my.cnf < $sql
								done
								cd ..
							fi
						done
						echo ""
						cd ..
					fi
				done
				cd ..
			fi
		done
		cd ..
	fi
done

cat > /var/log/simgos-test.txt <<-EOF
$versionLatest-$buildLatest
EOF

rm -Rf /var/tmp/my.cnf
