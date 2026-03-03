#!/bin/bash

# setup.sh - Project environment setup script for Mac (Requires Homebrew)

set -e

# 1. Check/Install rbenv and ruby-build
echo "Step 1: Ensuring rbenv and ruby-build are installed via brew"
if ! command -v rbenv >/dev/null 2>&1; then
    echo "Installing rbenv..."
    brew install rbenv
else
    echo "rbenv already installed."
fi

if ! brew list --formula | grep -q "^ruby-build$"; then
    echo "Installing ruby-build..."
    brew install ruby-build
else
    echo "ruby-build already installed."
fi

# 2. Determine Ruby version from GitHub Pages
echo "Step 2: Determining Ruby version from GitHub Pages"
# Fetch versions.json and extract ruby version (requires ruby to be present, but we have system ruby)
GITHUB_RUBY_VERSION=$(/usr/bin/ruby -e 'require "json"; require "net/http"; puts JSON.parse(Net::HTTP.get(URI("https://pages.github.com/versions.json")))["ruby"]')
echo "GitHub Pages recommended Ruby version: $GITHUB_RUBY_VERSION"

# 3. Install Ruby via rbenv and set local version
echo "Step 3: Installing Ruby $GITHUB_RUBY_VERSION via rbenv"
if ! rbenv versions --bare | grep -q "^${GITHUB_RUBY_VERSION}$"; then
    echo "Installing Ruby $GITHUB_RUBY_VERSION... (this may take a while)"
    rbenv install "$GITHUB_RUBY_VERSION"
else
    echo "Ruby $GITHUB_RUBY_VERSION already installed in rbenv."
fi

echo "Setting local ruby version to $GITHUB_RUBY_VERSION"
rbenv local "$GITHUB_RUBY_VERSION"

# 4. Initialize rbenv for current shell session
eval "$(rbenv init -)"

# 5. Install Bundler
echo "Step 4: Installing Bundler"
# Check if bundler is installed for this ruby version
if ! gem list -i bundler >/dev/null 2>&1; then
    echo "Installing bundler..."
    gem install bundler
else
    echo "Bundler already installed."
fi

# 6. Install project gems
echo "Step 5: Installing project gems"
bundle install

echo "Setup complete! You can now run the project with:"
echo "bundle exec jekyll serve"
