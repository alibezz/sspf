ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...
  def novo_projeto(titulo, orientador=nil, semestre=nil, aluno=nil, topicos=[])
    if topicos.empty?
	   topicos = [Topico.create!(:nome => 't' + titulo).id]
    end
    orientador ||= Professor.create!(:nome => 'orientador', :orientador => true, :email => 'orientador@dcc.ufba.br',:usuario => 'orientador', :senha => '1234')
    aluno ||= Aluno.create!(:nome => 'aluno1', :email => 'aluno@dcc.ufba.br', :usuario => 'aluno1', :senha => '1234', :matricula => '200510213')
    projeto = Projeto.new(:titulo => titulo, :aluno => aluno, :orientador => orientador, :semestre => semestre || Semestre.corrente || novo_semestre('2008.1'), :topico_ids => topicos) 

    
    # anteprojeto é atributo protegido
    projeto.arquivo_anteprojeto = fixture_file_upload("anteprojeto.pdf",'content/pdf', :binary)

    if projeto.save!
      projeto
    end
  end

  def novo_semestre(nome, coordenador=nil, corrente=true, prazo_final=Date.today + 5.days, prazo_registro=Date.today + 2.days)
    Semestre.create!(:nome => nome, :coordenador => coordenador || novo_professor('coordenador'), :eh_corrente => corrente, :prazo_final => prazo_final, :prazo_registro => prazo_registro) 
  end

  def novo_professor(nome, orientador=true, avaliador=true, usuario = nil, senha = '1234')
    usuario ||= nome
    Professor.create!(:nome => nome, :email => usuario + '@dcc.ufba.br', :orientador => orientador, :avaliador => avaliador, :usuario => usuario || nome, :senha => senha)
  end

  def novo_usuario(usuario, senha = nil,nome = nil, email = nil)
    Usuario.create!(:usuario => usuario, :senha => senha || '123456', :nome => nome || 'Usuario ' + usuario, :email => email || usuario + '@dcc.ufba.br')
  end

  def novo_aluno(nome, matricula, usuario = nil, senha = '1234')
    usuario ||= nome
    Aluno.create!(:usuario => usuario, :senha => senha, :matricula => matricula, :nome => nome, :email => usuario + '@dcc.ufba.br')
  end

  def novo_topico(nome)
    Topico.create!(:nome => nome)
  end

  def loga_usuario(usuario, senha)
    @request.session[:id] = Usuario.find_by_usuario(usuario)
  end

  def loga_aluno(aluno, senha)
    loga_usuario(aluno,senha)
  end

  def loga_admin
    if Semestre.corrente
      loga_usuario(usuarios(:coordenador).usuario,'1234')
    end
  end

  def cria_projeto
    orientador = Professor.create!(:nome => 'orientador', :orientador => true, :email => 'orientador@dcc.ufba.br',:usuario => 'orientador', :senha => '1234')
    post 'projeto/registra', :projeto => {:titulo => 'Projeto 1', :resumo => ''}, :orientador => orientador.id, :topics => [novo_topico('1234')], :arquivo_anteprojeto => fixture_file_upload("anteprojeto.pdf",'content/pdf', :binary)
  end
end
