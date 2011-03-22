require File.dirname(__FILE__) + '/../test_helper'

class TopicoTest < ActiveSupport::TestCase

  def test_unicidade_de_topico
    count = Topico.count
    topico1 = Topico.create(:nome => 't2')
    topico2 = Topico.create(:nome => 't2')
    assert_equal count + 1, Topico.count
  end


end
