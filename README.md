# Passauce

Passauce is a gem for easily creating Apple Passbook passes from `ActiveRecord` models. The passes passuace creates are easily configurable and give full control to the developer for designing passes. 

Passauce includes the pre-made Apple templates as a starting point for you to generate passes. There are five basic passes, each of which pas sauce supports. Those types are: 

- Boarding Pass
- Coupon
- Generic
- Store Card
- Event Ticket

## Gem Installation

Add this line to your application's Gemfile:

    gem 'passauce'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install passauce
    
## Setup
Make sure to run the setup rake task. The rake task will create the configuration file `passauce.yml` and also install the pass templates to `vendor/assets/passes`

	rake passauce:setup
	
Passauce will create a table where your pass metadata will be saved. Be sure to run:

	rake db:migrate
	
### Configuration
	development:
	  cert_path: <your apple passbook cert>.p12
	  cert_password: <your_password>
	  wwdr_cert_path: <your wwdr intermediate cert>.cer
	  format: 'PKBarcodeFormatQR'
	  messageEncoding: 'iso-8859-1'
	  format_version: 1
	  pass_type_identifier: 'pass_type_identifier'
	  team_identifier: 'team_identifier'
	  web_service_url: 'web_service_url'
	  authentication_token: 'authentication_token'
	  organization_name: 'organization_name'
	  description: 'description'
	  logo_text: 'logo_text'
	  foreground_color: 'rgb(255, 255, 255)'
	  background_color: 'rgb(60, 65, 76)'
	  
	test:
	  cert_path: <your apple passbook cert>.p12
	  cert_password: <your_password>
	  wwdr_cert_path: <your wwdr intermediate cert>.cer
	  format: 'PKBarcodeFormatQR'
	  messageEncoding: 'iso-8859-1'
	  format_version: 1
	  pass_type_identifier: 'pass_type_identifier'
	  team_identifier: 'team_identifier'
	  web_service_url: 'web_service_url'
	  authentication_token: 'authentication_token'
	  organization_name: 'organization_name'
	  description: 'description'
	  logo_text: 'logo_text'
	  foreground_color: 'rgb(255, 255, 255)'
	  background_color: 'rgb(60, 65, 76)'
	
	production:	
	  cert_path: <your apple passbook cert>.p12
	  cert_password: <your_password>
	  wwdr_cert_path: <your wwdr intermediate cert>.cer
	  format: 'PKBarcodeFormatQR'
	  messageEncoding: 'iso-8859-1'
	  format_version: 1
	  pass_type_identifier: 'pass_type_identifier'
	  team_identifier: 'team_identifier'
	  web_service_url: 'web_service_url'
	  authentication_token: 'authentication_token'
	  organization_name: 'organization_name'
	  description: 'description'
	  logo_text: 'logo_text'
	  foreground_color: 'rgb(255, 255, 255)'
	  background_color: 'rgb(60, 65, 76)'

## Usage
I created this gem in order to issue users a visitor's pass when they visit. The example below outlines this simple relationship: 

	class User < ActiveRecord::Base	
	  has_one_pass
	
	  …
	  
	  def generate_pass 
	  	pass = Passauce::Pass.new
    	pass.pass_type = Passauce::Pass::EVENT_TICKET

    	user_name = "#{first_name} #{last_name}".upcase

    	pass.set_header_field "header", { :label => '', :value => 'VISITOR' }
    	pass.set_primary_field "primary", { :label => '', :value => "#{user_name}" }
    	pass.set_secondary_field "secondary", { :label => 'email:', :value => "#{email_address}".downcase }
    	self.pass = pass
    	self.save
	  end
	
	
	end
	
## Customizing
Before continuing, please refer to the [Apple Passbook documentation](http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/PassKit_PG/Chapters/Introduction.html).

Customizing the look and feel of your pass can be done by modifying the pass templates installed to your RAILS_ROOT/vendor/assets/passes path. Files are specifically named *by apple* changing file names will probably screw things up, so be careful. 

If you have screwed things up irrevocably, run the rake task again it it will automagically fix things. 

## TODO

- Locations
- Apple Push Notification / web service integration
