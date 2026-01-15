class KanbanColumn < ApplicationRecord
  belongs_to :kanban_board
  has_many :kanban_cards, dependent: :destroy

  validates :name, presence: true
  validates :position, presence: true

  def as_json(options = {})
    super(only: [ :id, :name, :color, :position, :kanban_board_id ]).merge({
      cards: kanban_cards.order(:position).map { |c| c.as_json }
    })
  end
end
