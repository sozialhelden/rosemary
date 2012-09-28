module Rosemary
  # OpenStreetMap Relation.
  #
  # To create a new Rosemary::Relation object:
  #   relation = Rosemary::Relation.new()
  #
  # To get a relation from the API:
  #   relation = Rosemary::Relation.find(17)
  #
  class Relation < Element
    # Array of Member objects
    attr_reader :members

    # Create new Relation object.
    #
    # If +id+ is +nil+ a new unique negative ID will be allocated.
    def initialize(attrs)
      attrs.stringify_keys!
      @members = extract_member(attrs['member'])
      super(attrs)
    end

    def type
      'relation'
    end

    # Return XML for this relation. This method uses the Builder library.
    # The only parameter ist the builder object.
    def to_xml(options = {})
      xml = options[:builder] ||= Builder::XmlMarkup.new
      xml.instruct! unless options[:skip_instruct]
      xml.osm(:generator => "rosemary v#{Rosemary::VERSION}", :version => Rosemary::Api::API_VERSION) do
        xml.relation(attributes) do
          members.each do |member|
            member.to_xml(:builder => xml, :skip_instruct => true)
          end
          tags.to_xml(:builder => xml, :skip_instruct => true)
        end
      end
    end

    def <=>(another_relation)
      parent_compare = super(another_relation)
      # don't bother to compare more stuff if parent comparison failed
      return parent_compare unless parent_compare == 0

      return -1 if self.send(:tags) != another_relation.send(:tags)

      members_compare = self.send(:members).sort <=> another_relation.send(:members).sort
      # don't bother to compare more stuff if nodes comparison failed
      return members_compare unless members_compare == 0

      0
    end


    protected

    def extract_member(member_array)
      return [] unless member_array && member_array.size > 0

      member_array.inject([]) do |memo, member|
        class_to_instantize = "Rosemary::#{member['type'].classify}".constantize
        memo << class_to_instantize.new(:id => member['ref'])
      end
    end

  end
end