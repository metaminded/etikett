module Etikett
  module TagAssociations
    extend ActiveSupport::Concern

    module ClassMethods

      # TODO: guess tag_type from target if possible
      # def has_many_tags name, target: nil, tag_type: nil
      #   raise "give target and tag_type parameters" unless target.present? && tag_type.present?
      #   raise "association #{name} already exists" if self.reflect_on_association(name.to_sym).present?
      #   # users_tags
      #   target_tags_name = "#{name}_tags"
      #   has_many target_tag_name.to_sym,
      #     ->{joins(:tag_type).where("etikett_tag_types.name = '#{tag_type}'")},
      #     class_name: 'Etikett::Tag', as: :taggable

      #   target_tag_objects_name = "#{name}_tag_objects"
      #   has_many target_tag_objects_name.to_sym,
      #     ->{joins(:tag_type).where("etikett_tag_types.name = '#{tag_type}'")},
      #     class_name: 'Etikett::TagObject', as: :taggable
      #   has_many target, through: target_tag_objects_name, as: :object
      # end

    end
  end
end

# class AppointmentGroup < ActiveRecord::Base

#   has_many_tags :lecturers, target: :user, tag_type: TagType[:user]

# end


# ap = AppointmentGroup.find(99)
# ap.lecturers <- [Lecturer1, Lecturer2]
