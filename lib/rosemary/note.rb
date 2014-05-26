require 'builder'
module Rosemary
  # The note object
  class Note
    # Unique ID
    attr_accessor :id

    attr_accessor :lat
    attr_accessor :lon    
    attr_accessor :text
    attr_accessor :user
    attr_accessor :action

    def initialize(attrs = {})
      attrs.stringify_keys!
      @lat  = attrs['lat']
      @lon  = attrs['lon']
      @text = attrs['text'] || ''
      @user = attrs['user']
      @action = attrs['action'] || ''
    end

  end
end