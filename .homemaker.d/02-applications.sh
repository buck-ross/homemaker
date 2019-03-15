#!/usr/bin/env bash

# Handles the following apps: vim, git, python, nvm, todo, xterm, bash-palette

print_debug "Preloading user applications ..."

# Define a function to install vim configuration:
function install_vim {
  print_debug "Installing vim configuration ..."

  # Create directories:
  local DIRS=".vim/plugin"
  for dir in $DIRS; do
    print_debug "Creating directory \"$dir\" ..."
    mkdir -p $dir
  done

  # Download files:
  local FILES=".vimrc .vim/plugin/securemodelines.vim"
  for file in $FILES; do
    if [ "$FORCE" != "y" ] && [ -f $file ]; then
      if [ "$QUIET" == "n" ]; then
        prompt_yn "Found existing \"$file\" file. Overwrite it?"
        if [ "$REPLY" == "y" ]; then
          dl $file
        fi
      fi
    else
      dl $file
    fi
  done
}

# Define a function to install git configuration:
function install_git {
  print_debug "Installing git configuration ..."

  # Handle the "git tree" alias:
  if [ "$(git config --global alias.tree)" == "log --graph --all --decorate" ]; then
    print_debug "\"git tree\" alias already defined"
  elif [ "$FORCE" != "y" ] && [ -n "$(git config --global alias.tree)" ]; then
    if [ "$QUIET" == "n" ]; then
      prompt_yn "\"git tree\" alias has been defined. Overwrite it?"
      if [ "$REPLY" == "y" ]; then
        print_debug "Setting \"git tree\" alias"
        git config --global alias.tree "log --graph --all --decorate"
      else
        print_debug "Skipping \"git tree\" alias"
      fi
    else
      print_error "\"git tree\" alias already defined"
    fi
  else
    print_debug "Setting \"git tree\" alias"
    git config --global alias.tree "log --graph --all --decorate"
  fi

  # Define the global git username:
  if [ "$(git config --global user.name)" ]; then
    print_debug "Global git username already defined"
  elif [ "$QUIET" == "n" ]; then
    read -p "Enter a name to be used as the global git configuration: " NAME
    if [ -n "$NAME" ]; then
      print_debug "Setting global username: $NAME"
      git config --global user.name "$NAME"
      unset NAME
    else
      print_debug "Skipping global username ..."
    fi
  fi

  # Define the global git email:
  if [ "$(git config --global user.email)" ]; then
    print_debug "Global git email already defined"
  elif [ "$QUIET" == "n" ]; then
    read -p "Enter an email to be used as the global git configuration: " EMAIL
    if [ -n "$EMAIL" ]; then
      print_debug "Setting global email: $EMAIL"
      git config --global user.email "$EMAIL"
      unset EMAIL
    else
      print_debug "Skipping global email ..."
    fi
  fi

  # Define the uername and email addresses for each individual workspace:
  if [ "$WORK" == "n" ] || [ "$WORK" == "y" ]; then
    debug_print "Skipping git initialization of workspaces ..."
  else
    for dir in $WORK; do
      print_debug "Configure git for workspace \"$dir\""

      # Define the local configuration:
      read -p "Enter an username for the git configuration of \"~/workspace/$dir\" " NAME
      read -p "Enter an email for the git configuration of \"~/workspace/$dir\": " EMAIL
      git config -f "workspace/$dir/.gitconfig" user.name "$NAME"
      git config -f "workspace/$dir/.gitconfig" user.email "$EMAIL"
      unset NAME
      unset EMAIL

      # Add the global configuration:
      echo "[includeIf \"gitdir:~/workspace/$dir/\"]" >> .gitconfig
      echo "    path = ~/workspace/$dir/.gitconfig" >> .gitconfig
    done
  fi

  # Check for the "hub" command:
  if [ -n "$(type hub 2> /dev/null)" ] || [ "$LOCAL_BIN" != "y" ]; then
    print_debug "Skipping \"hub\" installation ..."
  else
    print_debug "Installing \"hub\" locally ..."
    dl hub-linux-amd64-2.10.0.tgz https://github.com/github/hub/releases/download/v2.10.0
    tar xzvf hub-linux-amd64-2.10.0.tgz
    mv hub-linux-amd64-2.10.0/bin/hub .local/bin/hub
    rm -rv hub-linux-amd64-2.10.0 hub-linux-amd64-2.10.0.tgz
  fi
}

# Define a function to install todo configuration:
function install_todo {
  print_debug "Installing todo configuration ..."

  # Create directories:
  local DIRS=".todo"
  for dir in $DIRS; do
    print_debug "Creating directory \"$dir\" ..."
    mkdir -p $dir
  done

  # Download main executable:
  if [ "$FORCE" != "y" ] && [ -f .local/bin/todo.sh ]; then
    if [ "$QUIET" == "n" ]; then
      prompt_yn "Found existing \".local/bin/todo.sh\" file. Overwrite it?"
      if [ "$REPLY" == "y" ]; then
        dl .local/bin/todo.sh
      fi
    fi
  else
    dl .local/bin/todo.sh
  fi

  # Download .todo files:
  local FILES="config todo.txt done.txt report.txt"
  pushd . > /dev/null
  cd .todo
  for file in $FILES; do
    if [ "$FORCE" != "y" ] && [ -f $file ]; then
      if [ "$QUIET" == "n" ]; then
        prompt_yn "Found existing \"$file\" file. Overwrite it?"
        if [ "$REPLY" == "y" ]; then
          dl $file
        fi
      fi
    else
      dl $file
    fi
  done
  popd > /dev/null
}

# Define a function to install nvm configuration:
function install_nvm {
  print_debug "Installing nvm configuration ..."

  # Create directories:
  local DIRS=".nvm"
  for dir in $DIRS; do
    print_debug "Creating directory \"$dir\" ..."
    mkdir -p $dir
  done

  # Download files:
  local FILES=".nvm/bash_completion .nvm/init-nvm.sh .nvm/install-nvm-exec .nvm/nvm.sh"
  for file in $FILES; do
    if [ "$FORCE" != "y" ] && [ -f $file ]; then
      if [ "$QUIET" == "n" ]; then
        prompt_yn "Found existing \"$file\" file. Overwrite it?"
        if [ "$REPLY" == "y" ]; then
          dl $file
        fi
      fi
    else
      dl $file
    fi
  done
}

# Define a function to install python3 configuration:
function install_python {
  print_debug "Installing python configuration ..."

  # Download files:
  mkdir python
  pushd . > /dev/null
  cd python
  dl Python-3.8.0a2.tgz https://www.python.org/ftp/python/3.8.0
  tar zxfv Python-3.8.0a2.tgz
  cd Python-3.8.0a2

  # Compile python:
  ./configure --prefix=$(cd ../.. && pwd)/.local
  make && make install
  popd > /dev/null
  rm -r python

  # Link the compiled files:
  ln -s .local/python3 .local/python
  ln -s .local/pip3 .local/pip
}

# Define a function to install xterm configuration:
function install_xterm {
  print_debug "Installing xterm configuration ..."

  # Download files:
  local FILES=".local/bin/xterm-colorized .local/bin/uxterm-colorized"
  for file in $FILES; do
    if [ "$FORCE" != "y" ] && [ -f $file ]; then
      if [ "$QUIET" == "n" ]; then
        prompt_yn "Found existing \"$file\" file. Overwrite it?"
        if [ "$REPLY" == "y" ]; then
          dl $file
        fi
      fi
    else
      dl $file
    fi
  done
}

# Define a function to install bash-palette:
function install_bash_palette {
  print_debug "Installing bash-palette configuration ..."

  # Download files:
  if [ "$FORCE" != "y" ] && [ -f bin/bash-palette ]; then
    if [ "$QUIET" == "n" ]; then
      prompt_yn "Found existing \"bin/bash-palette\" file. Overwrite it?"
      if [ "$REPLY" == "y" ]; then
        dl bin/bash-palette
      fi
    fi
  else
    dl bin/bash-palette
  fi
}


# Initialize vim:
if [ -n "$(type vim 2> /dev/null)" ]; then
  if [ "$APPS" == "y" ] || [ -n "$(echo "$APPS" | grep "vim")" ]; then
    install_vim
  elif [ "$APPS" == "p" ] && [ "$QUIET" == "n" ]; then
    prompt_yn "Install vim configuration?"
    if [ "$REPLY" == "y" ]; then
      install_vim
    else
      print_debug "Skipping vim configuration ..."
    fi
  else
    print_debug "Skipping vim configuration ..."
  fi
else
  print_debug "vim not found. Skipping ..."
fi

# Initialize git:
if [ -n "$(type git 2> /dev/null)" ]; then
  if [ "$APPS" == "y" ] || [ -n "$(echo "$APPS" | grep "git")" ]; then
    install_git
  elif [ "$APPS" == "p" ] && [ "$QUIET" == "n" ]; then
    prompt_yn "Install git configuration?"
    if [ "$REPLY" == "y" ]; then
      install_git
    else
      print_debug "Skipping git configuration ..."
    fi
  else
    print_debug "Skipping git configruation ..."
  fi
else
  print_debug "git not found. Skipping .."
fi

# Initialize todo:
if [ -z "$(type todo 2> /dev/null)" ] && [ "$LOCAL_BIN" != "n" ]; then
  if [ "$APPS" == "y" ] || [ -n "$(echo "$APPS" | grep "todo")" ]; then
    install_todo
  elif [ "$APPS" == "p" ] && [ "$QUIET" == "n" ]; then
    prompt_yn "Install todo configuration?"
    if [ "$REPLY" == "y" ]; then
      install_todo
    else
      print_debug "Skipping todo configuration ..."
    fi
  else
    print_debug "Skipping todo configruation ..."
  fi
else
  print_debug "todo found. Skipping ..."
fi

# Initialize nvm:
if [ -z "$(type nvm 2> /dev/null)" ]; then
  if [ "$APPS" == "y" ] || [ -n "$(echo "$APPS" | grep "nvm")" ]; then
    install_nvm
  elif [ "$APPS" == "p" ] && [ "$QUIET" == "n" ]; then
    prompt_yn "Install nvm configuration?"
    if [ "$REPLY" == "y" ]; then
      install_nvm
    else
      print_debug "Skipping nvm configuration ..."
    fi
  else
    print_debug "Skipping nvm configruation ..."
  fi
else
  print_debug "nvm found. Skipping ..."
fi

# Initialize python:
if [ -z "$(type python3 2> /dev/null)" ] && [ "$LOCAL_BIN" != "n" ]; then
  if [ "$APPS" == "y" ] || [ -n "$(echo "$APPS" | grep "nvm")" ]; then
    install_python
  elif [ "$APPS" == "p" ] && [ "$QUIET" == "n" ]; then
    prompt_yn "Install python3?"
    if [ "$REPLY" == "y" ]; then
      install_python
    else
      print_debug "Skipping python configuration ..."
    fi
  else
    print_debug "Skipping python configruation ..."
  fi
else
  print_debug "python3 found. Skipping ..."
fi

# Initialize xterm:
if [ -n "$(type xterm 2> /dev/null)" ] && [ "$LOCAL_BIN" != "n" ]; then
  if [ "$APPS" == "y" ] || [ -n "$(echo "$APPS" | grep "xterm")" ]; then
    install_xterm
  elif [ "$APPS" == "p" ] && [ "$QUIET" == "n" ]; then
    prompt_yn "Install xterm configuration?"
    if [ "$REPLY" == "y" ]; then
      install_xterm
    else
      print_debug "Skipping xterm configuration ..."
    fi
  else
    print_debug "Skipping xterm configruation ..."
  fi
else
  print_debug "xterm found. Skipping ..."
fi

# Initialize bash-palette:
if [ -z "$(type bash-palette 2> /dev/null)" ] && [ "$WORK" != "n" ]; then
  if [ "$APPS" == "y" ] || [ -n "$(echo "$APPS" | grep "nvm")" ]; then
    install_bash_palette
  elif [ "$APPS" == "p" ] && [ "$QUIET" == "n" ]; then
    prompt_yn "Install bash-palette?"
    if [ "$REPLY" == "y" ]; then
      install_bash_palette
    else
      print_debug "Skipping bash-palette configuration ..."
    fi
  else
    print_debug "Skipping bash-palette configruation ..."
  fi
else
  print_debug "bash-palette found. Skipping ..."
fi


# Unset all local functions:
unset -f install_vim
unset -f install_git
unset -f install_todo
unset -f install_nvm

# vim: set ts=4 sw=4 tw=0 noet :
