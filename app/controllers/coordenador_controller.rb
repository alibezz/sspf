class CoordenadorController < ApplicationController

before_filter :garante_professores, :only => [:cadastra_semestre]
before_filter :garante_professor_habilitado, :only => [:desabilita_professor]
before_filter :usuario_coordenador

  def index
    @professores = Professor.find :all
    @topicos = Topico.find :all
    @semestres = Semestre.find :all
  end

  def professores
    @professores = Professor.find(:all, :conditions => ['nome LIKE ?',"%#{ params[:nome]}%"]) - [@semestre_corrente.coordenador]
  end

  def alunos
    @alunos = Aluno.find(:all, :conditions => ['nome LIKE ?',"%#{ params[:nome]}%"])
  end

  def semestres
    @professores = Professor.find :all
    @semestre = Semestre.corrente
    if request.post? 
      @semestre.attributes = params[:semestre]
      @coordenador = Usuario.find(params[:coordenador_id]) if params[:coordenador_id]
      if @coordenador and @semestre.coordenador_id != @coordenador.id and  @coordenador.class == Professor
        @semestre.coordenador_id = @coordenador.id
        if @semestre.save
          flash[:notice] = "O novo coordenador do semestre é <b>" + @coordenador.nome + "</b>"
          redirect_to :action => 'index', :controller => 'sspf'
        end
      elsif @semestre.save
        flash[:notice] = 'Semestre <b>' + @semestre.nome + '</b> atualizado com sucesso.<br>Prazo de registro: <b>' + Semestre.data(@semestre.prazo_registro) + '</b><br>Prazo final: <b>' + Semestre.data(@semestre.prazo_final) + '</b>'
        redirect_to :action => 'index'
      end
    end
  end

  def finaliza_semestre
    @professores = Professor.find :all
    @semestre = Semestre.corrente
    if request.post?
      @coordenador = Professor.find(params[:coordenador])
      @semestre = Semestre.corrente
      if Semestre.finaliza(@coordenador)
        flash[:notice] = 'Semestre <b>' + @semestre.nome + "</b> finalizado.<br> Semestre <b>" + Semestre.corrente.nome + '</b> aberto.'
        redirect_to :action => 'index', :controller => 'coordenador'
      end	
    end
  end


#TODO: Isto não existe mais no modelo.
# View: semestre
# botão: prazo final, chama prazo_final
# botão: finalizar, cria novo
#  def cadastra_semestre
#    @semestre_corrente = Semestre.find_by_eh_corrente(true)
#    if @semestre_corrente
#      flash[:notice] = 'O semestre "' + @semestre_corrente.nome + '" já está cadastrado.'
#      redirect_to :action => 'index', :controller => 'coordenador'
#    else
#      @semestre = Semestre.new params[:semestre]
#      if request.post? 
#        flash[:notice] = 'Semestre "' + @semestre.nome + '" cadastrado com sucesso.'
#     # TODO: isto é estático. Para o construtor?
#        @semestre.eh_corrente = true
#        if @semestre.save
#          redirect_to :action => 'index'
#        end
#      end
#    end
#  end

  def registra_professor
    @professor = Professor.new params[:professor]
    @topicos = Topico.find :all
    if request.post? 
      @professor.topico_ids = params[:topics]
      if @professor.save
        flash[:notice] = 'Professor "' + @professor.nome + '" adicionado ao sistema.'
        redirect_to :action => 'professores'
      end
    end
  end

  def registra_aluno
    @aluno = Aluno.new params[:aluno]
    if request.post?
      if @aluno.save
        flash[:notice] = 'Aluno "' + @aluno.nome + '" adicionado ao sistema.'
        redirect_to :action => 'alunos'
      end
    end
  end

  def desabilita_professor
    if request.post?
      flash[:notice] = 'Professor "' + @professor.nome + '" com e-mail ' + @professor.email + ' desabilitado.' 
      @professor.orientador = false
      @professor.avaliador = false
      if @professor.save
        redirect_to :action => 'professores'            
      end
    end
  end

  def topicos
    @topicos = Topico.find :all
    @topico = Topico.new params[:topico]
    if request.post? and  @topico.save
      flash[:notice] = 'Tópico "' + @topico.nome + '" cadastrado com sucesso'
      redirect_to :action => :index
    end
  end

  def bancas
    @projetos = Projeto.find(:all).select {|p| p.semestre == Semestre.corrente}
    if @projetos.empty?
      flash[:notice] = 'Não há projetos registrados neste semestre.'
      redirect_to :action => 'index'
    end
  end
private
  def garante_professores
    @professores = Professor.find :all
    if @professores.empty?
      flash[:notice] = "Ainda não há professores cadastrados."
      redirect_to :action => 'index', :controller => 'coordenador'
    end
  end

  def garante_professor_habilitado
    @professor = Professor.find(params[:id])
    if @professor.nil? or not (@professor.orientador or @professor.avaliador)
      render :file => File.join(RAILS_ROOT,'public', '404.html'), :status => 404
    end
  end  
end    
