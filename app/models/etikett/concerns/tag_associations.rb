module Etikett
  module TagAssociations
    extend ActiveSupport::Concern

    module ClassMethods

      def has_many_tags name, options = {}
        return unless options[:through].present? && options[:tag_type].present?
        return if self.reflect_on_association(name.to_sym).present?
        has_many options[:through].to_sym, class_name: 'Etikett::TagObject', as: :taggable
        has_many name.to_sym, -> do 
          joins(:tag_type).where("etikett_tag_types.name = '#{options[:tag_type]}'")
        end, through: options[:through].to_sym, class_name: 'Etikett::Tag', source: :tag
      end

    end
  end
end
