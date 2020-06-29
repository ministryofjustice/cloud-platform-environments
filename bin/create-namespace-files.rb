#!/usr/bin/env ruby

require "yaml"
require_relative "./namespace_creation.rb"

# TODO: default
# TODO: question N of M
# TODO: validate answers
# TODO: check namespace name is available
# TODO: remove old terraform stuff from namespace-resources/
# TODO: accomodate the gitops work Jason & Raz are doing
# TODO: mount user's home directory into the tools image, so we can write deployment files to their working copy of their app.

TEMPLATES_DIR = "namespace-resources"
NAMESPACES_DIR = "namespaces/live-1.cloud-platform.service.justice.gov.uk"

############################################################

def create_namespace_files(answers)
  namespace = answers.fetch("namespace")
  dir = File.join(NAMESPACES_DIR, namespace)
  system("mkdir #{dir}")
  yaml_templates.each { |template| create_file(template, dir, answers) }
  copy_terraform_files(namespace)
end

def copy_terraform_files(namespace)
  dir = File.join(NAMESPACES_DIR, namespace)
  system("cp -r namespace-resources/resources #{dir}")
end

def create_file(template, dir, answers)
  content = interpolate(File.read(template), answers)
  outfile = File.join(dir, File.basename(template))
  File.write(outfile, content)
end

def interpolate(content, answers)
  answers.each { |key, value| content = replace_var(content, key, value) }
  content
end

def replace_var(content, key, value)
  str = "${#{key}}"
  lower_str = "${lower(#{key})}"
  content
    .gsub(str, value)
    .gsub(lower_str, value.downcase)
end

def yaml_templates
  Dir["#{TEMPLATES_DIR}/*.yaml"]
end

def get_answers
  answers = {}
  QUESTIONS.map { |question| ask_question(answers, question) }
  answers
end

def ask_question(answers, question)
  var = question.fetch(:variable)
  validator_class = question[:validator]
  good_answer = false

  until good_answer
    answer = prompt(question)

    if validator_class
      validator = validator_class.new
      if validator.is_valid?(answer)
        good_answer = true
      else
        puts "Bad answer: #{validator.error}"
      end
    else
      # No validation for this question
      good_answer = true
    end

    answers[var] = answer
  end
end

def prompt(question)
  desc = question.fetch(:description)
  var = question.fetch(:variable)
  puts
  puts desc
  puts
  print "  #{var}: "
  gets.strip
end

############################################################

# For testing, we can supply on the command-line the name of a YAML
# file containing the answers to the questions above. This enables us
# to run `make namespace` non-interactively, and compare the results
# with a fixture file.
if (filename = ARGV.shift) && FileTest.exists?(filename)
  hash = YAML.load(File.read(filename))
  create_namespace_files hash.fetch("answers")
else
  create_namespace_files get_answers
end
