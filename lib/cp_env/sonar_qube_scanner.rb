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
        repo_name = each_repo_url_list.last
        puts `git clone #{each_repo_url}`
        puts `sonar-scanner -Dsonar.projectKey=#{repo_name} -Dsonar.sources=#{repo_name} -Dsonar.host.url=#{ENV["SONARQUBE_HOST_URL"]} -Dsonar.login=#{ENV["SONARQUBE_TOKEN"]}`
      end
      puts `rm -rf cloud-platform-*`
    end


  end
end
