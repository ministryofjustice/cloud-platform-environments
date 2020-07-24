#!/usr/bin/env ruby

# Attempts to provide a consistent answer to the question "What services are
# hosted on the cloud platform?"

# NB: This is only an estimate. There is a many to many relationship between
# production namespaces and "services", so it's very hard to produce an
# accurate figure.

require "open3"

# These namespaces have "is-production: true", but they're system namespaces, not services
# 'probation' just holds some zone data, ditto "nomis" and "prison", "hmpps".
PRODUCTION_NAMESPACES_TO_IGNORE = %w(
  authorized-keys-provider
  cloud-platform-bots
  kiam
  kuberos
  monitoring
  probation
  nomis
  prison
  hmpps
)

# Remove all of these to get the name of the actual service
SUFFIXES = [
  %r[-prod.*],
  %r[-preprod.*],
  %r[-api.*],
  %r[-metabase.*],
  %r[-ui.*],
  %r[-frontend.*],
  %r[-backend.*],
]

cmd = "grep -l 'is-production.*true' namespaces/live-1.cloud-platform.service.justice.gov.uk/*/00-namespace.yaml"
stdout, _, _ = Open3.capture3(cmd)

production_namespaces = stdout.split("\n")

filtered = production_namespaces
  .map { |ns| ns.sub(/.*gov.uk./, '').sub(/\/.*/, '') }
  .map { |ns| ns.sub(%r[-prod.*], '') }
  .map { |ns| ns.sub(/formbuilder.*/, "formbuilder") } # formbuilder is a special case

SUFFIXES.each do |suffixre|
  filtered = filtered.map { |ns| ns.sub(suffixre, '') }
end

filtered
  .reject { |ns| PRODUCTION_NAMESPACES_TO_IGNORE.include?(ns) }
  .uniq
  .map { |service| puts service }

