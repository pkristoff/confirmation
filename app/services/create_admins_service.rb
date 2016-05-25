class CreateAdminsService
  def call
    ConfirmationEvent.find_or_create_by!(name: 'Parent Information Meeting') do |confirmation_event|
      confirmation_event.name = 'Parent Information Meeting'
      confirmation_event.due_date = Date.today
    end
    Admin.find_or_create_by!(email: Rails.application.secrets.admin_email) do |admin|
      admin.name = Rails.application.secrets.admin_name
      admin.password = Rails.application.secrets.admin_password
      admin.password_confirmation = Rails.application.secrets.admin_password
    end
  end
end
