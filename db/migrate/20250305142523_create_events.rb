class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :nome
      t.date :data_inizio
      t.time :orario_inizio
      t.date :data_fine
      t.time :orario_fine
      t.string :paese
      t.string :indirizzo
      t.integer :max_partecipanti

      t.timestamps
    end
  end
end
