class Avaliacao < ActiveRecord::Base
  belongs_to :professor
  validates_presence_of :professor_id, :banca_id
  validates_numericality_of :clareza, :objetividade, :detalhamento, :dominio, :resultados, :organizacao, :material_apoio, :transmissao_assunto, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100, :message => "deve ter valor inteiro entre 0 e 100"

  def self.calcula_nota(avaliacao)
    #TODO Desarmengar este codigo
    nota = (avaliacao.clareza.to_i + avaliacao.objetividade.to_i + avaliacao.correcao.to_i + avaliacao.detalhamento.to_i + avaliacao.dominio.to_i + avaliacao.resultados.to_i + avaliacao.organizacao.to_i + avaliacao.material_apoio.to_i + avaliacao.transmissao_assunto.to_i) / 90.0
    nota
  end
end
