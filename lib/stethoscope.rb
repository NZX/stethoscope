require 'dictionary'
require 'tilt'
require 'json'
require 'stethoscope/rails'

# Stethoscope is Rack middleware that provides a heartbeat function to an application.
#
# Stethoscope provides a mechanism to add checks to the application, and will render a template
# in response to a request
#
# @example
#   Rack::Builder.new do
#     use Stethoscope
#     run MyApp.new
#   end
#
# @see Rack
class Stethoscope
  # Set the url to check for the heartbeat in this application
  #
  # @example
  #   Stethoscope.url = "/my/heartbeat/location"
  #
  #   GET "/my/heartbeat/location" <-- intercepted by stethoscope
  #
  # @see Stethoscope.url
  # @api public
  def self.url=(url)
    @url = url
  end

  # The current url that Stethoscope is setup to listen for
  # @see Stethoscope.url=
  # @api public
  def self.url
    @url ||= "/heartbeat"
  end

  # The collection of checks currently in place in Stethoscope
  # @see Stethoscope.check
  # @api public
  def self.checks
    @checks ||= Dictionary.new
  end

  # Add a check to Stethoscope
  #
  # A check is a block that checks the health of some aspect of your application
  # You add information to the response of the check, including a status (if not successful)
  #
  # Any resonse that has a status outside 200..299 will cause the heartbeat to fail
  #
  # @example
  #   Stethoscope.check("My Database") do |response|
  #     if my_db_check
  #       response[:result] = "Success"
  #     else
  #       response[:result] = "Bad Bad Bad"
  #       response[:arbitrary] = "something else"
  #       response[:status] = 500 # <---- VERY IMPORTANT
  #     end
  #   end
  #
  # @see Stethoscope.check
  # @api public
  def self.check(name, &blk)
    checks[name] = blk
  end

  # Removes a give check
  # @example
  #   Stethoscope.remove_check("my check to remove")
  #
  # @see Stethoscope.check
  # @api public
  def self.remove_check(name)
    checks.delete(name)
  end

  # Clears all defined checks
  # @see Stethoscope.check
  # @api public
  def self.clear_checks
    checks.clear
  end

  # Sets the Tilt template that will be used for heartbeat rendering
  #
  # @param template - A Tilt template object
  #
  # @see Stethoscope.template
  # @see Tilt
  # @api public
  def self.template=(template)
    @template = template
  end

  # Getter for the Tilt template for heartbeat rendering
  # By default, the Stethoscope default template is used.  Overwrite this to use a custom template
  #
  # @see Stethoscope.template=
  # @see Tilt
  #
  # @api public
  def self.template
    @template ||= Tilt.new(File.join(File.dirname(__FILE__), "stethoscope", "template.erb"))
  end
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    return @app.call(env) unless check_heartbeat?(request.path)
    responses = Hash.new do |h,k|
      h[k] = {:status => 200}
    end

    Stethoscope.checks.each do |name, check|
      begin
        check.call(responses[name])
      rescue => e
        responses[name][:error]  = e
        responses[name][:status] = 500
      end
    end

    status = responses.any?{ |k,v| v[:status] && !((200..299).include?(v[:status])) } ? 500 : 200
    _format = format(request.path)

    headers = { 'Content-Type' => 'text/html' }

    case format(request.path)
    when :html
      result = Stethoscope.template.render(Object.new, :checks => responses)
    when :json
      result = {:checks => responses, :status => status}.to_json
      headers['Content-Type'] = 'application/json'
    end

    Rack::Response.new(result, status, headers).finish
  end

  private
  def check_heartbeat?(path)
    path == self.class.url || path == (self.class.url + '.json')
  end

  def format(path)
    return :json if path == (self.class.url + '.json')
    :html
  end
end
