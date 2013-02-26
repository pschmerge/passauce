class CreatePassTable < ActiveRecord::Migration
  def self.up
    create_table :pass_locations do |t|
      t.float :latitude
      t.float :longitude
      t.references :pass

      t.timestamps
    end

    create_table :pass_barcodes do |t|
      t.string :message
      t.string :format
      t.string :message_encoding
      t.references :pass

      t.timestamps
    end

    create_table :passes do |t|
      t.integer :format_version
      t.string :pass_type_identifier
      t.string :serial_number 
      t.string :team_identifier
      t.string :web_service_url
      t.string :authentication_token
      t.datetime :relevant_date
      t.string :organization_name
      t.string :description
      t.string :logo_text
      t.string :foreground_color
      t.string :background_color
      t.string :pass_type

      t.text :header_fields
      t.text :primary_fields
      t.text :secondary_fields
      t.text :auxiliary_fields
      t.text :back_fields

      t.string :passable_type
      t.integer :passable_id
      t.timestamps
    end
  end

  def self.down
    drop_table :pass_locations
    drop_table :pass_barcodes
    drop_table :passes
  end
end

