class Aluno < Usuario
  validates_presence_of :matricula, :message => "não pode ser deixado em branco"
  validates_format_of :matricula, :with => /^\d{9,9}$/, :message => "com formato inválido"
  has_one :projeto
end
