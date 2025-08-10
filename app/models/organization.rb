# app/models/organization.rb
class Organization < ApplicationRecord
  has_many :organization_memberships, dependent: :destroy
  has_many :users, through: :organization_memberships

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true
end
