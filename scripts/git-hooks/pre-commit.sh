#!/usr/bin/env bash

set -e

# Enable extended globbing for Bash pattern matching.
shopt -s extglob

cleanup_backup() {
  local backup_file="$1"
  [[ -f ${backup_file} ]] && rm -f "${backup_file}"
}

restore_from_backup() {
  local original_file="$1"
  local backup_file="$2"
  [[ -f ${backup_file} ]] && mv "${backup_file}" "${original_file}"
}

# Validate file path for security (prevents directory traversal).
validate_file_path() {
  local file="$1"

  if [[ ${file} == *..* || ${file} == /* ]]; then
    echo "    ⚠️  Skipping invalid file path: ${file}"
    return 1
  fi
  return 0
}

format_file_with_backup() {
  local file="$1"
  local file_type="$2"
  local format_cmd="$3"
  local backup_file="$4"
  local temp_output

  temp_output=$(eval "${format_cmd} \"${file}\"" 2>&1)
  if eval "${format_cmd} \"${file}\"" > /dev/null 2>&1; then
    if ! cmp -s "${file}" "${backup_file}"; then
      echo "    📐 Formatted: ${file}"
      files_changed=true
      git add "${file}"
    fi
  else
    restore_from_backup "${file}" "${backup_file}"
    echo "    ❌ Error: Format failed for ${file}"
    [[ -n ${temp_output} ]] && echo "    Error details: ${temp_output}"
    echo "💡 Check ${file_type,,} syntax and try again."
    exit 1
  fi
}

lint_file_with_backup() {
  local file="$1"
  local file_type="$2"
  local lint_cmd="$3"
  local backup_file="$4"
  local temp_output

  temp_output=$(eval "${lint_cmd} \"${file}\"" 2>&1)
  if eval "${lint_cmd} \"${file}\"" > /dev/null 2>&1; then
    cleanup_backup "${backup_file}"
  else
    restore_from_backup "${file}" "${backup_file}"
    echo "    ❌ Error: Lint failed for ${file}"
    [[ -n ${temp_output} ]] && echo "    Error details: ${temp_output}"
    echo "💡 Fix ${file_type,,} linting issues and try again."
    exit 1
  fi
}

process_file_with_backup() {
  local file="$1"
  local file_type="$2"
  local format_cmd="$3"
  local lint_cmd="$4"

  # Use process ID and timestamp for unique backup filename
  local backup_file
  backup_file="${file}.backup.$(date +%s).$$"

  echo "  🔧 Processing ${file_type}: ${file}"
  cp "${file}" "${backup_file}"

  format_file_with_backup "${file}" "${file_type}" "${format_cmd}" "${backup_file}"
  lint_file_with_backup "${file}" "${file_type}" "${lint_cmd}" "${backup_file}"
}

cleanup_on_exit() {
  echo -e "\n🧹 Cleaning up backup files..."
  find . -name "*.backup.*" -type f -delete 2> /dev/null || true
}

is_shell_script() {
  local file="$1"

  # Use Bash pattern matching - all shell scripts should have proper extensions.
  [[ "${file}" == *.@(sh|bash) ]]
}

# Set up trap handlers for safe cleanup on interruption
trap cleanup_on_exit EXIT INT TERM

echo "🔧 Running code quality checks..."

staged_files=$(git diff --cached --name-only --diff-filter=ACM || true)
staged_gd_files=$(echo "${staged_files}" | grep '\.gd$' || true)
staged_shell_files=()
if [ -n "${staged_files}" ]; then
  while IFS= read -r file; do
    if [ -n "${file}" ] && is_shell_script "${file}"; then
      staged_shell_files+=("${file}")
    fi
  done <<< "${staged_files}"
fi

if [[ -z ${staged_gd_files} && ${#staged_shell_files[@]} -eq 0 ]]; then
  echo "ℹ️  No files to check"
  exit 0
fi

gd_count=0
shell_count=${#staged_shell_files[@]}
if [[ -n ${staged_gd_files} ]]; then
  gd_count=$(echo "${staged_gd_files}" | wc -l)
fi

file_summary=()
[[ ${gd_count} -gt 0 ]] && file_summary+=("${gd_count} GDScript files")
[[ ${shell_count} -gt 0 ]] && file_summary+=("${shell_count} shell scripts")

if [[ ${#file_summary[@]} -gt 0 ]]; then
  printf "📝 Checking %s...\n" "$(printf '%s and ' "${file_summary[@]}" | sed 's/ and $//')"
fi

tools_missing=false

if [[ -n ${staged_gd_files} ]]; then
  if ! command -v gdformat &> /dev/null || ! command -v gdlint &> /dev/null; then
    echo "❌ Error: gdtoolkit not installed."
    echo "💡 See CONTRIBUTING.md for installation instructions."
    echo "💡 Install with: pip install \"gdtoolkit==4.*\"."
    tools_missing=true
  fi
fi

if [[ ${#staged_shell_files[@]} -gt 0 ]]; then
  if ! command -v shfmt &> /dev/null; then
    echo "❌ Error: shfmt not installed."
    echo "💡 Install with: go install mvdan.cc/sh/v3/cmd/shfmt@latest."
    tools_missing=true
  fi

  if ! command -v shellcheck &> /dev/null; then
    echo "❌ Error: shellcheck not installed."
    echo "💡 Install with package manager (apt install shellcheck, brew install shellcheck, etc.)."
    tools_missing=true
  fi
fi

if [[ ${tools_missing} == true ]]; then
  exit 1
fi

process_gdscript_file() {
  local file="$1"
  process_file_with_backup "${file}" "GDScript" "gdformat" "gdlint"
}

process_shell_file() {
  local file="$1"
  process_file_with_backup "${file}" "shell script" "shfmt -i 2 -bn -ci -sr -w" "shellcheck --enable=require-variable-braces"
}

files_changed=false

if [[ -n ${staged_gd_files} ]]; then
  while IFS= read -r file; do
    if [[ -n ${file} ]] && validate_file_path "${file}" && [[ -f ${file} ]]; then
      process_gdscript_file "${file}"
    fi
  done <<< "${staged_gd_files}"
fi

if [[ ${#staged_shell_files[@]} -gt 0 ]]; then
  for file in "${staged_shell_files[@]}"; do
    if [[ -n ${file} ]] && validate_file_path "${file}" && [[ -f ${file} ]]; then
      process_shell_file "${file}"
    fi
  done
fi

if [[ ${files_changed} == true ]]; then
  echo "✅ Files formatted and staged. Commit will proceed."
else
  echo "✅ All files passed formatting and linting checks."
fi

echo "🎉 Code quality checks completed successfully!"
