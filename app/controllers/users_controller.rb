class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :current ], raise: false

  def current
    if current_user
      render json: {
        id: current_user.id,
        email: current_user.email,
        name: current_user.name,
        role: current_user.role
      }
    else
      render json: nil, status: :ok
    end
  end

  def update
    if current_user.update(user_params)
      render json: current_user
    else
      render json: { error: current_user.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end
end
