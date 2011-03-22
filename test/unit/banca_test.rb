require File.dirname(__FILE__) + '/../test_helper'

class BancaTest < ActiveSupport::TestCase
  def test_cria_banca_para_projeto
    projeto = novo_projeto('Projeto 1')
    count = Banca.count
    banca = projeto.create_banca
    assert_equal count+1, Banca.count
  end

  def test_cria_banca
    projeto = novo_projeto('Projeto 1')
    count = Banca.count
    banca = Banca.new
    projeto.banca = banca
    projeto.save
    banca.save

    assert_equal count+1, Banca.count
    assert_equal banca.projeto_id, projeto.id
  end

  def test_banca_soh_existe_com_projeto
    count = Banca.count
    banca = Banca.new
    banca.save
    assert_equal count, Banca.count
  end

  def test_projeto_criado_sem_banca
    projeto = novo_projeto('Projeto 1')
    assert_nil projeto.banca
  end

  def test_banca_com_professores
    orient = novo_professor('prof1')
    prof2 = novo_professor('prof2')
    prof3 = novo_professor('prof3')
    prof4 = novo_professor('prof4')
    projeto = novo_projeto('Projeto 1', orient)
    count = Banca.count
    projeto.create_banca
    projeto.banca.professors = [orient,prof2,prof3]

    assert_equal projeto.banca.professors,[orient, prof2, prof3]

    projeto.banca.professors << prof4
    assert_equal projeto.banca.professors,[orient, prof2, prof3,prof4]
  end

  def test_ordenacao
    
    t1 = novo_topico('SO')
    t2 = novo_topico('SD')
    t3 = novo_topico('ES')
    t4 = novo_topico('IA')
    t5 = novo_topico('BD')

    prof1 = novo_professor('pr1')
    prof1.topicos = [t1, t2, t3] # SO, SD, ES
    prof2 = novo_professor('pr2')
    prof2.topicos = [t5] # BD
    prof3 = novo_professor('pr3')
    prof3.topicos = [t1, t2, t3, t5] # SO, SD, ES, BD
    prof4 = novo_professor('pr4')
    prof4.topicos = [t5, t4, t2] # IA, BD, SD
    
    semestre = novo_semestre('2009.1')
    
    orient = novo_professor('prof1')
    aluno1 = novo_aluno('Marcia', 200610612)
    proj1 = novo_projeto('Proj1', orient, semestre, aluno1)
    proj1.create_banca
    proj1.banca.professors = [orient, prof1, prof4]
    aluno2 = novo_aluno('Ilka', 200610613)
    proj2 = novo_projeto('Proj2', orient, semestre, aluno2)
    proj2.create_banca
    proj2.banca.professors = [orient, prof2, prof1]
    aluno3 = novo_aluno('Nancy', 200610614)
    proj3 = novo_projeto('Proj3', orient, semestre, aluno3)
    proj3.create_banca
    proj3.banca.professors = [orient, prof1, prof3]
    aluno4 = novo_aluno('Janete', 200610615)
    proj4 = novo_projeto('Proj4', orient, semestre, aluno4)
    proj4.create_banca
    proj4.banca.professors = [orient, prof2, prof3]
    aluno5 = novo_aluno('Luzana', 200610616)
    proj5 = novo_projeto('Proj5', orient, semestre, aluno5)
    proj5.create_banca
    proj5.banca.professors = [orient, prof3, prof4]

    aluno = novo_aluno('Joao', 200610617)
    projeto_teste = novo_projeto('Teste', orient, semestre, aluno, [t2, t5])

    avaliadores = [prof1, prof2, prof3, prof4] 
    avaliadores = Banca.sugere_banca(projeto_teste, avaliadores)
    assert_equal [prof4, prof3, prof2, prof1], avaliadores
  end    
end
