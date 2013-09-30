module Etikett
  module SearchableConcern
    extend ActiveSupport::Concern

    included do
      after_create :create_searchable
      after_save :insert_tsvector
      after_destroy :destroy_tsvector
      def create_searchable
        if self.class.enabled
          Etikett::Searchable.create(ref_id: self.id, ref_type: self.class.to_s)
        end
      end

      def insert_tsvector
        # if self.class.enabled
          self.class.searchable_string ||= []
          self.class.full_text_searchable_string ||= []
          search_string = self.class.searchable_string.map{|sym| self.send(sym)}.join(' ')
          full_string = self.class.full_text_searchable_string.map{|sym| self.send(sym)}.join(' ')
          s = Etikett::Searchable.find_by(ref_id: self.id, ref_type: self.class.to_s)
          st = ActiveRecord::Base.connection.execute(
            "update etikett_searchables SET short = to_tsvector('de_config', #{ActiveRecord::Base.sanitize(search_string)}),
             fulltext = to_tsvector('de_config', #{ActiveRecord::Base.sanitize(full_string)}) WHERE id = #{s.id}")
        # end
      end

      def destroy_tsvector
        Etikett::Searchable.where(ref_id: self.id, ref_type: self.class.to_s).destroy_all
      end
    end

    module ClassMethods

      attr_accessor :enabled

      attr_accessor :searchable_string
      attr_accessor :full_text_searchable_string

      def searchable *args
        self.enabled = true
        self.searchable_string = args.flatten
      end

      def full_text_searchable *args
        self.enabled = true
        self.full_text_searchable_string = args.flatten
      end
    end
  end
end
