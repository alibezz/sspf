require File.dirname(__FILE__) + '/../test_helper'

class ProfessorControllerTest < ActionController::TestCase
  fixtures :usuarios, :semestres, :topicos

# Edição do professor

  def test_professor_edita_seu_proprio_perfil
    prof = novo_professor('um professor', false, false, 'prof1', '1234')
    loga_usuario('prof1','1234');

    get :edita, :id => prof.id
    assert_response :success
    assert_equal prof,assigns(:professor)
  end

  def test_outro_professor_nao_edita
    prof1 = novo_professor('um professor', false, false, 'prof1', '1234')
    prof2 = novo_professor('outro professor', false, false, 'prof2', '1234')

    loga_usuario('prof1','1234');

    get :edita, :id => prof2.id
    assert_template nil
    assert_response :redirect
  end

  def test_coordenador_edita_qualquer_professor
    loga_admin
    prof1 = novo_professor('um professor', false, false, 'prof1', '1234')
    prof2 = novo_professor('outro professor', false, false, 'prof2', '1234')

    get :edita, :id => prof1.id
    assert_template 'edita'
    assert_response :success

    get :edita, :id => prof2.id
    assert_template 'edita'
    assert_response :success
  end

  def test_aluno_nao_edita_professor
    aluno = novo_aluno("Aluno qualquer", 200456789, 'alunoqq','1234')
    prof1 = novo_professor('um professor', false, false, 'prof1', '1234')
    loga_usuario(aluno.nome,'1234')

    get :edita, :id => prof1.id
    assert_response :redirect
    assert_template nil
  end

  def test_edita
    prof = novo_professor('nome', false, false, 'aaa', '1234')
    loga_usuario('aaa','1234');
    post :edita, :id => prof.id, :professor => { :email => 'mail2@a.com', :nome => 'Novo_nome' , :orientador => true, :avaliador => true}

    assert_equal Professor.find_by_usuario('aaa').email,'mail2@a.com'
    assert_equal Professor.find_by_usuario('aaa').nome,'Novo_nome'
    assert_equal Professor.find_by_usuario('aaa').orientador, true
    assert_equal Professor.find_by_usuario('aaa').avaliador, true
  end

  def test_professor_editado_contem_seus_dados
    prof =  novo_professor('a', false, false, 'aaa', '1234')
    loga_usuario('aaa','1234')
    get :edita, :id => prof.id
    
    assert_equal prof, assigns(:professor)
  end

  def test_editado_vai_para_index
    professor = novo_professor('aline', false, false, 'aaa', '1234')
    loga_usuario('aaa','1234')
    post :edita, :id => professor.id
    assert_response :redirect
    assert_redirected_to :action => :index
  end

# Geração de folha
  def test_nao_gera_folha_sem_3_avaliacoes
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), usuarios(:aluno1), [topicos(:t1)])
    prof = novo_professor('Teste')

    projeto.create_banca
    projeto.banca.professor_ids = [projeto.orientador_id, prof.id, usuarios(:professor2).id]
    projeto.save!

    loga_usuario(usuarios(:professor1).usuario, '1234')
    assert_equal projeto.avaliacaos.length, 0 
    get :projetos_orientados
    get :gera_folha, :id => projeto.titulo #Nenhuma avaliação
    assert_response :redirect
    assert_redirected_to :action => :projetos_orientados
	
    projeto.avaliacaos.build  #abstraindo o valor das coisas.
    assert_equal projeto.avaliacaos.length, 1
    get :gera_folha, :id => projeto.titulo #1 avaliação
    assert_response :redirect
    assert_redirected_to :action => :projetos_orientados
	

    projeto.avaliacaos.build  #abstraindo o valor das coisas.
    assert_equal projeto.avaliacaos.length, 2 
    get :gera_folha, :id => projeto.titulo #2 avaliações
    assert_response :redirect
    assert_redirected_to :action => :projetos_orientados
  end
end
