class AddReplyAndReactionsToKanbanComments < ActiveRecord::Migration[8.0]
  def change
    add_reference :kanban_comments, :parent_comment, foreign_key: { to_table: :kanban_comments }
    add_column :kanban_comments, :likes_count, :integer, default: 0
    add_column :kanban_comments, :reactions, :json, default: []
  end
end
