require File.dirname(__FILE__) + '/../test_helper'

class ProfessorTest < ActiveSupport::TestCase
  def test_professor_inicialmente_nao_tem_banca
    professor = novo_professor('prof1')
    assert professor.bancas.empty?
  end

  def test_adiciona_banca_professor
    professor = novo_professor('prof1')
    banca = novo_projeto('bla',professor).create_banca
    professor.bancas << banca

    assert !professor.bancas.empty?
  end

#  def test_faz_avaliacao_de_projeto
#    professor = novo_professor('prof1')
#    banca = professor.avaliacaos.create
#    professor.save
#
#    avaliacao = banca.avaliacaos.create
#    avaliacao.professor_id = professor.id
#    avaliacao.save
#    banca.save
#
#    assert_equal professor.bancas, [banca]
#    assert_equal Banca.find_by_
#  end
end
