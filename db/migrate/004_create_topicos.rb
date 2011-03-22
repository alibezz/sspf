class CreateTopicos < ActiveRecord::Migration
  def self.up
    create_table :topicos do |t|
      t.string :nome

      t.timestamps
    end
  end

  def self.down
    drop_table :topicos
  end
end
