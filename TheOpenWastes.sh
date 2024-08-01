#!/bin/sh
echo -ne '\033c\033]0;TheOpenWastes\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/TheOpenWastes.x86_64" "$@"
