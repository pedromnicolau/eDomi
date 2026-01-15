class AddClientIdToKanbanCards < ActiveRecord::Migration[8.0]
  def change
    add_column :kanban_cards, :client_id, :bigint
    add_foreign_key :kanban_cards, :people, column: :client_id
  end
end
