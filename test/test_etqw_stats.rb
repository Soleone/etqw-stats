require File.dirname(__FILE__) + '/test_helper.rb'

class TestETQWStats < Test::Unit::TestCase

  def setup
  end
  
  def test_truth
    badge1 = ETQWStats::Badge.new('soldier', 1) do
			task 1, 600, 2242.95573172
			task 2, 2, 22
		end

		badge2 = ETQWStats::Badge.new('soldier', 1)
		badge2.task 1, 600, 2242.95573172
		badge2.task 2, 2, 22

		badge3 = ETQWStats::Badge.new('soldier', 2)
		badge3.task 1, 3000, 2242.95573172
		badge3.task 2, 2000, 1083
		badge3.task 3, 20, 22
		
		assert_equal badge1, badge2, "The first and second badge should be the same!"
		assert badge1 != badge3, "The first and third batch should be different!"
		assert badge2 != badge3, "The second and third batch should be different!"
  end
end
