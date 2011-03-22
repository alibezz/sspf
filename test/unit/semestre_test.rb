require File.dirname(__FILE__) + '/../test_helper'

class SemestreTest < ActiveSupport::TestCase
## caso 1.4
  def test_cria_semestre
    n = Semestre.count
    sem = novo_semestre('2008.1')
    assert_equal n+1, Semestre.count
  end

  def test_nao_cria_semestre_sem_nome
    n = Semestre.count
    Semestre.create(:nome => nil)
    assert_equal n, Semestre.count
  end

  def test_somente_um_semestre_com_mesmo_nome 
    Semestre.create(:nome => '2008.1')
    n = Semestre.count
    Semestre.create(:nome => '2008.1')
    assert_equal n, Semestre.count
  end

  def test_somente_um_semestre
    sem1 = Semestre.create!(:nome => '2008.1', :coordenador => novo_professor('coordenador'), :eh_corrente => true, :prazo_final => Date.today, :prazo_registro => Date.today - 2.days); sem1.save!
    sem2 = Semestre.create(:nome => '2008.2', :coordenador => novo_professor('teste'), :eh_corrente => true, :prazo_final => Date.today + 2.days, :prazo_registro => Date.today - 3.days)
    sem2.eh_corrente = true
    assert !sem2.save
  end

  def test_pode_ter_dois_semestre_nao_correntes
     sem1 = Semestre.create!(:nome => '2008.1', :coordenador => novo_professor('coordenador'), :eh_corrente => false, :prazo_final => Date.today, :prazo_registro => Date.today - 2.days); sem1.save
    sem2 = Semestre.create!(:nome => '2008.2', :coordenador => novo_professor('coordenador2'), :eh_corrente => false, :prazo_final => Date.today + 2.days, :prazo_registro => Date.today - 2.days)
    sem2.eh_corrente = false
    assert sem2.save
  end

  def test_semestre_corrente_deve_existir
    semestre_corrente = novo_semestre('2008.1')
    semestre_corrente.eh_corrente = true
    semestre_corrente.save
    semestre_corrente2 = Semestre.find_by_eh_corrente(true)
    assert_not_equal semestre_corrente2, nil
  end

  def test_nao_aceita_prazo_final_invalido
    semestre = novo_semestre('2008.1')
    semestre.attributes = {"prazo_final(1i)"=>"2008", "prazo_final(2i)"=>"2", "prazo_final(3i)"=>"31"}
    assert ! semestre.valid?
  end

  def test_prazo_registro_tem_que_ser_antes_do_prazo_final
    count = Semestre.count
    sem2 = Semestre.create(:nome => '2008.2', :coordenador => novo_professor('coordenador2'), :eh_corrente => false, :prazo_final => Date.today, :prazo_registro => Date.today)

    assert_equal Semestre.count, count
  end

  def test_finaliza_semestre_cria_outro_semestre_corrente
    semestre = novo_semestre('2008.2')
    Semestre.finaliza(novo_professor('Teste')); semestre.reload
    assert_equal Semestre.corrente.nome, Semestre.proximo(semestre.nome)
  end   

end
