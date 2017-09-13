#!/usr/bin/env bash

jsonfile="$1"

cat $jsonfile | jq .channels[].id
cat $jsonfile | jq .channels[].playlists[].playlist_url
