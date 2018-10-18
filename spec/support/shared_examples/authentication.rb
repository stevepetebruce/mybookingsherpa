RSpec.shared_examples 'authentication' do
  context 'not signed in' do
    it 'should redirect to the sign in page' do
      do_request

      expect(response).to redirect_to(new_guide_session_path)
    end
  end
end