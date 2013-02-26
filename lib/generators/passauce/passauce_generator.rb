require 'rails/generators'
require 'rails/generators/migration'

 class PassauceGenerator < Rails::Generators::Base

   include Rails::Generators::Migration

   def self.source_root 
     @source_root ||= File.join(File.dirname(__FILE__), 'templates')
   end

   def self.next_migration_number ( dirname ) 
      if ActiveRecord::Base.timestamped_migrations
        Time.new.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
   end

   def create_migration_file
     begin
     migration_template 'migration.rb', 'db/migrate/create_pass_table.rb'
     rescue 
     end
   end

   def copy_config_file
     template 'config/passauce.yml'
   end

   def copy_pass_templates
     directory 'passes', 'vendor/assets/passes'
   end
   

 end


