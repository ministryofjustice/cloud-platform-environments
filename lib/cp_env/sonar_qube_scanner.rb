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
  
    def get_repos_ministryofjustice_org
      repo_urls_ministry_org_only = []
      get_repos.each do |each_repo_url|
        split_repo_url = each_repo_url.split('/')
        if split_repo_url[3] == 'ministryofjustice' # only if the repo is in the ministryofjustice org then add it to the new array.
          repo_urls_ministry_org_only.push(each_repo_url)
        end
      end
      return repo_urls_ministry_org_only
    end

    def scantest
      pp get_repos_ministryofjustice_org
    end

    def scan
      get_repos_ministryofjustice_org.each do |each_repo_url|
        each_repo_url_list = each_repo_url.split('/')
        folder_name = ""
        folder_name = each_repo_url_list.last
        # some repo urls have .git at the end. So we need to strip it out if it exists.
        repo_name_with_git_suffix = folder_name.split('.')
        if repo_name_with_git_suffix.count > 1 # then this repo url has .file_format (e.g .git, .tf etc) suffixed in the end
          folder_name = repo_name_with_git_suffix.first
          # If the suffix is anything other than .git then skip to next iteration as it is an invalid url
          if repo_name_with_git_suffix[1] != 'git'
            next
          end
        end
        puts 'REPO NAME: '+folder_name
        if File.exists?(folder_name)
          puts folder_name+': This repo is already scanned'
        else
          system("(git clone #{each_repo_url})")
          system("(sonar-scanner -Dsonar.projectKey=#{folder_name} -Dsonar.sources=#{folder_name} -Dsonar.host.url=#{ENV["SONARQUBE_HOST_URL"]} -Dsonar.login=#{ENV["SONARQUBE_TOKEN"]})")
          system("(rm -rf #{folder_name})") 
        end
      end
    end
  end
end
