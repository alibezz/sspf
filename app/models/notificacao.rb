class Notificacao < ActionMailer::Base

  def envia_senha(user)
    @subject    =  'Sua nova senha do SSPF'
    @recipients =  "#{user.email}"
    @from       =  'cason@dcc.ufba.br'
#    @sent_on    =  Time.now
    @body[:nova_senha] =  "#{user.senha}"
    @body[:nome] = "#{user.nome}"
  end
end
