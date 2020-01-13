#!/usr/bin/env ruby

require "yaml"
require "fileutils"

# TODO: default
# TODO: question N of M
# TODO: validate answers
# TODO: check namespace name is available
# TODO: remove old terraform stuff from namespace-resources/
# TODO: mount user's home directory into the tools image, so we can write deployment files to their working copy of their app.

TEMPLATES_DIR = "gitops-namespace-resources"
DEPLOY_TEMPLATES_DIR = "#{TEMPLATES_DIR}/kubectl_deploy"
CLUSTER_NAME = "live-1.cloud-platform.service.justice.gov.uk"
NAMESPACES_DIR = "namespaces/#{CLUSTER_NAME}"
WORKING_COPY = FileTest.directory?("/appsrc") ? "/appsrc" : "/tmp" # Use /tmp for tests. /appsrc when in a docker container.
DEPLOYMENT_DIR = "cloud-platform-deploy" # will be created in user's app. working copy

class Validator
  attr_reader :error

  def is_valid?(_value)
    raise "Validator sub-class #{self.class} did not define 'is_valid?' method"
  end
end

class TrueFalseValidator < Validator
  def is_valid?(value)
    return true if %w[true false].include?(value)

    @error = "Answer must be 'true' or 'false'"
    false
  end
end

class NamespaceNameValidator < Validator
  def is_valid?(value)
    return true if /^[a-z\-]+$/.match?(value) && value.count("-") > 0
    @error = "Value must consist of lower-case letters and dashes only"
    false
  end
end

############################################################

def create_namespace_files(answers)
  namespace = answers.fetch("namespace")
  dir = File.join(NAMESPACES_DIR, namespace)
  gitops_dir = File.join(NAMESPACES_DIR, namespace, "gitops-resources")
  system("mkdir -p #{dir}")
  system("mkdir -p #{gitops_dir}")
  yaml_templates.each { |template| create_file(template, dir, answers) }
  gitops_yaml_templates.each { |template| create_file(template, gitops_dir, answers) }
  copy_terraform_files(namespace)

  create_gitops_module(namespace, answers)
  create_cloud_platform_deploy(answers)
end

def copy_terraform_files(namespace)
  dir = File.join(NAMESPACES_DIR, namespace)
  system("cp -r #{TEMPLATES_DIR}/resources #{dir}")
end

def create_gitops_module(namespace, answers)
  dir = File.join(NAMESPACES_DIR, namespace, "resources")
  FileUtils.mkdir_p(dir)
  render_templates(Dir["#{TEMPLATES_DIR}/gitops-resources/*.tf"], dir, answers)
end

def create_cloud_platform_deploy(answers)
  dir = File.join(WORKING_COPY, DEPLOYMENT_DIR, answers.fetch("namespace"))
  FileUtils.mkdir_p(dir)
  # TODO: get the helloworld deployment files from the helloworld repo, so that we stay
  # up to date with any changes.
  render_templates(Dir["#{DEPLOY_TEMPLATES_DIR}/*.yaml"], dir, answers.merge("hostname" => CLUSTER_NAME))
end

def render_templates(files, dir, answers)
  files.each { |template| create_file(template, dir, answers) }
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
  lower_str = "lower(#{key})"
  content
    .gsub(str, value)
    .gsub(lower_str, value.downcase)
end

def yaml_templates
  Dir["#{TEMPLATES_DIR}/*.yaml"]
end

def gitops_yaml_templates
  Dir["#{TEMPLATES_DIR}/gitops-resources/*.yaml"]
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

QUESTIONS = [
  {
    variable: "namespace",
    description: "What is the name of your namespace? This should be of the form: <application>-<environment>. e.g. myapp-dev (lower-case letters and dashes only)",
    validator: NamespaceNameValidator,
  },

  {
    variable: "github_team",
    description: "What is the name of your Github team? (this must be an exact match, or you will not have access to your namespace)",
  },

  {
    variable: "business-unit",
    description: "Which part of the MoJ is responsible for this service? (e.g HMPPS, Legal Aid Agency)",
  },

  {
    variable: "is-production",
    description: "Is this a production namespace? (please answer true or false)",
    default: "false",
    validator: TrueFalseValidator,
  },

  {
    variable: "environment",
    description: "What type of application environment is this namespace for? e.g. development, staging, production",
  },

  {
    variable: "application",
    description: "What is the name of your application/service? (e.g. Send money to a prisoner)",
  },

  {
    variable: "owner",
    description: "Which team in your organisation is responsible for this application? (e.g. Sentence Planning)",
  },

  {
    variable: "contact_email",
    description: "What is the email address for the team which owns the application? (this should not be a named individual's email address)",
  },

  {
    variable: "source_code_url",
    description: "What is the Github repository URL of the source code for this application?",
  },
]

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
