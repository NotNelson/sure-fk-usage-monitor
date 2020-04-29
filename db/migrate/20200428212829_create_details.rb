class CreateDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :details do |t|
      t.references :account, null: false, foreign_key: true
      t.date :date_usage
      t.decimal :usage_amount

      t.timestamps
    end
  end
end
