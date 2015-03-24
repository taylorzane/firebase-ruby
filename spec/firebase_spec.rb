require 'spec_helper'

describe "Firebase" do
  let (:data) do
    { 'name' => 'Oscar' }
  end

  let (:user) do
    ['test@example.com', 'secret_password']
  end

  let (:admin) do
    ['admin@example.com', 'secret_password']
  end

  describe "invalid uri" do
    it "should raise on http" do
      expect{ Firebase::Client.new('http://test.firebaseio.com') }.to raise_error(ArgumentError)
    end

    it 'should raise on empty' do
      expect{ Firebase::Client.new('') }.to raise_error(ArgumentError)
    end
  end

  before do
    @firebase = Firebase::Client.new('https://test.firebaseio.com')
    @req = @firebase.request
  end

  describe "authentication" do
    context "with Simple Login" do
      # These shouldn't be stubbed, because test.firebaseio.com allows all except listing all users.
      it "creates a simple login user" do
        expect(@req).to receive(:create_user).with(*user)
        @firebase.create_user(*user)
      end

      it "removes a simple login user" do
        expect(@req).to receive(:remove_user).with(*user)
        @firebase.remove_user(*user)
      end

      it "lists all simple login users" do
        expect(@req).to receive(:list_users).with(5, 0, *admin)
        @firebase.list_users(5, 0, *admin)
      end

      it "authenticates a simple login user" do
        expect(@req).to receive(:auth_with_password).with(*user)
        @firebase.auth_with_password(*user)
      end
    end
  end

  describe "set" do
    it "writes and returns the data" do
      expect(@req).to receive(:put).with('users/info', data, {})
      @firebase.set('users/info', data)
    end
  end

  describe "get" do
    it "returns the data" do
      expect(@req).to receive(:get).with('users/info', {})
      @firebase.get('users/info')
    end

    it "return nil if response body contains 'null'" do
      mock_response = double(:body => 'null')
      response = Firebase::Response.new(mock_response)
      expect { response.body }.to_not raise_error
    end

    it "return true if response body contains 'true'" do
      mock_response = double(:body => 'true')
      response = Firebase::Response.new(mock_response)
      expect(response.body).to eq(true)
    end

    it "return false if response body contains 'false'" do
      mock_response = double(:body => 'false')
      response = Firebase::Response.new(mock_response)
      expect(response.body).to eq(false)
    end

    it "raises JSON::ParserError if response body contains invalid JSON" do
      mock_response = double(:body => '{"this is wrong"')
      response = Firebase::Response.new(mock_response)
      expect { response.body }.to raise_error
    end
  end

  describe "push" do
    it "writes the data" do
      expect(@req).to receive(:post).with('users', data, {})
      @firebase.push('users', data)
    end
  end

  describe "delete" do
    it "returns true" do
      expect(@req).to receive(:delete).with('users/info', {})
      @firebase.delete('users/info')
    end
  end

  describe "update" do
    it "updates and returns the data" do
      expect(@req).to receive(:patch).with('users/info', data, {})
      @firebase.update('users/info', data)
    end
  end

  describe "options" do
    it "passes custom options" do
      firebase = Firebase::Client.new('https://test.firebaseio.com', 'secret')
      expect(firebase.request).to receive(:get).with('todos', {:auth => 'secret', :foo => 'bar'})
      firebase.get('todos', :foo => 'bar')
    end
  end
end
