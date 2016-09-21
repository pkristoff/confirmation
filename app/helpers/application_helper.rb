module ApplicationHelper
  def sortable(column, title, confirmation_event_id='')
    title ||= column.titleize
    css_class = column == sort_column(params[:sort]) ? "current #{sort_direction(params[:direction]) == 'asc' ? 'glyphicon glyphicon-arrow-up' : 'glyphicon glyphicon-arrow-down'}" : nil
    direction = column == sort_column(params[:sort]) && sort_direction(params[:direction]) == 'asc' ? 'desc' : 'asc'
    link_to title, {sort: column, direction: direction, class: css_class, update: {confirmation_event_id => ''}}, method: :post
  end
  def sortable_candidates(column, title)
    title ||= column.titleize
    css_class = column == sort_column(params[:sort]) ? "current #{sort_direction(params[:direction]) == 'asc' ? 'glyphicon glyphicon-arrow-up' : 'glyphicon glyphicon-arrow-down'}" : nil
    direction = column == sort_column(params[:sort]) && sort_direction(params[:direction]) == 'asc' ? 'desc' : 'asc'
    link_to title, candidates_path(sort: column, direction: direction, class: css_class), method: :get
  end
end
