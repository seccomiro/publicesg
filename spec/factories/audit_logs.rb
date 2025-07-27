FactoryBot.define do
  factory :audit_log do
    user { nil }
    company { nil }
    auditable { nil }
    action { 1 }
    resource_type { "MyString" }
    resource_id { 1 }
    audit_changes { "MyText" }
    ip_address { "MyString" }
    user_agent { "MyString" }
  end
end
