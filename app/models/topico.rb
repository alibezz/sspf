class Topico < ActiveRecord::Base
  validates_presence_of :nome, :message => "não pode ser deixado em branco"
  validates_uniqueness_of :nome, :message => "já existe"

  has_and_belongs_to_many :professors
  has_and_belongs_to_many :projetos
end
