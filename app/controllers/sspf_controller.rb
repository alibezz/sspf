class SspfController < ApplicationController

  def index
  end

  def projetos	 
    @semestres = Semestre.find(:all)
    if (params[:semestre])
      @semestre = Semestre.find_by_nome(params[:semestre])
    else
      @semestre = @semestre_corrente
    end
    @projetos = Projeto.find(:all, :conditions => ['titulo LIKE ? AND semestre_id = ?',"%#{params[:titulo]}%", @semestre.id])
  end

  def professores
    @professores = Professor.find(:all, :conditions => ['nome LIKE ?',"%#{ params[:nome]}%"])
  end  

  def alunos
    @orientadores = Professor.find(:all).select {|p| p.orientador}
    @topicos = Topico.find :all
    @semestre_corrente = Semestre.find_by_eh_corrente(true)
    #TODO before_filter abaixo
    if (@orientadores.empty? or @topicos.empty? or @semestre_corrente.nil?)
      redirect_to :action => 'erro', :controller => 'projeto'
    end
  end

  def login
    if request.post?
      if session[:id] = Usuario.autentica(params[:usuario][:usuario],params[:usuario][:senha])
        if session[:id].class == Aluno
          redirect_to :controller => 'projeto', :action => 'index'
        elsif session[:id].class == Professor
          redirect_to :controller => 'professor', :action => 'index'
	     else
          redirect_to :controller => 'sspf', :action => 'index'
        end 
      else
        flash[:warning] = "Usuário e senha inválidos"
        if @retorno
          redirect_to(@retorno)
        else
          redirect_to :controller => 'sspf', :action => 'index'
        end
      end
    end
  end

  def logout
    if (session[:id])
      flash[:notice] = "Usuário '" + session[:id].usuario + "' deslogado"
      @usuario = session[:id] = nil
    end
    redirect_to :controller => 'sspf', :action => 'index'
  end

  def muda_senha
    @user = Usuario.find_by_usuario(params[:id])
    if @user.nil? or @usuario.nil? or @user.id != @usuario.id
      render :file => File.join(RAILS_ROOT,'public', '404.html'), :status => 404 unless coordenador?
    end

    @usuario = @user

    if request.post?
      if params.has_key?(:senha_antiga) and Usuario.autentica(params[:id],params[:senha_antiga])
        if @usuario.update_attributes(params[:usuario])
          flash[:notice] = "Senha atualizada com sucesso."
          redirect_to :controller => 'sspf', :action => 'index'
        end
      else
        flash[:warning] = "Usuário e senha inválidos"
      end
    else
    end
  end
end
