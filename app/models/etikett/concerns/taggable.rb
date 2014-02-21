module Etikett
  module Taggable
    extend ActiveSupport::Concern

    included do

      has_many :tag_mappings, as: :taggable, class_name: 'Etikett::TagMapping', dependent: :destroy
      has_many :tags, through: :tag_mappings, class_name: 'Etikett::Tag'

    end

    def create_automated_tag
      settings = auto_tag_settings
      t = master_tag_class.new(
          name: settings[:sid],
          nice: settings[:nice],
          generated: true,
          prime: self
      )
      t.create_valid_tag_name!
      t.save!
      puts t.inspect
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
      raise "master_tag block should give a hash with at least a :sid key." if settings[:sid].blank?
      settings
    end
    # def navigate_to
    #   t = Etikett::Tag.where(taggable: self)
    #   t.get_path
    # end

    # def prime_tag
    #   Etikett::Tag.joins(:tag_objects).find_by(etikett_tag_objects: {taggable_id: self, taggable_type: self.class, prime: true})
    # end


    module ClassMethods

      attr_accessor :tag_config
      attr_accessor :taggable_automated_tag

      def master_tag &block
        self.tag_config = block
        klassname = self.name
        klass = "#{klassname}Tag"
        mapping_klass = "#{klass}Mapping"
        inherited_class = Class.new(Etikett::Tag) do
          relname = klassname.underscore
          # create 'direct' relation
          belongs_to relname.to_sym, foreign_key: :prime_id
          define_method "#{relname}=" do raise "Don't call!" end
          # make proper polymorphic association, too
          belongs_to :prime, polymorphic: true
          before_validation do
            self.prime = self.send relname
          end
          validates_uniqueness_of :prime_id, scope: :prime_type
        end

        Etikett.const_set(klass, inherited_class)

        define_method :master_tag_class do
          inherited_class
        end

        inherited_mapping_class = Class.new(Etikett::TagMapping) do
          belongs_to klassname.underscore.to_sym
        end
        puts mapping_klass
        Etikett.const_set(mapping_klass, inherited_mapping_class)

        has_one :master_tag, class_name: "Etikett::#{klass}", foreign_key: :prime_id

        after_create :create_automated_tag
        after_update :update_automated_tag

      end # master_tag

      def has_many_tags name, class_name: nil
        raise "association #{name} already exists" if self.reflect_on_association(name.to_sym).present?
        # users_tags
        klass = name.to_s.camelize.singularize
        tag_class = "Etikett::#{klass}Tag"
        # target_tags_name = "#{name}_tags"
        singular = name.to_s.singularize
        through_name = "#{singular}_tags".to_sym

        has_many "#{singular}_tag_mappings".to_sym, as: :taggable, class_name: "Etikett::#{klass}TagMapping"

        has_many through_name, through: "#{singular}_tag_mappings".to_sym, class_name: "::Etikett::#{klass}Tag", source: :tag

        has_many name, through: through_name, class_name: klass.to_s
        # has_many target_tag_name.to_sym,
        #   ->{joins(:tag_type).where("etikett_tag_types.name = '#{tag_type}'")},
        #   class_name: 'Etikett::Tag', as: :taggable

        # target_tag_objects_name = "#{name}_tag_objects"
        # has_many target_tag_objects_name.to_sym,
        #   ->{joins(:tag_type).where("etikett_tag_types.name = '#{tag_type}'")},
        #   class_name: 'Etikett::TagObject', as: :taggable
        # has_many target, through: target_tag_objects_name, as: :object
      end
    end # ClassMethods
  end # Taggable
end # Etikett
