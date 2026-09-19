# dotfiles

Config for an Arch + Hyprland (HyDE) setup, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Each top-level directory is a **stow package** whose inner tree mirrors `$HOME`.
`stow hypr` symlinks `hypr/.config/hypr/*` to `~/.config/hypr/*`.

## Restore on a new machine

This repo alone is NOT a full system image -- it holds configuration, plus
manifests for everything else. Order matters, so `install.sh` is split into
steps rather than one blind command:

```sh
git clone <this-repo> ~/dotfiles && cd ~/dotfiles
./install.sh packages    # yay, then repo + AUR packages from packages/
./install.sh hyde        # clone HyDE, then run ITS interactive installer
./install.sh dotfiles    # stow this repo over HyDE's defaults, then bootstrap
./install.sh services    # re-enable the systemd units
./install.sh extras      # npm globals, go binaries, conda env
./install.sh tools       # oh-my-zsh, nvim plugins (lazy-lock), Mason tools
```

**`chaotic-aur` is required.** 19 explicitly-installed packages come from it
(`packages/requires-chaotic-aur.txt`) -- brave-bin, zen-browser-bin,
google-chrome, anaconda and others. A fresh Arch install does not have that
repo, so `install.sh packages` sets it up (key, mirrorlist, pacman.conf) before
installing anything.

Log out and back in, then `hyde-shell reload` to regenerate the theme-derived
files.

**HyDE must be installed before stowing.** Its installer writes its own
`~/.config/hypr`, `~/.config/waybar` etc.; stowing afterwards replaces the ones
this repo owns. `install.sh dotfiles` uses `stow --adopt`, so run `git diff`
after and `git checkout .` to keep this repo's versions.

### What is tracked vs. rebuilt vs. gone

| | where it comes from |
|---|---|
| Your configs | this repo (`stow`) |
| ~199 packages, 12 AUR | `packages/*.txt` |
| 14 system + 6 user services | `packages/services-*.txt` |
| HyDE framework, themes, wallpapers (~500 MB) | HyDE's installer |
| nvim plugins | `lazy-lock.json` (exact revisions) |
| Mason LSP servers / linters (~640 MB) | `install.sh tools` |
| oh-my-zsh + zsh-256color | `install.sh tools` |
| 10 npm globals, `kind` (go), conda `backend-env` | `packages/npm-global.txt`, `go-bin.txt`, `conda-backend-env.yml` |
| **Not covered:** `/etc`, partitioning, bootloader, users, secrets, SSH keys | you |
| **Not covered:** `/opt/containerd` (manual), AppImages (Pencil, Cursor) | you |

### Package channels audited

Everything below was checked, so the manifests are not just "whatever pacman knew":

| channel | found |
|---|---|
| pacman explicit | 199 (187 native incl. 19 chaotic-aur, 12 AUR) |
| npm global | 10 |
| go install | 1 (`kind`) |
| conda envs | 1 user env (`backend-env`); base belongs to the `anaconda` package |
| pipx / uv / cargo / flatpak | none installed |
| `~/.local/bin` | 41 executables, nearly all pip shims from `/opt/anaconda` |
| `/opt` | all pacman-owned except `containerd` |

If a target file already exists, stow refuses rather than clobbering it.
Use `stow --adopt <pkg>` to pull the existing file into the repo instead,
then `git diff` to see whether you want the repo's version or the machine's.

## Packages

| Package    | Contents                                                                           |
| ---------- | ---------------------------------------------------------------------------------- |
| `hypr`     | `hyprland.lua` (monitor scale, scroll, caps/esc swap), `hyde.conf`, idle/sunset    |
| `waybar`   | `modules/network-override.json` (wifi picker on click), `user-style.css`           |
| `kitty`    | `kitty.conf` (padding override)                                                    |
| `zsh`      | `.hyde.zshrc` (the file HyDE actually sources), `user.zsh`, `.zshrc`, `omz-custom` |
| `tmux`     | `.tmux.conf` incl. wallbash theme hook                                             |
| `starship` | `starship.toml` (battery indicator disabled)                                       |
| `hyde`     | `config.toml` (animation `duration_scale`), `wallbash/` templates + scripts        |
| `nvim`     | AstroNvim v6 config                                                                |
| `bin`      | `wifimenu.sh` — rofi wifi picker used by waybar                                    |

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
  _first_ match of `~/.hyde.zshrc`, `~/.user.zsh`, `$ZDOTDIR/user.zsh`. Since
  `~/.hyde.zshrc` exists, it wins and `user.zsh` is never read. Edit `.hyde.zshrc`.
- **Two tracked symlinks use absolute paths** and assume this `$HOME`:
  - `zsh/.config/zsh/omz-custom/plugins/zsh-256color` -> `~/.oh-my-zsh/custom/plugins/zsh-256color`
    (requires a `~/.oh-my-zsh` checkout; it is what fixes the `zsh-256color not found` warning)
  - `nvim/.config/nvim/colors/wallbash.vim` -> `~/.config/vim/colors/wallbash.vim`
    (generated; create `~/.config/vim/colors/` then run `hyde-shell reload`)
- **nvim plugins** are restored by lazy from `lazy-lock.json` on first launch.
