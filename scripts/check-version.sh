#!/bin/bash

# ## 引数を受け取る
VERSON=$1

RESPONSE=$(curl -s "https://www.php.net/releases/index.php?json&version={$VERSON}" | jq ".version")

## バージョンが存在しない場合
if [ "$RESPONSE" = "null" ]; then
  echo "バージョンが存在しません"
  exit 1
else
    echo "バージョンが存在します"
    exit 0
fi
