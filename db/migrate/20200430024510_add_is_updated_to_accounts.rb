class AddIsUpdatedToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :is_updated, :boolean, default: false
  end
end
