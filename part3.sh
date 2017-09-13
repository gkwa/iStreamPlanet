#!/usr/bin/env bash

set -e

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

	get_id $playlist_url
	
	local json='UNEXPECTED'
	read -r -d '' json <<__eof__
    {
      "id": "$id",
      "playlists": [
        {
          "playlist_url": "$playlist_url"
        }
      ]
    }
__eof__
	echo $json
}

function sort_by_distributor()
{
	playlist_url="$1"

	get_id $playlist_url	
	get_distributor $playlist_url

 	mkdir -p $TMPDIR
 	echo $id $playlist_url >>$TMPDIR/$distributor
}

function cleanup()
{
	rm -rf $TMPDIR
}

function json_from_distributor_file()
{
	# New json for each distributor
	for distributor in $(ls $TMPDIR)
	do
		# build list so we can join with ','
		playlist=() 
		while read -r id url
		do
			playlist+=( "$(json_from_url $url)" )
		done < $TMPDIR/$distributor

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
	done
}

function main()
{
	# filter only for urls
	cat "${1:-/dev/stdin}" | grep -iE 'https?' |
		while read url
		do
			sort_by_distributor $url
		done

	json_from_distributor_file
}

main