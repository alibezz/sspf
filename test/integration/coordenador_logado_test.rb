require "#{File.dirname(__FILE__)}/../test_helper"

class CoordenadorLogadoTest < ActionController::IntegrationTest
  fixtures :usuarios
  # Primeiro acesso do sistema
  def test_primeiro_acesso
    Semestre.destroy_all
    Usuario.destroy_all
    Topico.destroy_all

    get 'sspf/'
    assert_redirected_to :controller => :setup, :action => :index
    
    # request_uri tem que ser '/setup' senao redireciona
    post 'setup', :professor => {:nome => 'Primeiro Professor', :email => 'admin@dcc.ufba.br', :usuario => 'prof0', :senha => '1234',:senha_confirmation => '1234'},
                        :semestre => {:nome => '2008.1', :prazo_registro => Date.today, :prazo_final => Date.today + 2.days}
    assert_equal Professor.count,1
    assert_equal Semestre.count,1
    assert Semestre.corrente
    assert_redirected_to :controller => 'sspf', :action => 'index'
    assert_equal Semestre.corrente.coordenador, Professor.find_by_usuario('prof0')
    assert_equal @request.session[:id],Semestre.corrente.coordenador

    get 'coordenador/'
    assert_response :success
    assert_equal Semestre.corrente.coordenador, Professor.find_by_usuario('prof0')
    assert_equal @request.session[:id],Semestre.corrente.coordenador
  end

  def test_setup_inacessivel_se_semestre
    assert Semestre.corrente
    get 'setup/'
    assert_response :missing

    loga_admin
    get 'setup/'
    assert_response :missing
  end
end
