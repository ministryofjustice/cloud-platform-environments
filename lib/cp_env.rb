require "bundler/setup"
require "aws-sdk-s3"
require "kubeclient"
require "open-uri"
require "open3"
require 'base64'
require 'json'

class CpEnv
end

require File.join(File.dirname(__FILE__), "cp_env", "executor")
require File.join(File.dirname(__FILE__), "cp_env", "pipeline")
require File.join(File.dirname(__FILE__), "cp_env", "terraform")
require File.join(File.dirname(__FILE__), "cp_env", "namespace_deleter")
require File.join(File.dirname(__FILE__), "cp_env", "kubeconfig")
require File.join(File.dirname(__FILE__), "cp_env", "gitops_gpg_keypair")

# TODO: Move gpg stuff into CpEnv
require File.join(File.dirname(__FILE__), "gpg_keypair")
