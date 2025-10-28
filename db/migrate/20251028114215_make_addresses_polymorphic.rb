class MakeAddressesPolymorphic < ActiveRecord::Migration[8.0]
  def change
    remove_reference :addresses, :person, foreign_key: true

    add_reference :addresses, :addressable, polymorphic: true, null: false, index: true
  end
end
