module OpenStreetMap
  # OpenStreetMap Way.
  #
  # To create a new OpenStreetMap::Way object:
  #   way = OpenStreetMap::Way.new()
  #
  # To get a way from the API:
  #   way = OpenStreetMap::Way.find_way(17)
  #
  class Way < Element
    # Array of node IDs in this way.
    attr_reader :nodes

    # Create new Way object.
    #
    # id:: ID of this way. If +nil+ a new unique negative ID will be allocated.
    # user:: Username
    # timestamp:: Timestamp of last change
    # nodes:: Array of Node objects and/or node IDs
    def initialize(attrs = {})
      attrs.stringify_keys!
      @nodes = []
      super(attrs)
    end

    def type
        'Way'
    end

    # Add one or more tags or nodes to this way.
    #
    # The argument can be one of the following:
    #
    # * If the argument is a Hash or an OSM::Tags object, those tags are added.
    # * If the argument is an OSM::Node object, its ID is added to the list of node IDs.
    # * If the argument is an Integer or String containing an Integer, this ID is added to the list of node IDs.
    # * If the argument is an Array the function is called recursively, i.e. all items in the Array are added.
    #
    # Returns the way to allow chaining.
    #
    # call-seq: way << something -> Way
    #
    def <<(stuff)
      case stuff
        when Array  # call this method recursively
          stuff.each do |item|
            self << item
          end
        when OpenStreetMap::Node
          nodes << stuff.id
        when String
          nodes << stuff.to_i
        when Integer
          nodes << stuff
        else
          tags.merge!(stuff)
       end
       self    # return self to allow chaining
    end


    # The list of attributes for this Way
    def attribute_list # :nodoc:
      [:id, :version, :uid, :user, :timestamp, :changeset]
    end

    def to_xml(options = {})
      options[:indent] ||= 0
      xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
      xml.instruct! unless options[:skip_instruct]
      xml.osm do
        xml.way(attributes) do
          tags.each do |k,v|
            xml.tag(:k => k, :v => v)
          end unless tags.empty?
          nodes.each do |node_id|
            xml.nd(:ref => node_id)
          end unless nodes.empty?
        end
      end
    end
  end
end