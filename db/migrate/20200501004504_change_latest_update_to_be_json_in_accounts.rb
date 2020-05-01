class ChangeLatestUpdateToBeJsonInAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :json_data, :json
  end
end
