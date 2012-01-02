require 'builder'
class OpenStreetMap
  class User
    # Unique ID
    attr_reader :id

    # Display name
    attr_reader :display_name

    def initialize(attrs = {})
      attrs.stringify_keys!
      @id           = attrs['id'].to_i if attrs['id']
      @display_name = attrs['display_name']
    end

  end
end
