require 'httpclient'
require 'json'

module Firebase
  class Request
    def initialize(base_uri)
      @client = HTTPClient.new(base_url: base_uri)
      @client.default_header['Content-Type'] = 'application/json'
      @subdomain = base_uri.scan(/(?:https:\/\/)(?:([^.]+)\.)/)[0][0]
    end

    def get(path, query_options)
      process(:get, path, nil, query_options)
    end

    def put(path, value, query_options)
      process(:put, path, value.to_json, query_options)
    end

    def post(path, value, query_options)
      process(:post, path, value.to_json, query_options)
    end

    def delete(path, query_options)
      process(:delete, path, nil, query_options)
    end

    def patch(path, value, query_options)
      process(:patch, path, value.to_json, query_options)
    end

    def create_user(email, password)
      response = @client.request(:get, "https://auth.firebase.com/v2/#{@subdomain}/users", email: email, password: password, _method: 'POST')
      Firebase::Response.new(response)
    end

    def change_email(old_email, new_email, password)
      response = @client.request(:get, "https://auth.firebase.com/v2/#{@subdomain}/users/#{CGI.escape(old_email)}/email", oldEmail: old_email, newEmail: new_email, password: password, email: new_email, _method: 'PUT')
      Firebase::Response.new(response)
    end

    def change_password(email, old_password, new_password)
      response = @client.request(:get, "https://auth.firebase.com/v2/#{@subdomain}/users/#{CGI.escape(email)}/password", email: email, oldPassword: old_password, newPassword: new_password, password: new_password, _method: 'PUT')
      Firebase::Response.new(response)
    end

    def reset_password(email)
      fail NotImplementedError
      Firebase::Response.new(response)
    end

    def remove_user(email, password)
      response = @client.request(:get, "https://auth.firebase.com/v2/#{@subdomain}/users/#{email}", email: email, password: password, _method: 'DELETE')
      Firebase::Response.new(response)
    end

    def list_users(limit, offset, admin_email, admin_password)
      token_response = get_admin_token(admin_email, admin_password)
      token = token_response.body['adminToken'] if token_response.success?
      response = @client.request(:get, "https://auth.firebase.com/v2/#{@subdomain}/users", limit: limit, offset: offset, token: token)
      Firebase::Response.new(response)
    end

    def auth_with_password(email, password)
      response = @client.request(:get, "https://auth.firebase.com/v2/#{@subdomain}/auth/password", email: email, password: password)
      Firebase::Response.new(response)
    end
    
    def auth_with_oauth(provider, request_id = nil, redirect = nil)
      response = @client.request(:get, "https://auth.firebase.com/v2/#{@subdomain}/auth/#{provider}", requestId: request_id, redirectTo: redirect)
      Firebase::Response.new(response)
    end

    def auth_with_custom_token(token)
      fail NotImplementedError
      Firebase::Response.new(response)
    end

    def auth_anonymously
      fail NotImplementedError
      Firebase::Response.new(response)
    end

    private

    def process(method, path, body=nil, query_options={})
      response = @client.request(method, "#{path}.json", body: body, query: query_options, follow_redirect: true)
      Firebase::Response.new(response)
    end

    def get_admin_token(admin_email, admin_password)
      response = @client.request(:get, "https://admin.firebase.com/account/login", email: admin_email, password: admin_password)
      Firebase::Response.new(response)
    end
  end
end
