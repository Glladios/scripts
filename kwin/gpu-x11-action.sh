#!/bin/bash
# uso: ~/gpu-x11-action.sh          -> todos os Flatpaks
#      ~/gpu-x11-action.sh ID1 ID2  -> só esses
DEST=~/.local/share/applications
mkdir -p "$DEST"
ids=("$@")
[ ${#ids[@]} -eq 0 ] && mapfile -t ids < <(flatpak list --app --columns=application)
for id in "${ids[@]}"; do
  src=$(ls /var/lib/flatpak/exports/share/applications/$id.desktop ~/.local/share/flatpak/exports/share/applications/$id.desktop 2>/dev/null | head -1)
  [ -z "$src" ] && { echo "sem .desktop: $id"; continue; }
  dst="$DEST/$id.desktop"
  cp -L "$src" "$dst"
  gpu_exec=$(grep -m1 '^Exec=' "$dst" | sed -E 's#^Exec=([^ ]*flatpak) run #Exec=switcherooctl launch -g 1 \1 run --nosocket=wayland --socket=x11 #')
  if grep -q '^Actions=' "$dst"; then
    sed -i -E '/^Actions=/ s/;?$/;gpux11;/' "$dst"
  else
    sed -i '0,/^\[Desktop Entry\]/ s//[Desktop Entry]\nActions=gpux11;/' "$dst"
  fi
  printf '\n[Desktop Action gpux11]\nName=Executar com GPU dedicada (X11)\n%s\n# gpu-x11-action\n' "$gpu_exec" >> "$dst"
  echo "ok: $id"
done
update-desktop-database "$DEST" 2>/dev/null
kbuildsycoca6 2>/dev/null
