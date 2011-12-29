class OpenStreetMap
  # OpenStreetMap Relation.
  #
  # To create a new OpenStreetMap::Relation object:
  #   relation = OpenStreetMap::Relation.new()
  #
  # To get a relation from the API:
  #   relation = OpenStreetMap::Relation.find(17)
  #
  class Relation < Element
    # Array of Member objects
    attr_reader :members

    # Create new Relation object.
    #
    # If +id+ is +nil+ a new unique negative ID will be allocated.
    def initialize(attrs)
      attrs.stringify_keys!
      @members = attrs('members')
      super(attrs)
    end

    def type
      'relation'
    end

  end
end