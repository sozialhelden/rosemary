require 'builder'
class OpenStreetMap
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
    attr_reader :lon

    # Latitude in decimal degrees
    attr_reader :lat

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
      [:id, :version, :uid, :user, :timestamp, :lon, :lat]
    end

    def to_xml(options = {})
      options[:indent] ||= 0
      xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
      xml.instruct! unless options[:skip_instruct]
      xml.osm do
        xml.node(attributes) do
          tags.each do |k,v|
            xml.tag(:k => k, :v => v)
          end unless tags.empty?
        end
      end
    end

  end
end