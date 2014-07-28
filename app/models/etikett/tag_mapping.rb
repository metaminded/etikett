class Etikett::TagMapping < ActiveRecord::Base
  belongs_to :tag, class_name: 'Etikett::Tag'
  belongs_to :taggable, polymorphic: true

  def usage_key
    "#{taggable_type.underscore}.#{typ}"
  end
end
