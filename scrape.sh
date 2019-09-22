#!/bin/bash

WORK=$(cd $(dirname $0) && pwd)

PAGE_LIST=$WORK/all-pages.list
IMAGE_LIST=$WORK/all-images.list

function main() {
	list_pages

	cat $PAGE_LIST | while read LINE
	do
		URI=$(echo $LINE | cut -d' ' -f1 )
		NAME=$(echo $LINE | cut -d' ' -f2-)
		page $URI $NAME
	done

	cat $IMAGE_LIST | while read LINE
	do
		URI=$(echo $LINE | cut -d' ' -f1 )
		NAME=$(echo $LINE | cut -d' ' -f2-)
		image $URI $NAME
	done
}

function list_pages() {
	LIST_URI=$INDEX?cmd=list
	LIST_URI_REGEX=$(echo $LIST_URI | sed -E "s/\//\\\\\//g")

	curl --retry 3 -sL $LIST_URI | 
	grep -e "<li><a href" |
	grep -e "$INDEX" |
	sed -E "s/^.*<a href=\"([^\"]*)\">([^<]*)<\/a>.*$/\1 \2/g" |
	sed -E "1s/^/$LIST_URI_REGEX index\n/" > $PAGE_LIST

	rm -rf $IMAGE_LIST
}

function page() {
	URI=$1
	NAME=${@:2:($#-1)}

	DIR=$(dirname "$(htmlpath $NAME)")
	mkdir -p "$DIR"
	
	curl --retry 3 -sL $URI |
	xmllint --xpath '//*[@id="body"]' --html - > "$(htmlpath $NAME)"
	echo "download page: $(htmlpath $NAME)"

	list_images "$NAME"
}

function list_images() {
	NAME=${@:1:($#)}

	cat "$(htmlpath $NAME)" |
	grep "<img src=" |
	sed -E "s/<img ([^>]*)>/\n<img \1>\n/g" |
	grep "<img src=" |
	sed -E "s/^<img src=\"([^\"]*)\".*$/\1/g" |
	sed -E "s/amp;//g" | while read URI
	do
		echo "$URI $NAME" >> $IMAGE_LIST
	done
}

function image() {
	URI=$1
	NAME=${@:2:($#-1)}

	SRC=$(echo $URI | sed -E "s/^.*src=(.*)$/\1/g")
	IMAGE=$(echo "$WORK/page/${NAME}.html__${SRC}" | nkf -w --url-input)

	curl --retry 3 -sL $URI > "$IMAGE"
	echo "download image: $IMAGE"
}

function htmlpath {
	NAME=${@:1:($#)}
	echo "$WORK/page/$NAME.html"
}

main
