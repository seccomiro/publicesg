class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.references :auditable, polymorphic: true, null: false
      t.integer :action
      t.string :resource_type
      t.integer :resource_id
      t.text :audit_changes
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
