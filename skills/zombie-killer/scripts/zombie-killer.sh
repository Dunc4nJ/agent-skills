#!/usr/bin/env bash
# zombie-killer.sh — Detect, report, and kill zombie processes
# Usage: zombie-killer.sh [scan|kill|install-cron|uninstall-cron]
set -euo pipefail

ACTION="${1:-scan}"
ALERT_LOG="$HOME/.zombie-alerts.log"
THRESHOLD="${ZOMBIE_THRESHOLD:-5}"

# ── Helpers ──────────────────────────────────────────────────────────

zombies() {
  ps -eo pid,ppid,stat,user,comm 2>/dev/null | awk '$3 ~ /^Z/'
}

zombie_count() {
  local count
  count=$(zombies | wc -l)
  echo "$count"
}

zombie_parents() {
  # Returns: count parent_pid parent_comm
  zombies | awk '{print $2}' | sort | uniq -c | sort -rn | while read -r count ppid; do
    pcomm=$(ps -p "$ppid" -o comm= 2>/dev/null || echo "<exited>")
    printf "%4d  PID %-8s  %s\n" "$count" "$ppid" "$pcomm"
  done
}

log_alert() {
  echo "[$(date -Iseconds)] $*" >> "$ALERT_LOG"
}

# ── Actions ──────────────────────────────────────────────────────────

cmd_scan() {
  local count
  count=$(zombie_count)
  echo "=== Zombie Process Report ==="
  echo "Count: $count"
  echo ""

  if [ "$count" -eq 0 ]; then
    echo "No zombie processes found. System is clean."
    return 0
  fi

  echo "Parent processes holding zombies:"
  echo "  Count  Parent PID   Command"
  echo "  -----  ----------   -------"
  zombie_parents
  echo ""

  echo "Zombie details:"
  echo "  PID      PPID     STAT  USER       COMMAND"
  echo "  -------  -------  ----  ---------  -------"
  zombies | awk '{printf "  %-7s  %-7s  %-4s  %-9s  %s\n", $1, $2, $3, $4, $5}'
  echo ""

  if [ "$count" -ge "$THRESHOLD" ]; then
    echo "WARNING: Zombie count ($count) >= threshold ($THRESHOLD)"
    echo "Run: zombie-killer.sh kill   — to kill parent processes and reap zombies"
  fi
}

cmd_kill() {
  local count
  count=$(zombie_count)

  if [ "$count" -eq 0 ]; then
    echo "No zombie processes to clean up."
    return 0
  fi

  echo "Found $count zombie(s). Identifying parent processes..."
  echo ""

  # Collect unique parent PIDs
  local parent_pids
  parent_pids=$(zombies | awk '{print $2}' | sort -u)

  # Exclude our own process tree
  local my_pid=$$
  local my_ppid
  my_ppid=$(ps -o ppid= -p $my_pid 2>/dev/null | tr -d ' ')

  local killed=0
  local skipped=0

  for ppid in $parent_pids; do
    # Skip init/systemd
    if [ "$ppid" -le 1 ]; then
      echo "  SKIP PID $ppid (init/systemd — zombies will be reaped on parent exit)"
      skipped=$((skipped + 1))
      continue
    fi

    # Skip our own tree
    if [ "$ppid" = "$my_pid" ] || [ "$ppid" = "$my_ppid" ]; then
      echo "  SKIP PID $ppid (own process tree)"
      skipped=$((skipped + 1))
      continue
    fi

    local pcomm
    pcomm=$(ps -p "$ppid" -o comm= 2>/dev/null || echo "<exited>")
    local zcount
    zcount=$(zombies | awk -v p="$ppid" '$2 == p' | wc -l)

    echo "  Killing PID $ppid ($pcomm) — holding $zcount zombie(s)..."
    if kill "$ppid" 2>/dev/null; then
      killed=$((killed + 1))
      log_alert "Killed parent PID $ppid ($pcomm) holding $zcount zombies"
    else
      echo "    SIGTERM failed, trying SIGKILL..."
      if kill -9 "$ppid" 2>/dev/null; then
        killed=$((killed + 1))
        log_alert "Force-killed parent PID $ppid ($pcomm) holding $zcount zombies"
      else
        echo "    Could not kill PID $ppid (may need root)"
      fi
    fi
  done

  echo ""
  sleep 2
  local remaining
  remaining=$(zombie_count)
  echo "Result: killed $killed parent(s), skipped $skipped, zombies remaining: $remaining"
  log_alert "Cleanup: killed=$killed skipped=$skipped before=$count after=$remaining"
}

cmd_install_cron() {
  local script_path
  script_path="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  local cron_line="*/30 * * * * $script_path cron-check >> $ALERT_LOG 2>&1"

  # Check if already installed
  if crontab -l 2>/dev/null | grep -qF "zombie-killer"; then
    echo "Cron job already installed. Current entry:"
    crontab -l | grep "zombie-killer"
    return 0
  fi

  (crontab -l 2>/dev/null; echo "$cron_line") | crontab -
  echo "Cron job installed (runs every 30 minutes):"
  echo "  $cron_line"
  echo ""
  echo "Alerts logged to: $ALERT_LOG"
  echo "Threshold: $THRESHOLD zombies (set ZOMBIE_THRESHOLD to change)"
}

cmd_uninstall_cron() {
  if ! crontab -l 2>/dev/null | grep -qF "zombie-killer"; then
    echo "No zombie-killer cron job found."
    return 0
  fi

  crontab -l 2>/dev/null | grep -vF "zombie-killer" | crontab -
  echo "Cron job removed."
}

cmd_cron_check() {
  # Silent check used by cron — only logs if threshold exceeded
  local count
  count=$(zombie_count)
  if [ "$count" -ge "$THRESHOLD" ]; then
    log_alert "ALERT: $count zombie processes detected (threshold: $THRESHOLD)"
    # Log parent details
    zombie_parents | while IFS= read -r line; do
      log_alert "  Parent: $line"
    done
  fi
}

cmd_status() {
  echo "=== Zombie Killer Status ==="
  echo "Threshold: $THRESHOLD"
  echo "Alert log: $ALERT_LOG"
  echo ""

  if crontab -l 2>/dev/null | grep -qF "zombie-killer"; then
    echo "Cron: INSTALLED"
    crontab -l | grep "zombie-killer" | sed 's/^/  /'
  else
    echo "Cron: NOT installed (run: zombie-killer.sh install-cron)"
  fi

  echo ""
  echo "Current zombies: $(zombie_count)"

  if [ -f "$ALERT_LOG" ]; then
    local lines
    lines=$(wc -l < "$ALERT_LOG")
    echo ""
    echo "Recent alerts ($lines total):"
    tail -5 "$ALERT_LOG" | sed 's/^/  /'
  fi
}

# ── Dispatch ─────────────────────────────────────────────────────────

case "$ACTION" in
  scan)             cmd_scan ;;
  kill)             cmd_kill ;;
  install-cron)     cmd_install_cron ;;
  uninstall-cron)   cmd_uninstall_cron ;;
  cron-check)       cmd_cron_check ;;
  status)           cmd_status ;;
  *)
    echo "Usage: zombie-killer.sh [scan|kill|install-cron|uninstall-cron|status]"
    echo ""
    echo "Commands:"
    echo "  scan            Show zombie processes and their parents (default)"
    echo "  kill            Kill parent processes to reap zombies"
    echo "  install-cron    Install cron job to check every 30 minutes"
    echo "  uninstall-cron  Remove the cron job"
    echo "  status          Show config, cron state, and recent alerts"
    exit 1
    ;;
esac
