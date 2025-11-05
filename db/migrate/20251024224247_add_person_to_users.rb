class AddPersonToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :person, null: true, foreign_key: true, index: true
  end
end
