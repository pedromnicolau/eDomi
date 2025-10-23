class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    notifs = Notification.where(user_id: current_user.id).order(created_at: :desc).limit(50)
    render json: notifs.as_json(only: [:id, :title, :body, :read, :created_at])
  end

  def mark_as_read
    notif = Notification.find_by(id: params[:id], user_id: current_user.id)
    if notif
      notif.update(read: true)
      render json: { success: true }
    else
      render json: { error: "Notificação não encontrada" }, status: :not_found
    end
  end
end
