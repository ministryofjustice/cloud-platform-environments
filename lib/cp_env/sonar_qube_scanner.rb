class CpEnv
 
  class SonarQubeScanner
    attr_reader :executor, :dry_run

    def initialize(args = {})
      @executor = args.fetch(:executor) { Executor.new }
      @dry_run = args.fetch(:dry_run, false)
    end

    def scan_all_repos
      scan
    end

    private

    def get_namespaces
      stdout, _stderr, _status = executor.execute("kubectl get ns -o json", silent: true)
      namespaces = JSON.parse(stdout).fetch("items")
    end 

    def get_repos
      repo_full_url = get_namespaces.map {|namespace| namespace.dig('metadata','annotations','cloud-platform.justice.gov.uk/source-code') }.compact.uniq
    end


    def scan
      get_repos.each do |each_repo_url|
        each_repo_url_list = each_repo_url.split('/')
        repo_name = ""
        repo_name = each_repo_url_list.last
        # some repo urls have .git at the end. So we need to strip it out if it exists.
        repo_name_with_git_suffix = repo_name.split('.')
        if repo_name_with_git_suffix.count > 1 # then this repo url has .file_format (e.g .git, .tf etc) suffixed in the end
          repo_name = repo_name_with_git_suffix.first
          # If the suffix is anything other than .git then skip to next iteration as it is an invalid url
          if repo_name_with_git_suffix[1] != 'git'
            next
          end
        end 
        puts 'REPO NAME: '+repo_name
        repo_url_with_token = 'https://'+ENV["GITHUB_TOKEN_PUB_ONLY"]+'@github.com/ministryofjustice/'+repo_name+'.git'
        system("(git clone #{repo_url_with_token})")
        if $?.exitstatus != 0 # If exit code is anything other than 0 then the reop is invalid, private or already cloned. Skip to next.
          pp 'INVALID REPO'
          pp 'The repo '+repo_name+' is private, invalid or already cloned'
        else
          system("(cd #{repo_name})")
          puts 'SCANNING REPO: '+repo_name
          system("(sonar-scanner -Dsonar.projectKey=#{repo_name} -Dsonar.sources=. -Dsonar.host.url=#{ENV["SONARQUBE_HOST_URL"]} -Dsonar.login=#{ENV["SONARQUBE_TOKEN"]})")
          system("(cd ..)")
          system("(rm -rf #{repo_name})") 
        end
      end
    end
  end
end
