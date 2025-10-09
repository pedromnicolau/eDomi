class CreateProperties < ActiveRecord::Migration[8.0]
  def change
    create_table :properties do |t|
      t.string  :title, null: false
      t.text    :description
      t.decimal :price, precision: 12, scale: 2
      t.integer :property_type, default: 0, null: false
      t.decimal :area, precision: 10, scale: 2
      t.integer :bedrooms
      t.integer :bathrooms
      t.integer :parking_spaces
      t.boolean :furnished, default: false
      t.decimal :condominium_fee, precision: 10, scale: 2
      t.decimal :iptu, precision: 10, scale: 2
      t.integer :year_built
      t.string  :address
      t.string  :neighborhood
      t.string  :city
      t.string  :state
      t.string  :zip_code
      t.integer :status, default: 0, null: false
      t.references :agent, foreign_key: { to_table: :users }, null: true
      t.timestamps
    end
  end
end
