class CreateCommissions < ActiveRecord::Migration[8.0]
  def change
    create_table :commissions do |t|
      t.references :sale,    null: false, foreign_key: true
      t.bigint     :agent_id, null: false

      t.decimal    :percentage, precision: 5,  scale: 2, null: false
      t.decimal    :value,      precision: 12, scale: 2, null: false, default: 0

      t.boolean    :paid,    null: false, default: false
      t.datetime   :paid_at

      t.timestamps
    end

    add_foreign_key :commissions, :users, column: :agent_id
    add_index :commissions, [ :sale_id, :agent_id ], unique: true

    add_check_constraint :commissions, "percentage >= 0 AND percentage <= 100", name: "commissions_percentage_range"
    add_check_constraint :commissions, "value >= 0",                             name: "commissions_value_non_negative"
  end
end
