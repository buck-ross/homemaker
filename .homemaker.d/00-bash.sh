#!/usr/bin/env bash

print_debug "Configuring BASH Environment ..."

# Download .bashrc, .bash_aliases, and .bash_methods, one by one:
arr=(".bashrc" ".bash_aliases" ".bash_methods")
for i in "${arr[@]}"; do
  if [ -e $i ] && [ "$FORCE" == "n" ]; then
    if [ "$QUIET" == "n" ]; then
      prompt_yn "Found existing \"$i\" file. Overwrite it?"
      if [ "$REPLY" == "y" ]; then
        dl $i
      fi
    else
      print_error "Conflicting file \"$i\" found in filesystem"
    fi
  else
    dl $i
  fi
done

# Unset all defined functions and variables:
unset arr

# vim: set ts=4 sw=4 tw=0 noet :
