class CreateProperties < ActiveRecord::Migration[8.0]
  def change
    create_table :properties do |t|
      t.string  :title,        null: false
      t.text    :description

      t.decimal :price,        precision: 12, scale: 2, null: false
      t.integer :property_type,                            null: false

      t.decimal :area,         precision: 10, scale: 2
      t.integer :bedrooms,     null: false, default: 0
      t.integer :bathrooms,    null: false, default: 0
      t.integer :parking_spaces, null: false, default: 0
      t.boolean :furnished,    null: false, default: false

      t.decimal :condominium_fee, precision: 10, scale: 2, null: false, default: 0
      t.decimal :iptu,            precision: 10, scale: 2, null: false, default: 0

      t.integer :year_built

      t.string  :address,     null: false
      t.string  :neighborhood
      t.string  :city,        null: false
      t.string  :state,       null: false
      t.string  :zip_code

      t.integer :status,      null: false, default: 0

      # agent referencia a tabela users
      t.references :agent, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    # Índices úteis de busca/filtragem
    add_index :properties, :status
    add_index :properties, :property_type
    add_index :properties, :city
    add_index :properties, :neighborhood
    add_index :properties, :price
    add_index :properties, [ :bedrooms, :bathrooms ]

    # Regras de integridade (melhor qualidade de dados)
    add_check_constraint :properties, "price >= 0",                         name: "properties_price_non_negative"
    add_check_constraint :properties, "condominium_fee >= 0",               name: "properties_condo_fee_non_negative"
    add_check_constraint :properties, "iptu >= 0",                          name: "properties_iptu_non_negative"
    add_check_constraint :properties, "bedrooms >= 0",                      name: "properties_bedrooms_non_negative"
    add_check_constraint :properties, "bathrooms >= 0",                     name: "properties_bathrooms_non_negative"
    add_check_constraint :properties, "parking_spaces >= 0",                name: "properties_parking_non_negative"
    add_check_constraint :properties, "char_length(state) = 2",             name: "properties_state_len_2"
  end
end
