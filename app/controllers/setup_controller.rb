class SetupController < ApplicationController
  layout 'setup'
  
  def index
    if Semestre.corrente
      render :file => File.join(RAILS_ROOT,'public', '404.html'), :status => 404
      return
    end
    
    @professor = Professor.new params[:professor]
    @topico = Topico.create(:nome => 'Ciencia da Computação')

    if request.post?
      if @professor.save
        @semestre = Semestre.new params[:semestre]
        @semestre.coordenador_id = @professor.id
        @semestre.eh_corrente = true
        if @semestre.save
          session[:id] = @professor
          flash[:notice] = "Semestre <b>" + @semestre.nome + "</b> cadastrado com sucesso.<br>O seu coordenador é o usuário <b>" + @professor.usuario + "</b>."
          redirect_to :controller => 'sspf', :action => 'index'
        else
          Professor.destroy_all
	     end
      end
    end
  end
end
