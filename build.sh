#!/bin/bash

set -e

#filename=headquarters-$(git describe --abbrev=0 --tags).pk3
filename=headquarters.pk3

rm -f $filename
zip -R $filename "*.md" "*.txt" "*.zs"
gzdoom "$@" -file $filename
