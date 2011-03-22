class CreateBancas < ActiveRecord::Migration
  def self.up
    create_table :bancas do |t|
      t.integer :projeto_id
      t.timestamps
    end
  end

  def self.down
    drop_table :bancas
  end
end
