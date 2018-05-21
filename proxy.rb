require 'socket'
require 'uri'
require 'rack'

class Proxy  
  def rules(request_line)
      # Show what got requested
      puts request_line.inspect
      
      verb    = request_line[/^\w+/]
      url     = request_line[/^\w+\s+(\S+)/, 1]
      uri     = URI::parse url
      
      #defaults
      host=uri.host
      port=uri.port
      path=uri.path
      query=uri.query
      
      
      host,port,verb,path,query,response=conditions(host,port,verb,path,query)
      
      puts "host:#{host}, port:#{port}, verb:#{verb}, path:#{path}, query:#{query}"
      return host,port,verb,path,query,response

  end
  def run port
    begin
      # Start our server to handle connections (will raise things on errors)
      @socket = TCPServer.new port
      
      # Handle every request in another thread
      loop do
        s = @socket.accept
        Thread.new s, &method(:handle_request)
      end
      
    # CTRL-C
    rescue Interrupt
      puts 'Got Interrupt..'
    # Ensure that we release the socket on errors
    ensure
      if @socket
        @socket.close
        puts 'Socked closed..'
      end
      puts 'Quitting.'
    end
  end
  
  def handle_request to_client
    request_line = to_client.readline
    
    version = request_line[/HTTP\/(1\.\d)\s*$/, 1]
    
    host,port,verb,path,query,response=rules(request_line)
    
    to_server = TCPSocket.new(host, (port.nil? ? 80 : port))
    to_server.write("#{verb} #{path}?#{query} HTTP/#{version}\r\n")
    
    content_len = 0
    
    loop do      
      line = to_client.readline
      
      if line =~ /^Content-Length:\s+(\d+)\s*$/
        content_len = $1.to_i
      end
      
      # Strip proxy headers
      if line =~ /^proxy/i
        next
      elsif line.strip.empty?
        to_server.write("Connection: close\r\n\r\n")
        
        if content_len >= 0
          to_server.write(to_client.read(content_len))
        end
        
        break
      else
        to_server.write(line)
      end
    end
    
    buff = ""
    loop do
      to_server.read(4048, buff)
      to_client.write(buff)
      break if buff.size < 4048
    end
    
    # Close the sockets
    to_client.close
    to_server.close
  end
  
end

# Get parameters and start the server
if ARGV.empty?
  port = 8008
  cond="conditions"
elsif ARGV.size == 1
  port = ARGV[0].to_i
  cond="conditions"
elsif ARGV.size == 2
  port = ARGV[0].to_i
  cond=ARGV[1].dup
else
  puts 'Usage: proxy.rb [port] [conditions.rb]'
  puts "Defaults: port:8008, conditions file: conditions.rb"
  puts 'Examples:'
  puts 'proxy.rb'
  puts 'proxy.rb 9110'
  puts 'proxy.rb 9110 my_conditions_file.rb'
  exit 1
end
cond.gsub!(".rb","")
puts "Proxy started on port #{port}"
if File.exists?("./#{cond}.rb")
  require "./#{cond}" 
else
  warn "No conditions file supplied or the file didn't exist"
  def conditions(host,port,verb,path,query)
    return host,port,verb,path,query,nil
  end
end  
puts "-"*50
Proxy.new.run port