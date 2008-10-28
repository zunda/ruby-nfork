require 'nfork'

Process.maxchild = 2
10.times do |i|
  fork do
    puts "child #{i} starting"
    sleep 1
    puts "child #{i} done"
  end
end
Process.waitpid(-1, Process::WNOHANG | Process::WUNTRACED)
puts "#{Process.nchild} (should be 2) child processes are running"
puts "Trying again"

Process.maxchild = 4
10.times do |i|
  fork do
    puts "child #{i} starting"
    sleep 1
    puts "child #{i} done"
  end
end
Process.waitpid(-1, Process::WNOHANG | Process::WUNTRACED)
puts "#{Process.nchild} (should be 4) child processes are running"
