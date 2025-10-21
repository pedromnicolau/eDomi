class CreateSales < ActiveRecord::Migration[8.0]
  def change
    create_table :sales do |t|
      t.references :property, null: false, foreign_key: true

      t.bigint    :agent_id,    null: false
      t.bigint    :buyer_id,    null: false

      t.decimal   :sale_price,  precision: 12, scale: 2, null: false
      t.date      :sale_date,   null: false

      t.timestamps
    end

    add_foreign_key :sales, :users, column: :agent_id
    add_foreign_key :sales, :users, column: :buyer_id

    add_index :sales, :sale_date
    add_index :sales, [ :property_id, :sale_date ]

    add_check_constraint :sales, "sale_price >= 0", name: "sales_price_non_negative"
  end
end
