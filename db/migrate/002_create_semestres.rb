class CreateSemestres < ActiveRecord::Migration
  def self.up
    create_table :semestres do |t|
      t.string  :nome
      t.date    :prazo_final, :prazo_registro
      t.boolean :eh_corrente
      t.integer :coordenador_id
      t.timestamps
    end

  end

  def self.down
    drop_table :semestres
  end
end
