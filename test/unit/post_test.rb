require 'test_helper'

class PostTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  def test_should_not_save_without_title
    post = Post.new
    assert !post.save, "saved post without title"
  end
  
  def test_call_valid_ok
    post = Post.create({:title => "hi", :body => "this is a sentence"})
    assert post.valid?
  end
end
