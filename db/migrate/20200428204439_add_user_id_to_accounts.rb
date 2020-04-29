class AddUserIdToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :user_id, :integer
  end
end
