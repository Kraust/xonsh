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

from xonsh.built_ins import XSH
xontrib load fzf-completions
XSH.env['fzf_history_binding'] = "c-r"  # Ctrl+R
XSH.env['fzf_ssh_binding'] = "c-s"  # Ctrl+S
XSH.env['fzf_file_binding'] = "c-t"  # Ctrl+T
XSH.env['fzf_dir_binding'] = "c-g"  # Ctrl+G

xontrib load coreutils
xontrib load pyenv
xontrib load nodenv
xontrib load goenv
xontrib load prompt_starship
