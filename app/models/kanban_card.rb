class KanbanCard < ApplicationRecord
  belongs_to :kanban_column
  belongs_to :assigned_user, class_name: "User", optional: true

  has_many_attached :attachments
  has_many :kanban_comments, dependent: :destroy

  validates :title, presence: true

  scope :ordered, -> { order(:position) }

  def as_json(options = {})
    base = super(only: [ :id, :title, :description, :position, :client_info, :tags, :checklist, :assigned_user_id, :created_at, :updated_at ])
    base[:assigned_user] = assigned_user&.slice(:id, :name, :email)
    base[:attachments] = attachments.map { |a| { id: a.id, filename: a.filename.to_s, url: Rails.application.routes.url_helpers.rails_blob_url(a, only_path: true) } }
    base[:comments] = kanban_comments.order(:created_at).map do |c|
      { id: c.id, body: c.body, created_at: c.created_at, user: c.user&.slice(:id, :name, :email) }
    end
    base[:edit_history] = edit_history || []
    base
  end

  def track_changes(user, changed_fields)
    self.edit_history ||= []
    self.edit_history << {
      edited_at: Time.current,
      user: user&.slice(:id, :name, :email),
      fields: changed_fields
    }
  end
end
