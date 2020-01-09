class CpEnv
  # Detect and kill any pods which are:
  #
  #   * not part of a ReplicaSet
  #   * and not in kube-system
  #   * and have been running for more than 2 days
  #
  # Such pods prevent the node-recycler from draining a node to
  # replace it.
  #
  # Developers need to run manual pods for tasks such as port-forwarding
  # to a database, but there's no good reason for such a pod to still be
  # running after 48 hours. If pods should always be running, they should
  # be part of a deployment (and hence a ReplicaSet).
  #
  # To see a list of pods that *would be* deleted, without actually
  # deleting any, pass `dry_run: true` to the `initialize` method.
  class ManuallyCreatedPodDeleter
    attr_reader :executor, :dry_run

    SYSTEM_NAMESPACE = "kube-system"
    MAX_AGE_IN_SECONDS = 2 * 24 * 60 * 60 # 2 days

    def initialize(args = {})
      @executor = args.fetch(:executor) { Executor.new }
      @dry_run = args.fetch(:dry_run, false)
    end

    def run
      pods_to_delete = get_all_pods
        .reject { |pod| pod.fetch("metadata").key?("ownerReferences") }
        .reject { |pod| pod.dig("metadata", "namespace") == SYSTEM_NAMESPACE }
        .reject { |pod| seconds_running(pod) < MAX_AGE_IN_SECONDS }

      pods_to_delete.map { |pod| delete_pod(pod) }
    end

    private

    def get_all_pods
      stdout, _stderr, _status = executor.execute("kubectl get pods --all-namespaces -o json", silent: true)
      JSON.parse(stdout).fetch("items")
    end

    def seconds_running(pod)
      Time.now.to_i - DateTime.parse(pod.dig("status", "startTime")).to_time.to_i
    end

    def delete_pod(pod)
      namespace = pod.dig("metadata", "namespace")
      name = pod.dig("metadata", "name")
      if dry_run
        log("blue", "dry run: would delete pod #{name} from namespace #{namespace}")
      else
        executor.execute("kubectl -n #{namespace} delete pod #{name}")
      end
    end
  end
end
