#!/bin/bash

# =========[ Function: Install OS-specific Dependencies ]=========
install_dependencies() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt &>/dev/null; then
      echo "🟦 Ubuntu/Debian detected — installing build dependencies..."
      sudo apt update && sudo apt install -y \
        make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
        libffi-dev liblzma-dev git
    elif command -v pacman &>/dev/null; then
      echo "🟩 Arch Linux detected — installing build dependencies..."
      sudo pacman -Syu --needed base-devel openssl zlib xz tk readline sqlite libffi git curl
    else
      echo "❌ Unsupported Linux distro. Install build dependencies manually."
      exit 1
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 macOS detected — installing dependencies via Homebrew..."
    if ! command -v brew &>/dev/null; then
      echo "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install openssl readline sqlite3 xz zlib git
  else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
  fi
}

# =========[ Function: Install pyenv ]=========
install_pyenv() {
  echo "📦 Installing pyenv..."
  curl https://pyenv.run | bash

  # Add pyenv config to shell
  SHELL_RC=""
  if [[ $SHELL == */zsh ]]; then
    SHELL_RC="$HOME/.zshrc"
  else
    SHELL_RC="$HOME/.bashrc"
  fi

  echo '🔧 Configuring pyenv in shell...'
  echo -e '\n# pyenv setup' >> "$SHELL_RC"
  echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> "$SHELL_RC"
  echo 'eval "$(pyenv init --path)"' >> "$SHELL_RC"
  echo 'eval "$(pyenv init -)"' >> "$SHELL_RC"
  echo 'eval "$(pyenv virtualenv-init -)"' >> "$SHELL_RC"

  # Apply immediately
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
}

# =========[ Function: Python + Virtual Env Setup ]=========
setup_python_env() {
  echo "🐍 Installing Python 3.11.9 via pyenv..."
  pyenv install 3.11.9
  pyenv shell 3.11.9

  echo "📂 Creating virtual environment..."
  python -m venv spotify_ml_env
  source spotify_ml_env/bin/activate

  echo "⬆️ Upgrading pip and installing packages..."
  pip install --upgrade pip
  pip install tensorflow[and-cuda] pandas numpy matplotlib seaborn \
    plotly scikit-learn
}

# =========[ Main Script ]=========
echo "🚀 Setting up your Spotify ML environment..."
install_dependencies
install_pyenv
setup_python_env

echo "✅ All done!"
echo "To activate your environment later, run:"
echo "  source spotify_ml_env/bin/activate"
