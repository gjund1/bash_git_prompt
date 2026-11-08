# Bash Git Prompt

A lightweight and customizable Bash prompt installer for Ubuntu and Debian.

Bash Git Prompt automatically customizes your terminal to display useful information, including the current user, hostname, working directory and Git branch.

The project provides a simple installation system with automatic backups, installation checks, duplicate detection and clean uninstallation.

No additional dependencies or complex configuration are required.

---

## 1. Presentation

**Bash Git Prompt** is a small Bash utility designed to improve the readability and usability of the Linux terminal.

The default Bash prompt provides basic information about the current user and directory. However, when working with multiple projects and Git repositories, it can be useful to see the current Git branch directly in the terminal.

This project adds that functionality while keeping the prompt simple, readable and lightweight.

### Main objectives

- Display the current username and hostname.
- Display the current working directory.
- Automatically detect and display the active Git branch.
- Use colors to distinguish different prompt elements.
- Install the configuration automatically.
- Preserve the user's existing Bash configuration.
- Provide installation verification and clean uninstallation.

### Key features

| Feature | Description |
|---|---|
| Custom prompt | Personalized Bash terminal prompt |
| Git integration | Automatic Git branch detection |
| Colored display | Different colors for each prompt element |
| OS detection | Ubuntu and Debian verification |
| Bash verification | Checks Bash availability |
| Git verification | Checks whether Git is installed |
| Automatic backup | Creates timestamped backups |
| Duplicate protection | Detects existing installations |
| Integrity check | Detects incomplete installations |
| Status command | Checks installation status |
| Update command | Regenerates the prompt configuration |
| Uninstaller | Removes the installed configuration |
| Immediate activation | Activates changes without restarting the terminal |

---

## 2. Prompt Preview

The prompt displays different information depending on the current working directory.

### Inside a Git repository

```bash
user@mon_compte:~/projects/my-project (main)$
```

### Inside a feature branch

```bash
user@mon_compte:~/projects/my-project (feature/login)$
```

### Inside a Git development branch

```bash
user@mon_compte:/opt/lampp/htdocs/mon_pojet (dev)$
```

### Outside a Git repository

```bash
user@mon_compte:~/Documents$
```

The Git branch information is displayed only when the current directory belongs to a Git repository.

### Color scheme

| Element | Color | Description |
|---|---|---|
| Username and hostname | Green | Identifies the current user and machine |
| Current directory | Blue | Displays the working directory |
| Git branch | Yellow | Displays the active Git branch |
| Prompt symbol | Default | `$` for standard users |

### Visual example

```text
user@mon_compte:~/projects/projet (feature/add)$
```

The colors help identify each element quickly without making the terminal unnecessarily complicated.

---

## 3. Architecture

The project uses a simple and modular architecture with three main files.

```text
bash-git-prompt/
│
├── install.sh
│
├── README.md
│
└── LICENSE
```

### File description

#### install.sh

The main Bash installation program.

It handles:

- Operating system verification.
- Bash environment verification.
- Git availability verification.
- Existing installation detection.
- Configuration backup.
- Prompt configuration creation.
- Integration into `.bashrc`.
- Installation status verification.
- Clean uninstallation.
- Immediate prompt activation when sourced.

#### README.md

Project documentation.

It explains the installation process, architecture, features, available commands and configuration.

#### LICENSE

The MIT license allows other developers to use, modify and redistribute the project under its terms.

### Files created during installation

The installer creates the following configuration file in the user's home directory:

```text
~/
├── .bashrc
├── .bash_git_prompt.sh
│
├── .bashrc.backup_YYYYMMDD_HHMMSS
│
└── .bash_git_prompt.sh.backup_YYYYMMDD_HHMMSS
```

The backup files are created only when the corresponding original configuration files exist.

The installer does not overwrite the complete `.bashrc` file.

Instead, it adds a dedicated configuration block.

---

## 4. How It Works

Bash Git Prompt uses a separate configuration file loaded automatically through `.bashrc`.

### Step 1: Installation

The installer checks the operating system, Bash environment and Git availability.

It then checks whether a previous installation exists.

If everything is correct, it creates a backup of the existing configuration.

### Step 2: Configuration creation

The installer creates:

```bash
~/.bash_git_prompt.sh
```

This file contains the Git branch detection function and the custom prompt definition.

### Step 3: Integration with .bashrc

A dedicated block is added to the user's `.bashrc`:

```bash
# >>> BASH GIT PROMPT >>>

if [[ -f "${HOME}/.bash_git_prompt.sh" ]]; then
    source "${HOME}/.bash_git_prompt.sh"
fi

# <<< BASH GIT PROMPT <<<
```

This allows Bash to load the custom prompt automatically whenever a new interactive shell starts.

### Step 4: Git branch detection

The function:

```bash
__bpg_git_branch()
```

checks whether the current directory belongs to a Git repository.

It uses:

```bash
git rev-parse --is-inside-work-tree
```

If the directory is inside a repository, it retrieves the current branch:

```bash
git symbolic-ref --quiet --short HEAD
```

If Git is in detached HEAD state, it displays the short commit hash instead.

If the current directory is not inside a Git repository, nothing is displayed.

### Step 5: Prompt display

The custom `PS1` variable combines:

- Username: `\u`
- Hostname: `\h`
- Current directory: `\w`
- Git branch: `__bpg_git_branch`
- Prompt symbol: `\$`

The Git branch function is evaluated whenever Bash displays the prompt.

---

## 5. Installation

### Requirements

- Ubuntu or Debian.
- Bash.
- Git (optional, but required for Git branch information).

No additional dependencies are required.

### Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/bash-git-prompt.git
```

Enter the project directory:

```bash
cd bash-git-prompt
```

Make the installer executable:

```bash
chmod +x install.sh
```

### Option 1: Immediate installation

```bash
source ./install.sh
```

This is the recommended installation method.

It installs the configuration and activates the custom prompt immediately in the current terminal.

No additional command is necessary.

### Option 2: Standard installation

```bash
./install.sh
```

The installer modifies `.bashrc` but does not activate the prompt in the current terminal.

To activate it manually:

```bash
source ~/.bashrc
```

## Updating the Configuration

Bash Git Prompt includes an update command that allows users to regenerate the prompt configuration directly from `install.sh`.

This is particularly useful when modifying the Git branch display, prompt colors or other configuration settings.

### Update and activate immediately

```bash
source ./install.sh --update
```

This command:

1. Checks whether an installation already exists.
2. Verifies the installation markers in `.bashrc`.
3. Creates a timestamped backup of the existing configuration.
4. Regenerates `~/.bash_git_prompt.sh`.
5. Activates the updated prompt in the current terminal.

### Standard update

```bash
./install.sh --update
```

This updates the configuration without activating it immediately.

To activate the changes manually:

```bash
source ~/.bash_git_prompt.sh
```

### Example: Changing the Git branch color

The Git branch color can be modified directly in the `PS1` variable inside `install.sh`.

Example with a red Git branch:

```bash
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[01;31m\]$(__bpg_git_branch)\[\033[00m\]\$ '
```

After saving the changes, run:

```bash
source ./install.sh --update
```

The new configuration will be generated and activated automatically.

---

### 6. Available Commands

The installer supports several operations:

| Command | Description |
|---|---|
| `./install.sh` | Install the prompt |
| `source ./install.sh` | Install and activate immediately |
| `./install.sh --update` | Update the existing configuration |
| `source ./install.sh --update` | Update and activate immediately |
| `./install.sh --status` | Check installation status |
| `./install.sh --uninstall` | Uninstall the prompt |
| `./install.sh --help` | Display available commands |

### Check installation status

```bash
./install.sh --status
```

This command checks:

- Installation markers in `.bashrc`.
- Configuration file availability.
- Configuration loading.
- Git availability.
- Installation integrity.

### Uninstall

```bash
source ./install.sh --uninstall
```

The uninstaller:

1. Checks the existing installation.
2. Creates a backup.
3. Removes the dedicated configuration block from `.bashrc`.
4. Deletes `.bash_git_prompt.sh`.
5. Resets the current terminal prompt when sourced.

Unrelated `.bashrc` configuration is preserved.

### Help

```bash
./install.sh --help
```

Displays the available commands and usage instructions.

---

## 7. Backup and Installation Integrity

Protecting the user's existing configuration is an important part of this project.

Before modifying `.bashrc`, the installer creates a timestamped backup.

Example:

```text
.bashrc.backup_20261108_083000
```

If the configuration file already exists, it is also backed up before being replaced.

### Duplicate installation protection

The installer uses two markers:

```bash
# >>> BASH GIT PROMPT >>>
```

```bash
# <<< BASH GIT PROMPT <<<
```

These markers identify the configuration block managed by the installer.

They prevent duplicate installations and allow the uninstaller to identify the exact section to remove.

### Integrity verification

The installer checks whether:

- Both markers exist.
- The markers are correctly paired.
- There is only one installation block.
- The configuration file exists.

If an incomplete installation is detected, the installer stops rather than automatically modifying potentially damaged configuration.

---

## 8. Compatibility

| Operating system | Compatibility |
|---|---|
| Ubuntu | Supported |
| Debian | Supported |
| Linux Mint | Not officially tested |
| Other Linux distributions | Not officially supported |

The installer is designed for Bash environments.

Git is optional: the custom prompt still works without Git, but branch information will not be displayed.

---

## 9. Technical Details

### Technologies

- Bash
- GNU/Linux
- Git
- Standard Unix utilities (`grep`, `awk`, `cp`, `mktemp`, `date`)

### Configuration

The prompt is configured using the Bash `PS1` variable.

Git branch detection is performed dynamically through a Bash function.

No external prompt framework is required.

### Design principles

- Lightweight implementation.
- No unnecessary dependencies.
- Simple installation.
- Safe configuration management.
- Minimal modifications to existing files.
- Easy maintenance and removal.

---

## 10. License

This project is distributed under the **MIT License**.

You are free to use, modify and redistribute the software according to the terms of the license.

See the [LICENSE](LICENSE) file for more information.

---

## 11. Author

**Bash Git Prompt**

A lightweight Bash customization project for Ubuntu and Debian.

Developed to simplify terminal navigation and improve Git workflow visibility.