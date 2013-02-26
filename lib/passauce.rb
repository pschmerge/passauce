require "passauce/version"
require "active_support/dependencies"

module Passauce

  mattr_accessor :app_root

  def self.setup
    yield self
  end

  class Railtie < Rails::Engine
    rake_tasks { load "tasks/passauce.rake" }
  end

  require 'passauce/engine' if defined?(Rails)

end


module Passauce
  def self.included(base)
    base.class_eval do 
      extend ClassMethods
    end
  end

  module ClassMethods
    def has_associated_pass 
    end

    def has_many_passes 
      has_many :passes, :as => :passable, :class_name => 'Passauce::Pass', :dependent => :destroy
    end

    def has_one_pass
      has_one :pass, :as => :passable, :class_name => 'Passauce::Pass', :dependent => :destroy
    end

  end

end

ActiveRecord::Base.send(:include, Passauce)

require "passauce/engine"

