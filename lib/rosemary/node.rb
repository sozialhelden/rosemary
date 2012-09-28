require 'builder'
module Rosemary
  # OpenStreetMap Node.
  #
  # To create a new Rosemary::Node object:
  #   node = Rosemary::Node.new(:id => "123", :lat => "52.2", :lon => "13.4", :changeset => "12", :user => "fred", :uid => "123", :visible => true, :timestamp => "2005-07-30T14:27:12+01:00")
  #
  # To get a node from the API:
  #   node = Rosemary::Node.find(17)
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
      attrs = attrs.dup.stringify_keys!
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
      xml = options[:builder] ||= Builder::XmlMarkup.new
      xml.instruct! unless options[:skip_instruct]
      xml.osm(:generator => "rosemary v#{Rosemary::VERSION}", :version => Rosemary::Api::API_VERSION) do
        xml.node(attributes) do
          tags.to_xml(:builder => xml, :skip_instruct => true)
        end
      end
    end

    def <=>(another_node)
      parent_compare = super(another_node)
      # don't bother to compare more stuff if parent comparison failed
      return parent_compare unless parent_compare == 0

      tags_compare = self.send(:tags).sort <=> another_node.send(:tags).sort
      # don't bother to compare more stuff if tags comparison failed
      return tags_compare unless tags_compare == 0

      0
    end


  end
end