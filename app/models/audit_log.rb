class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :company, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  validates :action, presence: true
  validates :resource_type, presence: true

  enum action: {
    create: 0,
    update: 1,
    destroy: 2,
    read: 3
  }

  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_company, ->(company) { where(company: company) }
end
