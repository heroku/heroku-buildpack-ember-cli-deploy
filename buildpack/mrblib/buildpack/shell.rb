module Buildpack
  module Shell
    def system(command, env = nil)
      output = nil

      IO.popen(command_to_string(command, env)) do |io|
        output = io.read
      end

      [output, $?]
    end

    def pipe(command, output_io = @output_io, env = nil)
      IO.popen(command_to_string(command, env)) do |io|
        while data = io.read(1)
          output_io.print data
        end
      end

      $?
    end

    def command_success?(command)
      _, status = system(command)
      status.success?
    end

    private
    def command_to_string(command, env)
      if env
        env_string = env.map {|key, value| "#{Shellwords.shellescape(key)}=#{Shellwords.shellescape(value)}" }.join(" ")

        "/usr/bin/env #{env_string} #{command}"
      else
        command
      end
    end
  end
end
