module Rosemary
  # This is a virtual parent class for the OSM objects Node, Way and Relation.
  class Element
    include ActiveModel::Validations
    include Comparable

    # Unique ID
    # @return [Fixnum] id of this element
    attr_reader :id

    # The version of this object (as read from file, it
    # is not updated by operations to this object)
    # API 0.6 and above only
    # @return [Fixnum] the current version
    attr_accessor :version

    # The user who last edited this element (as read from file, it
    # is not updated by operations to this object)
    # @return [Rosemary::User] the user who last edititd this element
    attr_accessor :user

    # The user id of the user who last edited this object (as read from file, it
    # is not updated by operations to this object)
    # API 0.6 and above only
    attr_accessor :uid

    # Last change of this object (as read from file, it is not
    # updated by operations to this object)
    # @return [Time] last change of this object.
    attr_reader :timestamp

    # The changeset the last change of this object was made with.
    attr_accessor :changeset

    # Tags for this object
    attr_reader :tags

    # Get Rosemary::Element from API
    # @param [Fixnum] id the id of the element to load from the API

    def self.from_api(id, api=Rosemary::API.new) #:nodoc:
        raise NotImplementedError.new('Element is a virtual base class for the Node, Way, and Relation classes') if self.class == Rosemary::Element
        api.get_object(type, id)
    end

    def initialize(attrs = {}) #:nodoc:
      raise NotImplementedError.new('Element is a virtual base class for the Node, Way, and Relation classes') if self.class == Rosemary::Element
      attrs = {'version' => 1, 'uid' => 1}.merge(attrs.stringify_keys!)
      @id         = attrs['id'].to_i if attrs['id']
      @version    = attrs['version'].to_i
      @uid        = attrs['uid'].to_i
      @user       = attrs['user']
      @timestamp  = Time.parse(attrs['timestamp']) rescue nil
      @changeset  = attrs['changeset'].to_i
      @tags       = Tags.new
      add_tags(attrs['tag']) if attrs['tag']
    end

    def <=>(another_element)
      attribute_list.each do |attrib|
        next if self.send(attrib) == another_element.send(attrib)

        if self.send(attrib) < another_element.send(attrib)
          return -1
        else
          return 1
        end
      end
      0
    end

    # Create an error when somebody tries to set the ID.
    # (We need this here because otherwise method_missing will be called.)
    def id=(id) # :nodoc:
      raise NotImplementedError.new('id can not be changed once the object was created')
    end

    # Set timestamp for this object.
    # @param [Time] timestamp the time this object was created
    def timestamp=(timestamp)
      @timestamp = _check_timestamp(timestamp)
    end

    # The list of attributes for this object
    def attribute_list # :nodoc:
      [:id, :version, :uid, :user, :timestamp, :changeset, :tags]
    end

    # Returns a hash of all non-nil attributes of this object.
    #
    # Keys of this hash are <tt>:id</tt>, <tt>:user</tt>,
    # and <tt>:timestamp</tt>. For a Node also <tt>:lon</tt>
    # and <tt>:lat</tt>.
    #
    # call-seq: attributes -> Hash
    #
    def attributes
      attrs = Hash.new
      attribute_list.each do |attribute|
        value = self.send(attribute)
        attrs[attribute] = value unless value.nil?
      end
      attrs
    end

    # Get tag value
    def [](key)
      tags[key]
    end

    # Set tag
    def []=(key, value)
      tags[key] = value
    end

    # Add one or more tags to this object.
    #
    # call-seq: add_tags(Hash) -> OsmObject
    #
    def add_tags(new_tags)
      case new_tags
      when Array # Called with an array
        # Call recursively for each entry
        new_tags.each do |tag_hash|
          add_tags(tag_hash)
        end
      when Hash # Called with a hash
        #check if it is weird {'k' => 'key', 'v' => 'value'} syntax
        if (new_tags.size == 2 && new_tags.keys.include?('k') && new_tags.keys.include?('v'))
          # call recursively with values from k and v keys.
          add_tags({new_tags['k'] => new_tags['v']})
        else
          # OK, this seems to be a proper ruby hash with a single entry
          new_tags.each do |k,v|
            self.tags[k] = v
          end
        end
      end
      self    # return self so calls can be chained
    end

    def update_attributes(attribute_hash)
      dirty = false
      attribute_hash.each do |key,value|
        if self.send(key).to_s != value.to_s
          self.send("#{key}=", value.to_s)
          dirty = true
        end
      end
      dirty
    end


    # Has this object any tags?
    #
    # @return [Boolean] has any tags?
    #
    def is_tagged?
      ! @tags.empty?
    end

    # Create a new GeoRuby::Shp4r::ShpRecord with the geometry of
    # this object and the given attributes.
    #
    # This only works if the GeoRuby library is included.
    #
    # geom:: Geometry
    # attributes:: Hash with attributes
    #
    # call-seq: shape(attributes) -> GeoRuby::Shp4r::ShpRecord
    #
    # Example:
    #   require 'rubygems'
    #   require 'geo_ruby'
    #   node = Node(nil, nil, nil, 7.84, 54.34)
    #   g = node.point
    #   node.shape(g, :type => 'Pharmacy', :name => 'Hyde Park Pharmacy')
    #
    def shape(geom, attributes)
      fields = Hash.new
      attributes.each do |key, value|
        fields[key.to_s] = value
      end
      GeoRuby::Shp4r::ShpRecord.new(geom, fields)
    end

    # Get all relations from the API that have his object as members.
    #
    # The optional parameter is an Rosemary::API object. If none is specified
    # the default OSM API is used.
    #
    # Returns an array of Relation objects or an empty array.
    #
    def get_relations_from_api(api=Rosemary::API.new)
      api.get_relations_referring_to_object(type, self.id.to_i)
    end

    # Get the history of this object from the API.
    #
    # The optional parameter is an Rosemary::API object. If none is specified
    # the default OSM API is used.
    #
    # Returns an array of Rosemary::Node, Rosemary::Way, or Rosemary::Relation objects
    # with all the versions.
    def get_history_from_api(api=Rosemary::API.new)
      api.get_history(type, self.id.to_i)
    end

    # All other methods are mapped so its easy to access tags: For
    # instance obj.name is the same as obj.tags['name']. This works
    # for getting and setting tags.
    #
    #   node = Rosemary::Node.new
    #   node.add_tags( 'highway' => 'residential', 'name' => 'Main Street' )
    #   node.highway                   #=> 'residential'
    #   node.highway = 'unclassified'  #=> 'unclassified'
    #   node.name                      #=> 'Main Street'
    #
    # In addition methods of the form <tt>key?</tt> are used to
    # check boolean tags. For instance +oneway+ can be 'true' or
    # 'yes' or '1', all meaning the same.
    #
    #   way.oneway?
    #
    # will check this. It returns true if the value of this key is
    # either 'true', 'yes' or '1'.
    def method_missing(method, *args)
      methodname = method.to_s
      if methodname.slice(-1, 1) == '='
        if args.size != 1
          raise ArgumentError.new("wrong number of arguments (#{args.size} for 1)")
        end
        tags[methodname.chop] = args[0]
      elsif methodname.slice(-1, 1) == '?'
        if args.size != 0
          raise ArgumentError.new("wrong number of arguments (#{args.size} for 0)")
        end
        tags[methodname.chop] =~ /^(true|yes|1)$/
      else
        if args.size != 0
          raise ArgumentError.new("wrong number of arguments (#{args.size} for 0)")
        end
        tags[methodname]
      end
    end

    def initialize_copy(from)
      super
      @tags = from.tags.dup
    end

    def self.from_xml(xml)
      Parser.call(xml, :xml)
    end

    private

    # Return next free ID
    def _next_id
        @@id -= 1
        @@id
    end

    def _check_id(id)
        if id.kind_of?(Integer)
            return id
        elsif id.kind_of?(String)
            raise ArgumentError, "ID must be an integer" unless id =~ /^-?[0-9]+$/
            return id.to_i
        else
            raise ArgumentError, "ID must be integer or string with integer"
        end
    end

    def _check_timestamp(timestamp)
        if timestamp !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(Z|([+-][0-9]{2}:[0-9]{2}))$/
            raise ArgumentError, "Timestamp is in wrong format (must be 'yyyy-mm-ddThh:mm:ss(Z|[+-]mm:ss)')"
        end
        timestamp
    end

    def _check_lon(lon)
        if lon.kind_of?(Numeric)
            return lon.to_s
        elsif lon.kind_of?(String)
            return lon
        else
            raise ArgumentError, "'lon' must be number or string containing number"
        end
    end

    def _check_lat(lat)
        if lat.kind_of?(Numeric)
            return lat.to_s
        elsif lat.kind_of?(String)
            return lat
        else
            raise ArgumentError, "'lat' must be number or string containing number"
        end
    end

  end
end