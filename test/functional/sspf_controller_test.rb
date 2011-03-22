require File.dirname(__FILE__) + '/../test_helper'

class SspfControllerTest < ActionController::TestCase
  fixtures :usuarios, :semestres, :topicos
  
  def test_index_mostra_links
    get :index
    assert_tag :tag => 'form', :attributes => { :action => "/sspf/login",  :method => "post" }
    assert_tag :tag => 'a', :attributes => { :href => '/sspf/projetos' }
    assert_tag :tag => 'a', :attributes => { :href => '/sspf/professores' }
    assert_no_tag :tag => 'a', :attributes => { :href => '/coordenador' }
    assert_no_tag :tag => 'a', :attributes => { :href => '/sspf/alunos' }
  end
  
  def test_mostra_projetos_com_link_para_visualizar
    semestre = Semestre.corrente
    if semestre.nil? 
    	semestre = novo_semestre('2008.2')
    end
    professor = novo_professor('orientador')
    novo_projeto('projeto1',professor,semestre, novo_aluno('aluno1', 200610630))
    novo_projeto('projeto2',professor,semestre, novo_aluno('aluno2', 200610623))

    get :projetos
    assert_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/projeto1'}        
    assert_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/projeto2'}        
  end

  def test_soh_visualiza_projetos_do_semestre_corrente
    professor = usuarios(:professor1)
    semestre = semestres(:semestre_atual)
    novo_projeto('projeto1',professor,semestre, novo_aluno('aluno1', 200610630))
    novo_projeto('projeto2',professor,semestre, novo_aluno('aluno2', 200610623))

    get :projetos
    assert_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/projeto1'}        
    assert_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/projeto2'}        

    Semestre.finaliza(professor)
    novo_projeto('projeto3',professor,Semestre.corrente, novo_aluno('aluno3', 200610621))
    semestre.reload
    # A funcao finaliza nao recarrega o valor do semestre corrente
    get :projetos, :semestre => Semestre.corrente.nome
    assert_no_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/projeto1'}        
    assert_no_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/projeto2'}        
    assert_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/projeto3'}        
  end

  def test_busca_projetos
    professor = usuarios(:professor1)
    semestre2 = novo_semestre('2008.2',professor,false)
    novo_projeto('Projeto1',professor,semestres(:semestre_atual), usuarios(:aluno1))
    novo_projeto('Projet2',professor,semestres(:semestre_atual),usuarios(:aluno2))
    novo_projeto('ProjetoAnterior',professor,semestre2,usuarios(:aluno3))

    post :projetos
    assert_response :success
    assert_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/Projeto1' }
    assert_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/Projet2' }
    assert_no_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/ProjetoAnterior' }

    post :projetos, :titulo => 'Projeto'
    assert_response :success
    assert_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/Projeto1' }
    assert_no_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/Projet2' }
    assert_no_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/ProjetoAnterior' }

    post :projetos, :titulo => 'Projeto', :semestre => semestre2.nome
    assert_response :success
    assert_no_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/Projeto1' }
    assert_no_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/Projet2' }
    assert_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/ProjetoAnterior' }
  end

  ## LOGIN ##
  def test_campos_de_senha_e_usuario
    get :index

    assert_tag :tag => 'input', :attributes => {:size => '20', :name => 'usuario[usuario]'}
    assert_tag :tag => 'input', :attributes => {:size => '20', :type => 'password', :name => 'usuario[senha]'}
  end

  def test_login_valido
    novo_usuario('teste','1234')
    post :login, :usuario => {:usuario => 'teste', :senha => '1234'}

    assert_redirected_to :action => 'index', :controller => 'sspf'
    assert session[:id]
    assert_equal session[:id], Usuario.find_by_usuario('teste')

    follow_redirect
    assert_template 'index'
    assert_tag :tag => 'a', :attributes => {:href => '/sspf/logout'}
    assert_tag :tag => 'a', :attributes => {:href => '/sspf/muda_senha/teste'}
  end

  def test_login_invalido
    novo_usuario('teste','1234')

    post :login, :usuario => {:usuario => 'teste1', :senha => '1234'}
    assert_nil session[:id]
    assert flash[:warning]

    post :login, :usuario => {:usuario => 'teste', :senha => '12345'}
    assert_nil session[:id]
    assert flash[:warning]
  end

  ## LOGOUT ##
  def test_usuario_logado_desloga_do_sistema
    loga_usuario(usuarios(:aluno1).usuario,'1234')
    get :logout

    assert_nil @request.session[:id]
    assert flash[:notice]
    assert_equal flash[:notice], "Usuário 'aluno01' deslogado"
    assert_redirected_to :action => 'index', :controller => 'sspf'
  end

  def test_usuario_nao_logado_desloga_do_sistema
    get :logout

    assert_nil session[:id]
    assert_redirected_to :action => 'index', :controller => 'sspf'
  end

  ## Mudar Senha ##
  def test_mudanca_de_senha
    loga_usuario(usuarios(:aluno1).usuario,'1234')
    get :muda_senha, :id => 'aluno01'

    assert_equal Usuario.find_by_usuario('aluno01'), assigns(:usuario)
    assert_tag :tag => 'input', :attributes => {:size => '20', :type => 'password', :name => 'senha_antiga'}
    assert_tag :tag => 'input', :attributes => {:size => '20', :type => 'password', :name => 'usuario[senha_confirmation]'}
    assert_tag :tag => 'input', :attributes => {:size => '20', :type => 'password', :name => 'usuario[senha]'}
  end

  def test_muda_senha_mesmo
    user = loga_usuario('aluno01','1234')
    assert user
    post :muda_senha, :id => 'aluno01', :usuario => {:senha => '2345', :senha_confirmation => '2345'}, :senha_antiga => '1234'

    assert flash[:notice]
    assert Usuario.autentica('aluno01','2345') 
    assert_nil Usuario.autentica('aluno01','1234') 
    assert_nil Usuario.autentica('aluno01','outra') 
  end

  def test_nao_muda_senha_sem_anterior
    user = loga_usuario('aluno01','1234')
    post :muda_senha, :id => 'aluno01', :usuario => {:senha => '2345', :senha_confirmation => '2345'}

    assert flash[:warning]
    assert_response 200
    assert_equal user, Usuario.find_by_usuario('aluno01')
    assert_equal user, Usuario.autentica('aluno01','1234')
    assert_nil Usuario.autentica('aluno01','2345')
  end

  def test_soh_usuario_ou_coordenador_muda_sua_senha
    get :muda_senha, :id => usuarios(:aluno2).usuario
    assert_response :missing

    user = loga_usuario(usuarios(:aluno1).usuario,'1234')
    get :muda_senha, :id => usuarios(:aluno2).usuario
    assert_response :missing

    loga_admin
    get :muda_senha, :id => usuarios(:aluno2).usuario
    assert_response :success
  end

end
