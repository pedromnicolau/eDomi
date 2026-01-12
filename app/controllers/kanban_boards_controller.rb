class KanbanBoardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_board, only: [ :show, :update, :destroy ]
  before_action :ensure_privileged!

  def index
    @boards = KanbanBoard.all
    render json: @boards.map { |b| b.as_json }
  end

  def show
    render json: @board.as_json
  end

  def create
    b = KanbanBoard.new(board_params)
    if b.save
      render json: b.as_json, status: :created
    else
      render json: { errors: b.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @board.update(board_params)
      render json: @board.as_json
    else
      render json: { errors: @board.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @board.destroy
    head :no_content
  end

  private

  def set_board
    @board = KanbanBoard.find(params[:id])
  end

  def board_params
    params.require(:kanban_board).permit(:name)
  end

  def ensure_privileged!
    unless current_user&.admin? || current_user&.agent?
      render json: { error: "Não autorizado" }, status: :forbidden
    end
  end
end
