#!/usr/bin/env bash
set -e

function usage()
{
	echo usage examples:
	echo "$(basename $0)" {playlist url}
	echo "echo {playlist url} | $(basename $0)"
	echo "cat urls.txt | $(basename $0)"
}

TMPDIR=.$0
trap cleanup EXIT

function get_id()
{
	playlist_url="$1"

	id='UNEXPECTED'
	id=$(echo $playlist_url | sed 's,http.*/F\([0-9]*\)/.*,\1,')
}

function get_distributor()
{
	playlist_url="$1"

	distributor='UNEXPECTED'
	distributor=$(echo $playlist_url |
					  sed 's,.*gcs-streams-prod.\([^\.]*\).*,\1,')
}

function cleanup()
{
	rm -rf $TMPDIR
}

function json_from_url()
{
	playlist_url="$1"
	playlist_id="$2"

	local json='UNEXPECTED'
	read -r -d '' json <<__eof__
    {
      "id": "$playlist_id",
      "playlists": [
        {
          "playlist_url": "$playlist_url"
        }
      ]
    }
__eof__
	echo $json
}

function cleanup()
{
	rm -rf $TMPDIR
}

function json_from_distributor_file()
{
	dfile="$1"

	# build list so we can join with ','
	playlist=()
	while read -r id url
	do
		playlist+=( "$(json_from_url $url $id)" )
	done < $dfile

	channels=()
	SAVE_IFS="$IFS"
	IFS=","
	channels+=( "${playlist[*]}" )
	IFS="$SAVE_IFS"

	cat << __eof__ >$distributor.json.tmp
{
  "distributor": "$distributor",
  "channels": [ ${channels[*]} ]
}
__eof__
	cat $distributor.json.tmp | jq . >$distributor.json
	rm -f $distributor.json.tmp
	cat $distributor.json
}

function json_from_distributors()
{
	if test ! -d $TMPDIR
	then
		usage
		exit 1
	fi

	# new json file for each distributor
	for distributor in $(ls $TMPDIR)
	do
		json_from_distributor_file $TMPDIR/$distributor
	done
}

function sort_by_distributor()
{
	playlist_url="$1"

	id='UNEXPECTED'

	get_id $playlist_url
	get_distributor $playlist_url

	mkdir -p $TMPDIR
	echo $id $playlist_url >>$TMPDIR/$distributor
}

function main()
{
	# expect urls on stdin
	if [ -t 0 ]
	then
		usage
		exit 1
	fi

	# filter input for urls
	cat "${1:-/dev/stdin}" | grep -iE 'https?' |
		while read -r url
		do
			sort_by_distributor $url
		done
	
	json_from_distributors
}

main
