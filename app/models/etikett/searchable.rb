class Etikett::Searchable < ActiveRecord::Base
  def self.search query, lng="english"
    where("short @@ plainto_tsquery('#{lng}',:q)", q: query)
  end

  def self.full_search query, lng="english"
    rank = <<-RANK
      ts_rank(short, plainto_tsquery('#{lng}',#{sanitize(query)})) +
      ts_rank(fulltext, plainto_tsquery('#{lng}',#{sanitize(query)}))
    RANK
    where("short @@ plainto_tsquery('#{lng}',:q) or fulltext @@ plainto_tsquery('#{lng}', :q)", q: query).order("#{rank} desc")
  end

end
