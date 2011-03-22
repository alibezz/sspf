class CreateBancasProfessors < ActiveRecord::Migration
  def self.up
    create_table :bancas_professors, :id => false do |t|
      t.integer :banca_id
      t.integer :professor_id
    end
  end

  def self.down
    drop_table :bancas_professors
  end
end
