module Sunburst
	def self.get_stats(pid)
		stats = Sunburst.ps_stat(pid)

		if stats.empty?
			Process.kill(9, pid)
			fail RuntimeError, 'Something horribly wrong happened! Exiting.'
		end

		stats
	end

	def self.measure(command:, time: nil, sleep_time: 0.001)
		progress = block_given?

		r = {
			execution_time: nil, cpu_time: nil,
			memory: nil, max_threads: nil,
			max_memory: nil, state: nil, last_state: nil
		}

		IO.popen(command) { |x|
			time1 = Sunburst.clock_monotonic
			pid = x.pid

			t = if progress
				Thread.new { }
			else
				Thread.new { print x.readpartial(4096) until x.eof? }
			end

			last_mem = 0
			max_threads = 0
			max_mem = 0
			last_state = nil

			while true
				_last_mem = Sunburst.get_mem(pid)

				break if (time && Sunburst.clock_monotonic - time1 > time) || _last_mem == 0
				last_mem = _last_mem
				max_mem = last_mem if max_mem < _last_mem

				# Get stats
				stats = get_stats(pid)
				_threads = stats[3]
				max_threads = _threads if max_threads < _threads
				last_state = stats[4]

				cpu_time = stats[1].+(stats[2]).fdiv(Sunburst::TICKS)

				if progress
					yield(
						Sunburst.clock_monotonic.-(time1),
						stats[1].+(stats[2]).fdiv(Sunburst::TICKS),
						_last_mem * Sunburst::PAGESIZE,
						_threads,
						last_state
					)
				end

				sleep(sleep_time)
			end

			time2 = Sunburst.clock_monotonic

			# Get Stats
			stats = get_stats(pid)
			cpu_time = stats[1].+(stats[2]).fdiv(Sunburst::TICKS)

			_threads = stats[3]
			max_threads = _threads if max_threads < _threads

			_last_mem = Sunburst.get_mem(pid)
			max_mem = _last_mem if max_mem < _last_mem
			last_mem = _last_mem unless _last_mem == 0

			state = stats[4]

			t.kill
			Process.kill(9, pid)

			r[:cpu_time] = cpu_time
			r[:max_threads] = max_threads unless max_threads == 0
			r[:memory] = last_mem * Sunburst::PAGESIZE if last_mem > 0
			r[:max_memory] = max_mem * Sunburst::PAGESIZE if last_mem > 0

			r[:execution_time] = time2.-(time1).truncate(5)
			r[:state] = state
			r[:last_state] = last_state
		}

		r
	end
end
