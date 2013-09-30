class CreateEtikettTagSynonyms < ActiveRecord::Migration
  def change
    create_table :etikett_tag_synonyms do |t|
      t.string :name
      t.references :tag, index: true

      t.timestamps
    end
  end
end
