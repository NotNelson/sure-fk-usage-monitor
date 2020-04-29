   class Account < ApplicationRecord
     belongs_to :user
     has_many :details

     # Current app secret key base for salting the password hash
     SALT = Rails.application.credentials.secret_key_base

     # Sure API location
     API = URI.parse('http://usage.sure.co.fk/cgi-bin/bots')

     # Encrypts the password for the current account
     # Each password is salted with a combination of the account name and the Rails app secret key base
     def encrypt_password
       cipher = OpenSSL::Cipher.new('AES-128-ECB').encrypt
       cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(self.username, SALT, 20_000, cipher.key_len)
       encrypted = cipher.update(self.password) + cipher.final
       self.password = encrypted.unpack('H*')[0].upcase
     end

     # Returns a string with the decrypted password for the HTTP request to the Sure API
     def decrypt_password
       cipher = OpenSSL::Cipher.new('AES-128-ECB').decrypt
       cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(self.username, SALT, 20_000, cipher.key_len)
       decrypted = [self.password].pack('H*').unpack('C*').pack('c*')
       self.password = cipher.update(decrypted) + cipher.final
     end

     # Requests account data to the Sure API and returns a Rails Json object
     def get_usage
       request = Net::HTTP::Get.new(API.path)
       request.basic_auth self.username, self.decrypt_password
       sock = Net::HTTP.new(API.host, API.port)
       response = sock.start { |http| http.request(request) }
       response.code == '200' ? JSON.parse(response.body) : "[]"
     end
   end