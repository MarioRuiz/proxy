# Proxy tool

## Description
This tool creates a proxy to route the connections

## Prerequisites
You need to have Ruby installed already.

## How to install
1. Install Ruby 2.2+
1. Enable the proxy in your machine
1. Copy proxy.rb and conditions.rb to a folder
1. Specify the different conditions to route the connections on conditions.rb
1. Adding mock responses:
	Responses can be added directly on your conditions.rb file, just specify the response like this:

```ruby
				response=[200, {'Content-Type' => 'application/json'}, 
				{ 
					name: 'Peter Daily',
					city: 'New York',
					isClient: false,
					currency: 'EUR',
					balance: 4663
				 }.to_json
				]
``` 
		The response variable is an array of three positions: code, headers hash, response data
		
		To start the service, run in command line: `responses.rb`

        Defaults: port:8008, conditions file: conditions.rb

        Examples of use:

       `respones.rb`

       `responses.rb my_conditions_file.rb`
	 
1. To start the proxy run on that folder from command line: `proxy.rb`
	 
   Defaults: port:8008, conditions file: conditions.rb
   
   Examples of use:
   
     `proxy.rb`
	 
     `proxy.rb 9110`
	 
     `proxy.rb 9110 my_conditions_file.rb`
