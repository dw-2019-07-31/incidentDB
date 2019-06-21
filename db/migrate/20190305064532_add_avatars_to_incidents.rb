class AddAvatarsToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :avatars, :string
  end
end
