class CreateCompanies < ActiveRecord::Migration[8.0]
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
