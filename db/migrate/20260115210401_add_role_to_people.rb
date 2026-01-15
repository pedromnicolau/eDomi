class AddRoleToPeople < ActiveRecord::Migration[8.0]
  def change
    add_column :people, :role, :integer
  end
end
