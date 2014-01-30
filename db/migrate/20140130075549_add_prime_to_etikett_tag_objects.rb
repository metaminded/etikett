class AddPrimeToEtikettTagObjects < ActiveRecord::Migration
  def change
    add_column :etikett_tag_objects, :prime, :boolean, default: false
  end
end
