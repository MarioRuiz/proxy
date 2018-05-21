require 'rack'
require 'json'
# Get parameters and start the server
if ARGV.empty?
  cond="conditions"
elsif ARGV.size == 1
  cond=ARGV[0].dup
else
  puts 'Usage: responses.rb [conditions.rb]'
  puts "Defaults: conditions file: conditions.rb"
  puts 'Examples:'
  puts 'responses.rb'
  puts 'responses.rb my_conditions_file.rb'
  exit 1
end
cond.gsub!(".rb","")
if File.exists?("./#{cond}.rb")
  require "./#{cond}" 
else
  warn "No conditions file supplied or the file didn't exist"
  def conditions(host,port,verb,path,query)
    return host,port,verb,path,query,nil
  end
end  
puts "-"*50

mock = Proc.new do |env|
	req = Rack::Request.new(env)
	
	  req.request_method #=> GET, POST, PUT, etc.
	  req.get?           # is this a GET request
	  req.path_info      # the path this request came in on
	  req.session        # access to the session object, if using the Rack::Session middleware
	  req.params         # a hash of merged GET and POST params, useful for pulling values out of a query string
	 
	  # ... and many more
	  host,port,verb,path,query,response=conditions(nil,nil,req.request_method,req.path_info,nil)
	  if response.to_s()=="" then
		response=[404,{},[]]
	  elsif !response[2].kind_of?(Array) then
		response[2]=[response[2]]
	  end
	  response
end

Rack::Handler::WEBrick.run mock, {Port:9292}
