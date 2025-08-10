# app/models/user.rb
class User < ApplicationRecord
  has_many :organization_memberships, dependent: :destroy
  has_many :organizations, through: :organization_memberships

  validates :email, presence: true, uniqueness: true
end
