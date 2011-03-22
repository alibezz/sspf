require File.dirname(__FILE__) + '/../test_helper'
class ProjetoControllerTest < ActionController::TestCase
  fixtures :usuarios, :semestres, :topicos

## Entradas no controller ##
  def test_usuario_comum_so_acessa_visualiza
    get :edita
    assert flash[:warning]
    assert_response :redirect
    assert_template nil

    projeto = novo_projeto('Um projeto', usuarios(:professor1), semestres(:semestre_atual), usuarios(:aluno1), [topicos(:t1)])
    get :edita, :id => "Um projeto"
    assert flash[:warning]
    assert_response :redirect
    assert_template nil

    get :registra
    assert flash[:warning]
    assert_response :redirect
    assert_template nil

    get :visualiza
    assert_response :missing
    
    get :visualiza, :id => "Projeto inexistente"
    assert_response :missing

    get :visualiza, :id => "Um projeto"
    assert_response :success
    assert_template 'visualiza'
    assert_equal assigns(:projeto), projeto
  end

## Registra projeto
  def test_nao_registra_sem_orientador_e_sem_topico
    Professor.destroy_all
    novo_professor('Professor nao orientador', false, true, 'professor99','1234')
    Topico.destroy_all
    loga_usuario(usuarios(:aluno1).usuario, '1234')
    get :registra
    assert_response :redirect
    assert_redirected_to :action => 'erro'
    follow_redirect
  end

  def test_nao_pode_registrar_fora_do_prazo
    semestres(:semestre_atual).prazo_registro = Date.today - 1.day
    semestres(:semestre_atual).save!
    assert_equal Semestre.corrente.prazo_registro, Date.today - 1.day

    assert loga_usuario(usuarios(:aluno1).usuario, '1234')
    get :registra
    assert_response :redirect
    assert_redirected_to :action => 'erro'
    follow_redirect
  end

  def test_formulario_devolvido
    loga_usuario('aluno01', '1234')
    get :registra
    assert_tag :tag => 'form', :attributes => { :action => "/projeto/registra",  :enctype => "multipart/form-data", :method => "post"}
  end

  def test_registra_mesmo
    aluno1 = loga_usuario('aluno01', '1234')
    count = Projeto.count
    post :registra, :projeto => {:titulo => '123', :resumo => '123',:topico_ids => [topicos(:t1).id, topicos(:t2).id] }, :orientador => usuarios(:professor1).id, :arquivo_anteprojeto => fixture_file_upload("anteprojeto.pdf",'content/pdf', :binary)
    assert_equal count + 1, Projeto.count
    assert_equal aluno1, Projeto.find_by_titulo('123').aluno
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end


  def test_recebe_ante_projeto
    aluno = loga_usuario('aluno01', '1234')
    projeto = novo_projeto('123', usuarios(:professor1), semestres(:semestre_atual), aluno, [topicos(:t1)])
    get :visualiza, :id => '123'
    assert_tag :tag => 'a', :attributes => {:href => '/projeto/anteprojeto/123'}
  end

  def test_ante_projeto_obrigatorio
    aluno = loga_usuario('aluno01','1234')
    count = Projeto.count
    post :registra, :projeto => {:titulo => '123', :resumo => '123'}, :orientador => usuarios(:professor1).id, :topics => [topicos(:t1), topicos(:t2)]
    assert_equal count, Projeto.count
    assert_response :success
  end

  def test_somente_aluno_registra_projeto
    get :registra
    assert flash[:warning]
    assert_response :redirect

    loga_admin
    get :registra
    assert flash[:warning]
    assert_response :redirect

    loga_usuario(usuarios(:professor1).usuario,'1234')
    get :registra
    assert flash[:warning]
    assert_response :redirect
  end

### Visualiza projeto
  def test_mostra_projeto_registrado
    aluno = loga_usuario('aluno01', '1234')
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), aluno, [topicos(:t1)])
    get :visualiza, :id => "Teste"
    assert_equal projeto, assigns(:projeto)
  end

  def test_projeto_inexistente
    loga_usuario('aluno01', '1234')
    get :visualiza, :id => "Este nao existe"
    assert_response :missing
  end

  def test_link_download_projetofinal
    aluno = loga_usuario('aluno01', 'aline')
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), aluno, [topicos(:t1)])
    projeto.projeto_final = fixture_file_upload("projeto_final.pdf",'content/pdf', :binary)
    projeto.save!
    get :visualiza, :id => "Teste"
    assert_tag :tag => 'a', :attributes => { :href => '/projeto/projeto_final/Teste'}
  end

#### Edita projeto

  def test_editar_proprio_projeto_existente
    aluno = loga_usuario('aluno01', '1234')
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), aluno, [topicos(:t1)])
    get :edita, :id => projeto.titulo
    post :edita, :id => projeto.titulo, :projeto => { :resumo => 'novo resumo do projeto'}
    assert Projeto.find_by_titulo('Teste')
    assert_equal 'novo resumo do projeto', Projeto.find_by_titulo('Teste').resumo
  end

  def test_form_para_editar_projeto_existente
    aluno = loga_usuario('aluno01', '1234')
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), aluno, [topicos(:t1)])
    get :edita, :id => projeto.titulo
    assert_tag :tag => 'a', :attributes => {:href => '/projeto'}
    assert_response :success
    assert_equal projeto, assigns(:projeto)
  end   

  def test_nao_pode_editar_fora_do_prazo
    aluno = loga_usuario('aluno01', '1234')
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), aluno, [topicos(:t1)])
    semestres(:semestre_atual).prazo_registro = Date.today - 2;
    semestres(:semestre_atual).prazo_final = Date.today - 1;
    semestres(:semestre_atual).save!
    get :edita, :id => projeto.titulo
    assert_response :redirect
    assert_redirected_to :action => 'erro'
    follow_redirect
  end

  def test_adiciona_projeto_final
    aluno = loga_usuario('aluno01', '1234')
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), aluno, [topicos(:t1)])
    post :edita, :id => projeto.titulo, :arquivo_projeto_final => fixture_file_upload("projeto_final.pdf",'content/pdf',:binary)
    assert Projeto.find_by_titulo(projeto.titulo).projeto_final

    get :visualiza, :id => projeto.titulo
    assert_tag :tag => 'a', :attributes => { :href => '/projeto/projeto_final/' + projeto.titulo }
  end

  def test_sobrescreve_projeto_final
    aluno = loga_usuario('aluno01', '1234')
    projeto = novo_projeto('teste', usuarios(:professor1), semestres(:semestre_atual), aluno, [novo_topico('topico')])
    post :edita, :id => projeto.titulo, :arquivo_projeto_final => fixture_file_upload("projeto_final.pdf",'content/pdf',:binary)
    assert_equal Projeto.find_by_titulo(projeto.titulo).projeto_final,'projeto_final.pdf'

    post :edita, :id => projeto.titulo, :arquivo_projeto_final => fixture_file_upload("anteprojeto.pdf",'content/pdf',:binary)
    assert_equal Projeto.find_by_titulo(projeto.titulo).projeto_final,'anteprojeto.pdf'
  end

  def test_outros_nao_editam
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), usuarios(:aluno1), [topicos(:t1)])

    get :edita, :id => projeto.titulo
    assert_template nil
    assert_response :redirect

    loga_usuario(usuarios(:aluno2).usuario, '1234')
    get :edita, :id => projeto.titulo
    assert_template nil
    assert_response :redirect

    loga_usuario(usuarios(:professor2).usuario, '1234')
    get :edita, :id => projeto.titulo
    assert_template nil
    assert_response :redirect
  end

  def test_edita_projeto_inexistente
    Projeto.destroy_all
    get :edita, :id => "Este nao existe"
    assert_response :redirect
    assert_template nil
  end

  def test_nao_edita_projeto_de_semestre_passado
    aluno = loga_usuario('aluno01', '1234')
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), aluno, [topicos(:t1)])
    Semestre.finaliza(usuarios(:professor1))
    get :edita, :id => projeto.titulo
    assert_response :redirect
    assert flash[:warning]
    assert_template nil
  end

## Edita Bancas

  def test_cria_banca
    loga_admin
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), usuarios(:aluno1), [topicos(:t1)])
    prof = novo_professor('Teste')	
    assert_nil projeto.banca

    post :edita_banca, :id => projeto.titulo, :banca => {:professor_ids => [usuarios(:professor2).id, prof.id, projeto.orientador_id]}
    assert_redirected_to :action => 'bancas', :controller => 'coordenador'

    projeto.reload
    assert_equal projeto.banca.professors, [usuarios(:professor1), usuarios(:professor2), prof]

    assert Professor.find(prof.id).bancas.grep(projeto.banca)
    assert Professor.find(usuarios(:professor1)).bancas.grep(projeto.banca)
    assert Professor.find(usuarios(:professor2)).bancas.grep(projeto.banca)
  end

  def test_o_orientador_deve_estar_na_banca
    loga_admin
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), usuarios(:aluno1), [topicos(:t1)])
    prof = novo_professor('Teste')	
    banca = projeto.banca
    assert_nil projeto.banca
    
    post :edita_banca, :id => projeto.titulo, :banca => {:professor_ids => [usuarios(:professor2).id, prof.id]} # Sem orientador
    projeto.reload

    assert Professor.find(prof.id).bancas.grep(banca).empty?
    assert_nil projeto.banca
  end

  def test_aluno_ve_banca
    loga_admin
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), usuarios(:aluno1), [topicos(:t1)])
    prof = novo_professor('Teste')	

    aluno = loga_usuario(usuarios(:aluno1).usuario,'1234')
    get :banca, :id => projeto.titulo # sem banca

    loga_admin
    projeto.reload
    banca = projeto.banca
    projeto.create_banca
    projeto.banca.professor_ids = [projeto.orientador_id, prof.id, usuarios(:professor2).id]
    projeto.save!

    aluno = loga_usuario(usuarios(:aluno1).usuario,'1234')
    get :banca, :id => projeto.titulo # banca nao vazia
    assert_response :success
    assert_equal assigns(:professores),[Professor.find(projeto.orientador_id),  usuarios(:professor2), prof]
  end

## Avaliacao ##
  def test_avalia_projeto
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), usuarios(:aluno1), [topicos(:t1)])
    prof = novo_professor('Teste')
    projeto.create_banca
    projeto.banca.professor_ids = [projeto.orientador_id, prof.id, usuarios(:professor2).id]
    projeto.save!
    assert projeto.avaliacaos.empty?

    professor = loga_usuario(usuarios(:professor1).usuario,'1234')

    post :avaliacao, :id => projeto.titulo, :avaliacao => {:clareza => 10, :objetividade => 9, :correcao => 8, :detalhamento => 7, :dominio => 6, :resultados => 5, :organizacao => 4, :material_apoio => 3, :transmissao_assunto => 2 }

    assert_response :success
    avaliacoes = Projeto.find(projeto.id).avaliacaos
    assert !avaliacoes.empty?
    aval1 = Avaliacao.find(:first, :conditions => {:professor_id => professor.id, :projeto_id => projeto.id})
    assert aval1
    assert avaliacoes.grep(aval1)
    assert_equal aval1.versao_corrigida, false
    assert_equal aval1.clareza, 10

    professor = loga_usuario(prof.usuario,'1234')

    post :avaliacao, :id => projeto.titulo, :avaliacao => {:clareza => 9, :objetividade => 9, :correcao => 8, :detalhamento => 7, :dominio => 6, :resultados => 5, :organizacao => 4, :material_apoio => 3, :transmissao_assunto => 2 }

    assert_response :success
    avaliacoes = Projeto.find(projeto.id).avaliacaos
    assert !avaliacoes.empty?
    aval2 = Avaliacao.find(:first, :conditions => {:professor_id => professor.id, :projeto_id => projeto.id})
    assert aval2
    assert avaliacoes.grep(aval2)
    assert_equal aval2.versao_corrigida, false
    assert_equal aval2.clareza, 9

    professor = loga_usuario(usuarios(:professor2).usuario,'1234')

    post :avaliacao, :id => projeto.titulo, :avaliacao => {:clareza => 8, :objetividade => 9, :correcao => 8, :detalhamento => 7, :dominio => 6, :resultados => 5, :organizacao => 4, :material_apoio => 3, :transmissao_assunto => 2, :versao_corrigida => true }

    assert_response :success
    avaliacoes = Projeto.find(projeto.id).avaliacaos
    assert !avaliacoes.empty?
    aval3 = Avaliacao.find(:first, :conditions => {:professor_id => professor.id, :projeto_id => projeto.id})
    assert aval3
    assert avaliacoes.grep(aval3)
    assert_equal aval3.versao_corrigida, true
    assert_equal aval3.clareza, 8

    # Todas tres avaliacoes existem
    assert_equal avaliacoes.size, 3
    assert avaliacoes.grep(aval1)
    assert avaliacoes.grep(aval2)
    assert avaliacoes.grep(aval3)
  end

  def test_nao_avaliador_nao_avalia
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), usuarios(:aluno1), [topicos(:t1)])
    prof = novo_professor('Teste')
    projeto.create_banca
    projeto.banca.professor_ids = [projeto.orientador_id, prof.id, usuarios(:professor2).id]
    projeto.save!

    prof0 = novo_professor('Sembanca')

    professor = loga_usuario(prof0.usuario,'1234') # Nao estah na banca

    post :avaliacao, :id => projeto.titulo, :avaliacao => {:clareza => 10, :objetividade => 9, :correcao => 8, :detalhamento => 7, :dominio => 6, :resultados => 5, :organizacao => 4, :material_apoio => 3, :transmissao_assunto => 2 }

    assert_response :redirect
    assert flash[:warning]
    assert_redirected_to :controller => 'sspf', :action => 'index'
    assert Projeto.find(projeto.id).avaliacaos.empty?

    @request.session[:id] = nil

    post :avaliacao, :id => projeto.titulo, :avaliacao => {:clareza => 10, :objetividade => 9, :correcao => 8, :detalhamento => 7, :dominio => 6, :resultados => 5, :organizacao => 4, :material_apoio => 3, :transmissao_assunto => 2 }

    assert_response :redirect
    assert flash[:warning]
    assert_redirected_to :controller => 'sspf', :action => 'index'
    assert Projeto.find(projeto.id).avaliacaos.empty?
  end

  def test_nota_final_calculada
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), usuarios(:aluno1), [topicos(:t1)])
    prof = novo_professor('Teste')
    projeto.create_banca
    projeto.banca.professor_ids = [projeto.orientador_id, prof.id, usuarios(:professor2).id]
    projeto.save!

    professor = loga_usuario(usuarios(:professor1).usuario,'1234')

    post :avaliacao, :id => projeto.titulo, :avaliacao => {:clareza => 10, :objetividade => 9, :correcao => 8, :detalhamento => 7, :dominio => 6, :resultados => 5, :organizacao => 4, :material_apoio => 3, :transmissao_assunto => 3 }
    assert_response :success
    assert_template 'avaliacao'
    nota = (10+9+8+7+6+5+4+3+3)/90.0; nota = "%.1f" % nota

    assert_equal assigns(:nota), nota.to_s

    get :avaliacao, :id => projeto.titulo
    assert_response :success
    assert_template 'avaliacao'
    assert_equal assigns(:nota), nota
    post :avaliacao, :id => projeto.titulo, :avaliacao => {:clareza => 9, :objetividade => 9, :correcao => 8, :detalhamento => 7, :dominio => 6, :resultados => 5, :organizacao => 4, :material_apoio => 3, :transmissao_assunto => 3 }
    assert_response :success
    assert_template 'avaliacao'
    assert_equal assigns(:nota), nota.to_s

    get :avaliacao, :id => projeto.titulo
    assert_response :success
    assert_template 'avaliacao'
    assert_equal assigns(:nota), nota
  end

  def test_formulario_de_avaliacao 
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), usuarios(:aluno1), [topicos(:t1)])
    prof = novo_professor('Teste')
    projeto.create_banca
    projeto.banca.professor_ids = [projeto.orientador_id, prof.id, usuarios(:professor2).id]
    projeto.save!

    professor = loga_usuario(usuarios(:professor1).usuario,'1234')
    get :avaliacao, :id => projeto.titulo

    assert_response :success
    assert_tag :tag => 'a', :attributes => {:href => '/professor'} # Voltar
    assert_nil assigns(:nota)
    assert_tag :tag => 'input', :attributes => {:name => 'avaliacao[versao_corrigida]', :type => 'checkbox'}
  end

  def test_aluno_ve_avaliacao
    projeto = novo_projeto('Teste', usuarios(:professor1), semestres(:semestre_atual), usuarios(:aluno1), [topicos(:t1)])
    prof = novo_professor('Teste')

    aluno = loga_usuario(usuarios(:aluno1).usuario,'1234')

    get :ver_avaliacao, :id => projeto.titulo
    assert flash[:notice] # sem banca
    assert_redirected_to :action => 'index'

    projeto.create_banca
    projeto.banca.professor_ids = [projeto.orientador_id, prof.id, usuarios(:professor2).id]
    projeto.save!

    get :ver_avaliacao, :id => projeto.titulo
    assert flash[:notice] # sem avaliacao
    assert_redirected_to :action => 'index'

    professor = loga_usuario(usuarios(:professor1).usuario,'1234')
    post :avaliacao, :id => projeto.titulo, :avaliacao => {:clareza => 10, :objetividade => 9, :correcao => 8, :detalhamento => 7, :dominio => 6, :resultados => 5, :organizacao => 4, :material_apoio => 3, :transmissao_assunto => 3 }

    aluno = loga_usuario(usuarios(:aluno1).usuario,'1234')
    get :ver_avaliacao, :id => projeto.titulo
    nota1 = (10+9+8+7+6+5+4+3+3)/90.0; "%.1f" % nota1
    assert_response :success
    assert_equal assigns(:nota), "%.1f" % nota1

    professor = loga_usuario(prof.usuario,'1234')
    post :avaliacao, :id => projeto.titulo, :avaliacao => {:clareza => 8, :objetividade => 7, :correcao => 8, :detalhamento => 7, :dominio => 6, :resultados => 5, :organizacao => 4, :material_apoio => 2, :transmissao_assunto => 2, :versao_corrigida => true }
    nota2 = (8+7+8+7+6+5+4+2+2)/90.0

    aluno = loga_usuario(usuarios(:aluno1).usuario,'1234')
    get :ver_avaliacao, :id => projeto.titulo
    assert_response :success
    media = (nota1 + nota2)/2.0 
    assert_equal assigns(:nota), "%.1f" % media
  end
end
