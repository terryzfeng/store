# store

When you live in the terminal as much as I do, sometimes you find yourself typing the same long things over and over again. "I gotta open this directory again buried deep in ~/Documents/Research/Programming/Cpp/FailedProjects/NumbersRoyale/". Instead of navigating there folder by folder, or typing the full path in every time, now you can just type `restore numbers-royale` and BAM! You're there, navigated to your project directory, locked in and ready to go. 

With `store`, you can save any string, directory, or file path, and restore it later with ease. Write down all your juicy secrets and then `store secrets ~/Documents/Important/DontOpen/StayAway/MySuperSecretFile.txt` deep and hidden away for safekeeping. When life happens, things get ugly, Emily said what?! to Edward, and now Steven's getting under the press and Evan's money is on the line, simply `restore secrets vim` and write that down, WRITE THAT DOWN!

TL;DR; `store` is a simple, lightweight key-value store for your terminal. Save strings, directories, or file paths under a nickname and quickly access them later.

## Installation

### Automatic (Recommended)

Run the install script to automatically copy `store.sh` to `~/.store/` and update your shell configuration:

```bash
sh install.sh
```

### Manual

Source the script in your shell (e.g., `.bashrc` or `.zshrc`):

```bash
source /path/to/store.sh
```

## Usage

### Store a value
```bash
# Store a string
store greet "hello world"

# Store a directory
store docs ~/Documents

# Store a file
store readme ./README.md

# Store a url
store google https://google.com
```

### List all stored values
```bash
stored
```

### Remove a stored value
```bash
unstore greet
```

### Restore a value
```bash
# Print stored value to stdout
restore greet

# Restore a path and chain with a command
restore docs cd
restore readme vim
restore google open

# Pipe output to another command
restore greet | wc

# Use with templates (replace {} with value)
restore greet echo "Greeting: {}"
```

## Help

Use `-h` or `--help` to see the help message for each command.