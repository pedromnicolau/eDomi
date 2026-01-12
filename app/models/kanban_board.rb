class KanbanBoard < ApplicationRecord
  has_many :kanban_columns, dependent: :destroy

  validates :name, presence: true

  def as_json(options = {})
    super(only: [ :id, :name ]).merge({
      columns: kanban_columns.order(:position).map { |c| c.as_json }
    })
  end
end
