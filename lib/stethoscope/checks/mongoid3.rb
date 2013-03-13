require 'stethoscope'

# Provides a check for mongoid databases
Stethoscope.check :database do |response|
  collections = Mongoid::Sessions.default.collections
  response["collection count"] = collections.size
  response["Mongoid"] = "OK"
end
