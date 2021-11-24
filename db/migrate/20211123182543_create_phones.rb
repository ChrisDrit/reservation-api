class CreatePhones < ActiveRecord::Migration[6.1]
  def change
    create_table :phones do |t|
      t.references :guest, null: false, foreign_key: true
      t.string :number

      t.timestamps
    end
  end
end
