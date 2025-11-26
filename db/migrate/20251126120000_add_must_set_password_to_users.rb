class AddMustSetPasswordToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :must_set_password, :boolean, null: false, default: false
  end
end
