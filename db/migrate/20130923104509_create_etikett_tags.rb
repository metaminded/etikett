class CreateEtikettTags < ActiveRecord::Migration
  def change
    create_table :etikett_tags do |t|
      t.string :name
      t.boolean :generated, default: false
      t.string :nice
      t.references :prime, polymorphic: true
      t.string :type
      t.timestamps
    end
  end
end
