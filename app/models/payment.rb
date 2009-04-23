class Payment < ActiveRecord::Base
  serialize :set_ec_request_params
  serialize :set_ec_response_params
  serialize :get_ec_request_params
  serialize :get_ec_response_params
  serialize :do_ec_request_params
  serialize :do_ec_response_params
  serialize :do_dp_request_params
  serialize :do_dp_response_params

  belongs_to :order

  validates_presence_of :token, :state, :method_type, :order

  attr_accessible :token, :state, :method_type, :txn_id

  attr_accessible :set_ec_request_params, :set_ec_response_params,
                  :get_ec_request_params, :get_ec_response_params,
                  :do_ec_request_params,  :do_ec_response_params,
                  :do_dp_request_params,  :do_dp_response_params

  default_scope  :order => "created_at DESC"
  named_scope :by_order, lambda {|order| {:conditions => ["order_id = ?", order.id]}}
  named_scope :by_token, lambda {|token| {:conditions => ["token = ?", token]}}
  named_scope :by_state, lambda {|state| {:conditions => ["state = ?", state]}}
  named_scope :limit,    lambda {|num|   { :limit => num } }

  state_machine :initial => 'pending' do
    event :accept do
      transition :pending => :completed
    end

    event :reject do
      transition :pending => :rejected
    end
  end
end
