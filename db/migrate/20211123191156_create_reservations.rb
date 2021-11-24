class CreateReservations < ActiveRecord::Migration[6.1]
  def change
    create_table :reservations do |t|
      t.string :type
      t.references :guest, null: false, foreign_key: true
      t.string :code, index: {unique: true}
      t.string :start_date
      t.string :end_date
      t.integer :nights
      t.integer :guests
      t.integer :adults
      t.integer :children
      t.integer :infants
      t.string :status
      t.string :currency
      t.string :payout_price
      t.string :security_price
      t.string :total_price

      t.timestamps
    end
  end
end
