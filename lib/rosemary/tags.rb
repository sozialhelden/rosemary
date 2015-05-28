module Rosemary
  # A collection of OSM tags which can be attached to a Node, Way,
  # or Relation.
  # It is a subclass of Hash.
  class Tags < Hash

    def coder
      @coder ||= HTMLEntities.new
    end

    # Return XML for these tags. This method uses the Builder library.
    # The only parameter ist the builder object.
    def to_xml(options = {})
      xml = options[:builder] ||= Builder::XmlMarkup.new
      xml.instruct! unless options[:skip_instruct]
      each do |key, value|
        # Remove leading and trailing whitespace from tag values
        xml.tag(:k => key, :v => coder.decode(value.strip)) unless value.blank?
      end unless empty?
    end

    def []=(key, value)
      # Ignore empty values, cause we don't want them in the OSM anyways
      return if value.blank?
      super(key, value)
    end

    # Return string with comma separated key=value pairs.
    #
    # @return [String] string representation
    #
    def to_s
      sort.collect{ |k, v| "#{k}=#{v}" }.join(', ')
    end

  end
end