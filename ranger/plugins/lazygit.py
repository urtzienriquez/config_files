from ranger.api.commands import Command
from ranger.ext.get_executables import get_executables


class lazygit(Command):
    """
    :lazygit [options]
    Interact with the Git Repository using lazygit.
    https://github.com/jesseduffield/lazygit
    """

    def execute(self):

        if "lazygit" not in get_executables():
            self.fm.notify("Could not find lazygit", bad=True)
            return

        pager_commands = (
            "-h --help -v --version -c --config -cd --print-config-dir".split()
        )

        if self.rest(1) in pager_commands:
            self.fm.run(self.rest(0) + "| $PAGER")
            return

        self.fm.run(self.rest(0))
