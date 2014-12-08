class Article < ActiveRecord::Base
  include Etikett::Taggable

  belongs_to_tag :author, class_name: 'User'
end
