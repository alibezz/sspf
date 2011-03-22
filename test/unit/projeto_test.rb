require File.dirname(__FILE__) + '/../test_helper'

class ProjetoTest < ActiveSupport::TestCase

  def test_tem_que_ter_ao_menos_um_topico  
    aluno = novo_aluno('aluno1','200510345')
    count = Projeto.count
    Projeto.create(:titulo => 'bla', :orientador => novo_professor('bla'), :aluno => aluno)
    assert_equal count, Projeto.count
  end

  def test_deve_pertecer_a_semestre
    projeto = novo_projeto('teste')
    projeto.semestre = nil
    assert ! projeto.save
  end

  def test_projeto_deve_conter_aluno_e_orientador
    count = Projeto.count
    Projeto.create(:titulo => 'bla', :orientador => nil, :aluno => nil)
    assert_equal count, Projeto.count
  end

  def test_nao_podem_haver_projetos_com_o_mesmo_nome
    sem = novo_semestre('2008.1')
    aluno = novo_aluno('aluno2','200410232')
    topico = Topico.create!(:nome => 't1')
    count = Projeto.count
    proj1 = novo_projeto('bla')
    proj2 = Projeto.create(:titulo => 'bla', :aluno => aluno, :orientador => novo_professor('teste2'), :semestre => sem)
    assert_equal count + 1, Projeto.count
  end

  def test_aluno_nao_pode_ter_dois_projetos
    aluno = novo_aluno('aluno','200410232')
    sem = novo_semestre('2008.1')
    topico = Topico.create!(:nome => 't1')
    count = Projeto.count
    proj1 = novo_projeto('bla', novo_professor('teste2'), sem, aluno)

    proj2 = Projeto.new(:titulo => 'bla2', :aluno => aluno, :orientador => novo_professor('teste1'), :semestre => sem, :topico_ids => [topico.id])
    proj2.arquivo_anteprojeto = fixture_file_upload("anteprojeto.pdf",'content/pdf',:binary)
    proj2.save

    assert_equal count + 1, Projeto.count
  end
end
