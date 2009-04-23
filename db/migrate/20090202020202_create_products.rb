class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string      :type,            :null => false, :default => 'Product', :limit => 40
      t.string      :code,            :null => false, :limit => 20
      t.string      :name,            :null => false, :limit => 100
      t.string      :currency_code,   :null => false, :limit => 3
      t.decimal     :price,           :null => false, :default => 0.00, :precision => 10, :scale => 2
      t.integer     :rank,            :null => false, :default => 1
      t.boolean     :is_published,    :null => false, :default => false
      t.datetime    :date_available,  :null => true
      t.text        :description,     :null => true
      t.integer     :position,        :null => true,  :default => 1
      t.integer     :count_of_variations, :null => true, :default =>0
      t.integer     :parent_id,       :null => true

      t.timestamps
    end

    add_index :products, :parent_id
    add_index :products, [:id, :type, :is_published], :unique => true
    add_index(:products, :code, :unique => true)

    create_table :package_components do |t|
      t.integer     :package_id,    :null => false
      t.integer     :item_id,       :null => false
      t.integer     :position,      :null => false, :default => 1

      t.timestamps
    end

    add_index :package_components, [:package_id, :item_id], :unique => true
    add_index :package_components, :item_id

    create_table :user_uploads do |t|
      t.string      :type,              :null => true, :limit => 40
      t.integer     :instance_id,       :null => true
      t.integer     :position,          :null => true, :default => 1
      t.string      :data_file_name,    :null => true, :limit => 100
      t.string      :data_content_type, :null => true, :limit => 40
      t.integer     :data_file_size,    :null => true

      t.timestamps
    end

    add_index :user_uploads, [:instance_id, :type, :position]
    add_index :user_uploads, [:id, :type], :unique => true
  end

  def self.down
    drop_table :products
    drop_table :package_components
    drop_table :user_uploads
  end
end

