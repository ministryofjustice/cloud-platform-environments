class CpEnv
  # This script will delete completed jobs which are:
  #
  #   * not part of a Cronjobs
  #   * and job not set with ttlSecondsAfterFinished
  #
  # These completed jobs pods are taking up pod count on each node
  # creating too many pods per node get alerts (limit set by KOPS is 100 per node)
  #
  # To see a list of jobs that *would be* deleted, without actually
  # deleting any, pass `dry_run: true` to the `initialize` method.
  class CompletedJobDeleter
    attr_reader :executor, :dry_run

    def initialize(args = {})
      @executor = args.fetch(:executor) { Executor.new }
      @dry_run = args.fetch(:dry_run, false)
    end

    def delete
      jobs_to_delete = get_completed_jobs
        .reject { |job| job.fetch("spec").key?("ttlSecondsAfterFinished") }

      jobs_to_delete.map do |job|
        delete_job(job)
      rescue Exception => e
        # Job might have been deleted since we read the list
        puts "Caught error #{e}:\n#{e.message}"
        puts "Continuing..."
      end
    end

    private

    def get_jobs
      stdout, _stderr, _status = executor.execute("kubectl get jobs --all-namespaces -o json", silent: true)
      JSON.parse(stdout).fetch("items")
    end

    def get_completed_jobs
      get_jobs.find_all { |job| completed_jobs(job) }
    end

    def completed_jobs(job)
      job.dig("status", "succeeded") == 1
    end

    def delete_job(job)
      namespace = job.dig("metadata", "namespace")
      name = job.dig("metadata", "name")
      if dry_run
        log("blue", "dry run: would delete job #{name} from namespace #{namespace}")
      else
        executor.execute("kubectl -n #{namespace} delete job #{name}")
      end
    end
  end
end
