module SearchableProjects
  module ProjectsControllerPatch
    def self.included(base)
      base.class_eval do
        def index_with_searchable_projects
          if request.format == :html
            @limit = per_page_option

            retrieve_query(ProjectQuery)
            sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
            sort_update(@query.sortable_columns)

            @projects_count = @query.projects_count
            @project_pages = ActionController::Pagination::Paginator.new self, @projects_count, @limit, params['page']
            @offset ||= @project_pages.current.offset

            @projects = @query.projects(:order => sort_clause, :offset => @offset, :limit => @limit)

          else
            index_without_searchable_projects
          end

        end
        alias_method_chain :index, :searchable_projects
      end
    end
  end
end