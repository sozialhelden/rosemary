module OpenStreetMap
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
      @nodes = attrs['nd'].collect{ |node| node.kind_of?(OpenStreetMap::Node) ? node.id : node['ref'].to_i }
      super(attrs)
    end

    def type
        'way'
    end

  end
end