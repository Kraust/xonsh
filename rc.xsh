import os
import shutil
from pathlib import Path
import builtins
import os
import os.path
import subprocess
import sys
import typing

import xonsh.dirstack
import xonsh.environ


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
$GIT_CONFIG_GLOBAL = "~/.config/gitconfig/gitconfig"

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

if shutil.which("grep") == "" and os.name == 'nt':
    # NOTE: Findutils is not packaged yet.
    # https://uutils.github.io/
    winget install coreutils
    winget install GnuWin32.FindUtils

if os.name == 'nt':
	$PATH.append(r'C:\Program Files\Git\usr\bin')

xonsh_env = Path(Path.home() / Path("work/scripts/xonsh.xsh"))
if xonsh_env.exists():
	source f"{xonsh_env}"

aliases["docker"] = "podman"

# =============================================================================
#
# Utility functions for zoxide.
#


def __zoxide_bin() -> str:
    """Finds and returns the location of the zoxide binary."""
    zoxide = typing.cast(str, xonsh.environ.locate_binary("zoxide"))
    if zoxide is None:
        zoxide = "zoxide"
    return zoxide


def __zoxide_env() -> dict[str, str]:
    """Returns the current environment."""
    return builtins.__xonsh__.env.detype()  # type: ignore  # pylint:disable=no-member


def __zoxide_pwd() -> str:
    """pwd based on the value of _ZO_RESOLVE_SYMLINKS."""
    pwd = __zoxide_env().get("PWD")
    if pwd is None:
        raise RuntimeError("$PWD not found")
    return pwd


def __zoxide_cd(path: str | bytes | None = None) -> None:
    """cd + custom logic based on the value of _ZO_ECHO."""
    if path is None:
        args = []
    elif isinstance(path, bytes):
        args = [path.decode("utf-8")]
    else:
        args = [path]
    _, exc, _ = xonsh.dirstack.cd(args)
    if exc is not None:
        raise RuntimeError(exc)


class ZoxideSilentException(Exception):
    """Exit without complaining."""


def __zoxide_errhandler(
    func: typing.Callable[[list[str]], None],
) -> typing.Callable[[list[str]], int]:
    """Print exception and exit with error code 1."""

    def wrapper(args: list[str]) -> int:
        try:
            func(args)
            return 0
        except ZoxideSilentException:
            return 1
        except Exception as exc:  # pylint: disable=broad-except
            print(f"zoxide: {exc}", file=sys.stderr)
            return 1

    return wrapper


# =============================================================================
#
# Hook configuration for zoxide.
#

# Initialize hook to add new entries to the database.
if "__zoxide_hook" not in globals():

    @builtins.events.on_chdir  # type: ignore  # pylint:disable=no-member
    def __zoxide_hook(**_kwargs: typing.Any) -> None:
        """Hook to add new entries to the database."""
        pwd = __zoxide_pwd()
        zoxide = __zoxide_bin()
        subprocess.run(
            [zoxide, "add", "--", pwd],
            check=False,
            env=__zoxide_env(),
        )


# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#


@__zoxide_errhandler
def __zoxide_z(args: list[str]) -> None:
    """Jump to a directory using only keywords."""
    if args == []:
        __zoxide_cd()
    elif args == ["-"]:
        __zoxide_cd("-")
    elif len(args) == 1 and os.path.isdir(args[0]):
        __zoxide_cd(args[0])
    else:
        try:
            zoxide = __zoxide_bin()
            cmd = subprocess.run(
                [zoxide, "query", "--exclude", __zoxide_pwd(), "--"] + args,
                check=True,
                env=__zoxide_env(),
                stdout=subprocess.PIPE,
            )
        except subprocess.CalledProcessError as exc:
            raise ZoxideSilentException() from exc

        result = cmd.stdout[:-1]
        __zoxide_cd(result)


@__zoxide_errhandler
def __zoxide_zi(args: list[str]) -> None:
    """Jump to a directory using interactive search."""
    try:
        zoxide = __zoxide_bin()
        cmd = subprocess.run(
            [zoxide, "query", "-i", "--"] + args,
            check=True,
            env=__zoxide_env(),
            stdout=subprocess.PIPE,
        )
    except subprocess.CalledProcessError as exc:
        raise ZoxideSilentException() from exc

    result = cmd.stdout[:-1]
    __zoxide_cd(result)


# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

builtins.aliases["cd"] = __zoxide_z  # type: ignore  # pylint:disable=no-member
builtins.aliases["z"] = __zoxide_z  # type: ignore  # pylint:disable=no-member
builtins.aliases["zi"] = __zoxide_zi  # type: ignore  # pylint:disable=no-member

# =============================================================================
#
# To initialize zoxide, add this to your configuration (usually ~/.xonshrc):
#
# execx($(zoxide init xonsh), 'exec', __xonsh__.ctx, filename='zoxide')
