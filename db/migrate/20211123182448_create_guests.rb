class CreateGuests < ActiveRecord::Migration[6.1]
  def change
    create_table :guests do |t|
      t.string :email, index: {unique: true}
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
