#!/bin/bash

dirs=`find . -type dir | grep -v "./.git"`
for dir in ${dirs};do
  if [ "$dir" != "." ];then
    files=`ls "$dir" | grep -E "\.md$" | grep -v "index.md"`
    if [ -z "$files" ];then
      continue;
    fi
    if [ -f "$dir"/index.md ];then
      trash "$dir"/index.md
    fi
    dirname=`basename $dir`
    echo "# $dirname" > "$dir"/index.md
    echo >> "$dir"/index.md
    for file in ${files};do
      filename=${file%*${file:(-3)}}
      echo "[$filename]($file)" >> "$dir"/index.md
      echo >> "$dir"/index.md
    done
  fi
done
