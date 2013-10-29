class Etikett::TagObject < ActiveRecord::Base
  belongs_to :tag, class_name: 'Etikett::Tag'
  belongs_to :taggable, polymorphic: true
end
