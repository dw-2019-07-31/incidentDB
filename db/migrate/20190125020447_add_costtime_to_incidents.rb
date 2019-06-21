class AddCosttimeToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :costtime, :integer
  end
end
