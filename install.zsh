#!/usr/bin/env zsh

set -eu

repo=${0:A:h}
config_dir=$HOME/.config

mkdir -p "$config_dir"

sources=(
  dwm
  sxstatus
  .zshrc
  .vimrc
  .xsessionrc
  .config/kitty/kitty.conf
  .config/kitty/current-theme.conf
  .config/mpv/mpv.conf
  .config/mpv/scripts/autosave.lua
  .config/nvim/.gitignore
  .config/nvim/.neoconf.json
  .config/nvim/init.lua
  .config/nvim/lazy-lock.json
  .config/nvim/stylua.toml
  .config/nvim/lua/config/autocmds.lua
  .config/nvim/lua/config/keymaps.lua
  .config/nvim/lua/config/lazy.lua
  .config/nvim/lua/config/options.lua
  .config/nvim/lua/plugins/example.lua
  .config/dunst/dunstrc
  .config/picom/picom-blur.conf
  .config/picom/picom-blurvsync.conf
  .config/picom/picom-opacity.conf
  .config/picom/picom-vsync.conf
  .config/picom/picom.conf
  .config/fastfetch/config.jsonc
  .config/fastfetch/om.txt
  .config/yt-dlp/config
  .config/dmenu/config.h
  .local/bin/theme
  .local/bin/theme-watch
  .local/bin/theme-accent
  .local/bin/theme-neutral
  .local/bin/theme-contrast
  .local/bin/theme-dunst
  .config/wal/templates/dwm-xres
  .config/wal/templates/sxstatus-colors
)

targets=(
  dwm
  sxstatus
  .zshrc
  .vimrc
  .xsessionrc
  .config/kitty/kitty.conf
  .config/kitty/current-theme.conf
  .config/mpv/mpv.conf
  .config/mpv/scripts/autosave.lua
  .config/nvim/.gitignore
  .config/nvim/.neoconf.json
  .config/nvim/init.lua
  .config/nvim/lazy-lock.json
  .config/nvim/stylua.toml
  .config/nvim/lua/config/autocmds.lua
  .config/nvim/lua/config/keymaps.lua
  .config/nvim/lua/config/lazy.lua
  .config/nvim/lua/config/options.lua
  .config/nvim/lua/plugins/example.lua
  .config/dunst/dunstrc
  .config/picom/picom-blur.conf
  .config/picom/picom-blurvsync.conf
  .config/picom/picom-opacity.conf
  .config/picom/picom-vsync.conf
  .config/picom/picom.conf
  .config/fastfetch/config.jsonc
  .config/fastfetch/om.txt
  .config/yt-dlp/config
  .config/dmenu/config.h
  .local/bin/theme
  .local/bin/theme-watch
  .local/bin/theme-accent
  .local/bin/theme-neutral
  .local/bin/theme-contrast
  .local/bin/theme-dunst
  .config/wal/templates/dwm-xres
  .config/wal/templates/sxstatus-colors
)

if (( ${#sources} != ${#targets} )); then
  print -u2 -- "Installer source and target lists do not match."
  exit 1
fi

for (( i = 1; i <= ${#sources}; i++ )); do
  source="$repo/${sources[$i]}"
  target="$HOME/${targets[$i]}"
  if (( i <= 2 )); then
    source="$repo/${targets[$i]}"
  fi
  if [[ -L $target && ${target:A} == ${source:A} ]]; then
    continue
  fi

  if [[ ! -e $source ]]; then
    print -u2 -- "Missing $source. Clone repo with --recurse-submodules or run git submodule update --init --recursive."
    exit 1
  fi

  if [[ -L $target ]]; then
    print -u2 -- "Refusing unrelated symlink: $target -> ${target:A}"
    exit 1
  fi

  if [[ -e $target ]]; then
    print -u2 -- "Refusing to replace existing path: $target"
    print -u2 -- "Back it up or move it aside, then rerun this installer."
    exit 1
  fi
done

for (( i = 1; i <= ${#sources}; i++ )); do
  source="$repo/${sources[$i]}"
  target="$HOME/${targets[$i]}"
  if (( i <= 2 )); then
    source="$repo/${targets[$i]}"
  fi
  if [[ -L $target && ${target:A} == ${source:A} ]]; then
    print -- "Already linked: $target"
    continue
  fi
  mkdir -p "${target:h}"
  ln -s "$source" "$target"
  print -- "Linked $target -> $source"
done
