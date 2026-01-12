class CreateKanbanBoardsColumnsCards < ActiveRecord::Migration[8.0]
  def change
    create_table :kanban_boards do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :kanban_columns do |t|
      t.references :kanban_board, null: false, foreign_key: true
      t.string :name, null: false
      t.string :color, default: "#7c8cff"
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :kanban_cards do |t|
      t.references :kanban_column, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.references :assigned_user, foreign_key: { to_table: :users }
      t.integer :position, null: false, default: 0
      t.jsonb :client_info, default: {}
      t.jsonb :tags, default: []
      t.jsonb :checklist, default: []
      t.timestamps
    end

    # ensure jsonb defaults (postgres)
    add_index :kanban_cards, :client_info, using: :gin
    add_index :kanban_cards, :tags, using: :gin
    add_index :kanban_cards, :checklist, using: :gin
  end
end
