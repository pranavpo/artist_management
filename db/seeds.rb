# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.create!(
    first_name: "Admin",
    last_name: "User",
    email: "admin@example.com",
    password: "password",
    phone: "1234567890",
    dob: "1990-01-01",
    gender: :m,
    address: "123 Admin Street",
    role: :super_admin
)