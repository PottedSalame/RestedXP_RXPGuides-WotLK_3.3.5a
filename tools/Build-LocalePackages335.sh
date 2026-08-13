#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --source <localization checkout> --output <directory> --version <tag> --revision <commit>" >&2
  exit 2
}

source_root=""
output_root=""
version=""
revision=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --source) source_root="${2:-}"; shift 2 ;;
    --output) output_root="${2:-}"; shift 2 ;;
    --version) version="${2:-}"; shift 2 ;;
    --revision) revision="${2:-}"; shift 2 ;;
    *) usage ;;
  esac
done

[[ -n "${source_root}" && -d "${source_root}" ]] || usage
[[ -n "${output_root}" && -n "${version}" && -n "${revision}" ]] || usage
[[ "${version}" =~ ^v?[0-9A-Za-z][0-9A-Za-z._-]*$ ]] || {
  echo "Invalid package version: ${version}" >&2
  exit 1
}
[[ "${revision}" =~ ^[0-9a-f]{40}$ ]] || {
  echo "Invalid localization revision: ${revision}" >&2
  exit 1
}

script_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_root="$(cd "${source_root}" && pwd)"
mkdir -p "${output_root}"
output_root="$(cd "${output_root}" && pwd)"
staging="$(mktemp -d)"
trap 'rm -rf "${staging}"' EXIT

locales=(deDE esES frFR ruRU koKR zhCN zhTW)
for locale in "${locales[@]}"; do
  addon="RXPGuides_Locale_${locale}"
  folder="${staging}/${addon}"
  pack="${source_root}/locale/GuidePack.${locale}.lua"
  [[ -f "${pack}" ]] || {
    echo "Missing compiled locale pack: ${pack}" >&2
    exit 1
  }

  mkdir -p "${folder}"
  cp "${script_root}/packaging/locale/Bootstrap.lua" \
    "${folder}/Bootstrap.lua"
  cp "${pack}" "${folder}/GuidePack.${locale}.lua"
  scripts=("Bootstrap.lua")
  if [[ "${locale}" == "zhCN" ]]; then
    exact="${source_root}/locale/GuideExact.zhCN.lua"
    [[ -f "${exact}" ]] || {
      echo "Missing reviewed zhCN exact catalog: ${exact}" >&2
      exit 1
    }
    cp "${exact}" "${folder}/GuideExact.zhCN.lua"
    scripts+=("GuideExact.zhCN.lua")
  fi
  scripts+=("GuidePack.${locale}.lua")

  toc="${folder}/${addon}.toc"
  {
    printf '## Interface: 30300\n'
    printf '## Title: RestedXP Guides Locale - %s\n' "${locale}"
    printf '## Notes: Optional %s display translations for RXPGuides\n' "${locale}"
    printf '## Author: RestedXP community localization\n'
    printf '## Version: %s\n' "${version}"
    printf '## Dependencies: RXPGuides\n'
    printf '## LoadOnDemand: 1\n'
    printf '## X-RXPGuides-Localization-Commit: %s\n\n' "${revision}"
    printf '%s\n' "${scripts[@]}"
  } > "${toc}"

  archive="${output_root}/${addon}-${version}.zip"
  (
    cd "${staging}"
    zip -q -r "${archive}" "${addon}"
  )
  unzip -Z1 "${archive}" | grep -Fxq \
    "${addon}/${addon}.toc" || {
      echo "Locale package is missing its addon manifest: ${archive}" >&2
      exit 1
    }
  if unzip -Z1 "${archive}" | grep -Evq "^${addon}/"; then
    echo "Locale package contains an entry outside ${addon}: ${archive}" >&2
    exit 1
  fi
  echo "Created $(basename "${archive}")"
done
