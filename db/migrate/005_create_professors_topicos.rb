class CreateProfessorsTopicos < ActiveRecord::Migration
  def self.up
    create_table :professors_topicos, :id => false do |t|
      t.integer :topico_id
      t.integer :professor_id
    end
  end

  def self.down
    drop_table :professors_topicos
  end
end
