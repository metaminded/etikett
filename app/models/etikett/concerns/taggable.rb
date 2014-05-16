module Etikett
  module Taggable
    extend ActiveSupport::Concern

    included do
    end

    def create_automated_tag
      settings = auto_tag_settings
      if settings.present?
        t = "Etikett::#{self.class.get_klass_name}Tag".constantize.new(
            name: settings[:sid],
            nice: settings[:nice],
            generated: true,
            prime: self
        )
        t.create_valid_tag_name!
        t.save!
      end
    end

    def update_automated_tag
      settings = auto_tag_settings
      master_tag.assign_attributes(
        name: settings[:sid],
        nice: settings[:nice]
      )
      master_tag.create_valid_tag_name!
      master_tag.save!
    end

    def auto_tag_settings
      raise "I ain't master-tagged!" unless self.class.tag_config
      settings = self.instance_eval &self.class.tag_config
      return if settings.nil?
      raise "master_tag block should give a hash with at least a :sid key." if settings[:sid].blank?
      settings
    end


    module ClassMethods

      attr_accessor :tag_config
      attr_accessor :taggable_automated_tag

      def master_tag &block
        self.tag_config = block
        klassname = self.get_klass_name
        unformatted_name = self.name
        klass = "#{klassname}Tag"
        mapping_klass = "#{klass}Mapping"
        unless Etikett.const_defined?(klass)
          inherited_class = Class.new(Etikett::Tag) do
            relname = klassname.underscore
            # create 'direct' relation
            belongs_to relname.to_sym, foreign_key: :prime_id, class_name: unformatted_name
            define_method "#{relname}=" do raise "Don't call!" end
            # make proper polymorphic association, too
            belongs_to :prime, polymorphic: true
            before_validation do
              self.prime = self.send relname
            end
            validates_uniqueness_of :prime_id, scope: :prime_type
          end

          Etikett.const_set(klass, inherited_class)
        end

        unless Etikett.const_defined?(mapping_klass)
          inherited_mapping_class = Class.new(Etikett::TagMapping) do
            belongs_to klassname.underscore.to_sym
          end
          Etikett.const_set(mapping_klass, inherited_mapping_class)
        end

        has_one :master_tag, class_name: "Etikett::#{klass}", foreign_key: :prime_id

        after_create :create_automated_tag
        after_update :update_automated_tag

      end # master_tag

      def get_klass_name
        self.name.gsub('::', '_')
      end

      def has_many_via_tags name, class_name: nil, after_add: nil, after_remove: nil
        if class_name
          tag_class = "Etikett::#{class_name}Tag"
          klass = class_name
          # Object.const_get(class_name)
        else
          tag_class = "Etikett::#{klass}Tag"
          klass = name.to_s.camelize.singularize.gsub('::', '_')
        end
        # return if defined?("Etikett::#{klass}TagMapping")
        return if self.reflect_on_association(name.to_sym).present?
        # users_tags
        # target_tags_name = "#{name}_tags"
        singular = name.to_s.singularize
        through_name = "#{singular}_tags".to_sym

        has_many "#{singular}_tag_mappings".to_sym, as: :taggable, class_name: "Etikett::#{klass}TagMapping"

        has_many through_name, through: "#{singular}_tag_mappings".to_sym,
          class_name: "::Etikett::#{klass}Tag", source: :tag, after_add: after_add,
          after_remove: after_remove

        has_many name, through: through_name, class_name: klass.to_s, source: klass.downcase.to_sym
      end


      def has_many_tags name = nil, typ: nil
        if typ
          raise "Can not have a general has_many_tags method and one with type #{typ}" if self.respond_to?(:tags)
          @_uses_has_many_tags_with_typ = true
          has_many "#{name}_tag_mappings".to_sym, ->{ where(typ: typ.downcase) }, class_name: "Etikett::TagMapping", dependent: :destroy, as: :taggable
          has_many "#{name}_tags".to_sym, through: "#{name}_tag_mappings".to_sym, class_name: "Etikett::Tag", source: :tag
        else
          raise "Can not have a general has_many_tags method and one with type #{typ}" if @_uses_has_many_tags_with_typ
          has_many :tag_mappings, as: :taggable, class_name: 'Etikett::TagMapping', dependent: :destroy
          has_many :tags, through: :tag_mappings, class_name: 'Etikett::Tag'
        end
      end

    end # ClassMethods
  end # Taggable
end # Etikett
