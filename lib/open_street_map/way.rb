class OpenStreetMap
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
      @nodes = attrs['nd'].collect do |node_hash|
        node_hash.stringify_keys!
        node_hash['ref'].to_i
      end
      super(attrs)
    end

    def type
        'Way'
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