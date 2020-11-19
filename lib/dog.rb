class Dog

    attr_accessor :name, :breed, :id

    def initialize(attr_hash={})
        attr_hash.each do |key, value|
            self.send("#{key.to_s}=", value) 
        end
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);") 
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs;")
    end

    def save
        if self.id
            self.update
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
            DB[:conn].execute(sql, self.name, self.breed) 
            #@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self.id = DB[:conn].last_insert_row_id
        end
        self 
    end

    def self.create(hash)
        name = hash[:name]
        breed = hash[:breed]
        Dog.new(name: name, breed: breed).save 
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ? 
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL
        row = DB[:conn].execute(sql, name).flatten
        new_from_db(row)
    end
    
    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, id).flatten
        new_from_db(row)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
        SQL
        dog = DB[:conn].execute(sql, name, breed)
        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end 

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        Dog.new(id: id, name: name, breed: breed)
    end
end 

  # dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ? AND name = ? AND breed = ?", name, breed)
        # if !dog.empty?
        #   dog_data = dog[0]
        #   dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        # else
        #   dog = self.create(name: name, breed: breed)
        # end
        # dog