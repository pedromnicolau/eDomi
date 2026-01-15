class AddPropertyIdToKanbanCards < ActiveRecord::Migration[8.0]
  def change
    add_reference :kanban_cards, :property, null: false, foreign_key: true
  end
end
