module OpenStreetMap
  # OpenStreetMap Node.
  #
  # To create a new OSM::Node object:
  #   node = OSM::Node.new(17, 'someuser', '2007-10-31T23:48:54Z', 7.4, 53.2)
  #
  # To get a node from the API:
  #   node = OSM::Node.from_api(17)
  #
  class Node < OsmObject

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

  end
end