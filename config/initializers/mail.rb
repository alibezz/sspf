  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :address => "mail.dcc.ufba.br",
    :port => 25,
    :domain => "dcc.ufba.br",
    :user_name => "cason",
    :password => "testesspf",
    :authentication => :login
  }

