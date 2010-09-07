require 'stethoscope'

# Provides a check for active record databases
Stethoscope.check :database do |response|
  query = "SELECT 1"
  response["query"] = query.inspect
  ActiveRecord::Base.connection.execute(query)
  response["ActiveRecord"] = "OK"
end
