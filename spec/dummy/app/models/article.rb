class Article < ActiveRecord::Base
  include Etikett::Taggable

  master_tag do
    {sid: title}
  end

  belongs_to_tag :author, class_name: 'User'
end
