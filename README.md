# Stethoscope

Stethoscope is Rack Middelware that provides heartbeats for your application.  Heartbeats are used to check that your application is functioning correctly.

Typically, a tool like Nagios will monitor a heartbeat URL which will return a 200 OK status if everything is ok, or a 500 response for any issues.

## Usage

### Rack

    use Stethoscope
    run MyApp

### Rails 2

    # config/environment.rb
    config.middleware.use Stethoscope

### Rails 3

Just require Stethoscope in your application. Stethoscope has a Railtie that will configure Stethoscope to work

## Customizing Stethoscope

### Heartbeat URL

Default: `/heartbeat`

    Stethoscope.url = "/some/custom/path"

### Checks

Stethoscope uses _checks_ to check some component of the application.  A check is simply a block that is executed when the heartbeat url is hit.

A response hash is made available to store any information which is then made available to the heartbeat template.

Returning a response _:status_ outside 200..299 will trigger Stethoscope to return a 500 status code to the client.

#### Example

    Stethoscope.check :database do |response|
      ActiveRecord::Base.connection.execute('select 1')
    end

    Stethoscope.check :some_service do |response|
      start   = Time.now
      response['result']    = SomeSerivce.check_availability!
      response['Ping Time'] = Time.now - start
      response[:status]     = 245 # Any status outside 200..299 will result in a 500 status being returned from the heartbeat
    end

Any exceptions are caught and added to the response with the _:error_ key.  The template can then handle them appropriately

#### Defaults

* ActiveRecord
  * Check name - :database
  * require 'stethoscope/checks/active\_record'
  * Included if the ActiveRecord constant is present in Rails 3
* DataMapper
  * Check name - :database
  * require 'stethoscope/checks/data\_mapper'
  * Included if the DataMapper constant is present in Rails 3

### Template

Stethoscope uses [Tilt](http://github.com/rtomayko/tilt) to render a template for the heartbeat response

By default, Stethoscope provides a simple template to render the responses of the checks in the _lib/stethoscope/template.erb_ file.

You can overwrite the template used:

    Stethoscope.template = Tilt.new("my_new_tempalte_file.haml")
