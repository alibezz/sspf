class Professor < Usuario
  has_and_belongs_to_many :topicos
  has_and_belongs_to_many :bancas
#  has_many :avaliacaos, :through => :bancas

  def cria_avaliacao(projeto)
    return nil unless projeto
    banca = projeto.banca
    return nil unless banca
    avaliacao = avaliacaos.create
    avaliacao.banca_id = banca.id
    avaliacao.save
  end
end
