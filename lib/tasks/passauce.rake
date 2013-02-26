
namespace :passauce do
  desc "Setup passauce" 
  task :setup do
    puts "passauce setup"
    
    file = File.join(File.dirname(__FILE__), 'config/passauce.yml')
    puts "file: #{file}"

    begin 
      path = Rails.root.join("config")
      FileUtils.cp(file, path)

    rescue Exception => e 
      puts "#{e}"
      puts "there was an issue"
    end

  end 

end
