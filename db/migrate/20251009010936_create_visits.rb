class CreateVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :visits do |t|
      t.references :property, null: false, foreign_key: true
      t.bigint :buyer_id, null: false
      t.bigint :agent_id, null: false
      t.datetime :scheduled_at, null: false
      t.integer :status, default: 0, null: false
      t.text :notes
      t.timestamps
    end

    add_foreign_key :visits, :users, column: :buyer_id
    add_foreign_key :visits, :users, column: :agent_id
  end
end
