require "#{File.dirname(__FILE__)}/../test_helper"

class UsuarioNaoLogadoTest < ActionController::IntegrationTest
  fixtures :usuarios, :semestres, :topicos

  # Aparece página inicial
  def test_pagina_inicial
    get 'sspf/index'
    assert_response :success
    assert_template 'index'
  end

  def test_ve_projetos_do_semestre_atual
    get 'sspf/index'
    assert_tag :tag => 'a', :attributes => { :href => '/sspf/projetos' }

    novo_projeto('Projeto1', usuarios(:professor1), semestres(:semestre_atual), usuarios(:aluno1), [topicos(:t1)])
    novo_projeto('Projeto2', usuarios(:professor1), semestres(:semestre_atual), usuarios(:aluno2), [topicos(:t1)])
    novo_projeto('ProjetoAnterior', usuarios(:professor1), novo_semestre('2009.1', usuarios(:professor1), false), usuarios(:aluno3), [topicos(:t1)])

    get 'sspf/projetos'
    assert_response :success
    assert_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/Projeto1' }
    assert_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/Projeto2' }
    assert_no_tag :tag => 'a', :attributes => { :href => '/projeto/visualiza/ProjetoAnterior' }
  end
 
  def test_ve_professores
    get 'sspf/index'
    assert_tag :tag => 'a', :attributes => { :href => '/sspf/professores' }
    prof = novo_professor('Teste')

    get 'sspf/professores'
    assert_response :success
    assert_no_tag :tag => 'a', :attributes => { :href => '/professor/visualiza/' + prof.id.to_s }
  end

  def test_nao_acessa_projeto
    get '/sspf/projetos'
    
    get 'projeto/'
    assert flash[:warning]
    assert_response :redirect

    get 'projeto/edita/'
    assert_response :redirect
    assert flash[:warning]

    proj = novo_projeto('Projeto1', usuarios(:professor1), semestres(:semestre_atual), usuarios(:aluno1), topicos=[topicos(:t1)])

    get 'projeto/edita/' + proj.titulo
    assert flash[:warning]
    assert_response :redirect

    get 'projeto/registra'
    assert flash[:warning]
    assert_response :redirect
  end

  def test_nao_acessa_coordenador
    get 'coordenador/'
    assert flash[:warning]
    assert_response :redirect

    get 'coordenador/registra_aluno'
    assert flash[:warning]
    assert_response :redirect
  end

end
