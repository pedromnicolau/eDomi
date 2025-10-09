class PropertiesController < ApplicationController
  before_action :authenticate_user!, only: [ :show, :new, :create, :edit, :update ]

  def index
    @properties = Property.available.includes(:property_photos)
  end

  def show
    @property = Property.find(params[:id])
    @visit = Visit.new
  end

  def new
    @property = Property.new
  end

  def edit
    @property = Property.find(params[:id])
  end

  def create
    @property = Property.new(property_params)
    if @property.save
      redirect_to property_path(@property), notice: "Propriedade cadastrada com sucesso!"
    else
      render :new
    end
  end

  def update
    @property = Property.find(params[:id])
    if @property.update(property_params)
      if params[:property][:new_images].present?
        params[:property][:new_images].each do |img|
          @property.property_photos.create(image: img)
        end
      end
      redirect_to property_path(@property), notice: "Propriedade atualizada com sucesso!"
    else
      render :edit
    end
  end

  private

  def property_params
    params.require(:property).permit(:title, :description, :property_type, :status, :price, :agent_id, :city, :state, property_photos_attributes: [ :image ])
  end
end
