# PublicESG Phase 1 Implementation Plan
## Foundation & Core Infrastructure (Weeks 1-4)

### Overview
This document provides a detailed implementation plan for Phase 1 of the PublicESG platform development, focusing on establishing the foundational infrastructure, authentication system, and core models that will support the entire sustainability reporting SaaS platform.

## Week 1: Project Setup & Development Environment

### 1.1 Rails Application Initialization ✅
**Tasks:**
- [x] Create new Rails 8 application with API-first architecture
- [x] Configure PostgreSQL as primary database
- [x] Set up Solid Queue for background job processing
- [x] Configure environment variable management with dotenv-rails

**Commands:**
```bash
rails new publicesg_platform --api --database=postgresql --skip-test
cd publicesg_platform
```

**Gemfile additions:**
```ruby
# Authentication & Authorization
gem 'devise'
gem 'omniauth-google-oauth2'
gem 'pundit'

# Background Jobs
gem 'solid_queue'

# Environment Management
gem 'dotenv-rails'

# Development & Testing
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers'
  gem 'webmock'
  gem 'capybara'
  gem 'simplecov'
  gem 'rubocop-rails'
end
```

### 1.2 Docker Development Environment ✅
**Tasks:**
- [x] Create Dockerfile for Rails application
- [x] Set up docker-compose.yml with PostgreSQL services
- [x] Configure separate databases for development and test
- [x] Create Docker development workflow documentation

**Docker Configuration:**

`Dockerfile`:
```dockerfile
FROM ruby:3.2-alpine

RUN apk add --no-cache \
  build-base \
  postgresql-dev \
  tzdata \
  nodejs \
  npm

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
```

`docker-compose.yml`:
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: publicesg_development
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  postgres_test:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: publicesg_test
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5433:5432"

  web:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - postgres
    environment:
      DATABASE_URL: postgresql://postgres:password@postgres:5432/publicesg_development
    volumes:
      - .:/app
      - bundle_cache:/usr/local/bundle

volumes:
  postgres_data:
  bundle_cache:
```

## Week 2: Core Models & Database Schema

### 2.1 User Management Models
**Tasks:**
- [ ] Generate and configure Devise User model
- [ ] Add role enumeration to User model
- [ ] Create Company/Organization model
- [ ] Set up User-Company associations
- [ ] Implement soft delete functionality

**User Model (`app/models/user.rb`):**
```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  enum role: {
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
```

**Company Model (`app/models/company.rb`):**
```ruby
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
```

**CompanyUser Association (`app/models/company_user.rb`):**
```ruby
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
```

### 2.2 Database Migrations
**Tasks:**
- [ ] Create Devise users migration
- [ ] Create companies migration
- [ ] Create company_users join table migration
- [ ] Create audit_logs migration
- [ ] Add indexes for performance optimization

**Migration Files:**
```ruby
# db/migrate/xxx_devise_create_users.rb
class DeviseCreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :first_name,         null: false
      t.string :last_name,          null: false
      t.integer :role,              null: false, default: 0
      t.datetime :deleted_at
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :role
    add_index :users, :deleted_at
  end
end

# db/migrate/xxx_create_companies.rb
class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :industry, null: false
      t.string :size, null: false
      t.text :description
      t.integer :status, default: 0
      t.date :fiscal_year_end
      t.timestamps
    end

    add_index :companies, :name
    add_index :companies, :industry
    add_index :companies, :status
  end
end

# db/migrate/xxx_create_company_users.rb
class CreateCompanyUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :company_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.integer :role, default: 0
      t.timestamps
    end

    add_index :company_users, [:user_id, :company_id], unique: true
  end
end
```

## Week 3: Authentication & Authorization System

### 3.1 Devise Configuration
**Tasks:**
- [ ] Configure Devise initializer
- [ ] Set up Google OAuth integration
- [ ] Create custom Devise controllers for API
- [ ] Implement JWT token authentication for API

**Devise Configuration (`config/initializers/devise.rb`):**
```ruby
Devise.setup do |config|
  config.mailer_sender = ENV.fetch('MAILER_FROM', 'noreply@publicesg.com')
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth, :token_auth]
  config.stretches = Rails.env.test? ? 1 : 12
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 8..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
  config.responder = DeviseResponder
end
```

### 3.2 Pundit Authorization
**Tasks:**
- [ ] Configure Pundit in ApplicationController
- [ ] Create base ApplicationPolicy
- [ ] Implement UserPolicy and CompanyPolicy
- [ ] Create policy specs

**ApplicationPolicy (`app/policies/application_policy.rb`):**
```ruby
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError
    end

    private

    attr_reader :user, :scope
  end
end
```

## Week 4: Testing Framework & Security

### 4.1 RSpec Configuration
**Tasks:**
- [ ] Configure RSpec with Rails
- [ ] Set up FactoryBot factories
- [ ] Configure Shoulda-Matchers
- [ ] Implement test coverage with SimpleCov
- [ ] Create shared examples and helpers

**RSpec Configuration (`spec/rails_helper.rb`):**
```ruby
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rails'
require 'shoulda/matchers'
require 'webmock/rspec'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::IntegrationHelpers, type: :request
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
```

### 4.2 FactoryBot Factories
**User Factory (`spec/factories/users.rb`):**
```ruby
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    role { :viewer }

    trait :administrator do
      role { :administrator }
    end

    trait :data_contributor do
      role { :data_contributor }
    end

    trait :approver_reviewer do
      role { :approver_reviewer }
    end
  end
end
```

### 4.3 Security Implementation
**Tasks:**
- [ ] Configure HTTPS/TLS for development
- [ ] Implement secure headers
- [ ] Set up CORS configuration
- [ ] Configure rate limiting
- [ ] Implement audit logging

**Security Configuration (`config/application.rb`):**
```ruby
module PublicesgPlatform
  class Application < Rails::Application
    config.api_only = true
    config.load_defaults 7.1
    
    # Security headers
    config.force_ssl = Rails.env.production?
    
    # CORS configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins ENV.fetch('ALLOWED_ORIGINS', 'localhost:3001').split(',')
        resource '*',
                 headers: :any,
                 methods: [:get, :post, :put, :patch, :delete, :options, :head],
                 credentials: true
      end
    end
  end
end
```

## Audit Logging System

### 4.4 Audit Trail Implementation
**Tasks:**
- [ ] Create AuditLog model
- [ ] Implement audit logging concern
- [ ] Add audit triggers to models
- [ ] Create audit log viewer interface

**AuditLog Model (`app/models/audit_log.rb`):**
```ruby
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
```

## Auto-save Infrastructure

### 4.5 Version Control & Auto-save
**Tasks:**
- [ ] Implement auto-save functionality
- [ ] Create version control system
- [ ] Set up background job for auto-save
- [ ] Implement conflict resolution

**Auto-save Concern (`app/models/concerns/auto_saveable.rb`):**
```ruby
module AutoSaveable
  extend ActiveSupport::Concern

  included do
    after_update :create_version, if: :should_create_version?
    after_create :create_initial_version
  end

  private

  def should_create_version?
    saved_changes.present? && saved_changes.keys != ['updated_at']
  end

  def create_version
    AutoSaveJob.perform_later(self.class.name, id, saved_changes)
  end

  def create_initial_version
    AutoSaveJob.perform_later(self.class.name, id, attributes)
  end
end
```

## API Foundation

### 4.6 API Structure
**Tasks:**
- [ ] Set up API versioning (v1)
- [ ] Create base API controllers
- [ ] Implement JSON API responses
- [ ] Set up API authentication
- [ ] Create API documentation structure

**Base API Controller (`app/controllers/api/v1/base_controller.rb`):**
```ruby
class Api::V1::BaseController < ApplicationController
  include Pundit::Authorization
  
  before_action :authenticate_user!
  before_action :set_current_company
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

  private

  def set_current_company
    @current_company = current_user&.companies&.first
  end

  def user_not_authorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def not_found
    render json: { error: 'Not found' }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: { 
      error: 'Validation failed', 
      details: exception.record.errors.full_messages 
    }, status: :unprocessable_entity
  end
end
```

## Deliverables Checklist

### Technical Deliverables
- [ ] Rails 8 application with Docker setup
- [ ] PostgreSQL databases (development/test) configured
- [ ] User authentication with Devise and Google OAuth
- [ ] Role-based authorization with Pundit
- [ ] Core models: User, Company, CompanyUser
- [ ] Audit logging system
- [ ] Auto-save infrastructure
- [ ] API foundation with versioning
- [ ] Comprehensive test suite (>80% coverage)
- [ ] Security configuration (HTTPS, headers, CORS)

### Documentation Deliverables
- [ ] Development environment setup guide
- [ ] API documentation structure
- [ ] Database schema documentation
- [ ] Security implementation guide
- [ ] Testing strategy documentation

### Quality Assurance
- [ ] All tests passing
- [ ] Code coverage >80%
- [ ] Security review completed
- [ ] Performance baseline established
- [ ] Code style compliance (Rubocop)

## Risk Mitigation

### Technical Risks
1. **Rails 8 Compatibility**: Use stable gem versions, maintain test coverage
2. **Docker Performance**: Optimize development setup, use volume mounting
3. **Database Migrations**: Test migrations thoroughly, maintain rollback scripts
4. **OAuth Integration**: Implement fallback authentication, test edge cases

### Security Risks
1. **Authentication Vulnerabilities**: Regular security audits, penetration testing
2. **Data Protection**: Implement encryption, secure data handling practices
3. **API Security**: Rate limiting, input validation, secure headers

## Success Metrics

### Technical Metrics
- Test coverage: >80%
- Page load times: <500ms for API responses
- Security compliance: OWASP Top 10 addressed
- Code quality: Rubocop score >90%

### Functional Metrics
- User registration flow: 100% completion rate in tests
- Authentication success: 99% uptime
- Role-based access: All permission scenarios tested
- Audit logging: 100% coverage of CRUD operations

## Next Steps (Phase 2 Preparation)

### Architecture Considerations
- API scalability for materiality matrix data
- Database optimization for standards storage
- Background job infrastructure for AI integration
- Caching strategy for performance optimization

### Integration Points
- Frontend application connection points
- AI service integration foundations
- File upload and processing infrastructure
- Email notification system setup

This implementation plan provides a comprehensive roadmap for establishing the foundational infrastructure of the PublicESG platform, ensuring a solid base for subsequent development phases.