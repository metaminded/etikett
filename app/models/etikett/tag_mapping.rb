class Etikett::TagMapping < ActiveRecord::Base
  belongs_to :tag, class_name: 'Etikett::Tag'
  belongs_to :taggable, polymorphic: true

  validates :tag, presence: true
  validates :taggable, presence: true, on: :update

  def usage_key
    "#{taggable_type.underscore}.#{typ}"
  end
end
