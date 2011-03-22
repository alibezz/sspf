require "#{File.dirname(__FILE__)}/../test_helper"

class ProfessorLogadoTest < ActionController::IntegrationTest
  fixtures :usuarios, :semestres, :topicos

  def test_professor_nao_coordenador
    post 'sspf/login', :usuario => {:usuario => usuarios(:professor1).usuario, :senha => '1234'}
    assert_equal @request.session[:id], usuarios(:professor1)
    assert_redirected_to :controller => 'professor', :action => 'index'

    get 'professor/index'
    assert_response :success
    assert_template 'index'
    assert_tag :tag => 'a', :attributes => { :href => '/professor'}
    assert_tag :tag => 'a', :attributes => { :href => '/professor/edita/' + usuarios(:professor1).id.to_s}
    assert_tag :tag => 'a', :attributes => { :href => '/professor/bancas'}
    assert_tag :tag => 'a', :attributes => { :href => '/professor/projetos_orientados'}
    assert_no_tag :tag => 'a', :attributes => { :href => '/coordenador/_professores'}
    
    get 'professor/edita',:id => usuarios(:professor1).id
    assert_response :success
    assert_template 'edita'

    post 'professor/edita',:id => usuarios(:professor1).id, :professor => {:nome => 'Professor 1'}
    assert_redirected_to :action => 'index'

    get 'coordenador/index'
    assert_response :redirect
    assert_template nil
  end
  
  def test_professor_coordenador
    sem = semestres(:semestre_atual)
    sem.coordenador_id = usuarios(:professor1).id
    sem.save!
    assert Semestre.corrente
    assert_equal Semestre.corrente.coordenador_id, usuarios(:professor1).id

    post 'sspf/login', :usuario => {:usuario => usuarios(:professor1).usuario, :senha => '1234'}
    assert_equal @request.session[:id], usuarios(:professor1)
    assert_redirected_to :controller => 'professor', :action => 'index'

    get 'professor/index'
    assert_response :success
    assert_template 'index'
    assert_tag :tag => 'a', :attributes => { :href => '/professor'}
    assert_tag :tag => 'a', :attributes => { :href => '/professor/edita/' + usuarios(:professor1).id.to_s}
    assert_tag :tag => 'a', :attributes => { :href => '/professor/bancas'}
    assert_tag :tag => 'a', :attributes => { :href => '/professor/projetos_orientados'}
    assert_tag :tag => 'a', :attributes => { :href => '/coordenador/professores'}
    
    get 'professor/edita', :id => usuarios(:professor1).id
    assert_response :success
    assert_template 'edita'

    post 'professor/edita',:id =>usuarios(:professor1).id, :professor => {:nome => 'Professor 1'}
    assert Professor.find_by_nome('Professor 1')

    get 'coordenador/index'
    assert_response :success
    assert_template 'index'

    get 'professor/edita/' + usuarios(:professor1).id.to_s
    assert_response :success
    assert_template 'edita'

    get 'professor/edita/' + usuarios(:professor2).id.to_s
    assert_response :success
    assert_template 'edita'
  end
end
