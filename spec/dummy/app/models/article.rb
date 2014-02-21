class Article < ActiveRecord::Base
  include Etikett::Taggable
end
