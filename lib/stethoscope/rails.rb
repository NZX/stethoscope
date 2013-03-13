if defined?(Rails::Railtie)
  # Adds the heartbeat to the stack
  class Stethoscope
    class Railtie < Rails::Railtie
      initializer 'stethoscope.middleare' do |app|
        app.middleware.use Stethoscope

        require 'stethoscope/checks/active_record' if defined?(ActiveRecord)
        require 'stethoscope/checks/data_mapper'   if defined?(DataMapper)
        if defined?(Mongoid)
          mongoid_check = defined?(Moped) ? "mongoid3" : "mongoid2"
          require "stethoscope/checks/#{mongoid_check}"
        end
      end
    end
  end
end
