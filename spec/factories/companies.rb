FactoryBot.define do
  factory :company do
    name { "MyString" }
    industry { "MyString" }
    size { "MyString" }
    description { "MyText" }
    status { 1 }
    fiscal_year_end { "2025-07-27" }
  end
end
