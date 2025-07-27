class CreateCompanyUsers < ActiveRecord::Migration[8.0]
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
