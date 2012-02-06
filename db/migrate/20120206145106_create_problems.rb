class CreateProblems < ActiveRecord::Migration

  def up
    create_table :problems do |t|
      t.string :name
      t.text :description
      t.text :hand
      t.text :answer
      t.integer :pos_11
      t.integer :pos_12
      t.integer :pos_13
      t.integer :pos_14
      t.integer :pos_21
      t.integer :pos_22
      t.integer :pos_23
      t.integer :pos_24
      t.integer :pos_31
      t.integer :pos_32
      t.integer :pos_33
      t.integer :pos_34
      t.integer :pos_41
      t.integer :pos_42
      t.integer :pos_43
      t.integer :pos_44
      t.timestamps
    end

    create_table :tags do |t|
      t.string :name
    end

    create_table :problems_to_tags do |t|
      t.references :problem
      t.references :tag
    end

  end

  def down
    drop_table :problems
    drop_table :tags
  end

end
