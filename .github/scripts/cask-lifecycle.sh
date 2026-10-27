#!/bin/bash
# Install a cask, then uninstall it with --zap and fail if anything it declares
# survives: apps, package receipts and their files, launchd jobs, login items,
# deleted paths and zap paths. Zap paths are seeded first because the app never
# runs here, so this proves the zap stanza removes them, not that it is complete.
set -euo pipefail

cask="$1"
work="$(mktemp -d)"
info="${work}/info.json"
failures=0

fail() {
  echo "::error::${cask}: $*"
  failures=$((failures + 1))
}

# Every value of one key across a stanza (uninstall or zap), one per line.
values() {
  jq -r --arg stanza "$1" --arg key "$2" '
    .casks[0].artifacts[] | .[$stanza]? // empty | .[] | .[$key]? // empty
    | if type == "array" then .[] else . end' "${info}"
}

expand() {
  local path="$1"
  printf '%s\n' "${path/#\~/${HOME}}"
}

receipts() {
  local pattern
  while IFS= read -r pattern; do
    pkgutil --pkgs | grep -E -- "${pattern}" || true
  done < <(values uninstall pkgutil)
}

launchd_job_exists() {
  local label="$1"
  if [[ "${label}" == *"*"* ]]; then
    launchctl list | awk '{print $3}' | grep -qE -- "^${label//\*/.*}$"
    return
  fi
  launchctl print "gui/$(id -u)/${label}" >/dev/null 2>&1 ||
    sudo launchctl print "system/${label}" >/dev/null 2>&1
}

login_items() {
  osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null |
    tr ',' '\n' | sed 's/^ *//'
}

brew info --json=v2 --cask "${cask}" >"${info}"

brew install --cask "${cask}"

jq -r '.casks[0].artifacts[] | select(.app) | .target' "${info}" >"${work}/apps"
while IFS= read -r app; do
  [[ -e "${app}" ]] || fail "app ${app} missing after install"
done <"${work}/apps"

: >"${work}/receipt-files"
while IFS= read -r pattern; do
  matched="$(pkgutil --pkgs | grep -E -- "${pattern}" || true)"
  [[ -n "${matched}" ]] || fail "no receipt matches pkgutil pattern ${pattern} after install"
  while IFS= read -r receipt; do
    [[ -n "${receipt}" ]] || continue
    volume="$(pkgutil --pkg-info "${receipt}" | awk -F': ' '/^volume:/ {print $2}')"
    location="$(pkgutil --pkg-info "${receipt}" | awk -F': ' '/^location:/ {print $2}')"
    pkgutil --only-files --files "${receipt}" |
      sed "s|^|${volume%/}/${location:+${location%/}/}|" >>"${work}/receipt-files"
  done <<<"${matched}"
done < <(values uninstall pkgutil)

while IFS= read -r path; do
  path="$(expand "${path}")"
  [[ -e "${path}" ]] && continue
  if [[ "${path}" == *.plist ]]; then
    mkdir -p "$(dirname "${path}")" && touch "${path}"
  else
    mkdir -p "${path}"
  fi
done < <(values zap trash)

brew uninstall --cask --zap "${cask}"

[[ ! -e "$(brew --caskroom)/${cask##*/}" ]] || fail "Caskroom entry survived"

while IFS= read -r app; do
  [[ ! -e "${app}" ]] || fail "app ${app} survived uninstall"
done <"${work}/apps"

remaining="$(receipts)"
[[ -z "${remaining}" ]] || fail "receipts survived: ${remaining//$'\n'/ }"

while IFS= read -r path; do
  [[ ! -e "${path}" && ! -L "${path}" ]] || fail "receipt file survived: ${path}"
done <"${work}/receipt-files"

while IFS= read -r label; do
  ! launchd_job_exists "${label}" || fail "launchd job ${label} survived"
  for dir in "${HOME}/Library/LaunchAgents" /Library/LaunchAgents /Library/LaunchDaemons; do
    [[ ! -e "${dir}/${label}.plist" ]] || fail "launchd plist ${dir}/${label}.plist survived"
  done
done < <(values uninstall launchctl; values zap launchctl)

if items="$(login_items)"; then
  while IFS= read -r item; do
    ! grep -qxF -- "${item}" <<<"${items}" || fail "login item ${item} survived"
  done < <(values uninstall login_item)
else
  echo "::warning::${cask}: could not list login items; not checked"
fi

while IFS= read -r path; do
  path="$(expand "${path}")"
  [[ ! -e "${path}" ]] || fail "path ${path} survived"
done < <(values uninstall delete; values zap trash)

exit $((failures > 0))
