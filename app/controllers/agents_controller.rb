class AgentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_privileged!

  def index
    respond_to do |format|
      format.html {
        # ...existing code...
        # (mantém render padrão da view index se houver)
      }
      format.json do
        # assume que role == 1 representa 'agent' na base (seguindo convenção do projeto)
        agents = User.where(role: 1).select(:id, :name, :email).order(Arel.sql("COALESCE(name, email)"))
        render json: agents.map { |u| { id: u.id, name: u.name, email: u.email } }
      end
    end
  end
end
