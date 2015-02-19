require 'builder'

module Rosemary
  # OpenStreetMap Boundary Box.
  #
  class BoundingBox < Element

    attr_accessor :nodes, :ways, :relations, :minlat, :minlon, :maxlat, :maxlon

    # Create new Node object.
    #
    # If +id+ is +nil+ a new unique negative ID will be allocated.
    def initialize(attrs = {})
      attrs = attrs.dup.stringify_keys!
      @minlat = attrs['minlat'].to_f
      @minlon = attrs['minlon'].to_f
      @maxlat = attrs['maxlat'].to_f
      @maxlon = attrs['maxlon'].to_f

      @nodes = []
      @ways = []
      @relations = []
    end


    def type
      'BoundingBoxBox'
    end

    # List of attributes for a bounds element
    def attribute_list
      [:minlat, :minlon, :maxlat, :maxlon]
    end

    def to_xml(options = {})
      xml = options[:builder] ||= Builder::XmlMarkup.new
      xml.instruct! unless options[:skip_instruct]
      xml.osm(:generator => "rosemary v#{Rosemary::VERSION}", :version => Rosemary::Api::API_VERSION) do
        xml.bounds(attributes)
        [ nodes, ways, relations].each do |elements|
          elements.each { |e| e.to_xml(:builder => xml, :skip_instruct => true) }
        end
      end
    end
  end
end
