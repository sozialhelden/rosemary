require 'builder'
module OpenStreetMap
  # OpenStreetMap Node.
  #
  # To create a new OpenStreetMap::Node object:
  #   node = OpenStreetMap::Node.new(:id => "123", :lat => "52.2", :lon => "13.4", :changeset => "12", :user => "fred", :uid => "123", :visible => true, :timestamp => "2005-07-30T14:27:12+01:00")
  #
  # To get a node from the API:
  #   node = OpenStreetMap::Node.find(17)
  #
  class Node < Element
    # Longitude in decimal degrees
    attr_accessor :lon

    # Latitude in decimal degrees
    attr_accessor :lat

    validates :lat, :presence => true, :numericality => {:greater_than_or_equal_to => -180, :less_than_or_equal_to => 180}
    validates :lon, :presence => true, :numericality => {:greater_than_or_equal_to => -90,  :less_than_or_equal_to => 90}

    # Create new Node object.
    #
    # If +id+ is +nil+ a new unique negative ID will be allocated.
    def initialize(attrs = {})
      attrs.stringify_keys!
      @lon = attrs['lon'].to_f rescue nil
      @lat = attrs['lat'].to_f rescue nil
      super(attrs)
    end

    def type
      'Node'
    end

    # List of attributes for a Node
    def attribute_list
      [:id, :version, :uid, :user, :timestamp, :lon, :lat, :changeset]
    end

    def to_xml(options = {})
      options[:indent] ||= 0
      xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
      xml.instruct! unless options[:skip_instruct]
      xml.osm do
        xml.node(attributes) do
          tags.to_xml(:builder => xml, :indent => 2, :skip_instruct => true)
        end
      end
    end

  end
end