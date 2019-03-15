#!/usr/bin/env bash

# Define a set of global variables:
VERSION=1.0.0
if [ -z ${BASE_URL:-} ]; then
  export BASE_URL=https://raw.githubusercontent.com/haximilian/homemaker/master
fi

# Set some sanity checks:
set -o errexit -o pipefail -o noclobber -o nounset

# Define a method to print out the version information and exit:
function print_version {
  echo "$(basename $0) $VERSION"
  exit
}

# Define a method to print out the help dialogue and exit:
function print_help {
  echo "$(basename $0) $VERSION"
  echo "Usage: $(basename $0) [options]"
  MSG="    -d,--debug:/Prints out debug information as the application executes. Cannot be used with \"-q\".
    -f,--force:/When specified, this will cause the application to automatically overwrite any conflicting files.
    -h,--help:/Print this help message and exit.
    -q,--quiet:/Runs the script without prompting the user or printing any non-error messages. Cannot be used with \"-d\".
    -v,--version:/Print out the version information and exit.
    -x,--fail:/Terminates the application whenever an error is encountered.
    -a,--apps [apps|\"n\"|\"y\"]:/Conrtols the initialization of all user applications by providing a \"y\" (initializes all applications), a \"n\" (initializes no applications),  of a comma-seperated list of all applications to install.
    -w,--work [dirs|\"y\"|\"n\"]:/Controls the initialization of the work directories (personal, professional, school, &c) by providing a \"y\" (makes room for them), a \"n\" (does nothing), or a comma-seperated list of directories to initialize.
    -l,--life [dirs|\"y\"|\"n\"]:/Controls the initialization of the life directories (Documents, Downloads, Desktop, &c) by either providing a \"y\" (initializes all of them), a \"n\" (does nothing), or a comma-seperated list of directories to initialize.
    -b,--local-bin [\"y\"|\"n\"]:/Controls the initialization of the local \"bin\" directory by providing a \"y\" or a \"n\" for \"yes\" or \"no\".
    -m,--mount [\"y\"|\"n\"]:/Controls the initialization of the local \"mnt\" directory by providing a \"y\" or a \"n\" for \"yes\" or \"no\".
"

  # Print the message:
  if [ -n "$(type tput 2> /dev/null)" ]; then
    echo "$MSG" | column -t -s "/" -c $(tput cols) -W 2
  else
    echo "$MSG" | column -t -s "/"
  fi
  exit
}


# Check for proper getopt:
! getopt --test > /dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo '>> ERROR homemaker requires enhanced `getopt` to be installed to continue' >&2
    exit 1
fi

# Parse the CLI options, & exit if the parser failed:
OPTIONS=hvdfqxa:w:l:b:m:
LONGOPTS=help,version,debug,force,quiet,fail,apps:,work:,life:,local-bin:,mount:
! OPTS=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$(basename $0)" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    exit 1
fi

# Set the defaults:
DEBUG=n
FORCE=n
QUIET=n
FAIL=n
APPS=p
LIFE=p
WORK=p
LOCAL_BIN=p
MNT=p

# Evaluate the arguments:
eval set -- "$OPTS"
while true; do
  case $1 in
    -h|--help)
      # Print the help dialogue:
      print_help
      ;;

    -v|--version)
      # Print the version information:
      print_version
      ;;

    -d|--debug)
      # Set the debug flag:
      DEBUG=y
      ;;

    -f|--force)
      # Set the force flag:
      FORCE=y
      ;;

    -q|--quiet)
      # Set the quiet flag:
      QUIET=y
      ;;

	  -x|--fail)
		  # Set the fail flag:
		  FAIL=y
		  ;;

    -a|--apps)
      # Set the apps flag:
      shift
      APPS=$1
      ;;

    -w|--work)
      # Set the work flag:
      shift
      WORK=$1
      ;;

    -l|--life)
      # Set the life flag:
      shift
      LIFE=$1
      ;;

    -b|--local-bin)
      # Set the local-bin flag:
      shift
      LOCAL_BIN=$1
      ;;

    -m|--mnt)
      # Set the local-bin flag:
      shift
      MNT=$1
      ;;

    -e|--everything)
      # Set all creation flags:
      shift
      if [ "$1" == "y" ]; then
        WORK=y
        LIFE=y
        LOCAL_BIN=y
      fi
      ;;

    --)
      # Exit the loop:
      break
      ;;
  esac
  shift
done

# Check the validity of the arguments:
if [ $DEBUG == "y" ] && [ $QUIET == "y" ]; then
  echo ">> ERROR arguments \"--debug\" and \"--quiet\" are mutually exclusive" >&2
  exit 1
fi


# Define a function to display error messages:
if [ "$FAIL" == "y" ]; then
  function print_error {
    echo ">> ERROR: $1" >&2
    exit 1
  }
else
  function print_error {
    echo ">> ERROR: $1" >&2
  }
fi

# Define a method to display debug messages:
if [ "$DEBUG" == "y" ]; then
  function print_debug {
    echo ">> DEBUG: $1"
  }
else
  function print_debug { :; }
fi

# Define a wrapper method for download files from the repo:
if [ -n "$(type curl 2> /dev/null)" ]; then
  print_debug "\"curl\" detected."
  function dl {
    local url=${2:-}
    if [ -z "$url" ]; then url=$BASE_URL; fi
    print_debug "Downloading \"$url/$1\""
    local RES=$(curl --write-out %{http_code} --silent --fail --out $1 $url/$1)
    if [ "$RES" != "200" ]; then
      print_error "could not download file \"$1\"; error code \"$RES\""
    fi
  }
elif [ -n "$(type wget 2> /dev/null)" ]; then
  print_debug "\"wget\" detected."
  function dl {
    local url=${2:-}
    if [ -z "$url" ]; then url=$BASE_URL; fi
    print_debug "Downloading \"$url/$1\""
    pushd . > /dev/null
    cd $(dirname $1)
    wget -q $url/$1 2> /dev/null
    if [ $? != 0 ]; then
      print_error "could not download file \"$url/$1\""
    fi
    popd > /dev/null
  }
else
  echo ">> ERROR: Either \"wget\" or \"curl\" must be installed and accessible to continue" >&2
  exit 1
fi

# Define a method to allow scripts to prompt the user for yes/no answers:
function prompt_yn {
  read -p "$1 [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy$] ]]; then
    REPLY=y
  else
    REPLY=n
  fi
}


# Run all init hooks:
if [ -d .homemaker.d ]; then
  for f in .homemaker.d/*; do
    source $f
  done

  # Cleanup:
  rm -r .homemaker.d
fi

# Cleanup (includes deleting this script):
print_debug "Cleaning up ..."
if [ -f homemaker.tar.gz ]; then rm homemaker.tar.gz; fi
rm -- "$0"

# vim: set ts=4 sw=4 tw=0 noet :
