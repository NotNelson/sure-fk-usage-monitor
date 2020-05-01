class AddColumnToDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :details, :date_name, :string
  end
end
