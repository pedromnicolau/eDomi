class KanbanCard < ApplicationRecord
  belongs_to :kanban_column
  belongs_to :assigned_user, class_name: "User", optional: true

  has_many_attached :attachments

  validates :title, presence: true

  scope :ordered, -> { order(:position) }

  def as_json(options = {})
    base = super(only: [ :id, :title, :description, :position, :client_info, :tags, :checklist, :assigned_user_id ])
    base[:assigned_user] = assigned_user&.slice(:id, :name, :email)
    base[:attachments] = attachments.map { |a| { id: a.id, filename: a.filename.to_s, url: Rails.application.routes.url_helpers.rails_blob_url(a, only_path: true) } }
    base
  end
end
