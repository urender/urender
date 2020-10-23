#!/bin/sh

./merge-schema.py schema schema urender.yml urender.schema.json 1 1
./merge-schema.py schema schema urender.yml urender.schema.pretty.json 0 1
./merge-schema.py schema schema urender.yml urender.schema.full.json 0 0

rm -rf generated/
mkdir generated/
./generate-reader.uc

mkdir -p docs
generate-schema-doc --config expand_buttons=true urender.schema.pretty.json docs/urender-schema.html

