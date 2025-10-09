class CreatePropertyPhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :property_photos do |t|
      t.references :property, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
