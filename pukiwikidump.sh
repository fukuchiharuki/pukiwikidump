#!/bin/bash

export INDEX="http://localhost/wiki/index.php"

#export BASE_HREF="/static/pukiwikidump/"
export BASE_HREF="/"

export TEMPLATE_TITLE="ポケットがチケットでいっぱい（アーカイブ）"
export TEMPLATE_DESCRIPTION="Tipsや調べたことなど、自分のために残したもの。"
export TEMPLATE_AUTHOR="ふくちはるき"
export TEMPLATE_HOMEPAGE="https://fukuchiharuki.me/"

bash $(cd $(dirname $0) && pwd)/scrape.sh
bash $(cd $(dirname $0) && pwd)/setup.sh
