#!/usr/bin/env python

import sys
import re
import json
from urlparse import urlparse

def print_err(*args):
    sys.stderr.write(' '.join(map(str,args)) + '\n')

urls = []
for l in sys.stdin.readlines():
    l = l.strip().strip('"')
    u = urlparse(l)
    if u.scheme == '':
        print_err("skipping input [%s].  Can't find url in this input"%l)
    else:
        urls.append(u)

distributors = dict()
for url in urls:
    dist = re.search("-streams-prod.([^\.]+)\.", url.netloc).group(1)
    id = re.search("/F(\d+)/", url.path)
    d = { 'id': id.group(1), 'playlists': [ { 'playlist_url': url.geturl() } ] }

    if not dist in distributors:
        distributors[dist] = []
    distributors[dist].append(d)

for dist in distributors:
    d = {
        'distributor': dist,
        'channels': distributors[dist]
    }
    j = json.dumps(d,indent=2, sort_keys=False)
    print j
    with open("%s.json"%dist, 'w') as f:
        f.write(j)
