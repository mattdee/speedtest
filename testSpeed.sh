#!/bin/bash
set -e


unset WORKINGDIR
unset RUNTIME
unset BREW

export WORKINGDIR=$HOME/MyScripts/speedtest
export RUNTIME=$(date +%m_%d_%y_%H%M)
export BREW=$(which brew)
export SPDTESTV=2.1.4b1


# check for homebrew
checkBrew()
{
	if  [[ -x $BREW ]] 
	then
		echo "Brew found, proceeding..."
	else
		echo "Brew not installed! "
        installBrew
	fi
}

installBrew()
{
    echo "Install Brew from https://brew.sh?"
    echo "Please answer yes or no..."
    read yesBrew
    if [[ $yesBrew = yes ]]
    then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Not installing Brew."
        return 1 2>/dev/null
        exit 1
    fi
}

checkSpeedtest()
{
	export whatVersion=$(/usr/local/bin/speedtest --version | grep cli | awk '{print $2}')
	echo "Found version of speedtest-cli is: "$whatVersion
	echo "Required version of speedtest-cli is: "$SPDTESTV



	if [ "$whatVersion" == "$SPDTESTV" ]; then
    echo "Correct version of speedtest-cli installed."
else
    echo "Incorrect version of speedtest-cli found."
    echo "Install correct version?"
    read -e -p "Y or N? " yn
    if [[ "y" = "$yn" || "Y" = "$yn" ]]; then
    	brew install speedtest-cli
    else
    	echo "Need speedtest-cli version: "$SPDTESTV "to continue."
    	echo "Exiting..."
    	return 1 2>/dev/null
    	exit
    fi
fi

}

setUpDB()
{
	echo "Database maintenance..."
	touch $WORKINGDIR/results.db
	sqlite3 $WORKINGDIR/results.db < $WORKINGDIR/speedtest.sql
}


function runTests()
{
	echo "Testing internets speed, please be patient..."
	#nohup /usr/local/bin/speedtest --csv >>$WORKINGDIR/results.$RUNTIME &>/dev/null &
	/usr/local/bin/speedtest --csv >>$WORKINGDIR/results.$RUNTIME &
	/usr/local/bin/speedtest
}

function getCurrentID()
{
	export CURRENT_ROWID=$(sqlite3 $WORKINGDIR/results.db<<EOF
		select max(rowid) from results;
EOF
	)
echo $CURRENT_ROWID
}

function getNewID()
{
	export LAST_ROWID=$(sqlite3 $WORKINGDIR/results.db<<EOF
		select max(rowid) from results;
EOF
)
echo $LAST_ROWID
}

function loadResults()
{
sqlite3 $WORKINGDIR/results.db<<EOF
.mode csv
.import $WORKINGDIR/results.$RUNTIME results
.quit
EOF
}

function fileCheck()
{
	if [[ -s $WORKINGDIR/results.$RUNTIME ]]
	then
			cat $WORKINGDIR/results.$RUNTIME
	        echo "File contains data..."
	        echo "Loading results..."
	        loadResults
	else
	        cat $WORKINGDIR/results.$RUNTIME
	        echo "File is empty..."
	        echo "Waiting 10 seconds"
	        sleep 10
	        fileCheck
	fi
}


function loadResults()
{
sqlite3 $WORKINGDIR/results.db<<EOF
.mode csv
.import $WORKINGDIR/results.$RUNTIME results
.quit
EOF
}

function cleanUp()
{
	# clean up current file
	rm $WORKINGDIR/results.$RUNTIME
}


function runIt()
{
	runTests
	getCurrentID
	fileCheck
	#loadResults this is called from fileCheck
	getNewID
	cleanUp
}


# Run it
checkBrew
checkSpeedtest
setUpDB
runIt




