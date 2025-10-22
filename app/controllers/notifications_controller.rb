class NotificationsController < ApplicationController
  # não forçamos authenticate_user! para evitar redirecionamentos HTML inesperados em chamadas XHR;
  # tratamos explicitamente abaixo.
  def index
    unless respond_to?(:current_user) && current_user
      render json: [], status: :unauthorized and return
    end

    notifs = Notification.where(user_id: current_user.id).order(created_at: :desc).limit(50)
    render json: notifs.as_json(only: [ :id, :title, :body, :read, :created_at ])
  end
end
