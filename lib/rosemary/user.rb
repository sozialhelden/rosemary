require 'builder'
module Rosemary
  class User
    # Unique ID
    attr_reader :id

    # Display name
    attr_reader :display_name

    # When this user was created
    attr_reader :account_created

    # A little prosa about this user
    attr_accessor :description

    # All languages the user can speak
    attr_accessor :languages

    # Lat/Lon Coordinates of the users home.
    attr_accessor :lat, :lon, :zoom

    # A picture from this user
    attr_accessor :img

    def initialize(attrs = {})
      attrs.stringify_keys!
      @id               = attrs['id'].to_i if attrs['id']
      @display_name     = attrs['display_name']
      @account_created  = Time.parse(attrs['account_created']) rescue nil
      @languages         = []
    end

  end
end
