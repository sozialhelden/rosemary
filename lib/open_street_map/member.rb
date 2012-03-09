require 'builder'
module OpenStreetMap
  # A member of an OpenStreetMap Relation.
  class Member

    # Role this member has in the relationship
    attr_accessor :role

    # Type of referenced object (can be 'node', 'way', or 'relation')
    attr_reader :type

    # ID of referenced object
    attr_reader :ref

    # Create a new Member object. Type can be one of 'node', 'way' or
    # 'relation'. Ref is the ID of the corresponding Node, Way, or
    # Relation. Role is a freeform string and can be empty.
    def initialize(type, ref, role='')
      if type !~ /^(node|way|relation)$/
        raise ArgumentError.new("type must be 'node', 'way', or 'relation'")
      end
      if ref.to_s !~ /^[0-9]+$/
          raise ArgumentError
      end
      @type = type
      @ref  = ref.to_i
      @role = role
    end

    # Return XML for this way. This method uses the Builder library.
    # The only parameter ist the builder object.
    def to_xml(xml)
      xml.member(:type => type, :ref => ref, :role => role)
    end

  end
end