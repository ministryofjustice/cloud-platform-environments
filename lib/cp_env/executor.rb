class CpEnv
  class Executor
    def execute(cmd, can_fail: false, silent: false)
      log("blue", "executing: #{cmd}") unless silent

      stdout, stderr, status = Open3.capture3(cmd)

      unless can_fail || status.success?
        log("red", "Command: #{cmd} failed.")
        log("red", stderr)
        raise
      end

      log("green", stdout) unless silent

      [stdout, stderr, status]
    end
  end
end
