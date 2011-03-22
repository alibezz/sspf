require File.dirname(__FILE__) + '/../test_helper'

class CoordenadorControllerTest < ActionController::TestCase
  fixtures :usuarios, :semestres

#TODO: antes de cada teste, tem que colocar
#    loga_admin
#ou 
#    loga_usuario(usuario,senha)

## index
  def test_links_do_index_de_coordenacao
    loga_usuario(usuarios(:coordenador).usuario,'1234')
    get :index
    assert_tag :tag => 'a', :attributes => { :href => '/coordenador/professores' }
    assert_tag :tag => 'a', :attributes => { :href => '/coordenador/alunos' }
    assert_tag :tag => 'a', :attributes => { :href => '/coordenador/topicos'}
    assert_tag :tag => 'a', :attributes => { :href => '/coordenador/semestres' }
    assert_tag :tag => 'a', :attributes => {:href => '/'} # Voltar
  end

## Professores ##

  def test_lista_professores
    loga_admin
    get :professores
    
    assert_tag :tag => 'a', :attributes => { :href => '/professor/edita/' + usuarios(:professor1).id.to_s }
    assert_tag :tag => 'a', :attributes => { :href => '/professor/edita/' + usuarios(:professor2).id.to_s }
    assert assigns(:professores).grep(usuarios(:coordenador)).empty?
    assert !assigns(:professores).grep(usuarios(:professor2)).empty?
    assert !assigns(:professores).grep(usuarios(:professor1)).empty?
  end

  def test_link_para_desabilitar_professor_se_orientador_ou_avaliador
    loga_admin
    get :professores
    assert_tag :tag => 'a', :attributes => { :href => '/coordenador/desabilita_professor/' + usuarios(:professor1).id.to_s }
    assert_tag :tag => 'a', :attributes => { :href => '/coordenador/desabilita_professor/' + usuarios(:professor2).id.to_s }
    assert_no_tag :tag => 'a', :attributes => { :href => '/coordenador/desabilita_professor/' + usuarios(:coordenador).id.to_s } # pois nao estah disponivel para isto

    coordenador = usuarios(:coordenador)
    coordenador.avaliador = coordenador.orientador = true
    coordenador.save!

    prof1 = usuarios(:professor1)
    prof1.avaliador = prof1.orientador = false
    prof1.save!

    get :professores
    assert_no_tag :tag => 'a', :attributes => { :href => '/coordenador/desabilita_professor/' + usuarios(:professor1).id.to_s } # pois nao estah disponivel para isto
    assert_no_tag :tag => 'a', :attributes => { :href => '/coordenador/desabilita_professor/' + usuarios(:coordenador).id.to_s } # pois o coordenador nao se desabilita
  end

  def test_busca_professores
    loga_admin
    post :professores, :nome => 'Primeiro'

    assert_tag :tag =>'a', :attributes => { :href => "/professor/edita/" + usuarios(:professor1).id.to_s}
    assert_no_tag :tag =>'a', :attributes => { :href => "/professor/edita/" + usuarios(:professor2).id.to_s}
  end

## Alunos ##

  def test_lista_alunos
    loga_admin
    get :alunos
    assert_response :success
  end

  def test_link_para_projeto_se_submetido
    loga_admin
    projeto = novo_projeto('Projeto1')
    get :alunos
    assert_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/' + projeto.titulo }
  end

## cadastro de professor
  def test_registra_professor
    loga_admin
    get :registra_professor
    assert_tag :tag => 'a', :attributes => { :href => '/coordenador/topicos' } # cadastrar topicos
    assert_tag :tag => 'a', :attributes => { :href => '/coordenador' } # cancelar
  end

  def test_registra_professor
    loga_admin
    count = Professor.count
    post :registra_professor, :professor => {:nome => 'aline', :email => 'frieda@ufba.br', :usuario => 'aline', :senha_confirmation => '1234', :senha => '1234'}
    assert_equal count + 1, Professor.count
    assert_redirected_to :action => 'professores'
  end

  def test_soh_registra_com_confirmacao
    loga_admin
    count = Professor.count
 post :registra_professor, :professor => {:nome => 'aline1', :email => 'frieda1@ufba.br', :usuario => 'aline1', :senha_confirmation => '', :senha => '1234'}
    assert_equal count, Professor.count
  end

### desabilitacao de professor
  def test_mostra_dados_de_removidos
    loga_admin
    professor = novo_professor('professor1', true, true, 'prof', '1234')
    get :desabilita_professor, :id => professor.id
    assert_equal professor, assigns(:professor)
    assert_tag :tag =>'a', :attributes => { :href => "/coordenador"}#Voltar
  end

  def test_desabilitar_um_nao_habilitado
    loga_admin
    professor = novo_professor('professor1', false, false, 'prof', '1234')
    post :desabilita_professor, :id => professor.id
    assert_response :missing
  end

  def test_desabilita_efetivamente
    loga_admin
    professor = novo_professor('professor1', true, true, 'prof', '1234')
    post :desabilita_professor, :id => professor.id
    assert_equal Professor.find_by_nome('professor1').orientador,false
    assert_equal Professor.find_by_nome('professor1').avaliador,false
    assert_redirected_to :action => :professores
  end

## cadastro de alunos
  def test_formulario_registra_aluno
    loga_admin
    get :registra_aluno
    assert_tag :tag => 'a', :attributes => { :href => '/professor' } # cancelar
    assert_tag :tag => 'form', :attributes => { :action => '/coordenador/registra_aluno',  :method => "post"} #registra_aluno
  end

  def test_registra_aluno
    loga_admin
    count = Aluno.count
    post :registra_aluno, :aluno => {:nome => 'Primeiro Aluno', :email => 'aluno@dcc.ufba.br', :matricula => '200412342', :usuario => 'aluno1', :senha => '1234'}
    assert_equal count + 1, Aluno.count
  end

  def test_matricula_obrigatoria_para_aluno
    loga_admin
    count = Aluno.count
    post :registra_aluno, :aluno => {:nome => 'aluno1', :email => 'aluno@dcc.ufba.br', :usuario => 'aluno1', :senha => '1234'}
    assert_equal count, Aluno.count
    assert_response :success
  end

  def test_aluno_registrado_loga
    loga_admin
    aluno = novo_aluno('aluno2','200510513','aluno2','senha')
    assert Usuario.autentica('aluno2','senha')
    assert_equal Usuario.autentica('aluno2','senha'), aluno
  end

## Topicos

  def test_cadastra_topico
    loga_admin
    count = Topico.count
    post :topicos, :topico => { :nome => 't1'}
    assert_equal count + 1, Topico.count
  end

  def test_lista_topicos
    loga_admin
    get :topicos
    assert_response :success
  end

## caso 1.2
#  
#  def test_soh_cadastra_semestre_se_houver_professor
#    loga_admin
#    Professor.destroy_all
#    get :cadastra_semestre
#    assert_response :redirect
#    assert_redirected_to :action => :index
#    follow_redirect
#  end
#
#  def test_cadastra_semestre_corrente
#    loga_admin
#    Semestre.destroy_all
#    post :cadastra_semestre, :semestre => {:nome => '2008.1', :coordenador => novo_professor('prof'), :prazo_final => Date.today, :prazo_registro => Date.today - 2.days}
#    assert_equal 1, Semestre.count
#    assert_response :redirect
#    assert_redirected_to :action => :index
#    follow_redirect
#  end
#
#  def test_cadastra_apenas_um_semestre
#    loga_admin
#    professor = novo_professor('professor1', true, true, 'prof', '1234')
#    post :cadastra_semestre, :semestre => {:nome => '2008.1'}
#    count = Semestre.count
#    post :cadastra_semestre, :semestre => {:nome => '2008.2'}
#    assert_equal count, Semestre.count
#  end
#
#  def test_existe_cancelar_cadastro_de_semestre
#    loga_admin
#    professor = novo_professor('professor1', true, true, 'prof', '1234')
#    get :cadastra_semestre
#    assert_tag :tag =>'a', :attributes => { :href => "/coordenador"} #Voltar
#  end
#

## Semestres

  def test_edicao_semestre
    loga_admin
    get :semestres
    assert_response :success
    assert_equal assigns(:semestre), semestres(:semestre_atual)
  end

  def test_define_prazo_final
    prof = usuarios(:coordenador)
    loga_usuario('coordenador', '1234')
    post :semestres, :semestre => {"prazo_final(1i)"=>"2008", "prazo_final(2i)"=>"10", "prazo_final(3i)"=>"1"}
    assert flash[:notice]
    assert_equal '2008-10-01', Semestre.corrente.prazo_final.to_s
    assert_response :redirect
    assert_redirected_to :action => 'index'
    follow_redirect
  end

## finaliza semestre
  def test_pode_nao_finalizar
    loga_admin
    get :finaliza_semestre
    assert_tag :tag => 'a', :attributes => { :href => '/professor' }#Cancelar
  end

 def test_semestre_corrente_finalizado
    loga_admin
    sem = Semestre.corrente
    post :finaliza_semestre, :coordenador => usuarios(:coordenador).id
    sem.reload
    assert_equal Semestre.proximo(sem.nome), Semestre.corrente.nome
    assert_equal false, sem.eh_corrente 
  end

## bancas

  def test_ve_aviso_se_nao_ha_projetos
    get :bancas
     assert flash
  end

  def test_nao_ve_projetos_de_outros_semestres
    projeto = novo_projeto('Bla')
    Semestre.finaliza(usuarios(:professor1))
    get :bancas
    assert_no_tag :tag => 'a', :attributes => {:href => '/projeto/edita_banca/' + projeto.titulo}
  end 
end  

