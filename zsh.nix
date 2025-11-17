{ ... }: {

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "pattern"
        "regexp"
        "root"
        "line"
      ];
    };
    historySubstringSearch.enable = true;

    history = {
      ignoreDups = true;
      save = 10000;
      size = 10000;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "direnv"
        "extract"
        "history"
        "command-not-found"
        "colored-man-pages"
        "sudo"
      ];
    };

    initContent = ''
      # ============================================================================
      # HISTORY OPTIONS (from zshrc-drew)
      # ============================================================================
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_REDUCE_BLANKS
      setopt INC_APPEND_HISTORY
      setopt SHARE_HISTORY
      setopt HIST_EXPIRE_DUPS_FIRST
      setopt HIST_IGNORE_SPACE

      # ============================================================================
      # DIRECTORY OPTIONS (from zshrc-drew)
      # ============================================================================
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT

      # ============================================================================
      # COMPLETION OPTIONS (from zshrc-drew)
      # ============================================================================
      setopt ALWAYS_TO_END
      setopt AUTO_MENU
      setopt COMPLETE_IN_WORD
      setopt AUTO_LIST
      setopt AUTO_PARAM_SLASH

      # ============================================================================
      # GLOBBING OPTIONS (from zshrc-drew)
      # ============================================================================
      setopt GLOB_DOTS
      setopt EXTENDED_GLOB
      setopt NO_CASE_GLOB

      # ============================================================================
      # OTHER OPTIONS (from zshrc-drew)
      # ============================================================================
      setopt INTERACTIVE_COMMENTS
      setopt NO_BEEP
      setopt PROMPT_SUBST

      # ============================================================================
      # LOCALE & LESS CONFIGURATION (from zshrc-drew)
      # ============================================================================
      export LANG=en_US.UTF-8
      export LC_ALL=en_US.UTF-8
      export LESS='-R -F -X -i -P %f (%i/%m) '
      export LESSHISTFILE=/dev/null

      # Colored man pages (from zshrc-drew)
      export LESS_TERMCAP_mb=$'\e[1;32m'
      export LESS_TERMCAP_md=$'\e[1;32m'
      export LESS_TERMCAP_me=$'\e[0m'
      export LESS_TERMCAP_se=$'\e[0m'
      export LESS_TERMCAP_so=$'\e[01;33m'
      export LESS_TERMCAP_ue=$'\e[0m'
      export LESS_TERMCAP_us=$'\e[1;4;31m'

      # ============================================================================
      # COMPLETION CACHING (from zshrc-drew)
      # ============================================================================
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "$HOME/.zsh/cache"
      zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
      zstyle ':completion:*:warnings' format '%F{red}No matches found%f'

      # ============================================================================
      # TERMINAL & KEYBINDINGS
      # ============================================================================
      export TERMINAL="kitty"
      export XDG_TERMINAL_EMULATOR="kitty"
      bindkey "\eh" backward-word
      bindkey "\ej" down-line-or-history
      bindkey "\ek" up-line-or-history
      bindkey "\el" forward-word

      # ============================================================================
      # PERSONAL OVERRIDES
      # ============================================================================
      if [ -f $HOME/.zshrc-personal ]; then
        source $HOME/.zshrc-personal
      fi

      # Disable any right prompt from zsh/oh-my-zsh themes to avoid stray symbols (e.g., snowflake)
      RPROMPT=""
      RPS1=""

      # ============================================================================
      # WELCOME MESSAGE (from zshrc-drew)
      # ============================================================================
      if [ -n "$PS1" ]; then
        echo
        echo -e "\033[1;34m  / |/ (_)_ __/ __ \\\\ / __/\033[0m"
        echo -e "\033[1;34m /    / /\\\\ \\\\ / /_/ /\\\\ \\\\\033[0m"
        echo -e "\033[1;34m/_/|_/_//_\\\\_\\\\\\\\____/___/\033[0m"
        echo
        echo -e "\033[1;34m=== Welcome back, $USER! ===\033[0m"
        echo -e "Date: $(date '+%A, %B %d, %Y - %H:%M:%S')"
        echo -e "Hostname: $(hostname)"
        echo -e "Kernel: $(uname -sr)"
        echo -e "Uptime: $(uptime | awk '{print $3, $4}' | sed 's/,$//')"
        echo -e "Load: $(uptime | awk -F'load average:' '{print $2}')"
        echo
      fi
    '';

  };
}
