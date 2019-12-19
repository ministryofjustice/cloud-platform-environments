require "bundler/setup"
require "kubeclient"
require "open3"
require "open-uri"
require "aws-sdk-s3"

class CpEnv
end

require File.join(File.dirname(__FILE__), "cp_env", "executor")
require File.join(File.dirname(__FILE__), "cp_env", "pipeline")
require File.join(File.dirname(__FILE__), "cp_env", "terraform")
require File.join(File.dirname(__FILE__), "cp_env", "namespace_deleter")
require File.join(File.dirname(__FILE__), "cp_env", "kubeconfig")

# TODO: Move gpg stuff into CpEnv
require File.join(File.dirname(__FILE__), "gitops_gpg_keypair")
require File.join(File.dirname(__FILE__), "gpg_keypair")
