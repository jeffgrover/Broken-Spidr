require 'spidr'
require 'yaml'

url_map = Hash.new { |hash,key| hash[key] = [] }
urls = {} 
last = 0
spider = Spidr.site('http://asperasoft.com/') do |spider|
  spider.every_link do |origin,dest|
    url_map[dest] << origin
    if url_map.size > last
       STDERR.print "#{url_map.size} " 
    end
    urls[origin.path] = 0 unless urls[origin.path]
    urls[origin.path] += 1 
    last = url_map.size
    system("stty raw -echo")
    char = STDIN.read_nonblock(1) rescue nil
    system("stty -raw echo")
    spider.pause! if /q/i =~ char
  end
end

puts
puts "VISITED:"
puts urls.to_yaml
puts "#{urls.size} total"
puts
puts "FAILURES:"

spider.failures.each do |url|
  puts "Broken link #{url} found in:"

  url_map[url].each { |page| puts "  #{page}" }
end
puts "#{spider.failures.size} total"

