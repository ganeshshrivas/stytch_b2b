# app/models/user.rb
class User < ApplicationRecord
  has_many :organization_memberships, dependent: :destroy
  has_many :organizations, through: :organization_memberships

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email,
            presence: true,
            uniqueness: true,
            format: { with: VALID_EMAIL_REGEX, message: "is invalid" }
end
