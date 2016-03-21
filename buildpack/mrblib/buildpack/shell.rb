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

    def pipe_exit_on_error(command, output_io = @output_io, error_io = @error_io, env = nil)
      status = pipe(command, output_io, env)
      if status.success?
        status
      else
        @error_io.puts "Error running: #{command}"
        exit 1
      end
    end

    def command_success?(command, env = nil)
      _, status = system(command_to_string(command, env))
      status.success?
    end

    private
    def command_to_string(command, env)
      if env
        env_string = env.map {|key, value| "#{Shellwords.shellescape(key)}=#{Shellwords.shellescape(value)}" }.join(" ")

        "/usr/bin/env #{env_string} bash -c '#{command}'"
      else
        command
      end
    end
  end
end
