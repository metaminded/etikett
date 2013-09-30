class CreateEtikettTagObjects < ActiveRecord::Migration
  def change
    create_table :etikett_tag_objects do |t|
      t.references :taggable, polymorphic: true
      t.references :tag, index: true

      t.timestamps
    end
  end
end
