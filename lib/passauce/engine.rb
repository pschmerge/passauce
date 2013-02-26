module Passauce

  class Engine < Rails::Engine
    initializer "passauce.load_app_instance_data" do |app|
#      PASSAUCE_CONFIG = YAML.load_file("#{Rails.root}/config/passauce.yml")[Rails.env] unless Rails.nil?

      begin
        app.config.passauce = YAML.load_file("#{Rails.root}/config/passauce.yml")[Rails.env] unless Rails.nil? 
      rescue
        app.config.passauce = {}
      end
    end

  end

end
