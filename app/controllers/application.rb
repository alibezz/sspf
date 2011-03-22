# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '5b450167b6348057c98173cdf1dd8c59'

  before_filter :inicializa_semestre_corrente
  before_filter :usuario_ativo
  before_filter :salva_retorno

protected

  def inicializa_semestre_corrente
    if Semestre.corrente.nil?
      if !request.request_uri.match(/^\/setup/)
        redirect_to :controller => 'setup', :action => 'index'
      end
      return
    end
    @semestre_corrente ||= Semestre.corrente 
  end

  def salva_retorno
    @retorno = session[:retorno]
    session[:retorno] = request.request_uri
  end


  def usuario_ativo
    @usuario = session[:id]
  end

  def coordenador?
    if Semestre.corrente
      usuario_ativo and @usuario.id == Semestre.corrente.coordenador_id
    else
      usuario_ativo and @usuario == Usuario.find_by_usuario('admin') 
    end
  end

  def aluno?
    session[:id] and session[:id].class == Aluno
  end

  def professor?
    session[:id] and session[:id].class == Professor
  end

  def usuario_coordenador
    if usuario_ativo.nil?
      autenticacao_requerida
    else
      coordenador? || acesso_negado
    end
  end

  def autenticacao_requerida
    flash[:warning] = "Você precisa se autenticar para realizar esta ação"
    if @retorno
      redirect_to(@retorno)
    else
      redirect_to('/')
    end
  end

  def acesso_negado
    flash[:warning] = "Você não tem permissão para realizar esta ação"
    if @retorno and @retorno != session[:retorno]
      redirect_to(@retorno)
    else
      redirect_to('/')
    end
  end
end
