#!/usr/bin/env bash
set -eo pipefail

echo "==> Running AzerothCore database import..."
/azerothcore/env/dist/bin/dbimport

echo "==> Applying module SQL files..."

apply_sql_dir() {
  local dir="$1" host="$2" port="$3" user="$4" pass="$5" db="$6"
  [ -d "$dir" ] || return 0
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    echo "  >> $(basename "$f")"
    mysql -h"$host" -P"$port" -u"$user" -p"$pass" --force "$db" < "$f" 2>&1 \
      | grep -Ev "^$|mysql: \[Warning\]" || true
  done < <(find "$dir" -name "*.sql" -type f | sort)
}

IFS=';' read -r whost wport wuser wpass wdb <<< "${AC_WORLD_DATABASE_INFO}"
IFS=';' read -r ahost aport auser apass adb <<< "${AC_LOGIN_DATABASE_INFO}"
IFS=';' read -r chost cport cuser cpass cdb <<< "${AC_CHARACTER_DATABASE_INFO}"

# mod-ah-bot
apply_sql_dir "/azerothcore/modules/mod-ah-bot/data/sql/db-world/" \
  "$whost" "$wport" "$wuser" "$wpass" "$wdb"

# mod-solocraft
apply_sql_dir "/azerothcore/modules/mod-solocraft/data/sql/db-world/" \
  "$whost" "$wport" "$wuser" "$wpass" "$wdb"
apply_sql_dir "/azerothcore/modules/mod-solocraft/data/sql/db-characters/" \
  "$chost" "$cport" "$cuser" "$cpass" "$cdb"

# mod-individual-progression (base tables first, then incremental updates)
apply_sql_dir "/azerothcore/modules/mod-individual-progression/data/sql/world/base/" \
  "$whost" "$wport" "$wuser" "$wpass" "$wdb"
apply_sql_dir "/azerothcore/modules/mod-individual-progression/data/sql/world/updates/" \
  "$whost" "$wport" "$wuser" "$wpass" "$wdb"
apply_sql_dir "/azerothcore/modules/mod-individual-progression/data/sql/auth/updates/" \
  "$ahost" "$aport" "$auser" "$apass" "$adb"
apply_sql_dir "/azerothcore/modules/mod-individual-progression/data/sql/characters/updates/" \
  "$chost" "$cport" "$cuser" "$cpass" "$cdb"

echo "==> Module SQL import complete!"
