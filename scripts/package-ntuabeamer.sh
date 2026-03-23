#!/usr/bin/env sh
set -eu

repo_root=$(
  CDPATH= cd -- "$(dirname -- "$0")/.." && pwd
)

src_dir="$repo_root/latex/framework/ntua-beamer"
dist_dir="$repo_root/dist"
modular_dir="$dist_dir/ntuabeamer-modular"
standalone_dir="$dist_dir/ntuabeamer-standalone"

rm -rf "$modular_dir" "$standalone_dir"
mkdir -p "$modular_dir" "$standalone_dir"

cp "$src_dir/ntuabeamer.cls" "$src_dir/ntuabeamer.sty" "$src_dir/macros.tex" "$src_dir/theme.tex" "$modular_dir/"
cp "$src_dir"/assets/* "$modular_dir"/

{
  printf '%s\n' '\NeedsTeXFormat{LaTeX2e}'
  printf '%s\n' '\ProvidesClass{ntuabeamer}[2026/03/23 NTUA Beamer standalone class]'
  sed '1,2d;/^\\RequirePackage{ntuabeamer}$/d' "$src_dir/ntuabeamer.cls"
  printf '\n%s\n' '%% Inlined from ntuabeamer.sty'
  sed '1,2d;/^\\input{macros.tex}$/d;/^\\input{theme.tex}$/d' "$src_dir/ntuabeamer.sty"
  printf '\n%s\n' '%% Inlined from macros.tex'
  cat "$src_dir/macros.tex"
  printf '\n%s\n' '%% Inlined from theme.tex'
  cat "$src_dir/theme.tex"
} > "$standalone_dir/ntuabeamer.cls"
