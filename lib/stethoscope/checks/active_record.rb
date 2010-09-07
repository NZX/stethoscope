require 'stethoscope'

# Provides a check for active record databases
Stethoscope.check :database do |response|
  ActiveRecord::Base.connection.execute("SELECT 1")
  response["ActiveRecord"] = "OK"
end
