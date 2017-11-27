require 'test_helper'

class Admin::TipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_tip = admin_tips(:one)
  end

  test "should get index" do
    get admin_tips_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_tip_url
    assert_response :success
  end

  test "should create admin_tip" do
    assert_difference('Admin::Tip.count') do
      post admin_tips_url, params: { admin_tip: {  } }
    end

    assert_redirected_to admin_tip_url(Admin::Tip.last)
  end

  test "should show admin_tip" do
    get admin_tip_url(@admin_tip)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_tip_url(@admin_tip)
    assert_response :success
  end

  test "should update admin_tip" do
    patch admin_tip_url(@admin_tip), params: { admin_tip: {  } }
    assert_redirected_to admin_tip_url(@admin_tip)
  end

  test "should destroy admin_tip" do
    assert_difference('Admin::Tip.count', -1) do
      delete admin_tip_url(@admin_tip)
    end

    assert_redirected_to admin_tips_url
  end
end
