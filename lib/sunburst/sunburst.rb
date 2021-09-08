module Sunburst
	def self.get_stats(pid)
		stats = Sunburst.ps_stat(pid)

		if stats.empty?
			Process.kill(9, pid)
			fail RuntimeError, 'Something horribly wrong happened! Exiting.'
		end

		stats
	end

	def self.calculate_cpu_usage(pid, sleep_time)
		ticks = Sunburst::TICKS
		stat = Sunburst.ps_stat(pid)
		uptime = IO.read('/proc/uptime').to_f

		unless uptime && !stat.empty?
			sleep(sleep_time)
			return nil
		end

		utime, stime, starttime = *stat.values_at(1, 2, 5).map(&:to_f)
		uptime *= ticks

		total_time = utime + stime
		idle1 = uptime - starttime - total_time

		sleep(sleep_time)

		stat = Sunburst.ps_stat(pid)
		uptime = IO.read('/proc/uptime').to_f
		return nil unless uptime && !stat.empty?

		utime2, stime2, starttime2 = *stat.values_at(1, 2, 5).map(&:to_f)
		uptime *= ticks

		total_time2 = utime2 + stime2
		idle2 = uptime - starttime2 - total_time2

		totald = idle2.+(total_time2).-(idle1 + total_time)
		cpu_u = totald.-(idle2 - idle1).fdiv(totald).abs.*(100)./(Sunburst.nprocessors)

		cpu_usage = cpu_u > 100 ? 100.0 : cpu_u.round(3)
	end

	def self.measure(command:, time: nil, sleep_time: 0.001)
		progress = block_given?

		r = {
			execution_time: nil, cpu_time: nil,
			memory: nil, max_threads: nil,
			avg_mem: nil, max_memory: nil, state: nil, last_state: nil,
			avg_cpu_usage: nil
		}

		IO.popen(command) { |x|
			time1 = Sunburst.clock_monotonic
			pid = x.pid

			t = if progress
				Thread.new { }
			else
				Thread.new { print x.readpartial(4096) until x.eof? }
			end

			cpu_usage = 0
			cpu_usage_sum = 0
			cpu_usage_measure_count = 0

			Thread.new {
				while true
					_cpu_usage = calculate_cpu_usage(pid, 0.25)

					if _cpu_usage
						cpu_usage = "%05.2f%%".freeze % _cpu_usage
						cpu_usage_sum += _cpu_usage
						cpu_usage_measure_count += 1
					else
						cpu_usage = ?X.freeze
					end

				end
			}

			last_mem = 0
			max_threads = 0
			max_mem = 0
			last_state = nil

			avg_mem = 0
			mem_measure_count = 0

			while true
				_last_mem = Sunburst.get_mem(pid)

				break if (time && Sunburst.clock_monotonic - time1 > time) || _last_mem == 0
				last_mem = _last_mem
				max_mem = last_mem if max_mem < _last_mem

				avg_mem += _last_mem
				mem_measure_count += 1

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
						last_state,
						cpu_usage
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
			r[:avg_mem] =  (avg_mem * Sunburst::PAGESIZE) / mem_measure_count if mem_measure_count > 0

			r[:execution_time] = time2.-(time1).truncate(5)
			r[:state] = state
			r[:last_state] = last_state

			r[:avg_cpu_usage] = sprintf("%05.2f%%", cpu_usage_sum / cpu_usage_measure_count) if cpu_usage_measure_count > 0
		}

		r
	end
end
