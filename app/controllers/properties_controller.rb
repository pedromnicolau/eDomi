class PropertiesController < ApplicationController
  before_action :authenticate_user!, only: [ :show ]

  def index
    @properties = Property.available.includes(:property_photos)
  end

  def show
    @property = Property.find(params[:id])
    @visit = Visit.new
  end
end
