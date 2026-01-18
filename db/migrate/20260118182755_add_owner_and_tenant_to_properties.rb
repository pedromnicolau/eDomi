class AddOwnerAndTenantToProperties < ActiveRecord::Migration[8.0]
  def change
    add_reference :properties, :owner, null: true, foreign_key: { to_table: :people }
    add_reference :properties, :tenant, null: true, foreign_key: { to_table: :people }
  end
end
