# laptop setup

**.dotfiles**: create symbolic links in `$HOME`.

**folders**: symbolic links in `.config`. E.g.:

```bash
ln -s ~/path/to/file/or/folder/in/github/repo $HOME/.config/
```

For **Vim pluggins** need to install vim-plug. For that run:

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
