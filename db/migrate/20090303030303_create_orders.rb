class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :order_number_generators do |t|
      t.integer :last_number,  :null => false
      t.integer :lock_version, :null => false
      t.timestamps
    end

    # Initialize the generator
    orderNumber = OrderNumberGenerator.create do |n|
      n.id = 0
      n.last_number = 0
      n.lock_version= 0
    end

    create_table :orders, :force => true do |t|
      t.string   :state,             :null => false, :limit => 30
      t.boolean  :has_checked_out,   :null => false, :default=> false
      t.string   :currency_code,     :null => false, :limit => 3
      t.string   :ip_address,        :null => true
      t.integer  :user_id,           :null => true
      t.datetime :placed_at,         :null => true
      t.string   :order_num,         :null => true, :limit => 15
      t.string   :token,             :null => true, :limit => 100
      t.string   :recipient,         :null => true
      t.text     :note,              :null => true
      t.decimal  :total,             :null => true, :precision => 8, :scale => 2
      t.decimal  :product_total,     :null => true, :precision => 8, :scale => 2
      t.decimal  :tax_total,         :null => true, :precision => 8, :scale => 2
      t.decimal  :shipping_total,    :null => true, :precision => 8, :scale => 2
      t.decimal  :discount_total,    :null => true, :precision => 8, :scale => 2

      t.timestamps
    end

    add_index :orders, :order_num, :unique => true
    add_index :orders, [:id, :state], :unique => true
    add_index :orders, :user_id
    add_index :orders, :token

    create_table :order_lines do |t|
      t.integer  :order_id,        :null => false
      t.string   :type,            :null => false, :limit => 30
      t.integer  :print_sequence,  :null => false, :default => 0
      t.string   :code,            :null => false, :limit => 20
      t.string   :name,            :null => false, :limit => 100
      t.string   :description,     :null => false, :limit => 255
      # assume currency refers to its order
      t.decimal  :price,           :null => false, :precision => 8, :scale => 2, :default => 0.0
      t.integer  :quantity,        :null => false, :default => 0
      t.integer  :product_id

      t.timestamps
    end

    add_index :order_lines, [:order_id, :print_sequence]
    add_index :order_lines, :product_id

    create_table :payments do |t|
      t.integer  :order_id,          :null => false
      t.string   :token,             :null => false, :limit => 100
      t.string   :state,             :null => false, :limit => 30
      t.string   :method_type,       :null => false
      t.string   :txn_id
      t.text     :set_ec_request_params
      t.text     :set_ec_response_params
      t.text     :get_ec_request_params
      t.text     :get_ec_response_params
      t.text     :do_ec_request_params
      t.text     :do_ec_response_params
      t.text     :do_dp_request_params
      t.text     :do_dp_response_params

      t.timestamps
    end

    add_index :payments, [:order_id, :state]
    add_index :payments, [:order_id, :token], :unique => true

    create_table :payment_notifications do|t|
      t.string   :token
      t.integer  :order_id
      t.string   :txn_id
      t.string   :status
      t.text     :params

      t.timestamps
    end

    add_index :payment_notifications, :txn_id
    add_index :payment_notifications, :token
    add_index :payment_notifications, :order_id

    create_table :countries do |t|
      t.string :alpha_3_code,   :limit => 3
      t.string :alpha_2_code,   :limit => 2
      t.string :name
      t.string :official_name

      t.timestamps
    end

    add_index :countries, :alpha_3_code, :unique => true
    add_index :countries, :alpha_2_code, :unique => true

    hk = Country.create do |c|
      c.id = 344
      c.alpha_3_code = "HKG"
      c.alpha_2_code = "HK"
      c.name = "Hong Kong"
      c.official_name = "Hong Kong Special Administrative Region of China"
    end
    us = Country.create do |c|
      c.id = 840
      c.alpha_3_code = "USA"
      c.alpha_2_code = "US"
      c.name = "United States"
      c.official_name = "United States of America"
    end

    create_table :addresses do |t|
      t.string      :type,             :null => true, :limit => 40
      t.integer     :addressable_id,   :null => false
      t.string      :addressable_type, :null => false
      t.string      :street_1,         :null => false
      t.string      :street_2
      t.string      :city,             :null => false
      t.string      :postal_code,      :null => false
      t.references  :country,          :null => false
      t.timestamps
    end

    add_index :addresses, [:addressable_id, :addressable_type]
    add_index :addresses, :country_id

    create_table :download_links do |t|
      t.integer  :user_upload_id,  :null => false
      t.integer  :user_id,         :null => false
      t.string   :order_num,       :null => false, :limit => 15
      t.integer  :order_id,        :null => false
      t.integer  :order_line_id,   :null => false
      t.integer  :product_id,      :null => false
      t.string   :token,           :null => false, :limit => 100
      t.datetime :last_download_at

      t.timestamps
    end

    add_index :download_links, :user_upload_id
    add_index :download_links, :user_id
    add_index :download_links, :order_id
    add_index :download_links, :order_line_id
    add_index :download_links, :product_id
    add_index :download_links, :token
  end

  def self.down
    drop_table :order_number_generators
    drop_table :orders
    drop_table :order_lines
    drop_table :countries
    drop_table :addresses
    drop_table :payments
    drop_table :payment_notifications
    drop_table :download_links
  end
end
