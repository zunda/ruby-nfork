#
# nfork.rb - limits number of child processes
#
# Copyright (C) 2008 by zunda <zunda at freeshell.org>
# 
# Author:: zunda <zunda at freeshell.org>
# License:: Ruby's
#
# == Example
#
# Limit child process to two or less
#
#   Process.maxchild = 2
#   10.times do |i|
#     fork do
#       puts "child #{i} starting" 
#       sleep(1)
#       puts "child #{i} done"
#     end
#   end
#   Process.waitall
#

module Process
	@@nchild = 0
	@@maxchild = nil

	def Process.nchild
		@@nchild
	end

	def Process.maxchild
		@@maxchild
	end

	def Process.maxchild=(other)
		@@maxchild = other
	end

	def Process.block
		if @@maxchild
			begin
				while Process.waitpid(-1, Process::WNOHANG | Process::WUNTRACED)
				end
				while @@maxchild <= @@nchild
					Process.waitpid(-1)
				end
			rescue Errno::ECHILD
			end
		end
	end

	class << self
		alias nfork_fork_orig fork
	end
	def Process.fork(*args, &block)
		Process.block
		@@nchild += 1
		nfork_fork_orig(*args, &block)
	end

	class << self
		alias nfork_wait_orig wait
	end
	def Process.wait(*args)
		r = Process.nfork_wait_orig(*args)
		@@nchild -= 1 if r
		return r
	end

	class << self
		alias nfork_wait2_orig wait2
	end
	def Process.wait(*args)
		r = Process.nfork_wait2_orig(*args)
		@@nchild -= 1 if r
		return r
	end

	class << self
		alias nfork_waitpid_orig waitpid
	end
	def Process.waitpid(*args)
		r = Process.nfork_waitpid_orig(*args)
		@@nchild -= 1 if r
		return r
	end

	class << self
		alias nfork_waitpid2_orig waitpid2
	end
	def Process.waitpid(*args)
		r = Process.nfork_waitpid2_orig(*args)
		@@nchild -= 1 if r
		return r
	end

	class << self
		alias nfork_waitall_orig waitall
	end
	def Process.waitall
		r = Process.nfork_waitall_orig
		@@nchild = 0
		return r
	end
end

def fork(*args, &block)
	Process.fork(*args, &block)
end

if __FILE__ == $0
	require 'test/unit'

	class ProcessTest < Test::Unit::TestCase
		def teardown
			Process.maxchild = nil
			Process.waitall
		end
		
		def test_max
			Process.maxchild = nil
			assert_equal(nil, Process.maxchild)
			Process.maxchild = 1
			assert_equal(1, Process.maxchild)
		end

		def test_normal_fork
			Process.maxchild = nil
			t1 = Time.now
			assert(fork{sleep(1)})
			assert(fork{sleep(1)})
			assert(fork{sleep(1)})
			t2 = Time.now
			assert(t2 - t1 < 1)
		end

		def test_blocked_fork
			Process.maxchild = 2
			t1 = Time.now
			assert(fork{sleep(1)})
			assert(fork{sleep(1)})
			assert(fork{sleep(1)})
			t2 = Time.now
			assert(t2 - t1 > 1)
		end

		def test_nchild
			assert_equal(0, Process.nchild)
			assert(fork{sleep(1)})
			assert_equal(1, Process.nchild)
			assert(fork{sleep(1)})
			assert_equal(2, Process.nchild)
			sleep(1.1)	# waiting for child processes to end
			begin
				while Process.waitpid(-1, Process::WNOHANG | Process::WUNTRACED)
				end
			rescue Errno::ECHILD
			end
			assert_equal(0, Process.nchild)	# needs to call waitpid to update nchild
		end
	end
end
