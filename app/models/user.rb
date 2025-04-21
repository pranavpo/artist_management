class User < ApplicationRecord
    has_secure_password
  
    # Associations
    has_one :artist, dependent: :destroy
  
    # Enums
    enum :gender, { m: 'm', f: 'f', o: 'o' }, prefix: true, default: :m
    enum :role, { super_admin: 'super_admin', artist_manager: 'artist_manager', artist: 'artist' }, default: :artist
  
    # Validations
    validates :first_name, presence: { message: "First name is required" }
    validates :last_name, presence: { message: "Last name is required" }
  
    validates :email,
            presence: { message: "Email is required and must be a valid address" },
            uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "Email is required and must be a valid address" }
  
    validates :password, length: { minimum: 8, message: "Password is too short(minimum is 8 characters)" }, if: :password_required?
  
    validates :gender, inclusion: { in: genders.keys, message: 'Gender must be one of: Male, Female, Other' }
  
    private
  
    # Skip password validation on update if password is not being changed
    def password_required?
      new_record? || password.present?
    end
  end
