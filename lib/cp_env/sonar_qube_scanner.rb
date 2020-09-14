class CpEnv
  class SonarQubeScanner
    attr_reader :executor, :dry_run, :sonar_qube_host, :sonar_qube_token

    REPO_REGEXP = %r{^https://github.com/[^\s,]+$}

    def initialize(args = {})
      @sonar_qube_host = args.fetch(:sonar_qube_host, ENV.fetch("SONARQUBE_HOST_URL"))
      @sonar_qube_token = args.fetch(:sonar_qube_token, ENV.fetch("SONARQUBE_TOKEN"))
      @executor = args.fetch(:executor) { Executor.new }
      @dry_run = args.fetch(:dry_run, false)
    end

    def scan_all_repos
      repo_urls.each do |url|
        if checkout_repo(url)
          dir = url.split("/").last.sub(/\..*$/, "")
          scan_directory(dir)
          system("rm -rf #{dir}")
        end
      end
    end

    private

    def repo_urls
      get_namespaces
        .map { |namespace| namespace.dig("metadata", "annotations", "cloud-platform.justice.gov.uk/source-code") }
        .map { |str| str.to_s.split(",") }
        .flatten
        .map(&:strip)
        .compact
        .uniq
        .find_all { |url| REPO_REGEXP.match?(url) }
    end

    def get_namespaces
      stdout, _stderr, _status = executor.execute("kubectl get ns -o json", silent: true)
      JSON.parse(stdout).fetch("items")
    end

    def checkout_repo(url)
      system("GIT_TERMINAL_PROMPT=0 git clone --depth 1 #{url}")
      $?.success? # If the command failed then the reop is invalid, private or already cloned. Skip to next.
    end

    def scan_directory(dir)
      puts "SCANNING REPO: " + dir
      system("(cd #{dir}; sonar-scanner -Dsonar.projectKey=#{dir} -Dsonar.sources=. -Dsonar.host.url=#{sonar_qube_host} -Dsonar.login=#{sonar_qube_token})")
    end
  end
end
