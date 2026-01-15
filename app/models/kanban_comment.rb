class KanbanComment < ApplicationRecord
  belongs_to :kanban_card
  belongs_to :user, optional: true
  belongs_to :parent_comment, class_name: "KanbanComment", optional: true
  has_many :replies, class_name: "KanbanComment", foreign_key: :parent_comment_id, dependent: :destroy

  validates :body, presence: true

  def as_json(options = {})
    base = super(only: [ :id, :body, :created_at, :updated_at, :likes_count, :parent_comment_id ])
    base[:user] = user&.slice(:id, :name, :email)
    base[:reactions] = reactions || []
    base[:replies] = replies.map(&:as_json) if replies.any?
    base
  end

  def add_like(user_id)
    self.reactions ||= []
    self.reactions << { type: "like", user_id: user_id, created_at: Time.current }
    self.likes_count = (likes_count || 0) + 1
    save
  end

  def remove_like(user_id)
    self.reactions ||= []
    self.reactions.reject! { |r| r["type"] == "like" && r["user_id"] == user_id }
    self.likes_count = (likes_count || 0) - 1
    save
  end

  def add_reaction(emoji, user_id)
    self.reactions ||= []
    self.reactions << { type: "emoji", emoji: emoji, user_id: user_id, created_at: Time.current }
    save
  end

  def remove_reaction(emoji, user_id)
    self.reactions ||= []
    self.reactions.reject! { |r| r["type"] == "emoji" && r["emoji"] == emoji && r["user_id"] == user_id }
    save
  end
end
