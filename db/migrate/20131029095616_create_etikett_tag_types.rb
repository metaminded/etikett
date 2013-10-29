class CreateEtikettTagTypes < ActiveRecord::Migration
  def change
    create_table :etikett_tag_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
