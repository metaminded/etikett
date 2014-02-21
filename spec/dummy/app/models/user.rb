class User < ActiveRecord::Base
  include Etikett::Taggable

  master_tag do
    {sid: "#{first_name} #{last_name}"}
  end

  has_many :posts, dependent: :destroy
end
