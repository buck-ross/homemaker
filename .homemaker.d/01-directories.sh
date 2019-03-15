#!/usr/bin/env bash

print_debug "Creating local directory structure ..."

# Define a function to create the life directories:
function create_life_dirs {
  if [ "$LIFE" == "p" ]; then LIFE=y; fi

  # Create all specified directories:
  if [ "$LIFE" == "y" ]; then
    print_debug "Creating default life directories"
    mkdir -p Documents Downloads Desktop Pictures Music
  else
    (IFS=','; for dir in $LIFE; do
      print_debug "Creating life directory \"$dir\""
      mkdir -p $dir
    done)
  fi
}

# Define a function to create all workspaces:
function create_workspace_dirs {
  print_debug "Creating working directories ..."
  if [ "$WORK" == "p" ]; then WORK=y; fi
  mkdir -p workspace bin

  # Create all specified directories:
  if [ "$WORK" == "y" ] && [ "$QUIET" == "n" ]; then
    print_debug "Prompting for workspaces ..."
    WORK=""
    while true; do
      read -p "Add a new workspace ([ENTER] to exit): " LINE
      if [ "$LINE" == "" ]; then break; fi
      mkdir -p "workspace/$LINE"
      if [ -z "$WORK" ]; then
        WORK="$LINE"
      else
        WORK="$WORK $LINE"
      fi
      print_debug "New workspace list: \"$WORK\""
    done
    if [ -z "$WORK" ]; then WORK=n; fi
    unset LINE
  elif [ "$WORK" != "y" ]; then
    (IFS=','; for dir in $WORK; do
      print_debug "Creating workspace directory \"$dir\" ..."
      mkdir -p "workspace/$dir"
    done)
  else
    print_debug "Skipping workspace directories ..."
  fi
}

# Define a function to create all local bin directories:
function create_lbin_dirs {
  print_debug "Creating local \"bin\" directory ..."
  if [ "$LOCAL_BIN" == "p" ]; then LOCAL_BIN=y; fi
  mkdir -p .local/bin
}

# Define a function to create all local mnt directories:
function create_lmnt_dirs {
  print_debug "Creating local \"mnt\" directory ..."
  if [ "$MNT" == "p" ]; then MNT=y; fi
  mkdir -p mnt
}


# Create the basic life directories:
if [ "$LIFE" == "n" ]; then
  print_debug "Skipping life directories ..."
elif [ "$LIFE" == "p" ] && [ "$QUIET" == "n" ]; then
  prompt_yn "Create Documents directories?"
  if [ "$REPLY" == "y" ]; then
    create_life_dirs
  else
    print_debug "Skipping life directories ..."
    LIFE=n
  fi
else
  create_life_dirs
fi

# Create the work directories:
if [ "$WORK" == "n" ]; then
  print_debug "Skipping working directories ..."
elif [ "$WORK" == "p" ] && [ "$QUIET" == "n" ]; then
  prompt_yn "Create work directories?"
  if [ "$REPLY" == "y" ]; then
    create_workspace_dirs
  else
    print_debug "Skipping working directories ..."
    WORK=n
  fi
else
  create_workspace_dirs
fi

# Create the local bin directory:
if [ "$LOCAL_BIN" == "n" ]; then
  print_debug "Skipping local bin ..."
elif [ "$LOCAL_BIN" == "p" ] && [ "$QUIET" == "n" ]; then
  prompt_yn "Create local \"bin\" directory?"
  if [ "$REPLY" = "y" ]; then
    create_lbin_dirs
  else
    print_debug "Skipping local bin ..."
    LOCAL_BIN=n
  fi
else
  create_lbin_dirs
fi

# Create the local mount directory:
if [ "$MNT" == "n" ]; then
  print_debug "Skipping local mnt ..."
elif [ "$MNT" == "p" ] && [ "$QUIET" == "n" ]; then
  prompt_yn "Create local \"mnt\" directory?"
  if [ "$REPLY" = "y" ]; then
    create_lmnt_dirs
  else
    print_debug "Skipping local mnt ..."
    MNT=n
  fi
else
  create_lmnt_dirs
fi

# Unset all used functions:
unset -f create_life_dirs
unset -f create_workspace_dirs
unset -f create_lbin_dirs

# vim: set ts=4 sw=4 tw=0 noet :
