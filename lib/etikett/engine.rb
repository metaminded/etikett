module Etikett
  class Engine < ::Rails::Engine
    config.after_initialize do
      module ::Etikett
        def self.const_missing_with_tag_search(nam)
          # if !const_missing_without_tag_search(nam)
          name = nam.to_s
          begin
            c = const_missing_without_tag_search(nam)
            return c
          rescue NameError => e
          end
          # c
          # const_missing_without_tag_search(nam)
          # return name.constantize
          @_searched_tags ||= []
          raise NameError.new("#{name} not found!") if @_searched_tags.member?(name)
          @_searched_tags << name
          m = /(\w+)TagMapping\Z/.match name
          m ||= /(\w+)Tag\Z/.match name
          if m
            m[1].gsub('_', '::').constantize
            "Etikett::#{name}".constantize
          else
            klass = const_get(nam)
            return klass if klass
            const_missing_without_tag_search(nam)
          end
        end

        class << self
          alias_method_chain :const_missing, :tag_search
        end
      end
    end
  end
end
