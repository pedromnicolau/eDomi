class CreatePropertyPhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :property_photos do |t|
      t.references :property, null: false, foreign_key: true
      t.integer    :position, null: false, default: 1
      t.timestamps
    end

    add_index :property_photos, [ :property_id, :position ], unique: true
  end
end
