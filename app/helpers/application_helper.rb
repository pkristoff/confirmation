module ApplicationHelper
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column(params[:sort]) ? "current #{sort_direction(params[:direction]) == 'asc' ? 'glyphicon glyphicon-arrow-up' : 'glyphicon glyphicon-arrow-down'}" : nil
    direction = column == sort_column(params[:sort]) && sort_direction(params[:direction]) == 'asc' ? 'desc' : 'asc'
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end
end
