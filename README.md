# dotfiles

Config for an Arch + Hyprland (HyDE) setup, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Each top-level directory is a **stow package** whose inner tree mirrors `$HOME`.
`stow hypr` symlinks `hypr/.config/hypr/*` to `~/.config/hypr/*`.

## Restore on a new machine

```sh
sudo pacman -S stow
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
stow hypr waybar kitty zsh tmux starship hyde nvim bin
./bootstrap.sh
```

Then log out and back in, and run `hyde-shell reload` to regenerate the
theme-derived files (see below).

If a target file already exists, stow refuses rather than clobbering it.
Use `stow --adopt <pkg>` to pull the existing file into the repo instead,
then `git diff` to see whether you want the repo's version or the machine's.

## Packages

| Package | Contents |
|---|---|
| `hypr` | `hyprland.lua` (monitor scale, scroll, caps/esc swap), `hyde.conf`, idle/sunset |
| `waybar` | `modules/network-override.json` (wifi picker on click), `user-style.css` |
| `kitty` | `kitty.conf` (padding override) |
| `zsh` | `.hyde.zshrc` (the file HyDE actually sources), `user.zsh`, `.zshrc`, `omz-custom` |
| `tmux` | `.tmux.conf` incl. wallbash theme hook |
| `starship` | `starship.toml` (battery indicator disabled) |
| `hyde` | `config.toml` (animation `duration_scale`), `wallbash/` templates + scripts |
| `nvim` | AstroNvim v6 config |
| `bin` | `wifimenu.sh` — rofi wifi picker used by waybar |

## What is deliberately NOT tracked

HyDE regenerates these from the active wallpaper/theme, so tracking them
produces noise and merge conflicts. They are in `.gitignore` and are rebuilt by
`hyde-shell reload` or any wallpaper change:

- `hypr/themes/`, `hypr/animations.conf`, `hypr/hyprlock.conf`, `hypr/shaders/`
- `waybar/config.jsonc`, `style.css`, `theme.css`, `includes/`, `layouts/`, `menus/`
- `kitty/hyde.conf`, `kitty/theme.conf`
- `~/.config/vim/colors/wallbash.vim` (generated from `hyde/wallbash/always/vim.dcol`)
- zsh caches (`.zcompdump*`, `.zsh_history`) and HyDE-managed `conf.d/`

Also untracked: `~/.config/hyde/themes/` (~310 MB of wallpapers) — reinstall via HyDE.

## Notes / gotchas

- **`.hyde.zshrc` vs `user.zsh`** — HyDE's `conf.d/hyde/terminal.zsh` sources the
  *first* match of `~/.hyde.zshrc`, `~/.user.zsh`, `$ZDOTDIR/user.zsh`. Since
  `~/.hyde.zshrc` exists, it wins and `user.zsh` is never read. Edit `.hyde.zshrc`.
- **Two tracked symlinks use absolute paths** and assume this `$HOME`:
  - `zsh/.config/zsh/omz-custom/plugins/zsh-256color` -> `~/.oh-my-zsh/custom/plugins/zsh-256color`
    (requires a `~/.oh-my-zsh` checkout; it is what fixes the `zsh-256color not found` warning)
  - `nvim/.config/nvim/colors/wallbash.vim` -> `~/.config/vim/colors/wallbash.vim`
    (generated; create `~/.config/vim/colors/` then run `hyde-shell reload`)
- **nvim plugins** are restored by lazy from `lazy-lock.json` on first launch.
