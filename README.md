# 🧰 dotfiles

Personal macOS setup for terminal, developer tools, and environment provisioning.

## 🔧 Includes

- `.zshrc` – ZSH shell config
- `.zprofile` – Login-specific environment vars
- `bootstrap.sh` – One-shot setup: clones repo, installs Brew, cleans venvs, sets up pyenv
- SSH agent + keychain configuration

## 🛠 Usage

Clone and run directly:

```bash
curl -fsSL https://raw.githubusercontent.com/DetroitCheese/dotfiles/main/bootstrap.sh | bash
