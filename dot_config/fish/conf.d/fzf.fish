# FZF configuration
# Env vars must be set before fzf --fish sources key bindings (done in config.fish)

# Disable Ctrl-R: atuin handles history search
# fzf skips the binding when this var is set and empty
set -gx FZF_CTRL_R_COMMAND ""

# Disable Alt-C: no directory jump command configured
set -gx FZF_ALT_C_COMMAND ""

# In git repos: git ls-files (tracks .gitignore, shows tracked + untracked non-ignored files)
# Outside git repos: bfs fallback (fast breadth-first traversal, excludes .git dir)
set -gx FZF_DEFAULT_COMMAND "git ls-files --cached --others --exclude-standard 2>/dev/null || bfs -color -mindepth 1 -exclude \( -name .git \) -type f -printf '%P\n' 2>/dev/null"
set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --ansi"

# Ctrl-T: same strategy as default command
set -gx FZF_CTRL_T_COMMAND "git ls-files --cached --others --exclude-standard 2>/dev/null || bfs -color -mindepth 1 -exclude \( -name .git \) -type f -printf '%P\n' 2>/dev/null"
set -gx FZF_CTRL_T_OPTS "--preview 'bat -n --color=always --line-range :500 {}'"

# Git integration: used by fzf-git bindings
function _fzf_git_fzf
    fzf-tmux -p80%,60% -- \
        --layout=reverse --multi --height=50% --min-height=20 --border \
        --border-label-pos=2 \
        --color='header:italic:underline,label:blue' \
        --preview-window='right,50%,border-left' \
        --bind='ctrl-/:change-preview-window(down,50%,border-top|hidden|)' $argv
end

# Pacman helpers
function paruinstall
    paru -Slq | fzf -q "$argv[1]" -m --preview 'paru -Si {1}' | xargs -ro paru -S
end

function paruremove
    paru -Qq | fzf -q "$argv[1]" -m --preview 'paru -Qi {1}' | xargs -ro paru -Rns
end

# Interactive man page search
function fman
    man -k . | fzf -q "$argv[1]" --prompt='man> ' \
        --preview "echo {} | tr -d '()' | awk '{printf \"%s \", \$2} {print \$1}' | xargs -r man" \
        | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
end
