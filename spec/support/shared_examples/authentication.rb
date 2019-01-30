RSpec.shared_examples "authentication" do
  context "not signed in" do
    it "should redirect to the sign in page" do
      do_request

      expect(response).to redirect_to(sign_in_path)
    end
  end

  def sign_in_path
    if defined? resource_sign_in_path
      resource_sign_in_path
    else
      new_guide_session_path
    end
  end
end
