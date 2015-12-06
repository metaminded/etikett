class Post < ActiveRecord::Base
  include Etikett::Taggable

  master_tag do
    {sid: title}
  end

  belongs_to :user
end
