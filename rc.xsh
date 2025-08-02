import os
from pathlib import Path

$PATH.append("~/.local/xonsh-env/bin/")
$PATH.append("~/.cargo/bin")
$PATH.append("~/bin")
$PATH.append("~/.config/bin")
$PATH.append("~/.pyenv/bin")
$PATH.append("~/.goenv/bin")
$PATH.append("~/.nodenv/bin")
$PATH.append("~/.rbenv/bin")

$XONSH_HISTORY_BACKEND = 'sqlite'
$STARSHIP_CONFIG = '~/.config/starship/starship.toml'
# $GIT_CONFIG_GLOBAL = f"{$HOME}/.config/gitconfig/gitconfig"

if os.name != "nt":
    if not Path(Path.home() / ".goenv/bin").exists():
        git clone https://github.com/go-nv/goenv.git ~/.goenv
        pip install xontrib-langenv

    if not Path(Path.home() / ".pyenv/bin").exists():
        git clone https://github.com/pyenv/pyenv.git ~/.pyenv
        pip install xontrib-langenv

    if not Path(Path.home() / ".nodenv/bin").exists():
        git clone https://github.com/nodenv/nodenv.git ~/.nodenv
        pip install xontrib-langenv

    # Manually run git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
    if not Path(Path.home() / ".rbenv/bin").exists():
        git clone https://github.com/rbenv/rbenv.git ~/.rbenv
        pip install xontrib-langenv

        xontrib load pyenv
        xontrib load nodenv
        xontrib load goenv
        xontrib load rbenv

xontrib load -s sh jump_to_dir pipeliner whole_word_jumping dalias;
$PROMPT = $PROMPT.replace('{prompt_end}', '\n{prompt_end}')

from xonsh.built_ins import XSH
xontrib load fzf-completions
XSH.env['fzf_history_binding'] = "c-r"  # Ctrl+R
XSH.env['fzf_ssh_binding'] = "c-s"  # Ctrl+S
XSH.env['fzf_file_binding'] = "c-t"  # Ctrl+T
XSH.env['fzf_dir_binding'] = "c-g"  # Ctrl+G

# xpip install xontrib-prompt-starship
# xpip install xontrib-fzf-completions
# xpip install xontrib-langenv
xontrib load coreutils
xontrib load prompt_starship

aliases['ls'] = 'eza'
aliases['find'] = 'fd'

if os.name == 'nt':
	$PATH.append(r'C:\Program Files\Git\usr\bin')

xonsh_env = Path(Path.home() / Path("work/scripts/xonsh.xsh"))
if xonsh_env.exists():
	source f"{xonsh_env}"

