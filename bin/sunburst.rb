require 'sunburst'
STDOUT.sync = STDIN.sync = true

if ARGV.any? { |x| x[/^\-(\-help|h)$/] }
	puts <<~EOF
		Sunburst lets you run a command for a given time.
		When the time expires, the program will be SIGKILLed.
		Sunburst will then report the total CPU time and last known memory usage
		of the program.

		If no time is specified, it will run until the command exits.


		Arguments:
		\s\s\s\s--time=N\s\s\s\s\s\s\s\s\s\sRun the program for N seconds
		\s\s\s\s-h | --help\s\s\s\s\s\s\sShow this help section
		\s\s\s\s--humanize\s\s\s\s\s\s\s\sHuman readable memory units

		Example:
		\s\s\s\ssunburst echo hello world --time=0.05 --humanize
		\s\s\s\ssunburst "echo hello world" --time=0.05 --humanize
		\s\s\s\ssunburst "ruby -e 'while true do end'" --time=3 --humanize
		\s\s\s\ssunburst "ruby -e 'p :Hello'" --time=3 --humanize
	EOF

	exit 0
end

time_arg = ARGV.find { |x| x[/^\-\-time=[0-9]+\.?[0-9]*$/] }
ARGV.delete(time_arg) if time_arg
time = time_arg ? time_arg.split('=')[-1].to_f : nil

_human_readable = ARGV.find { |x| x[/^\-\-humanize$/] }
ARGV.delete(_human_readable) if _human_readable
human_readable = _human_readable

command = ARGV.join(' ')

puts %Q(:: Running "#{command}" for #{time || 'infinite'} seconds)
puts "-" * Sunburst.win_width

data = Sunburst.measure(command: command, time: time, sleep_time: 0.0001)

puts "-" * Sunburst.win_width
puts "::Total Execution Time: #{data[:execution_time]} seconds"
puts ":: CPU Time: #{data[:cpu_time]} second#{?s if data[:cpu_time] != 1}"

mem = data[:memory]

if mem
	if human_readable
		mem_text = if mem >= 10 ** 12
			"#{mem.fdiv(10 ** 12).round(3)} TB"
		elsif mem >= 10 ** 9
			"#{mem.fdiv(10 ** 9).round(3)} GB"
		elsif mem >= 10 ** 6
			"#{mem.fdiv(10 ** 6).round(3)} MB"
		elsif mem >= 10 ** 3
			"#{mem.fdiv(10 ** 3).round(3)} KB"
		else
			"#{mem} Bytes"
		end

		puts ":: Memory usage: #{mem_text}"
	else
		puts ":: Memory usage: #{mem} bytes"
	end
else
	puts ":: The memory usage can't be logged."
end
