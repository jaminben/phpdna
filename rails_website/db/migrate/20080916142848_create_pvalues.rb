class CreatePvalues < ActiveRecord::Migration
  def self.up
    create_table :pvalues do |t|
      t.text :pvalue
      #t.timestamps
    end

  end

  def self.down
    drop_table :pvalues
  end
end
