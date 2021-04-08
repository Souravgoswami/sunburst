module Sunburst
	def self.measure(command:, time: nil, sleep_time: 0.001)
		r = {execution_time: nil, cpu_time: nil, memory: nil}

		IO.popen(command) { |x|
			time1 = Sunburst.clock_monotonic
			pid = x.pid

			t = Thread.new {
				print x.readpartial(4096) until x.eof?
			}

			last_mem = 0

			while true
				_last_mem = Sunburst.get_mem(pid)

				break if (time && Sunburst.clock_monotonic - time1 > time) || _last_mem == 0
				last_mem = _last_mem

				sleep(sleep_time)
			end

			time2 = Sunburst.clock_monotonic

			# Get CPU Time
			cpu_time = Sunburst.get_times(pid).truncate(5)

			# Get Memory Usage
			_last_mem = Sunburst.get_mem(pid)
			last_mem = _last_mem unless _last_mem == 0

			t.kill
			Process.kill(9, pid)

			r[:execution_time] = time2.-(time1).truncate(5)
			r[:cpu_time] = cpu_time
			r[:memory] = last_mem * Sunburst::PAGESIZE if last_mem > 0
		}

		r
	end
end
