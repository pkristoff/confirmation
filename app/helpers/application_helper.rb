module ApplicationHelper
  # TODO: merge with sortable_candidates
  def sortable(column, title, route, confirmation_event_id='')
    title ||= column.titleize
    css_class = column == sort_column(params[:sort]) ? "current #{sort_direction(params[:direction]) == 'asc' ? 'glyphicon glyphicon-arrow-up' : 'glyphicon glyphicon-arrow-down'}" : nil
    direction = column == sort_column(params[:sort]) && sort_direction(params[:direction]) == 'asc' ? 'desc' : 'asc'
    path = 'unknown path'
    path = monthly_mass_mailing_path(sort: column, direction: direction, class: css_class, update: {confirmation_event_id => ''}) if route === :monthly_mass_mailing
    path = mass_edit_candidates_event_path(id: confirmation_event_id, sort: column, direction: direction, class: css_class, update: {confirmation_event_id => ''}) if route === :mass_edit_candidates_event
    link_to title, path, method: :get
  end
  # TODO: merge with sortable
  def sortable_candidates(column, title )
    title ||= column.titleize
    css_class = column == sort_column(params[:sort]) ? "current #{sort_direction(params[:direction]) == 'asc' ? 'glyphicon glyphicon-arrow-up' : 'glyphicon glyphicon-arrow-down'}" : nil
    direction = column == sort_column(params[:sort]) && sort_direction(params[:direction]) == 'asc' ? 'desc' : 'asc'
    link_to title, candidates_path(sort: column, direction: direction, class: css_class), method: :get
  end

  # private - test only
  def sort_column(sort_column)
    columns = CandidateSheet.get_permitted_params.map { |attr| "candidate_sheet.#{attr}" }
    columns << 'account_name'
    columns << 'completed_date'
    columns.include?(sort_column) ? sort_column : 'account_name'
  end

  def sort_direction(direction)
    %w[asc desc].include?(direction) ? direction : 'asc'
  end
end
