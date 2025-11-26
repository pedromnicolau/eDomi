class AddProviderUidAndVerificationToUsers < ActiveRecord::Migration[8.0]
  def change
    # Novas colunas para OAuth + verificação de e-mail
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :email_verification_token, :string
    add_column :users, :email_verified_at, :datetime
    add_column :users, :verification_sent_at, :datetime

    # Índices
    add_index :users, [:provider, :uid], unique: true
    add_index :users, :email_verification_token, unique: true
  end
end