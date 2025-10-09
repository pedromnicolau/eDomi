# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
User.find_or_create_by!(email: "admin@edomi.test") do |u|
  u.name = "Admin eDomi"
  u.password = "12345678"
  u.password_confirmation = "12345678"
  u.role = 0
end

User.find_or_create_by!(email: "corretor@edomi.test") do |u|
  u.name = "Corretor Exemplo"
  u.password = "12345678"
  u.password_confirmation = "12345678"
  u.role = 1
  u.phone = "11999999999"
end
