require 'projects_controller_patch'
require 'queries_helper_patch'

Redmine::Plugin.register :serchable_projects do
  name 'Searchable Projects'
  author 'Anton Petrunich'
  description 'Replace default projects index page with searchable table view'
  version '0.0.1'

  settings :default => {:columns => ['name', 'short_description', 'is_public', 'identifier', 'start_date', 'due_date']}
  Rails.configuration.to_prepare do
    ProjectsController.send(:include, SearchableProjects::ProjectsControllerPatch)
    QueriesHelper.send(:include, SearchableProjects::QueriesHelperPatch)
  end
end