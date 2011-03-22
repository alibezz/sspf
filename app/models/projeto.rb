class Projeto < ActiveRecord::Base
  validates_presence_of :titulo, :aluno_id, :orientador_id, :semestre_id, :message => "não pode ser deixado em branco"
  validates_uniqueness_of :titulo, :message => "já utilizado"
  validates_uniqueness_of :aluno_id, :message => "já registrou o seu projeto", :scope => [:semestre_id]
  belongs_to :semestre
  belongs_to :orientador, :class_name => 'Professor'
  belongs_to :aluno
  has_one :banca
  has_many :avaliacaos

  has_and_belongs_to_many :topicos

  def situacao
    if projeto_final.nil?
      "a ser submetido"
    else
      # if recebeu nota => finalizado
      "em avaliação"	    
    end	    
  end	  

#### Validações ###
  validate do |b|
    b.tem_que_marcar_topicos
    b.tem_que_ter_arquivo
    b.projeto_final_tem_que_ser_pdf
  end

  def tem_que_marcar_topicos
    if topicos.empty?
      errors.add_to_base("Ao menos um tópico deve ser marcado")
    end
  end

  def tem_que_ter_arquivo
    if anteprojeto.nil? or not type_anteprojeto.include?('pdf')
      errors.add_to_base("Arquivo pdf de ante-projeto obrigatório")
    end
  end

  def projeto_final_tem_que_ser_pdf
    if not type_projeto_final.nil?
      errors.add_to_base("O arquivo com o projeto final deve estar no formato PDF") unless type_projeto_final.include?('pdf')
    end
  end

#### Arquivos ###

  attr_protected :anteprojeto, :projeto_final  
  
  def arquivo_anteprojeto= arquivo
    write_attribute(:anteprojeto, limpa_filename(arquivo.original_filename))
    self.type_anteprojeto = arquivo.content_type
    self.data_anteprojeto = arquivo.read
  end

  def arquivo_projeto_final= arquivo
    write_attribute(:projeto_final, limpa_filename(arquivo.original_filename))
    self.type_projeto_final = arquivo.content_type
    self.data_projeto_final = arquivo.read
  end

private
  def limpa_filename(filename)
    # obtém somente o nome do arquivo, não todo seu caminho (IE)
    nome = File.basename(filename)
    # substitui todos caracteres diferentes por underscores
    nome.gsub(/[^\w\.\-]/,'_')
  end

end
