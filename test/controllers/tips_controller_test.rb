require 'test_helper'

class TipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tip = tips(:one)
  end

  test "should get index" do
    get tips_url
    assert_response :success
  end

  test "should get new" do
    get new_tip_url
    assert_response :success
  end

  test "should create tip" do
    assert_difference('Tip.count') do
      post tips_url, params: { tip: { points: @tip.points, qual_first: @tip.qual_first, qual_second: @tip.qual_second, qual_third: @tip.qual_third, race_first: @tip.race_first, race_second: @tip.race_second, race_tenth: @tip.race_tenth, race_third: @tip.race_third } }
    end

    assert_redirected_to tip_url(Tip.last)
  end

  test "should show tip" do
    get tip_url(@tip)
    assert_response :success
  end

  test "should get edit" do
    get edit_tip_url(@tip)
    assert_response :success
  end

  test "should update tip" do
    patch tip_url(@tip), params: { tip: { points: @tip.points, qual_first: @tip.qual_first, qual_second: @tip.qual_second, qual_third: @tip.qual_third, race_first: @tip.race_first, race_second: @tip.race_second, race_tenth: @tip.race_tenth, race_third: @tip.race_third } }
    assert_redirected_to tip_url(@tip)
  end

  test "should destroy tip" do
    assert_difference('Tip.count', -1) do
      delete tip_url(@tip)
    end

    assert_redirected_to tips_url
  end
end
