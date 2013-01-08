require File.expand_path('../../test_helper', __FILE__)

class ProjectsControllerTest < ActionController::TestCase
  fixtures :projects

  def test_index_success
    get :index

    assert_response :success
  end

  def test_project_list_rendered
    get :index

    assert_template :partial => '_projects_list'
  end

  def test_query_rendered
    get :index

    assert_template :partial => '_query'
  end
end