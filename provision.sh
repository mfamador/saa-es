#!/bin/sh
set -e

# Start up Elasticsearch
/usr/local/bin/docker-entrypoint.sh eswrapper &

set +e

# Delete all 'junk' indices
curl -XDELETE localhost:9200/_all

# Add index settings
while true; do
	curl -fsSL -XPUT -H "Content-Type: application/json" --data-binary @/tmp/mappings.json http://localhost:9200/documents
	if [ $? == 0 ]; then
		break
	fi
	sleep 1
done

# Import our data
while true; do
	curl -fsSL -XPOST -H "Content-Type: application/json" --data-binary @/tmp/data.json http://localhost:9200/documents/document/_bulk
	if [ $? == 0 ]; then
		break
	fi
	sleep 10
done
set -e

# Shut down Elasticsearch so it's data files are in a clean state
kill $(ps -ef | grep java | grep -v grep | awk '{print $2}')

# Wait on all child processes to exit (i.e. Elasticseach)
wait
