# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def menu_lateral
    if @usuario
      if @usuario.class == Aluno
        @projeto = Projeto.find_by_aluno_id(@usuario.id)
        if @projeto.nil?
          link_to 'Registrar Projeto', :action => :registra, :controller => :projeto
	else
          link_to "Editar Projeto", :controller => 'projeto', :action => 'edita'
	end
      elsif @usuario.class == Professor
        @semestre = Semestre.find_by_eh_corrente(true)
	if @semestre.coordenador_id == @usuario.id
          link_to "Coordenador", :controller => 'sspf', :action => 'index'
	else
          link_to "Professor", :controller => 'sspf', :action => 'index'	  
	end
      end
    end
  end

  def menu_login
  end
end
