module Etikett
  class Tag < ActiveRecord::Base
    has_and_belongs_to_many :tag_categories
    has_many :tag_objects, class_name: 'Etikett::TagObject'
    has_many :tag_synonyms

    has_many :courses, through: :tag_objects, source: :taggable, source_type: 'Course'

    belongs_to :tag_type

    validates :name, uniqueness: true

    def create_valid_tag_name!
      i = 0
      until(valid? || !errors.include?(:name)) do
        scanned_name = self.name.scan(/\A(.+_)(\d+)\z/).flatten
        if scanned_name.any?
          self.name = [scanned_name[0], (scanned_name[1].to_i + 1)].join
        else
          self.name = "#{self.name}_0"
        end
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

    def self.search params, limit=10
      query = Etikett::Tag
      if params[:category_id]
        query = query.joins(:tag_categories).where('etikett_tag_categories.id = ?', params[:category_id])
      end
      query = query.where("etikett_tags.name ILIKE '%#{params[:query]}%'").limit(limit)
      query
    end

    def self.fetch params
      if params.include? :query
        etiketts = Etikett::Tag.search(params)
      elsif params.include?(:taggable_type)
        if params[:taggable_id].present?
          etiketts = Etikett::Tag.joins(:tag_objects).
            where("etikett_tag_objects.taggable_id IN (?) and etikett_tag_objects.taggable_type = ?",params[:taggable_id], CGI::unescape(params[:taggable_type])).
            group("etikett_tags.id").
            having("COUNT(etikett_tags.id) = ?", Array(params[:taggable_id]).count).
            order("generated desc, name asc")
        else
          etiketts = Etikett::Tag.none
        end
      else
        etiketts = Etikett::Tag.all
      end
      if params[:tag_type_name]
        etiketts = etiketts.joins(:tag_type).where('etikett_tag_types.name = ?', params[:tag_type_name])
      end
      etiketts
    end

    def is_prime_for? taggable_type, taggable_id
      Etikett::TagObject.find_by(taggable_type: taggable_type,
        taggable_id: taggable_id, prime: true, tag: self).present?
    end
  end
end
