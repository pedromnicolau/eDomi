class KanbanCardsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_privileged!
  before_action :set_card, only: [ :show, :update, :destroy ]

  def create
    column = KanbanColumn.find(params.dig(:kanban_card, :kanban_column_id) || params[:kanban_column_id])
    card = column.kanban_cards.build(card_params)
    card.position = column.kanban_cards.maximum(:position).to_i + 1
    if card.save
      if params[:attachments].present?
        Array(params[:attachments]).each { |f| card.attachments.attach(f) }
      end
      render json: card.as_json, status: :created
    else
      render json: { errors: card.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: @card.as_json
  end

  def update
    # allow moving between columns by providing kanban_column_id and position
    if @card.update(card_params)
      if params[:attachments].present?
        Array(params[:attachments]).each { |f| @card.attachments.attach(f) }
      end
      # handle removal of attachments by blob ids
      if params[:remove_attachment_blob_ids].present?
        ids = Array(params[:remove_attachment_blob_ids]).map(&:to_i)
        @card.attachments_attachments.where(blob_id: ids).each(&:purge)
      end
      render json: @card.as_json
    else
      render json: { errors: @card.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @card.destroy
    head :no_content
  end

  def reorder
    # expects params: cards: [{id:, kanban_column_id:, position:}, ...]
    unless params[:cards].is_a?(Array)
      render json: { error: "cards array required" }, status: :bad_request and return
    end
    ActiveRecord::Base.transaction do
      params[:cards].each do |c|
        card = KanbanCard.find_by(id: c[:id])
        next unless card
        card.update!(kanban_column_id: c[:kanban_column_id] || card.kanban_column_id, position: c[:position].to_i)
      end
    end
    head :no_content
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_card
    @card = KanbanCard.find(params[:id])
  end

  def card_params
    params.require(:kanban_card).permit(:title, :description, :kanban_column_id, :assigned_user_id, :position, client_info: {}, tags: [], checklist: [])
  end

  def ensure_privileged!
    unless current_user&.admin? || current_user&.agent?
      render json: { error: "Não autorizado" }, status: :forbidden
    end
  end
end
