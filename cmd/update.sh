#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)

cd $SCRIPT_DIR

# download https://github.com/amzxyz/rime_wanxiang/releases/download/LTS/wanxiang-lts-zh-hans.gram and save to ../
curl -L -o $SCRIPT_DIR/../wanxiang-lts-zh-hans.gram https://github.com/amzxyz/rime_wanxiang/releases/download/LTS/wanxiang-lts-zh-hans.gram

git fetch upstream
git rebase upstream/main
