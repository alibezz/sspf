require "#{File.dirname(__FILE__)}/../test_helper"

class AlunoLogadoTest < ActionController::IntegrationTest
  fixtures :usuarios, :semestres, :topicos

  def test_aluno_loga_sem_projeto
    get '/'
    post 'sspf/login', :usuario => {:usuario => 'aluno01', :senha => '1234'}

    assert_redirected_to :controller => 'projeto', :action => 'index'

    get 'projeto/index'
    assert_response :success

    get 'projeto/registra/'
    assert_response :success 
  end

  def test_aluno_loga_com_projeto
    projeto = novo_projeto('Projeto 1', usuarios(:professor1), semestres(:semestre_atual), usuarios(:aluno2)) 
    
    get '/'
    post 'sspf/login', :usuario => {:usuario => usuarios(:aluno2).usuario, :senha => '1234'}

    assert_redirected_to :controller => 'projeto', :action => 'index'
    
    get 'projeto/edita/' + projeto.titulo
    assert_response :success 

    # A avaliação não tá feita, nem a banca.
    get 'projeto/ver_avaliacao/' + projeto.titulo
    assert_response :redirect 
    get 'projeto/banca/' + projeto.titulo
    assert_response :redirect

    #A banca tah feita, mas nao a avaliação
    prof = novo_professor('Teste')
    projeto.create_banca
    projeto.banca.professor_ids = [projeto.orientador_id, prof.id, usuarios(:professor2).id]
    projeto.save!
    get 'projeto/banca/' + projeto.titulo
    assert_response :success

    get 'projeto/ver_avaliacao/' + projeto.titulo
    assert_response :redirect 

    get 'projeto/visualiza/' + projeto.titulo
    assert_response :success 

    # Banca e avaliacoes feitas
    post 'sspf/login', :usuario => {:usuario => prof.usuario, :senha => '1234'}
    post 'projeto/avaliacao', :id => projeto.titulo, :avaliacao => {:clareza => 10, :objetividade => 9, :correcao => 8, :detalhamento => 7, :dominio => 6, :resultados => 5, :organizacao => 4, :material_apoio => 3, :transmissao_assunto => 2 }

    post 'sspf/login', :usuario => {:usuario => usuarios(:aluno2).usuario, :senha => '1234'}
    get 'projeto/ver_avaliacao/' + projeto.titulo
    assert_response :success 

    post 'sspf/login', :usuario => {:usuario => prof.usuario, :senha => '1234'}
    post 'projeto/avaliacao', :id => projeto.titulo, :avaliacao => {:clareza => 56, :objetividade => 9, :correcao => 8, :detalhamento => 7, :dominio => 6, :resultados => 5, :organizacao => 4, :material_apoio => 3, :transmissao_assunto => 2 }

    post 'sspf/login', :usuario => {:usuario => usuarios(:aluno2).usuario, :senha => '1234'}
    get 'projeto/ver_avaliacao/' + projeto.titulo
    assert_response :success 
    assert_equal assigns(:avaliacoes).size,1

    post 'sspf/login', :usuario => {:usuario => projeto.orientador.usuario, :senha => '1234'}
    post 'projeto/avaliacao', :id => projeto.titulo, :avaliacao => {:clareza => 56, :objetividade => 9, :correcao => 8, :detalhamento => 7, :dominio => 6, :resultados => 5, :organizacao => 4, :material_apoio => 3, :transmissao_assunto => 2 }

    post 'sspf/login', :usuario => {:usuario => usuarios(:aluno2).usuario, :senha => '1234'}
    get 'projeto/ver_avaliacao/' + projeto.titulo
    assert_response :success 
    assert_equal assigns(:avaliacoes).size,2
  end

  def test_aluno_nao_tem_acesso_a_outros_controllers
    post 'sspf/login', :usuario => {:usuario => 'aluno01', :senha => '1234'}

    get 'coordenador/'
    assert_response :redirect
    assert_template nil

    get 'coordenador/cadastra_aluno'
    assert_response :redirect
    assert_template nil

    get 'professor/'
    assert_response :redirect
    assert_template nil

    get 'professor/edita/'
    assert_response :redirect
    assert_template nil
  end
end
