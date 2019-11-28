#!/usr/bin/env ruby

# TODO: default
# TODO: question N of M
# TODO: validate answers
# TODO: check namespace name is available
# TODO: remove old terraform stuff from namespace-resources/
# TODO: accomodate the gitops work Jason & Raz are doing
# TODO: mount user's home directory into the tools image, so we can write deployment files to their working copy of their app.

TEMPLATES_DIR = "namespace-resources"
NAMESPACES_DIR = "namespaces/live-1.cloud-platform.service.justice.gov.uk"

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

create_namespace_files get_answers
