  require 'json'
  #examples:
  #host: "" # in case same than localhost
  #host: "dfc.myexample.com"
  #port: 443
  #verb: GET
  #path: /blue/beep/444
  def conditions(host,port,verb,path,query)
	  response=nil
      if path.include?("/blue/") 
        host="doom.zoom.com"
        port=9141
      elsif port==9142
          host="doom2.zoom.com"
          port=9141
      elsif path.match(/myregularexpression/)
          host="doom.zoom.com"
          port=9134
      elsif port==443 and path.match(/myregularexpression/) and verb=="POST"
          host="doom.zoom.com"
          port=9157
	  #when adding autoresponses only the path and the verb can be used to select	
	  elsif path.include?("/cp/xala/")
		response=[200, {'Content-Type' => 'application/json'}, 
		  { 
			name: 'Peter Daily',
			city: 'New York',
			isClient: false,
			currency: 'EUR',
			balance: 4663
		  }.to_json
		]
	  #when adding autoresponses only the path and the verb can be used to select	
	  elsif path.include?("/cp/alabi/")
		response=[200, {'Content-Type' => 'application/json'}, 
		  { 
			name: 'Mario',
			city: 'London',
			isClient: true,
			currency: 'EUR',
			balance: 323
		  }.to_json
		]
      end
      if !response.nil? #to use rack for autoresponses
		host="localhost"
		port=9292
	  end
    return host,port,verb,path,query,response
  
  end
