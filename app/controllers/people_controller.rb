class PeopleController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_privileged!
  before_action :set_person, only: [ :show, :update, :destroy ]

  # GET /people.json
  def index
    @people = Person.includes(:addresses, :assigned_agent).order(created_at: :desc)
    render json: @people.as_json(
      only: [ :id, :name, :email, :phone, :cpf, :birthdate, :status, :preferred_contact_method, :active, :created_at, :notes, :role ],
      methods: [ :assigned_agent_name ],
      include: { addresses: { only: [ :id, :address_line1, :city, :state, :zip_code, :address_type, :primary ] } }
    )
  end

  # GET /people/:id.json
  def show
    render json: @person.as_json(
      only: [ :id, :name, :email, :phone, :cpf, :birthdate, :status, :preferred_contact_method, :active, :notes, :created_at, :role ],
      methods: [ :assigned_agent_name ],
      include: { addresses: { only: [ :id, :address_line1, :address_line2, :city, :state, :zip_code, :address_type, :primary ] } }
    )
  end

  # POST /people.json
  def create
    @person = Person.new(person_params)
    if @person.save
      render json: @person.as_json(
        only: [ :id, :name, :email, :phone, :cpf, :birthdate, :status, :preferred_contact_method, :active, :notes, :created_at, :role ],
        methods: [ :assigned_agent_name ],
        include: { addresses: { only: [ :id, :address_line1, :address_line2, :city, :state, :zip_code, :address_type, :primary ] } }
      ), status: :created
    else
      render json: { errors: @person.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /people/:id.json
  def update
    if @person.update(person_params)
      render json: @person.as_json(
        only: [ :id, :name, :email, :phone, :cpf, :birthdate, :status, :preferred_contact_method, :active, :notes, :created_at, :role ],
        methods: [ :assigned_agent_name ],
        include: { addresses: { only: [ :id, :address_line1, :address_line2, :city, :state, :zip_code, :address_type, :primary ] } }
      )
    else
      render json: { errors: @person.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /people/:id.json
  def destroy
    @person.destroy
    head :no_content
  end

  private

  def set_person
    @person = Person.find(params[:id])
  end

  def person_params
    params.require(:person).permit(
      :name, :email, :phone, :birthdate, :status, :preferred_contact_method,
      :notes, :active, :assigned_agent_id, :cpf, :role,
      addresses_attributes: [ :id, :address_line1, :address_line2, :number, :city, :state, :zip_code, :address_type, :primary, :_destroy ]
    )
  end
end
