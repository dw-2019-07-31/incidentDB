class CreateChoices < ActiveRecord::Migration[5.1]
  def change
    create_table :choices do |t|
      t.string :column_name
      t.string :value

      t.timestamps
    end
  end
end
