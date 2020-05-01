   class Account < ApplicationRecord
     belongs_to :user
     has_many :details

     # Current app secret key base for salting the password hash
     # TODO: debug for Heroku deployment
     SALT = Rails.application.credentials.secret_key_base
     #SALT = "8dh293n9d98j23o892j578xsdm8e2734"

     # Sure API location
     API = URI.parse('http://usage.sure.co.fk/cgi-bin/bots')

     def validate_account
       request = Net::HTTP::Get.new(API.path)
       request.basic_auth self.username, self.decrypt_password
       sock = Net::HTTP.new(API.host, API.port)
       response = sock.start { |http| http.request(request) }
       self.encrypt_password
       response.code == '200'
     end

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
       # Check if its been at least an hour since the last time the account was checked
       if ((Time.now - self.updated_at) / 1.hour).round >= 1 || self.details.count == 0 || self.is_updated == false
         request = Net::HTTP::Get.new(API.path)
         request.basic_auth self.username, self.decrypt_password
         sock = Net::HTTP.new(API.host, API.port)
         response = sock.start { |http| http.request(request) }
         if response.code == '200'
           details = JSON.parse(response.body)
           update_details(details)
           update_usage_data(details)
           details
         end
       else
         #update_usage_data(self.json_data)
         self.json_data
       end
     end

     def update_details(details)
       self.json_data = details
       self.name = details["name"]
       self.quota = details["quota"]
       self.total = details["total"]
       self.ratio = details["ratio"]
       self.is_updated = true
       self.encrypt_password
       self.save
     end

     def update_usage_data(data)
       if self.details.count > 0 # yes there are records details, lets update the table
         arr_len = data["daily"].length
         last_record = self.details.last.date_name
         data["daily"].each_with_index do |kv, index|
           if kv.keys[0] == last_record
            (index+1...arr_len).each do |day|
              self.details.create(
                  date_name: data["daily"][day].keys[0],
                  usage_amount: data["daily"][day].values[0])
            end
             return
           end
         end
       else
         data["daily"].each do |day|
           self.details.create(
               date_name: day.keys[0],
               usage_amount: day.values[0])
         end
       end
     end
   end
