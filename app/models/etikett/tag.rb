module Etikett
  class Tag < ActiveRecord::Base
    has_and_belongs_to_many :tag_categories
    has_many :tag_objects
    has_many :tag_synonyms

    validates :name, uniqueness: true

    def create_valid_tag_name!
      i = 0
      until(valid? || !errors.include?(:name)) do
          self.name = "#{self.name}_#{i}"
          i += 1
      end
    end

    def self.search_by_tag_name name
      t = Etikett::Tag.where(name: name)
      ts = Etikett::TagSynonym.includes(:tag).where(name: name)
      found_tags = Array(t)
      ts.each do |synonym|
        found_tags << synonym.tag
      end
      found_tags
    end

    def to_json
      {id: id, title: name}
    end
  end
end
