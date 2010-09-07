require 'nanotest'
require 'nanotest/contexts'
require 'nanotest/stats'
require 'rack/test'

$:.unshift File.join(File.expand_path(File.dirname(__FILE__)), "..", "lib")
require 'stethoscope'

APP = lambda{ |e| Rack::Response.new("default").finish }

module StethoscopeTestHelpers
  def setup_app(&blk)
    @app = begin
      Rack::Builder.new do
        if blk
          instance_eval &blk
        else
          use Stethoscope
        end
        run APP
      end
    end
  end

  def app
    @app
  end
end
