#!/bin/bash

WORK=$(cd $(dirname $0) && pwd)

PAGE_LIST=$WORK/all-pages.list
SWAP=$WORK/swap

TEMPLATE=$WORK/template.html
BASE_HREF=$(echo $BASE_HREF | sed -E "s/\//\\\\\//g")
TEMPLATE_HOMEPAGE=$(echo $TEMPLATE_HOMEPAGE | sed -E "s/\//\\\\\//g")

function main() {
	cat $PAGE_LIST | while read LINE
	do
		NAME=$(echo $LINE | cut -d' ' -f2-)
		fix $NAME
		make $NAME
	done
	index
}

function fix() {
	NAME=${@:1:($#)}
	NAME_REGEX=$(echo $"$NAME" | sed -E "s/\//\\\\\//g")

	cat "$(htmlpath $NAME)" |
	sed -E "s/img src=\"[^\"]*index\.php\?plugin=ref\&amp;page=([^\"\&]*)\&amp;src=([^\"]*)\"/img src=\"page\/\1.html__\2\"/g" |
	sed -E "s/ href=\"[^\"]*index\.php\?plugin=attach\&amp;refer=([^\"\&]*)\&amp;openfile=([^\"]*)\"/ href=\"page\/\1.html__\2\"/g" |
	sed -E "s/ href=\"[^\"]*index\.php\?([^\"#]*)([^\"]*)\"/ href=\"page\/\1.html\2\"/g" |
	sed -E "s/ href=\"#(top_[0-9]*)\"/ href=\"page\/$NAME_REGEX.html#\1\"/g" |
	sed -E "s/ href=\"#(head_[0-9]*)\"/ href=\"page\/$NAME_REGEX.html#\1\"/g" |
	sed -E "s/ href=\"#(navigator)\"/ href=\"page\/$NAME_REGEX.html#\1\"/g" > $SWAP
	cat $SWAP > "$(htmlpath $NAME)"
}

function make() {
	NAME=${@:1:($#)}
	NAME_REGEX=$(echo $"$NAME" | sed -E "s/\//\\\\\&#047;/g")

	TIMESTAMP=$(date "+%Y-%m-%dT%H:%M:%S")

	echo "<!DOCTYPE html>" > $SWAP
	echo "<html>" >> $SWAP

	cat $TEMPLATE |
	xmllint --xpath '//head' --html - |
	sed -E "s/%7Bbase%7D/$BASE_HREF/g" |
	sed -E "s/%7Bhomepage%7D/$TEMPLATE_HOMEPAGE/g" |
	sed -E "s/\{title\}/$TEMPLATE_TITLE/g" |
	sed -E "s/\{description\}/$TEMPLATE_DESCRIPTION/g" |
	sed -E "s/\{author\}/$TEMPLATE_AUTHOR/g" |
	sed -E "s/\{timestamp\}/$TIMESTAMP/g" |
	sed -E "s/\{name\}/$NAME_REGEX/g" >> $SWAP

	echo "<body>" >> $SWAP

	cat $TEMPLATE |
	xmllint --xpath '//*[@id="header"]' --html - |
	sed -E "s/%7Bhomepage%7D/$TEMPLATE_HOMEPAGE/g" |
	sed -E "s/\{title\}/$TEMPLATE_TITLE/g" |
	sed -E "s/\{description\}/$TEMPLATE_DESCRIPTION/g" |
	sed -E "s/\{author\}/$TEMPLATE_AUTHOR/g" |
	sed -E "s/\{timestamp\}/$TIMESTAMP/g" |
	sed -E "s/\{name\}/$NAME_REGEX/g" >> $SWAP

	cat "$(htmlpath $NAME)" >> $SWAP

	cat $TEMPLATE |
	xmllint --xpath '//*[@id="footer"]' --html - |
	sed -E "s/%7Bhomepage%7D/$TEMPLATE_HOMEPAGE/g" |
	sed -E "s/\{title\}/$TEMPLATE_TITLE/g" |
	sed -E "s/\{description\}/$TEMPLATE_DESCRIPTION/g" |
	sed -E "s/\{author\}/$TEMPLATE_AUTHOR/g" |
	sed -E "s/\{timestamp\}/$TIMESTAMP/g" |
	sed -E "s/\{name\}/$NAME_REGEX/g" >> $SWAP

	echo "</body>" >> $SWAP
	echo "</html>" >> $SWAP

	cat $SWAP > "$(htmlpath $NAME)"
	echo "make page: $NAME"
}

function index() {
	mv $WORK/page/index.html $WORK/index.html
	cat $WORK/index.html |
	grep -v "class=\"return\"" |
	sed -E "s/page\/index\.html/index.html/g" > $SWAP
	cat $SWAP > $WORK/index.html
}

function htmlpath {
	NAME=${@:1:($#)}
	echo "$WORK/page/$NAME.html"
}

main
