class CreateIncidents < ActiveRecord::Migration[5.1]
  def change
    create_table :incidents do |t|
      t.string :type
      t.date :reception_date
      t.string :group
      t.string :username
      t.string :hostname
      t.string :os
      t.string :product
      t.string :subject
      t.string :solution
      t.text :story
      t.string :status
      t.date :close_date
      t.string :remarks
      t.string :operator

      t.timestamps
    end
  end
end
