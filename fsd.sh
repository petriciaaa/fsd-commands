#!/bin/bash

# Wrapper script to handle subcommands

case "$1" in
  make-slice)
    make-slice
    ;;
  *)
    echo "Usage: fsd {make-slice}"
    exit 1
    ;;
esac