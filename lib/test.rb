Process.maxchild = 2
10.times do |i|
  fork do
    puts "child #{i} starting"
    sleep 1
    puts "child #{i} done"
  end
end
Process.waitpid(-1, Process::WNOHANG | Process::WUNTRACED)
puts "#{Process.nchild} child processes are running"
puts "Try again"

Process.maxchild = 4
10.times do |i|
  fork do
    puts "child #{i} starting"
    sleep 1
    puts "child #{i} done"
  end
end
Process.waitpid(-1, Process::WNOHANG | Process::WUNTRACED)
puts "#{Process.nchild} child processes are running"
