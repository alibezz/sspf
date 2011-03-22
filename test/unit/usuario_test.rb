require File.dirname(__FILE__) + '/../test_helper'
require 'digest/sha1'

class UsuarioTest < ActiveSupport::TestCase
# Caso 5.0
  def test_cria_usuario
    count = Usuario.count
    novo_usuario('teste','1234')

    assert_equal count + 1, Usuario.count
    assert Usuario.find_by_usuario('teste')
  end

  def test_nome_de_usuario_unico
    count = Usuario.count
    novo_usuario('teste','1234')
    Usuario.create(:usuario => 'teste', :senha => '123456', :nome => 'Usuario teste', :email => 'teste@dcc.ufba.br')

    assert_equal count + 1, Usuario.count
    assert Usuario.find_by_usuario('teste')
  end

  def test_senha_obrigatoria
    count = Usuario.count
    Usuario.create(:usuario => 'teste', :nome => 'Usuario teste', :email => 'teste@dcc.ufba.br')

    assert_equal count, Usuario.count
    assert_nil Usuario.find_by_usuario('teste')
  end

  def test_nome_obrigatorio
    count = Usuario.count
    Usuario.create(:usuario => 'teste', :senha => '1234', :email => 'teste@dcc.ufba.br')

    assert_equal count, Usuario.count
    assert_nil Usuario.find_by_usuario('teste')
  end

  def test_email_obrigatorio_e_no_formato
    count = Usuario.count
    Usuario.create(:usuario => 'teste', :senha => '1234', :nome => 'Usuario teste')
    Usuario.create(:usuario => 'teste', :senha => '1234', :nome => 'Usuario teste',:email => 'abcdef')
    Usuario.create(:usuario => 'teste', :senha => '1234', :nome => 'Usuario teste',:email => 'abcdef@abcd')

    assert_equal count, Usuario.count
    assert_nil Usuario.find_by_usuario('teste')
  end

  def test_tamanho_da_senha
    count = Usuario.count
    Usuario.create(:usuario => 'teste', :senha => '123', :nome => 'Usuario teste', :email => 'teste@dcc.ufba.br') # < 4

    assert_equal count, Usuario.count
    assert_nil Usuario.find_by_usuario('teste')

    Usuario.create(:usuario => 'teste', :senha => '123456789012345678900', :nome => 'Usuario teste', :email => 'teste@dcc.ufba.br') # > 20
    assert_equal count, Usuario.count
    assert_nil Usuario.find_by_usuario('teste2')
  end

  def test_tamanho_do_nome_usuario
    count = Usuario.count
    Usuario.create(:usuario => 'aa', :senha => '1234', :nome => 'Usuario teste', :email => 'teste@dcc.ufba.br') # < 3

    assert_equal count, Usuario.count
    assert_nil Usuario.find_by_usuario('aa')

    Usuario.create(:usuario => 'aaaaaaaaaaaaaaaaaaaaa', :senha => '1234', :nome => 'Usuario teste', :email => 'teste@dcc.ufba.br') # > 20

    assert_equal count, Usuario.count
    assert_nil Usuario.find_by_usuario('aaaaaaaaaaaaaaaaaaaaa')
  end

  def test_senha_inacessivel
    count = Usuario.count
    novo_usuario('teste','1234')

    user = Usuario.find_by_usuario('teste')    

    assert_nil user.senha
    assert_not_equal user.senha_encriptada,'1234'
  end

  def test_encripta_senha
    novo_usuario('teste','1234')
    user = Usuario.find_by_usuario('teste')    

    assert_equal user.senha_encriptada, Digest::SHA1.hexdigest('1234' + user.salto)
  end

# Caso 5.1
  def test_autentica_usuario_valido
    novo_usuario('teste','1234')

    assert Usuario.autentica('teste','1234')
    assert Usuario.find_by_usuario('teste'), Usuario.autentica('teste','1234')
  end

  def test_nao_autentica_usuario_invalido
    novo_usuario('teste','1234')

    assert_nil Usuario.autentica('teste','12345')
    assert_nil Usuario.autentica('teste1','1234')
  end

# Caso 5.4
#  def test_troca_senha_por_email
#    user = novo_usuario('teste','1234')
#    user.envia_email('nova_senha')
#
#    assert Usuario.autentica('teste','nova_senha')
#    assert_nil Usuario.autentica('teste','1234')
#  end

# Alunos
  def test_numero_de_matricula_obrigatorio_e_valido
    count = Aluno.count
    Aluno.create(:usuario => 'aluno1', :senha => '1234', :nome => 'Aluno 1', :email => 'aluno1@dcc.ufba.br') # sem matricula
    Aluno.create(:usuario => 'aluno2', :senha => '1234', :nome => 'Aluno 2', :email => 'aluno2@dcc.ufba.br', :matricula => 'asdasdas') # matricula invalida
    Aluno.create(:usuario => 'aluno3', :senha => '1234', :nome => 'Aluno 3', :email => 'aluno3@dcc.ufba.br', :matricula => '2005')
    Aluno.create(:usuario => 'aluno4', :senha => '1234', :nome => 'Aluno 4', :email => 'aluno4@dcc.ufba.br', :matricula => '2005101010')
    assert_equal count , Aluno.count

    Aluno.create(:usuario => 'aluno5', :senha => '1234', :nome => 'Aluno 5', :email => 'aluno5@dcc.ufba.br', :matricula => '200510234') # correto
    assert_equal count + 1, Aluno.count
  end
end
