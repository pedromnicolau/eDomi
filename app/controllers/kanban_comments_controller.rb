class KanbanCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_card, except: [ :like, :unlike, :add_reaction, :remove_reaction ]
  before_action :set_comment, only: [ :like, :unlike, :add_reaction, :remove_reaction, :show ]

  def index
    render json: @card.kanban_comments.where(parent_comment_id: nil).order(:created_at).map(&:as_json)
  end

  def show
    render json: @comment.as_json
  end

  def create
    comment = @card.kanban_comments.create!(comment_params.merge(user: current_user))
    render json: comment.as_json, status: :created
  end

  def create_reply
    parent_comment = KanbanComment.find(params[:comment_id])
    reply = parent_comment.replies.create!(comment_params.merge(user: current_user, kanban_card_id: parent_comment.kanban_card_id))
    render json: reply.as_json, status: :created
  end

  def like
    @comment.add_like(current_user.id)
    render json: @comment.as_json
  end

  def unlike
    @comment.remove_like(current_user.id)
    render json: @comment.as_json
  end

  def add_reaction
    emoji = params.require(:emoji)
    @comment.add_reaction(emoji, current_user.id)
    render json: @comment.as_json
  end

  def remove_reaction
    emoji = params.require(:emoji)
    @comment.remove_reaction(emoji, current_user.id)
    render json: @comment.as_json
  end

  private

  def set_card
    @card = KanbanCard.find(params[:kanban_card_id])
  end

  def set_comment
    @comment = KanbanComment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
