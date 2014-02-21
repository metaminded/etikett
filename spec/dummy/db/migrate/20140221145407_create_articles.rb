class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.integer :product_no
      t.string :title

      t.timestamps
    end
  end
end
