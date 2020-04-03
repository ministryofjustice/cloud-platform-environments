class CpEnv
  class Logger

    FILTER_LIST = %w(
      password
      secret
      token
      key
    )

    def log(colour, message)
      colour_code = case colour
                    when "red"
                      31
                    when "blue"
                      34
                    when "green"
                      32
                    else
                      raise "Unknown colour #{colour} passed to 'log' method"
                    end

      redacted_message(message).split("\n").each do |line|
        puts "\e[#{colour_code}m#{line}\e[0m"
      end
    end

    private

    def redacted_message(message)
      message
        .split("\n")
        .map { |line| redacted_line(line) }
        .join("\n")
    end

    def redacted_line(line)
      FILTER_LIST.each do |term|
        line.sub!(/#{term}.*/, "#{term} REDACTED")
      end
      line
    end
  end
end
