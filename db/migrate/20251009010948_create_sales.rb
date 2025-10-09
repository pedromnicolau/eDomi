class CreateSales < ActiveRecord::Migration[8.0]
  def change
    create_table :sales do |t|
      t.references :property, null: false, foreign_key: true
      t.bigint :agent_id, null: false
      t.bigint :buyer_id
      t.decimal :sale_price, precision: 12, scale: 2
      t.date :sale_date
      t.timestamps
    end

    add_foreign_key :sales, :users, column: :agent_id
    add_foreign_key :sales, :users, column: :buyer_id
    add_index :sales, :property_id, unique: true, name: 'index_sales_on_property'
  end
end
