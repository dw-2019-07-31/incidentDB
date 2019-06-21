require 'test_helper'

class IncidentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @incident = incidents(:one)
  end

  test "should get index" do
    get incidents_url
    assert_response :success
  end

  test "should get new" do
    get new_incident_url
    assert_response :success
  end

  test "should create incident" do
    assert_difference('Incident.count') do
      post incidents_url, params: { incident: { close_date: @incident.close_date, group: @incident.group, hostname: @incident.hostname, operator: @incident.operator, os: @incident.os, product: @incident.product, reception_date: @incident.reception_date, remarks: @incident.remarks, solution: @incident.solution, status: @incident.status, story: @incident.story, subject: @incident.subject, type: @incident.type, username: @incident.username } }
    end

    assert_redirected_to incident_url(Incident.last)
  end

  test "should show incident" do
    get incident_url(@incident)
    assert_response :success
  end

  test "should get edit" do
    get edit_incident_url(@incident)
    assert_response :success
  end

  test "should update incident" do
    patch incident_url(@incident), params: { incident: { close_date: @incident.close_date, group: @incident.group, hostname: @incident.hostname, operator: @incident.operator, os: @incident.os, product: @incident.product, reception_date: @incident.reception_date, remarks: @incident.remarks, solution: @incident.solution, status: @incident.status, story: @incident.story, subject: @incident.subject, type: @incident.type, username: @incident.username } }
    assert_redirected_to incident_url(@incident)
  end

  test "should destroy incident" do
    assert_difference('Incident.count', -1) do
      delete incident_url(@incident)
    end

    assert_redirected_to incidents_url
  end
end
