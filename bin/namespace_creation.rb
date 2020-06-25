# These questions and classes are used in the namespace creation process by:
#
#   create-namespace-files.rb
#   create-gitops-namespace-files.rb
#

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
    variable: "slack_channel",
    description: "What is the best slack channel to use if we need to contact your team? (If you don't have a team slack channel, please create one)",
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
