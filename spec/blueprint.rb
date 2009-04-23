require 'faker'

Sham.fullname  { Faker::Name.last_name +  " " + Faker::Name.first_name }
Sham.login  { Faker::Name.first_name + "---" + Faker::Name.last_name }
# Sham.email { Faker::Internet.email(Faker::Name.first_name) }

User.blueprint do
  login { Sham.login }
  email "no-reply@dontrush.org"
  fullname { Sham.fullname }
  # email { Sham.email }
  password "secretpassword"
  password_confirmation "secretpassword"
  active true
  time_zone "Hong Kong"
  # login_count 1
  # perishable_token
end


Item.blueprint do
  code "ITM001"
  name "Item ITM001"
  currency_code "HKD"
  price 1.99
  rank 1
  is_published 1
  date_available 1.days.ago
  position 1
  description "This is item ITM001"
end

Package.blueprint do
  code "PKG001"
  name "Package PKG001"
  currency_code "HKD"
  price 3.88
  rank 1
  is_published 1
  date_available 1.days.ago
  position 1
  description "This is package PKG001"
end

Order.blueprint do
  state "initialized"
  has_checked_out 0
  currency_code "HKD"
end

Download.blueprint do
  id 1
  type "Download"
  instance_id 1
  position 1
  data_file_name "sample.pdf"
  data_content_type "application/pdf"
  data_file_size 1024
end

DownloadLink.blueprint do
  id 1
  user_upload_id 1
  user_id 1
  order_num "000001"
  order_id 1
  order_line_id 1
  product_id 1
  token "123"
end
