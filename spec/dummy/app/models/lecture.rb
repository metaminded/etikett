class Lecture < ActiveRecord::Base
  include Etikett::Taggable

  master_tag do
    {sid: "#{title}"}
  end

  has_many_via_tags :students, class_name: 'User'
  has_many_via_tags :docents, class_name: 'User'
end
