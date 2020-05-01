class AddColumnLatestUpdateToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :latest_update, :string
  end
end
