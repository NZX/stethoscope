require 'stethoscope'

# Provides a check for datamapper databases
Stethoscope.check :database do |response|
  DataMapper.repository.adapter.execute("select 1")
  response['Datamapper'] = "OK"
end

