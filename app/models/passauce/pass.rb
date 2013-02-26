module Passauce

  require 'sign_pass'

  SignPass = ::SignPass

  class PassLocation < ActiveRecord::Base 
    attr_accessible :latitude, :longitude

    belongs_to :pass

    def as_json ( options = { } ) 
      {
        :latitude => latitude, 
        :longitude => longitude
      }
    end
  end

  class PassBarcode < ActiveRecord::Base

    attr_accessible :message

    after_initialize do 
      
      Rails.application.config.passauce.each do |key, value|
        method_key = "#{key}".underscore

        if self.respond_to? method_key.to_sym 
          self.send("#{method_key}=", value) if self.send("#{method_key}").nil?
        end
      end

    end

    def as_json ( option = { } )
      {
        :message => self.message,
        :format => self.format,
        :messageEncoding => self.message_encoding
      }
    end

  end

  class Pass < ActiveRecord::Base

    # types for the pass...
    BOARDING_PASS = "boardingPass"
    COUPON = "coupon"
    EVENT_TICKET = "eventTicket"
    GENERIC = "generic"
    SOTRE_CARD = "storeCard"

    serialize :header_fields, Hash
    serialize :primary_fields, Hash
    serialize :secondary_fields, Hash
    serialize :auxiliary_fields, Hash
    serialize :back_fields, Hash

    has_many :pass_locations
    has_one :pass_barcode

    attr_accessible :format_version, :pass_type_identifier, :team_identifier, 
      :web_service_url, :authentication_token, :locations, :barcode, 
      :organization_name, :description, :logo_text, :foreground_color, 
      :background_color, :pass_type

    attr_accessor :cert_path, :cert_password, :wwdr_cert_path, :output_path

    attr_readonly :serial_number, :header_fields, :primary_fields, 
      :secondary_fields, :auxiliary_fields, :back_fields

    validates :pass_type, :presence => true

    after_save :update_pass

    after_initialize do 
      Rails.application.config.passauce.each do |key, value|
        method_key = "#{key}".underscore

        if self.respond_to? method_key.to_sym 
          self.send("#{method_key}=", value) if self.send("#{method_key}").nil?
        end
      end

      self.pass_barcode ||= PassBarcode.new
    end

    def serial_number
      self.id.nil? ? nil : "%08i" % self.id 
    end

    def set_header_field ( key, hash ) 
      set_field(self.header_fields, key, hash)
    end

    def set_primary_field ( key, hash ) 
      set_field(self.primary_fields, key, hash)
    end

    def set_secondary_field ( key, hash ) 
      set_field(self.secondary_fields, key, hash)
    end

    def set_auxiliary_field ( key, hash ) 
      set_field(self.auxiliary_fields, key, hash)
    end

    def set_back_field ( key, hash ) 
      set_field(self.back_fields, key, hash)
    end

    def add_location ( latitude, longitude ) 
      self.pass_locations << PassLocation.new(:latitude => latitude, :longitude => longitude )
    end

    def as_json ( options = { } )

      header_field_array = field_array(self.header_fields)
      primary_field_array = field_array(self.primary_fields)
      secondary_field_array = field_array(self.secondary_fields)
      auxiliary_field_array = field_array(self.auxiliary_fields)
      back_field_array = field_array(self.back_fields)

      {
        :formatVersion => self.format_version,
        :passTypeIdentifier => self.pass_type_identifier,
        :serialNumber => self.serial_number,
        :teamIdentifier => self.team_identifier,
        :webServiceURL => self.web_service_url,
        :authenticationToken => self.authentication_token,
        :locations => self.pass_locations,
        :barcode => self.pass_barcode,
#         TODO figure out relevant date  
#        : => self.relevant_date
        :organizationName => self.organization_name,
        :description => self.description,
        :logoText => self.logo_text,
        :foregroundColor => self.foreground_color,
        :backgroundColor => self.background_color,
        self.pass_type => { 
          :headerFields => header_field_array, 
          :primaryFields => primary_field_array,
          :secondaryFields => secondary_field_array,
          :auxiliaryFields => auxiliary_field_array,
          :backFields => back_field_array
        }
      }
    end

    def generate_pass

      unless id.nil?
        pass_barcode.message = "%08i" % self.passable_id #serial_number

        create_directory
        write_pass_json
        sign_pass = SignPass.new(raw_pass_dir.to_path, @cert_path, @cert_password,
                                 @wwdr_cert_path, compressed_pass_path.to_path)

        sign_pass.sign_pass!
      else
        puts "Must save pass before attempting to generate"
      end

      self.save
    end

    def path 
      temp_path = compressed_pass_path.to_s
      sub_path = /.*\/(#{output_path}.*)/.match(temp_path)
      sub_path[1]
    end

    private

    def set_field ( hash, key, value ) 
      unless hash.nil?
        hash[key] = value
      else
        hash.delete key
      end
    end

    def field_array ( hash ) 
      array = []

      hash.each do |key, value|
        hash = { } 
        hash[:key] = key
        
        value.each do |value_key, value_value|
          hash[value_key] = value_value
        end

        array << hash
      end

      array
    end

    def create_directory
      # if the pass directory is not nil 
      # AND
      # if the pass directory doesn't exist, create it
      # AND
      # if the raw pass directory does exist, delete it
      # AND
      # the if pass type is not nil
      # AND
      # the vendor/assets/#{pass_type}.raw exists, copy pass contents
      unless pass_dir.nil?
        
        # create the base dir if it doesn't yet exist
        unless File.directory?(pass_dir)
          FileUtils.mkdir_p pass_dir
        end

        if File.directory?(raw_pass_dir)
          FileUtils.rm_rf raw_pass_dir
        end

        unless pass_type.nil?
          if File.directory?("vendor/assets/passes/#{pass_type}.raw")
            FileUtils.cp_r "vendor/assets/passes/#{pass_type}.raw", raw_pass_dir
          end
        end

      end

    end

    def pass_dir 
      dir = nil

      unless id.nil?
        dir = Rails.root.join("#{output_path}/#{id}")
      end

      return dir

    end

    def clean_pass_dir 

      if File.directory? pass_dir
        FileUtils.rm_rf pass_dir
      end

    end

    def raw_pass_dir 
      dir = nil

      unless pass_dir.nil?
        dir = pass_dir.join("#{id}_pass.raw")
      end

      return dir 
    end

    def compressed_pass_path
      path = nil
      unless pass_dir.nil?
        path = pass_dir.join("#{id}_pass.pkpass")
      end

      return path
    end
     
    def write_pass_json
      File.open("#{raw_pass_dir}/pass.json", 'w') { |file| file.write(JSON.pretty_generate(self.as_json)) }
    end

    def update_pass 

      # remove the pass directory for this object if it already exists
      clean_pass_dir 

      # create the pass now
      generate_pass
    end

  end

end
