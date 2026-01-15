class AddEditHistoryToKanbanCards < ActiveRecord::Migration[8.0]
  def change
    add_column :kanban_cards, :edit_history, :json, default: []
  end
end
