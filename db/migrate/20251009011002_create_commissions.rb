class CreateCommissions < ActiveRecord::Migration[8.0]
  def change
    create_table :commissions do |t|
      t.references :sale, null: false, foreign_key: true
      t.bigint :agent_id, null: false
      t.decimal :percentage, precision: 5, scale: 2
      t.decimal :value, precision: 12, scale: 2
      t.boolean :paid, default: false
      t.datetime :paid_at
      t.timestamps
    end

    add_foreign_key :commissions, :users, column: :agent_id
  end
end
