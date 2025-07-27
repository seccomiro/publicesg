class Company < ApplicationRecord
  has_many :company_users, dependent: :destroy
  has_many :users, through: :company_users
  has_many :audit_logs, dependent: :destroy

  validates :name, presence: true
  validates :industry, presence: true
  validates :size, presence: true, inclusion: { in: %w[small medium large] }

  enum status: { active: 0, inactive: 1, suspended: 2 }

  scope :active, -> { where(status: :active) }
end
