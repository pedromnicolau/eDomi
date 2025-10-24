class CreatePeopleAndAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :people do |t|
      t.string  :name,               null: false
      t.string  :email,                    null: false
      t.string  :phone
      t.date    :birthdate
      t.integer :status,                   null: false, default: 0   # ex: [:prospect, :client, :inactive]
      t.integer :preferred_contact_method, null: false, default: 0   # ex: [:phone, :email, :whatsapp]
      t.text    :notes
      t.boolean :active,    null: false, default: true
      t.timestamps
    end

    add_index :people, :email, unique: true

    create_table :addresses do |t|
      t.references :person,      null: false, foreign_key: true
      t.string     :address_line1, null: false
      t.string     :address_line2
      t.string     :neighborhood
      t.string     :city,         null: false
      t.string     :state,        null: false, limit: 2
      t.string     :zip_code
      t.string     :country,      null: false, default: "BR"
      t.decimal    :latitude,     precision: 10, scale: 6
      t.decimal    :longitude,    precision: 10, scale: 6
      t.integer    :address_type, null: false, default: 0  # ex: [:primary, :mailing, :billing, :property]
      t.boolean    :primary,      null: false, default: false
      t.timestamps
    end

    add_index :addresses, [ :person_id, :address_type ], name: "index_addresses_on_person_and_type"
    add_check_constraint :addresses, "char_length(state::text) = 2", name: "addresses_state_len_2"
  end
end
