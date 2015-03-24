require 'uri'
require 'firebase/request'
require 'firebase/response'

module Firebase
  class Client
    attr_reader :request
    attr_accessor :auth

    def initialize(base_uri, auth=nil)
      if base_uri !~ URI::regexp(%w(https))
        raise ArgumentError.new('base_uri must be a valid https uri')
      end
      base_uri += '/' unless base_uri.end_with?('/')
      @request = Firebase::Request.new(base_uri)
      @auth = auth
    end

    # Writes and returns the data.
    #   Firebase.set('users/info', { 'name' => 'Oscar' }) => { 'name' => 'Oscar' }
    def set(path, data, query={})
      request.put(path, data, query_options(query))
    end

    # Returns the data at path.
    def get(path, query={})
      request.get(path, query_options(query))
    end

    # Writes the data, returns the key name of the data added.
    #   Firebase.push('users', { 'age' => 18 }) => { 'name': '-INOQPH-aV_psbk3ZXEX' }
    def push(path, data, query={})
      request.post(path, data, query_options(query))
    end

    # Deletes the data at path and returns true.
    def delete(path, query={})
      request.delete(path, query_options(query))
    end

    # Write the data at path but does not delete ommited children. Returns the data.
    #   Firebase.update('users/info', { 'name' => 'Oscar' }) => { 'name' => 'Oscar' }
    def update(path, data, query={})
      request.patch(path, data, query_options(query))
    end

    # Creates a new user for the Simple Login authentication method. Returns uid data.
    #   Firebase.create_user('email@example.com', 'password') => { 'uid': 'simplelogin:1' }
    def create_user(email, password)
      request.create_user(email, password)
    end

    def change_email(old_email, new_email, password)
      request.change_email(old_email, new_email, password)
    end

    def change_password(email, old_password, new_password)
      request.change_password(email, old_password, new_password)
    end

    def reset_password(email) # Must have password resets enabled...
      fail NotImplementedError
    end
    
    # Removes a user for the Simple Login authentication method. Returns uid data.
    #   Firebase.remove_user('email@example.com', 'password') => { 'uid': 'simplelogin:1' }
    def remove_user(email, password)
      request.remove_user(email, password)
    end

    # Lists all users for the Simple Login authentication method. Returns all Simple Login users, and some metadata.
    #   Firebase.list_users(0, 0, ENV['FIREBASE_ADMIN_EMAIL'], ENV['FIREBASE_ADMIN_PASSWORD'])
    #   => {'users' => [{'uid'=>'simplelogin:1', 'email'=>'email@example.com'}, 
    #                   {'uid'=>'simplelogin:2', 'email'=>'email2@example.com'}],
    #                  '_metadata'=>{'limit'=>5, 'offset'=>0, 'total'=>2}}
    #   NOTE: It is highly recommended to use environment variables for your admin credentials.
    def list_users(limit, offset, admin_email, admin_password)
      request.list_users(limit, offset, admin_email, admin_password)
    end

    # Authenticates Firebase by Simple Login. Returns the auth data.
    #   Firebase.auth_with_password('test@firebase.com', 'secret_password')
    #   => {'provider'=>'password', 'uid'=>'simplelogin:29', 'token'=>'LONG_TOKEN_STRING_HERE', 
    #       'password'=>{'email'=>'email@example.com', 'isTemporaryPassword'=>false}}
    #   NOTE: You must use the firebase_token_generator gem to create usable auth data.
    def auth_with_password(email, password)
      request.auth_with_password(email, password)
    end

    # Authenticates Firebase by OAuth (Facebook, Twitter, GitHub, Google). Returns auth data.
    #   Firebase.auth_with_oath('github') => Unknown?
    def auth_with_oauth(provider, request_id = nil, redirect = nil)
      request.auth_with_oauth(provider, request_id, redirect)
    end

    # Authenticates Firebase by Custom Token. Returns auth data.
    #   Firebase.auth_with_custom_token(AUTH_DATA_HERE) => Unknown?
    def auth_with_custom_token(token)
      fail NotImplementedError
    end

    # Authenticates Firebase anonymously. Returns auth data.
    #   Firebase.auth_anonymously => Unknown?
    def auth_anonymously
      fail NotImplementedError
    end

    private

    def query_options(query)
      if auth
        { :auth => auth }.merge(query)
      else
        query
      end
    end
  end
end

