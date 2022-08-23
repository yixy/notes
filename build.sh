#!/bin/bash

dirs=`find . -type dir | grep -v "./.git"`
for dir in ${dirs};do
  if [ "$dir" != "." ];then
    files=`ls "$dir" | grep -E "\.md$" | grep -E -v "^index.md$" |grep -E -v "^mind.md$"`
    if [ -z "$files" ];then
      continue;
    fi
    if [ -f "$dir"/index.md ];then
      trash "$dir"/index.md
    fi
    dirname=`basename $dir`
    echo -e "# $dirname\n" > "$dir"/index.md
    if [ -f "$dir"/mind.md ];then
      cat "$dir"/mind.md >> "$dir"/index.md
    fi
    for file in ${files};do
      filename=${file%*${file:(-3)}}
      echo -e "[$filename]($file)\n" >> "$dir"/index.md
    done
  fi
done
