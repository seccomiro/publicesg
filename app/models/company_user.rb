class CompanyUser < ApplicationRecord
  belongs_to :user
  belongs_to :company

  validates :user_id, uniqueness: { scope: :company_id }
  validates :role, presence: true

  enum role: {
    member: 0,
    admin: 1,
    owner: 2
  }
end
