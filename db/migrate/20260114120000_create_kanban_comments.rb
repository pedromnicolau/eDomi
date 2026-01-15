class CreateKanbanComments < ActiveRecord::Migration[7.0]
  def change
    create_table :kanban_comments do |t|
      t.references :kanban_card, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end
    add_index :kanban_comments, :created_at
  end
end
