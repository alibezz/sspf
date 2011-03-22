require 'digest/sha1'
class Usuario < ActiveRecord::Base
  validates_presence_of :nome, :email, :message => "não pode ser deixado em branco"
  validates_presence_of :usuario, :senha, :message => "não pode ser deixado em branco", :if => :senha_necessaria? 
  validates_uniqueness_of :usuario, :email, :message => "já utilizado"
  validates_length_of :senha, :within => 4..20, :too_long => "deve conter no máximo 20 caracteres",:too_short => "deve conter no mínimo 4 caracteres", :if => :senha_necessaria? 
  validates_length_of :usuario, :within => 3..20,:too_long => "deve conter no máximo 20 caracteres",:too_short => "deve conter no mínimo 3 caracteres"
  validates_confirmation_of :senha, :message => "deve coincidir com sua confirmação", :if => :senha_necessaria?
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "com formato inválido"

  def self.autentica(usuario,senha)
    user = Usuario.find_by_usuario(usuario)
    user if user && user.senha_encriptada == Usuario.encripta(senha,user.salto)
  end

  attr_protected :salt, :senha_encriptada
  attr_reader :senha

  def senha= nova_senha
    @senha = nova_senha
    self.salto = [Array.new(10){rand(256).chr}.join].pack("m").chomp
    self.senha_encriptada = Usuario.encripta(nova_senha, salto)
  end

  def envia_email(nova_senha = nil)
    nova_senha ||= [Array.new(10){rand(256).chr}.join].pack("m").chomp
    self.senha = self.senha_confirmation = nova_senha
    self.save
    usuario = {:nova_senha => nova_senha, :email => self.email, :nome => self.nome}
    Notificacao.envia_senha(usuario)
  end

private
  def self.encripta(senha, salto)
    Digest::SHA1.hexdigest(senha + salto)
  end

  def senha_necessaria?
    senha_encriptada.blank? || !senha.nil?
  end
end
