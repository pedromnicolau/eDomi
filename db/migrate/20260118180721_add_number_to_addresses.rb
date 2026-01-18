class AddNumberToAddresses < ActiveRecord::Migration[8.0]
  def change
    add_column :addresses, :number, :string
  end
end
