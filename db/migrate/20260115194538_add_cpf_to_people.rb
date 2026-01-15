class AddCpfToPeople < ActiveRecord::Migration[8.0]
  def change
    add_column :people, :cpf, :string
  end
end
