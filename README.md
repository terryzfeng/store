# store

When you live in the terminal as much as I do, sometimes you find yourself typing the same long things over and over again. "I gotta open this directory again buried deep in ~/Documents/Research/Programming/Cpp/FailedProjects/NumbersRoyale/". Instead of navigating there folder by folder, or typing the full path in every time, now you can just type `restore numbers-royale` and BAM! You're there, navigated to your project directory, locked in and ready to go. 

With `store`, you can save any string, directory, or file path, and restore it later with ease. Write down all your juicy secrets and then `store secrets ~/Documents/Important/DontOpen/StayAway/MySuperSecretFile.txt` deep and hidden away for safekeeping. When life happens, things get ugly, Emily said what?! to Edward, and now Steven's getting under the press and Evan's money is on the line, simply `restore secrets vim` and write that down, WRITE THAT DOWN!

TL;DR; A simple, lightweight key-value store for your terminal. Save strings, directories, or files and restore them later.

## Installation

Source the script in your shell (e.g., `.bashrc` or `.zshrc`):

```bash
source /path/to/store.sh
```

## Usage

### Store a value
```bash
store greet "hello world"
store docs ~/Documents
store script my_script.sh
```

### List all stored values
```bash
stored
```

### Restore a value
```bash
# Print the value
restore greet

# Change directory (if value is a directory)
restore docs

# Use with a command
restore script vim   # Opens the file in vim
```
