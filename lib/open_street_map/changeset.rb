class OpenStreetMap
  class Changeset
    # Unique ID
    attr_reader :id

    # The user who last edited this object (as read from file, it
    # is not updated by operations to this object)
    attr_accessor :user

    # The user id of the user who last edited this object (as read from file, it
    # is not updated by operations to this object)
    # API 0.6 and above only
    attr_accessor :uid

    # True if this changeset is still open.
    attr_accessor :open

    # Creation date of this changeset
    attr_accessor :created_at

    # When the changeset was closed
    attr_accessor :closed_at

    # Bounding box surrounding all changes made in this changeset
    attr_accessor :min_lat, :min_lon, :max_lat, :max_lon

    # Tags for this object
    attr_reader :tags

    def initialize(attrs = {}) #:nodoc:
      attrs.stringify_keys!
      @id         = attrs['id'].to_i if attrs['id']
      @uid        = attrs['uid'].to_i
      @user       = attrs['user']
      @created_at = Time.parse(attrs['created_at']) rescue nil
      @closed_at  = Time.parse(attrs['closed_at']) rescue nil
      @open       = attrs['open']
      @tags       = Tags.new
      @tags[:created_by] = 'osm-client for ruby'
      @min_lat    = attrs['min_lat'].to_f
      @min_lon    = attrs['min_lon'].to_f
      @max_lat    = attrs['max_lat'].to_f
      @max_lon    = attrs['max_lon'].to_f

    end

    # Set timestamp for this object.
    def created_at=(timestamp)
      @created_at = Time.parse(timestamp)
    end

    def open?
      ["yes", "1", "t", "true"].include?(open)
    end

    def to_xml(options = {})
      options[:indent] ||= 0
      xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
      xml.instruct! unless options[:skip_instruct]
      xml.osm do
        xml.changeset do
          tags.each do |k,v|
            xml.tag(:k => k, :v => v)
          end unless tags.empty?
        end
      end
    end

  end
end