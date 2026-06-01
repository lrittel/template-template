#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME <template> <subcommand> [args...]

Wrapper around copier that pre-fills the template path as the first positional
argument to the given subcommand.

Arguments:
  template      Path or URL to the copier template (required)

Subcommands:
  copy          Copy the template to a destination directory
  update        Update a copy from the template
  recopy        Recopy the template into an existing destination
  migrate       Migrate a copy to a new template

Options:
  -h, --help    Show this help message and exit

All arguments after <template> (except the subcommand itself) are passed
through verbatim to copier.

Examples:
  $SCRIPT_NAME ./my-template copy ./my-project
  $SCRIPT_NAME ./my-template copy ./my-project --data author=Jane
  $SCRIPT_NAME gh:org/template update --defaults
  $SCRIPT_NAME ./my-template recopy --overwrite
EOF
}

if [[ $# -eq 0 ]] || [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

TEMPLATE="$1"
shift

if [[ $# -eq 0 ]]; then
    echo "$SCRIPT_NAME: subcommand required" >&2
    echo "Run '$SCRIPT_NAME --help' for usage." >&2
    exit 1
fi

SUBCOMMAND="$1"
shift

case "$SUBCOMMAND" in
    copy)
        exec copier "$SUBCOMMAND" "$TEMPLATE" "$@"
        ;;
    update | recopy | migrate)
        exec copier "$SUBCOMMAND" "$@"
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        echo "$SCRIPT_NAME: unknown subcommand '$SUBCOMMAND'" >&2
        echo "Valid subcommands: copy, update, recopy, migrate" >&2
        exit 1
        ;;
esac
