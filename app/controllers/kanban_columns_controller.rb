class KanbanColumnsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_privileged!
  before_action :set_column, only: [ :update, :destroy ]

  def create
    board = KanbanBoard.find(params.dig(:kanban_column, :kanban_board_id) || params[:kanban_board_id])
    column = board.kanban_columns.build(column_params)
    column.position = board.kanban_columns.maximum(:position).to_i + 1
    if column.save
      render json: column.as_json, status: :created
    else
      render json: { errors: column.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @column.update(column_params)
      render json: @column.as_json
    else
      render json: { errors: @column.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @column.destroy
    head :no_content
  end

  def reorder
    # expects params: columns: [{id:, position:}, ...]
    unless params[:columns].is_a?(Array)
      render json: { error: "columns array required" }, status: :bad_request and return
    end
    params[:columns].each do |c|
      col = KanbanColumn.find_by(id: c[:id])
      next unless col
      col.update(position: c[:position].to_i)
    end
    head :no_content
  end

  private

  def set_column
    @column = KanbanColumn.find(params[:id])
  end

  def column_params
    params.require(:kanban_column).permit(:name, :color, :position, :kanban_board_id)
  end

  def ensure_privileged!
    unless current_user&.admin? || current_user&.agent?
      render json: { error: "Não autorizado" }, status: :forbidden
    end
  end
end
