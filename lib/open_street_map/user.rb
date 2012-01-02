require 'builder'
class OpenStreetMap
  class User
    # Unique ID
    attr_reader :id

    # Display name
    attr_reader :display_name

    # A little prosa about this user
    attr_reader :description

    # When this user was created
    attr_reader :account_created

    # All languages the user can speak
    attr_reader :languages

    # Lat/Lon Coordinates of the users home.
    attr_reader :lat, :lon

    # A picture from this user
    attr_reader :img

    def initialize(attrs = {})
      attrs.stringify_keys!
      @id               = attrs['id'].to_i if attrs['id']
      @display_name     = attrs['display_name']
      @lat              = attrs['home']['lat'].to_f
      @lon              = attrs['home']['lon'].to_f
      @languages        = attrs['languages']['lang'] if attrs['languages']
      @description      = attrs['description']
      @account_created  = Time.parse(attrs['account_created']) rescue nil
      @img              = attrs['img']['href'] if attrs['img']
    end

  end
end
