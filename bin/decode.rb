#!/usr/bin/env ruby

# Given the yaml representation of a kubernetes secret on stdin,
# base64 decode its data and re-output as yaml
#
# USAGE:
#
#     kubectl -n [namespace] get secret [secret] -o yaml | ./bin/decode_secret.rb

require 'yaml'
require 'base64'

hash = YAML.load($stdin.read)
hash["data"] = hash.fetch("data").transform_values! { |v| Base64.decode64(v) }

puts hash.to_yaml
