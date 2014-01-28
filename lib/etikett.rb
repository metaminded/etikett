require "etikett/engine"
require_relative "../app/models/etikett/concerns/taggable"
require_relative "../app/models/etikett/concerns/searchable_concern"
require_relative "../app/models/etikett/concerns/tag_associations"

module Etikett
  def self.table_name_prefix
    'etikett_'
  end
end

