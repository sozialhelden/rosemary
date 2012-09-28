module Rosemary
  # OpenStreetMap Way.
  #
  # To create a new Rosemary::Way object:
  #   way = Rosemary::Way.new()
  #
  # To get a way from the API:
  #   way = Rosemary::Way.find_way(17)
  #
  class Way < Element
    # Array of node IDs in this way.
    # @return [Array]
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
    # @return [Rosemary::Way] the way itself
    #
    def <<(stuff)
      case stuff
        when Array  # call this method recursively
          stuff.each do |item|
            self << item
          end
        when Rosemary::Node
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

    # Instantiate a way from an XML representation.
    # @param [String] xml_string the xml representing a way.
    # @return [Rosemary::Way] the way represented by the given XML string.
    def self.from_xml(xml_string)
      Parser.call(xml_string, :xml)
    end

    def to_xml(options = {})
      xml = options[:builder] ||= Builder::XmlMarkup.new
      xml.instruct! unless options[:skip_instruct]
      xml.osm(:generator => "rosemary v#{Rosemary::VERSION}", :version => Rosemary::Api::API_VERSION) do
        xml.way(attributes) do
          nodes.each do |node_id|
            xml.nd(:ref => node_id)
          end unless nodes.empty?
          tags.to_xml(:builder => xml, :skip_instruct => true)
        end
      end
    end

    def <=>(another_way)
      parent_compare = super(another_way)
      # don't bother to compare more stuff if parent comparison failed
      return parent_compare unless parent_compare == 0

      nodes_compare = self.send(:nodes).sort <=> another_way.send(:nodes).sort
      # don't bother to compare more stuff if nodes comparison failed
      return nodes_compare unless nodes_compare == 0

      tags_compare = self.send(:tags).sort <=> another_way.send(:tags).sort
      # don't bother to compare more stuff if tags comparison failed
      return tags_compare unless tags_compare == 0

      0
    end
  end
end