require 'builder'
module Rosemary
  # The note object
  class Note
    # Unique ID
    attr_accessor :id

    attr_accessor :lat
    attr_accessor :lon    
    attr_accessor :text

    def initialize(attrs = {})
      attrs.stringify_keys!
      @lat  = attrs['lat']
      @lon  = attrs['lon']
      @text = attrs['text'] || ''
    end

  end
end