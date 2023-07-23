#!/bin/bash

dirs=`find . -type d | grep -v "./.git"`
for dir in ${dirs};do
  if [ "$dir" != "." ];then
    files=`ls "$dir" | grep -E "\.md$" | grep -E -v "^index.md$" |grep -E -v "^attach.md$"`
    if [ -z "$files" ];then
      continue;
    fi
    if [ -f "$dir"/index.md ];then
      trash "$dir"/index.md
    fi
    dirname=`basename $dir`
    echo -e "# $dirname\n" > "$dir"/index.md
    if [ -f "$dir"/attach.md ];then
      cat "$dir"/attach.md >> "$dir"/index.md
    fi
    for file in ${files};do
      filename=${file%*${file:(-3)}}
      echo -e "[$filename]($file)\n" >> "$dir"/index.md
    done
  fi
done
