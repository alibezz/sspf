require File.dirname(__FILE__) + '/../test_helper'

class SetupControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def test_formulario_de_setup
    Semestre.destroy_all
    Usuario.destroy_all
    get :index
    assert_tag :tag => 'form', :attributes => { :action => '/setup',  :method => "post"} #registra_aluno
    assert_tag :tag => 'input', :attributes => {:size => '20', :name => 'semestre[nome]'}
  end

  def test_registra_professor_e_semestre
    Semestre.destroy_all
    Usuario.destroy_all

    post 'index', :professor => {:nome => 'Primeiro Professor', :email => 'admin@dcc.ufba.br', :usuario => 'prof0', :senha => '1234',:senha_confirmation => '1234'},
                        :semestre => {:nome => '2008.1', :prazo_registro => Date.today, :prazo_final => Date.today + 2.days}
    assert_equal Professor.count,1
    assert_equal Semestre.count,1
    assert Semestre.corrente
    assert_redirected_to :controller => 'sspf', :action => 'index'
    assert_equal Semestre.corrente.coordenador, Professor.find_by_usuario('prof0')
    assert_equal @request.session[:id],Semestre.corrente.coordenador
  end

  def test_nao_registra_professor_semestre
    Semestre.destroy_all
    Usuario.destroy_all

    post 'index', :professor => {:nome => 'Primeiro Professor', :email => 'admin@dcc.ufba.br', :usuario => 'prof0', :senha => '1234',:senha_confirmation => '1234'},
                        :semestre => {:prazo_registro => Date.today, :prazo_final => Date.today + 2.days}
    assert_equal Professor.count,0
    assert_equal Semestre.count,0
    assert_nil Semestre.corrente
    assert_nil @request.session[:id]
  end
end
