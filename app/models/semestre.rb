class Semestre < ActiveRecord::Base
  belongs_to :coordenador, :class_name => 'Professor'

  validates_uniqueness_of :nome, :message => "já utilizado"
  validates_presence_of :nome, :message => "não pode ser deixado em branco"
  validates_uniqueness_of :eh_corrente, :if => :eh_corrente
  validates_format_of :nome, :with => /\A([0-9][0-9][0-9][0-9]).([1-2])\Z/i, :message => " do semestre com formato inválido. Exemplo de nome válido: 2007.2. "
  validates_date :prazo_registro, :before => :prazo_final, :before_message => "deve ser anterior ao Prazo Final"
  validates_date :prazo_final

  def self.corrente
    find_by_eh_corrente(true)
  end
  
  def self.finaliza(coordenador)
    novo = Semestre.create!(:nome => proximo(corrente.nome), :prazo_final => Date.today + 1.day,:prazo_registro => Date.today, :coordenador => coordenador)
    anterior = corrente
    anterior.eh_corrente = false
    anterior.save!

    novo.eh_corrente = true
    novo.save! 
  end

  private

  def self.proximo(sem)
    s = sem.split('.')
    if s[1] == '1' then
      sem.next
    else
      s[0].next + '.1'
    end
  end

  def self.data(data)
    data.day.to_s + "/" + data.month.to_s + "/" + data.year.to_s
  end  

end
