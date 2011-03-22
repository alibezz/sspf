class CreateProjetos < ActiveRecord::Migration  
  def self.up
    create_table :projetos do |t|
      t.string :titulo
      t.text :resumo
      t.integer :semestre_id, :orientador_id, :aluno_id, :banca_id

      t.string :anteprojeto, :projeto_final
      t.string :type_anteprojeto, :type_projeto_final
      t.binary :data_anteprojeto, :data_projeto_final

      t.timestamps
    end
  end

  def self.down
    drop_table :projetos
  end
end  
