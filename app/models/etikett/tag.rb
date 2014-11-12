module Etikett
  class Tag < ActiveRecord::Base
    has_and_belongs_to_many :tag_categories, class_name: 'Etikett::TagCategory'
    has_many :tag_mappings, class_name: 'Etikett::TagMapping', dependent: :destroy
    has_many :tag_synonyms, dependent: :destroy

    belongs_to :prime, polymorphic: true

    validates :name, uniqueness: true, if: :name_changed?

    default_scope -> { order(id: :asc) }

    attr_accessor :typ

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
      klass = params[:class].presence
      if klass.respond_to? :each
        query = Etikett::Tag
      else
        query = klass.try(:constantize) || Etikett::Tag
      end
      if params[:category_id].present?
        query = query.joins(:tag_categories).where('etikett_tag_categories.id = ?', params[:category_id])
      end
      if params[:only_prime].present?
        query = query.where("etikett_tags.prime_id IS NOT NULL")
      end
      if klass.respond_to?(:each) && (klass.length > 1 || klass[0] != 'Etikett::Tag')
        query = query.where(type: klass)
      end
      query = query.where("etikett_tags.name ILIKE ?", "%#{params[:query]}%").limit(limit)
      query
    end

    def self.fetch params
      if params.include? :query
        etiketts = Etikett::Tag.search(params)
      elsif params.include?(:taggable_type)
        if params[:taggable_id].present?
          etiketts = Etikett::Tag.joins(:tag_mappings).
            where("etikett_tag_mappings.taggable_id IN (?) and etikett_tag_mappings.taggable_type = ?",params[:taggable_id], CGI::unescape(params[:taggable_type])).
            group("etikett_tags.id").
            having("COUNT(etikett_tags.id) = ?", Array(params[:taggable_id]).count).
            order("generated desc, name asc")
        else
          etiketts = Etikett::Tag.none
        end
      else
        etiketts = Etikett::Tag.all
      end
      etiketts
    end

    def is_prime_for? obj_type, obj_id
      prime_type && prime_type == obj_type && prime_id && prime_id == obj_id
    end

    def taggables
      tag_mappings.includes(:taggable).map(&:taggable)
    end

    def global?
      false
    end
  end
end
