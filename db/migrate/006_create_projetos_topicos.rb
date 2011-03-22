class CreateProjetosTopicos < ActiveRecord::Migration
  def self.up
    create_table :projetos_topicos, :id => false do |t|
      t.integer :topico_id
      t.integer :projeto_id
    end
  end

  def self.down
    drop_table :projetos_topicos
  end
end
