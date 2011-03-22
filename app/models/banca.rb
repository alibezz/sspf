class Banca < ActiveRecord::Base
  belongs_to :projeto
  has_and_belongs_to_many :professors
  has_many :avaliacaos, :source => :professors

  validates_presence_of :projeto_id
  validates_uniqueness_of :projeto_id

  validate do |b|
    b.tem_no_maximo_3_professores
    b.tem_que_ter_o_orientador
  end

  def tem_no_maximo_3_professores
    if professors.length > 3
      errors.add_to_base("A banca é constituída de apenas 3 avaliadores.")
    end  
  end

  def tem_que_ter_o_orientador
    return if projeto_id.nil?
    projeto = Projeto.find(projeto_id)
    if !professors.nil? and !professors.empty? and professors.grep(projeto.orientador).empty?
      errors.add_to_base("A banca deve conter o(a) orientador(a) do projeto (" + projeto.orientador.nome + ").");
    end
  end
  
  def self.sugere_banca(projeto, professores)
    sugeridos = professores.sort { |a,b| 
      a0 = (projeto.topicos & a.topicos).size;
      b0 = (projeto.topicos & b.topicos).size;
      if a0 == b0
        a1 = a.bancas.size;
        b1 = b.bancas.size;
	a1 <=> b1;
      else
        b0 <=> a0;
      end;}
    sugeridos 
  end  
end
