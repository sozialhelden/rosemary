class Rosemary::Permissions
  include Enumerable

  attr_reader :raw

  def initialize
    @raw = []
  end

  # make sure we can add permissions and are "Enumerable" via delegation to the permissions array
  delegate :<<, :each, :to => :raw

  # some convenience helpers for permissions we already know:
  %w(allow_read_prefs allow_write_prefs allow_write_diary
     allow_write_api allow_read_gpx allow_write_gpx).each do |name|
    define_method("#{name}?") { raw.include?(name) }
  end
end