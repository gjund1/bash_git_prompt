#!/usr/bin/env bash

# ============================================================
# Bash Git Prompt Installer
# Compatible with Ubuntu and Debian
# ============================================================

set -o pipefail

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

APP_NAME="Bash Git Prompt"
APP_VERSION="1.0.0"

BASHRC="${HOME}/.bashrc"
CONFIG_FILE="${HOME}/.bash_git_prompt.sh"

START_MARKER="# >>> BASH GIT PROMPT >>>"
END_MARKER="# <<< BASH GIT PROMPT <<<"

# Detect whether the script is sourced
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    SCRIPT_SOURCED=true
else
    SCRIPT_SOURCED=false
fi

# ------------------------------------------------------------
# Colors
# ------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

# ------------------------------------------------------------
# Display functions
# ------------------------------------------------------------

print_header() {
    echo
    echo -e "${CYAN}============================================${RESET}"
    echo -e "${CYAN}       ${APP_NAME} v${APP_VERSION}${RESET}"
    echo -e "${CYAN}============================================${RESET}"
    echo
}

success() {
    echo -e "${GREEN}[OK]${RESET} $1"
}

warning() {
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

error() {
    echo -e "${RED}[ERROR]${RESET} $1"
}

info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

# ------------------------------------------------------------
# Help
# ------------------------------------------------------------

show_help() {
    print_header

    echo "Usage:"
    echo
    echo "  source ./install.sh       Install and activate"
    echo "  ./install.sh              Install"
    echo "  ./install.sh --status     Check installation"
    echo "  ./install.sh --uninstall  Uninstall"
    echo "  ./install.sh --help       Display help"
    echo
}

# ------------------------------------------------------------
# Operating system verification
# ------------------------------------------------------------

check_os() {

    if [[ ! -f /etc/os-release ]]; then
        error "Cannot identify operating system."
        return 1
    fi

    # shellcheck disable=SC1091
    source /etc/os-release

    case "${ID}" in
        ubuntu|debian)
            success "Operating system: ${PRETTY_NAME}"
            ;;
        *)
            error "Unsupported operating system: ${PRETTY_NAME}"
            echo "Supported systems: Ubuntu and Debian."
            return 1
            ;;
    esac
}

# ------------------------------------------------------------
# Bash verification
# ------------------------------------------------------------

check_bash() {

    if [[ -z "${BASH_VERSION:-}" ]]; then
        error "This installer requires Bash."
        return 1
    fi

    success "Bash version: ${BASH_VERSION}"
}

# ------------------------------------------------------------
# Git verification
# ------------------------------------------------------------

check_git() {

    if command -v git >/dev/null 2>&1; then
        success "Git available: $(git --version)"
    else
        warning "Git is not installed."
        warning "The prompt will work without Git branch information."
        echo "Install Git later with: sudo apt install git"
    fi
}

# ------------------------------------------------------------
# Check existing installation
# ------------------------------------------------------------

check_installation() {

    if [[ ! -f "${BASHRC}" ]]; then
        return 0
    fi

    local start_count
    local end_count

    start_count=$(grep -Fc "${START_MARKER}" "${BASHRC}" || true)
    end_count=$(grep -Fc "${END_MARKER}" "${BASHRC}" || true)

    if [[ "${start_count}" -ne "${end_count}" ]] ||
       [[ "${start_count}" -gt 1 ]]; then

        error "Incomplete or duplicated installation detected."
        echo "Please inspect ${BASHRC} manually."
        return 2
    fi

    if [[ "${start_count}" -eq 1 ]]; then

        if [[ ! -f "${CONFIG_FILE}" ]]; then
            error "Configuration file is missing."
            return 2
        fi

        success "Existing installation detected."
        return 1
    fi

    return 0
}

# ------------------------------------------------------------
# Backup
# ------------------------------------------------------------

create_backup() {

    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")

    if [[ -f "${BASHRC}" ]]; then

        cp -p "${BASHRC}" "${BASHRC}.backup_${timestamp}" || {
            error "Unable to backup .bashrc."
            return 1
        }

        success "Backup created: ${BASHRC}.backup_${timestamp}"

    fi

    if [[ -f "${CONFIG_FILE}" ]]; then

        cp -p "${CONFIG_FILE}" "${CONFIG_FILE}.backup_${timestamp}" || {
            error "Unable to backup configuration."
            return 1
        }

        success "Configuration backup created."

    fi
}

# ------------------------------------------------------------
# Create prompt configuration
# ------------------------------------------------------------

create_configuration() {

    cat > "${CONFIG_FILE}" <<'PROMPT_CONFIG'
# ============================================================
# Bash Git Prompt
# ============================================================

# Display current Git branch
__bpg_git_branch() {

    command -v git >/dev/null 2>&1 || return 0

    git rev-parse --is-inside-work-tree &>/dev/null || return 0

    local branch

    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)

    # Detached HEAD
    if [[ -z "${branch}" ]]; then
        branch=$(git rev-parse --short HEAD 2>/dev/null)
    fi

    [[ -n "${branch}" ]] && printf ' (%s)' "${branch}"
}

# Custom prompt
#
# Green  : user@hostname
# Blue   : current directory
# Yellow : Git branch

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[01;33m\]$(__bpg_git_branch)\[\033[00m\]\$ '

PROMPT_CONFIG

    if [[ $? -ne 0 ]]; then
        error "Unable to create configuration file."
        return 1
    fi

    chmod 644 "${CONFIG_FILE}"

    success "Prompt configuration created."
}

# ------------------------------------------------------------
# Add configuration to .bashrc
# ------------------------------------------------------------

update_bashrc() {

    touch "${BASHRC}" || {
        error "Unable to create .bashrc."
        return 1
    }

    cat >> "${BASHRC}" <<EOF

${START_MARKER}
if [[ -f "\${HOME}/.bash_git_prompt.sh" ]]; then
    source "\${HOME}/.bash_git_prompt.sh"
fi
${END_MARKER}
EOF

    success ".bashrc updated."
}

# ------------------------------------------------------------
# Installation
# ------------------------------------------------------------

install_prompt() {

    print_header

    echo "Checking system..."
    echo

    check_os || return 1
    check_bash || return 1
    check_git

    echo

    local result

    check_installation
    result=$?

    case "${result}" in
        1)
            warning "Bash Git Prompt is already installed."
            echo
            echo "Use --status to inspect the installation."
            return 0
            ;;
        2)
            return 1
            ;;
    esac

    echo "Starting installation..."
    echo

    create_backup || return 1

    create_configuration || return 1

    update_bashrc || return 1

    echo
    success "Installation completed!"

    if [[ "${SCRIPT_SOURCED}" == true ]]; then

        # Activate immediately in the current terminal
        source "${CONFIG_FILE}"

        success "Prompt activated in the current terminal."

    else

        echo
        info "To activate the prompt in your current terminal:"
        echo
        echo "  source ~/.bashrc"
        echo

    fi
}

# ------------------------------------------------------------
# Installation status
# ------------------------------------------------------------

show_status() {

    print_header

    echo "Installation status:"
    echo

    if [[ ! -f "${BASHRC}" ]]; then
        error ".bashrc not found."
        return 1
    fi

    local start_count
    local end_count

    start_count=$(grep -Fc "${START_MARKER}" "${BASHRC}" || true)
    end_count=$(grep -Fc "${END_MARKER}" "${BASHRC}" || true)

    if [[ "${start_count}" -ne "${end_count}" ]] ||
       [[ "${start_count}" -gt 1 ]]; then

        error "Installation integrity: FAILED"
        return 1
    fi

    if [[ "${start_count}" -eq 0 ]]; then
        warning "Prompt is not installed."
        return 1
    fi

    success "Installation markers: OK"

    if [[ -f "${CONFIG_FILE}" ]]; then
        success "Configuration file: OK"
    else
        error "Configuration file: MISSING"
        return 1
    fi

    if grep -Fq 'source "${HOME}/.bash_git_prompt.sh"' "${BASHRC}"; then
        success "Configuration loading: OK"
    else
        error "Configuration loading: FAILED"
        return 1
    fi

    if command -v git >/dev/null 2>&1; then
        success "Git: $(git --version)"
    else
        warning "Git is not installed."
    fi

    echo
    success "Installation integrity: OK"
}

# ------------------------------------------------------------
# Remove managed block from .bashrc
# ------------------------------------------------------------

remove_bashrc_block() {

    local temporary_file

    temporary_file=$(mktemp "${BASHRC}.XXXXXX") || {
        error "Unable to create temporary file."
        return 1
    }

    awk -v start="${START_MARKER}" -v end="${END_MARKER}" '
        $0 == start {
            inside = 1
            next
        }

        $0 == end {
            inside = 0
            next
        }

        !inside {
            print
        }
    ' "${BASHRC}" > "${temporary_file}" || {
        rm -f "${temporary_file}"
        error "Unable to process .bashrc."
        return 1
    }

    cat "${temporary_file}" > "${BASHRC}" || {
        rm -f "${temporary_file}"
        error "Unable to update .bashrc."
        return 1
    }

    rm -f "${temporary_file}"

    success "Managed block removed from .bashrc."
}

# ------------------------------------------------------------
# Uninstallation
# ------------------------------------------------------------

uninstall_prompt() {

    print_header

    echo "Checking installation..."
    echo

    if [[ ! -f "${BASHRC}" ]]; then
        warning ".bashrc not found."
        return 0
    fi

    local start_count
    local end_count

    start_count=$(grep -Fc "${START_MARKER}" "${BASHRC}" || true)
    end_count=$(grep -Fc "${END_MARKER}" "${BASHRC}" || true)

    if [[ "${start_count}" -eq 0 ]] &&
       [[ "${end_count}" -eq 0 ]]; then

        warning "No installation detected."
        return 0
    fi

    if [[ "${start_count}" -ne 1 ]] ||
       [[ "${end_count}" -ne 1 ]]; then

        error "Incomplete installation detected."
        error "Automatic removal cancelled to protect .bashrc."
        return 1
    fi

    create_backup || return 1

    remove_bashrc_block || return 1

    if [[ -f "${CONFIG_FILE}" ]]; then
        rm -f "${CONFIG_FILE}" || {
            error "Unable to remove configuration."
            return 1
        }
    fi

    echo
    success "Uninstallation completed."

    if [[ "${SCRIPT_SOURCED}" == true ]]; then

        # Remove the custom prompt from current shell
        unset -f __bpg_git_branch

        PS1='\u@\h:\w\$ '

        success "Current terminal prompt reset."

    else

        echo
        info "Reload your terminal configuration:"
        echo
        echo "  source ~/.bashrc"
        echo

    fi
}

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------

main() {

    case "${1:-}" in

        --help|-h)
            show_help
            ;;

        --status)
            show_status
            ;;

        --uninstall)
            uninstall_prompt
            ;;

        "")
            install_prompt
            ;;

        *)
            error "Unknown option: $1"
            show_help
            return 1
            ;;

    esac
}

# ------------------------------------------------------------
# Execute
# ------------------------------------------------------------

main "$@"
RESULT=$?

if [[ "${SCRIPT_SOURCED}" == true ]]; then
    return "${RESULT}"
else
    exit "${RESULT}"
fi
