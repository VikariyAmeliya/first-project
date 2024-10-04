#!/bin/bash

function zzgrep {
  mkdir -p temp 
  tar -xzf "$1" -C temp
  grep -R "$2" temp 
  rm -r temp 
}

zzgrep "$@"
