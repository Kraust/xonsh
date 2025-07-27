$PATH.append("~/.local/xonsh-env/bin/")
$PATH.append("~/.cargo/bin")
$PATH.append("~/bin")
$PATH.append("~/.config/bin")
$PATH.append("~/.pyenv/bin")
$PATH.append("~/.goenv/bin")
$PATH.append("~/.nodenv/bin")

$XONSH_HISTORY_BACKEND = 'sqlite'
$STARSHIP_CONFIG = '~/.config/starship/starship.toml'
$GIT_CONFIG_GLOBAL = f"{$HOME}/.config/gitconfig/gitconfig"

xontrib load -s sh jump_to_dir pipeliner whole_word_jumping dalias;
$PROMPT = $PROMPT.replace('{prompt_end}', '\n{prompt_end}')

xontrib load fzf-widgets
$fzf_history_binding = "c-r"  # Ctrl+R
$fzf_ssh_binding = "c-s"      # Ctrl+S
$fzf_file_binding = "c-t"      # Ctrl+T
$fzf_dir_binding = "c-g"      # Ctrl+G


$fzf_find_command = "fd"
$fzf_find_dirs_command = "fd -t d"


xontrib load coreutils
xontrib load pyenv
xontrib load nodenv
xontrib load goenv
xontrib load prompt_starship

