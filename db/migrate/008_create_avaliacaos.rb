class CreateAvaliacaos < ActiveRecord::Migration
  def self.up
    create_table :avaliacaos do |t|
      t.integer :clareza, :objetividade, :correcao, :detalhamento, :dominio, :resultados, :organizacao, :material_apoio, :transmissao_assunto
      t.integer :professor_id
      t.integer :banca_id
      t.integer :projeto_id
			t.float :primeira_nota, :segunda_nota
      t.boolean :versao_corrigida, :default => false
			t.boolean :primeira_versao, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :avaliacaos
  end
end
