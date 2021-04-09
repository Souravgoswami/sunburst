module Sunburst
	def self.get_stats(pid)
		stats = Sunburst.ps_stat(pid)

		if stats.empty?
			Process.kill(9, pid)
			fail RuntimeError, 'Something horribly wrong! Exiting.'
		end

		stats
	end

	def self.measure(command:, time: nil, sleep_time: 0.001)
		r = {
			execution_time: nil, cpu_time: nil,
			memory: nil, max_threads: nil
		}

		IO.popen(command) { |x|
			time1 = Sunburst.clock_monotonic
			pid = x.pid

			t = Thread.new { print x.readpartial(4096) until x.eof? }

			last_mem = 0
			max_threads = 0

			while true
				_last_mem = Sunburst.get_mem(pid)

				break if (time && Sunburst.clock_monotonic - time1 > time) || _last_mem == 0
				last_mem = _last_mem

				# Get stats
				stats = get_stats(pid)
				_threads = stats[3]
				max_threads = _threads if max_threads < _threads

				sleep(sleep_time)
			end

			time2 = Sunburst.clock_monotonic

			# Get Stats
			stats = get_stats(pid)
			cpu_time = stats[1].+(stats[2]).fdiv(Sunburst::TICKS)

			_threads = stats[3]
			max_threads = _threads if max_threads < _threads

			# Get Memory Usage
			_last_mem = Sunburst.get_mem(pid)
			last_mem = _last_mem unless _last_mem == 0

			t.kill
			Process.kill(9, pid)

			r[:cpu_time] = cpu_time
			r[:max_threads] = max_threads unless max_threads == 0
			r[:memory] = last_mem * Sunburst::PAGESIZE if last_mem > 0

			r[:execution_time] = time2.-(time1).truncate(5)
		}

		r
	end
end
