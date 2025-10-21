class UsersController < ApplicationController
  before_action :authenticate_user!

  def current
    render json: {
      id: current_user.id,
      email: current_user.email,
      name: current_user.name,
      role: current_user.role # enum retorna string, ex: "agent", "admin", "buyer"
    }
  end
end
