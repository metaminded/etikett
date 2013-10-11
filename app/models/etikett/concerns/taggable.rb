
module Etikett
  module Taggable
    extend ActiveSupport::Concern

    included do
      has_many :tag_objects, as: :taggable, class_name: 'Etikett::TagObject'
      has_many :tags, through: :tag_objects, class_name: 'Etikett::Tag'
      after_create :create_automated_tag

      def create_automated_tag
        settings = self.class.tag_config.call(self)
        settings[:sid] ||= "tag:#{self.id}"
        t = Etikett::Tag.new(name: settings[:sid], nice: settings[:nice], generated: true)
        t.create_valid_tag_name!
        ActiveRecord::Base.transaction do
          t.save
          to = Etikett::TagObject.create(tag: t, taggable: self)
        end
      end

      def navigate_to
        t = Etikett::Tag.where(taggable: self)
        t.get_path
      end

    end

    module ClassMethods

      attr_accessor :tag_config
      attr_accessor :taggable_automated_tag

      def master_tag &block
        self.tag_config = block
      end
    end
  end
end
