class AddTagTypeToEtikettTags < ActiveRecord::Migration
  def change
    add_reference :etikett_tags, :tag_type, index: true
  end
end
