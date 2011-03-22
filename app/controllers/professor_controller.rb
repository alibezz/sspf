class ProfessorController < ApplicationController

before_filter :professor_logado
layout "application", :except => :gera_folha
 
  def index
    @professor = Professor.find(@usuario.id)
  end

  def edita
    if (params[:id])
      @professor = Professor.find(params[:id])
      render :file => File.join(RAILS_ROOT,'public', '404.html'), :status => 404 unless @professor
    else
      render :file => File.join(RAILS_ROOT,'public', '404.html'), :status => 404
      return
    end
    acesso_negado unless @professor.id == @usuario.id or coordenador?
    @topicos = Topico.find :all
    if request.post? 
      @professor.attributes = params[:professor]
      if @professor.save
        if @usuario.id == Semestre.corrente.coordenador_id and @usuario.id != @professor.id
          redirect_to :controller => 'coordenador', :action => 'professores'
        else
          redirect_to :action => 'index'
        end
      end
    end
  end

  def projetos_orientados
    @projetos = Projeto.find(:all).select {|p| p.orientador_id == @usuario.id}
    if @projetos.empty?
      flash[:notice] = "Você não está orientando nenhum projeto atualmente"
    end
  end
  
  def bancas
    @projetos = Projeto.find(:all).select {|p| p.semestre == Semestre.corrente && !p.banca.nil? && !p.banca.professors.grep(@usuario).empty?}
    if @projetos.empty?
      flash[:notice] = "Você não está associado a nenhuma banca neste semestre."
    end
  end

  def gera_folha
    if (params[:id])
      @projeto = Projeto.find_by_titulo(params[:id])
      render :file => File.join(RAILS_ROOT,'public', '404.html'), :status => 404 unless @projeto
    else
      render :file => File.join(RAILS_ROOT,'public', '404.html'), :status => 404
      return
    end
		if @projeto.banca and @projeto.avaliacaos and @projeto.banca.professors and @projeto.avaliacaos.length == @projeto.banca.professors.length 
			@avaliacoes = @projeto.avaliacaos
			@media1 = (@avaliacoes[0].primeira_nota + @avaliacoes[1].primeira_nota + @avaliacoes[2].primeira_nota)/3.to_f; @media1 = "%.1f" % @media1
			@nota1 = define_nota_exibida(@nota1, @avaliacoes[0])
			@nota2 = define_nota_exibida(@nota2, @avaliacoes[1])
			@nota3 = define_nota_exibida(@nota3, @avaliacoes[2])
			@media2 = (@nota1 + @nota2 + @nota3)/3.to_f; @media2 = "%.1f" % @media2
		else
			redirect_to :action => 'projetos_orientados'
		end
	end

private
  def professor_logado
    if @usuario
      acesso_negado unless @usuario.class == Professor
    else
      autenticacao_requerida
    end
  end

  def define_nota_exibida(nota, avaliacao)
		if (avaliacao.segunda_nota.nil?)
			nota = avaliacao.primeira_nota
		else
			nota = avaliacao.segunda_nota
		end
		nota
  end
end
