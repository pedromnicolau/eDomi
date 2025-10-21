class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string  :title,  null: false
      t.text    :body
      t.boolean :read,   null: false, default: false
      t.timestamps
    end

    add_index :notifications, [ :user_id, :read ]
  end
end
