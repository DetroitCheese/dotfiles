#!/bin/bash
# === bootstrap.sh ===
# This script sets up a new Mac with your dotfiles, Homebrew packages, Python deps, and prunes idle venvs

set -e

### CONFIG ###
DOTFILES_REPO="git@github.com:DetroitCheese/dotfiles.git"
PROJECTS_DIR="$HOME/projects"
VENV_NAME=".venv"

### STEP 1: Clone dotfiles repo ###
echo "\n🔧 Cloning dotfiles..."
git clone "$DOTFILES_REPO" "$HOME/dotfiles"
cd "$HOME/dotfiles"

### STEP 2: Setup Homebrew & install Brewfile deps ###
echo "\n🍺 Installing Homebrew packages..."
which -s brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$($(brew --prefix)/bin/brew shellenv)"

# Ensure Homebrew is in PATH permanently
if ! grep -q "brew shellenv" "$HOME/.zprofile"; then
  echo 'eval "$($(brew --prefix)/bin/brew shellenv)"' >> "$HOME/.zprofile"
fi

brew bundle --file="$HOME/dotfiles/Brewfile"

### STEP 3: Symlink dotfiles (optional customize) ###
echo "\n🔗 Linking dotfiles..."
ln -sf "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"
# Add more dotfiles as needed

### STEP 4: Clean idle venvs in ~/projects ###
echo "\n🧹 Cleaning idle virtual environments in $PROJECTS_DIR..."
find "$PROJECTS_DIR" -type d -name "$VENV_NAME" | while read venv_dir; do
  project_dir="$(dirname "$venv_dir")"
  if [ ! -f "$project_dir/requirements.txt" ]; then
    # Remove if no requirements.txt and no .py file modified in last 90 days
    if ! find "$project_dir" -name "*.py" -mtime -90 | grep -q .; then
      echo "⚠️  Removing idle venv: $venv_dir"
      rm -rf "$venv_dir"
    fi
  fi
done

### STEP 5: Install pyenv + plugins ###
echo "\n🐍 Setting up pyenv and installing Python versions..."
brew install pyenv pyenv-virtualenv

if ! grep -q 'pyenv init' ~/.zshrc; then
  echo -e '\n# Pyenv init' >> ~/.zshrc
  echo 'eval "$(pyenv init --path)"' >> ~/.zprofile
  echo 'eval "$(pyenv init -)"' >> ~/.zshrc
  echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc
fi

# Auto-install Python versions if .python-version exists
find "$PROJECTS_DIR" -name ".python-version" | while read pyenv_file; do
  py_version=$(cat "$pyenv_file")
  echo "📦 Installing Python $py_version via pyenv..."
  pyenv install -s "$py_version"
done

### STEP 6: Reload shell ###
echo "\n✅ Setup complete. Reloading shell..."
exec $SHELL -l
