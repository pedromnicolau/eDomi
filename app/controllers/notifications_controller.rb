class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    notifs = current_user.notifications.order(created_at: :desc).limit(50)
    render json: notifs.as_json(only: [ :id, :title, :body, :read, :created_at ])
  end
end
