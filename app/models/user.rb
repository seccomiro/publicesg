class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  enum :role, {
    viewer: 0,
    data_contributor: 1,
    approver_reviewer: 2,
    administrator: 3
  }

  has_many :company_users, dependent: :destroy
  has_many :companies, through: :company_users
  has_many :audit_logs, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :role, presence: true

  scope :active, -> { where(deleted_at: nil) }

  def soft_delete!
    update!(deleted_at: Time.current)
  end

  def active?
    deleted_at.nil?
  end
end
