class ChangeDataColumnTypeInChoices < ActiveRecord::Migration[7.0]
  def change
    change_column :choices, :data, :mediumtext
  end
end
