# According to the OSM API any changes made to the date need an open changeset which belongs to the user
# executing the changes.
# To keep the code simple the before_save method is included which makes sure and open
module Callbacks

  def self.included(into)
    into.instance_methods(false).select{|method_name| [:save, :create, :update, :destroy].include?(method_name.to_sym)}.each do |m|
      Callbacks.before_write(into, m)
    end

    def into.method_added(m)
      unless @adding
        @adding = true
        if [:save, :create, :update, :destroy].include?(m.to_sym)
          Callbacks.before_write(self, m)
        end
        @adding = false
      end
    end
  end

  def Callbacks.before_write(klass, meth)
    klass.class_eval do
      alias_method "old_#{meth}", "#{meth}"
      define_method(meth) do |*args|
        find_or_create_open_changeset
        self.send("old_#{meth}", *args)
      end
    end
  end
end
