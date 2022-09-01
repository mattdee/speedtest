#!/bin/bash


unset WORKINGDIR
unset RUNTIME

export WORKINGDIR=$HOME/MyScripts/speedtest
export RUNTIME=$(date +%m_%d_%y_%H%M)



function runTests()
{
	echo "Testing internets speed, please be patient..."
	#nohup /usr/local/bin/speedtest --csv >>$WORKINGDIR/results.$RUNTIME &>/dev/null &
	time /usr/local/bin/speedtest --csv >>$WORKINGDIR/results.$RUNTIME
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
runIt




