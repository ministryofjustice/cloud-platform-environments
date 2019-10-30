#!/usr/bin/env ruby

# TODO: default
# TODO: question N of M
# TODO: create the main.tf
# TODO: validate answers
# TODO: block progress until a good answer is provided
# TODO: check namespace name is available
# TODO: remove old terraform stuff from namespace-resources/
# TODO: accomodate the gitops work Jason & Raz are doing

TEMPLATES_DIR = "namespace-resources"
NAMESPACES_DIR = "namespaces/live-1.cloud-platform.service.justice.gov.uk"

QUESTIONS = [
  {
    variable: "namespace",
    description: "What is the name of your namespace? This should be of the form: <application>-<environment>. e.g. myapp-dev (lower-case letters and dashes only)",
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
    default: "false"
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

def create_namespace_files(answers)
  namespace = answers.fetch("namespace")
  dir = File.join(NAMESPACES_DIR, namespace)
  system("mkdir #{dir}")
  yaml_templates.each { |template| create_file(template, dir, answers) }
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
  content.gsub(str, value)
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
  answers[var] = prompt(question)
end

def prompt(question)
  desc = question.fetch(:description)
  var = question.fetch(:variable)
  puts
  puts desc
  puts
  print "#{var}: "
  gets.strip
end

############################################################

create_namespace_files get_answers
