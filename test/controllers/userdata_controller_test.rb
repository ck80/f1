require 'test_helper'

class UserdataControllerTest < ActionDispatch::IntegrationTest
  setup do
    @userdatum = userdata(:one)
  end

  test "should get index" do
    get userdata_url
    assert_response :success
  end

  test "should get new" do
    get new_userdatum_url
    assert_response :success
  end

  test "should create userdatum" do
    assert_difference('Userdatum.count') do
      post userdata_url, params: { userdatum: {  } }
    end

    assert_redirected_to userdatum_url(Userdatum.last)
  end

  test "should show userdatum" do
    get userdatum_url(@userdatum)
    assert_response :success
  end

  test "should get edit" do
    get edit_userdatum_url(@userdatum)
    assert_response :success
  end

  test "should update userdatum" do
    patch userdatum_url(@userdatum), params: { userdatum: {  } }
    assert_redirected_to userdatum_url(@userdatum)
  end

  test "should destroy userdatum" do
    assert_difference('Userdatum.count', -1) do
      delete userdatum_url(@userdatum)
    end

    assert_redirected_to userdata_url
  end
end
