#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <assessment.yaml>" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 2
fi

assessment_file="$1"
schema_file="$(dirname "$0")/ticket-schema.yaml"

if [[ ! -f "$assessment_file" ]]; then
  echo "Assessment file not found: $assessment_file" >&2
  exit 2
fi

if [[ ! -f "$schema_file" ]]; then
  echo "Assessment schema not found: $schema_file" >&2
  exit 2
fi

ruby - "$assessment_file" "$schema_file" <<'RUBY'
require "yaml"

assessment_path, schema_path = ARGV

def load_yaml(path)
  YAML.safe_load(
    File.read(path),
    permitted_classes: [],
    permitted_symbols: [],
    aliases: false,
  )
rescue Psych::SyntaxError => e
  warn "Invalid YAML in #{path}: #{e.message}"
  exit 1
end

def fetch_path(document, dotted_path)
  dotted_path.split(".").reduce(document) do |value, key|
    break nil unless value.is_a?(Hash)

    value[key]
  end
end

def missing?(value)
  value.nil? || (value.respond_to?(:empty?) && value.empty?)
end

assessment = load_yaml(assessment_path)
schema = load_yaml(schema_path)
errors = []

schema.fetch("required_fields").each do |field|
  value = fetch_path(assessment, field)
  errors << "Missing required field: #{field}" if missing?(value)
end

status = fetch_path(assessment, "assessment.status")
allowed_statuses = schema.fetch("allowed_statuses")

unless missing?(status) || allowed_statuses.include?(status)
  errors << "Unsupported assessment status: #{status}"
end

unless errors.empty?
  errors.each { |error| warn error }
  exit 1
end
RUBY

echo "Assessment structure is valid: ${assessment_file}"
