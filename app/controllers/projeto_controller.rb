class ProjetoController < ApplicationController
# Garante acesso ao edita, registra somente para Alunos ou o Coordenador logados
before_filter :aluno_logado, :only => [:index,:registra,:edita, :ver_avaliacao, :banca]
# Garante que o projeto cujo titulo eh passado, existe
before_filter :garante_projeto, :except => [:index, :registra, :erro]

# Garante que o semestre do projeto eh o corrente
before_filter :garante_projeto_corrente, :only => [:edita, :edita_banca, :avaliacao]

# Garantem prazos, presença de um projeto final, professores cadastrados, etc
before_filter :carrega_arquivo, :only => [:anteprojeto, :projeto_final] 
before_filter :garante_prazo_registro, :only => [:registra]
before_filter :garante_prazo_final, :only => [:edita]

# Actions publicas
  def visualiza
  end

  def anteprojeto
      send_data @arquivo.data_anteprojeto, :filename => @arquivo.anteprojeto, :type => @arquivo.type_anteprojeto
  end

  def projeto_final
      send_data @arquivo.data_projeto_final, :filename => @arquivo.projeto_final, :type => @arquivo.type_projeto_final
  end

  def erro
  end

# Actions de usuario logado
  def index
    @projeto = Projeto.find_by_aluno_id(@usuario.id)
    if @projeto.nil?
      flash[:notice] = "A data final de submissão do projeto final é " + Semestre.data(@semestre_corrente.prazo_registro)
      render :action => 'sem_projeto'
    else
      render :action => 'com_projeto'
    end
  end
 
  def registra
    @orientadores = Professor.find_all_by_orientador(true)
    @topicos = Topico.find :all

    if @topicos.empty? or @orientadores.empty?
      redirect_to :action => 'erro'
    end  

    @projeto = Projeto.find_by_aluno_id(@usuario.id)
    redirect_to :action => 'index' unless @projeto.nil?
    @projeto = Projeto.new params[:projeto]
    if request.post?
      @projeto.orientador = Professor.find(params[:orientador])
      @projeto.aluno = @usuario
      @projeto.semestre = Semestre.corrente

      if params[:arquivo_anteprojeto] and params[:arquivo_anteprojeto] != ""
        @projeto.arquivo_anteprojeto = params[:arquivo_anteprojeto]
      end

      if @projeto.save
        flash[:notice] = "Projeto registrado com sucesso!"
        redirect_to :action => 'index'
      end
    end
  end  
  
  def edita
    acesso_negado unless @usuario.id == @projeto.aluno_id or coordenador?
    @topicos = Topico.find :all
    if request.post?
       @projeto.attributes = params[:projeto]
       if params[:arquivo_projeto_final] and params[:arquivo_projeto_final] != ""
         @projeto.arquivo_projeto_final = params[:arquivo_projeto_final]
         if @projeto.type_projeto_final and not @projeto.type_projeto_final.include?('pdf')
           flash[:notice] = "O formato do projeto final deve ser PDF."
         end
       end
       
       if @projeto.save
         redirect_to :action => 'visualiza', :id => @projeto.titulo
       end
     end
  end

  def banca
    if @projeto.banca.nil?
      flash[:notice] = "Banca avaliadora não formada até o momento"
      redirect_to :action => 'index'
    else
      @professores = @projeto.banca.professors
    end
  end

  def ver_avaliacao
    if @projeto.banca.nil?
      flash[:notice] = "Banca avaliadora não formada até o momento"
      redirect_to :action => 'index'
    else
      @avaliacoes = @projeto.avaliacaos
      if @avaliacoes.empty?
        flash[:notice] = "Nenhuma avaliação realizada até o momento"
        redirect_to :action => 'index'
      else
				#Isso aqui pode mudar, se eu guardo primeira e segunda versao. Mas isso simplifica checagens logicas.
        @nota = 0
        @avaliacoes.each { |a| @nota += Avaliacao.calcula_nota(a) }
        @nota = (@nota/@avaliacoes.size).to_f; @nota = "%.1f" % @nota
      end
    end
  end

# Action para coordenador
  def edita_banca
    acesso_negado unless coordenador?
    @professores = Professor.find :all, :conditions => {:avaliador => true}
    @sugeridos = [@projeto.orientador] + Banca.sugere_banca(@projeto, @professores - [@projeto.orientador])

    if @projeto.banca.nil?
      # Cria sugestoes para nova banca
      @banca = Banca.new
      if @sugeridos.length >= 2
        @banca.professor_ids = [@sugeridos[0], @sugeridos[1],@sugeridos[2]]
      end	
    else
      # Editando a banca
      @banca = @projeto.banca
    end

    if request.post? 
      @banca.projeto_id = @projeto.id
      @banca.professor_ids = params[:banca][:professor_ids]
      if @banca.save
        @projeto.banca = @banca
        if @projeto.save
          redirect_to :action => 'bancas', :controller => 'coordenador'
	     end
      end	
    end 
  end

# Action para professores
  def avaliacao
    @banca = @projeto.banca
    if @banca.nil?
      flash[:warning] = "Projeto " + @projeto.titulo + " ainda não possui banca formada."
      redirect_to :controller => 'professor', :action => 'index'
      return
    end

    if @banca.professors.grep(@usuario).empty? or @usuario.nil?
      acesso_negado
      return
    end

    @avaliacao = Avaliacao.find(:first, :conditions => { :projeto_id => @projeto.id, :professor_id => @usuario.id})
    if @avaliacao.nil?
      @avaliacao = @banca.avaliacaos.build params[:avaliacao]
      @avaliacao.professor_id = @usuario.id
      @avaliacao.projeto_id = @projeto.id
    else
      @nota = Avaliacao.calcula_nota(@avaliacao); @nota = "%.1f" % @nota
    end
		
    if request.post?
      @avaliacao.attributes = params[:avaliacao]
      @nota = Avaliacao.calcula_nota(@avaliacao); @nota = "%.1f" % @nota
			if not @avaliacao.primeira_versao
				@avaliacao.primeira_nota = @nota
				@avaliacao.primeira_versao = true
			else
				@avaliacao.segunda_nota = @nota
			end	
      if @avaliacao.save
  	    if @projeto.save
          render :action => 'avaliacao'
        end
      end	
    end 
  end

private
  def carrega_arquivo
    @arquivo = Projeto.find_by_titulo(params[:id])
    render :file => File.join(RAILS_ROOT,'public', '404.html'), :status => 404 unless @arquivo
  end


  def garante_projeto_corrente
    acesso_negado unless Semestre.corrente == @projeto.semestre
  end

  def garante_prazo_final
    if Semestre.corrente.prazo_final.nil? or Date.today > Semestre.corrente.prazo_final
       redirect_to :action => 'erro'
    end
  end  

  def garante_prazo_registro
    if Semestre.corrente.prazo_registro.nil? or Semestre.corrente.prazo_registro < Date.today
      redirect_to :action => 'erro'
    end
  end 

  # edicao exclusiva pelo aluno
  def aluno_logado
    if @usuario
      acesso_negado unless @usuario.class == Aluno
    else
      autenticacao_requerida
    end
  end

  def garante_projeto
    @projeto = Projeto.find_by_titulo(params[:id])
    if @projeto.nil?
      render :file => File.join(RAILS_ROOT,'public', '404.html'), :status => 404
    end
  end    
end
