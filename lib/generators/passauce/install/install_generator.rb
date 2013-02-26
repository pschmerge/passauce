require 'rails/generators/migration'

 class PassuanceGenerator < Rails::Generator::Base

   include Rails::Generators::Migration

   def self.source_root 
     @source_root ||= File.join(File.dirname(__FILE__), 'templates')
   end

   def self.next_migration_numer ( dirname ) 
      if ActiveRecord::Base.timestamped_migrations
        Time.new.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
   end

   def create_migration_file
     migration_template 'migration.rb', 'db/migrate/create_pass_table.rb'
   end
   

 end

