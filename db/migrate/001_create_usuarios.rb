class CreateUsuarios < ActiveRecord::Migration
  def self.up
    create_table :usuarios do |t|
      t.string :usuario, :senha_encriptada, :salto
      t.string :nome, :email
      # Atributos de Aluno
      t.string :matricula
      # Atributos de Professor
      t.boolean :orientador, :avaliador
      # Armazena subclasse
      t.string :type
      t.timestamps
    end
  end

  def self.down
    drop_table :usuarios
  end
end
