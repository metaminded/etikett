require "etikett/engine"
require_relative "../app/models/etikett/concerns/taggable"
require_relative "../app/models/etikett/concerns/searchable_concern"

module Etikett
  def self.table_name_prefix
    'etikett_'
  end
end

