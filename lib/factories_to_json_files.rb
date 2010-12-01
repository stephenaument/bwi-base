# Class for converting factory files to individual  
#
#
require 'factory_girl_rails'
require 'json'

module BWI
  class FactoriesToJsonFiles
    def initialize(*args)
    
    end
  
    def FactoriesToJsonFiles.process
      puts "exporting json files for factories..."

      Factory.factories.each do |factory|
        begin
          name = factory.select{|f| f.is_a? Factory}.first.factory_name
          puts "creating factory for #{name}"
          obj = Factory.build(name, :created_at => ::Time.now, :updated_at => ::Time.now, :id => 1)
          File.open(File.join('.','spec','factories',"#{name}.json"), mode="w") do |file|
            file << JSON.pretty_generate(JSON.parse(obj.to_json))
          end
          User.where("email like 'person%@example.com'").destroy_all
        rescue
          puts "Error while processing factory #{name}: #{$!}"
        end
      end
    end
  end  
end
