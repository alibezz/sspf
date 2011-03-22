require File.dirname(__FILE__) + '/../test_helper'

class AvaliacaoTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_cria_avaliacao_de_professor_para_banca
    professor = novo_professor('prof1')
    projeto = novo_projeto('Projeto 1',professor)
    banca = projeto.create_banca

    banca.professors << professor
    avaliacao = banca.avaliacaos.create(:clareza => 3, :objetividade => 4, :correcao => 5, :detalhamento => 5, :dominio => 6, :resultados => 5, :organizacao => 6, :material_apoio => 3, :transmissao_assunto => 5)
    avaliacao.professor = professor
    avaliacao.save!
    banca.save!

    assert banca
    assert avaliacao
    assert_equal banca.avaliacaos, [avaliacao]
    assert avaliacao.professor_id
    assert_equal banca.professors, [professor]
  end

  def test_cria_avaliacao
    count = Avaliacao.count
    professor = novo_professor('prof1')
    projeto = novo_projeto('Projeto 1',professor)
    banca = projeto.build_banca
    banca.professors << projeto.orientador
    banca.save!

    avaliacao = Avaliacao.create(:clareza => 3, :objetividade => 4, :correcao => 5, :detalhamento => 5, :dominio => 6, :resultados => 5, :organizacao => 6, :material_apoio => 3, :transmissao_assunto => 5, :professor_id => professor.id, :banca_id => banca.id )
    assert_equal count + 1, Avaliacao.count
  end

  def test_nao_cria_avaliacao_sem_professor
    count = Avaliacao.count
    professor = novo_professor('prof1')
    projeto = novo_projeto('Projeto 1',professor)
    banca = projeto.create_banca
    banca.professors << professor
    banca.save!

    avaliacao = Avaliacao.create(:clareza => 3, :objetividade => 4, :correcao => 5, :detalhamento => 5, :dominio => 6, :resultados => 5, :organizacao => 6, :material_apoio => 3, :transmissao_assunto => 5, :banca_id => banca.id )
    assert_equal count, Avaliacao.count
  end

  def test_nao_cria_sem_banca
    count = Avaliacao.count
    professor = novo_professor('prof1')
    projeto = novo_projeto('Projeto 1',professor)
    banca = projeto.create_banca
    banca.professors << professor
    banca.save!

    avaliacao = Avaliacao.create(:clareza => 3, :objetividade => 4, :correcao => 5, :detalhamento => 5, :dominio => 6, :resultados => 5, :organizacao => 6, :material_apoio => 3, :transmissao_assunto => 5, :professor_id => professor.id )
    assert_equal count, Avaliacao.count
  end


  def test_nao_cria_sem_todas_as_notas
    count = Avaliacao.count
    professor = novo_professor('prof1')
    projeto = novo_projeto('Projeto 1',professor)
    banca = projeto.create_banca
    banca.professors << professor
    banca.save!

    avaliacao = Avaliacao.create(:banca_id => banca.id, :professor_id => professor.id )
    assert_equal count, Avaliacao.count
  end

  def test_nao_salva_sem_uma_nota
    count = Avaliacao.count
    professor = novo_professor('prof1')
    projeto = novo_projeto('Projeto 1',professor)
    banca = projeto.build_banca
    banca.professors << projeto.orientador
    banca.save!

    avaliacao = Avaliacao.create(:objetividade => 4, :correcao => 5, :detalhamento => 5, :dominio => 6, :resultados => 5, :organizacao => 6, :material_apoio => 3, :transmissao_assunto => 5, :professor_id => professor.id, :banca_id => banca.id ) # falta clareza
    assert_equal count, Avaliacao.count

    avaliacao = Avaliacao.create(:professor_id => professor.id )
    assert_equal count, Avaliacao.count
  end

  def test_notas_entre_0_e_10
    count = Avaliacao.count
    professor = novo_professor('prof1')
    projeto = novo_projeto('Projeto 1',professor)
    banca = projeto.build_banca
    banca.professors << projeto.orientador
    banca.save!

    avaliacao = Avaliacao.create(:clareza => -1,:objetividade => 4, :correcao => 5, :detalhamento => 5, :dominio => 6, :resultados => 5, :organizacao => 6, :material_apoio => 3, :transmissao_assunto => 5, :professor_id => professor.id, :banca_id => banca.id )
    avaliacao = Avaliacao.create(:clareza => 101,:objetividade => 4, :correcao => 5, :detalhamento => 5, :dominio => 6, :resultados => 5, :organizacao => 6, :material_apoio => 3, :transmissao_assunto => 5, :professor_id => professor.id, :banca_id => banca.id )
    assert_equal count, Avaliacao.count
  end
end
