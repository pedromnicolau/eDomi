class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :current ], raise: false

  # GET /users or /users.json
  def index
    respond_to do |format|
      format.html {
        # ...existing code (render view if present) ...
      }
      format.json do
        scope = User.select(:id, :name, :email, :role).order(Arel.sql("COALESCE(name, email)"))

        # filtro por role (aceita valor numérico)
        if params[:role].present?
          scope = scope.where(role: params[:role].to_i)
        end

        # busca por nome ou email (param q)
        if params[:q].present?
          q = "%#{params[:q].to_s.downcase}%"
          scope = scope.where("LOWER(name) LIKE ? OR LOWER(email) LIKE ?", q, q)
        end

        render json: scope.map { |u| { id: u.id, name: u.name, email: u.email, role: u.role } }
      end
    end
  end

  # GET /current_user
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
      render json: { error: current_user.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end
end
