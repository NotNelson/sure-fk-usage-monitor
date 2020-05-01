class AddFieldsToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :quota, :float, default: 0
    add_column :accounts, :total, :float, default: 0
    add_column :accounts, :ratio, :float, default: 0
  end
end
