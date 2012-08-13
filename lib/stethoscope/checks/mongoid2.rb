require 'stethoscope'

# Provides a check for mongoid databases
Stethoscope.check :database do |response|
  collection_names = Mongoid.database.collection_names
  response["collection count"] = collection_names.size
  response["Mongoid"] = "OK"
end
